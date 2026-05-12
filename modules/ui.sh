#!/bin/bash
# ==============================================================
# Moduł: ui.sh
# Odpowiada za interfejs użytkownika (zenity)
# Wymaga: tablic level_names[] i level_sizes[] z config.sh
#         show_highscores() z scores.sh
# ==============================================================

chosen_index=-1

select_level () {
  while true; do
    local zenity_list_args=()

    for i in "${!level_names[@]}"; do
      if [ $i -eq 0 ]; then
        zenity_list_args+=("TRUE")
      else
        zenity_list_args+=("FALSE")
      fi
      zenity_list_args+=("$((i+1))")
      zenity_list_args+=("${level_names[$i]}")
    done

    local chosen
    chosen=$(zenity --list \
      --radiolist \
      --title="Memory – wybór poziomu" \
      --text="Wybierz poziom trudności:" \
      --column="Wybierz" \
      --column="#" \
      --column="Poziom" \
      --width=380 \
      --height=$(( 120 + ${#level_names[@]} * 100 )) \
      --extra-button="High Scores" \
      "${zenity_list_args[@]}" 2>/dev/null)

    local exit_code=$?

    # Kliknięto "High Scores"
    if [ "$chosen" = "High Scores" ]; then
      _show_all_highscores
      continue
    fi

    if [ $exit_code -ne 0 ] || [ -z "$chosen" ]; then
      echo "Anulowano wybór poziomu."
      exit 0
    fi

    chosen_index=$(( chosen - 1 ))
    break
  done
}

# Wyświetl high scores wszystkich poziomów w jednym oknie zenity
_show_all_highscores () {
  if [ ! -f "$SCORES_FILE" ]; then
    zenity --info \
      --title="High Scores" \
      --text="Brak zapisanych wyników." \
      --width=300 2>/dev/null
    return
  fi

  local rows=()

  for level in "${level_names[@]}"; do
    local rank=1
    while IFS='|' read -r lvl nick score; do
      rows+=("$level" "$rank" "$nick" "$score")
      (( rank++ ))
    done < <(grep "^${level}|" "$SCORES_FILE" \
               | sort -t'|' -k3 -rn \
               | head -3)
  done

  if [ ${#rows[@]} -eq 0 ]; then
    zenity --info \
      --title="High Scores" \
      --text="Brak zapisanych wyników." \
      --width=300 2>/dev/null
    return
  fi

  zenity --list \
    --title="High Scores" \
    --text="Najlepsze wyniki" \
    --column="Poziom" \
    --column="Miejsce" \
    --column="Nick" \
    --column="Punkty" \
    --width=520 \
    --height=$(( 140 + ${#rows[@]} * 25 )) \
    "${rows[@]}" 2>/dev/null
}
