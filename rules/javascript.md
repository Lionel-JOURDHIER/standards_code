---
paths:
  - "**/*.js"
  - "**/*.html"
---

# JavaScript

## Outillage

- **Biome** pour le lint et le format, un seul outil, configuration dans
  `biome.json`. Installation une fois par machine : `npm install` (nécessite
  Node.js). Avant de committer :
  `npx biome check app && npx biome format --write app`
- Ce que Biome vérifie n'est pas répété ici.
- Pas de bundler ni de chaîne de build tant que le projet n'en a pas besoin.

## Organisation

- Vérifier avant d'écrire si le projet utilise les modules ES. Beaucoup de nos
  front-ends chargent un seul fichier par page via `<script src="...">`, en
  variables globales au fichier : dans ce cas `import`/`export` ne fonctionnent
  pas et introduire `type="module"` est un changement d'architecture, pas un
  détail de mise en forme.
- Un fichier par page ou par écran. Même seuil de taille qu'en Python.

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

## Style

- Nommage en français pour les concepts métier, `camelCase`.
- `const` par défaut, `let` si réassignation, jamais `var`.
- Comparaisons strictes `===`.
