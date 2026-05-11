#!/bin/bash
# ==============================================================
# Moduł: ui.sh
# Odpowiada za interfejs użytkownika (zenity)
# Wymaga: tablic level_names[] i level_sizes[] z config.sh
# ==============================================================

chosen_index=-1

select_level () {
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
    --width=350 \
    --height=$(( 120 + ${#level_names[@]} * 35 )) \
    "${zenity_list_args[@]}" 2>/dev/null)

  if [ $? -ne 0 ] || [ -z "$chosen" ]; then
    echo "Anulowano wybór poziomu."
    exit 0
  fi

  chosen_index=$(( chosen - 1 ))
}
