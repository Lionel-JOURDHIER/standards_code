# <nom-du-depot>

<!-- Le README s'adresse à quelqu'un qui arrive sans contexte : un collègue,
     soi-même dans six mois, un prestataire. Il répond à trois questions dans
     cet ordre — à quoi ça sert, comment je le fais tourner, où est le reste.

     Ce qui n'a PAS sa place ici :
     - les conventions de code -> .claude/standards/ ;
     - les instructions destinées à Claude -> CLAUDE.md ;
     - la documentation par module -> docs/, générée par Sphinx ;
     - un tutoriel d'installation de ruff, sphinx ou pytest : ce sont des
       conventions d'équipe, pas des informations sur CE projet.

     Ce qu'on ne fait pas :
     - pas de README généré par la CI à partir d'un README.template.md :
       une CI vérifie, elle ne corrige pas, et un job qui commit relance le
       job suivant (voir rules/cicd.md) ;
     - pas de badge servi par un site externe (shields.io, contrib.rocks) :
       derrière le proxy, ce sont des images cassées.

     Cible : une page, hors sections Docker et Documentation. Supprimer une
     section vide plutôt que d'écrire « à venir ». Retirer ces commentaires
     une fois le fichier rempli. -->

[![Tests](https://<gitea>/<groupe>/<depot>/actions/workflows/tests.yml/badge.svg?branch=develop)](https://<gitea>/<groupe>/<depot>/actions)
[![Lint](https://<gitea>/<groupe>/<depot>/actions/workflows/lint.yml/badge.svg?branch=develop)](https://<gitea>/<groupe>/<depot>/actions)

<!-- Badges servis par Gitea lui-même, donc pas de dépendance externe. Un par
     workflow réellement en place, pas davantage : un badge décoratif
     (« Ruff: checked ») n'est relié à rien et ment dès que la CI casse.
     Format à confirmer sur notre instance, il dépend de la version de Gitea. -->

Une à trois phrases : ce que fait le projet, pour qui, et la contrainte
structurante (mono-poste sans serveur, classeur Excel autonome, API interne
derrière le proxy, pipeline en 8 étapes…).

## Démarrage rapide

```bash
git clone <url> && cd <nom-du-depot>
uv sync                 # environnement + dépendances, d'après uv.lock
cp .env.example .env    # puis renseigner les valeurs
uv run <commande>       # lancer
```

<!-- `uv sync` crée le .venv : ni `python -m venv`, ni activation manuelle,
     ni `pip install`. `uv run` fonctionne sans activer quoi que ce soit.
     Le .env.example est versionné et liste toutes les variables requises ;
     l'application refuse de démarrer si l'une manque, c'est voulu. -->

### Prérequis

- Python <3.x> et [uv](https://docs.astral.sh/uv/)
- <base de données, service, accès réseau, compte…>

## Commandes

| Action | Commande |
|---|---|
| Lancer | `uv run <…>` |
| Tests | `uv run pytest` |
| Couverture | `uv run pytest --cov=src --cov-report=term-missing` |
| Lint | `uv run ruff check .` |
| Format | `uv run ruff format .` |
| Documentation | `uv run sphinx-build -b html docs/source public` |

<!-- Les mêmes commandes que le CLAUDE.md du dépôt et que la CI, à
     l'identique. Trois listes qui divergent donnent trois verdicts. -->

## Documentation

<!-- Voir .claude/standards/rules/documentation.md. Garder les trois entrées :
     l'URL n'existe pas toujours, la construction locale suppose un poste
     équipé, le lien relatif marche partout. Supprimer la première ligne si
     rien n'est publié — une URL morte est pire que pas d'URL. -->

- **En ligne** : <https://…>
- **En local** — construire, puis ouvrir :

  ```bash
  uv run sphinx-build -b html docs/source public
  uv run python -m webbrowser public/index.html
  ```

  Si cette seconde commande n'ouvre rien (poste sans navigateur déclaré, WSL
  sans `wslu`), au choix : `explorer.exe public\index.html` sous WSL,
  `start public\index.html` sous Windows, `xdg-open` sous Linux,
  `open` sous macOS. Sur un serveur :
  `python -m http.server -d public 8000`, puis <http://localhost:8000>.

- **Sans rien construire** : [guides](docs/source/guides/)

## Structure

<!-- Seulement les répertoires qu'il faut connaître pour s'y retrouver, une
     ligne chacun. Pas l'arborescence complète : elle est fausse au prochain
     commit. -->

```
src/<paquet>/     code de production
tests/            tests pytest
docs/source/      sources de la documentation
```

## Conteneur

<!-- Section à supprimer si le projet ne se déploie pas en conteneur. -->

```bash
docker compose up -d          # démarrer
docker compose logs -f <svc>  # suivre les journaux
docker compose down           # arrêter et supprimer conteneurs et réseaux
```

<!-- Images poussées sur le registre interne, jamais sur un registre public.
     Pas de mise à jour automatique tirée d'un registre (type Watchtower) :
     un déploiement se décide. Les variables du compose viennent du .env,
     jamais écrites dans le fichier versionné. -->

## Contribuer

<!-- Supprimer sur un dépôt à un seul auteur. -->

Branches `main` / `develop` / `feature/*` ; conventions dans
`.claude/standards/socle-code.md`. Activer le garde-fou de commit, une fois par
machine :

```bash
git config core.hooksPath .githooks
```

## Propriété

<!-- Une ligne : à qui appartient le dépôt, qui le maintient. Licence si le
     projet est diffusé hors de l'entreprise. -->
