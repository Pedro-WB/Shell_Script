#!/bin/bash

# Incluir as funções do arquivo functions.sh
source ./func.sh

# Verificar a existência do comando scp
if ! check_command "scp"; then
    print_error "O comando 'scp' não está disponível. Certifique-se de que o OpenSSH está instalado."
    exit 1
fi

# Verificar a existência do Yad
if ! check_command "yad"; then
    print_error "O Yad não foi encontrado! Em distribuições baseadas em Debian, utilize para instalar: sudo apt-get install yad"
    exit 1
fi

# Pedir informações de conexão SSH antes de exibir a interface gráfica
read -p "Usuário Remoto: " remote_user
read -p "Host Remoto: " remote_host
read -p "Porta SSH (press Enter para padrão 22): " ssh_port

# Validar conexão SSH antes de exibir a interface gráfica
if ! validate_ssh_connection "$remote_user" "$remote_host" "$ssh_port"; then
    print_error "Erro ao conectar-se ao host remoto. Verifique as credenciais SSH e a porta especificada."
    exit 1
fi

# Interface gráfica
FORM=$(yad --form \
    --title "SCP Transferência de Arquivos" \
    --text-align="center" \
    --width=400 \
    --height=200 \
    --field="Arquivo Local:FL" "" \
    --field="Caminho Remoto:FL" "" \
    --field="Progresso:PM" "" \
    --button="gtk-cancel:1" \
    --button="gtk-ok:0" \
    --columns=2 \
    --separator="|" \
    --auto-close \
    --center
)

# Remover a barra de título padrão
yad --title=" " --image="gtk-dialog-info" --window-icon="gtk-dialog-info" --width=400 --height=50 --text-align="center" --text="<b>Transferência em Andamento...</b>" --timeout=3 --no-buttons --center --skip-taskbar &

# Obter valores dos campos
IFS="|" read -r local_file remote_path <<< "$FORM"

# Validar entrada
if [ -z "$local_file" ] || [ -z "$remote_path" ]; then
    print_error "Preencha todos os campos corretamente."
    exit 1
fi

# Iniciar a transferência em segundo plano
scp -P "$ssh_port" "$local_file" "$remote_user@$remote_host:$remote_path" &

# Mostrar barra de progresso
(
    while true; do
        sleep 1
        # Calcular o progresso (apenas um exemplo)
        progress=$(du -b "$local_file" | cut -f1)
        yad --progress \
            --percentage="$((progress * 100 / $(stat -c %s "$local_file")))" \
            --text="<b>Transferindo:</b> $progress bytes" \
            --auto-close \
            --no-cancel \
            --center
    done
) &

# Esperar até que a transferência seja concluída
wait

# Verificar o status da transferência
if [ $? -eq 0 ]; then
    print_success "Transferência concluída!"
else
    print_error "Erro durante a transferência. Verifique as permissões e a disponibilidade do arquivo."
fi
