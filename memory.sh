#!/bin/bash
# ==============================================================
# memory.sh — punkt wejścia gry Memory
#
# Użycie:
#   ./memory.sh [OPCJE] [ścieżka_do_levels.conf]
#
# Opcje:
#   -h, --help      Wyświetl pomoc i zakończ
#   -v, --version   Wyświetl informację o wersji i zakończ
#
# Struktura plików:
#   memory.sh         — punkt wejścia
#   levels.conf       — konfiguracja poziomów
#   scores.dat        — tabela wyników (tworzony automatycznie)
#   modules/
#     config.sh       — wczytywanie pliku konfiguracyjnego
#     scores.sh       — obliczanie i zapisywanie punktów
#     ui.sh           — okno wyboru poziomu
#     board.sh        — inicjalizacja i wyświetlanie planszy
#     game.sh         — logika i pętla główna gry
# ==============================================================

# Wersja gry
VERSION="1.0.0"

# Funkcja wyświetlająca pomoc
show_help() {
    cat << EOF
MEMORY - gra w dopasowywanie par

OPIS:
    Memory to klasyczna gra, w której gracz odkrywa karty i stara się
    znaleźć pasujące do siebie pary. Gra oferuje różne poziomy trudności
    oraz zapisuje najlepsze wyniki.

SKŁADNIA:
    $(basename "$0") [OPCJE] [PLIK_KONFIGURACYJNY]

OPCJE:
    -h, --help      Wyświetla tę pomoc i kończy działanie
    -v, --version   Wyświetla informację o wersji i kończy działanie

ARGUMENTY:
    PLIK_KONFIGURACYJNY
        Ścieżka do pliku konfiguracyjnego z poziomami gry.
        Jeśli nie podano, domyślnie używany jest plik 'levels.conf'
        w katalogu skryptu.

OPIS ROZGRYWKI:
    - Wybierz poziom trudności z listy
    - Odkrywaj karty za pomocą klawiszy:
      * Strzałki - poruszanie kursorem
      * Enter   - odkrycie karty
      * q       - wyjście z gry
    - Znajdź wszystkie pary, aby wygrać

SYSTEM PUNKTACJI:
    - Każda para: 100 punktów
    - Bonus za efektywność: (pary - błędy) * 20 punktów
    - Maksymalny bonus: pary * 50 punktów (gdy brak błędów)

KONFIGURACJA:
    Plik konfiguracyjny powinien mieć format:
    nazwa_poziomu|rozmiar|emoji1,emoji2,emoji3,...
    
    Przykład:
    Łatwy|2|🐶,🐱
    Średni|4|🐶,🐱,🐭,🐹,🐰,🦊,🐻,🐼

WYMAGANIA:
    - Bash 4.0 lub nowszy
    - Zenity (dla interfejsu graficznego)
    - Terminal z obsługą kolorów i ukrywaniem kursora

PLIKI:
    memory.sh           - główny skrypt
    levels.conf         - konfiguracja poziomów
    scores.dat          - tabela wyników (tworzony automatycznie)
    modules/            - katalog z modułami gry

PRZYKŁADY:
    $(basename "$0")
        Uruchom grę z domyślnym plikiem konfiguracyjnym

    $(basename "$0") moje_poziomy.conf
        Uruchom grę z własnym plikiem konfiguracyjnym

    $(basename "$0") -v
        Wyświetl wersję gry

AUTOR:
    Memory Game Script

ZOBACZ TAKŻE:
    man bash, zenity --help

EOF
}

# Funkcja wyświetlająca wersję
show_version() {
    cat << EOF
memory.sh v${VERSION}

Copyright (C) 2026 Memory Game
Licencja: GPL v3
To jest wolne oprogramowanie: możesz je zmieniać i rozpowszechniać.
Nie ma ŻADNEJ GWARANCJI, w granicach dozwolonych przez prawo.

Napisanego dla Bash wersji ${BASH_VERSION%%(*}
EOF
}

# Parsowanie argumentów za pomocą getopts
usage() {
    echo "Użycie: $(basename "$0") [-h|--help] [-v|--version] [plik_konfiguracyjny]"
    echo "Uruchom '$(basename "$0") --help' aby uzyskać więcej informacji."
}

# Główna część skryptu - parsowanie opcji
CONFIG_FILE_ARG=""

# Użyj getopts do przetworzenia opcji krótkich
while getopts ":hv-:" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        v)
            show_version
            exit 0
            ;;
        -)
            # Obsługa długich opcji
            case "${OPTARG}" in
                help)
                    show_help
                    exit 0
                    ;;
                version)
                    show_version
                    exit 0
                    ;;
                *)
                    echo "Nieznana opcja: --${OPTARG}" >&2
                    usage
                    exit 1
                    ;;
            esac
            ;;
        \?)
            echo "Nieznana opcja: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "Opcja -$OPTARG wymaga argumentu" >&2
            usage
            exit 1
            ;;
    esac
done

# Przesunięcie wskaźnika opcji
shift $((OPTIND-1))

# Pozostały argument to plik konfiguracyjny (opcjonalny)
if [ $# -gt 0 ]; then
    CONFIG_FILE_ARG="$1"
    if [ $# -gt 1 ]; then
        echo "Ostrzeżenie: zignorowano dodatkowe argumenty: ${@:2}" >&2
    fi
fi

# Zmienne główne
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE_ARG:-$SCRIPT_DIR/levels.conf}"
MODULES_DIR="$SCRIPT_DIR/modules"

# Sprawdź czy istnieje katalog modules
if [ ! -d "$MODULES_DIR" ]; then
    echo "Błąd: nie znaleziono katalogu modules: $MODULES_DIR" >&2
    exit 1
fi

# ---- Wczytaj moduły (kolejność ma znaczenie) ----
for module in config scores ui board game; do
    module_path="$MODULES_DIR/${module}.sh"
    if [ ! -f "$module_path" ]; then
        echo "Błąd: brakuje modułu: $module_path" >&2
        exit 1
    fi
    source "$module_path"
done

# Sprawdź wymagania
if ! command -v zenity &> /dev/null; then
    echo "Błąd: Zenity nie jest zainstalowane." >&2
    echo "Zainstaluj zenity: sudo apt-get install zenity (lub odpowiednie dla Twojej dystrybucji)" >&2
    exit 1
fi

# ---- Uruchom grę ----
load_config  "$CONFIG_FILE"
select_level
init_board   "$chosen_index"
run_game
