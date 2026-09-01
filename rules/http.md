---
paths:
  - "**/clients/**/*.py"
  - "**/*_client.py"
  - "**/integrations/**/*.py"
---

# Appels HTTP sortants

<!-- Portée imparfaite, et c'est assumé : un appel HTTP peut apparaître dans
     n'importe quel .py, aucun glob ne l'attrape de façon fiable. Ces chemins
     couvrent l'endroit où l'on *doit* les regrouper. Volontairement pas
     "**/services/**" : dans un découpage en couches, c'est la logique métier,
     où il n'y a pas une ligne de réseau. Si un dépôt regroupe ses appels
     ailleurs, ajouter le chemin dans la copie locale.

     Cette règle traite le code qui *appelle* une API. Le code qui en *expose*
     une est dans rules/securite-api.md. -->

Tout accès réseau passe par un module dédié, jamais par un appel dispersé au
milieu de la logique métier : c'est ce qui rend l'appel testable, remplaçable
par un double, et repérable le jour où le fournisseur change.

## Client

- **httpx** par défaut, en asynchrone comme le reste de la pile. `requests`
  seulement dans un script synchrone déjà écrit ainsi. Un seul des deux par
  projet.
- Un client instancié une fois et réutilisé — dans le `lifespan` de
  l'application, ou en dépendance. Un `httpx.get(...)` par appel rouvre une
  connexion TLS à chaque fois et épuise les ports sous charge.
- `base_url` et en-têtes communs portés par le client, pas recopiés à chaque
  appel.

## Délai d'attente

**Aucun appel sans `timeout` explicite.** C'est la règle la plus importante du
fichier : sans délai, un serveur distant qui ne répond plus fige un worker
indéfiniment, puis tous les autres, et la panne se présente comme une
application lente sans erreur nulle part.

```python
client = httpx.AsyncClient(timeout=httpx.Timeout(10.0, connect=3.0))
```

Le délai de connexion est court, celui de lecture dépend de ce qu'on appelle —
une inférence de modèle n'a pas le budget d'un `GET` de configuration.

## Codes de retour

- Une réponse 4xx ou 5xx **n'est pas une exception** : sans
  `response.raise_for_status()`, le code continue avec un corps d'erreur.
- 4xx : c'est notre requête qui est fausse, ne pas réessayer, échouer avec un
  message qui contient le code et l'URL.
- 429 et 503 : respecter l'en-tête `Retry-After` s'il est présent, plutôt qu'une
  temporisation inventée.

## Réessais

- Uniquement sur les méthodes idempotentes (`GET`, `PUT`, `DELETE`) et sur les
  échecs transitoires (délai dépassé, 5xx, coupure réseau).
- **Jamais sur un `POST`** sans clé d'idempotence acceptée par le fournisseur :
  la première requête a pu aboutir et seule la réponse s'est perdue. On crée
  alors deux commandes, deux paiements, deux lignes.
- Temporisation exponentielle, nombre d'essais borné et écrit. Une boucle de
  réessai sans plafond transforme une panne distante en déni de service qu'on
  s'inflige.

## Proxy et certificats

- Le proxy de l'entreprise se configure par `HTTP_PROXY`, `HTTPS_PROXY` et
  `NO_PROXY` — jamais en dur dans le code.
- Autorité de certification interne : la déclarer (`SSL_CERT_FILE`,
  `REQUESTS_CA_BUNDLE`, `verify=<chemin>`). **Jamais `verify=False`**, même
  « temporairement pour tester » : la ligne survit et supprime toute garantie
  d'authenticité du serveur.

## Données

- La réponse d'un service tiers n'est pas de confiance : la valider avec un
  modèle Pydantic avant de s'en servir. Un champ absent découvert trois couches
  plus loin est indiagnostiquable.
- `response.json()` lève si le corps n'est pas du JSON — ce qui arrive
  précisément lors des pannes, quand le proxy renvoie une page HTML.
- Gros téléchargement : lecture en flux vers un fichier, pas `response.content`
  qui charge tout en mémoire.
- Pagination : suivre le lien fourni par l'API, et borner le nombre de pages.

## Secrets et journalisation

- Jeton en en-tête `Authorization`, **jamais en paramètre d'URL** : les proxies
  et les journaux d'accès enregistrent les URL complètes.
- Journaliser méthode, hôte, chemin, code et durée. Jamais les en-têtes
  d'authentification, jamais le corps complet d'une requête ou d'une réponse.

## URL construite depuis une saisie

Une URL qui provient d'un utilisateur — même indirectement, via un champ de
base — n'est jamais appelée telle quelle : liste blanche de domaines autorisés.
Sinon le serveur devient un relais vers le réseau interne et vers les services
de métadonnées de l'hébergeur.

## Tests

Aucun appel réseau réel dans les tests : le double est monté au niveau du
transport (`httpx.MockTransport`), ce qui vérifie aussi l'URL et les en-têtes
construits. Un test qui dépend d'un service distant échoue pour des raisons qui
n'ont rien à voir avec le code.
