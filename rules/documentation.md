---
paths:
  - "docs/**"
  - "**/conf.py"
  - "**/*.rst"
  - "README.md"
---

# Documentation générée — Sphinx

<!-- `README.md` est dans la portée : c'est la porte d'entrée de la
     documentation, et la section qui y renvoie est décrite plus bas.

     Ce fichier traite la documentation *publiée*. Le format des docstrings
     dont elle est extraite est dans rules/python.md, la publication en
     intégration continue dans rules/cicd.md. -->

La documentation se **génère** à partir du code : ce qui est écrit deux fois
diverge une fois. Sphinx + `autodoc` extrait les docstrings ; ce qui n'est pas
dans une docstring n'a pas à être recopié dans un `.rst`.

## Mise en place

- Dépendances dans le groupe `doc`, jamais en production :
  `uv add --group doc sphinx sphinx-rtd-theme myst-parser`.
- Sources dans `docs/source/`, sortie hors du dépôt (`public/` ou `docs/build/`)
  et **ignorée** : du HTML généré n'a rien à faire dans l'historique.
- Construction : `uv run sphinx-build -b html docs/source public`. La commande
  exacte est écrite dans le `CLAUDE.md` du dépôt, comme les autres
  vérifications.
- Extensions attendues dans `conf.py` : `autodoc`, `napoleon` (indispensable —
  sans lui les sections `Args:` / `Returns:` de nos docstrings Google
  s'affichent en bloc de texte brut), `viewcode`, `myst_parser`, `mathjax` si
  le projet contient des formules.
- **Pas de `sys.path.insert` dans `conf.py`.** Le besoin signale un projet non
  installé : disposition `src/`, `uv sync`, et `autodoc` importe le paquet comme
  n'importe quel autre module. Même règle que pour les tests.

## Structure

- Un fichier par module, listé dans le `toctree` de `index.rst`. **Un fichier
  absent du `toctree` n'apparaît nulle part**, sans avertissement à la
  construction — c'est le premier symptôme d'une page « perdue ».
- `sphinx-apidoc -f -e -o docs/source/ src/<paquet>` régénère ces fichiers. Ce
  qui est régénéré ne se modifie pas à la main : les guides écrits à la main
  vivent dans des fichiers distincts, hors de la portée de la commande.
- Les guides (installation, prise en main, décisions d'architecture) en
  Markdown via `myst_parser`, pas en `.rst` : ils restent lisibles tels quels
  dans l'interface de Gitea, y compris quand personne n'a construit la doc.

## Accès depuis le README

Le `README.md` est le seul point d'entrée dont on est sûr qu'il sera lu. Il
porte une section **Documentation** qui donne, dans cet ordre :

1. l'adresse de la documentation publiée, si elle l'est ;
2. la commande pour la construire **et celle pour l'ouvrir** — un chemin de
   fichier seul n'est pas une instruction : le lecteur est sous Windows, sous
   WSL ou sur un serveur sans navigateur, et la commande n'est pas la même ;
3. un lien relatif vers les guides en Markdown de `docs/`, qui fonctionne dans
   l'interface de Gitea sans rien construire.

Bloc à recopier dans le README, à adapter au dépôt :

````markdown
## Documentation

- **En ligne** : <https://…>  *(à remplacer, ou à supprimer si non publiée)*
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

- **Sans rien construire** : [guides](docs/source/guides/).
````

Sous WSL, `xdg-open` échoue le plus souvent faute d'environnement de bureau :
c'est `explorer.exe` qui ouvre le navigateur Windows, et il attend une barre
oblique inverse. La dernière ligne du tableau est aussi celle qui sert quand la
doc est construite sur un serveur.

Le troisième point est ce qui garantit l'accessibilité : un lien relatif reste
valide dans Gitea, dans un clone, et dans la doc construite. Réciproquement, le
README est inclus dans la page d'accueil de la doc plutôt que recopié :

```rst
.. include:: ../../README.md
   :parser: myst_parser.sphinx_
```

## Publication

**Gitea n'a pas de service Pages** : le schéma `upload-pages-artifact` +
`deploy-pages` du support de formation ne fonctionne pas, et les permissions
`pages` / `id-token` qu'il réclame sont ignorées en silence — voir
`rules/cicd.md`.

- En intégration continue, la construction sert de **contrôle** : un
  avertissement Sphinx fait échouer le job (`-W`), ce qui attrape les
  références cassées et les modules absents du `toctree`.
- La publication proprement dite est un déploiement ordinaire, décrit dans le
  `CLAUDE.md` du dépôt. Voir ci-dessous.
- Tant que rien n'est publié, la section Documentation du README l'assume : une
  URL morte est pire que pas d'URL.

### Servir le HTML, pour avoir une URL à mettre dans le README

Sphinx produit un dossier de fichiers, pas un site. Il n'y a de lien à écrire
dans le README que si quelqu'un sert ce dossier.

- **Lier un `.html` brut de la forge ne fonctionne pas.** Gitea sert les
  fichiers bruts en téléchargement ou en texte, pas comme un site navigable, et
  les liens internes de Sphinx (feuille de style, recherche, renvois entre
  pages) seraient de toute façon cassés. À ne pas tenter.
- Consultation locale : `python -m http.server -d public 8000`. Pour soi, pas
  partageable — donc jamais dans le README comme si c'était une adresse.
- Adresse partagée : un service statique dans le `docker-compose.yml` du
  projet, qui monte le dossier construit en lecture seule.

  ```yaml
  docs:
    image: nginx:alpine
    volumes:
      - ./public:/usr/share/nginx/html:ro
    ports:
      - "8081:80"
  ```

  L'URL devient stable, la CI se contente de reconstruire le dossier, et c'est
  cette URL qui occupe le point 1 de la section Documentation du README.

## Ce qui vient des docstrings

- Docstrings Google, `napoleon` s'en charge — format dans `rules/python.md`.
- `r"""…"""` dès qu'une docstring contient une formule LaTeX ou une
  contre-oblique, sinon Python interprète les séquences d'échappement avant que
  Sphinx ne voie quoi que ce soit.
- Le support de formation met des exemples `>>>` dans les docstrings : le
  standard ne les reprend pas (`rules/python.md`, § Docstrings). Rien ne les
  exécute, donc ils mentent tôt ou tard. Un exemple qui doit rester juste est un
  test.
- Bibliographie (`sphinxcontrib-bibtex`, `:cite:p:`) : utile sur un projet de
  recherche qui cite des articles, inutile ailleurs. À n'installer que si le
  besoin existe.
