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
| 14 | Keras / PyTorch / NLP / audio / Hugging Face | fait |
| 15 | MLflow | fait |
| 16 | MLOps 0 → 4 | fait |
| 17 | Evidently | fait |
| 18 | Sécurité en Python | fait |
| 19 | hash / cryptage | fait |
| 20 | Sécuriser une API FastAPI | fait |
| 21 | Vault 1 & 2 | fait |
| 22 | Streamlit | fait |
| 23 | Selenium | fait |
| 24 | Redmail | fait |
| 25 | Workflow I | fait |

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

Cours 14 (Keras/PyTorch/NLP/audio/Hugging Face, 5 supports) traité : la
majeure partie du contenu est théorique (maths du signal audio — Fourier,
fenêtrage, biologie de l'audition ; fondamentaux réseau de neurones —
neurone, activation, loss, optimiseurs) et hors du périmètre « convention de
code » de ce dépôt, comme la théorie pure du cours 13. Quatre ajouts concrets
dans `rules/ml.md` (commit `feat : PyTorch/Keras, fenêtre glissante,
vectoriseur texte, modèles pré-entraînés dans ml.md`, fusionné dans
`develop`) :
- Nouvelle section « Framework : PyTorch ou Keras », en tête de fichier (même
  esprit que « Deux styles » de `bdd.md`) : tableau de contexte repris du
  support (recherche/contrôle -> PyTorch, production/déploiement -> Keras,
  conclusion du support lui-même, cohérente avec l'unique dépôt deep learning
  connu — `MNIST_01`, en PyTorch) ; gestion explicite du device PyTorch ;
  `set_memory_growth` côté Keras.
- § Données : bullet neuf sur la fenêtre glissante d'un modèle séquentiel
  (RNN) — ne pas « prédire le présent », renvoi au piège du support.
- § Fuite de données : bullet neuf sur le vectoriseur de texte (TF-IDF,
  `CountVectorizer`), même règle fit-train/transform-reste que le
  `ColumnTransformer` déjà écrit au cours 13.
- Nouvelle section « Modèles pré-entraînés — Hugging Face », après Registry
  et promotion : transfer learning par défaut plutôt qu'entraîner from
  scratch ; `revision=` épinglée (même principe que la version figée MLflow) ;
  licence du modèle/dataset vérifiée avant réutilisation ; jeton HF en
  variable d'environnement.
Pas de nouveau fichier de règle — treize règles inchangé.

Cours 15 (MLflow) traité : le support est un tutoriel minimal (`start_run`,
`log_metric`, `log_param`, `log_model(model, "model")` sans
`registered_model_name`, rechargement par `runs:/<run_id>/...`) — MLflow
Tracking seulement, ni Registry ni promotion. `rules/ml.md` couvrait déjà
l'esprit (rien hors MLflow, artefacts systématiques, Registry comme seul
chemin vers la production) mais pas le geste mécanique qui relie un run au
Registry. Ajouts dans `rules/ml.md` (commit `feat : tracking/artifact store,
registered_model_name et alias figé dans ml.md`, fusionné dans `develop`) :
- § MLflow : séparation tracking store (SQLite/PostgreSQL) / artifact store
  (S3/MinIO) — présente dans le CLAUDE.md racine du dossier de formation mais
  absente de `rules/ml.md` jusqu'ici ; `registered_model_name=` sur
  `log_model` (ou `mlflow.register_model()` explicite) comme geste qui fait
  passer un modèle de simple artefact de run à entrée du Registry.
- § Registry et promotion : distinction explicite `runs:/<run_id>/...`
  (reproduire une expérience, jamais la production) vs `models:/<nom>@<alias>`
  ou `models:/<nom>/<n°>` (Registry, seule source de production) — le cours
  utilise justement `runs:/` pour recharger un modèle, ce qui aurait pu passer
  pour un patron valable en production sans cette clarification.
- **Reconciliation avec le CLAUDE.md racine** (`/home/lionel/DEVIA/Support/CLAUDE.md`,
  section MLOps § MLflow) : ce fichier recommande explicitement un alias
  (`models:/{name}@{alias}`) avec « cache invalidé si l'alias change de
  version », alors que `rules/ml.md` disait jusqu'ici « version figée par URI,
  pas un stage résolu dynamiquement » — lecture proche d'une contradiction. La
  règle est reformulée pour tenir les deux : alias préféré au numéro de
  version brut pour la lisibilité, mais résolu une fois (démarrage ou
  événement explicite d'invalidation), jamais à chaque appel — la « version
  figée » désigne ce qui tourne en mémoire entre deux invalidations, pas une
  interdiction des alias.
Pas de nouveau fichier de règle — treize règles inchangé.

Cours 16 (MLOps 0 → 4, 7 supports — Intro, Packaging, Orchestration, Factory,
Automation, Monitoring, Advanced ; `Copie_de_MLOPS_4_Advanced.pptx` écarté :
brouillon tronqué du même support, sans contenu propre) traité. `MLOPS_0_Intro`
et `MLOPS_0_PACKAGING` ne font que confirmer, sans rien ajouter, ce qui est
déjà écrit dans `rules/python.md` (uv, ruff, dependency-groups),
`rules/tests-python.md` et `rules/cicd.md` (structure de la CI). Le reste
(Compose, MinIO, Prefect, Celery, Kubernetes) n'avait de domicile dans aucune
règle existante — vérification faite contre le `CLAUDE.md` racine du dossier
de formation (point de vigilance laissé au cours 15) : son § MLOps couvre les
mêmes sujets sans contredire ce qui suit, une fois l'alias MLflow reformulé au
cours 15. **Nouveau fichier `rules/deploiement.md`** (commit `feat : nouvelle
règle deploiement.md — Docker, Compose, Prefect, Celery, Kubernetes`, fusionné
dans `develop`) — quatorzième règle du dépôt, `README.md` et
`modeles/modele-CLAUDE.md` mis à jour en conséquence (le second listait
« onze » alors qu'il énumérait déjà treize noms : incohérence préexistante
corrigée au passage) :
- § Dockerfile : image `uv` officielle, `pyproject.toml`/`uv.lock` copiés avant
  le reste du code pour le cache de build, `.dockerignore`, aucun secret figé
  en `ENV`, modèle/dataset jamais copiés dans l'image (montés en volume —
  cohérent avec le `CLAUDE.md` racine § Packaging).
- § Docker Compose : `.env`/`.env.example`, une variable n'atteint un service
  que si son bloc `environment:` la référence, volume nommé pour ce qui doit
  survivre à `down`, limite mémoire par service, réseau dédié pour isoler ce
  qui doit se parler — renvoi à `rules/securite-api.md` sur l'esprit
  moindre-privilège.
- § Stockage objet — MinIO : une instance, deux buckets (DVC / MLflow),
  création de bucket idempotente, identifiants en variable d'environnement.
- § Orchestration — Prefect : `@flow`/`@task`, `retries` sur ce qui dépend
  d'un réseau, `cache_key_fn` ; `.serve()` réservé au développement,
  `prefect deploy` + `prefect.yaml` (work pool, worker persistant) en
  production ; rappel que les règles de `rules/ml.md` s'appliquent toujours
  à l'intérieur de chaque tâche orchestrée.
- § Celery : `.delay()` pour ne jamais bloquer une requête sur un traitement
  lourd, arbitrage Redis (rapide, sans garantie) / RabbitMQ (livraison
  confirmée), Flower comme seul point de visibilité, nommage des workers
  incompatible avec le scaling horizontal.
- § Kubernetes : Kubernetes ne construit pas d'image (Compose reste l'étape de
  validation locale avant migration), `Deployment`+`Service` comme paire
  indissociable reliée par étiquette, HPA limité au CPU/RAM (KEDA pour la
  profondeur de file), `describe pod` pour ce que les logs ne montrent pas.
- § Publication d'image en CI : registre interne plutôt que Docker Hub,
  renvoi à `rules/cicd.md` § Jetons et secrets (pas d'OIDC disponible).
- § Monitoring d'infrastructure : distingue explicitement de `rules/ml.md`
  § Surveillance en production — santé du conteneur contre justesse du modèle,
  ni l'un ni l'autre ne dispense du second.

Deux affinages et un ajout dans `rules/ml.md` à cette occasion :
- § Registry et promotion : le bullet sur l'alias figé (reformulé au cours 15)
  est précisé avec le mécanisme concret montré par le support — vérification
  légère de la version derrière l'alias (`get_model_version_by_alias`) à
  chaque appel, rechargement du modèle complet seulement si elle a changé. Ne
  change pas la règle, la rend vérifiable contre un exemple de code réel.
- § MLflow et § Surveillance en production : un renvoi croisé chacun vers
  `rules/deploiement.md` (stockage objet ; monitoring infrastructure).

`rules/cicd.md` § Jetons et secrets gagne un bullet sur le scan de secrets
(Gitleaks), absent jusqu'ici : `fetch-depth: 0`, échec bloquant, et le rappel
qu'un secret poussé reste compromis même corrigé ensuite — seule la rotation
répare, cohérent avec la section déjà en place sur la rotation des jetons
Gitea.

Non retenu du cours 16, hors périmètre : Gitleaks lui-même n'est pas détaillé
au-delà de son usage en CI (pas d'outil de scan local) ; Kafka (Producer/
Consumer/Topic, `MLOPS_4_Advanced` slides 3-10) écarté — présenté comme notion
générale de streaming, sans lien avec le reste du corpus (pas de Kafka ailleurs
dans les 25 cours) ni avec un besoin déjà écrit dans les règles ; Uptime Kuma
et le détail Prometheus/Grafana (fichiers de config, dashboards) restent au
niveau du principe (§ Monitoring d'infrastructure) plutôt que de la recette,
la configuration precise d'un exporter Python n'étant pas montrée dans le
support.

Cours 17 (Evidently, 1 support) traité : deck conceptuel court — vocabulaire
(Report/Metric/Preset, TestSuite, Workspace/Snapshot/Panel/Evidently UI),
moteur statistique de la dérive, points d'intégration dans le cycle MLOps
(CI/CD, orchestrateurs, dashboard de production) — sans slide de code (la
diapositive « Démo de Code » est vide dans l'extraction, démo live non
capturée). `rules/ml.md` § Portail qualité couvrait déjà Evidently comme
porte bloquante, mais en confondant implicitement `Report` et le mécanisme de
blocage. Deux affinages, pas de gap nouveau au sens d'un concept absent
(commit `feat : Report vs TestSuite, tests statistiques et Workspace
Evidently dans ml.md`, fusionné dans `develop`) :
- § Portail qualité avant promotion : `Report` (diagnostic visuel,
  `DataDriftPreset`/`DataSummaryPreset`/`TargetDriftPreset`) et `TestSuite`
  (résultat binaire, l'outil réellement fait pour bloquer un pipeline) sont
  désormais distingués — la porte qualité s'appuie sur un `TestSuite`, pas sur
  un `Report` dont on extrait les métriques à la main. Bullet neuf sur le choix
  du test statistique de dérive (Kolmogorov-Smirnov pour une colonne
  numérique, PSI ou Chi² pour une catégorielle, choix automatique selon
  type/volume) derrière un seuil relatif, distingué du seuil absolu déjà
  écrit.
- § Surveillance en production : bullet neuf sur le `Workspace` et les
  snapshots JSON comme historique continu (`evidently ui`), distinct de
  l'archivage par run du Portail qualité — les deux coexistent.
- `rules/deploiement.md` § Orchestration — Prefect : bullet neuf reliant le
  `TestSuite` Evidently à une `@task` ordinaire, cohérent avec le point
  d'intégration « orchestrateur » du support (bloquer entraînement/inférence
  en aval d'une anomalie détectée sur les données entrantes).
Pas de nouveau fichier de règle — quatorze règles inchangé.

Non retenu du cours 17, hors périmètre : la panne silencieuse du ML (Data
Drift/Concept Drift/qualité des données comme motivation) reste du contexte,
pas une convention actionnable au-delà de ce qui est déjà écrit ; la
« polyvalence » annoncée vers le texte (NLP) et les logs LLM/RAG n'est pas
creusée — aucune recette concrète donnée par le support au-delà de
l'affirmation, et aucun besoin identifié dans le corpus pour l'instant.

Cours 18 (Sécurité en Python, 1 support) traité : le support lui-même n'est
qu'un plan de onze lignes (API, JWT, rappel FastAPI, OAuth2 et
rafraîchissement, 401/403, pas de mot de passe stocké, JWT pas de secret, JWT
décodé le plus paramétré possible) — aucun de ces points n'est développé,
c'est l'annonce des cours 19 (hash/cryptage) et 20 (Sécuriser une API
FastAPI). `rules/securite-api.md` couvre déjà chacun de ces points en détail
(le fichier existait avant le début de cette revue systématique, sourcé
directement du kit « Sécuriser une API FastAPI ») et `rules/python.md` §
Mots de passe et saisie sensible couvre le stockage. Un seul manque réel
trouvé en confrontant le plan à `rules/securite-api.md` (commit `feat :
Authorization Code + PKCE plutôt que Resource Owner Password Grant`, fusionné
dans `develop`) :
- § Sessions : access + refresh gagne un bullet en tête sur le choix du grant
  OAuth2 — Authorization Code + PKCE plutôt que Resource Owner Password
  Grant, déjà énoncé dans le CLAUDE.md racine mais absent de
  `rules/securite-api.md`, qui ne détaillait que la mécanique access/refresh
  une fois les jetons obtenus, pas comment ils le sont. Piège nommé
  explicitement : le tutoriel officiel FastAPI (`OAuth2PasswordRequestForm`)
  enseigne justement le grant mot de passe.
Pas de nouveau fichier de règle — quatorze règles inchangé.

Non retenu du cours 18, hors périmètre : rien d'autre à retenir — le plan est
trop court pour receler d'autre divergence ou complément que celui listé
ci-dessus ; les points 401/403, JWT sans secret dans le payload et décodage
paramétré sont déjà couverts mot pour mot par `rules/securite-api.md`.

Cours 19 (hash / cryptage, 1 support) traité : **aucune modification de
règle**. Le support couvre trois volets — hachage de mot de passe (mauvais
exemple `hashlib.sha256` + comparaison par `==`, puis Werkzeug
`generate_password_hash`/`check_password_hash`), chiffrement symétrique
(`cryptography.Fernet`) et asymétrique (RSA/OAEP, `cryptography.hazmat`) — et
chacun est déjà couvert mot pour mot :
- `rules/python.md` § Mots de passe et saisie sensible interdit déjà
  `hashlib.sha256` pour un mot de passe et impose la comparaison par la
  fonction de vérification de la bibliothèque, jamais par `==` — exactement
  l'anti-patron du support (`verifier_mot_de_passe` fait `== ` sur les hash
  recalculés).
- `rules/securite-api.md` § Chiffrement des données couvre déjà Fernet
  (symétrique) et RSA/OAEP 2048 bits (asymétrique) au même niveau de détail
  que le support, clés hors code incluses.
- La combinaison décrite par le support (asymétrique pour échanger une clé,
  symétrique pour chiffrer le volume) reste une remarque conceptuelle, pas un
  geste de code distinct à encoder en règle.
- La suggestion du support d'ajouter un `try/except` autour du
  chiffrement/déchiffrement est déjà couverte, en général et pas
  spécifiquement à la crypto, par `rules/python.md` § Gestion des exceptions
  (pas de `except:`/`except Exception:` nu, remontée jusqu'au point d'entrée).

**Divergence assumée** : le support liste `SHA-256` comme fonction de
hachage « sécurisée » au même titre que `bcrypt` pour un mot de passe
(« Utilisez toujours une fonction de hachage cryptographique sécurisée comme
SHA-256 ou bcrypt »). C'est inexact pour ce cas d'usage précis — SHA-256 est
volontairement rapide, donc forçable à haute vitesse, ce qui est justement la
raison pour laquelle `rules/python.md` l'exclut explicitement pour un mot de
passe (bcrypt/pwdlib est lent par conception). Règle du dépôt maintenue telle
quelle, aucune reformulation : SHA-256 reste approprié pour de l'intégrité
(empreinte de fichier) mais pas pour un mot de passe. Werkzeug (deuxième
exemple du support) n'est pas ajouté à la liste des bibliothèques écartées à
côté de `passlib` : contrairement à `passlib`, rien n'indique qu'il soit mal
maintenu ou insuffisamment salé — l'absence de mention n'est pas une mise en
garde, seulement le silence sur une bibliothèque tierce hors du choix déjà
prescrit (pwdlib/bcrypt).

Pas de nouveau fichier de règle, aucun fichier existant modifié — quatorze
règles inchangé.

Cours 20 (Sécuriser une API FastAPI, 58 diapositives, `Tuto/securiser-api-fastapi.pptx`)
traité. Confirmation attendue : `rules/securite-api.md` est directement sourcé
de ce kit (avant le début de cette revue) — l'essentiel (bcrypt/pwdlib, JWT
signé non chiffré, épinglage d'algorithme, `audience=`/`issuer=`, access 15
min/refresh 7 j, rotation, révocation par `jti`, 401/403, dépendances
chaînées, fail-closed, rate limiting, CORS, anti-énumération, HTTPS,
`httpOnly` vs `localStorage`, durcissement d'un endpoint de modèle, injection
de prompt, OWASP API Top 10) était déjà couvert mot pour mot. Cinq manques
concrets trouvés, tous des gestes mécaniques ou des pièges nommés
explicitement par le support et absents du fichier (commit `feat : claims
JWT complets, gotchas python-multipart/pyjwt/slowapi, Client Credentials,
WWW-Authenticate dans securite-api.md`, fusionné dans `develop`) :
- § JWT : la diapositive « Valider un JWT, vraiment » du support exige
  `aud`/`iss`/`nbf` en plus de `exp`/`iat`/`sub` dans `options={"require":
  [...]}` — le fichier n'en demandait que trois. Corrigé : la règle
  n'expliquait le couple `audience=`/`issuer=` que côté vérification, jamais
  côté claims obligatoires, ce qui laissait passer un token qui omet
  purement et simplement `aud`/`iss` sans être rejeté pour cette raison. Plus
  un bullet sur le piège `pip install jwt` (mauvais paquet) contre `pyjwt`
  (import `jwt`).
- § Sessions : dépendance `python-multipart` pour `OAuth2PasswordRequestForm`
  (sinon 422 sur `/token` sans message clair), et le grant **Client
  Credentials** pour un appel service-à-service sans utilisateur humain — le
  fichier ne distinguait que Password Grant et Authorization Code+PKCE, tous
  deux pensés pour un utilisateur, jamais le cas M2M.
- § Autorisation : en-tête `WWW-Authenticate: Bearer` sur le 401 levé par
  `get_current_user`, exigé par la spécification HTTP, absent du fichier.
- § Durcissement : `slowapi` exige `request: Request` en paramètre de la
  route décorée par `@limiter.limit(...)`, sans quoi il échoue à l'exécution
  et pas au démarrage — piège concret montré par le code du support, absent
  du fichier.

**Divergence assumée, réaffirmée sans changement** : le support autorise le
Resource Owner Password Grant pour « votre propre front-end » (client de
confiance), alors que `rules/securite-api.md` (ajout du cours 18) le réserve
à un script interne au dépôt, jamais à un client tiers **ni une application
publique** — donc plus strict que le support y compris pour son propre cas
d'usage recommandé. Resserrement délibéré maintenu : un front-end reste un
client public au sens OAuth2 (code exécuté hors du contrôle du serveur), la
règle du dépôt suit la lecture la plus prudente plutôt que celle du support.

Pas de nouveau fichier de règle — quatorze règles inchangé.

Cours 21 (HashiCorp Vault, 2 parties, 968 lignes cumulées) traité. Première
extension réelle du périmètre : aucun `rules/*.md` ne mentionnait Vault avant
ce cours, seul le `CLAUDE.md` racine du dossier de formation en parlait (§
Secrets, une phrase). Analyse déléguée à un agent pour digérer les deux
parties (policies, AppRole, KV v2, secrets dynamiques, Transit, response
wrapping, seal/unseal, réplication...) et distinguer ce qui relève du code
applicatif (`hvac`, patrons Python) de ce qui relève de l'exploitation pure
(installation du serveur, seal/unseal, HSM/FIPS, réplication — écarté du
même geste que Kafka au cours 16). Nouvelle section « Secrets applicatifs —
HashiCorp Vault » dans `rules/securite-api.md`, juste après § Configuration :
fail-closed (commit `feat : nouvelle section Secrets applicatifs —
HashiCorp Vault dans securite-api.md`, fusionné dans `develop`) :
- Même patron fail-closed que `SECRET_KEY`, appliqué à `VAULT_ADDR`/
  `VAULT_TOKEN` : sans connexion, l'application refuse de démarrer.
- Jamais de jeton en dur dans le code, y compris un jeton racine — le
  support montre lui-même l'anti-patron (`os.environ["VAULT_TOKEN"] =
  "hvs...."`) comme une facilité de développement local explicitement
  écartée en production.
- AppRole pour le M2M avec les contraintes concrètes du support :
  `secret_id` à usage unique, TTL court, restriction CIDR, politique dédiée
  au service — jamais `default`.
- KV v2 : `cas_required=True` et l'exception `hvac.exceptions.
  InvalidRequest` sur une écriture qui écraserait une version plus récente
  sans le savoir ; rappel que `list` n'est pas filtré par la politique, donc
  aucune information sensible dans un nom de chemin ou de clé.
- **Distinction secret statique/dynamique, absente de tout le corpus
  jusqu'ici** : révoquer un bail attaché à une lecture KV ne coupe rien à un
  client qui a déjà lu la valeur (« une photocopie »), contrairement à un
  secret dynamique (identifiants générés à la demande) que Vault peut
  vraiment couper à la source. C'est le point le plus susceptible d'être mal
  supposé par quelqu'un qui découvre Vault.
- Moteur Transit comme alternative au chiffrement applicatif
  (`cryptography.Fernet`/RSA, déjà écrit) quand Vault est déjà en place —
  renvoi croisé plutôt que duplication, base64 présenté pour ce qu'il est
  (transport, pas sécurité).
- Response wrapping pour la remise d'un secret une seule fois : un deuxième
  `unwrap` qui échoue est un signal d'interception, pas une erreur à
  ignorer.

Non retenu, hors périmètre (pur ops/infra, jamais de surface en code
applicatif Python) : installation et démarrage du serveur Vault, seal/
unseal et partage de Shamir, HSM/PKCS#11/FIPS, choix du backend de stockage
(Raft/externe/fichier/mémoire), write-ahead log et rollback manager internes
à Vault, réplication de performance (Enterprise), configuration HCL de Vault
Agent/Consul-Template, génération de CA PKI (posture équipe sécurité dans le
support lui-même), modèle de politiques deny-by-default/chemin le plus
spécifique (déjà énoncé dans le CLAUDE.md racine, écrire des politiques HCL
n'est pas du code applicatif Python).

Pas de nouveau fichier — le contenu tient dans une section de
`rules/securite-api.md`, dont le périmètre (`src/api/**/*.py`, `**/auth.py`,
`**/security.py`) couvre déjà exactement le code qui appellerait `hvac`.
Quatorze règles inchangé.

Cours 22 (Streamlit, 1 support) traité. Contrairement au cours 21, aucun
fichier existant n'a de périmètre (`paths:`) qui couvre du code Streamlit —
**nouveau fichier `rules/streamlit.md`** (commit `feat : nouvelle règle
streamlit.md — structure, état, cache, secrets, déploiement`, fusionné dans
`develop`) — quinzième règle du dépôt, `README.md` et
`modeles/modele-CLAUDE.md` mis à jour en conséquence. Le support lui-même
est un catalogue de widgets et deux mini-projets guidés (fonction affine,
data analyst sur un CSV de ventes de jeux vidéo) — aucune convention à en
tirer au niveau API (`st.button()` fait un bouton n'est pas une règle). Le
contenu réel du fichier vient surtout du `CLAUDE.md` racine § Applications —
Streamlit (une seule phrase dense, jamais développée dans aucun `rules/*.md`
jusqu'ici) déplié en sections, plus ce que le support confirme ou contredit :
- § Structure : dossier `pages/` à préfixe numérique — **confirmé
  littéralement** par le support (`0_fonction_affine.py`, `1_data_analyst.py`
  dans les instructions elles-mêmes) ; renvoi à `rules/tests-python.md` pour
  la logique métier testable séparée du widget, déjà écrit, pas dupliqué.
- § État et connexions : `@st.cache_resource`, `st.session_state`,
  `st.rerun()`, `key=` unique en boucle — repris du `CLAUDE.md` racine,
  développés (raison de chaque règle, pas seulement l'API), absents du
  support qui ne couvre que les bases.
- § Fichiers envoyés par l'utilisateur : à partir des deux widgets montrés
  par le support (`file_uploader`, `download_button`), deux gestes non
  écrits par le support lui-même — vérifier le contenu réel d'un fichier
  chargé, pas seulement son extension ; mettre en cache (`@st.cache_data`)
  un calcul coûteux derrière un bouton de téléchargement, qui se régénère
  sinon à chaque rerun où il reste affiché.
- § Journalisation : renvoi à `rules/python.md` (loguru obligatoire), avec la
  précision propre à Streamlit qu'un `st.write()` de debug oublié reste
  visible à l'utilisateur final, contrairement à un `print()` oublié.
- § Secrets : `.streamlit/secrets.toml`, jamais commité — même moule que
  `.env` dans `rules/python.md` § Configuration.
- § Déploiement — **divergence assumée corrigée** : le support recommande
  explicitement « Streamlit Cloud ou un autre service de déploiement ».
  `rules/python.md` § Choix par défaut fixe déjà « Déploiement serveur :
  `docker-compose.yml`, images sur le registre interne » pour tout le reste
  du dépôt — la règle nouvelle étend ce choix par défaut à Streamlit
  (conteneurisé comme n'importe quelle autre application, `rules/deploiement.md`
  s'applique), un service cloud tiers restant une dérogation à écrire dans le
  `CLAUDE.md` du dépôt, pas un défaut.

Non retenu du cours 22, hors périmètre : le catalogue de widgets lui-même
(boutons, cases à cocher, curseurs, colonnes, onglets, graphiques
Matplotlib/Plotly/Seaborn) — pure référence d'API, rien à en dire au niveau
convention ; les deux mini-projets (fonction affine, data analyst) sont des
exercices, pas une source de règle au-delà de ce qui précède ; les
alternatives listées en fin de support (Taipy, Panel, Shiny, Gradio,
streamlit-elements) — mentionnées sans détail, aucun besoin identifié dans
le corpus.

Quinze règles au total à partir de ce cours.

Cours 23 (Selenium, 1 support) traité, sans agent (demande explicite). Même
figure que Streamlit : `grep -rln -i selenium rules/ README.md modeles/` ne
retournait rien avant ce cours, seul le `CLAUDE.md` racine en parlait (§
Applications — Selenium, une phrase). **Nouveau fichier `rules/selenium.md`**
(commit `feat : nouvelle règle selenium.md — driver, locators, WebDriverWait,
éthique du scraping`, fusionné dans `develop`) — seizième règle du dépôt,
`README.md` et `modeles/modele-CLAUDE.md` mis à jour. Le mini-cours (setup,
locators, deux démos books.toscrape.com/quotes.toscrape.com) confirme déjà
l'essentiel de la phrase du CLAUDE.md racine (BeautifulSoup pour le
statique/Selenium pour le dynamique, jamais `time.sleep()` mais
`WebDriverWait`/`expected_conditions`, `driver.quit()`, RGPD/robots.txt/CGU)
et ajoute deux gestes concrets absents du CLAUDE.md racine :
- § Driver : `webdriver_manager` (`ChromeDriverManager().install()` +
  `Service(...)`) plutôt qu'un binaire `chromedriver` téléchargé et
  versionné à la main — montré tel quel par les deux démos du support.
- § Localiser un élément : ordre de préférence explicite des locators —
  `By.CSS_SELECTOR` par défaut (lisible, robuste, rapide), `By.ID` si un
  identifiant unique existe, `By.XPATH` en dernier recours seulement — repris
  du support (« souvent le meilleur choix » / « seulement si nécessaire »),
  absent du CLAUDE.md racine qui ne mentionne pas les locators.

**Divergence assumée, non corrigée dans la règle (le code du support n'est
pas repris tel quel)** : la Démo 1 du support (books.toscrape.com) place
`driver.quit()` en fin de script linéaire, hors `try/finally`, alors que la
Démo 2 (quotes.toscrape.com/js) l'enveloppe correctement. Le support
n'applique donc pas sa propre bonne pratique de façon cohérente d'un exemple
à l'autre — la règle retient uniquement le patron `try/finally`, cohérent
avec le CLAUDE.md racine, pas l'exemple incohérent de la Démo 1.

Non retenu, hors périmètre : le tableau Selenium vs BeautifulSoup et les
schémas d'attente (matériel pédagogique, déjà résumé par la règle en une
phrase) ; les trois exercices progressifs (interactions site statique/
dynamique, collecte multi-pages + export CSV) — scaffolding d'atelier ; le
« bilan » (avantages/limites/QA/CI-CD) — contexte, rien d'actionnable
au-delà de ce qui précède.

Seize règles au total à partir de ce cours.

Cours 24 (Redmail, 17 lignes) traité. Le support le plus court de toute la
revue : un lien vers la page des mots de passe d'application Google et un
exemple de sept lignes (`from redmail import gmail`, `gmail.username`/
`gmail.password`, `.send()`). Le CLAUDE.md racine avait déjà une clause
dédiée (§ Secrets : « Email : mot de passe d'application dédié, jamais le
mot de passe réel du compte, chargé depuis l'environnement ») jamais reprise
dans aucun `rules/*.md`. **Divergence directe dans l'exemple du support
lui-même** : `gmail.username = "votre_adresse@gmail.com"` et
`gmail.password = "..."` sont écrits en dur dans le script — exactement ce
que `rules/python.md` § Configuration interdit déjà de façon générale
(« aucun identifiant en dur dans le code »). Un bullet ajouté à cette
section, plutôt qu'une nouvelle section ou un nouveau fichier — le contenu
tient en deux phrases et rattache un cas concret (Redmail/Gmail) à une règle
déjà écrite plutôt que de la dupliquer (commit `feat : mot de passe
d'application Redmail/Gmail dans python.md § Configuration`, fusionné dans
`develop`) :
- Mot de passe d'application dédié (jamais le mot de passe réel du compte —
  une fuite se révoque sans toucher au compte), `gmail.username`/
  `gmail.password` chargés depuis l'environnement, jamais en dur comme le
  fait l'exemple du support.

Placé dans `rules/python.md` plutôt que `rules/securite-api.md` : l'envoi
d'un email n'est pas circonscrit au code d'API (`src/api/**/*.py`,
`**/auth.py`, `**/security.py`) — un script de notification ou une tâche
planifiée qui envoie un email n'a aucune raison de vivre dans ces chemins,
`rules/python.md` charge partout.

Non retenu, hors périmètre : rien d'autre à retenir — le support est trop
court pour receler d'autre divergence ou complément.

Pas de nouveau fichier de règle — seize règles inchangé.

Cours 25 (Workflow I, 23 diapositives) traité — **dernier cours de la
revue**. Support d'accueil de la formation (compte Google pro, installation
VSCode/Anaconda/Git, configuration `git config --global user.name/
user.email`, `.gitignore`, environnement virtuel `venv`/`pip freeze >
requirements.txt`, Markdown, bibliothèques courantes, notebook vs script,
premier `import`) — c'est le support d'onboarding « jour 0 », logiquement en
tête du parcours réel de formation, mais traité en dernier dans cette revue
puisque les cours ont été pris dans l'ordre de la numérotation du dépôt de
formation, pas de leur chronologie pédagogique.

**Aucune modification.** Tout le contenu est soit hors périmètre (compte
Google, installation d'éditeur, extensions VSCode — administratif/outillage
de poste, pas une convention de code), soit déjà couvert **et déjà
sciemment divergé** dès le cours 1, en toute première tâche de cette revue :
- `venv`/`pip`/`pip freeze > requirements.txt` (slides 10-11, 15, 17) :
  `rules/python.md` § Environnement impose déjà `uv` exclusivement, avec la
  raison explicite « jamais [pip], maintenir en plus un `requirements.txt` :
  deux verrous divergent toujours » — divergence déjà actée, pas à réaffirmer
  une deuxième fois.
- `git config --global user.name/user.email` (slide 8) : déjà dans
  `socle-code.md` (« L'auteur du commit doit être identifiable »).
- `.gitignore` avec `.venv` (slide 9) : déjà couvert partout où c'est
  pertinent.
- Notebook vs script (slide 18) : déjà couvert mot pour mot par le CLAUDE.md
  racine et `rules/donnees.md` (« un notebook explore, dès qu'une
  transformation est retenue, elle devient une fonction testable »).
- Extension VSCode « black formatter » (slide 14) : divergence déjà actée
  au cours 1 — le dépôt impose **ruff**, jamais black.
- Anaconda (slide 4) : le support lui-même dit de le fermer et de ne s'en
  servir que pour obtenir une distribution Python — rien à en retenir, non
  contredit par `uv`.

Ce cours confirme, plutôt qu'il ne surprend, que les décisions prises en
tout début de revue (cours 1) tenaient déjà pour le support qui aurait
logiquement dû être lu en premier.

Pas de nouveau fichier de règle — seize règles inchangé.

## Revue des 25 cours terminée

Les 25 cours du corpus de formation ont été traversés un par un, dans
l'ordre imposé par cette session. Bilan : seize règles au total, dont dix
déjà présentes avant cette revue et six créées pendant — `tests-python.md`,
`documentation.md`, `donnees.md` aux cours 1-10, `deploiement.md` au
cours 16, `streamlit.md` au cours 22, `selenium.md` au cours 23. Les
fichiers de suivi (`SESSION.md`, le journal externe) sont à jour à ce
point ; le détail cours par cours reste consultable dans le journal externe
pour un résumé final si besoin.

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

**Nouveaux (4 règles, 1 modèle) :**
- `rules/tests-python.md` — pytest, seul endroit où le DRY du socle ne
  s'applique pas.
- `rules/documentation.md` — Sphinx, accès depuis le README, publication.
- `rules/donnees.md` — pandas et seaborn ; un DataFrame n'est pas un stockage.
- `rules/deploiement.md` (cours 16) — Docker, Compose, MinIO, Prefect, Celery,
  Kubernetes ; publication d'image en CI ; monitoring d'infrastructure ;
  `TestSuite` Evidently comme `@task` Prefect ordinaire (cours 17).
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
  vérifie et ne corrige pas, section « Un échec doit bloquer », scan de
  secrets Gitleaks sous Jetons et secrets (cours 16).
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
- `rules/ml.md` (cours 13 à 17) — pipeline sklearn et rééquilibrage de classes
  dans Fuite de données, section « Recherche d'hyperparamètres », deux bullets
  Métriques (précision/rappel selon coût, MAE vs MSE), section « Apprentissage
  non supervisé » ; en tête de fichier, section « Framework : PyTorch ou
  Keras », fenêtre glissante dans Données, vectoriseur de texte dans Fuite de
  données, section « Modèles pré-entraînés — Hugging Face » ; séparation
  tracking/artifact store et `registered_model_name=` dans MLflow, distinction
  `runs:/` vs `models:/` et alias figé (reformulé cours 15, précisé cours 16
  avec le mécanisme de vérification légère) dans Registry et promotion ; deux
  renvois croisés vers `rules/deploiement.md` (cours 16) ; distinction `Report`
  / `TestSuite` et choix du test statistique de dérive dans Portail qualité,
  `Workspace`/snapshots comme historique continu dans Surveillance en
  production (cours 17).
- `README.md`, `modeles/modele-CLAUDE.md` — **quatorze règles** désormais
  (le second listait « onze » pour treize noms déjà énumérés — incohérence
  préexistante corrigée au cours 16).
- `rules/securite-api.md` (cours 18) — § Sessions : access + refresh gagne un
  bullet en tête sur Authorization Code + PKCE plutôt que Resource Owner
  Password Grant, avec le piège du tutoriel officiel FastAPI
  (`OAuth2PasswordRequestForm`).
- `rules/securite-api.md` (cours 20) — § JWT : claims obligatoires étendus
  (`aud`/`iss`/`nbf`), piège `pyjwt` vs `jwt` ; § Sessions : dépendance
  `python-multipart`, grant Client Credentials pour le M2M ; § Autorisation :
  en-tête `WWW-Authenticate: Bearer` ; § Durcissement : `request: Request`
  requis par `slowapi`.
- `rules/securite-api.md` (cours 21) — nouvelle section « Secrets
  applicatifs — HashiCorp Vault » après § Configuration : fail-closed :
  fail-closed `VAULT_ADDR`/`VAULT_TOKEN`, jamais de jeton en dur ni racine,
  AppRole M2M, KV v2/CAS, distinction secret statique/dynamique, Transit,
  response wrapping.
- `rules/streamlit.md` (cours 22, **nouveau fichier**, quinzième règle) —
  structure `pages/` à préfixe numérique, `@st.cache_resource`/
  `st.session_state`/`st.rerun()`/`key=` unique, fichiers envoyés par
  l'utilisateur, journalisation loguru, secrets `.streamlit/secrets.toml`,
  déploiement conteneurisé plutôt que Streamlit Cloud. `README.md` et
  `modeles/modele-CLAUDE.md` mis à jour (quinze règles).
- `rules/selenium.md` (cours 23, **nouveau fichier**, seizième règle) —
  BeautifulSoup vs Selenium, `webdriver_manager`/`Service`, `driver.quit()`
  en `finally`, ordre de préférence des locators (`CSS_SELECTOR` > `ID` >
  `XPATH`), `WebDriverWait`/`expected_conditions` jamais `time.sleep()`,
  éthique et cadre légal du scraping. `README.md` et
  `modeles/modele-CLAUDE.md` mis à jour (seize règles).
- `rules/python.md` (cours 24) — § Configuration gagne un bullet sur l'envoi
  d'email (Redmail/Gmail) : mot de passe d'application dédié, chargé depuis
  l'environnement, jamais en dur comme le fait l'exemple du support.

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
  `rules/ml.md`. Cours 16 (Docker/Compose/Prefect/Celery/Kubernetes) a ouvert
  `rules/deploiement.md`, nouveau fichier plutôt qu'une extension de `ml.md` ou
  `donnees.md` — sujet d'infrastructure, pas de cycle de vie du modèle ni de
  transformation de données. Cours 17 (Evidently) confirmé situé dans
  `rules/ml.md` § Portail qualité et § Surveillance en production, comme
  anticipé — aucun nouveau fichier. Cours 18 (Sécurité en Python) traité :
  plan de onze lignes annonçant les cours 19/20, situé dans
  `rules/securite-api.md` (existant, pas `rules/python.md` — le plan parle
  d'API, JWT, OAuth2, pas de stockage de mot de passe en CLI) — aucun nouveau
  fichier, un seul bullet ajouté. Cours 19 (hash/cryptage) confirmé sans
  aucune modification : `rules/python.md` § Mots de passe et saisie sensible
  et `rules/securite-api.md` § Chiffrement des données couvraient déjà tout
  le contenu du support, anti-patron `==`/`hashlib.sha256` inclus — premier
  cours de la revue sans aucun fichier de règle touché. Cours 20 (Sécuriser
  une API FastAPI) confirmé très majoritairement (58 diapositives sourcées
  du même kit que `rules/securite-api.md`), avec cinq gestes mécaniques/
  pièges concrets ajoutés (claims JWT complets, `python-multipart`, Client
  Credentials, `WWW-Authenticate`, `slowapi`/`Request`) — pas de nouveau
  fichier. Cours 21 (Vault 1 & 2) traité : première extension réelle du
  périmètre confirmée (`grep` ne retournait rien avant ce cours) — nouvelle
  section dans `rules/securite-api.md`, voisine de § Configuration :
  fail-closed comme anticipé, pas de nouveau fichier (le périmètre de
  `securite-api.md` couvre déjà le code qui appellerait `hvac`). Cours 22
  (Streamlit) traité : même figure confirmée — `grep -rln -i streamlit
  rules/ README.md modeles/` ne retournait rien avant ce cours, seul le
  CLAUDE.md racine en parlait (§ Applications, une phrase dense) —
  **nouveau fichier `rules/streamlit.md`** (quinzième règle), le support
  (catalogue de widgets, deux mini-projets) n'apportant lui-même qu'une
  confirmation de structure (`pages/` à préfixe numérique) et une
  divergence sur le déploiement (Streamlit Cloud contre le défaut
  `docker-compose`/registre interne déjà écrit). Cours 23 (Selenium) traité :
  même figure confirmée — nouveau fichier `rules/selenium.md` (seizième
  règle), pas rattaché à `donnees.md`/`http.md` (le support ne le suggérait
  pas, et le pilotage de navigateur n'est ni une transformation de données ni
  un appel HTTP au sens des deux fichiers existants). Cours 24 (Redmail)
  suit vraisemblablement le même patron une troisième fois : `grep -rln -i
  "redmail\|smtp\|email" rules/ README.md modeles/` ne retourne rien, seul
  le CLAUDE.md racine en parle (§ Secrets, une clause : mot de passe
  d'application dédié, jamais le mot de passe réel du compte, chargé depuis
  l'environnement). Traité : le support (17 lignes, le plus court de toute
  la revue) ne justifiait ni nouvelle section ni nouveau fichier — un seul
  bullet ajouté à `rules/python.md` § Configuration, placé là plutôt que
  `rules/securite-api.md` puisque l'envoi d'email n'est pas circonscrit au
  code d'API. Cours 25 (Workflow I, `WORKFLOW_I.pptx`), dernier de la
  revue : support pas encore lu à ce stade — `rules/workflow-session.md`
  existant porte sur le déroulé d'une session Claude Code, pas sur un sujet
  de formation, donc pas de lien de nom présumé avant lecture ; vérifier à
  la lecture si le sujet recoupe de l'orchestration déjà couverte
  (`rules/deploiement.md` § Prefect/Celery) ou ouvre un thème réellement
  neuf.
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
- Cours 14 traité, sans contradiction avec le cours 13 (vérifié : les sections
  neuves s'articulent avec Registry et promotion / Fuite de données /
  Données existantes plutôt que de les dupliquer).
- Écart de méthode assumé, cours 14 : la licence des modèles/datasets Hugging
  Face n'est mentionnée nulle part dans le support — ajout à partir d'un
  risque connu (licences non permissives sur le Hub), pas d'un point du cours,
  dans le même esprit que le shuffle/UDF ajoutés au cours 12.
- Non retenu du cours 14, hors périmètre : théorie du signal audio (Fourier,
  fenêtrage, biologie de l'audition — 35 slides), fondamentaux réseau de
  neurones (neurone/activation/loss/optimiseurs — définitions), callbacks
  Keras au détail (`EarlyStopping`, `ModelCheckpoint`, `TensorBoard` :
  mécanique déjà couverte par les principes MLflow/Registry existants),
  auto-encodeurs, GAN, diffusion, comparatif Hugging Face vs GitHub.
- Cours 15 a mis au jour une tension entre `rules/ml.md` § Registry et
  promotion et le CLAUDE.md racine du dossier de formation sur le
  chargement par alias — reconciliée (voir plus haut). Vérification
  holistique faite au cours 16 : le § MLOps du CLAUDE.md racine (MLflow,
  Packaging/uv, Orchestration/Prefect, Docker Compose → Kubernetes, Celery,
  Evidently) a été relu entièrement contre `rules/ml.md` et le nouveau
  `rules/deploiement.md` — aucune autre tension trouvée, le contenu du
  CLAUDE.md racine est soit déjà couvert (packaging uv, MinIO, Prefect
  serve/deploy), soit repris tel quel (modèle jamais copié dans l'image,
  registre interne). Le point Evidently du CLAUDE.md racine reste à
  confronter en détail au cours 17.
- Divergence assumée, cours 16 : `MLOPS_2_Factory` montre
  `client.get_latest_versions(model_name, stages=["None"])[0]` pour retrouver
  « la dernière version créée » avant de lui poser un alias — l'API `stages`
  est dépréciée depuis MLflow 2.x (remplacée par les alias eux-mêmes) et
  n'a pas été reprise dans `rules/deploiement.md` ni `rules/ml.md` ; seul le
  geste `set_registered_model_alias` a été retenu comme pattern utile.
- Kafka (`MLOPS_4_Advanced`, ~8 slides) volontairement absent de
  `rules/deploiement.md` : présenté au niveau notion générale, sans exemple
  Python complet ni lien avec un besoin déjà identifié dans le corpus — à
  ajouter seulement si un cours ultérieur ou un dépôt réel en a l'usage.
- Point Evidently du CLAUDE.md racine (§ MLOps — « comparer Reference/Current
  via `Report(metrics=[...])`, utiliser comme gate qualité, lever une
  exception si un seuil métier est franchi ») confronté au cours 17 : cohérent
  avec `rules/ml.md` § Portail qualité une fois `TestSuite` distingué de
  `Report` — le CLAUDE.md racine simplifie (il dit `Report` là où le geste
  qui bloque vraiment est un `TestSuite`) sans être faux, aucune reformulation
  nécessaire côté CLAUDE.md racine.
- Le support Evidently n'a pas de slide de code exploitable (« Démo de Code »
  vide dans l'extraction PDF) : les ajouts de ce cours s'appuient sur le
  vocabulaire et les mécanismes décrits en slides, pas sur un extrait de code
  du support lui-même — à garder en tête si Lionel veut vérifier contre
  l'API Evidently réelle (versions récentes) avant de s'y fier en production.

## Cours 26 (hors liste initiale) — DEVIA 25 - IA Agentic

Cours découvert après la clôture de la revue des 25 cours (absent du corpus
scratchpad pré-extrait, source PDF trouvée directement dans
`/home/lionel/DEVIA/Support`, extraite via `pdftotext -layout` — 2561 lignes).
Contenu : LangChain/LCEL, LangGraph (agents, boucle ReAct, nœuds
d'évaluation, guardrail), RAG (LangChain+ChromaDB, LlamaIndex+FAISS),
sécurité (injection de prompt, défense en profondeur), human-in-the-loop
(checkpoints, time travel), multi-agent (pair-à-pair, superviseur central),
Langfuse, connecteur MCP. Sujet entièrement neuf : aucune règle existante ne
couvrait LangChain/LangGraph/agents avant ce cours.

Digest fait par agent (lecture intégrale du support + relecture complète de
`rules/securite-api.md`, `rules/ml.md`, `rules/bdd.md`, `rules/deploiement.md`
pour repérer tout chevauchement avant d'écrire). Nouvelle règle créée :
`rules/agents-ia.md` (dix-septième règle du dépôt), avec des renvois plutôt
que des doublons vers l'existant :
- `rules/securite-api.md` § Si le modèle servi est un LLM garde le principe
  (défense en profondeur), `rules/agents-ia.md` § Sécurité — injection de
  prompt porte l'implémentation (taxonomie d'attaque, quatre niveaux). Un
  renvoi ajouté dans `securite-api.md`.
- `rules/bdd.md` § Recherche vectorielle — pgvector garde l'index/les
  opérateurs côté SQLAlchemy ; `agents-ia.md` n'ajoute que ce qui est
  vraiment neuf (le `PGVector` de LangChain côté microservice RAG, et le
  critère de choix entre les deux : mélanger filtre relationnel et
  similarité vectorielle penche vers SQLAlchemy).
- `rules/ml.md` § Portail qualité avant promotion et § Humain dans la boucle
  citées en cross-référence dans `agents-ia.md` (même philosophie de porte
  qui bloque / de suspension avant action, appliquée par tour d'agent plutôt
  que par déploiement de modèle) — aucune des deux règles ml.md modifiée, le
  parallèle suffisait.
- `rules/deploiement.md` non modifié : le point neuf sur ce cours (un
  serveur MCP en `streamable-http` exposé au-delà de `localhost` doit
  recevoir le même traitement qu'une route FastAPI — auth, rate limiting,
  CORS) est un ajout prescriptif de `agents-ia.md` § Connecteur MCP, pas une
  extension de `deploiement.md`.

Non retenu (scaffolding pédagogique) : Fondamentaux Ollama/tokenisation/
température (théorie d'installation et de concepts), narration du cours
(métaphores « bras »/« juge »/« douanier »), exercices, comparatif
FastAPI/FastMCP en tant que tel (seul le critère de transport `stdio` vs
`streamable-http` a été retenu), tableau de stratégies de mémoire exotiques
(Entity Memory, Vectorized History — gardé un menu court à trois options).

`README.md` et `modeles/modele-CLAUDE.md` mis à jour (dix-sept règles,
liste et chemin de `agents-ia.md`).

Travail réalisé sur `feature/agents-ia`, commit `feat : nouvelle règle
agents-ia (LangChain, LangGraph, RAG, MCP)`, fusionné `--no-ff` dans
`develop`, branche supprimée.

## Cours 27 (hors liste initiale) — tuto-traefik

Cours découvert lui aussi après la clôture de la revue des 25 cours, source
`.html` (pas de `.txt` pré-extrait) — converti par un script Python maison
(`bs4` absent de l'environnement, pas de `pandoc`/`lynx`/`w3m` disponibles)
vers `tuto-traefik.html.txt` (1112 lignes) dans le scratchpad. Contenu :
proxy vs reverse proxy, vocabulaire Traefik (EntryPoint/Router/Service/
Middleware), mise en place d'un docker-compose avec labels Traefik devant
un frontend + une API FastAPI, dashboard sécurisé par basicauth, exposition
du socket Docker, ACME/HTTPS.

Digest fait par agent (lecture intégrale + relecture de `rules/deploiement.md`
et `rules/securite-api.md` pour vérifier chevauchement/contradiction).
Aucune contradiction trouvée : `deploiement.md` ne mentionnait aucun reverse
proxy, c'est un vrai manque plutôt qu'un doublon. Nouvelle section
`## Reverse proxy — Traefik` ajoutée dans `rules/deploiement.md`, juste
après `## Docker Compose — configuration et secrets` (pas de nouveau
fichier — le volume ne justifiait pas un dix-huitième fichier de règle avec
son propre glob à synchroniser). Renvois plutôt que doublons vers
`rules/securite-api.md` § Durcissement pour la politique CORS, et pour le
rate limiting applicatif (`slowapi`) distingué du rate limiting de bord
(`ratelimit` Traefik, complémentaire, pas un remplacement).

Non retenu (scaffolding pédagogique) : quiz, narration « à l'écran », pas-à-
pas de démonstration, exercice guidé, comparatif Traefik vs Caddy/nginx/Kong
en tant que tel (retenu seulement le diagnostic 404 vs 502, qui est un
réflexe de débogage réutilisable, pas un comparatif d'outils).

Travail réalisé sur `feature/traefik`, commit `feat : section Reverse proxy
- Traefik dans deploiement.md`, fusionné `--no-ff` dans `develop`, branche
supprimée.

## Cours 28 (hors liste initiale) — dossier « Machine Learning »

Nouveau dossier découvert : `Machine Learning.pptx` (support de base,
supervisé/non supervisé, nettoyage, pipeline scikit-learn, métriques,
MLflow, clustering, PCA) et `Machine Learning/` (onze PDF courts : Naive
Bayes, Bagging, AdaBoost, histoire du Perceptron, SVC, Stacking, SVM/SVR,
veille AutoML, arbre de décision, Isolation Forest, KNN). Traité **sans
agent**, sur demande explicite — lecture directe de chaque fichier.

Extraction : `.pptx` racine converti via `python-pptx` (pas de `bs4`/
`pandoc`/`lynx`/`w3m` disponibles, script maison déjà utilisé au cours 27) ;
les onze PDF via `pdftotext -layout`. Douze fichiers, tous courts (22 à
344 lignes), lus intégralement un par un.

La majorité du contenu est de la théorie pure sans convention de code :
histoire du Perceptron, principe de Naive Bayes/AdaBoost/Stacking/SVC/SVM/
arbre de décision/Isolation Forest, définitions de métriques (précision,
rappel, accuracy, F1, matrice de confusion) déjà couvertes conceptuellement
par `rules/ml.md` § Métriques. Le support pptx racine reprend d'ailleurs mot
pour mot la divergence PCA/RGPD déjà actée au cours 13 (« anonymat des
données (RGPD) ») — cohérent avec la décision déjà prise, rien à rejouer.

Trois points particuliers réellement neufs et transférables, absents de
`rules/ml.md` :
- **Mise à l'échelle par famille d'algorithme** : les algorithmes à distance
  (KNN — source du point, SVM, k-means, PCA) l'exigent, les algorithmes à
  arbres non — absent jusqu'ici, seule la fuite de données via
  Pipeline/ColumnTransformer était couverte, pas la nécessité elle-même.
- **Méthodes ensemblistes** (bagging/boosting/stacking, PDF dédiés à
  chacune) condensées en une table de trois lignes plutôt que trois
  sections séparées — bagging réduit la variance, boosting le biais (plus
  sensible au bruit), stacking gagne à combiner des modèles peu corrélés
  mais coûte cher sur un petit jeu de données.
- **AutoML** (PyCaret/TPOT/AutoKeras, PDF de veille dédié) rattaché au § déjà
  existant Baseline plutôt qu'une section à part : accélérateur de
  comparatif multi-modèle, pas un pilote automatique — risques nommés par le
  support repris (garbage in/garbage out, surapprentissage par balayage
  massif, perte d'interprétabilité).
- Un quatrième point (Isolation Forest) ajouté au § Apprentissage non
  supervisé déjà existant plutôt qu'une nouvelle section : détection
  d'anomalies, mêmes réserves que le clustering (pas de vérité terrain),
  taux de contamination en configuration.

Nouvelle section `## Modèles classiques — scikit-learn` ajoutée dans
`rules/ml.md`, entre § Métriques et § Apprentissage non supervisé (qui a
reçu son bullet Isolation Forest). Pas de nouveau fichier.

Non retenu (théorie ou déjà couvert) : Naive Bayes, AdaBoost, Stacking,
SVC/SVM (concepts), histoire du Perceptron (aucune convention), toutes les
définitions de métriques de classification déjà dans § Métriques, sous/
sur-échantillonnage déjà couvert au § Fuite de données, `Pipeline`/
`ColumnTransformer` déjà couvert au § Fuite de données, `GridSearchCV` déjà
couvert au § Recherche d'hyperparamètres, MLflow logging déjà couvert au
§ MLflow.

Travail réalisé sur `feature/ml-classiques`, commit `feat : modèles
classiques scikit-learn (mise à l'échelle, ensemblistes, AutoML, Isolation
Forest) dans ml.md`, fusionné `--no-ff` dans `develop`, branche supprimée.

## [2026-09-02] — Audit de lisibilité des `.md` pour Claude

**Branche :** `feature/audit-lisibilite-md`

**Fait :**
- Mécanisme de chargement des règles vérifié **dans le binaire Claude Code
  2.1.84**, pas seulement d'après la documentation : la clé de frontmatter lue
  est bien `paths` (nom interne `globs`), la comparaison se fait en sémantique
  `.gitignore` sur le chemin relatif à la **racine du dépôt**, un `/**` final
  est retiré avant comparaison, et un fichier de `.claude/rules/` sans `paths`
  est chargé à chaque session. Le dépôt était donc correct sur le fond ; les
  quatre autres colonnes du tableau ajouté au README ne se devinaient pas.
- Sept défauts corrigés (détail ci-dessous), tous des cas où la consigne
  se contredit ou n'est pas exécutable telle quelle par l'assistant.
- Portées `paths` de `deploiement.md` élargies aux noms de fichiers réels
  (`compose.yaml` de Compose v2, `Dockerfile.<service>`, `k8s/` imbriqué) et
  débarrassées de leurs doublons `**/`, inutiles en sémantique `.gitignore`.

**Décisions techniques :** (avec la raison, pas seulement le choix)
- Sémantique de `paths` documentée dans le **README** et non dans chaque règle :
  c'est de la connaissance de mainteneur, elle n'a pas à coûter du contexte à
  chaque session. Seule `deploiement.md` en garde un rappel, parce que c'est le
  fichier dont les motifs sont les plus faciles à re-casser.
- `**/k8s/**` plutôt que quatre motifs `k8s/**/*.yaml` + `.yml` + compagnons
  `**/` : couvre les manifestes quelle que soit l'extension et à toute
  profondeur, en une ligne.
- Doublons `**/` retirés de `deploiement.md` seulement, pas de `streamlit.md` :
  là ils sont inoffensifs et le fichier n'avait pas de défaut à corriger — pas
  de reformatage au détour d'un correctif (priorité 3 du socle).
- Les trois consignes de `workflow-session.md` que l'assistant ne peut pas
  exécuter (`/clear`, `/context`, changement de modèle) sont regroupées sous un
  paragraphe qui dit explicitement à qui elles s'adressent, plutôt que
  supprimées : elles restent vraies, c'est leur destinataire qui manquait.
- `log_prints=True` conservé dans `deploiement.md`, mais rattaché à ce qu'il
  fait réellement (récupérer la sortie standard du code tiers) : le supprimer
  aurait retiré une information juste, le laisser tel quel autorisait un
  `print()` de suivi que `python.md` interdit.

**Fichiers principaux modifiés :**
- `rules/ml.md` — commentaire de portée aligné sur le frontmatter réel
  (notebooks + `conf/`, plus larges que `src/ml/`) ; renvois « ci-dessus » du
  § Apprentissage non supervisé corrigés (Registry et Portail qualité sont plus
  bas) ; § Modèles pré-entraînés ne prétend plus que le § Registry « interdit »
  la résolution dynamique, alors qu'il recommande l'alias ; puce du cache
  d'alias (9 lignes, une seule phrase) coupée en deux.
- `rules/cicd.md` — puce « entraînement pas en CI » remontée de § Un échec doit
  bloquer, où elle était orpheline après un paragraphe de conclusion, vers
  § Contenu d'un workflow ; « écrire la réponse ici » remplacé par l'endroit
  qui survit à une mise à jour du sous-module.
- `rules/deploiement.md` — frontmatter `paths` ; `log_prints=True` séparé de
  la puce `@flow`/`@task` et rattaché à `python.md` § Journalisation.
- `rules/workflow-session.md` — § Pendant et étape 7 de § Fin de tâche.
- `README.md` — nouvelle section « Comment le frontmatter `paths` est
  réellement interprété ».

**Vérifié :**
- Motifs `paths` testés en sémantique réelle, par `git check-ignore` dans un
  dépôt jetable : `Dockerfile.dev`, `docker/Dockerfile`, `compose.yaml`,
  `deploy/k8s/api.yml` déclenchent bien `deploiement.md`, et `src/app.py` ne la
  déclenche pas. Idem contrôles de non-régression sur `ml.md`, `streamlit.md`
  et `bdd.md`, inchangés.
- Renvois `rules/x.md` et `§ Section` revérifiés par script contre les en-têtes
  réels : aucun renvoi mort. Blocs de code équilibrés, aucun saut de niveau de
  titre, tout en UTF-8/LF.
- Coût contexte mesuré : ~43 k jetons si les dix-sept règles étaient chargées
  ensemble, 5 à 8 k pour un projet VBA, ~20 k pour un projet Python complet —
  à comparer au seuil de 120 k que ce même fichier de règles fixe.
- Non vérifié : rien n'a été exécuté dans un vrai dépôt consommateur, le
  chargement effectif des règles élargies n'est donc constaté que par la
  sémantique `.gitignore`, pas par une session réelle.

**Points de vigilance pour la suite :**
- `git config user.email` vaut `lio.jourdhier@gmail.com` sur ce poste, alors que
  le socle exige l'adresse professionnelle. Tout l'historique existant est signé
  ainsi ; à trancher (garder pour ce dépôt, ou corriger et l'assumer pour les
  commits futurs).
- `**/tools/**/*.py` (`agents-ia.md`, 3,3 k jetons) reste la portée la plus
  large du dépôt : `tools/` est un nom de dossier générique, la règle se
  chargera sur des projets sans le moindre agent. À resserrer si le cas se
  présente vraiment.
- Les trois points « à vérifier sur notre instance » de `cicd.md` sont toujours
  sans réponse. Ils bornent la forme des workflows tant qu'ils le restent.

## [2026-09-02] — Portée `tools/` resserrée dans agents-ia.md

**Branche :** `feature/portee-tools-agents-ia`

**Fait :**
- `**/tools/**/*.py` retiré du frontmatter d'`agents-ia.md`, remplacé par
  `**/tools.py` et `**/*_tools.py`. La règle (3,3 k jetons) ne se charge plus
  sur le `tools/` d'utilitaires que beaucoup de dépôts possèdent sans avoir le
  moindre agent.
- Ligne correspondante du tableau du README mise à jour.

**Décisions techniques :**
- Aucun motif ne peut exprimer « un `tools/` voisin d'`agents/` » en sémantique
  `.gitignore`. Les outils rangés sous `agents/`, `chains/`, `graphs/` ou `rag/`
  restaient de toute façon couverts par les motifs de répertoire existants : le
  seul cas réellement perdu est un `tools/` de premier niveau contenant des
  `@tool`, c'est-à-dire exactement le cas ambigu. Il se récupère en ajoutant le
  chemin dans la copie locale, comme le font déjà `http.md` et `nodejs.md`.
- Faux positif résiduel assumé et écrit dans l'en-tête : un `excel_tools.py`
  d'utilitaires déclenche encore. Un fichier, plus une arborescence entière.

**Fichiers principaux modifiés :**
- `rules/agents-ia.md` — frontmatter `paths` et en-tête (raison du resserrement).
- `README.md` — description de la portée d'`agents-ia.md`.

**Vérifié :**
- Douze cas passés par `git check-ignore` dans un dépôt jetable :
  `src/agents/tools/recherche.py`, `src/chains/tools/sql.py`, `app/tools.py`,
  `src/ia/recherche_tools.py`, `mcp_server_parc.py`, `src/devis_agent.py`
  déclenchent ; `tools/export_xlsx.py`, `scripts/tools/nettoyage.py` et
  `src/api/main.py` ne déclenchent plus.
- Non vérifié : aucun dépôt consommateur réel n'a été ouvert pour constater le
  chargement en session.

**Points de vigilance pour la suite :**
- Reste de l'audit de lisibilité : l'adresse de commit (gmail au lieu de
  l'adresse professionnelle) et les trois points « à vérifier sur notre
  instance » de `cicd.md`, toujours sans réponse.

## [2026-09-02] — Adresse de commit corrigée

**Branche :** `develop` (réglage de poste, aucun fichier du dépôt modifié à part
ce résumé)

**Fait :**
- `git config --global user.email` passé de `lio.jourdhier@gmail.com` à
  `l'adresse professionnelle`, conformément au socle (§ Commits, « l'auteur du
  commit doit être identifiable […] avec l'adresse professionnelle »).
  Sauvegarde de l'ancien fichier dans `~/.gitconfig.bak-20260902`.

**Décisions techniques :**
- Réglage **global** et non local au dépôt : l'adresse était déjà dans
  `~/.gitconfig`, et le socle parle d'un réglage de poste. Tous les dépôts de la
  machine sont donc concernés, y compris les dépôts personnels — c'est
  l'intention de la règle, et le changement se défait par une commande.
- **Historique existant non réécrit.** Tous les commits antérieurs restent
  signés avec l'ancienne adresse : le socle interdit de réécrire l'historique
  sans demande explicite, et ici la réécriture n'apporterait rien qu'une
  divergence avec les copies déjà distribuées.

**Vérifié :**
- Commit d'essai dans un dépôt jetable : auteur
  `Lionel JOURDHIER <l'adresse professionnelle>`. `user.name` inchangé.

**Points de vigilance pour la suite :**
- Il reste, de l'audit de lisibilité, les trois points « à vérifier sur notre
  instance » de `cicd.md` (expressions autres qu'`always()`, `actions/cache`,
  lecture de `.github/workflows`), toujours sans réponse.
