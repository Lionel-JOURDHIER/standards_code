# <Nom du projet>

@.claude/standards/socle-code.md

<!-- Ne dupliquez rien du socle ici. Ce fichier ne contient que ce qui est vrai
     pour CE dépôt et que Claude ne peut pas déduire du code. Cible : 60 lignes.
     Les commentaires HTML de ce type sont retirés avant injection dans le
     contexte : ils ne coûtent rien et servent de notes au mainteneur. -->

Une phrase : ce que fait l'application, pour qui, et la contrainte structurante
(mono-poste sans serveur, classeur Excel autonome, pipeline en 8 étapes...).

## Commandes

<!-- Uniquement celles qu'on tape vraiment. Pas la liste exhaustive. -->

| | |
|---|---|
| Lancer | `…` |
| Lint / format | `…` |
| Tests | `…` |
| Activer les hooks (une fois par machine) | `…` |

## Ce qui est spécifique à ce projet

- **Docstrings** : <format retenu + fichier exemplaire du dépôt>.
- **Journalisation** : <le mécanisme unique, et l'interdiction correspondante —
  p. ex. « loguru, jamais `logging` ni `print()` » ou « `print()` en CLI et
  `messagebox` en GUI, ne pas introduire de logger : choix délibéré »>.
- **Seuil de taille** : <n> lignes par fichier.
- **Tests** : <ce qui est couvert, ce qui ne l'est jamais et pourquoi>.
- **Commit** : <extension éventuelle du format, p. ex. `fix 06 : …`>.

## Dette existante

<!-- Nommer les fichiers déjà au-dessus du seuil. Sans cette liste, la règle de
     taille se transforme en refactorisations non demandées. -->

- `chemin/fichier` (n lignes) — à découper dans une branche dédiée, pas au
  détour d'un correctif.

## Pièges déjà payés

<!-- Le contenu le plus rentable du fichier : ce qu'on ne peut pas déduire du
     code et qui a coûté du temps une fois. Une ligne chacun, le pourquoi. -->

- …

## Après validation

Séquence à indiquer à l'utilisateur pour resynchroniser et relancer côté
Windows, sur `develop` :

```bash
git checkout develop
git pull
…
```

Fusionner `develop` dans `main` une fois la validation confirmée sur données
réelles — sur demande explicite uniquement.

---

<!-- Règles par langage : ne PAS les mettre ici, et ne pas les écrire à la main.
     Le sous-module en contient dix-sept, déjà rédigées et versionnées, dans
     .claude/standards/rules/ : python, tests-python, javascript, nodejs, vba,
     ml, donnees, bdd, deploiement, securite-api, agents-ia, streamlit,
     selenium, cicd, http, documentation, workflow-session.

     On copie celles qui servent, une par une, comme décrit dans le README du
     sous-module :

       cp .claude/standards/rules/python.md .claude/rules/python.md

     Chacune porte un frontmatter `paths` et ne se charge que sur les fichiers
     correspondants : un projet VBA ne charge jamais les règles ruff, et
     inversement. Ne recopier que les règles des langages et des composants
     présents — une règle chargée pour rien coûte du contexte à chaque session.

     Ce qui ne vaut que pour CE dépôt va dans le présent fichier, pas dans
     .claude/rules/, dont le contenu est celui du dépôt de standards et se fait
     écraser à chaque mise à jour. Même chose pour .claude/agents/ et
     .claude/commands/ (planner, implementer, reviewer, /backlog) : copies du
     sous-module, rafraîchies par hooks/maj-standards, pas à éditer ici. -->
