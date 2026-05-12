#!/bin/bash
# ==============================================================
# Moduł: game.sh
# Odpowiada za logikę i pętlę główną gry
# Sterowanie: strzałki = ruch kursora, Enter = odkryj kartę, q = wyjście
# Wymaga: hidden[], states[], row_count, total_cards z board.sh
#         print_board() z board.sh
#         level_names[], chosen_index z ui.sh / config.sh
#         calculate_score(), ask_nick_and_save() z scores.sh
# ==============================================================

compare () {
  [ "${hidden[$1]}" = "${hidden[$2]}" ]
}

# Odczytuje jeden klawisz
read_key () {
  local key
  IFS= read -r -s -n1 key

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

# Przerysuj całą planszę w miejscu
redraw () {
  local cur_col="$1"
  local cur_row="$2"
  local msg="$3"

  tput cup "$BOARD_TOP" 0
  print_board "$cur_col" "$cur_row"
  tput el
  printf '%s' "$msg"
  tput el
}

run_game () {
  local inputs=(-1 -1)
  local visible=0
  local pairs=0
  local attempts=0      
  local total_pairs=$(( total_cards / 2 ))

  local cur_col=0
  local cur_row=0

  tput civis
  tput clear

  tput cup 0 0
  printf "=== MEMORY ===  Poziom: %s (%dx%d)  [strzałki=ruch  Enter=odkryj  q=wyjście]\n" \
    "${level_names[$chosen_index]}" "$row_count" "$row_count"

  BOARD_TOP=2

  local msg="Wybierz kartę:"
  redraw "$cur_col" "$cur_row" "$msg"

  trap 'tput cnorm; tput sgr0' EXIT

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
      '')   # Enter
        local idx=$(( cur_col + cur_row * row_count ))

        if [ "${states[$idx]}" = 1 ]; then
          msg="Karta już odkryta"
          redraw "$cur_col" "$cur_row" "$msg"
          continue
        fi

        states[$idx]=1
        inputs[$visible]=$idx
        (( visible++ ))
        redraw "$cur_col" "$cur_row" "..."

        if [ $visible -eq 2 ]; then
          (( attempts++ ))
          sleep 1

          if compare "${inputs[0]}" "${inputs[1]}"; then
            (( pairs++ ))
            msg="Para! [${pairs}/${total_pairs}]"
          else
            msg="Nie trafiono."
            (( states[${inputs[0]}] = 0 ))
            (( states[${inputs[1]}] = 0 ))
          fi

          inputs=(-1 -1)
          visible=0

          if [ $pairs -eq $total_pairs ]; then
            redraw "$cur_col" "$cur_row" ""
            tput cup $(( BOARD_TOP + row_count + 2 )) 0
            tput cnorm

            # Oblicz i zapisz wynik
            local score
            score=$(calculate_score "$pairs" "$attempts")
            printf "Wygrana!  Pary: %d  Próby: %d  Wynik: %d pkt\n" \
              "$pairs" "$attempts" "$score"

            sleep 1
            # Zapytaj o nick i zapisz (zenity)
            ask_nick_and_save "${level_names[$chosen_index]}" "$score"
            clear
            exit 0
          fi
        fi
        ;;
      'q'|'Q')
        tput cnorm
        clear
        printf "Do widzenia!\n"
        exit 0
        ;;
    esac

    redraw "$cur_col" "$cur_row" "$msg"
    msg="Wybierz kartę:"
  done
}
