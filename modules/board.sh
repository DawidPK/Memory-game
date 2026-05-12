#!/bin/bash
# ==============================================================
# Moduł: board.sh
# Odpowiada za inicjalizację planszy i jej wyświetlanie
# Wymaga: chosen_index z ui.sh, tablic z config.sh
# Eksportuje: hidden[], states[], row_count, total_cards
# ==============================================================

hidden=()
states=()
row_count=0
total_cards=0
unknown='##'

# Szerokość jednej komórki (znaki + spacje)
CELL_W=4

init_board () {
  local index="$1"

  row_count="${level_sizes[$index]}"
  local emojis_raw="${level_emojis[$index]}"
  total_cards=$(( row_count * row_count ))

  IFS=',' read -ra unique_emojis <<< "$emojis_raw"
  local required_unique=$(( total_cards / 2 ))
  local actual_unique=${#unique_emojis[@]}

  if [ "$actual_unique" -lt "$required_unique" ]; then
    zenity --error \
      --title="Błąd konfiguracji" \
      --text="Poziom '${level_names[$index]}' wymaga $required_unique unikalnych emoji,\na w pliku podano tylko $actual_unique." 2>/dev/null
    echo "Błąd: za mało emoji w konfiguracji dla tego poziomu." >&2
    exit 1
  fi

  local card_pool=()
  for ((i=0; i<required_unique; i++)); do
    card_pool+=("${unique_emojis[$i]}")
    card_pool+=("${unique_emojis[$i]}")
  done

  # Fisher-Yates shuffle
  for ((i=total_cards-1; i>0; i--)); do
    local j=$(( RANDOM % (i+1) ))
    local tmp="${card_pool[$i]}"
    card_pool[$i]="${card_pool[$j]}"
    card_pool[$j]="$tmp"
  done

  hidden=("${card_pool[@]}")
  states=()
  for ((i=0; i<total_cards; i++)); do
    states+=(0)
  done
}

# print_board CUR_COL CUR_ROW
# Rysuje planszę; komórka [CUR_COL, CUR_ROW] zostaje podświetlona
print_board () {
  local cur_col="${1:-0}"
  local cur_row="${2:-0}"

  for ((j=0; j<row_count; j++)); do 
    for ((i=0; i<row_count; i++)); do
      local idx=$((i + j * row_count))
      local cell
      if [ "${states[$idx]}" = 1 ]; then
        cell="${hidden[$idx]}"
      else
        cell="$unknown"
      fi

      if [ "$i" -eq "$cur_col" ] && [ "$j" -eq "$cur_row" ]; then
        # Podświetlenie kursora: odwrócone kolory
        tput rev
        printf '[%s]' "$cell"
        tput sgr0
      else
        printf ' %s ' "$cell"
      fi
    done
    printf "\n"
  done
  printf "\n"
}
