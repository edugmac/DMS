#!/bin/bash
TIMESTAMP=$(date +"%d%m%Y_%H%M%S")
exec 3>&1 1>"logfiles/logfile_${TIMESTAMP}.log" 2>&1
set -x
date -Is

echo "Iniciando instalação da TA">&3
echo "Aviso: A instalação automática somente funcionará caso o diretório de instalação">&3
echo "seja igual ao do readme. Caso a instalação tenha sido feita num diretório diferente,">&3
echo "o processo terá de ser feito manualmente." >&3

# Solicitar confirmação do usuário
echo "Deseja continuar com a instalação? (s/n): " >&3
read resposta 

# Verificar a resposta do usuário
if [[ "$resposta" =~ ^[Ss]$ ]]; then
    echo "Continuando com a instalação..." >&3
else
    echo "Instalação abortada pelo usuário." >&3
    exit 1
fi

# Definir o diretório atual
CURRENT_DIR=$(dirname "$0")

# Procurar pela pasta "ola_mundo" no diretório atual
SOURCE_DIR="$CURRENT_DIR/ola_mundo"

# Verificar se a pasta "ola_mundo" existe no diretório atual
if [ ! -d "$SOURCE_DIR" ]; then
  echo "A pasta 'ola_mundo' não foi encontrada no diretório atual. Clone o repositório novamente!" >&3
  exit 1
fi

# Definir caminhos fixos para optee_qemu e optee_rasp na pasta home do usuário
USER_HOME="/home/$USER"
OPTEE_QEMU_PATH="$USER_HOME/optee_qemu"
OPTEE_RASP_PATH="$USER_HOME/optee_rasp"

# Função para mover a pasta "ola_mundo" para "optee_examples" dentro do diretório especificado
move_to_optee_examples() {
  DEST_DIR="$1/optee_examples"
  
  if [ -d "$DEST_DIR" ]; then
    echo "Iniciando instalação da TA" >&3
    cp -r "$SOURCE_DIR" "$DEST_DIR"
    if [ $? -eq 0 ]; then
      echo "Instalação bem-sucedida"
    else
      echo "Falha na instalação. Verifique o logfile gerado" >&3
      exit 1
    fi
  else
    echo "O diretório de instalação do OP-TEE não foi encontrado." >&3
  fi
}

# Verificar e mover para optee_qemu/optee_examples
echo "Verificando instalação do OP-TEE para Qemu" >&3
if [ -d "$OPTEE_QEMU_PATH" ]; then
  move_to_optee_examples "$OPTEE_QEMU_PATH"
else
  echo "A instalação do OP-TEE para Qemu não foi encontrada" >&3
fi

# Verificar e mover para optee_rasp/optee_examples
echo "Verificando instalação do OP-TEE para Raspberry Pi" >&3
if [ -d "$OPTEE_RASP_PATH" ]; then
  move_to_optee_examples "$OPTEE_RASP_PATH"
else
  echo "A instalação do OP-TEE para Raspberry Pi não foi encontrada" >&3
fi
echo "Fim da instalação" >&3
