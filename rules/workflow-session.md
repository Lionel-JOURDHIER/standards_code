# Déroulé d'une session

<!-- Pas de frontmatter `paths` : cette règle se charge à chaque session. -->

## Démarrage

1. Lire `SESSION.md` — où en était le travail précédent.
2. Lire `ARCHITECTURE.md` — état courant de l'architecture.
3. Si le dépôt a un graphe de code, l'interroger avant tout parcours de fichiers
   bruts (commande dans le `CLAUDE.md` du dépôt).
4. Identifier la seule tâche de la session.

## Pendant

- Une tâche à la fois, sur une branche `feature/*` créée depuis `develop`.
- Ne pas changer de modèle en cours de session : le cache de prompt est invalidé
  et la session redevient coûteuse.
- Texte uniquement dans le contexte. Un PDF ou une capture d'écran passent par
  une extraction texte préalable.
- Surveiller `/context`, qui visualise la fenêtre courante — `/usage` et son
  alias `/cost` mesurent le forfait, pas le contexte. Au-delà de 120 k jetons :
  finir le point en cours, puis `/clear`. Si la tâche n'est pas terminée, la
  découper et committer ce qui est fait plutôt que de continuer dans un contexte
  saturé.
- Préférer `/clear` avec un `SESSION.md` à jour plutôt que la compaction
  automatique : le résumé écrit est relu tel quel à la session suivante.

## Fin de tâche, dans cet ordre

1. Les vérifications déclarées dans le `CLAUDE.md` du dépôt passent (lint,
   tests, compilation — selon ce que le projet possède réellement).
2. Ce qui a été vérifié à la main est noté, pour figurer dans le message de
   commit.
3. Résumé écrit dans `SESSION.md` au format ci-dessous.
4. Relecture du résumé avec l'utilisateur avant de continuer.
5. `ARCHITECTURE.md` mis à jour si l'architecture a bougé.
6. Commit sur la branche `feature/*`, fusion dans `develop`, suppression de la
   branche.
7. `/clear`.

Ne jamais faire `/clear` avant que les vérifications passent et que `SESSION.md`
soit relu. Tout ce qui n'est pas écrit est perdu.

## Format d'une entrée de SESSION.md

```markdown
## [AAAA-MM-JJ] — <nom de la tâche>

**Branche :** feature/<slug>

**Fait :**
-

**Décisions techniques :** (avec la raison, pas seulement le choix)
-

**Fichiers principaux modifiés :**
- `chemin/fichier` — en une ligne

**Vérifié :** (ce qui a été testé à la main, ce qui ne l'a pas été)
-

**Points de vigilance pour la suite :**
-
```

## ARCHITECTURE.md

- Mis à jour à chaque tâche qui change la structure, pas en fin de projet.
- Contient : pile technique, découpage des modules, points d'entrée, variables
  d'environnement clés.
- Deux pages maximum. C'est la mémoire longue de l'architecture ; `SESSION.md`
  est la mémoire courte et n'a pas vocation à être relu en entier.

## Démarrage d'un nouveau projet

1. Lire le brief ou le cahier des charges.
2. Produire `PROJECT_KICKOFF.md` : besoins utilisateurs, priorisation MoSCoW,
   liste des fonctionnalités.
3. Faire valider le cadrage avant d'écrire une ligne de code.
4. Initialiser `ARCHITECTURE.md`, `SESSION.md`, le `CLAUDE.md` depuis le modèle.
5. Créer `develop` et la structure de dossiers.
