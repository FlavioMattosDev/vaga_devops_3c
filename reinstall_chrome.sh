#!/bin/bash

# Função para verificar se o último comando foi bem-sucedido
check_error() {
    if [ $? -ne 0 ]; then
        echo "Erro: $1"
        exit 1
    fi
}

echo "Iniciando o processo de atualização do Chrome e Chromedriver (versão estável)..."

# 1. Remover todas as variantes do Google Chrome existentes
echo "Removendo todas as variantes do Google Chrome existentes..."
# Tentar remover pacotes via apt, mas não falhar se não existirem
sudo apt-get remove --purge google-chrome-stable google-chrome-beta google-chrome-unstable -y &>/dev/null || true
echo "Removendo arquivos manuais do Google Chrome (incluindo Chrome for Testing)..."
sudo rm -rf /usr/lib/google-chrome /usr/lib/chromium-browser /opt/google/chrome-for-testing /usr/bin/google-chrome
check_error "Falha ao remover diretórios do Google Chrome"
sudo rm -rf ~/.config/google-chrome ~/.cache/google-chrome
check_error "Falha ao remover configurações do Chrome"

# 2. Remover Chromedriver existente
echo "Removendo Chromedriver existente..."
sudo rm -f /usr/local/bin/chromedriver
check_error "Falha ao remover Chromedriver existente"

# 3. Atualizar lista de pacotes
echo "Atualizando lista de pacotes..."
sudo apt-get update &>/dev/null
check_error "Falha ao atualizar lista de pacotes"

# 4. Instalar Google Chrome Stable mais recente
echo "Instalando a versão estável mais recente do Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
check_error "Falha ao baixar o pacote do Chrome Stable"
sudo dpkg -i google-chrome-stable_current_amd64.deb &>/dev/null
check_error "Falha ao instalar o Chrome Stable via dpkg"
sudo apt-get install -f -y &>/dev/null # Corrige dependências se necessário
check_error "Falha ao corrigir dependências do Chrome Stable"
rm google-chrome-stable_current_amd64.deb

# 5. Obter versão do Chrome instalada
CHROME_VERSION=$(google-chrome-stable --version | grep -oP '\d+\.\d+\.\d+\.\d+')
echo "Versão do Chrome Stable instalada: $CHROME_VERSION"

# 6. Baixar e instalar Chromedriver compatível
echo "Baixando Chromedriver compatível com a versão estável..."
# Usar o repositório chrome-for-testing-public para o Chromedriver
DRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip"

# Baixar o Chromedriver diretamente com a versão exata do Chrome
wget -q "$DRIVER_URL" -O chromedriver-linux64.zip
check_error "Falha ao baixar o Chromedriver (versão $CHROME_VERSION). Verifique conexão ou se a versão existe no repositório."

# Descompactar e instalar
unzip -q chromedriver-linux64.zip -d /tmp
check_error "Falha ao descompactar o Chromedriver"
sudo mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
check_error "Falha ao mover o Chromedriver"
sudo chmod +x /usr/local/bin/chromedriver
check_error "Falha ao dar permissão de execução ao Chromedriver"

# Limpar arquivos temporários
rm -rf chromedriver-linux64.zip /tmp/chromedriver-linux64

# 7. Verificar versões instaladas
echo "Verificando versões instaladas:"
CHROME_INSTALLED=$(google-chrome-stable --version)
CHROMEDRIVER_INSTALLED=$(chromedriver --version)
echo "Google Chrome Stable: $CHROME_INSTALLED"
echo "Chromedriver: $CHROMEDRIVER_INSTALLED"

# 8. Testar compatibilidade básica
echo "Testando compatibilidade..."
if chromedriver --version &>/dev/null && google-chrome-stable --version &>/dev/null; then
    # Verificar se as versões principais coincidem
    CHROME_MAJOR=$(echo "$CHROME_INSTALLED" | grep -oP '\d+' | head -1)
    DRIVER_MAJOR=$(echo "$CHROMEDRIVER_INSTALLED" | grep -oP '\d+' | head -1)
    if [ "$CHROME_MAJOR" != "$DRIVER_MAJOR" ]; then
        echo "Aviso: Versões principais não coincidem (Chrome: $CHROME_MAJOR, Chromedriver: $DRIVER_MAJOR)"
        echo "Isso pode causar problemas com Selenium."
    else
        echo "Versões compatíveis confirmadas!"
    fi
    echo "Instalação concluída com sucesso!"
    echo "Tudo pronto para usar com Selenium."
else
    echo "Erro: Algum componente não está funcionando corretamente"
    exit 1
fi

exit 0