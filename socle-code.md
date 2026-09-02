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
   correction opportuniste au détour d'un autre correctif. La frontière avec la
   priorité 1 : ce que j'écris ou réécris suit les conventions, ce qui existait
   autour et que je n'ai pas eu à toucher reste tel quel. Une docstring devenue
   fausse parce que j'ai changé le comportement appartient au premier lot, pas
   au second.

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

## Méthode : le plus simple qui règle le cas demandé

Dans cet ordre, à chaque fois :

1. **Formuler la règle métier** en une phrase, avant d'écrire une ligne. Un code
   qu'on n'arrive pas à décrire en une phrase résout un problème mal posé.
2. **Écrire la version la plus directe** qui traite le cas demandé, et rien
   d'autre.
3. **Ne factoriser qu'ensuite**, et seulement ce qui est prouvé identique.
4. **Supprimer ce que la modification vient de rendre inatteignable.** Du code
   retiré est du code gagné : il ne se maintient pas, ne se teste pas et ne se
   lit pas de travers. Le code mort qui préexistait n'entre pas dans le lot,
   c'est une tâche à part — sinon on retire au détour d'un correctif ce que la
   priorité 3 interdit de toucher. Et avant toute suppression, vérifier qu'il
   n'y a pas d'appel par nom — VBA, réflexion, point d'entrée déclaré en
   configuration — qu'aucune recherche de références ne fait apparaître.

### KISS

- Le besoin exprimé, pas le besoin imaginé. Pas de paramètre de configuration
  pour un cas qui ne s'est jamais présenté, pas de couche d'abstraction avec une
  seule implémentation, pas de moteur générique là où trois conditions
  suffisent. Le jour où le deuxième cas arrive, on le voit vraiment — et il ne
  ressemble presque jamais à celui qu'on avait anticipé.
- Une fonction dont on ne peut pas prédire le comportement à la lecture de sa
  signature est trop maligne, même si elle est courte.
- Préférer ce que la bibliothèque standard fait déjà à une réécriture, et une
  structure de données évidente à une astuce qui économise trois lignes.

### DRY

Ce qui ne doit pas être dupliqué, c'est une **règle**, pas des caractères.

- Une même valeur, un même seuil, un même format de fichier, une même règle de
  gestion : un seul endroit, toujours. Deux copies divergent, et c'est la
  mauvaise qui reste en production.
- Deux blocs qui se ressemblent aujourd'hui mais qui évolueront pour des raisons
  différentes **restent séparés**. Les fusionner crée un couplage qu'on paiera
  en ajoutant un paramètre booléen pour retrouver les deux comportements — et un
  booléen qui pilote le corps d'une fonction est le signe qu'il en fallait deux.
- Attendre la troisième occurrence avant d'extraire. À la deuxième, on ne sait
  pas encore ce qui est commun et ce qui est accidentel.

Les deux principes se contredisent régulièrement. Quand c'est le cas, KISS
l'emporte : une duplication se voit et se corrige, une mauvaise abstraction se
propage.

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
  travail. La mettre à jour (`git pull --ff-only`) **avant** d'en tirer une
  branche : une `feature/*` partie d'un `develop` en retard fusionne en
  conflits qui n'ont rien à voir avec la tâche.
- **`feature/<nom-kebab-case>`** : une branche par tâche, créée depuis
  `develop`, fusionnée dans `develop` par `git merge --no-ff`, puis supprimée.
  Pas de rebase, pas de squash : les commits restent tels qu'ils ont été écrits.
  `--no-ff` force un commit de fusion même quand l'avance rapide est possible,
  ce qui garde le regroupement de la tâche une fois la branche supprimée. Sans
  lui, l'option `-m` est ignorée en silence et le message de fusion est perdu.
- **`hotfix/<nom-kebab-case>`** : correction urgente créée depuis `main`,
  fusionnée dans `main` **et** dans `develop`.
- Ne jamais committer directement sur `main`.
- Une branche vit le temps d'une tâche. Au-delà de quelques jours, elle diverge
  plus vite qu'elle n'avance : découper la tâche et fusionner ce qui est fini.
- Une seule personne décide des fusions vers `main`. Côté assistant, cela se
  traduit par l'interdiction ci-dessous : la fusion dans `main` se demande, elle
  ne se prend pas.
- **Un commit = une unité cohérente**, c'est-à-dire une fonctionnalité, une
  correction ou une réécriture — pas une journée de travail, pas un fichier.
  C'est ce qui rend un `git revert` possible et un historique lisible.
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
- L'auteur du commit doit être identifiable : `git config user.name` et
  `user.email` renseignés sur le poste, avec l'adresse professionnelle. Un
  historique signé « root@machine » ne dit plus qui a écrit quoi.
- Un commit écrit par l'assistant porte la ligne de fin
  `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`, séparée du corps par
  une ligne vide. Uniformément : un historique où seuls certains la portent ne
  distingue plus rien.
- Avant de committer, lancer les vérifications déclarées dans le `CLAUDE.md` du
  dépôt. Ce qui n'est pas couvert par un outil automatique et a été vérifié à la
  main est écrit dans le message de commit.

## Ce qui ne doit jamais être commité

Le `.gitignore` est écrit à la création du dépôt, pas après le premier incident :
un fichier déjà suivi continue de l'être quand on l'ajoute au `.gitignore`, et
un secret déjà commité reste dans l'historique même après suppression — il est à
considérer comme divulgué, donc à révoquer.

- Données réelles : exports, fichiers clients, adresses, noms de personnes,
  configuration pointant vers un partage réel. Seuls les jeux d'essai
  synthétiques sont légitimes dans le dépôt.
- Secrets : clés d'API, mots de passe, chaînes de connexion.
- Artefacts régénérables : rapports de couverture, dossiers de build,
  dépendances installées.
- Avant tout `git add` large (`git add .`), vérifier `git status`.
