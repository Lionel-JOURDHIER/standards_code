---
paths:
  - "**/*.bas"
  - "**/*.cls"
  - "**/*.frm"
---

# VBA

Pas de linter disponible : les règles ci-dessous tiennent par la relecture, donc
elles restent peu nombreuses et vérifiables à l'œil.

## Structure d'un module

```vba
Attribute VB_Name = "modNomModule"
Option Explicit

'==========================================================================
' modNomModule
' Rôle du module en une ligne.
' Dépend de : modParametres, modOutils
'==========================================================================

' Constantes privées, énumérations, types, puis publiques, puis privées.
```

- `Option Explicit` en tête de chaque module, sans exception.
- Les dépendances sont écrites dans l'en-tête. Pas d'appel circulaire : la
  hiérarchie des modules est décrite dans `ARCHITECTURE.md` du projet.

## Nommage

| Élément | Convention | Exemple |
|---|---|---|
| Constante | MAJUSCULES_SOULIGNE | `OUTIL_VERSION` |
| Énumération et ses valeurs | PascalCase | `CategorieLigne.ArticleRegulier` |
| Procédure publique | PascalCase, verbe actif | `ExtraireArticles` |
| Procédure privée | camelCase, verbe actif | `extraireArticles` |
| Variable publique | PascalCase | `NombreArticles` |
| Variable privée, paramètre | camelCase | `nombreArticles`, `nomFeuille` |

Préfixes d'intention :

| Préfixe | Type | Exemple |
|---|---|---|
| `col` | Long, numéro de colonne | `colIntitule` |
| `lig` | Long, numéro de ligne | `ligEntete` |
| `nb` | Long, compteur | `nbLignesEcartees` |
| `plg` | Range | `plgSource` |
| `feuille` | Worksheet | `feuilleImport` |
| `classeur` | Workbook | `classeurSource` |
| `dict` | Collection | `dictChapitres` |
| `is` | Boolean | `isDejaImporte` |

Nommage en français pour les concepts métier. Toute déclaration porte un type
explicite : `Dim valeur` crée un Variant sans le dire.

## Règles de gestion

Référencer le numéro en commentaire quand le code applique une règle du cahier
des charges. C'est le seul commentaire systématique accepté.

```vba
' RG-04 : est une ligne d'article toute ligne portant une unité et un intitulé
```

## Erreurs

- Pas de gestion d'erreur sur les cas impossibles par contrat. Faire confiance
  aux invariants.
- Gestion nécessaire sur ce qui peut vraiment échouer : fichiers, ressources
  externes, conversions de type.
- `On Error Resume Next` est toujours suivi d'un test de `Err` **et** refermé
  par `On Error GoTo 0` dans la même procédure. Laissé ouvert, il fait avaler
  silencieusement toutes les erreurs suivantes, y compris celles d'autres
  procédures appelées ensuite.

## Excel

- Lecture et écriture par blocs via un tableau Variant, jamais cellule par
  cellule : le facteur est de l'ordre de cent.

```vba
Dim donnees As Variant
donnees = plgSource.Value          ' une lecture
' ... traitement en mémoire ...
plgDestination.Value = donnees     ' une écriture
```

- `Application.Calculation`, `ScreenUpdating` et `EnableEvents` désactivés
  pendant un traitement massif **et rétablis dans tous les chemins de sortie**,
  y compris en cas d'erreur. Sortie prématurée sans rétablissement : Excel reste
  en calcul manuel, l'utilisateur croit à un bug de ses formules et le
  diagnostic prend une journée.
- Le gabarit est la source de vérité : repérer les repères par leur contenu
  (recherche du libellé) plutôt que par une position en dur, les gabarits
  hérités n'ont pas tous le même nombre de lignes.
- État persistant : noms définis du classeur plutôt que variables publiques.
  L'état voyage alors avec le fichier.
- Toute constante va dans `modParametres`. Pas de valeur magique dans le code.

## Traces de débogage

`MsgBox` et `Debug.Print` sont des outils de mise au point, pas de
journalisation. Aucun ne doit rester dans le code livré : une boîte de dialogue
oubliée dans une boucle bloque un import de mille lignes chez l'utilisateur.
Le suivi durable passe par l'onglet de contrôle créé à chaque import.

## Encodage

Les fichiers `.bas` sont en **Windows-1252**. Ne jamais les ouvrir dans un
éditeur qui les réencode en UTF-8 : les accents se cassent, le diff devient
illisible et l'import dans l'éditeur VBA échoue. Vérifier après toute
modification hors de l'éditeur VBA.

## Avant de livrer

- Compilation sans erreur (Débogage puis Compiler VBAProject).
- Audit du gabarit sur une feuille de vente vierge.
- Un cycle complet de bout en bout.
- Enregistrement en `.xlsm`.
