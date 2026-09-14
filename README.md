# standards-code

Source unique des conventions de code. Ce dépôt n'est jamais modifié depuis un
projet : une règle qui ne vaut que pour un projet va dans le `CLAUDE.md` de ce
projet.

```
socle-code.md            règles valables partout, importées dans chaque CLAUDE.md
rules/python.md          règles chargées seulement sur les .py
rules/tests-python.md    idem tests/, test_*.py, conftest.py
rules/javascript.md      idem .js / .mjs / .cjs / .html — code navigateur
rules/nodejs.md          idem package.json, .mjs, server/ — code serveur
rules/vba.md             idem .bas / .cls / .frm
rules/ml.md              idem src/ml/
rules/donnees.md         idem notebooks, data/, etl/, pipelines/ — pandas
rules/bdd.md             idem db/, repositories/, migrations/, alembic/
rules/deploiement.md     idem Dockerfile, docker-compose*.yml, k8s/, prefect.yaml
rules/securite-api.md    idem src/api/, auth.py, security.py — Vault inclus
rules/agents-ia.md       idem chains/, agents/, graphs/, rag/, tools.py, mcp_server*.py
rules/streamlit.md       idem app.py, Home.py, pages/, .streamlit/
rules/selenium.md        idem scraping/, scraper*.py, *_scraper.py
rules/cicd.md            idem .gitea/workflows/
rules/http.md            idem clients/, integrations/ — appels HTTP sortants
rules/documentation.md   idem docs/, conf.py, .rst, README.md — Sphinx
rules/workflow-session.md déroulé d'une session, chargé toujours
modeles/modele-CLAUDE.md à copier en CLAUDE.md et remplir dans un nouveau dépôt
modeles/modele-README.md à copier en README.md et remplir dans un nouveau dépôt
modeles/modele-BACKLOG.md à copier en BACKLOG.md — gabarit vide, géré par /backlog
modeles/FICHE-MODELE.md  une par modèle promu en production
agents/reviewer.md       revue lecture seule d'un diff ou d'une branche  -> Fable
agents/planner.md        plan d'implémentation, lecture seule            -> Opus
agents/implementer.md    application d'un plan ou d'une revue, avec tests -> Sonnet
commands/backlog.md      /backlog : la seule commande à connaître
hooks/pre-commit         garde-fou git, configurable par dépôt
hooks/standards.conf.exemple
hooks/verifier-installation  contrôle que le garde-fou est vraiment actif
hooks/maj-standards      met à jour le sous-module et les règles d'un dépôt
tests/banc-hook.sh       banc de test du hook, à relancer après l'avoir modifié
```

## Installer dans un dépôt

```bash
git submodule add <url>/standards-code.git .claude/standards
mkdir -p .claude/rules .githooks
cp .claude/standards/modeles/modele-CLAUDE.md CLAUDE.md
cp .claude/standards/modeles/modele-README.md README.md
cp .claude/standards/hooks/pre-commit .githooks/pre-commit
cp .claude/standards/hooks/standards.conf.exemple .githooks/standards.conf
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
bash .claude/standards/hooks/verifier-installation
```

La dernière ligne n'est pas facultative : voir ci-dessous.

Puis, pour chaque langage présent dans le dépôt :

```bash
cp .claude/standards/rules/python.md .claude/rules/python.md
```

Une copie plutôt qu'un lien symbolique : sous Windows les liens exigent les
droits administrateur ou le mode développeur. La contrepartie est que la copie
peut dater — d'où la commande de mise à jour ci-dessous.

Et, si le dépôt doit tenir un backlog et passer par la revue avant fusion :

```bash
mkdir -p .claude/agents .claude/commands
cp .claude/standards/modeles/modele-BACKLOG.md BACKLOG.md
cp .claude/standards/agents/*.md .claude/agents/
cp .claude/standards/commands/backlog.md .claude/commands/backlog.md
```

Claude ne lit les agents que dans `.claude/agents/` et les commandes que dans
`.claude/commands/` : les fichiers du sous-module ne sont pas découverts tout
seuls, la copie est nécessaire. Voir « Backlog et revue » plus bas.

Le modèle ne s'appelle pas `CLAUDE.md` dans le sous-module, et ce n'est pas
cosmétique : Claude charge les `CLAUDE.md` des sous-répertoires dès qu'il lit un
fichier à côté. Un gabarit à trous entrerait alors en contexte comme de vraies
consignes de projet. Ne pas le renommer.

Le `CLAUDE.md` du dépôt commence par `@.claude/standards/socle-code.md`. Le
chemin reste à l'intérieur du dépôt, donc pas de demande d'approbation au
premier lancement.

## Vérifier que le garde-fou est actif

```bash
bash .claude/standards/hooks/verifier-installation
```

Une installation ratée ne se voit pas : sur les quatre façons de la rater, trois
laissent passer les commits comme si tout allait bien.

| Ce qui cloche | Ce que fait git |
|---|---|
| `.githooks/` vide, hook jamais copié | accepte tout, sans un mot |
| hook non exécutable | accepte tout, avec un `hint:` noyé dans la sortie |
| `standards.conf` rangé ailleurs que dans `.githooks/` | accepte tout, sans un mot |
| hook en CRLF | refuse tout, bruyamment (`env: 'bash\r': ...`) |

`git config core.hooksPath` est un réglage **local**, donc non versionné : à
refaire après chaque clone, sur chaque poste. C'est le premier suspect quand un
commit qui aurait dû être refusé passe.

## Modifier le hook

```bash
bash tests/banc-hook.sh
```

Trente-six cas, chacun dans un dépôt jetable. Deux d'entre eux gardent des
défauts déjà rencontrés : un motif comme `*.xlsx` développé par le shell avant
la comparaison (le fichier interdit passait dès qu'un autre `.xlsx` traînait à
la racine), et une `standards.conf` en CRLF qui désactivait tout en silence.

## Mettre à jour un dépôt

```bash
bash .claude/standards/hooks/maj-standards
```

Le script ne rafraîchit que les règles **déjà présentes** dans le dépôt. Un
`cp rules/*.md` déverserait les dix-sept règles dans tous les projets, y compris
celles qui n'y servent à rien. Pour en ajouter une au passage :

```bash
REGLES_EN_PLUS=workflow-session.md bash .claude/standards/hooks/maj-standards
```

Même logique pour `.claude/agents/` et `.claude/commands/` : seuls les fichiers
déjà présents sont rafraîchis.

Il remet aussi le hook en place et lance le vérificateur, qui signale une copie
du hook ayant dérivé de la référence.

Il ne fait pas de `git pull` dans le sous-module, et ce n'est pas un détail :
l'historique de ce dépôt a été réécrit une fois, et un `pull` échoue dès que le
commit épinglé n'est plus un ancêtre du nouveau `main`. Le script fait un
`fetch` puis un `reset --hard`, ce qui marche dans les deux cas.

Un second argument permet de tirer depuis un dépôt local plutôt que depuis
`origin` — quand le remote n'est pas joignable, ou pas encore à jour :

```bash
bash .claude/standards/hooks/maj-standards . /chemin/vers/standards-code
```

Le script ne committe rien : il termine en affichant ce qui reste à valider.

Ne recopiez que les règles des langages présents : une règle chargée pour rien
consomme du contexte à chaque session.

## Backlog et revue

Trois agents et une commande, tous facultatifs, à copier comme indiqué dans
« Installer dans un dépôt ». Aucune automatisation de PR : tout se passe dans
la session, rien n'est publié.

| Fichier | Rôle | Modèle | Écrit ? |
|---|---|---|---|
| `commands/backlog.md` | `/backlog` : état, `add`, `migrate`, `triage`, `next`, `done`, `from-review` | celui de la session | `BACKLOG.md` seulement, après un tableau de validation |
| `agents/planner.md` | transforme une entrée `BL-xxx`, une demande ou une revue en plan par étapes vérifiables | Opus | rien |
| `agents/implementer.md` | applique le plan étape par étape, tests et vérification à chaque étape | Sonnet | le code et les tests, jamais `BACKLOG.md` ni `SESSION.md` |
| `agents/reviewer.md` | relit un diff ou une branche, constats prouvés par `fichier:ligne`, candidats pour le backlog en fin de rapport | Fable | rien |

Cycle type, sur une branche `feature/*` tirée de `develop` :

```
/backlog next M                               → propose BL-012
Utilise l'agent planner pour BL-012           → plan structuré
Utilise l'agent implementer pour appliquer le plan
Utilise l'agent reviewer sur la branche courante
/backlog from-review                          → importe les candidats de la revue
/backlog done BL-012 feature/<slug>
```

Le modèle de chaque agent est fixé dans son frontmatter. Ne pas définir
`CLAUDE_CODE_SUBAGENT_MODEL` : la variable écrase ces choix et tous les agents
tournent alors sur le même modèle. Le format des entrées est décrit en tête de
`BACKLOG.md` ; les noms de champs ne se changent pas, les agents les lisent.

Un `TODO.md` existant se convertit avec `/backlog migrate`, qui présente le
résultat avant d'écrire et laisse l'ancien fichier en place, marqué comme
migré.

## Modifier une règle

Sur une branche de `standards-code`, avec dans le message de commit la raison
du changement et le projet qui l'a motivé. Une règle ajoutée sans incident
déclencheur finit ignorée.

Avant d'ajouter : est-ce qu'un linter ou le hook peut le vérifier ? Si oui, ça
n'a rien à faire dans un fichier de règles. Un CLAUDE.md est du contexte, pas
une configuration appliquée ; seul un hook s'exécute quoi qu'il arrive.

## Comment le frontmatter `paths` est réellement interprété

Vérifié dans Claude Code 2.1.84, parce que trois de ces règles ne se devinent
pas et qu'un motif qui ne matche rien ne produit aucune erreur :

| Ce qu'on écrit | Ce qui se passe |
|---|---|
| pas de `paths` du tout | la règle est chargée **à chaque session** (c'est le cas de `workflow-session.md`) |
| `paths` présent | la règle n'est chargée que quand un fichier correspondant est lu ou écrit |
| motif **sans** barre oblique (`Dockerfile*`, `README.md`) | s'applique à **tous les niveaux** du dépôt ; un `**/` en plus est redondant |
| motif **avec** barre oblique (`k8s/**/*.yaml`, `pages/**/*.py`) | ancré à la **racine** du dépôt ; il faut un compagnon `**/…` pour les sous-dossiers |
| `/**` en fin de motif | retiré avant comparaison : `alembic/**` devient `alembic`, donc plus ancré du tout |

La comparaison se fait en sémantique `.gitignore`, sur le chemin du fichier
déclencheur relatif à la racine du dépôt. Les commentaires HTML (`<!-- … -->`)
sont retirés avant injection dans le contexte : ils ne coûtent rien et servent
de notes au mainteneur.

## Ce qui ne va pas dans ce dépôt

- Contexte commercial, noms de clients, organisation interne.
- Ce que Claude déduit du code : arborescence, liste des dépendances, aperçu de
  l'architecture.
- Ce qu'un linter vérifie déjà : longueur de ligne, ordre des imports, guillemets.
- Préférences personnelles de travail : elles vont dans `~/.claude/CLAUDE.md`.
