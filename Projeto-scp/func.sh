#!/bin/bash

# Função para verificar a existência de uma ferramenta no PATH
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Função para validar a conexão SSH
validate_ssh_connection() {
    local user=$1
    local host=$2
    local port=${3:-22}  # Porta SSH padrão é 22

    ssh -q -o BatchMode=yes -o ConnectTimeout=5 -p "$port" "$user@$host" exit
    return $?
}

# Função para exibir mensagens de erro em vermelho
print_error() {
    echo -e "\e[91mErro: $1\e[0m"
}

# Função para exibir mensagens de sucesso em verde
print_success() {
    echo -e "\e[92m$1\e[0m"
}
