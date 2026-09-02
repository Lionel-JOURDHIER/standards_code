---
paths:
  - "src/ml/**/*.py"
  - "**/*.ipynb"
  - "conf/**/*.yaml"
---

# Machine learning

<!-- Portée : le code ML vit sous src/ml/, ce qui garde la règle hors du reste
     du projet. Deux portées s'y ajoutent, et elles sont plus larges que
     src/ml/ : tout notebook du dépôt (**/*.ipynb), parce qu'un entraînement
     commence presque toujours là, et les configurations d'expérience
     (conf/**/*.yaml, à la racine seulement). Un notebook charge donc ml.md et
     donnees.md ensemble — voulu : donnees.md traite la manipulation du
     DataFrame, ce fichier traite le dataset comme objet versionné. -->

Un modèle n'est pas du code : il dépend de données, d'aléa et d'un
environnement. Les règles ci-dessous existent pour qu'un résultat soit
reproductible et qu'une dégradation soit détectable — pas pour ajouter de la
cérémonie.

## Framework : PyTorch ou Keras

Le choix dépend du contexte, pas d'une préférence. Les deux embarquent CUDA et
alourdissent l'environnement : un seul des deux par dépôt de modèle.

| Contexte | Framework |
|---|---|
| Recherche, prototypage, architecture non standard, débogage fin | **PyTorch** |
| Application de production, délai de mise sur le marché, écosystème de déploiement mature (TFLite, TF Serving) | **Keras / TensorFlow** |

- PyTorch : le device est explicite (`torch.device(...)`, puis `.to(device)`
  sur le modèle **et** sur chaque batch dans la boucle). L'oubli sur un batch
  ne lève pas d'erreur : le calcul continue sur CPU en silence, ou plante à la
  première opération qui mélange un tenseur CPU et un tenseur GPU.
- Keras/TensorFlow réserve tout le GPU par défaut au démarrage. Sur une
  machine partagée, limiter la croissance mémoire
  (`tf.config.experimental.set_memory_growth(gpu, True)`) avant toute autre
  opération TensorFlow.

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
- Fenêtre glissante pour un modèle séquentiel (RNN, séries temporelles) :
  chaque `X` s'arrête strictement avant l'instant que `y` doit prédire. Une
  fenêtre qui inclut ne serait-ce qu'un point contemporain ou postérieur à `y`
  fait « prédire le présent » — la métrique d'entraînement est excellente et
  le modèle est inutilisable en production.
- Validation du schéma en entrée de pipeline (colonnes, types, plages, taux de
  nuls, cardinalité). Un écart arrête le pipeline, il ne le dégrade pas
  silencieusement.

## Fuite de données

Une métrique inhabituellement bonne est un bug jusqu'à preuve du contraire.
Avant de croire un résultat :

- Normalisation, imputation et encodage ajustés sur l'entraînement seul, puis
  appliqués au reste — en pratique un `sklearn.pipeline.Pipeline` /
  `ColumnTransformer` unique, `fit` sur l'entraînement et `transform` partout
  ailleurs. C'est ce même objet, sérialisé avec le modèle, qui règle le
  § Écart entraînement / service plus bas : un seul chemin de calcul, pas deux
  implémentations à maintenir en parallèle.
- Un vectoriseur de texte (TF-IDF, `CountVectorizer`) suit la même règle :
  vocabulaire et poids appris sur l'entraînement, appliqués tels quels au
  reste. Un mot absent du vocabulaire d'entraînement est simplement ignoré à
  l'inférence — ce n'est pas une raison de réentraîner le vectoriseur sur
  l'ensemble du corpus.
- Un rééquilibrage de classes (sur-échantillonnage, SMOTE, sous-échantillonnage)
  s'applique **après** le découpage, sur l'entraînement seul. Rééquilibrer
  avant de découper duplique des exemples des deux côtés de la frontière
  train/test ; la validation et le test ne se rééquilibrent jamais, ils
  mesurent la réalité, pas un jeu artificiel.
- Aucune variable calculée à partir d'une information indisponible au moment de
  l'inférence.
- Pas de doublons ni d'objets identiques répartis entre entraînement et test.

## Recherche d'hyperparamètres

Une grille d'hyperparamètres (`GridSearchCV` ou équivalent) ne porte que sur
l'entraînement : ses plis de validation croisée se découpent **à l'intérieur**
de la partition d'entraînement, jamais sur le test gelé, qui reste réservé à la
mesure finale.

- Une recherche répétée sur le même ensemble de validation finit par le
  surapprendre : la meilleure combinaison devient la meilleure *pour cet
  échantillon-là*, pas en général. Une validation croisée imbriquée (une
  boucle externe pour l'estimation, une boucle interne pour la recherche) est
  le correctif quand le nombre d'essais est élevé.
- Le nombre de plis et la métrique d'optimisation sont écrits dans la
  configuration versionnée, pas déduits au cas par cas.
- La grille est un choix motivé (plage réaliste autour d'un ordre de grandeur
  connu), pas un balayage large « pour voir » : chaque combinaison coûte un
  entraînement complet.

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
- Classification : le choix entre précision et rappel suit le coût respectif
  d'un faux positif et d'un faux négatif (§ Humain dans la boucle), pas une
  préférence par défaut — un dépistage médical et un détecteur de fumée n'ont
  pas la même erreur à éviter en priorité, sur des matrices de confusion
  pourtant comparables.
- Régression : MAE si toutes les erreurs comptent au même poids, MSE quand une
  grosse erreur coûte disproportionnellement plus qu'une petite (elle est
  élevée au carré avant d'être moyennée). `R²` compare des modèles entre eux,
  ce n'est pas une note de qualité absolue.

## Modèles classiques — scikit-learn

- Les algorithmes fondés sur une distance (KNN, SVM, k-means, PCA) exigent
  des variables mises à la même échelle (`StandardScaler`, dans le même
  `Pipeline`/`ColumnTransformer` qu'au § Fuite de données) ; les algorithmes
  à base d'arbres (arbre de décision, Random Forest, gradient boosting/
  XGBoost) n'en ont pas besoin. Standardiser quand même n'est pas faux, mais
  masque l'oubli sur un algorithme qui, lui, en a réellement besoin.
- Méthodes ensemblistes, un choix motivé par le problème plutôt que la
  première essayée :

  | Méthode | Principe | Effet |
  |---|---|---|
  | Bagging (Random Forest) | arbres indépendants entraînés en parallèle sur des échantillons bootstrap | réduit la variance |
  | Boosting (AdaBoost, XGBoost) | arbres séquentiels, chacun corrige les erreurs du précédent | réduit le biais, plus sensible au bruit et aux valeurs aberrantes |
  | Stacking | modèles hétérogènes combinés par un méta-modèle | gagne à combiner des modèles peu corrélés entre eux ; coûteux, à éviter sur un petit jeu de données |

- Un outil AutoML (PyCaret, TPOT, AutoKeras) accélère la mise en place d'une
  baseline multi-modèle (§ Baseline) — pas un pilote automatique sans
  supervision : surveiller le surapprentissage que peut produire un balayage
  massif de combinaisons, et ne jamais promouvoir un modèle dont personne ne
  comprend le comportement.

## Apprentissage non supervisé

Le clustering et la réduction de dimension n'ont pas de vérité terrain. Le
§ Baseline ci-dessus, ainsi que le § Registry et promotion et le § Portail
qualité avant promotion situés plus bas, sont écrits pour un modèle supervisé
avec un champion à battre sur un test gelé : ils ne s'appliquent pas tels
quels.

- Le nombre de clusters (coude, silhouette) est **indicatif**, pas une preuve :
  la validation finale est un avis métier sur des clusters relus à la main, pas
  un score qu'on maximise.
- Loggé dans MLflow comme le reste (paramètres, graine, artefacts de
  visualisation), pour rester reproductible même sans métrique de décision
  unique à comparer d'un run à l'autre.
- Détection d'anomalies (Isolation Forest et équivalents) : mêmes réserves,
  pas de vérité terrain. Aucune mise à l'échelle nécessaire. Le taux de
  contamination attendu (proportion d'anomalies) est une hypothèse métier
  écrite dans la configuration, pas devinée à partir du jeu de données.

## MLflow

- Aucun entraînement hors MLflow, y compris « juste pour voir ».
- Loggés systématiquement : paramètres, métriques, configuration, signature du
  modèle, exemple d'entrée, dépendances, courbes et matrices en artefact.
- Jamais de données réelles en artefact (échantillons clients, adresses,
  coordonnées d'ouvrages).
- Tracking store (paramètres, métriques, tags — SQLite ou PostgreSQL) et
  artifact store (poids, courbes, gros fichiers — S3/MinIO) sont deux backends
  séparés. Les confondre fait grossir une base relationnelle avec des blobs, ou
  interroger un espace de stockage objet comme s'il indexait des métriques.
  Configuration concrète du backend objet (MinIO, buckets, Compose) :
  `rules/deploiement.md` § Stockage objet compatible S3.
- `log_model(model, "model", registered_model_name=...)` inscrit directement
  le modèle au Model Registry. Sans ce paramètre, le modèle reste un artefact
  du run, invisible du Registry tant que `mlflow.register_model()` n'est pas
  appelé explicitement — c'est ce geste, pas le seul `log_model`, qui rend un
  modèle éligible à la promotion (§ Registry et promotion).

## Registry et promotion

- Aucune copie manuelle d'un fichier de poids. Le seul chemin vers la production
  est le Model Registry.
- Deux familles d'URI, pas interchangeables : `runs:/<run_id>/...` pointe une
  exécution précise, pour comparer ou reproduire une expérience — jamais pour
  servir en production. Seul `models:/<nom>@<alias>` ou `models:/<nom>/<n°>`
  (Model Registry) alimente un service.
- Critères de promotion vérifiés et écrits dans la fiche modèle — une page par
  modèle promu, à partir de `modeles/FICHE-MODELE.md` (données, résultats,
  portail qualité, coût des erreurs, surveillance, retrait), versionnée à côté
  du code et mise à jour à chaque nouvelle version : bat le champion en place
  sur le test gelé, tient le budget de latence, ne régresse sur aucune tranche
  sensible.
- Un alias (`@production`, `@champion`) est préférable au numéro de version
  brut : il se lit, et il permet de changer le modèle servi sans redéployer le
  service.
- **Le service ne recharge pas le modèle à chaque appel pour autant.** À chaque
  appel, il ne pose que la question bon marché « quelle version est derrière
  l'alias ? » (`MlflowClient.get_model_version_by_alias`, un appel léger au
  Registry). Il ne recharge le modèle complet (`mlflow.pyfunc.load_model`) que
  si la réponse a changé depuis la dernière fois, et sert la **version mise en
  cache** sinon. Le modèle en mémoire reste donc figé entre deux changements
  réels de l'alias.
- Le champion précédent reste déployable. Retour arrière en une commande.

## Modèles pré-entraînés — Hugging Face

Réutiliser un modèle publié (transfer learning) est le choix par défaut dès
qu'un modèle couvre une tâche proche de celle visée : entraîner depuis zéro se
justifie par un besoin réel (domaine trop spécifique, licence incompatible),
pas par habitude. Geler le corps du modèle, n'entraîner que la tête ; ne
dégeler des couches profondes (fine tuning) que si une mesure montre que ça
sert.

- Chargement épinglé à une révision précise (`revision="<commit ou tag>"`),
  jamais la branche par défaut implicite : un modèle du Hub peut changer sous
  le même nom, sans que rien ne le signale. C'est la même exigence qu'au
  § Registry et promotion ci-dessus — savoir quelle version exacte est servie,
  et n'en changer que par un geste tracé : là un alias déplacé dans le
  Registry, ici une révision modifiée dans la configuration versionnée.
- Licence du modèle et du dataset vérifiée avant réutilisation, en particulier
  en usage commercial ou sur des données de production : toutes les licences du
  Hub ne sont pas permissives, certaines interdisent l'usage commercial ou
  imposent une attribution.
- Jeton Hugging Face en variable d'environnement, jamais en dur — même règle
  que tout autre secret (`rules/python.md` § Configuration).

## Portail qualité avant promotion

Le rapport de dérive n'est pas un tableau de bord : c'est un test qui bloque.
Evidently sépare les deux usages, pas interchangeables : un `Report` (preset
`DataDriftPreset`, `DataSummaryPreset`, `TargetDriftPreset`…) est un
diagnostic visuel pensé pour être regardé, pas pour décider tout seul. La porte
qualité automatisée est un `TestSuite` : son résultat est binaire
(succès/échec), exploitable sans intervention humaine dans un pipeline CI/CD
ou une tâche d'orchestrateur (`rules/deploiement.md` § Orchestration de
pipeline — Prefect). Avant une promotion ou une mise en service, le pipeline compare le
lot courant à la fenêtre de référence via un `TestSuite`, et lève une
exception dès qu'un test échoue. Un rapport qu'on regarde après coup ne
protège de rien.

- Le seuil est dans la configuration et dans la fiche modèle, pas dans le code
  du contrôle.
- Seuil relatif (la dérive ne doit pas être statistiquement significative — test
  de Kolmogorov-Smirnov pour une colonne numérique avec un volume suffisant,
  PSI ou Chi² pour une catégorielle, choix automatique selon le type et la
  taille, personnalisable colonne par colonne) ou seuil absolu (valeurs
  manquantes à zéro, latence sous X secondes) : le second l'emporte dès qu'une
  règle métier existe, le premier sert de filet là où aucune n'est écrite.
- `Report` et `TestSuite` sont archivés tous deux en artefact du run (JSON, et
  HTML pour le `Report`), pas seulement affichés ou exécutés puis jetés.

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
- Un snapshot Evidently (JSON léger) par exécution périodique de surveillance
  alimente un `Workspace` — distinct de l'archivage par run du § Portail
  qualité : celui-ci reproduit un run précis, le `Workspace` trace une
  tendance dans le temps (`evidently ui`, panels de dérive/latence). Les deux
  coexistent, l'un ne remplace pas l'autre.
- Chaque alerte a un destinataire et une action. Une alerte sans action est du
  bruit et finira coupée.
- Sentry pour les exceptions, Grafana pour les tendances. Ne pas alerter sur la
  dérive dans Sentry.
- Distinct de la santé du conteneur qui sert le modèle (disponibilité, charge) :
  voir `rules/deploiement.md` § Monitoring d'infrastructure.

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
