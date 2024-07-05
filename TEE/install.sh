#!/bin/bash

echo "Iniciando o script de movimentação de pastas..."

# Definir o diretório atual
CURRENT_DIR=$(dirname "$0")

# Procurar pela pasta "ola_mundo" no diretório atual
SOURCE_DIR="$CURRENT_DIR/ola_mundo"

echo "Verificando se a pasta 'ola_mundo' existe no diretório atual: $SOURCE_DIR"
# Verificar se a pasta "ola_mundo" existe no diretório atual
if [ ! -d "$SOURCE_DIR" ]; then
  echo "A pasta 'ola_mundo' não foi encontrada no diretório atual."
  exit 1
else
  echo "Pasta 'ola_mundo' encontrada."
fi

# Definir caminhos fixos para optee_qemu e optee_rasp na pasta home do usuário
USER_HOME="/home/$USER"
OPTEE_QEMU_PATH="$USER_HOME/optee_qemu"
OPTEE_RASP_PATH="$USER_HOME/optee_rasp"

# Função para mover a pasta "ola_mundo" para "optee_examples" dentro do diretório especificado
move_to_optee_examples() {
  DEST_DIR="$1/optee_examples"
  
  echo "Verificando se o diretório '$DEST_DIR' existe..."
  if [ -d "$DEST_DIR" ]; then
    echo "Diretório '$DEST_DIR' encontrado. Movendo 'ola_mundo'..."
    cp -r "$SOURCE_DIR" "$DEST_DIR"
    if [ $? -eq 0 ]; then
      echo "A pasta 'ola_mundo' foi movida com sucesso para '$DEST_DIR'."
    else
      echo "Falha ao mover a pasta 'ola_mundo' para '$DEST_DIR'."
    fi
  else
    echo "O diretório '$DEST_DIR' não foi encontrado."
  fi
}

# Verificar e mover para optee_qemu/optee_examples
echo "Verificando se a pasta 'optee_qemu' existe em: $OPTEE_QEMU_PATH"
if [ -d "$OPTEE_QEMU_PATH" ]; then
  move_to_optee_examples "$OPTEE_QEMU_PATH"
else
  echo "A pasta 'optee_qemu' não foi encontrada em: $OPTEE_QEMU_PATH"
fi

# Verificar e mover para optee_rasp/optee_examples
echo "Verificando se a pasta 'optee_rasp' existe em: $OPTEE_RASP_PATH"
if [ -d "$OPTEE_RASP_PATH" ]; then
  move_to_optee_examples "$OPTEE_RASP_PATH"
else
  echo "A pasta 'optee_rasp' não foi encontrada em: $OPTEE_RASP_PATH"
fi

echo "Script concluído."

