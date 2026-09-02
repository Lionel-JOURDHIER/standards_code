---
paths:
  - ".gitea/workflows/**"
  - ".github/workflows/**"
---

# Intégration continue — Gitea Actions

<!-- Les deux répertoires sont dans le glob volontairement : un dépôt migré
     depuis GitHub garde souvent .github/workflows le temps de la bascule.
     Le répertoire de référence chez nous est .gitea/workflows. -->

Gitea Actions reprend la syntaxe de GitHub Actions : un workflow copié depuis
GitHub démarre le plus souvent sans modification. C'est un piège autant qu'un
confort — **ce qui n'est pas supporté est ignoré en silence**, pas signalé. Un
workflow vert ne prouve donc pas que toutes ses clauses ont été appliquées.

## Ce qui est ignoré sans erreur

À ne jamais utiliser comme garde-fou : la clause est acceptée, puis n'a aucun
effet.

| Clause | Conséquence si on s'y fie |
|---|---|
| `permissions:` | Aucun moindre privilège. Gitea a son propre modèle de droits. |
| `jobs.<id>.environment` | **Pas de validation manuelle avant déploiement.** |
| `concurrency:` | Deux exécutions concurrentes peuvent se marcher dessus. |
| `timeout-minutes:` | Un job bloqué ne s'arrête pas tout seul. |

La deuxième ligne a une conséquence directe sur `rules/ml.md` : la règle
« aucune promotion automatique » ne peut pas être tenue par une règle de
protection d'environnement. La promotion reste une **action humaine hors CI**,
et le workflow s'arrête avant, il ne demande pas d'autorisation.

## Résolution des actions — le premier point de casse

`uses: actions/checkout@v4` n'est pas résolu localement : Gitea va le chercher
selon `DEFAULT_ACTIONS_URL`, qui ne vaut que `github` (téléchargement depuis
GitHub) ou `self` (uniquement depuis notre instance).

- Derrière le proxy de l'entreprise, un runner qui ne sort pas échoue sur la
  toute première étape, avec une erreur de résolution qui ne dit pas qu'il
  s'agit du réseau. C'est le premier suspect quand un workflow neuf ne démarre
  pas.
- Deux sorties : **miroiter les actions utilisées dans l'instance Gitea** et
  passer `DEFAULT_ACTIONS_URL=self`, ou épingler l'URL absolue —
  `uses: https://github.com/actions/checkout@v4` — que Gitea accepte pour
  n'importe quel dépôt git.
- Épingler une version (`@v4`), jamais une branche mouvante.

## Runners

- `runs-on:` désigne un **label de runner**, pas une image hébergée. `ubuntu-latest`
  ne veut dire que ce que le runner déclare sous ce label. Le lien label → image
  est de la configuration d'infrastructure : le documenter dans le `CLAUDE.md` du
  dépôt plutôt que de le supposer.
- Syntaxe simple uniquement : `runs-on: xyz` ou `runs-on: [xyz]`.
- Les runners sont les nôtres et persistent : ne jamais supposer une machine
  vierge, et ne jamais y laisser de secret sur disque.

## Jetons et secrets

- Le jeton fourni au job est `GITEA_TOKEN`. Un workflow repris de GitHub qui lit
  `GITHUB_TOKEN` est à relire.
- **Pas d'OIDC** (le scope `id-token` n'existe pas) : aucune authentification
  sans secret vers le registre interne. Il faut un jeton d'accès personnel ou un
  secret de dépôt, donc une rotation à prévoir et à écrire quelque part.
- Un secret n'est jamais échoïsé, ni passé en argument de ligne de commande
  (visible dans les logs de processus), ni écrit dans un artefact.
- Un scan de secrets (Gitleaks ou équivalent) en étape de CI, `fetch-depth: 0`
  pour couvrir tout l'historique et pas seulement le dernier commit, et la
  job en échec bloquant plutôt qu'informatif — un secret déjà poussé n'est
  plus un secret même après un correctif ultérieur, seule la rotation le
  répare.

## Publication de documentation

**Le schéma GitHub Pages ne fonctionne pas.** `upload-pages-artifact` et
`deploy-pages` reposent sur le scope de permission `pages` et sur un service
Pages, dont Gitea ne dispose pas. Un workflow de doc repris tel quel de GitHub
échouera, ou pire, produira un artefact que personne ne sert.

Construire la doc en CI reste utile — comme **contrôle** : un build Sphinx qui
casse fait échouer le job. La publication, elle, est un déploiement ordinaire
(artefact récupéré par le serveur, image servie par nginx, ou copie sur un
partage), à décrire dans le `CLAUDE.md` du dépôt.

## Contenu d'un workflow

- Déclencheurs explicites : `push` sur `develop` et `main`, `pull_request` vers
  ces deux branches. Pas de `on: [push]` nu, qui fait tourner la CI sur toutes
  les branches de travail et sature les runners.
- Les étapes reprennent **les commandes déclarées dans le `CLAUDE.md` du dépôt**,
  à l'identique. Une CI qui vérifie autre chose que ce qu'on lance en local
  donne deux verdicts et personne ne sait lequel croire.
- Python : `uv sync` puis `uv run …`. Pas de `pip install`, cohérent avec
  `rules/python.md`. Derrière le proxy : `uv sync --native-tls`.
- Un job qui installe des dépendances sans verrou (`uv.lock` absent du dépôt ou
  ignoré) ne teste pas la même chose que le poste de développement.
- Version de Python écrite dans le workflow et identique à celle du
  `pyproject.toml`. Une CI qui teste sur la version du runner change de verdict
  le jour où l'infrastructure est mise à jour, sans qu'aucun commit ne l'ait
  demandé. Une matrice ne se justifie que si le projet doit réellement
  fonctionner sur plusieurs versions — sinon elle multiplie le temps de runner
  pour rien.
- **Un seul appel à `pytest`** sur la suite entière, jamais une étape par
  fichier de test : les étapes suivantes ne s'exécutent pas après un échec, ce
  qui masque tous les autres défauts, et un fichier oublié à l'ajout n'est
  jamais lancé.
- Un job d'intégration continue vérifie, il ne corrige pas : pas de commit, pas
  de formatage automatique repoussé depuis la CI. `ruff format --check`, pas
  `ruff format`.
- L'entraînement d'un modèle ne tourne pas en CI : marqué `@pytest.mark.slow` et
  exclu, conformément à `rules/ml.md`.

## Un échec doit bloquer

Une CI que l'on peut ignorer ne sert qu'à décorer. Le caractère bloquant se
configure dans les **paramètres du dépôt Gitea** (protection de branche,
vérifications de statut requises), pas dans le workflow — la clause
`permissions:` et les règles d'environnement y sont sans effet.

Et la CI ne remplace pas les vérifications locales : elle constate ce qu'on
aurait dû voir avant de committer. Le crochet `pre-commit` reste le premier
filet.

## À vérifier sur notre instance avant d'y compter

La compatibilité varie selon la version de Gitea et celle d'`act_runner`. Ces
trois points décident de la forme des workflows et n'ont pas de réponse
générale — les tester une fois, puis écrire la réponse **dans `standards-code`,
sur une branche, et pas dans la copie locale de `.claude/rules/`** : cette
copie est écrasée à la prochaine mise à jour du sous-module. Ce qui ne vaut que
pour un dépôt (le label de runner réellement disponible, par exemple) va dans
son `CLAUDE.md`.

- Les expressions autres que `always()` — `success()`, `failure()`,
  `hashFiles()`, `contains()`. La documentation ne garantit qu'`always()`. Sans
  `hashFiles()`, pas de clé de cache calculée sur `uv.lock`.
- `actions/cache` et le serveur de cache d'`act_runner` : sans lui, chaque job
  retélécharge tout l'environnement.
- La lecture effective de `.github/workflows` en plus de `.gitea/workflows`.

Tant que ce n'est pas vérifié, écrire les workflows sans dépendre de ces trois
mécanismes : ils échouent en silence ou coûtent du temps de runner, jamais une
erreur claire.
