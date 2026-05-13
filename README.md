# Memory Game - Gra w dopasowywanie par

## Opis

Memory to klasyczna gra w dopasowywanie par, napisana w Bash. Gracz odkrywa karty i stara się znaleźć pasujące do siebie pary. Gra oferuje różne poziomy trudności, system punktacji oraz zapisuje najlepsze wyniki.

## Wymagania

- Bash 4.0 lub nowszy
- Zenity (dla interfejsu graficznego)
- Terminal z obsługą kolorów i ukrywaniem kursora

### Instalacja Zenity

**Debian/Ubuntu:**
sudo apt-get install zenity

**Fedora/RHEL:**
sudo dnf install zenity

**Arch Linux:**
sudo pacman -S zenity

**openSUSE:**
sudo zypper install zenity

## Instalacja

1. Pobierz wszystkie pliki gry:
git clone https://github.com/DawidPK/Memory-game.git
cd memory-game

2. Nadaj uprawnienia wykonywalne:
chmod +x memory.sh

3. Uruchom grę:
./memory.sh

## Struktura plików

memory-game/  
├── memory.sh           Główny skrypt  
├── levels.conf         Konfiguracja poziomów  
├── scores.dat          Tabela wyników (tworzony automatycznie)  
└── modules/            Katalog z modułami  
&emsp; ├── config.sh       Wczytywanie konfiguracji  
&emsp; ├── scores.sh       System punktacji  
&emsp; ├── ui.sh           Interfejs użytkownika  
&emsp; ├── board.sh        Zarządzanie planszą  
&emsp; └── game.sh         Logika gry  

## Użycie

Podstawowe użycie:
./memory.sh

Z własnym plikiem konfiguracyjnym:
./memory.sh moje_poziomy.conf

Wyświetlenie pomocy:
./memory.sh -h
lub
./memory.sh --help

Wyświetlenie wersji:
./memory.sh -v
lub
./memory.sh --version

## Opcje

-h, --help      Wyświetla pomoc i kończy działanie
-v, --version   Wyświetla wersję i kończy działanie

## Format pliku konfiguracyjnego (levels.conf)

Plik konfiguracyjny zawiera definicje poziomów gry w formacie:

nazwa_poziomu|rozmiar|emoji1,emoji2,emoji3,...

Przykład:

Łatwy 2x2|2|😈,👽
Średni 4x4|4|🐶,🐱,🐭,🐹,🦊,🐻,🐼,🐨
Trudny 6x6|6|🍎,🍊,🍋,🍇,🍓,🍒,🥭,🍍,🥝,🍑,🍈,🫐,🥥,🍌,🍉,🍏,🍐,🍑

- nazwa_poziomu - dowolny tekst (nie może zawierać znaku |)
- rozmiar - liczba całkowita parzysta (2, 4, 6...), określa rozmiar planszy N×N
- emoji - lista emoji oddzielonych przecinkami (musi być co najmniej (rozmiar²/2) unikalnych emoji)

## Rozgrywka

Sterowanie w grze:
- Strzałki - poruszanie kursorem po planszy
- Enter - odkrycie karty
- q - wyjście z gry

Cel gry:
Znajdź wszystkie pary pasujących do siebie kart. Gra kończy się, gdy wszystkie pary zostaną odkryte.

## System punktacji

Wynik obliczany jest według wzoru:

Wynik = (pary × 100) + bonus

Gdzie bonus to:
- Jeśli brak błędów: pary × 50
- W przeciwnym razie: max(0, (pary - błędy) × 20)

Błędy = liczba prób - liczba par

Przykłady punktacji:

Pary: 8, Próby: 8, Błędy: 0, Punkty: 1200 (800 + 400)
Pary: 8, Próby: 10, Błędy: 2, Punkty: 920 (800 + 120)
Pary: 8, Próby: 20, Błędy: 12, Punkty: 800 (800 + 0)

## Tabela wyników

Wyniki zapisywane są w pliku scores.dat w formacie:
nazwa_poziomu|nick|wynik

Dla każdego poziomu przechowywane jest top 3 najlepszych wyników.

## Najczęstsze problemy

Problem: Zenity nie jest zainstalowane
Rozwiązanie: Zainstaluj zenity (patrz sekcja "Instalacja Zenity")

Problem: Brak uprawnień do wykonania skryptu
Rozwiązanie: chmod +x memory.sh

Problem: Plik konfiguracyjny nie istnieje
Rozwiązanie: Utwórz levels.conf lub podaj ścieżkę do istniejącego pliku

Problem: Za mało emoji w konfiguracji
Rozwiązanie: Dodaj więcej unikalnych emoji do pliku konfiguracyjnego

## Dostosowywanie

Dodawanie własnych poziomów:
1. Otwórz plik levels.conf
2. Dodaj nową linię w formacie: Nazwa|rozmiar|emoji1,emoji2,...
3. Upewnij się, że liczba unikalnych emoji ≥ (rozmiar²/2)

Zmiana kolorów i stylu:
W pliku modules/board.sh możesz zmodyfikować:
- CELL_W - szerokość komórki
- unknown - symbol nieodkrytej karty
- Formatowanie podświetlenia kursora

## Licencja

GPL v3

## Autor

Memory Game Script

## Wersja

v1.0.0

## Zobacz także

man bash, zenity --help
