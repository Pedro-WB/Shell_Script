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

# Função para mostrar o diálogo de seleção de arquivo
select_file_dialog() {
    yad --file \
        --width=600 \
        --height=400 \
        --file-filter="Todos os Arquivos | *.*" \
        --file-filter="Arquivos de Texto | *.txt" \
        --file-filter="Documentos | *.doc;*.docx;*.odt" \
        --file-filter="Imagens | *.png;*.jpg;*.jpeg;*.gif" \
        --file-filter="Todos os Arquivos | *.*" \
        --title="Selecionar Arquivo"
}

# Interface gráfica para obter informações de conexão SSH
FORM=$(yad --form \
    --title "SCP Transferência de Arquivos" \
    --width=400 \
    --height=600 \
    --text-align="center" \
    --field="Arquivo Local:FBTN" "yad --file --width=600 --height=400" \
    --field="Caminho Remoto:TXT" "" \
    --field="Usuário Remoto:TXT" "" \
    --field="Host Remoto:TXT" "" \
    --field="Porta SSH:NUM" "22" \
    --field="Progresso:LBL" "" \
    --button="gtk-cancel:1" \
    --button="gtk-ok:0" \
    --columns=1 \  # Ajuste para uma coluna
    --separator="|" \
    --auto-close \
    --center
)

# Obter valores dos campos
IFS="|" read -r local_file remote_path remote_user remote_host ssh_port <<< "$FORM"

# Validar entrada
if [ -z "$local_file" ] || [ -z "$remote_path" ] || [ -z "$remote_user" ] || [ -z "$remote_host" ]; then
    print_error "Preencha todos os campos corretamente."
    exit 1
fi

# Iniciar a transferência em segundo plano
scp -P "$ssh_port" "$local_file" "$remote_user@$remote_host:$remote_path" &

# Janela de progresso
(
    while true; do
        sleep 1
        # Calcular o progresso (apenas um exemplo)
        progress=$(du -b "$local_file" | cut -f1)
        echo "$((progress * 100 / $(stat -c %s "$local_file"))) Transferindo: $progress bytes"
    done
) | yad --title "Progresso da Transferência" \
    --text-align="center" \
    --width=500 \
    --height=150 \
    --progress \
    --auto-close \
    --no-cancel \
    --center

# Esperar até que a transferência seja concluída
wait

# Verificar o status da transferência
if [ $? -eq 0 ]; then
    yad --title "Transferência Concluída" \
        --text-align="center" \
        --width=300 \
        --height=100 \
        --image="gtk-ok" \
        --text="<b>Transferência concluída!</b>" \
        --button="gtk-ok:0" \
        --center
else
    yad --title "Erro na Transferência" \
        --text-align="center" \
        --width=300 \
        --height=100 \
        --image="gtk-no" \
        --text="<b>Erro durante a transferência.</b>\nVerifique as permissões e a disponibilidade do arquivo." \
        --button="gtk-ok:0" \
        --center
fi

