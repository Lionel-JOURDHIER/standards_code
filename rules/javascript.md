---
paths:
  - "**/*.js"
  - "**/*.mjs"
  - "**/*.cjs"
  - "**/*.html"
---

# JavaScript

<!-- Code navigateur. Ce qui est propre à l'exécution côté serveur —
     dépendances npm, processus, système de fichiers — est dans
     rules/nodejs.md, qui se charge en plus de celle-ci sur ces fichiers. -->

## Outillage

- **Biome** pour le lint et le format, un seul outil, configuration dans
  `biome.json`. Installation des dépendances : voir `rules/nodejs.md`, qui est
  le seul endroit où la commande est donnée. Avant de committer :
  `npx biome check app && npx biome format --write app`
- Ce que Biome vérifie n'est pas répété ici.
- Pas de bundler ni de chaîne de build tant que le projet n'en a pas besoin.

## Organisation

- Vérifier avant d'écrire si le projet utilise les modules ES. Beaucoup de nos
  front-ends chargent un seul fichier par page via `<script src="...">`, en
  variables globales au fichier : dans ce cas `import`/`export` ne fonctionnent
  pas et introduire `type="module"` est un changement d'architecture, pas un
  détail de mise en forme.
- Un fichier par page ou par écran. Le seuil de taille est celui déclaré
  dans le `CLAUDE.md` du dépôt, le même pour tous les langages du projet.

## Documentation

- Chaque fichier démarre par un bloc `/** ... */` qui explique **pourquoi** le
  module existe, comme un en-tête de module Python.
- JSDoc sur toute fonction. Il n'y a pas de convention de préfixe pour le privé
  en JavaScript, donc pas d'exception.

## Erreurs et journalisation

- Jamais `console.log` ni `console.error` pour du diagnostic. Toute erreur passe
  par le canal déclaré par le projet, qui l'achemine vers les journaux du
  back-end.
- Une erreur donne toujours deux choses : un retour visuel à l'utilisateur et
  une trace exploitable. Une seule des deux est un bug.

```js
try {
  // appel au back-end
} catch (erreur) {
  afficherStatut(`... : ${erreur.message}`, "erreur"); // retour utilisateur
  journaliserErreur(`... : ${erreur.message}`);        // trace côté serveur
}
```

- Un `catch` qui ne fait ni l'un ni l'autre masque la panne : la page semble
  fonctionner et le journal est vide.

## Pièges

- **Applications packagées avec un webview embarqué** (WebView2, webkit2gtk) :
  le navigateur intégré met les fichiers en cache et sert une version périmée
  après mise à jour. Si le projet utilise un numéro de version manuel
  (`<script src="etape4.js?v=7">`), l'incrémenter à chaque modification du
  fichier. Un bug qui disparaît après vidage du cache vient de là.
- Un appel au pont natif est asynchrone même quand il en a l'air synchrone :
  `await`, et le `try`/`catch` autour, sinon l'erreur est avalée par une
  promesse non gérée.

## HTML

Le glob de cette règle couvre les `.html` : Biome ne les analyse pas, tout ce qui
suit tient donc à la relecture.

- Le numéro de version des `<script src="...?v=n">` est la contrepartie du piège
  de cache ci-dessus : il s'incrémente dans le HTML, pas dans le JS.
- Aucun gestionnaire d'événement en attribut (`onclick="..."`) : le
  comportement devient introuvable depuis le fichier JS.
- Aucune donnée serveur interpolée directement dans une balise `<script>`. Elle
  transite par un attribut `data-` ou par un appel au back-end, sinon la moindre
  apostrophe casse la page et la moindre saisie utilisateur devient une injection.
- Structure et style seulement : la logique va dans le `.js`, y compris quand
  elle tient en trois lignes.

## Style

- Nommage en français pour les concepts métier, `camelCase`.
- `const` par défaut, `let` si réassignation, jamais `var`.
- Comparaisons strictes `===`.
