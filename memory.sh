#!/bin/bash -f
temp=(":<" ":>" ":>" ":<")
temp2=(0 0 0 0)
row_count=2
unknown='#'

wypisz () {
  for ((j=0; j<row_count; j++))
  do
    for ((i=0; i<row_count; i++))
    do
      index=$((i + j * row_count))
      if [ ${temp2[$index]} = 1 ]; then
        echo -n ${temp[$index]}
      else
        echo -n "$unknown"
      fi
    done
    printf '\n'
  done
}

while true; do
  wypisz

  read OPCJA

  if [ "$OPCJA" = "q" ]; then
    exit 0
  fi

  if ! [[ "$OPCJA" =~ ^-?[0-9]+$ ]]; then
    echo "to nie jest liczba"
    continue
  fi

  max_index=$((row_count * row_count - 1))

  if [ "$OPCJA" -lt 0 ] || [ "$OPCJA" -gt "$max_index" ]; then
    echo "zla liczba"
  fi

  if [ ${temp2[$OPCJA]} = 1 ]; then
    echo "karta już widoczna"
  fi

  temp2[$OPCJA]=1
done
