---
paths:
  - "src/ml/**/*.py"
  - "**/*.ipynb"
  - "conf/**/*.yaml"
---

# Machine learning

<!-- Portée : tout le code ML vit sous src/ml/. C'est ce qui permet à cette
     règle de ne se charger que là et de ne rien coûter au reste du projet. -->

Un modèle n'est pas du code : il dépend de données, d'aléa et d'un
environnement. Les règles ci-dessous existent pour qu'un résultat soit
reproductible et qu'une dégradation soit détectable — pas pour ajouter de la
cérémonie.

## Reproductibilité : quatre empreintes par run

Tout entraînement loggue le commit git, la version du dataset, la configuration
complète et la graine aléatoire. Un run qui n'a pas les quatre est un run perdu.

- Dépôt propre exigé avant un entraînement qui compte ; sinon le run est marqué
  `dirty` et ne peut pas être promu.
- Graines fixées et loggées (python, numpy, torch). Le déterminisme GPU complet
  a un coût : l'activer pour les runs de référence, pas pour l'exploration.
- Hyperparamètres dans un fichier de configuration versionné, jamais en dur ni
  en arguments de ligne de commande.

## Données

- Aucune donnée dans git. DVC pointe vers MinIO, le dépôt ne contient que les
  pointeurs.
- Un dataset est immuable : une correction crée une version, elle n'écrase pas.
- Le découpage train/validation/test est fait une fois, versionné, jamais refait
  à la volée. Le test est gelé et n'est regardé qu'à la fin.
- **Données géographiques : découpage spatial par zones**, jamais aléatoire.
  Deux points voisins sont corrélés ; un découpage aléatoire les répartit de part
  et d'autre et donne une métrique fausse de 10 à 30 points.
- Données horodatées : découpage temporel, entraînement sur le passé,
  évaluation sur le futur.
- Validation du schéma en entrée de pipeline (colonnes, types, plages, taux de
  nuls, cardinalité). Un écart arrête le pipeline, il ne le dégrade pas
  silencieusement.

## Fuite de données

Une métrique inhabituellement bonne est un bug jusqu'à preuve du contraire.
Avant de croire un résultat :

- Normalisation, imputation et encodage ajustés sur l'entraînement seul, puis
  appliqués au reste. Pas d'ajustement sur l'ensemble des données.
- Aucune variable calculée à partir d'une information indisponible au moment de
  l'inférence.
- Pas de doublons ni d'objets identiques répartis entre entraînement et test.

## Baseline

- Avant tout modèle : une baseline triviale (classe majoritaire, dernière valeur
  connue, règle métier existante, régression linéaire), loggée dans MLflow comme
  un run à part entière.
- Un modèle qui ne bat pas la baseline ne va pas plus loin.
- Le gain se compare au coût qu'il introduit — latence, dépendance CUDA,
  maintenance — pas seulement à la métrique.

## Métriques

- La métrique de décision est choisie et écrite **avant** l'entraînement.
- Exactitude interdite comme métrique unique sur classes déséquilibrées.
- Toujours reporter par tranche (zone, type d'ouvrage, source de données), pas
  seulement l'agrégat : un modèle correct en moyenne peut être inutilisable sur
  un segment.
- Pour départager deux modèles proches, plusieurs graines et l'écart-type. Un
  écart de trois dixièmes de point sur un run unique n'est pas un résultat.

## MLflow

- Aucun entraînement hors MLflow, y compris « juste pour voir ».
- Loggés systématiquement : paramètres, métriques, configuration, signature du
  modèle, exemple d'entrée, dépendances, courbes et matrices en artefact.
- Jamais de données réelles en artefact (échantillons clients, adresses,
  coordonnées d'ouvrages).

## Registry et promotion

- Aucune copie manuelle d'un fichier de poids. Le seul chemin vers la production
  est le Model Registry.
- Critères de promotion vérifiés et écrits dans la fiche modèle : bat le champion
  en place sur le test gelé, tient le budget de latence, ne régresse sur aucune
  tranche sensible.
- La production charge une **version figée** par URI, pas un stage résolu
  dynamiquement : sinon une promotion change le comportement en production sans
  déploiement.
- Le champion précédent reste déployable. Retour arrière en une commande.

## Portail qualité avant promotion

Le rapport de dérive n'est pas un tableau de bord : c'est un test qui bloque.
Avant une promotion ou une mise en service, le pipeline compare le lot courant à
la fenêtre de référence (Evidently, `Report` sur un preset de dérive ou de
qualité), extrait les métriques du snapshot et lève une exception si un seuil
métier est franchi. Un rapport qu'on regarde après coup ne protège de rien.

- Le seuil est dans la configuration et dans la fiche modèle, pas dans le code
  du contrôle.
- Le rapport est archivé en artefact du run (JSON + HTML), pas seulement affiché.

## Écart entraînement / service

- Le calcul des variables est un module unique importé des deux côtés. Deux
  implémentations donnent deux comportements, et l'écart se découvre en
  production.
- Un test vérifie qu'une même entrée donne la même sortie par le chemin
  d'entraînement et par le chemin de service.

## Tests

Le taux de couverture ne dit rien de la qualité d'un modèle. Ce qui se teste :

- Schéma et forme des sorties de chaque étape du pipeline.
- Non-régression sur un mini-jeu synthétique commité (quelques dizaines de
  lignes), rejoué à chaque modification du pipeline.
- Comportement : invariances attendues, cas connus étiquetés à la main.
- Sérialisation : modèle sauvegardé puis rechargé, prédictions identiques.
- L'entraînement réel est marqué `@pytest.mark.slow` et exclu du run par défaut.
- Ne pas tester la valeur exacte d'une métrique — tester un plancher.

## Surveillance en production

Dans l'ordre de ce qui casse en premier :

1. **Disponibilité et latence** (Prometheus) : p95, taux d'erreur.
2. **Dérive des entrées** : distribution par variable contre la fenêtre de
   référence (le jeu d'entraînement), calculée par lot quotidien, pas par requête.
3. **Dérive des sorties** : distribution des prédictions et des scores de
   confiance. Signal le moins cher et souvent le plus précoce.
4. **Performance réelle** : seulement quand la vérité terrain arrive. Sur des
   données réseau elle arrive avec des semaines de retard — le circuit de retour
   (qui corrige, où c'est stocké, sous quel délai) se conçoit au début du projet,
   pas après la mise en production.
5. **Volume de cas abstenus** sous le seuil de confiance.

- Toute prédiction est tracée : entrée ou son empreinte, version du modèle,
  sortie, score, horodatage. Sans ça aucun incident n'est analysable.
- Chaque alerte a un destinataire et une action. Une alerte sans action est du
  bruit et finira coupée.
- Sentry pour les exceptions, Grafana pour les tendances. Ne pas alerter sur la
  dérive dans Sentry.

## Réentraînement

- Déclenché par un signal (dérive, dégradation mesurée, volume de nouvelles
  données), pas par un calendrier.
- Un modèle réentraîné repasse par les mêmes critères de promotion. Aucune
  promotion automatique.
- Changement d'architecture : passage en observation parallèle sur du trafic réel
  avant bascule.

## Humain dans la boucle

- Un modèle produit une proposition, pas une vérité. Le seuil de confiance
  en dessous duquel un cas part en revue humaine est dans la configuration et son
  volume est suivi.
- Le coût d'un faux positif et celui d'un faux négatif sont écrits dans la fiche
  modèle. Ce sont eux qui déterminent le seuil, pas l'inverse.

## Notebooks

- Exploration uniquement. Aucun import depuis un notebook dans le code de
  production.
- Sorties nettoyées avant commit : sinon le diff est illisible et des données
  réelles finissent dans git.
- Ce qui mérite d'être gardé sort du notebook et devient une fonction testée.
