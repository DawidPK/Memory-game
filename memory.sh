#!/bin/bash -f

hidden=("😈" "👽" "👽" "😈")
states=(0 0 0 0)
inputs=(-1 -1)
row_count=2
unknown='#'
visible=0
pairs=0

print_board () {
  for ((j=0; j<row_count; j++))
  do
    for ((i=0; i<row_count; i++))
    do
      index=$((i + j * row_count))
      if [ ${states[$index]} = 1 ]; then
        echo -n "${hidden[$index]}"
      else
        echo -n "$unknown"
      fi
    done
    printf '\n'
  done
}

compare () {
  local idx1=$1
  local idx2=$2
  if [ "${hidden[$idx1]}" = "${hidden[$idx2]}" ]; then
    return 0
  else
    return 1
  fi
}

while true; do
  print_board
  echo "Podaj indeks karty (0-3) lub 'q' aby wyjść:"
  read OPCJA

  if [ "$OPCJA" = "q" ]; then
    echo "Do widzenia!"
    exit 0
  fi

  if ! [[ "$OPCJA" =~ ^-?[0-9]+$ ]]; then
    echo "to nie jest liczba"
    continue
  fi

  max_index=$((row_count * row_count - 1))

  if [ "$OPCJA" -lt 0 ] || [ "$OPCJA" -gt "$max_index" ]; then
    echo "zla liczba"
    continue
  fi

  if [ ${states[$OPCJA]} = 1 ]; then
    echo "karta już widoczna"
    continue
  fi

  states[$OPCJA]=1
  inputs[$visible]=$OPCJA
  ((visible++))

  if [ $visible -eq 2 ]; then
    print_board
    echo ""
    sleep 1
    compare "${inputs[0]}" "${inputs[1]}"
    if [ $? -eq 0 ]; then
      echo "Para!"
      ((pairs++))
    else
      echo "Nie trafiono"
      (( states[${inputs[0]}] = 0 ))
      (( states[${inputs[1]}] = 0 ))
    fi
    inputs[0]=-1
    inputs[1]=-1
    visible=0
    
    total_pairs=$(( (row_count * row_count) / 2 ))
    if [ $pairs -eq $total_pairs ]; then
      print_board
      echo "WYGRANA!"
      exit 0
    fi
  fi
done
