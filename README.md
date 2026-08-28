# standards-code

Source unique des conventions de code. Ce dépôt n'est jamais modifié depuis un
projet : une règle qui ne vaut que pour un projet va dans le `CLAUDE.md` de ce
projet.

```
socle-code.md            règles valables partout, importées dans chaque CLAUDE.md
rules/python.md          règles chargées seulement sur les .py
rules/javascript.md      idem .js
rules/vba.md             idem .bas / .cls / .frm
rules/ml.md              idem src/ml/
rules/workflow-session.md déroulé d'une session, chargé toujours
modeles/CLAUDE.md        à copier et remplir dans un nouveau dépôt
modeles/FICHE-MODELE.md  une par modèle promu en production
hooks/pre-commit         garde-fou git, configurable par dépôt
hooks/standards.conf.exemple
```

## Installer dans un dépôt

```bash
git submodule add <url>/standards-code.git .claude/standards
mkdir -p .claude/rules .githooks
cp .claude/standards/modeles/CLAUDE.md CLAUDE.md
cp .claude/standards/hooks/pre-commit .githooks/pre-commit
cp .claude/standards/hooks/standards.conf.exemple .githooks/standards.conf
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

Puis, pour chaque langage présent dans le dépôt :

```bash
cp .claude/standards/rules/python.md .claude/rules/python.md
```

Une copie plutôt qu'un lien symbolique : sous Windows les liens exigent les
droits administrateur ou le mode développeur. La contrepartie est que la copie
peut dater — d'où la commande de mise à jour ci-dessous.

Le `CLAUDE.md` du dépôt commence par `@.claude/standards/socle-code.md`. Le
chemin reste à l'intérieur du dépôt, donc pas de demande d'approbation au
premier lancement.

## Mettre à jour un dépôt

```bash
git -C .claude/standards pull
cp .claude/standards/rules/*.md .claude/rules/
cp .claude/standards/hooks/pre-commit .githooks/pre-commit
```

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
