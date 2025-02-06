#!/bin/bash

# We define the folder (in $PATH), where the ollama binary will be placed
BIN_DIR=${HOME}/.local/bin
mkdir -p ${BIN_DIR} 

ollama_start() {
    echo "Downloading and launching ollama..."
    curl -L https://ollama.com/download/ollama-linux-amd64.tgz -o ollama-linux-amd64.tgz | tar -xzf ollama-linux-amd64.tgz -C ${BIN_DIR}/ollama
    chmod +x ${BIN_DIR}/ollama
    ollama serve &> /dev/null &
    echo -e "Finished: \033[32m✔\033[0m\n"
}

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
        ollama pull "${line}" > /dev/null 2>&1
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
