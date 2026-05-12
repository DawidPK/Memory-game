#!/bin/bash
# ==============================================================
# Moduł: game.sh
# Odpowiada za logikę i pętlę główną gry
# Sterowanie: strzałki = ruch kursora, Enter = odkryj kartę, q = wyjście
# Wymaga: hidden[], states[], row_count, total_cards z board.sh
#         print_board() z board.sh
#         level_names[], chosen_index z ui.sh / config.sh
# ==============================================================

compare () {
  [ "${hidden[$1]}" = "${hidden[$2]}" ]
}

# Odczytuje jeden klawisz (w tym sekwencje ESC strzałek)
read_key () {
  local key
  # Czytaj 1 znak
  IFS= read -r -s -n1 key

  # Jeśli ESC — próbuj doczytać sekwencję strzałki
  if [ "$key" = $'\x1b' ]; then
    local seq1 seq2
    IFS= read -r -s -n1 -t 0.1 seq1
    IFS= read -r -s -n1 -t 0.1 seq2
    case "${seq1}${seq2}" in
      '[A') key='UP'    ;;
      '[B') key='DOWN'  ;;
      '[C') key='RIGHT' ;;
      '[D') key='LEFT'  ;;
      *)    key='ESC'   ;;
    esac
  fi

  printf '%s' "$key"
}

# Przerysuj całą planszę w miejscu (bez scrollowania)
redraw () {
  local cur_col="$1"
  local cur_row="$2"
  local msg="$3"

  tput cup "$BOARD_TOP" 0
  print_board "$cur_col" "$cur_row"
  tput el   # wyczyść resztę linii statusu
  printf "%s" "$msg"
  tput el
}

run_game () {
  local inputs=(-1 -1)
  local visible=0
  local pairs=0
  local total_pairs=$(( total_cards / 2 ))

  local cur_col=0
  local cur_row=0

  # Ustaw terminal
  tput civis          # ukryj kursor
  tput clear

  # Nagłówek (stała pozycja 0)
  tput cup 0 0
  printf "=== MEMORY ===  Poziom: %s (%dx%d)  [strzałki=ruch  Enter=odkryj  q=wyjście]\n" \
    "${level_names[$chosen_index]}" "$row_count" "$row_count"

  # Plansza zaczyna się od linii 2
  BOARD_TOP=2

  # Pętla
  local status_row=$(( BOARD_TOP + row_count + 3 ))
  local msg="Wybierz kartę:"

  redraw "$cur_col" "$cur_row" "$msg"

  # Przywróć kursor i tryb terminala przy wyjściu
  trap 'tput cnorm; tput rmcup 2>/dev/null; tput sgr0' EXIT

  while true; do
    local key
    key=$(read_key)

    case "$key" in
      'UP')
        (( cur_row = (cur_row - 1 + row_count) % row_count ))
        ;;
      'DOWN')
        (( cur_row = (cur_row + 1) % row_count ))
        ;;
      'LEFT')
        (( cur_col = (cur_col - 1 + row_count) % row_count ))
        ;;
      'RIGHT')
        (( cur_col = (cur_col + 1) % row_count ))
        ;;
      '')   # Enter (pusty string po -n1)
        local idx=$(( cur_col + cur_row * row_count ))

        if [ "${states[$idx]}" = 1 ]; then
          msg="⚠ Karta już odkryta — wybierz inną."
          redraw "$cur_col" "$cur_row" "$msg"
          continue
        fi

        states[$idx]=1
        inputs[$visible]=$idx
        (( visible++ ))
        redraw "$cur_col" "$cur_row" ""

        if [ $visible -eq 2 ]; then
          sleep 1

          if compare "${inputs[0]}" "${inputs[1]}"; then
            msg="Para! Świetnie!"
            (( pairs++ ))
          else
            msg="Nie trafiono — karty zakryte."
            (( states[${inputs[0]}] = 0 ))
            (( states[${inputs[1]}] = 0 ))
          fi

          inputs=(-1 -1)
          visible=0

          if [ $pairs -eq $total_pairs ]; then
            redraw "$cur_col" "$cur_row" ""
            tput cup $(( BOARD_TOP + row_count + 2 )) 0
            printf "Wygrana!\n" "$total_pairs"
            tput cnorm
            read -r -s -n1   # czekaj na klawisz przed wyjściem
            clear
            exit 0
          fi
        fi
        ;;
      'q'|'Q')
        tput cnorm
        tput cup $(( BOARD_TOP + row_count + 2 )) 0
        clear
        printf "Do widzenia!\n"
        exit 0
        ;;
    esac

    redraw "$cur_col" "$cur_row" "$msg"
    msg="Wybierz kartę:"
  done
}
