---
paths:
  - "**/db/**/*.py"
  - "**/models.py"
  - "**/database.py"
  - "**/repositories/**/*.py"
  - "**/migrations/**"
  - "alembic/**"
---

# Base de données — SQLAlchemy

<!-- Portée à ajuster à l'arborescence réelle du dépôt. Si l'ORM vit dans un
     répertoire `models/`, ajouter "**/models/**/*.py" dans la copie locale —
     mais jamais dans un projet qui a un src/ml/models/, où le mot désigne des
     architectures de réseau et où cette règle n'aurait aucun sens.

     Cette règle complète le tableau « Choix par défaut » de rules/python.md,
     elle ne le remplace pas : SQLAlchemy 2.0 asynchrone, Alembic, SQLite en
     local et en test, PostgreSQL en serveur. -->

## Style 2.0, pas 1.x

Beaucoup d'exemples encore en circulation utilisent l'API héritée. Elle
fonctionne, elle n'est pas la nôtre — et les deux styles mélangés dans un même
projet produisent des erreurs de typage incompréhensibles.

| Hérité (1.x) | Attendu (2.0) |
|---|---|
| `Base = declarative_base()` | `class Base(DeclarativeBase): ...` |
| `nom = Column(String, nullable=False)` | `nom: Mapped[str] = mapped_column()` |
| `session.query(Modele).filter(...)` | `select(Modele).where(...)` + `session.execute(...)` |
| `create_engine` / `Session` | `create_async_engine` / `async_sessionmaker` |

`Mapped[str]` implique `NOT NULL`, `Mapped[str | None]` implique `NULL` : la
nullabilité se lit dans l'annotation, elle n'est pas à répéter en argument.

## Session

- **Une session par unité de travail.** Jamais de session globale de module,
  jamais une session partagée entre deux requêtes HTTP : les objets restent
  attachés, l'état fuit d'une opération à l'autre et les erreurs sont
  irreproductibles.
- Ouverture par gestionnaire de contexte, qui ferme et libère la connexion même
  en cas d'exception :

  ```python
  async with async_session() as session:
      async with session.begin():
          session.add(logement)
  ```

  `session.begin()` valide en sortie de bloc et annule sur exception. Écrire un
  `rollback()` à la main n'est utile que hors de ce schéma.

- Anti-schéma courant : un `try` qui englobe le `with`, et un `except` qui
  appelle `session.rollback()` — la variable n'existe plus ou la session est
  déjà fermée. Le rattrapage se met **à l'intérieur** du bloc, ou nulle part.
- Sur FastAPI, la session est une dépendance (`Depends(get_session)`), une par
  requête. Elle n'est pas créée dans la fonction de route.
- En asynchrone, tout accès à un attribut peut déclencher une requête : le
  chargement paresseux hors session lève `MissingGreenlet`. Charger
  explicitement ce qui sera lu (`selectinload`) plutôt que de compter dessus.

## Modèles

- `__tablename__` en `snake_case` pluriel.
- Clé primaire `id` entière autoincrémentée par défaut. UUID seulement si les
  identifiants doivent être générés hors base ou ne rien révéler.
- Relations bidirectionnelles avec `back_populates=` des deux côtés — jamais
  `backref`, qui crée un attribut invisible à la lecture du modèle enfant.
- `cascade="all, delete-orphan"` côté parent quand l'enfant n'a pas d'existence
  autonome. Y réfléchir explicitement : c'est une suppression en chaîne.
- Contraintes en base, pas seulement dans le code Python : `unique=True`,
  `nullable`, clés étrangères, `CheckConstraint`. Une règle qui ne vit que dans
  l'application est contournée par le premier script d'import.
- Index sur toute colonne servant à filtrer ou à joindre régulièrement. Les clés
  étrangères ne sont **pas** indexées automatiquement par PostgreSQL.
- Horodatages `timestamptz` avec valeur par défaut serveur
  (`server_default=func.now()`), pas une valeur calculée en Python : c'est
  l'heure de la base qui fait foi.

## Requêtes

- Toujours passer par les paramètres liés. `text("… WHERE nom = :nom")` avec
  paramètres est acceptable ; une f-string dans une requête SQL ne l'est jamais,
  y compris pour un script interne.
- Les jointures explicites, les tables aliasées dès qu'il y en a plus d'une.
- `N+1` : une boucle Python qui accède à une relation fait une requête par
  itération. Charger en une fois (`selectinload`, `joinedload`) et vérifier en
  activant `echo=True` en développement quand le doute existe.
- L'agrégation et le filtrage se font en base, pas en Python après un `SELECT *`.

## Migrations

- Tout changement de modèle passe par une migration Alembic, y compris en
  développement. Pas de `Base.metadata.create_all()` ailleurs que dans les tests.
- La migration générée par `--autogenerate` est **relue et corrigée** avant
  commit : elle rate les renommages (qu'elle traduit en `DROP` + `ADD`, donc en
  perte de données), les changements de type et les contraintes nommées.
- Chaque migration a un `downgrade` qui fonctionne, ou un commentaire disant
  pourquoi le retour arrière est impossible.
- Migration de structure et migration de données dans des révisions distinctes :
  elles n'échouent pas pour les mêmes raisons et ne se rejouent pas pareil.
- SQLite ne sait pas modifier une colonne en place. Une migration validée sur
  SQLite peut échouer sur PostgreSQL, et l'inverse : la cible de production est
  celle qui compte.

## Tests

- SQLite en mémoire, base recréée par test, transaction annulée en fin de test.
- Ce qui touche à un type spécifique à PostgreSQL (`JSONB`, `ARRAY`, `tsvector`,
  `vector`) ne peut pas être testé sur SQLite : ces tests-là visent une vraie
  base PostgreSQL, sinon ils ne prouvent rien.

## Connexion

- URL en variable d'environnement, jamais en dur — cohérent avec la section
  Configuration de `rules/python.md`. Un mot de passe de base n'apparaît ni dans
  le code, ni dans un log, ni dans une trace d'erreur renvoyée à un client.
- Un seul moteur par processus, créé au démarrage : c'est lui qui porte le pool
  de connexions. Un moteur créé par appel épuise les connexions du serveur.
- `await engine.dispose()` à l'arrêt de l'application (événement d'arrêt FastAPI).
