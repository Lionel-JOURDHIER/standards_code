---
paths:
  - "**/*.py"
---

# Python

## Outillage

- **uv** exclusivement : `uv sync`, `uv run <script>`, `uv add <paquet>`. Jamais
  `pip install`, jamais poetry, jamais d'activation manuelle du venv — `uv run`
  s'en charge et fonctionne à l'identique sous Windows et Linux.
- `uv.lock` est la source de vérité des versions et est committé. Ne pas
  maintenir en plus un `requirements.txt` : deux verrous divergent toujours.
- Derrière le proxy de l'entreprise : `uv sync --native-tls`.
- **ruff** pour le lint et le format. Avant de committer :
  `uv run ruff check --fix . && uv run ruff format .`
- Ce que ruff vérifie n'a pas à être répété ici : longueur de ligne, ordre des
  imports, guillemets, présence des docstrings.

## Structure d'un projet

- Le code vit sous `src/<nom_du_package>/`, jamais à la racine. **Le nom du
  package suit le nom du dépôt.** La racine ne porte que ce qui décrit le
  projet : `pyproject.toml`, `README.md`, `CLAUDE.md`, la CI, le Dockerfile.
- `__init__.py` déclare l'API publique du package avec `__all__`. Ce qui n'y
  figure pas est un détail d'implémentation : on peut le renommer sans prévenir.
  C'est ce qui rend l'interdiction de `import *` tenable au lieu d'arbitraire.
- Les tests vivent dans `tests/` à la racine, hors du package livré.
- Un module exécutable protège son point d'entrée par
  `if __name__ == "__main__":`, et cette clause ne contient qu'un appel. La
  logique est dans une fonction importable, donc testable — sans quoi elle
  s'exécute au moindre import et ne peut être appelée par rien d'autre.

## Classes

- `@property` / `@x.setter` avec validation qui lève `ValueError` dès qu'un
  attribut doit respecter une règle (bornes, format, cohérence avec un autre
  champ). Un attribut public non contrôlé délègue la vérification à chaque
  appelant, donc à aucun.
- Pas de `get_x()` / `set_x()` sans logique : en Python c'est un attribut, et on
  ajoute la `property` le jour où une règle apparaît, sans changer les appelants.
- Un objet qui ne fait que porter des champs est une `dataclass`, pas une classe
  écrite à la main.

## Docstrings

Style Google, en français. Contrôlé par la règle `D` de ruff quand le projet
l'active.

```python
def charger_parc(chemin: Path, marche: str) -> dict[str, Logement]:
    """Construit le parc à partir d'un export bailleur.

    Args:
        chemin: Fichier xlsx exporté depuis l'outil bailleur.
        marche: Code marché à quatre chiffres, non padé.

    Returns:
        Logements indexés par code, y compris les duplicables.

    Raises:
        FileNotFoundError: Si l'export est absent.
        ValueError: Si une colonne attendue manque.
    """
```

- Ce qui est déjà dit par le nom, les annotations de type et la signature n'est
  pas répété. Une fonction évidente prend un résumé d'une ligne, pas un
  `Args:`/`Returns:` complet.
- `Raises:` est obligatoire dès qu'une exception est levée volontairement :
  c'est le seul endroit où l'appelant peut l'apprendre.
- Fonctions privées (`_nom`) : docstring seulement si la logique n'est pas
  triviale.

## Typage

- Annotations sur toute signature publique. Le type de retour aussi, y compris
  `-> None`.
- Syntaxe moderne : `list[str]`, `dict[str, int]`, `str | None`. Pas de
  `typing.List` ni de `Optional`.
- `Path` plutôt que des chemins en chaîne, `pathlib` plutôt que `os.path`.

## Erreurs

- Lever une exception standard au message utilisable plutôt qu'un type maison :
  `FileNotFoundError`, `ValueError`, `KeyError`. Une exception dédiée seulement
  si l'appelant doit la distinguer pour agir différemment.
- Le message dit quoi et où : `f"Colonne '{nom}' absente de {chemin.name}"`.
- Jamais de `except:` ni de `except Exception:` sans re-levée. Rattraper le type
  précis attendu.
- Les exceptions remontent jusqu'au point d'entrée (CLI, fenêtre, route) qui
  décide de l'affichage. Pas de rattrapage intermédiaire qui transforme une
  erreur en valeur par défaut silencieuse.

## Journalisation

- Un seul mécanisme par projet, déclaré dans le `CLAUDE.md` du dépôt. Ne jamais
  en introduire un second, ni remplacer celui en place au détour d'un correctif.
- Projets sous **loguru** : la configuration des sinks est centralisée dans un
  module unique. Un point d'entrée fait `from logger import logger`, un module
  seulement importé fait `from loguru import logger` — loguru est global, les
  sinks sont hérités. `logger.add()` et `logger.remove()` nulle part ailleurs :
  une double configuration duplique chaque ligne de log.
- Arguments passés en style loguru, pas en f-string :
  `logger.error("lecture {} : {}", chemin, err)`. La chaîne n'est formatée que
  si le niveau est actif.
- Niveaux : `debug` pour le détail technique, `info` pour le suivi normal d'une
  étape, `warning` pour un cas dégradé mais géré, `error` pour un échec.

## Configuration

- Aucune URL, aucun chemin réseau, aucun identifiant en dur dans le code.
  Variables d'environnement lues au même endroit (`config.py`), valeurs par
  défaut pour le développement local.
- Le basculement entre contextes de déploiement se fait par une variable, pas
  par du code conditionnel dispersé.

## Choix par défaut

Valables sauf décision contraire écrite dans le `CLAUDE.md` du dépôt, avec sa
raison :

| | |
|---|---|
| Persistance | SQLAlchemy 2.0 en asynchrone, migrations Alembic |
| Base locale ou `.exe` | SQLite (`aiosqlite`) |
| Base serveur | PostgreSQL (`asyncpg`) |
| Tests | SQLite en mémoire |
| Paquetage Windows | PyInstaller |
| Déploiement serveur | `docker-compose.yml`, images sur le registre interne |

Le code SQLAlchemy reste identique d'un contexte à l'autre : seule l'URL change.

## Style

- Nommage en français pour les concepts métier (`affaire`, `logement`,
  `escalier`), `snake_case`, explicite plutôt que court.
- Pas d'import avec `*`.
- Une fonction qui dépasse l'écran ou qui atteint trois niveaux d'indentation
  demande une extraction, pas un commentaire.
