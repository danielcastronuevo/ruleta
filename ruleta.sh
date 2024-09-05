#!/bin/bash

#Colours ----------
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Función de CTRL + C ----------
function ctrl_c () {
  echo -e "\n\n${yellowColour}[!]${endColour} Saliendo...\n"
  tput cnorm; exit 1
}
#Atrapando el CTRL + C
trap ctrl_c INT

#Help Panel ----------
function helpPanel () {
  echo -e "\n${yellowColour}[!]${endColour} Uso: ${purpleColour}$0${endColour}\n"
  echo -e "\t${purpleColour}-m)${endColour}\tElegir la ${blueColour}cantidad de dinero${endColour} para jugar."
  echo -e "\t${purpleColour}-t)${endColour}\tElegir la ${blueColour}técnica${endColour} a utilizar."
}

#Manejando los parámetros ----------
while getopts "m:t:h" arg 2>/dev/null; do
  case $arg in
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel; exit 0;;
  esac
done





#Función Martingala ----------
function martingala () {
  numero_de_jugada=0
  money=$1
  topMoney=$money
  baseMoney=$money
  echo -e "\n${yellowColour}[+]${endColour} Dinero actual: ${blueColour}\$${money}${endColour}"
  echo -ne "\n${yellowColour}[+]${endColour} Cuanto dinero tienes pensado apostar? ${blueColour}->${endColour} " && read initial_bet
  if [[ $initial_bet =~ ^[0-9]+$ ]]; then
    if [[ $initial_bet -lt $money ]]; then
      :
    else
      echo -e "\n${redColour}[!] La cantidad de dinero ${endColour}${yellowColour}$initial_bet${endColour}${redColour} no puede ser mayor a ${endColour}${yellowColour}$money${endColour}${redColour}.${endColour}\n"
      exit 1
    fi
  else
    echo -e "\n${redColour}[!] La cantidad de dinero ${endColour}${yellowColour}$initial_bet${endColour}${redColour} debe ser un valor numérico entero.${endColour}\n"
    exit 1
  fi
  echo -ne "\n${yellowColour}[+]${endColour} A que deseas apostar continuamente (${yellowColour}par${endColour}/${yellowColour}impar${endColour})? ${blueColour}->${endColour} " && read par_impar
  par_impar_lowerCase="$(echo $par_impar | tr '[:upper:]' '[:lower:]')"
  if [ $par_impar_lowerCase == "par" ]; then
    :
  elif [ $par_impar_lowerCase == "impar" ]; then
    :
  else
    echo -e "\n${redColour}[!] La apuesta elegida no es válida${endColour}"
    echo -e "\n${yellowColour}[+]${endColour} Apuestas a utilizar:\n"
    echo -e "\t${blueColour}· Par${endColour}"
    echo -e "\t${blueColour}· Impar${endColour}"
    exit 1
  fi
  initial_bet_original=$initial_bet
  echo -ne "\n${yellowColour}[+]${endColour} Quieres ver la traza de las jugadas (${yellowColour}si${endColour}/${yellowColour}no${endColour})? ${blueColour}->${endColour} " && read traza
  if [[ $traza == "si" || $traza == "Si" || $traza == "sI" || $traza == "SI" ]]; then
    echo -ne "\n${yellowColour}[+]${endColour} Quieres ver la traza con tiempos de espera? (${yellowColour}si${endColour}/${yellowColour}no${endColour})? ${blueColour}->${endColour} " && read trazaTime
  fi
  traza_lowerCase="$(echo $traza | tr '[:upper:]' '[:lower:]')"
  echo -e "\n${yellowColour}[!]${endColour} Vamos a jugar con una cantidad inicial de ${blueColour}\$$initial_bet${endColour} a ${blueColour}$par_impar_lowerCase${endColour}."
  echo -ne "\n${greenColour}[!]${endColour} Presiona enter cuando quieras ${yellowColour}comenzar${endColour} la secuencia" && read go
  tput civis
  while true; do
  numero_de_jugadas=$(($numero_de_jugadas + 1))
  money=$(($money-$initial_bet))
  random_number="$(($RANDOM % 37))"
  if [ $traza_lowerCase == "no" ]; then
    if [ ! $money -le 0 ];then
      if [ $par_impar_lowerCase == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0 ];then
            initial_bet=$(($initial_bet *2))
          else
            money=$(($money + $initial_bet * 2))
            initial_bet=$initial_bet_original
          fi
        else
          initial_bet=$(($initial_bet *2))
        fi
      else
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0 ];then
            initial_bet=$(($initial_bet *2))
          else
            initial_bet=$(($initial_bet *2))
          fi
        else
          money=$(($money + $initial_bet * 2))
          initial_bet=$initial_bet_original
        fi
      fi
    else
      noMoney $money $numero_de_jugadas $topMoney $baseMoney
    fi
  else
    echo -e "\n${yellowColour}[+]${endColour} Acabas de apostar ${blueColour}\$$initial_bet${endColour} y tienes ${yellowColour}\$$money${endColour}"
    echo -e "${yellowColour}[+]${endColour} Salió el número: ${purpleColour}$random_number${endColour}" 
    if [ ! $money -le 0 ];then
      if [ $par_impar_lowerCase == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0 ];then
            echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es el 0 ¡Pierdes!${endColour}"
            initial_bet=$(($initial_bet *2))
            echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
          else
            echo -e "${yellowColour}[!]${endColour}${greenColour} El número que ha salido es par ¡Ganas!${endColour}"
            money=$(($money + $initial_bet * 2))
            echo -e "${yellowColour}[+]${endColour} Ganas un total de ${blueColour}\$$(($initial_bet * 2))${endColour}"
            echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
            initial_bet=$initial_bet_original
          fi
        else
          echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es impar ¡Pierdes!${endColour}"
          initial_bet=$(($initial_bet *2))
          echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
        fi
      else
        if [ "$(($random_number % 2))" -eq 0 ]; then
          if [ "$random_number" -eq 0 ];then
            echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es el 0 ¡Pierdes!${endColour}"
            initial_bet=$(($initial_bet *2))
            echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
          else
            echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es par ¡Pierdes!${endColour}"
            initial_bet=$(($initial_bet *2))
            echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
          fi
        else
          echo -e "${yellowColour}[!]${endColour}${greenColour} El número que ha salido es impar ¡Ganas!${endColour}"
          money=$(($money + $initial_bet * 2))
          echo -e "${yellowColour}[+]${endColour} Ganas un total de ${blueColour}\$$(($initial_bet * 2))${endColour}"
          echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
          initial_bet=$initial_bet_original
        fi
      fi
    else 
        noMoney $money $numero_de_jugadas $topMoney $baseMoney
    fi 
  fi
  if [ $money -gt $topMoney ]; then
    topMoney=$money
  fi
  if [[ $trazaTime == "si" || $trazaTime == "Si" || $trazaTime == "sI" || $trazaTime == "SI" ]]; then
    sleep 0.5
  fi
  done
  tput cnorm
}





# Función inverseLabrouchere
function inverseLabrouchere () {
  numero_de_jugada=0
  money=$1
  topMoney=$money
  baseMoney=$money
  echo -e "\n${yellowColour}[+]${endColour} Dinero actual: ${blueColour}\$${money}${endColour}"
  echo -ne "\n${yellowColour}[+]${endColour} A que deseas apostar continuamente (${yellowColour}par${endColour}/${yellowColour}impar${endColour})? ${blueColour}->${endColour} " && read par_impar
  par_impar_lowerCase="$(echo $par_impar | tr '[:upper:]' '[:lower:]')"
  if [ $par_impar_lowerCase == "par" ]; then
    :
  elif [ $par_impar_lowerCase == "impar" ]; then
    :
  else
    echo -e "\n${redColour}[!] La apuesta elegida no es válida${endColour}"
    echo -e "\n${yellowColour}[+]${endColour} Apuestas a utilizar:\n"
    echo -e "\t${blueColour}· Par${endColour}"
    echo -e "\t${blueColour}· Impar${endColour}"
    exit 1
  fi
  declare -a my_sequence=(1 2 3 4)
  echo -e "\n${yellowColour}[+]${endColour} Comenzaremos con la secuencia ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour} a ${blueColour}$par_impar_lowerCase${endColour}."
  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
  my_sequence=(${my_sequence[@]})
  echo -ne "\n${yellowColour}[+]${endColour} Quieres ver la traza de las jugadas (${yellowColour}si${endColour}/${yellowColour}no${endColour})? ${blueColour}->${endColour} " && read traza
  if [[ $traza == "si" || $traza == "Si" || $traza == "sI" || $traza == "SI" ]]; then
    echo -ne "\n${yellowColour}[+]${endColour} Quieres ver la traza con tiempos de espera? (${yellowColour}si${endColour}/${yellowColour}no${endColour})? ${blueColour}->${endColour} " && read trazaTime
  fi
  traza_lowerCase="$(echo $traza | tr '[:upper:]' '[:lower:]')"
  echo -e "\n${yellowColour}[+]${endColour} Invertiremos ${blueColour}\$$bet${endColour} y tendremos ${blueColour}\$$(($money - $bet))${endColour}."
  echo -ne "\n${greenColour}[!]${endColour} Presiona enter cuando quieras ${yellowColour}comenzar${endColour} la secuencia" && read go
  tput civis
  while true; do
    numero_de_jugadas=$(($numero_de_jugadas + 1))
    random_number=$(($RANDOM % 37))
    money=$(($money - $bet))
  if [ $traza_lowerCase == "si" ]; then
    echo -e "\n${yellowColour}[+]${endColour} Acabas de apostar ${blueColour}\$$bet${endColour} y tienes ${yellowColour}\$$money${endColour}"
    echo -e "${yellowColour}[+]${endColour} Salió el número: ${purpleColour}$random_number${endColour}" 
      if [ $par_impar_lowerCase == "par" ];then
        if [ $(($random_number % 2)) -eq 0 ]; then
          if [ $random_number -eq 0 ]; then
            echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es el 0 ¡Pierdes!${endColour}"
            if [ $money -le 0 ];then
              noMoney $money $numero_de_jugadas $topMoney $baseMoney
            fi
            unset my_sequence[-1] 2>/dev/null
            unset my_sequence[0]
            my_sequence=(${my_sequence[@]})
            if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
              bet=$((${my_sequence[0]}+${my_sequence[-1]}))
              echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
              echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            else
              echo -e "${yellowColour}[!]${endColour}${redColour} ¡Has perdido la secuencia!${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour} Restablecemos nuestra secuencia en ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
              bet=$((${my_sequence[0]}+${my_sequence[-1]}))
            fi
          echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"

          else 
            echo -e "${yellowColour}[!]${endColour}${greenColour} El número que ha salido es par ¡Ganas!${endColour}"
            reward=$(($bet *2))
            let money+=$reward

            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})
        
            if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
              
              bet=$((${my_sequence[0]}+${my_sequence[-1]}))
              echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"

            elif [ "${#my_sequence[@]}" -eq 1 ]; then

              bet=${my_sequence[0]}
              echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
              
            else
              echo -e "${yellowColour}[!]${endColour}${redColour} ¡Has perdido la secuencia!${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour} Restablecemos nuestra secuencia en ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
              bet=$((${my_sequence[0]}+${my_sequence[-1]}))
            fi

            echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
          fi
        else
          echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es impar ¡Pierdes!${endColour}"
          
          if [ $money -le 0 ];then
            noMoney $money $numero_de_jugadas $topMoney $baseMoney
          fi

          unset my_sequence[-1] 2>/dev/null
          unset my_sequence[0]

          my_sequence=(${my_sequence[@]})

          if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
            
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
            echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"

          elif [ "${#my_sequence[@]}" -eq 1 ]; then

            bet=${my_sequence[0]}
            echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            
          else
            echo -e "${yellowColour}[!]${endColour}${redColour} ¡Has perdido la secuencia!${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour} Restablecemos nuestra secuencia en ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi
        echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
        fi
      else
        if [ $(($random_number % 2)) -eq 0 ]; then
          if [ $random_number -eq 0 ]; then
            echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es el 0 ¡Pierdes!${endColour}"
            if [ $money -le 0 ];then
              noMoney $money $numero_de_jugadas $topMoney $baseMoney
            fi
            unset my_sequence[-1] 2>/dev/null
            unset my_sequence[0]
            my_sequence=(${my_sequence[@]})
            if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
              bet=$((${my_sequence[0]}+${my_sequence[-1]}))
              echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            elif [ "${#my_sequence[@]}" -eq 1 ]; then
              bet=${my_sequence[0]}
              echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            else
              echo -e "${yellowColour}[!]${endColour}${redColour} ¡Has perdido la secuencia!${endColour}"
              my_sequence=(1 2 3 4)
              echo -e "${yellowColour}[+]${endColour} Restablecemos nuestra secuencia en ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
              bet=$((${my_sequence[0]}+${my_sequence[-1]}))
            fi
          echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
          else
          echo -e "${yellowColour}[!]${endColour}${redColour} El número que salió es par ¡Pierdes!${endColour}"
          
          if [ $money -le 0 ];then
            noMoney $money $numero_de_jugadas $topMoney $baseMoney
          fi

          unset my_sequence[-1] 2>/dev/null
          unset my_sequence[0]

          my_sequence=(${my_sequence[@]})

          if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
            
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
            echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"

          elif [ "${#my_sequence[@]}" -eq 1 ]; then

            bet=${my_sequence[0]}
            echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            
          else
            echo -e "${yellowColour}[!]${endColour}${redColour} ¡Has perdido la secuencia!${endColour}"
            my_sequence=(1 2 3 4)
            echo -e "${yellowColour}[+]${endColour} Restablecemos nuestra secuencia en ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi
        echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
        fi
      else
        echo -e "${yellowColour}[!]${endColour}${greenColour} El número que ha salido es impar ¡Ganas!${endColour}"
        reward=$(($bet *2))
        let money+=$reward

        my_sequence+=($bet)
        my_sequence=(${my_sequence[@]})
        
        if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
              
          bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"

        elif [ "${#my_sequence[@]}" -eq 1 ]; then

          bet=${my_sequence[0]}
          echo -e "${yellowColour}[+]${endColour} Nuestra nueva secuencia es ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
              
        else
          echo -e "${yellowColour}[!]${endColour}${redColour} ¡Has perdido la secuencia!${endColour}"
          my_sequence=(1 2 3 4)
          echo -e "${yellowColour}[+]${endColour} Restablecemos nuestra secuencia en ${yellowColour}[${endColour}${blueColour} ${my_sequence[@]} ${endColour}${yellowColour}]${endColour}"
          bet=$((${my_sequence[0]}+${my_sequence[-1]}))
        fi

        echo -e "${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
      fi
    fi
    if [ $money -gt $topMoney ]; then
      topMoney=$money
    fi
  if [[ $trazaTime == "si" || $trazaTime == "Si" || $trazaTime == "sI" || $trazaTime == "SI" ]]; then
    sleep 0.5
  fi
  else
    if [ $par_impar_lowerCase == "par" ];then
      if [ $(($random_number % 2)) -eq 0 ]; then
        if [ $random_number -eq 0 ]; then
          if [ $money -le 0 ];then
            noMoney $money $numero_de_jugadas $topMoney $baseMoney
          fi
          unset my_sequence[-1] 2>/dev/null
          unset my_sequence[0]
          my_sequence=(${my_sequence[@]})
          if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
          else
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi
        else 
          reward=$(($bet *2))
          let money+=$reward

          my_sequence+=($bet)
          my_sequence=(${my_sequence[@]})
        
          if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
              
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))

          elif [ "${#my_sequence[@]}" -eq 1 ]; then

            bet=${my_sequence[0]}
              
          else
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi

        fi
      else
        if [ $money -le 0 ];then
          noMoney $money $numero_de_jugadas $topMoney $baseMoney
        fi

        unset my_sequence[-1] 2>/dev/null
        unset my_sequence[0]

        my_sequence=(${my_sequence[@]})

        if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then

          bet=$((${my_sequence[0]}+${my_sequence[-1]}))

        elif [ "${#my_sequence[@]}" -eq 1 ]; then

          bet=${my_sequence[0]}

        else
          my_sequence=(1 2 3 4)
          bet=$((${my_sequence[0]}+${my_sequence[-1]}))
        fi
      fi
    else
      if [ $(($random_number % 2)) -eq 0 ]; then
        if [ $random_number -eq 0 ]; then
          if [ $money -le 0 ];then
            noMoney $money $numero_de_jugadas $topMoney $baseMoney
          fi
          unset my_sequence[-1] 2>/dev/null
          unset my_sequence[0]
          my_sequence=(${my_sequence[@]})
          if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          elif [ "${#my_sequence[@]}" -eq 1 ]; then
            bet=${my_sequence[0]}
          else
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi

        else

          if [ $money -le 0 ];then
            noMoney $money $numero_de_jugadas $topMoney $baseMoney
          fi

          unset my_sequence[-1] 2>/dev/null
          unset my_sequence[0]

          my_sequence=(${my_sequence[@]})

          if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
            
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))

          elif [ "${#my_sequence[@]}" -eq 1 ]; then

            bet=${my_sequence[0]}
            
          else
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]}+${my_sequence[-1]}))
          fi
        fi
      else
          reward=$(($bet *2))
          let money+=$reward
          my_sequence+=($bet)
          my_sequence=(${my_sequence[@]})
        if [[ "${#my_sequence[@]}" -ne 1 && "${#my_sequence[@]}" -ne 0 ]]; then
          bet=$((${my_sequence[0]}+${my_sequence[-1]}))
        elif [ "${#my_sequence[@]}" -eq 1 ]; then
          bet=${my_sequence[0]}
        else
          my_sequence=(1 2 3 4)
          bet=$((${my_sequence[0]}+${my_sequence[-1]}))
        fi
      fi
    fi
  if [ $money -gt $topMoney ]; then
    topMoney=$money
  fi
  fi 
  done
  tput cnorm
}






# Función cuando el usuario se queda sin dinero
function noMoney () {
  money=$1
  numero_de_jugadas=$2
  topMoney=$3
  baseMoney=$4
  echo -e "\n${redColour}[!] Te quedaste sin dinero!${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} Tienes: ${yellowColour}\$$money${endColour}"
  echo -e "\n${greenColour}[+]${endColour} Se han realizado un total de: ${yellowColour}$numero_de_jugadas${endColour} jugadas."
  echo -e "\n${greenColour}[+]${endColour} Comenzamos con el monto de: ${blueColour}\$$baseMoney${endColour}."
  echo -e "\n${greenColour}[+]${endColour} El máximo de dinero ganado fue de: ${blueColour}\$$topMoney${endColour}.\n"

  tput cnorm
  exit 0
}





#Condicional Principal ----------
if [[ $money && $technique ]]; then
  #Verificando si money es una variable numérica
  if [[ $money =~ ^[0-9]+$ ]]; then
    :
  else
    echo -e "\n${redColour}[!] La cantidad de dinero ${endColour}${yellowColour}$money${endColour}${redColour} debe ser un valor numérico entero.${endColour}\n"
    exit 1
  fi
  #Convertimos la varible technique a una versión siempre lowerCase evitando un condicional muy largo
  technique_lowerCase="$(echo $technique | tr '[:upper:]' '[:lower:]')"
  #Verificamos si technique_lowerCase es Martingala o InverseLabrouchere
  if [[ $technique_lowerCase == "martingala" ]]; then
    martingala $money
  elif [[ $technique_lowerCase == "inverselabrouchere" ]]; then
    inverseLabrouchere $money
  else
    echo -e "\n${redColour}[!] La técnica elegida no es válida${endColour}"
    echo -e "\n${yellowColour}[+]${endColour} Técnicas a utilizar:\n"
    echo -e "\t${blueColour}· Martingala${endColour}"
    echo -e "\t${blueColour}· InverseLabrouchere${endColour}"
    exit 1
  fi
# Llamamos al helpPanel en caso de haber ingresado un parametro incorrecto  
else
  helpPanel
  exit 1
fi
