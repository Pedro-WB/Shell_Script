#!/bin/bash

# Nome do arquivo resultados
result_file="resultados.txt"

# Repetição do teste 9 vezes
for i in {1..10}; do

    # Solicita ao usuário o nome do arquivo de teste
    read -p "Digite o nome do arquivo de teste (sem extensão): " user_input
    
    # Conteúdo para o arquivo de teste
    echo "Este é um arquivo de teste para compactação usando gzip e tar. 
    Acredite, pense e faça,
    use sua intuição,
    transforme sonho em suor,
    pensamento em ação.
    Enfrente cada batalha
    sabendo que a gente falha
    e que isso é natural,
    cair pra se levantar,
    aprender para ensinar
    que o bem é maior que o mal. -- Bráulio Bessa --" > "${user_input}.txt"
    
    # Nome do arquivo a ser compactado
    original_file="${user_input}.txt"

    # Nome do arquivo compactado com gzip e com tar
    gzip_file="${original_file}.gz"

    tar_file="${original_file}.tar"
    
    # Teste com gzip
    echo "Compactando usando gzip..."
    time gzip "$original_file" >> "$result_file"
    
    echo "Teste $i - Verificação com gzip -l:" >> "$result_file"
    time gzip -l "$gzip_file" >> "$result_file"

    # Verifica se o arquivo compactado com gzip existe
    if [ -e "$gzip_file" ]; then
        echo "gzip: Compactação bem-sucedida."
        echo "Descompactando usando gzip..."
        time gzip -d "$gzip_file" >> "$result_file"
        echo "gzip: Descompactação bem-sucedida."
    else
        echo "gzip: Falha na compactação."
    fi

    # Cria um arquivo para testar a compactação com tar
    echo "Este é um segundo arquivo de teste." > "segundo_arquivo.txt"

    # Teste com tar
    echo "Teste $i - Verificação com tar -tzvf:" >> "$result_file"
    time tar -czvf "$tar_file" "$original_file" "segundo_arquivo.txt" >> "$result_file"

    # Teste com tar
    echo "Teste $i - Verificação com tar -ztvf:" >> "$result_file"
    time tar -xzvf "$tar_file" >> "$result_file"

    # Verifica se o arquivo compactado com tar existe
    if [ -e "$tar_file" ]; then
        echo "tar: Compactação bem-sucedida."
        echo "Descompactando usando tar..."
        time tar -xvvf "$tar_file" >> "$result_file"
        echo "tar: Descompactação bem-sucedida."
    else
        echo "tar: Falha na compactação."
    fi

    # Limpa os arquivos temporários criados
    rm "$original_file" "$tar_file" "segundo_arquivo.txt"

    echo "Teste $i concluído."

done

# Exibe o arquivo de resultados
cat "$result_file"
