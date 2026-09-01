# Socle commun — conventions de code

Fichier partagé par tous les dépôts, versionné dans `standards-code`. Il ne
contient que ce qui est vrai quel que soit le langage. Tout ce qui dépend du
projet (outillage, journalisation, tests, format de docstring, seuils) vit dans
le `CLAUDE.md` du dépôt ou dans `.claude/rules/<langage>.md`.

Ne jamais modifier ce fichier depuis un dépôt : une règle qui ne vaut que pour
un projet n'a rien à faire ici.

## Priorités en cas de conflit

1. Ces conventions — ce socle et les `rules/*.md` — s'appliquent à tout code
   **écrit ou modifié**, y compris dans un fichier qui ne les respecte pas
   ailleurs. Mais le reste du fichier n'est pas repris pour autant : on signale
   l'écart, on ne réécrit pas l'existant au détour d'une modification. Deux
   choses ne se laissent jamais en l'état par simple imitation du fichier : un
   secret ou une donnée réelle exposés, et un risque de perte de données. Cela
   se corrige, ou se signale immédiatement si la correction sort du cadre de la
   demande.
2. Ne jamais introduire un outil ou une dépendance qui n'est pas déjà dans le
   projet — logger, linter, framework de test, formateur, bibliothèque tierce —
   **sans le demander d'abord**, y compris quand l'ajout paraît évident ou
   minuscule. Les outils nommés dans les `rules/*.md` (Alembic, httpx, slowapi,
   pwdlib…) sont les défauts d'un projet ou d'un composant **neuf** : dans un
   dépôt existant qui ne les a pas, la règle ne s'applique pas d'elle-même. On
   signale l'écart, on propose l'ajout, on attend l'accord.
3. Une modification fait une chose. Pas de reformatage, de renommage ni de
   correction opportuniste au détour d'un autre correctif.

## Docstrings et en-têtes

- Un module/fichier démarre par un en-tête qui explique **pourquoi** il existe
  et ce qu'il apporte par rapport au reste du projet, pas seulement ce qu'il
  contient.
- Documenter ce que le nom et la signature ne disent pas déjà : une règle
  métier, un effet de bord, une exception levée, un piège. Le format retenu
  (Google, JSDoc, en-tête de module VBA) est fixé par projet.
- **Une docstring est du code** : toute modification de signature, de
  comportement ou d'exceptions levées met à jour la docstring correspondante
  dans le même commit. Une docstring obsolète est pire qu'aucune docstring.

## Commentaires

- Ne pas commenter ce que le code dit déjà : des noms explicites suffisent.
- Un commentaire n'a de valeur que s'il explique un **pourquoi** non évident :
  contrainte externe (format imposé, API tierce), contournement d'un bug précis,
  invariant qui surprendrait un relecteur.
- Pas de commentaire référençant une tâche, un ticket, un historique de
  correctif ou une conversation : cette information vit dans le message de
  commit.
- Pas de code mort laissé en commentaire : git le retrouve.

## Découpage et nommage

- Une fonction fait une chose et tient à l'écran. Au-delà, extraire plutôt
  qu'ajouter un niveau d'indentation.
- Un fichier au-dessus du seuil du projet mélange plusieurs responsabilités :
  en extraire une partie plutôt que de le laisser grossir.
- Le seuil s'applique au **code nouveau**. Les fichiers déjà au-dessus sont une
  dette identifiée (listée dans le `CLAUDE.md` du dépôt) : ne pas les découper
  en urgence ni au détour d'un autre correctif, mais dans une branche dédiée le
  jour où l'un d'eux doit être modifié en profondeur.
- Pas de valeur magique : toute constante porte un nom et vit à l'endroit prévu
  par le projet.
- Nommage en français pour les concepts métier, explicite plutôt que court.

## Erreurs

- Les erreurs prévisibles (fichier absent, colonne manquante, saisie invalide)
  sont signalées explicitement au plus près de leur détection, avec un message
  utilisable, et traitées au point d'entrée pour affichage à l'utilisateur.
- Ne jamais rattraper une erreur pour la taire : un `except` large et muet, un
  `On Error Resume Next` sans vérification, un `catch` vide sont des bugs en
  attente.
- Ne pas empiler de vérifications défensives sur des invariants déjà garantis
  ailleurs par contrat.

## Git : Git Flow

Branches `main` / `develop` / `feature/*` / `hotfix/*`.

- **`main`** : ligne stable. Ne reçoit du contenu que par fusion d'un
  `hotfix/*`, ou de `develop` une fois le travail validé par l'utilisateur sur
  sa machine. Pas de branche `release/*` tant que le versionnement n'est pas
  formalisé.
- **`develop`** : branche d'intégration, branche par défaut de tout nouveau
  travail.
- **`feature/<nom-kebab-case>`** : une branche par tâche, créée depuis
  `develop`, fusionnée dans `develop` par `git merge` (pas de rebase, pas de
  squash — historique simple), puis supprimée.
- **`hotfix/<nom-kebab-case>`** : correction urgente créée depuis `main`,
  fusionnée dans `main` **et** dans `develop`.
- Ne jamais committer directement sur `main`.
- Message de commit au format `type : résumé`, `type` pris dans cette liste :

  | Type | Pour |
  |---|---|
  | `feat` | nouvelle fonctionnalité ou comportement visible |
  | `fix` | correction d'un défaut |
  | `docs` | documentation seule — README, docstrings, conventions |
  | `refactor` | réécriture sans changement de comportement |
  | `test` | ajout ou correction de tests seuls |
  | `chore` | dépendances, configuration, outillage, `.gitignore` |
  | `ci` | workflows d'intégration continue |

  Un commit qui relèverait de deux types en fait probablement deux. Un projet
  peut ajouter un type, pas remplacer la liste.

## Commits

- Toute modification validée par l'utilisateur (code, docstrings, documentation)
  est committée avant de passer à la suite, sur une branche `feature/*`
  fusionnée dans `develop`. L'ordre est celui de `rules/workflow-session.md` :
  vérifications, résumé dans `SESSION.md`, relecture avec l'utilisateur, puis
  commit. Une fois le résumé validé, committer sans redemander confirmation, et
  sans laisser des changements non commités s'accumuler d'une tâche à l'autre.
- Ne jamais pousser (`git push`), forcer un push, fusionner dans `main` ni
  réécrire l'historique sans demande explicite. Le commit automatique ne couvre
  que les commits locaux et la fusion locale dans `develop`.
- Avant de committer, lancer les vérifications déclarées dans le `CLAUDE.md` du
  dépôt. Ce qui n'est pas couvert par un outil automatique et a été vérifié à la
  main est écrit dans le message de commit.

## Ce qui ne doit jamais être commité

- Données réelles : exports, fichiers clients, adresses, noms de personnes,
  configuration pointant vers un partage réel. Seuls les jeux d'essai
  synthétiques sont légitimes dans le dépôt.
- Secrets : clés d'API, mots de passe, chaînes de connexion.
- Artefacts régénérables : rapports de couverture, dossiers de build,
  dépendances installées.
- Avant tout `git add` large (`git add .`), vérifier `git status`.
