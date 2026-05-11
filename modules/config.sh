#!/bin/bash
# ==============================================================
# Moduł: config.sh
# Odpowiada za wczytanie i walidację pliku konfiguracyjnego
# ==============================================================

level_names=()
level_sizes=()
level_emojis=()

load_config () {
  local config_file="$1"

  if [ ! -f "$config_file" ]; then
    echo "Błąd: nie znaleziono pliku konfiguracyjnego: $config_file" >&2
    exit 1
  fi

  while IFS='|' read -r name size emojis || [[ -n "$name" ]]; do
    [[ "$name" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${name// }" ]] && continue

    level_names+=("$name")
    level_sizes+=("$size")
    level_emojis+=("$emojis")
  done < "$config_file"

  if [ ${#level_names[@]} -eq 0 ]; then
    echo "Błąd: plik konfiguracyjny nie zawiera żadnych poziomów." >&2
    exit 1
  fi
}
