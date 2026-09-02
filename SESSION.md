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
| **12** | **PySpark** | **à faire — reprendre ici** |
| 13 | Machine Learning | à faire |
| 14 | Keras / PyTorch / NLP / audio / Hugging Face | à faire |
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
  à 17 restent à situer ; ceux qui toucheront `rules/ml.md` et `rules/donnees.md`
  se chargent tous deux sur les notebooks — vérifier qu'ils ne se contredisent
  pas.
- Divergence assumée ajoutée par le cours 11 : le support montre un accès
  `psycopg2` + `register_vector(conn)` direct ; le dépôt impose le type
  `pgvector.sqlalchemy.Vector(N)` via `mapped_column`, cohérent avec le style
  SQLAlchemy 2.0 déjà en place — `psycopg2` brut reste toléré pour un script
  d'exploration ponctuel seulement.
