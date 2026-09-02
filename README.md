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
rules/agents-ia.md       idem chains/, agents/, graphs/, tools/, rag/, mcp_server*.py
rules/streamlit.md       idem app.py, Home.py, pages/, .streamlit/
rules/selenium.md        idem scraping/, scraper*.py, *_scraper.py
rules/cicd.md            idem .gitea/workflows/
rules/http.md            idem clients/, integrations/ — appels HTTP sortants
rules/documentation.md   idem docs/, conf.py, .rst, README.md — Sphinx
rules/workflow-session.md déroulé d'une session, chargé toujours
modeles/modele-CLAUDE.md à copier en CLAUDE.md et remplir dans un nouveau dépôt
modeles/modele-README.md à copier en README.md et remplir dans un nouveau dépôt
modeles/FICHE-MODELE.md  une par modèle promu en production
hooks/pre-commit         garde-fou git, configurable par dépôt
hooks/standards.conf.exemple
hooks/verifier-installation  contrôle que le garde-fou est vraiment actif
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

Trente-trois cas, chacun dans un dépôt jetable. Deux d'entre eux gardent des
défauts déjà rencontrés : un motif comme `*.xlsx` développé par le shell avant
la comparaison (le fichier interdit passait dès qu'un autre `.xlsx` traînait à
la racine), et une `standards.conf` en CRLF qui désactivait tout en silence.

## Mettre à jour un dépôt

```bash
git -C .claude/standards pull
for r in .claude/rules/*.md; do cp ".claude/standards/rules/$(basename "$r")" "$r"; done
cp .claude/standards/hooks/pre-commit .githooks/pre-commit
bash .claude/standards/hooks/verifier-installation
```

La boucle ne rafraîchit que les règles **déjà présentes** dans le dépôt. Un
`cp rules/*.md` déverserait les dix-sept règles dans tous les projets, y compris
celles qui n'y servent à rien.

Le vérificateur signale une copie du hook qui aurait dérivé de la référence.

Ne recopiez que les règles des langages présents : une règle chargée pour rien
consomme du contexte à chaque session.

## Modifier une règle

Sur une branche de `standards-code`, avec dans le message de commit la raison
du changement et le projet qui l'a motivé. Une règle ajoutée sans incident
déclencheur finit ignorée.

Avant d'ajouter : est-ce qu'un linter ou le hook peut le vérifier ? Si oui, ça
n'a rien à faire dans un fichier de règles. Un CLAUDE.md est du contexte, pas
une configuration appliquée ; seul un hook s'exécute quoi qu'il arrive.

## Ce qui ne va pas dans ce dépôt

- Contexte commercial, noms de clients, organisation interne.
- Ce que Claude déduit du code : arborescence, liste des dépendances, aperçu de
  l'architecture.
- Ce qu'un linter vérifie déjà : longueur de ligne, ordre des imports, guillemets.
- Préférences personnelles de travail : elles vont dans `~/.claude/CLAUDE.md`.
