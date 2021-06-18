#!/bin/bash

# Constantes que guardam as cores
RED='\033[31;1m'
GREEN='\033[32;1m'
BLUE='\033[34;1m'
YELLOW='\033[33;1m'
PURPLE='\033[35;1m'
WHITE='\033[37;1m'
RED_BLINK='\033[31;5;1m'
BABYBLUE='\033[36;1m'
END='\033[m'

#User-Agent
agent="User-Agent: MTecTools"

#Verifica o tamanho da janela para poder desenhar o layout
colunas=$(tput cols)

# Constantes para guardar os argumentos passado
ARG01=$1
ARG02=$2

#Função chamada quando o programa é cancelado com [Ctrl]+[c]
trap __Ctrl_c__ INT

#Função chamada ao pressionar as teclas Ctrl+c
__Ctrl_c__()
{
  printf "\n${RED_BLINK}Ação cancelada!!${END}\n\n"
  __Division__
  exit 1
}

#Função para desenhar uma divisoria
__Division__()
{
  printf "\r${PURPLE}=${END}"

  for index in $(seq 0 1 $(($colunas-2)));
  do
    printf "${PURPLE}=${END}"
  done
  echo
}

__Verification__()
{
  # Verifica as dependências.
  if ! [[ -e /usr/bin/curl ]];
  then
    printf "\nAusencia do programa ${RED}curl${END} para funcionar.\n"
    exit 1
  fi

  # Verifica se os argumentos foram passados.
  if [[ "$ARG02" == "" ]];
  then
    __Banner__
    exit 1
  fi
}

__Server_End_Tecnology__()
{
  # Verifica se a URL existe ou não responde
  status=$(curl -s -A "$agent" -I $ARG01)
  if [ "$status" == "" ]
  then
    printf "${RED}[-] Verifique a URL informada!!${END}"
  fi

  # Busca informações para obter o server e a tecnologia utilizada
  server=$(echo "$status" | grep -E "Server:" | cut -d ":" -f 2)
  tecnology=$(echo "$status" | grep -E "X-Powered-By:" | cut -d ":" -f 2)
  echo
  printf "${GREEN}[+] WebServer identificado:${END} \t${BABYBLUE}$server${END}\n"

  if [[ $tecnology != "" ]];
  then
    printf "${GREEN}[+] Tecnologia:${END} \t\t${BABYBLUE}$tecnology${END}\n"
  fi
}

__Banner__()
{
  clear
  __Division__
  echo


  centro_coluna=$(( $(( $(( $colunas-16))/2 )))) #Calculo para centralizar o titulo
  tput cup 0 $centro_coluna #Posiciona o cursor
  printf "${WHITE}MURILLO_NP WEB RECON${END}"


  echo
  echo
  __Division__
  printf "${WHITE}--> WEB RECON${END}\n"
  printf "${WHITE}--> Created by: Murillo NP${END}\n"
  echo
  echo -e "${WHITE}--> Usage   :${END}${GREEN}$0${END} ${WHITE}[URL] [EXTENSION]${END}"
  echo -e "${WHITE}--> Example :${END}${GREEN}$0${END} ${WHITE}http://alvo.com.br php${END}"
  __Division__
  exit 1
}

__Exec__()
{
  echo
  __Division__
  printf "${RED}========================= --> ${END}${BLUE}Searching for Directories${END}${RED} <-- =========================${END}\n"
  for directory in $(cat list02.txt);
  do
    answer=$(curl -s -A "$agent" -o /dev/null -w "%{http_code}" $ARG01/$directory/)

    if [[ $answer == "200" ]];
    then
      printf "${RED}==>${END} $ARG01/${GREEN}$directory${END}/\n"
    fi
  done
  __Exec_file__
}

__Exec_file__()
{
  echo
  printf "${RED}========================= --> ${END}${BLUE}Searching for File.......${END}${RED} <-- =========================${END}\n"
  for file in $(cat list02.txt);
  do
    answer=$(curl -s -A "$agent" -o /dev/null -w "%{http_code}" $ARG01/$file.$ARG02)

    if [[ $answer == "200" ]];
    then
      printf "${RED}==>${END} $ARG01/${GREEN}$file.$ARG02${END}\n"
    fi
  done
  __Division__
}

#Função principal
__Main__()
{
  __Verification__
  __Server_End_Tecnology__
  __Exec__
}

#Inicio do programa
__Main__
