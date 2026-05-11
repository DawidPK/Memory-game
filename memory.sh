#!/bin/bash
# ==============================================================
# memory.sh - główny plik do Memory
#
# Użycie:
#   ./memory.sh [ścieżka_do_levels.conf]
#
# Struktura plików:
#   memory.sh - wejście
#   levels.conf - plik konfiguracyjny
#   modules/
#     config.sh -  wczytywanie pliku konfiguracyjnego
#     ui.sh - interfejs użytkownika
#     board.sh - inicjalizacja i wyświetlanie planszy
#     game.sh - logika i pętla główna gry
# ==============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${1:-$SCRIPT_DIR/levels.conf}"
MODULES_DIR="$SCRIPT_DIR/modules"

# ---- Wczytaj moduły ----
for module in config ui board game; do
  module_path="$MODULES_DIR/${module}.sh"
  if [ ! -f "$module_path" ]; then
    echo "Błąd: brakuje modułu: $module_path" >&2
    exit 1
  fi
  source "$module_path"
done

# ---- Uruchom grę ----
load_config  "$CONFIG_FILE"
select_level
init_board   "$chosen_index"
run_game
