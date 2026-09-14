---
description: Gère BACKLOG.md. Usage : /backlog (état) | /backlog add <texte> | /backlog migrate | /backlog triage | /backlog next [S|M|L] | /backlog done <BL-xxx> [réf] | /backlog from-review
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git log:*), Bash(git diff:*), Bash(date:*)
---

Tu gères le fichier `BACKLOG.md` à la racine du dépôt. Respecte strictement le format décrit dans son en-tête. Ne touche jamais au code, seulement au backlog. Ne crée jamais de branche, de commit ni de PR.

Arguments reçus : `$ARGUMENTS`

## Sous-commandes

**(vide)** — État du backlog.
Affiche un tableau : nombre d'entrées par statut, puis les entrées « en cours » et les cinq premières « à faire ». Rien d'autre.

**add <texte>** — Nouvelle entrée.
Crée un bloc complet avec le prochain numéro BL. Déduis type, priorité et taille du texte ; si l'un des trois est vraiment incertain, pose une seule question groupée avant d'écrire. Source = `ajout manuel, <date du jour>`. Insère dans « À faire » à la bonne position, ou dans « Idées » si le texte est trop vague pour un critère de fin.

**migrate** — Convertit `TODO.md` vers le format structuré.
Lis `TODO.md`. Pour chaque item, propose un bloc BL rempli ; un item trop vague pour un critère de fin (« un jour… ») va dans « Idées », pas dans « À faire ». Présente d'abord un tableau récapitulatif (item d'origine → titre, type, priorité, taille proposés) et attends validation avant d'écrire dans `BACKLOG.md`. Après écriture, ajoute en tête de `TODO.md` la ligne `> Migré vers BACKLOG.md le <date>. Ce fichier n'est plus maintenu.` Ne supprime pas `TODO.md`.

**triage** — Nettoyage.
Pour chaque entrée « à faire » et « idées » : vérifie que le fichier cité existe encore et que le contexte est toujours vrai (`grep`, `git log`), détecte les doublons, propose priorité ou statut à changer. Sortie : un tableau des changements proposés, puis applique uniquement après validation.

**next [S|M|L]** — Recommandation.
Choisis la meilleure entrée « à faire » (priorité la plus haute, puis la plus petite taille ; filtre sur la taille donnée si précisée). Affiche le bloc complet et une phrase de justification. Ne change rien au fichier. Si l'utilisateur veut la lancer, il invoquera lui-même `planner` avec le numéro BL.

**done <BL-xxx> [réf]** — Clôture.
Passe l'entrée en « fait », ajoute `- Clos : <date>, <réf>` si une référence est fournie (branche `feature/*` fusionnée, commit ou `PR #n`), déplace le bloc dans « Fait ». Si « Fait » contient des entrées d'un mois antérieur, roule-les dans « Historique » en une ligne chacune : `BL-xxx · titre · <date>`.

**from-review** — Import depuis la dernière revue.
Cherche dans la conversation courante la dernière sortie de l'agent `reviewer`. Pour chaque constat PRE-EXISTANT et chaque suggestion non traitée, propose une entrée BL (type bug ou amélioration, source = `revue <branche ou PR>, <date>`). N'importe pas ce qui relève du cycle de session lui-même (clôturer une entrée, committer le backlog, amender un message de commit) : ce sont des gestes de fin de tâche, pas des entrées. Tableau récapitulatif, validation, puis écriture. S'il n'y a pas de revue dans la conversation, dis-le et arrête-toi.

## Format de sortie

Toujours : une ligne de bilan, un tableau si plusieurs éléments, les blocs BL complets uniquement quand ils sont créés ou modifiés. Pas de commentaire sur la méthode.
