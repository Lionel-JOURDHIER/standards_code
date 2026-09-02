# <nom-du-depot>

<!-- Le README s'adresse à quelqu'un qui arrive sur le dépôt sans contexte :
     un collègue, soi-même dans six mois, un prestataire. Il répond à trois
     questions dans cet ordre — à quoi ça sert, comment je le fais tourner, où
     est le reste. Tout le reste est ailleurs.

     Ce qui n'a PAS sa place ici :
     - les conventions de code -> .claude/standards/ ;
     - les instructions destinées à Claude -> CLAUDE.md ;
     - la documentation technique par module -> docs/, générée par Sphinx ;
     - l'historique des décisions -> journal de décisions ou commits.

     Cible : une page. Supprimer les sections sans contenu plutôt que d'écrire
     « à venir » — une section vide donne l'impression d'un dépôt abandonné.
     Ces commentaires HTML sont à retirer une fois le fichier rempli. -->

Une à trois phrases : ce que fait le projet, pour qui, et la contrainte
structurante (mono-poste sans serveur, classeur Excel autonome, API interne
derrière le proxy, pipeline en 8 étapes…).

## Prérequis

<!-- Uniquement ce qui n'est pas installable par la commande d'installation
     ci-dessous : version de Python, uv, Docker, accès réseau, compte. -->

- Python <3.x> et [uv](https://docs.astral.sh/uv/)
- <base de données, service, accès…>

## Installation

```bash
git clone <url>
cd <nom-du-depot>
uv sync
cp .env.example .env   # puis renseigner les valeurs
```

<!-- Le .env.example est versionné et liste toutes les variables requises,
     valeurs vides ou fictives. L'application refuse de démarrer si l'une
     manque : c'est voulu, voir le socle. -->

## Utilisation

```bash
uv run <commande>
```

| | |
|---|---|
| Lancer | `…` |
| Tests | `uv run pytest` |
| Lint / format | `uv run ruff check` / `uv run ruff format` |

<!-- Les mêmes commandes que le CLAUDE.md du dépôt et que la CI, à
     l'identique. Trois listes qui divergent donnent trois verdicts. -->

## Documentation

<!-- Voir .claude/standards/rules/documentation.md. Garder les trois entrées :
     l'URL n'existe pas toujours, la construction locale suppose un poste
     équipé, et le lien relatif marche partout. Supprimer la première ligne
     si rien n'est publié : une URL morte est pire que pas d'URL. -->

- **En ligne** : <https://…>
- **En local** — construire puis ouvrir :

  ```bash
  uv run sphinx-build -b html docs/source public
  ```

  | Environnement | Ouvrir la page d'accueil |
  |---|---|
  | Windows | `start public\index.html` |
  | WSL | `explorer.exe public\index.html` |
  | Linux bureau | `xdg-open public/index.html` |
  | macOS | `open public/index.html` |
  | Serveur sans navigateur | `python -m http.server -d public 8000`, puis <http://localhost:8000> |

- **Sans rien construire** : [guides](docs/source/guides/)

## Structure

<!-- Seulement les répertoires qu'il faut connaître pour s'y retrouver, avec
     une ligne chacun. Pas l'arborescence complète : elle est fausse dès le
     prochain commit. -->

```
src/<paquet>/     code de production
tests/            tests pytest
docs/source/      sources de la documentation
```

## Contribuer

<!-- Supprimer cette section sur un dépôt à un seul auteur. -->

Branches `main` / `develop` / `feature/*`, conventions dans
`.claude/standards/socle-code.md`. Activer le garde-fou de commit une fois par
machine :

```bash
git config core.hooksPath .githooks
```

## Licence / propriété

<!-- Une ligne. Sur un dépôt interne : à qui il appartient et qui le maintient. -->
