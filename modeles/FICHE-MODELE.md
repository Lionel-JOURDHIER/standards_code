# Fiche modèle — <nom>

<!-- Une fiche par modèle promu, versionnée à côté du code, mise à jour à chaque
     nouvelle version promue. C'est le document qu'on relit six mois plus tard
     quand le modèle se met à mal se comporter et que personne ne se souvient
     des hypothèses. Cible : une page. -->

| | |
|---|---|
| Version registry | `models:/<nom>/<version>` |
| Commit git | `<sha>` |
| Version dataset | `<tag DVC>` |
| Run MLflow | `<uri>` |
| Promu le / par | |

## Décision servie

Quelle décision est prise à partir de la sortie, par qui, et ce qui se passe si
elle est fausse. Si la réponse est « on regarde », le modèle n'a pas besoin
d'être en production.

## Données

- Source, période couverte, périmètre géographique.
- Volume, répartition des classes.
- Méthode de découpage (spatial / temporel / aléatoire) et pourquoi.
- **Ce qui n'est pas couvert** : zones, types d'ouvrages, conditions de saisie
  absents du jeu d'entraînement. C'est la section la plus utile de la fiche.

## Résultats

| | Baseline | Champion précédent | Ce modèle |
|---|---|---|---|
| <métrique de décision> | | | |
| Tranche la plus faible | | | |
| Latence p95 | | | |

Métrique de décision choisie avant l'entraînement : <laquelle et pourquoi>.

## Coût des erreurs

- Faux positif : conséquence concrète, coût estimé.
- Faux négatif : idem.
- Seuil de confiance retenu et volume d'abstentions attendu.

## Limites connues

Cas où le modèle ne doit pas être utilisé. Comportements dégradés observés
pendant l'évaluation et non corrigés.

## Surveillance

| Signal | Seuil d'alerte | Destinataire | Action |
|---|---|---|---|
| Dérive des entrées | | | |
| Dérive des sorties | | | |
| Performance réelle | | | |
| Latence p95 | | | |

Délai attendu d'arrivée de la vérité terrain : <…>. Circuit de retour : <qui
corrige, où c'est stocké>.

## Retrait

Conditions qui déclenchent un réentraînement, et celles qui déclenchent un
retour arrière immédiat vers `<version précédente>`.
