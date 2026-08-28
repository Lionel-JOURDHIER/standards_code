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

<!-- Règles par langage : ne PAS les mettre ici. Créer .claude/rules/<langage>.md
     avec un frontmatter `paths` pour qu'elles ne se chargent que sur les
     fichiers concernés :

     ---
     paths:
       - "**/*.py"
     ---
     # Python
     - Docstrings Google en français sur tout élément public.
     - `uv run ruff check .` et `uv run ruff format .` avant commit.

     Idem rules/javascript.md (`**/*.js`) et rules/vba.md (`**/*.bas`).
     Le projet VBA ne charge alors jamais les règles ruff, et inversement. -->
