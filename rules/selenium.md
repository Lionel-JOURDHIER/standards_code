---
paths:
  - "**/scraping/**/*.py"
  - "**/scraper*.py"
  - "**/*_scraper.py"
  - "**/selenium/**/*.py"
---

# Automatisation de navigateur — Selenium

<!-- Source : mini-cours Selenium (setup, locators, WebDriverWait, deux
     démos books.toscrape.com / quotes.toscrape.com) et le CLAUDE.md racine
     du dossier de formation § Applications — Selenium (une phrase, reprise
     et développée ici). Ce fichier traite le pilotage du navigateur ; une
     fois la donnée extraite, sa manipulation (DataFrame, nettoyage) relève
     de `rules/donnees.md`. -->

## Quand Selenium, quand BeautifulSoup

Selenium pilote un vrai navigateur (JavaScript exécuté, cookies, sessions) ;
BeautifulSoup ne fait que parser du HTML déjà reçu. Selenium est plus lent et
plus fragile qu'un simple parseur — à réserver au cas qui le justifie
vraiment : **HTML statique → BeautifulSoup, site dynamique (contenu injecté
en JavaScript, formulaire, connexion) → Selenium.** Ne pas ouvrir un
navigateur complet pour une page qui n'en a pas besoin.

## Driver

- `webdriver_manager` (`ChromeDriverManager().install()`, passé à
  `Service(...)`) plutôt qu'un binaire `chromedriver` téléchargé et versionné
  à la main : la version du driver reste alignée sur celle du navigateur
  installé, sans fichier binaire à committer ni à mettre à jour soi-même.
- **`driver.quit()` toujours en `finally`** : une exception avant
  `driver.quit()` laisse un processus navigateur ouvert, invisible, qui
  s'accumule sur la machine ou le runner CI à chaque exécution en échec.

## Localiser un élément

- `By.CSS_SELECTOR` par défaut : lisible, robuste au remaniement du HTML,
  et rapide. `By.ID` quand un identifiant unique existe. `By.XPATH` en
  dernier recours seulement (navigation dans le DOM que le CSS ne peut pas
  exprimer) — plus verbeux et plus fragile au moindre changement de
  structure.

## Attendre un contenu dynamique

**Jamais `time.sleep()`** pour attendre qu'un élément apparaisse : une pause
fixe est soit trop courte (l'élément n'est pas encore là, l'action échoue),
soit trop longue (temps perdu à chaque exécution, multiplié par le nombre de
pages). `WebDriverWait` + `expected_conditions` attend l'état réel plutôt
qu'une durée devinée :

```python
WebDriverWait(driver, 10).until(
    EC.visibility_of_element_located((By.CSS_SELECTOR, ".quote"))
)
```

Sans ce wait, un élément injecté par JavaScript après le chargement initial
est lu vide ou absent — l'échec est silencieux (aucune exception, juste une
liste vide), pas une erreur qui remonte clairement.

## Éthique et cadre légal

- Lire `robots.txt` et les CGU du site avant de scraper ; privilégier une API
  officielle quand elle existe plutôt que de simuler un navigateur.
- Espacer les requêtes plutôt qu'enchaîner en boucle serrée : la charge
  générée sur un serveur tiers n'est pas gratuite pour lui.
- RGPD dès qu'une donnée personnelle est collectée. Un usage commercial des
  données extraites impose de vérifier les droits au-delà du simple respect
  technique de `robots.txt`.
- Contourner une protection anti-bot n'est pas une astuce technique parmi
  d'autres : c'est ce que `robots.txt`/les CGU interdisent explicitement.
