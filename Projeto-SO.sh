#!/bin/bash

# Nome do arquivo resultados
result_file="resultados.txt"

# Repetição do teste 5 vezes
for i in {1..5}; do

    # Solicita ao usuário o nome do arquivo de teste
    read -p "Digite o nome do arquivo de teste (sem extensão): " user_input

    # Nome do arquivo a ser compactado
    original_file="${user_input}.txt"

    # Nome do arquivo compactado com gzip
    gzip_file="${original_file}.gz"

    # Nome do arquivo compactado com tar
    tar_file="${original_file}.tar"

    # Conteúdo para o arquivo de teste
    echo "Este é um arquivo de teste para compactação usando gzip e tar." > "$original_file"

    # Teste com gzip
    echo "Teste $i - Verificação com gzip -t:" >> "$result_file"
    gzip -t "$gzip_file" >> "$result_file"

    echo "Compactando usando gzip..."
    gzip "$original_file"

    # Verifica se o arquivo compactado com gzip existe
    if [ -e "$gzip_file" ]; then
        echo "gzip: Compactação bem-sucedida."
        echo "Descompactando usando gzip..."
        gzip -d "$gzip_file"
        echo "gzip: Descompactação bem-sucedida."
    else
        echo "gzip: Falha na compactação."
    fi

    # Cria um arquivo para testar a compactação com tar
    echo "Este é um segundo arquivo de teste." > "segundo_arquivo.txt"

    # Teste com tar
    echo "Teste $i - Verificação com tar -tzvf:" >> "$result_file"
    tar -tzvf "$tar_file" >> "$result_file"

    echo "Compactando usando tar..."
    tar -cvf "$tar_file" "$original_file" "segundo_arquivo.txt"

    # Teste com tar
    echo "Teste $i - Verificação com tar -ztvf:" >> "$result_file"
    tar -ztvf "$tar_file" >> "$result_file"

    # Verifica se o arquivo compactado com tar existe
    if [ -e "$tar_file" ]; then
        echo "tar: Compactação bem-sucedida."
        echo "Descompactando usando tar..."
        tar -xvf "$tar_file"
        echo "tar: Descompactação bem-sucedida."
    else
        echo "tar: Falha na compactação."
    fi

    # Limpa os arquivos temporários criados
    rm "$original_file" "$gzip_file" "$tar_file" "segundo_arquivo.txt"

    echo "Teste $i concluído."

done

# Executa o comando top e redireciona a saída para o arquivo resultados
top -b -n 1 >> "$result_file"

# Exibe o arquivo de resultados
cat "$result_file"

# Limpa o arquivo de resultados ao final (opcional)
# rm "$result_file"
