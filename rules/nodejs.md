---
paths:
  - "**/package.json"
  - "**/*.mjs"
  - "**/*.cjs"
  - "server/**/*.js"
  - "scripts/**/*.js"
---

# Node.js

<!-- Partage de portée avec rules/javascript.md, qui couvre "**/*.js" : sur un
     fichier serveur, les deux règles se chargent. C'est voulu — le style, la
     documentation et la gestion d'erreurs de javascript.md restent valables.
     Ce fichier ne traite que ce qui est propre à l'exécution hors navigateur :
     dépendances, processus, système de fichiers, sécurité serveur.

     Si un dépôt range son code serveur ailleurs que dans server/ ou scripts/,
     ajouter le chemin dans la copie locale. -->

## Dépendances

- **npm**, `package-lock.json` versionné. Pas de yarn ni de pnpm en parallèle :
  deux verrous divergent toujours.
- En CI et à l'installation d'un poste : `npm ci`, qui installe exactement le
  verrou et échoue s'il a dérivé du `package.json`. `npm install` le réécrit
  silencieusement, ce qui n'est pas ce qu'on veut d'une machine de build.
- Champ `engines` renseigné avec la version de Node visée. Sans lui, rien ne
  signale qu'un poste tourne deux majeures en arrière.
- Rien en installation globale : une dépendance non déclarée marche sur le poste
  de celui qui l'a installée et nulle part ailleurs. `npx` pour l'outillage
  ponctuel.
- Ajouter une dépendance est une décision : regarder ce qu'elle tire avec elle.
  `npm audit` avant livraison ; jamais `--force`, qui installe des versions
  incompatibles pour faire taire l'avertissement.

## Proxy et certificats

- `npm config set proxy` / `https-proxy`, et `cafile` pointant sur l'autorité de
  certification interne.
- **Jamais `strict-ssl false`** ni `NODE_TLS_REJECT_UNAUTHORIZED=0`. Le second
  désactive la vérification TLS pour tout le processus, y compris les appels
  sortants de l'application, pas seulement pour npm.

## Modules

- Choisir ESM ou CommonJS et le déclarer (`"type": "module"`), une fois pour le
  paquet. Mélanger `require` et `import` dans le même paquet produit des erreurs
  de chargement qui ne pointent pas vers leur cause.
- Les scripts `npm` sont les points d'entrée documentés du projet. Une commande
  à rallonge dans `scripts` va dans un fichier `.mjs` appelé par le script.

## Processus et erreurs

- `async`/`await` avec `try`/`catch`. Une promesse rejetée sans gestionnaire
  **arrête le processus** sur les versions récentes de Node.
- `process.on('unhandledRejection')` sert à journaliser avant de sortir, pas à
  continuer comme si de rien n'était : l'état du processus n'est plus connu.
- Sortir avec un code non nul en cas d'échec. Un script qui échoue en affichant
  un message et en rendant 0 passe pour un succès en CI.
- Ne pas bloquer la boucle d'événements : `fs/promises` plutôt que les variantes
  `...Sync`, sauf au démarrage avant que le serveur n'accepte des connexions.

## Configuration et secrets

- Tout par `process.env`, lu **au démarrage et en un seul endroit**, avec un
  arrêt explicite si une variable requise manque — même règle que côté Python.
  Pas de valeur par défaut silencieuse pour une URL ou un secret.
- Aucun secret dans `package.json`, ni dans les scripts npm, ni dans un fichier
  versionné. `.env` dans `.gitignore`, `.env.example` versionné.

## Sécurité

- **Jamais `exec` avec une chaîne construite** : `execFile`/`spawn` avec un
  tableau d'arguments. Une chaîne passe par un shell, donc tout caractère de
  contrôle dans une valeur devient une commande.
- Un chemin issu d'une saisie ne se concatène pas : résoudre, puis vérifier que
  le résultat est bien sous le répertoire autorisé. `path.join` accepte
  parfaitement `../../`.
- Pas de `eval`, pas de `new Function`, pas de `require` sur un chemin calculé à
  l'exécution.
- En conteneur : utilisateur non root, `node_modules` dans `.dockerignore`,
  installation par `npm ci --omit=dev`.

## Journalisation

Un seul mécanisme par projet, déclaré dans le `CLAUDE.md` du dépôt, comme côté
Python. `console.log` est un outil de mise au point : il ne reste pas dans le
code livré, et il n'a ni niveau, ni horodatage, ni destination configurable.
