#!/usr/bin/env bash
# Banc de test du hook pre-commit.
#
#   bash tests/banc-hook.sh
#
# Chaque cas monte un dépôt jetable, y installe le hook, tente un commit et
# compare le verdict obtenu au verdict attendu. À relancer après toute
# modification de hooks/pre-commit.

set -u
HOOK="${1:-$(dirname "$0")/../hooks/pre-commit}"
HOOK=$(readlink -f "$HOOK")
BASE=$(mktemp -d)
ok=0; ko=0

# attendu : refus | accepte
cas() {
  local titre="$1" attendu="$2" conf="$3" branche="$4"; shift 4
  local depot="$BASE/$(printf '%s' "$titre" | tr -c 'A-Za-z0-9' '_')"
  mkdir -p "$depot/.githooks"
  git -C "$depot" init -q -b main
  git -C "$depot" config user.name Test
  git -C "$depot" config user.email test@test
  cp "$HOOK" "$depot/.githooks/pre-commit"
  chmod +x "$depot/.githooks/pre-commit"
  git -C "$depot" config core.hooksPath .githooks
  [ -n "$conf" ] && printf '%s\n' "$conf" > "$depot/.githooks/standards.conf"

  # commit de base, hors hook, pour que HEAD existe
  : > "$depot/.socle"
  git -C "$depot" add -A
  git -C "$depot" commit -qm socle --no-verify
  [ "$branche" != "main" ] && git -C "$depot" checkout -qb "$branche"

  ( cd "$depot" && "$@" ) >/dev/null 2>&1

  local sortie verdict
  sortie=$(cd "$depot" && git commit -m "cas de test" 2>&1)
  if [ $? -eq 0 ]; then verdict=accepte; else verdict=refus; fi

  if [ "$verdict" = "$attendu" ]; then
    printf '  \033[32mOK\033[0m   %-52s (%s)\n' "$titre" "$verdict"
    ok=$((ok + 1))
  else
    printf '  \033[31mECHEC\033[0m %-52s attendu %s, obtenu %s\n' "$titre" "$attendu" "$verdict"
    printf '%s\n' "$sortie" | sed 's/^/         | /'
    ko=$((ko + 1))
  fi
}

printf '\n== Branche protégée ==\n'
cas "commit direct sur main, sans conf" refus "" main \
  bash -c ': > a.txt; git add a.txt'
cas "commit sur feature/x, sans conf" accepte "" feature/x \
  bash -c ': > a.txt; git add a.txt'
cas "main autorisée si BRANCHES_PROTEGEES vide" accepte 'BRANCHES_PROTEGEES=""' main \
  bash -c ': > a.txt; git add a.txt'

printf '\n== Motifs interdits ==\n'
cas "essai.xlsx (le test qui avait échoué)" refus 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c ': > essai.xlsx; git add essai.xlsx'
cas "xlsx dans un sous-dossier" refus 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c 'mkdir -p d; : > d/e.xlsx; git add d/e.xlsx'
cas "sources/* interdit" refus 'MOTIFS_INTERDITS="sources/*"' feature/x \
  bash -c 'mkdir -p sources; : > sources/a.csv; git add sources/a.csv'
cas ".env interdit" refus 'MOTIFS_INTERDITS=".env"' feature/x \
  bash -c ': > .env; git add .env'
cas "fichier hors motif" accepte 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c ': > a.txt; git add a.txt'
cas "nom avec espaces et accents" refus 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c ': > "relevé final.xlsx"; git add "relevé final.xlsx"'
cas "suppression d un fichier interdit déjà suivi" accepte 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c ': > v.xlsx; git add v.xlsx; git commit -qm v --no-verify; git rm -q v.xlsx'
cas "xlsx dans un chemin exclu (jeu d essai)" accepte 'MOTIFS_INTERDITS="*.xlsx"
CHEMINS_EXCLUS="exemples/*"' feature/x \
  bash -c 'mkdir -p exemples; : > exemples/e.xlsx; git add exemples/e.xlsx'
cas "xlsx exclu dans un sous-dossier profond (motif */exemple/*)" accepte 'MOTIFS_INTERDITS="*.xlsx"
CHEMINS_EXCLUS="*/exemple/*"' feature/x \
  bash -c 'mkdir -p "src appli/exemple"; : > "src appli/exemple/e.xlsx"; git add "src appli/exemple/e.xlsx"'
cas "xlsx hors du chemin exclu reste refusé" refus 'MOTIFS_INTERDITS="*.xlsx"
CHEMINS_EXCLUS="exemples/*"' feature/x \
  bash -c ': > e.xlsx; git add e.xlsx'

printf '\n== Python : print ==\n'
cas "print() interdit" refus 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "print(1)\n" > a.py; git add a.py'
cas "print() toléré si INTERDIRE_PRINT=0" accepte 'INTERDIRE_PRINT=0' feature/x \
  bash -c 'printf "print(1)\n" > a.py; git add a.py'
cas "marqueur standards: print autorise" accepte 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "print(1)  # standards: print autorise\n" > a.py; git add a.py'
cas "pprint() n est pas print()" accepte 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "from pprint import pprint\npprint(1)\n" > a.py; git add a.py'
cas "obj.print() n est pas print()" accepte 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "sortie.print(1)\n" > a.py; git add a.py'
cas "print dans un .txt ignoré" accepte 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "print(1)\n" > a.txt; git add a.txt'
cas "print dans un chemin exclu" accepte 'INTERDIRE_PRINT=1
CHEMINS_EXCLUS="Reference/*"' feature/x \
  bash -c 'mkdir -p Reference; printf "print(1)\n" > Reference/a.py; git add Reference/a.py'

printf '\n== Python : logging et logger ==\n'
cas "import logging interdit" refus 'INTERDIRE_LOGGING=1' feature/x \
  bash -c 'printf "import logging\n" > a.py; git add a.py'
cas "from logging import getLogger interdit" refus 'INTERDIRE_LOGGING=1' feature/x \
  bash -c 'printf "from logging import getLogger\n" > a.py; git add a.py'
cas "loguru accepté" accepte 'INTERDIRE_LOGGING=1' feature/x \
  bash -c 'printf "from loguru import logger\n" > a.py; git add a.py'
cas "logger.add hors du module logger" refus 'MODULE_LOGGER="logger.py"' feature/x \
  bash -c 'printf "logger.add(1)\n" > a.py; git add a.py'
cas "logger.add dans logger.py" accepte 'MODULE_LOGGER="logger.py"' feature/x \
  bash -c 'printf "logger.add(1)\n" > logger.py; git add logger.py'

printf '\n== Index et disque ==\n'
cas "index propre, disque sale : accepté" accepte 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "x = 1\n" > a.py; git add a.py; printf "print(1)\n" >> a.py'
cas "index sale, disque propre : refusé" refus 'INTERDIRE_PRINT=1' feature/x \
  bash -c 'printf "print(1)\n" > a.py; git add a.py; printf "x = 1\n" > a.py'

printf '\n== Modes et cas limites ==\n'
cas "MODE=avertir laisse passer" accepte 'MODE=avertir
MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c ': > e.xlsx; git add e.xlsx'
cas "conf absente : seule la branche compte" accepte "" feature/x \
  bash -c ': > e.xlsx; printf "print(1)\nimport logging\n" > a.py; git add -A'
cas "plusieurs violations d un coup" refus 'MOTIFS_INTERDITS="*.xlsx"
INTERDIRE_PRINT=1
INTERDIRE_LOGGING=1' feature/x \
  bash -c ': > e.xlsx; printf "print(1)\nimport logging\n" > a.py; git add -A'
cas "conf en CRLF (fichier venu de Windows)" refus 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c 'unix2dos -q .githooks/standards.conf 2>/dev/null || sed -i "s/$/\r/" .githooks/standards.conf; : > e.xlsx; git add e.xlsx'

printf '\n== Motifs et développement du shell ==\n'
cas "xlsx en sous-dossier, leurre .xlsx à la racine" refus 'MOTIFS_INTERDITS="*.xlsx"' feature/x \
  bash -c ': > leurre.xlsx; mkdir -p d; : > d/reel.xlsx; git add d/reel.xlsx'
cas "motif *.env avec un .env non indexé à côté" refus 'MOTIFS_INTERDITS="*.env"' feature/x \
  bash -c ': > prod.env; mkdir -p conf; : > conf/secret.env; git add conf/secret.env'
cas "sources/* alors que sources/ est vide sur le disque" refus 'MOTIFS_INTERDITS="sources/*"' feature/x \
  bash -c 'mkdir -p sources; : > sources/a.csv; git add sources/a.csv; rm sources/a.csv'
cas "chemin exclu absent du disque mais présent dans l index" accepte 'INTERDIRE_PRINT=1
CHEMINS_EXCLUS="Reference/*"' feature/x \
  bash -c 'mkdir -p Reference; printf "print(1)\n" > Reference/a.py; git add Reference/a.py; rm Reference/a.py'

printf '\n== Index vide ==\n'
depot_vide="$BASE/index_vide"
mkdir -p "$depot_vide/.githooks"
git -C "$depot_vide" init -q -b main
git -C "$depot_vide" config user.name T; git -C "$depot_vide" config user.email t@t
cp "$HOOK" "$depot_vide/.githooks/pre-commit"; chmod +x "$depot_vide/.githooks/pre-commit"
git -C "$depot_vide" config core.hooksPath .githooks
printf 'INTERDIRE_PRINT=1\nRUFF=1\nMOTIFS_INTERDITS="*.xlsx"\n' > "$depot_vide/.githooks/standards.conf"
: > "$depot_vide/.socle"; git -C "$depot_vide" add -A
git -C "$depot_vide" commit -qm socle --no-verify
git -C "$depot_vide" checkout -qb feature/x
if ( cd "$depot_vide" && git commit --allow-empty -m vide ) >/dev/null 2>&1; then
  printf '  \033[32mOK\033[0m   %-52s (accepte)\n' "commit vide, aucun fichier indexé"; ok=$((ok + 1))
else
  printf '  \033[31mECHEC\033[0m %-52s le hook plante sur un index vide\n' "commit vide, aucun fichier indexé"
  ( cd "$depot_vide" && git commit --allow-empty -m vide 2>&1 ) | sed 's/^/         | /'
  ko=$((ko + 1))
fi

printf '\n%d OK, %d échec(s)\n\n' "$ok" "$ko"
printf 'dépôts de test : %s\n' "$BASE"
[ "$ko" -eq 0 ]
