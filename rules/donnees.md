---
paths:
  - "**/*.ipynb"
  - "**/data/**/*.py"
  - "**/etl/**/*.py"
  - "**/pipelines/**/*.py"
  - "src/ml/**/*.py"
---

# Données tabulaires — pandas

<!-- Portée partagée avec rules/ml.md sur les notebooks et src/ml/ : les deux
     se chargent, et c'est voulu. Ce fichier traite la manipulation du
     DataFrame ; ml.md traite le dataset comme objet versionné (découpage,
     fuite, reproductibilité). Un accès en base est dans rules/bdd.md.

     Si un dépôt range ses traitements ailleurs, ajouter le chemin dans la
     copie locale. -->

Une transformation de données est du code : elle se relit, se teste et se
rejoue. Un nettoyage fait à la main dans un notebook n'est pas reproductible,
donc n'a pas eu lieu.

## Regarder avant de transformer

- `df.info()` et `df.describe()` **avant** toute modification : nombre de
  lignes, types réellement inférés, taux de valeurs manquantes par colonne.
- Ce qu'on constate se note (commentaire, cellule de texte, fiche de données) :
  « 12 % de `revenu` manquant, concentré sur les contrats avant 2019 ». Sans ça,
  le choix de traitement qui suit paraît arbitraire six mois plus tard.
- Types à la lecture plutôt qu'après coup : `dtype=`, `parse_dates=`. Un code
  postal ou un numéro d'affaire lu sans `dtype=str` devient un entier — puis un
  flottant dès qu'il y a une valeur manquante, et `01300` devient `1300.0`.

## Ordre du nettoyage

Valeurs manquantes → doublons → valeurs aberrantes → encodage. Chaque étape
change ce que la suivante mesure : filtrer les aberrantes avant d'imputer fait
calculer la moyenne sur un échantillon déjà tronqué.

- `df.dropna()` sans argument supprime toute ligne ayant **une** valeur
  manquante, sur n'importe quelle colonne : sur un jeu réel, c'est souvent la
  moitié du fichier. Préciser `subset=[…]`, et regarder combien de lignes
  disparaissent.
- Imputer ou supprimer est une décision métier, pas un réflexe : une valeur
  absente peut être une information (« pas de compteur installé »), auquel cas
  elle mérite une colonne indicatrice plutôt qu'une moyenne.
- Moyenne pour une distribution symétrique, **médiane** dès qu'elle est
  asymétrique ou que des valeurs extrêmes subsistent.
- Les paramètres d'imputation (moyenne, médiane, catégorie par défaut) se
  calculent sur l'ensemble d'entraînement seul, puis s'appliquent aux autres.
  Les calculer sur le jeu complet est une fuite de données — voir `rules/ml.md`.

## Affectation

**Pas de `inplace=True`, jamais.** L'option est en voie de suppression, et sur
une sélection de colonne elle modifie une copie temporaire : l'opération ne
produit aucune erreur et n'a simplement aucun effet.

```python
df["revenu"] = df["revenu"].fillna(mediane)     # attendu
df["revenu"].fillna(mediane, inplace=True)      # sans effet, silencieusement
```

- Une sélection de lignes est une vue : la modifier déclenche un
  `SettingWithCopyWarning` ou n'a pas d'effet. `df.loc[condition, "col"] = …`
  pour écrire, `.copy()` explicite pour travailler sur un extrait.
- Pas de boucle `for` ni d'`iterrows()` sur les lignes : opérations
  vectorisées, `groupby`, `merge`. Une boucle sur cent mille lignes prend des
  minutes là où la version vectorisée prend une seconde, et se relit moins bien.

## Valeurs aberrantes

- Les détecter par l'écart interquartile (`Q1 - 1.5·IQR`, `Q3 + 1.5·IQR`) ou par
  un seuil métier — souvent le second est le bon : un relevé négatif est faux,
  une consommation dix fois supérieure à la moyenne peut être exacte.
- **Ne pas supprimer par défaut.** Une valeur extrême est parfois exactement ce
  qu'on cherche (fraude, panne, cas limite). Le seuil retenu et sa justification
  sont écrits dans le code, pas seulement appliqués.
- Le filtrage ne s'applique **jamais** au jeu de test : on ne choisit pas les
  cas sur lesquels on sera évalué.

## Variables catégorielles

- Encodage ordinal par `.map({...})` seulement quand l'ordre a un sens métier
  (`aucun` < `bac` < `bac+2`). Sinon `pd.get_dummies` / one-hot : donner des
  numéros à des modalités non ordonnées invente une distance entre elles.
- `.map()` renvoie `NaN` pour une modalité absente du dictionnaire, sans
  avertissement. Vérifier après coup (`df["col"].isna().sum()`), et prévoir ce
  qui arrive à une modalité inconnue en production.
- La table de correspondance est définie une fois, à un endroit, et réutilisée à
  l'inférence — pas recopiée dans le script de service.

## Visualisation

- Seaborn sert au **diagnostic** avant nettoyage : `histplot(kde=True)` pour une
  distribution, `boxplot` pour les valeurs extrêmes, `barplot` pour un agrégat
  par groupe, `heatmap` de corrélations pour les redondances.
- Dans un script ou en intégration continue, `plt.show()` bloque ou échoue
  faute d'affichage : `matplotlib.use("Agg")` et `savefig` vers un fichier.
- Les figures produites ne sont pas commitées : ce sont des artefacts
  régénérables. Ce qui mérite d'être conservé est joint au run MLflow.
- Aucune donnée personnelle dans un graphique ou une sortie de notebook
  conservée : les sorties de cellules sont du contenu versionné comme le reste.

## Ce qui doit finir en `.py`

Un notebook explore. Dès qu'une transformation est retenue, elle devient une
fonction dans un module, avec ses paramètres explicites (seuils, colonnes,
valeurs de remplacement) et un test sur un petit tableau construit à la main —
c'est le seul moyen de vérifier qu'un nettoyage fait ce qu'on croit.
