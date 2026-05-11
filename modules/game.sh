#!/bin/bash
# ==============================================================
# Moduł: game.sh
# Odpowiada za logikę i pętlę główną gry
# Wymaga: hidden[], states[], row_count, total_cards z board.sh
#         print_board() z board.sh
#         level_names[], chosen_index z ui.sh / config.sh
# ==============================================================

compare () {
  local idx1=$1
  local idx2=$2
  [ "${hidden[$idx1]}" = "${hidden[$idx2]}" ]
}

run_game () {
  local inputs=(-1 -1)
  local visible=0
  local pairs=0
  local total_pairs=$(( total_cards / 2 ))

  echo "=== MEMORY ==="
  echo "Poziom: ${level_names[$chosen_index]} (plansza ${row_count}x${row_count})"
  echo "Karty są indeksowane od 0 do $((total_cards-1))"

  while true; do
    print_board
    echo "Podaj indeks karty (0-$((total_cards-1))) lub 'q' aby wyjść:"
    read OPCJA

    if [ "$OPCJA" = "q" ]; then
      echo "Do widzenia!"
      exit 0
    fi

    if ! [[ "$OPCJA" =~ ^-?[0-9]+$ ]]; then
      echo "to nie jest liczba"
      continue
    fi

    if [ "$OPCJA" -lt 0 ] || [ "$OPCJA" -gt $((total_cards-1)) ]; then
      echo "zła liczba (zakres 0-$((total_cards-1)))"
      continue
    fi

    if [ "${states[$OPCJA]}" = 1 ]; then
      echo "karta już widoczna"
      continue
    fi

    states[$OPCJA]=1
    inputs[$visible]=$OPCJA
    (( visible++ ))

    if [ $visible -eq 2 ]; then
      print_board
      sleep 1
      if compare "${inputs[0]}" "${inputs[1]}"; then
        echo "Para!"
        (( pairs++ ))
      else
        echo "Nie trafiono"
        (( states[${inputs[0]}] = 0 ))
        (( states[${inputs[1]}] = 0 ))
      fi

      inputs=(-1 -1)
      visible=0

      if [ $pairs -eq $total_pairs ]; then
        print_board
        echo "Wygrana! Znaleziono wszystkie $total_pairs par!"
        exit 0
      fi
    fi
  done
}
