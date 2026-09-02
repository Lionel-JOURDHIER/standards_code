# SESSION.md — standards-code

## [2026-09-02] — Revue des supports de formation, cours 1 à 10

**Branche :** `develop` (toutes les tâches fusionnées, rien en cours)

### Où on en est

Traversée du corpus de formation (40 documents, extraits en texte dans
`Support/`), **un cours après l'autre**. Pour chacun : dire où la bonne pratique
se retrouve déjà dans les `.md` du dépôt, nommer les divergences assumées, puis
combler les manques « au lieu le plus logique ».

| # | Cours | État |
|---|---|---|
| 1 | Python — cookbook | fait |
| 2 | DocString | fait |
| 3 | Logging | fait |
| 4 | Pytest / Loguru | fait |
| 5 | Git | fait (+ `.gitignore` à la demande) |
| 6 | GitHub Actions CI | fait |
| 7 | Sphinx | fait (+ modèle de README, servir le HTML, config outillage) |
| 8 | Pandas / Seaborn | fait |
| 9 | Pandas — mon premier CRUD | fait |
| 10 | SQLAlchemy | fait |
| 11 | pgvector | fait |
| 12 | PySpark | fait |
| 13 | Machine Learning | fait |
| **14** | **Keras / PyTorch / NLP / audio / Hugging Face** | **à faire — reprendre ici** |
| 15 | MLflow | à faire |
| 16 | MLOps 0 → 4 | à faire |
| 17 | Evidently | à faire |
| 18 | Sécurité en Python | à faire |
| 19 | hash / cryptage | à faire |
| 20 | Sécuriser une API FastAPI | à faire |
| 21 | Vault 1 & 2 | à faire |
| 22 | Streamlit | à faire |
| 23 | Selenium | à faire |
| 24 | Redmail | à faire |
| 25 | Workflow I | à faire |

Cours 11 (pgvector) traité : nouvelle section « Recherche vectorielle —
pgvector » dans `rules/bdd.md`, entre Modèles et Requêtes (commit `feat :
recherche vectorielle pgvector dans bdd.md`, fusionné dans `develop`). Pas de
nouveau fichier de règle — treize règles inchangé.

Cours 12 (PySpark) traité : nouvelle section « Passage à l'échelle — PySpark »
dans `rules/donnees.md`, juste avant « Ce qui doit finir en `.py` » (commit
`feat : passage à l'échelle PySpark dans donnees.md`, fusionné dans
`develop`). Pas de nouveau fichier de règle — treize règles inchangé, mêmes
chemins de portée (`etl/`, `pipelines/`, `data/`) déjà suffisants.

Cours 13 (Machine Learning) traité : `rules/ml.md` couvrait déjà l'essentiel
du cours (découpage train/val/test, fuite de données, choix de métrique,
MLflow, portail qualité, promotion) à un niveau plus exigeant que le support —
le cours est resté surtout théorique (définitions précision/rappel/F1,
formules MSE/MAE, pipeline ML générique). Trois manques concrets comblés dans
`rules/ml.md` (commit `feat : pipeline sklearn, recherche d'hyperparamètres et
non supervisé dans ml.md`, fusionné dans `develop`) :
- § Fuite de données : nomme l'outil concret (`sklearn.pipeline.Pipeline` /
  `ColumnTransformer`) qui applique la règle déjà écrite, plus une règle neuve
  sur le rééquilibrage de classes (SMOTE / sur- et sous-échantillonnage) —
  absent du fichier, sur l'entraînement seul et après le découpage.
- Nouvelle section « Recherche d'hyperparamètres » (GridSearchCV) : plis de
  validation croisée bornés à l'entraînement, jamais le test gelé ; validation
  croisée imbriquée si la recherche est répétée.
- § Métriques : deux bullets, choix précision/rappel selon le coût
  faux positif/négatif (renvoi à § Humain dans la boucle), MAE vs MSE en
  régression.
- Nouvelle section « Apprentissage non supervisé » (clustering, réduction de
  dimension) : signale que Baseline/Registry/Portail qualité, écrits pour du
  supervisé avec un champion à battre, ne s'appliquent pas tels quels ; le
  nombre de clusters (coude/silhouette) reste indicatif.
Pas de nouveau fichier de règle — treize règles inchangé.

### Décisions techniques prises pendant la revue

- **loguru est obligatoire** (demande explicite, 2026-09-02). Ce n'est plus « un
  mécanisme par projet » : la seule dérogation est un programme sans journal du
  tout, et elle s'écrit.
- **SQLAlchemy** : constat fait sur les dépôts voisins — bibliothèque 2.0.48
  installée partout, style 1.x écrit dans `Brief02_BDD`, `Brief03_appweb`,
  `Brief04`, style 2.0 dans `HorRAGor_2`, aucun projet en asynchrone. Décision :
  **1.x toléré** (un projet écrit en 1.x y reste), **2.0 pour le neuf**, jamais
  les deux dans le même dépôt ; **sync/async selon le contexte** (script et
  notebook en synchrone, API FastAPI en asynchrone).
- **Le README ne porte pas de bonnes pratiques** : ce qui est convention va dans
  `rules/`, le README ne décrit que le projet.
- Divergences assumées vis-à-vis des cours, réaffirmées : `uv` et jamais `pip` ;
  pas de type répété dans la docstring ; pas d'exemple d'utilisation dans une
  docstring ; `hashlib` exclu pour un mot de passe ; Gitea et non GitHub, donc
  pas de GitHub Pages, pas d'OIDC, `permissions:` ignorée.

### Fichiers modifiés ou créés

**Nouveaux (3 règles, 1 modèle) :**
- `rules/tests-python.md` — pytest, seul endroit où le DRY du socle ne
  s'applique pas.
- `rules/documentation.md` — Sphinx, accès depuis le README, publication.
- `rules/donnees.md` — pandas et seaborn ; un DataFrame n'est pas un stockage.
- `modeles/modele-README.md` — squelette de README à copier.

**Modifiés :**
- `socle-code.md` — méthode (entrées/sorties avant le corps), Git Flow
  (`pull --ff-only`, durée de vie d'une branche, un commit = une unité,
  `user.name`/`user.email`, `Co-Authored-By` systématique), sous-section
  `.gitignore`.
- `rules/python.md` — structure d'un projet, classes, docstrings
  (`Attributes:`, pas d'exemples), journalisation (loguru obligatoire,
  `logger.remove()`, dev/prod, `logger.exception`, rotation, pas de log en
  boucle serrée, aucun secret), **mots de passe et saisie sensible**,
  configuration de ruff.
- `rules/tests-python.md` — `TestClient`, pas de `sys.path.insert`,
  `[tool.pytest.ini_options]`, couverture hors des options par défaut.
- `rules/cicd.md` — version de Python alignée, un seul appel `pytest`, une CI
  vérifie et ne corrige pas, section « Un échec doit bloquer ».
- `rules/bdd.md` — deux styles 1.x/2.0, sync ou async, `session.dispose()`
  n'existe pas, conception Merise, `WHERE`/`HAVING`, `echo=True` hors livré,
  section « Recherche vectorielle — pgvector » (extension activée en migration
  Alembic, `pgvector.sqlalchemy.Vector(N)` plutôt que `psycopg2` brut,
  opérateur de distance selon le cas d'usage, index ANN HNSW/IVFFlat obligatoire
  au-delà de ~10 000 lignes, `EXPLAIN (ANALYZE, BUFFERS)` pour vérifier).
- `rules/donnees.md` — section « Passage à l'échelle — PySpark » (seuil réel
  avant de quitter pandas, une seule `SparkSession`, `JAVA_HOME`/`HADOOP_HOME`
  hors du code, Parquet et schéma explicite plutôt que `inferSchema`,
  `partitionBy` sur une colonne à faible cardinalité, fonctions natives plutôt
  qu'UDF Python, paresse des transformations et `collect()` réservé à un
  agrégat, tests sur `SparkSession` locale).
- `README.md`, `modeles/modele-CLAUDE.md` — **treize règles** désormais.

### Vérifié

- Chaque tâche : commit typé sur une branche `feature/*`, fusion
  `git merge --no-ff` dans `develop`, branche supprimée. Arbre propre.
- Rien n'a été poussé, `main` n'a pas bougé (reste à `2060bf9`).
- Pas de relecture croisée automatisée des `.md` : la cohérence entre fichiers
  a été vérifiée à la main, au fil des ajouts.

### Points de vigilance pour la suite

- **Journal détaillé des modifications** (cours par cours, pour le résumé final
  demandé) :
  `/tmp/claude-1000/-home-lionel-DEVIA-Support/63e8616f-5aba-4486-ab3b-59843e06dc40/scratchpad/journal-revue-cours.md`
  — répertoire de session, à recopier ailleurs s'il doit survivre.
- Extraits texte des 40 supports : `…/scratchpad/txt/*.txt`.
- Deux vérifications empiriques jamais faites : le hook `InstructionsLoaded`
  pour confirmer ce qui se charge réellement, et si les commentaires HTML sont
  retirés dans `rules/*.md` (documenté seulement pour `CLAUDE.md`).
- `rules/cicd.md` garde une section « À vérifier sur notre instance » : trois
  points Gitea non tranchés (`success()`/`hashFiles()`, `actions/cache`, lecture
  de `.github/workflows`).
- Le format des badges Gitea dans `modeles/modele-README.md` est à confirmer sur
  l'instance réelle.
- Cours 11 (pgvector) a fini dans `rules/bdd.md`, pas `rules/ml.md` : c'est une
  extension PostgreSQL/SQLAlchemy, pas un sujet de cycle de vie modèle. Cours 12
  (PySpark) a fini dans `rules/donnees.md`, aux côtés de pandas plutôt que dans
  `rules/ml.md`. Cours 13 à 17 restent à situer ; ceux qui toucheront
  `rules/ml.md` et `rules/donnees.md` se chargent tous deux sur les notebooks —
  vérifier qu'ils ne se contredisent pas.
- Divergence assumée ajoutée par le cours 11 : le support montre un accès
  `psycopg2` + `register_vector(conn)` direct ; le dépôt impose le type
  `pgvector.sqlalchemy.Vector(N)` via `mapped_column`, cohérent avec le style
  SQLAlchemy 2.0 déjà en place — `psycopg2` brut reste toléré pour un script
  d'exploration ponctuel seulement.
- Divergence assumée ajoutée par le cours 12 : le support fait
  `os.environ["JAVA_HOME"] = chemin` en dur dans le script Python ; le dépôt
  renvoie cette variable d'environnement (comme `HADOOP_HOME`) au périmètre du
  poste/conteneur, pas au code, en application de la règle déjà écrite dans
  `rules/python.md` § Configuration.
- Le support PySpark est court (une page de commandes de base) : la règle
  écrite va au-delà du contenu du cours sur le shuffle/partitionnement et les
  UDF, à partir de connaissances générales PySpark plutôt que d'un point du
  support — à signaler si Lionel veut border strictement aux cours.
- Divergence assumée, cours 13 : le support présente la réduction de dimension
  (PCA) comme un moyen d'« anonymat des données (RGPD) ». Affirmation non
  reprise — réduire des dimensions n'anonymise pas au sens RGPD (ré-
  identification possible, pas de garantie d'irréversibilité) — et aucune
  règle PCA n'a été ajoutée : ni ml.md ni donnees.md ne couvrent la réduction
  de dimension pour l'instant, seul le clustering/non-supervisé l'a été.
- Cours 14 (Keras/PyTorch/NLP/audio/Hugging Face) va aussi toucher `rules/ml.md`
  (deep learning, au-delà du scikit-learn implicite des sections existantes) —
  vérifier qu'il ne contredit pas les ajouts du cours 13 avant d'écrire.
