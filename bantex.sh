#!/bin/bash
SEP=:
TEMP=temp.$$
MASCARA=§

[ "$BANCO" ] || {
    echo "Base de dados não informada. Use a variavel BANCO."
    return 1
}
[ -r "$BANCO" -a -w "$BANCO" ] || {
    echo "Base travada, confirme as permissões de escrita e leitura."
    return 1
}

mascara() { tr $SEP $MASCARA ; }

desmascara() { tr $MASCARA $SEP ; }

apaga_registro() {
    tem_chave "$1" || return
    grep -i -v "^$1$SEP" "$BANCO" > "$TEMP"  
    mv "$TEMP" "$BANCO"
    echo "O registro '$1' foi apagado"
}


insere_registro() {
    local chave=$(echo "$1" | cut -d $SEP -f1)

    if tem_chave "$chave"; then
        echo "A chave '$chave' já esta cadastrada no banco."
        return 1
    else
        echo "$*" >> "$BANCO"
        echo  "Registro de '$chave' cadastrado com sucesso."
    fi
    return 0
}

pega_campo() {
    local chave=${2:-.*}
    grep -i "^$chave$SEP" "$BANCO" | cut -d $SEP -f $1 | desmascara
}

tem_chave() {
    grep -i -q "^$1$SEP" "$BANCO"
}

campos() {
    head -n 1 "$BANCO" | tr $SEP \\n
}

mostra_registro() {
    local dados=$(grep -i "^$1$SEP" "$BANCO")
    local i=0
    [ "$dados" ] || return
    campos | while read campo; do
        i=$((i+1))
        echo -n "$campo: "
        echo "$dados" | cut -d $SEP -f $i | desmascara
    done
}
