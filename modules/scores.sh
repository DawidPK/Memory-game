#!/bin/bash
# ==============================================================
# Moduł: scores.sh
# Odpowiada za obliczanie, zapisywanie i wyświetlanie punktów
# Format pliku scores: LEVEL_NAME|NICK|SCORE
# ==============================================================

SCORES_FILE="${SCORES_FILE:-${SCRIPT_DIR}/scores.dat}"

# Oblicz wynik końcowy
# Argumenty: $1=pairs $2=attempts (łączna liczba odkryć kart / 2)
# Para = 100 pkt; bonus za efektywność = max(0, (pairs - błędy) * 20)
calculate_score () {
  local pairs="$1"
  local attempts="$2"   # liczba tur (każda tura = 2 karty)
  local mistakes=$(( attempts - pairs ))
  local base=$(( pairs * 100 ))
  local bonus=$(( mistakes == 0 ? pairs * 50 : (pairs - mistakes) * 20 ))
  [ $bonus -lt 0 ] && bonus=0
  echo $(( base + bonus ))
}

# Zapisz wynik do pliku
# Argumenty: $1=level_name $2=nick $3=score
save_score () {
  local level="$1"
  local nick="$2"
  local score="$3"
  echo "${level}|${nick}|${score}" >> "$SCORES_FILE"
}

# Zapytaj o nick i zapisz wynik
ask_nick_and_save () {
  local level="$1"
  local score="$2"

  local nick
  nick=$(zenity --entry \
    --title="Koniec gry!" \
    --text="Twój wynik: $score pkt\n\nWpisz swój nick:" \
    --entry-text="Gracz" \
    --width=320 2>/dev/null)

  # Anulowanie
  [ $? -ne 0 ] && return

  # Usuń znaki pipe
  nick="${nick//|/}"
  [ -z "$nick" ] && nick="Anonim"

  save_score "$level" "$nick" "$score"

  zenity --info \
    --title="Zapisano!" \
    --text="Nick: $nick\nPunkty: $score\nZapisano do tabeli wyników!" \
    --width=280 2>/dev/null
}
