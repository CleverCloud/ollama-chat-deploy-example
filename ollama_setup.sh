#!/bin/bash

# We define the folder (in $PATH), where the ollama binary will be placed
BIN_DIR=${HOME}/.local/bin
LIB_DIR=${HOME}/.local/lib
mkdir -p ${BIN_DIR} 
mkdir -p ${LIB_DIR}


ollama_start() {
    echo "Downloading and launching ollama..."
    curl -L https://ollama.com/download/ollama-linux-amd64.tgz -o ollama-linux-amd64.tgz
    tar -xzf ollama-linux-amd64.tgz
    sleep 2
    echo "coucou"
    mv bin/* ${BIN_DIR}
    mv lib/* ${LIB_DIR}
    chmod +x ${BIN_DIR}/ollama
    ls ${BIN_DIR}/ollama
    echo "coucou2"
    sleep 2
    ollama serve &
    #&> /dev/null &
    echo -e "Finished: \o/"
}
#https://github.com/ollama/ollama/releases/tag/v0.5.8-rc7

get_models() {
    MODELS_FILE="models.list"
    MODELS_DEFAULT="orca-mini"

    # We check if the models file exists
    if [ ! -f ${MODELS_FILE} ]; then
        echo "File ${MODELS_FILE} not found, ${MODELS_DEFAULT} used by default."
        echo ${MODELS_DEFAULT} > ${MODELS_FILE}
    fi

    # Loop through each line and pull model
    while IFS= read -r line; do
        echo "Pulling ${line} model..."
        ollama pull "${line}" > /dev/null
        echo -e "Finished: \033[32m✔\033[0m\n"

    done < ${MODELS_FILE}
}

# We start ollama, and wait for it to respond
ollama_start
if [ $? -ne 0 ]; then
    echo -e "\nError during ollama setup."
    exit 1
fi

count=0
MAX_TIME=10

while ! pgrep -x "ollama" > /dev/null; do
    if [ ${count} -lt ${MAX_TIME} ]; then
        sleep 1
        count=$((count+1))
    else
        echo "Application 'ollama' did not launch within 10 seconds."
        exit 1
    fi
done

get_models
if [ $? -ne 0 ]; then
    echo -e "\nError during models downloading."
    exit 1
fi
