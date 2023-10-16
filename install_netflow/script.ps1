
Write-Output @"                                                   
*******************************************************                                                    
*                                                     *
*                       JOTA'S                        *
*                    Soluções em TI                   *
*                                                     *
*******************************************************                                                                                                                                                          
"@


# Solicitar informações do usuário para o GitHub
$usuario = Read-Host "Digite seu nome de usuário do GitHub"
$token = Read-Host "Digite seu token de acesso do GitHub"
$clientID = Read-Host "Digite seu Client ID do GitHub"

# Instalar Docker, Docker Compose e Git
Invoke-Expression -Command "apt-get update"
Invoke-Expression -Command "apt-get install -y docker.io"
Invoke-Expression -Command "curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose"
Invoke-Expression -Command "chmod +x /usr/local/bin/docker-compose"
Invoke-Expression -Command "apt-get install git -y"

# Função para baixar um repositório público do GitHub
function Save-GitHubRepositoryPublic {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Owner,

        [Parameter(Mandatory=$true)]
        [string]$Project,

        [Parameter()]
        [string]$Branch = 'master'
    )

    # Construir a URL do repositório no GitHub com base nos parâmetros fornecidos
    $url = "https://github.com/${Owner}/${Project}.git"

    # Obtém a hora de início do download
    $start_time = Get-Date

    # Usar git clone para baixar o repositório público
    git clone $url

    # Calcula e exibe o tempo total que levou para baixar o repositório
    Write-Host "Time taken: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"
}

# Baixar o repositório público do GitHub (elastiflow)
Save-GitHubRepositoryPublic -Owner "robcowart" -Project "elastiflow"

# Função para baixar um repositório privado do GitHub
function Save-GitHubRepositoryPrivate {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Owner,

        [Parameter(Mandatory=$true)]
        [string]$Project,

        [Parameter()]
        [string]$Branch = 'master'
    )

    # Construir a URL do arquivo tar.gz do repositório no GitHub com base nos parâmetros fornecidos
    $url = "https://github.com/${Owner}/${Project}/archive/${Branch}.tar.gz"

    # Obtém a hora de início do download
    $start_time = Get-Date

    # Usar Invoke-WebRequest para baixar o arquivo tar.gz do repositório privado com o token de acesso como cabeçalho de autorização
    Invoke-WebRequest -Uri $url -OutFile "${Project}-${Branch}.tar.gz" -Headers @{ Authorization = "Bearer $token" }

    # Descompactar o arquivo tar.gz
    tar -xzf "${Project}-${Branch}.tar.gz"

    # Calcula e exibe o tempo total que levou para baixar e descompactar o arquivo
    Write-Host "Time taken: $((Get-Date).Subtract($start_time).TotalSeconds) second(s)"
}

# Baixar e descompactar o repositório privado do GitHub (netflow_flowbix)
Save-GitHubRepositoryPrivate -Owner "Flowbix" -Project "netflow_flowbix"


# Caminho do arquivo docker-compose.yml do ElastiFlow
$dockerComposeFilePath = "./elastiflow/docker-compose.yml"

# Ler o conteúdo do arquivo
$dockerComposeContent = Get-Content -Path $dockerComposeFilePath -Raw

# Remover a seção elastiflow-kibana do conteúdo
$dockerComposeContent = $dockerComposeContent -replace '(?s)elastiflow-kibana.*?LOGGING_QUIET: ''false''', ''

# Escrever o conteúdo de volta para o arquivo
$dockerComposeContent | Set-Content -Path $dockerComposeFilePath

Write-Output "Seção elastiflow-kibana removida do arquivo docker-compose.yml do ElastiFlow."


# Caminho do arquivo .env dentro do diretório netflow_flowbix-main
$envFilePath = "./netflow_flowbix-main/.env"

# Ler o conteúdo do arquivo .env
$envContent = Get-Content -Path $envFilePath -Raw

# Expressão regular para encontrar o texto a ser substituído (substitua pelo seu valor real)
$regexPattern = "(?s)940db999-e775-4b3d-a299-0108e4ff3347*"

# Novo CLient ID
$novoValor = ${clientID}

# Realizar o replace usando a regex
$envContent = $envContent -replace $regexPattern, $novoValor

# Escrever o conteúdo modificado de volta para o arquivo .env
$envContent | Set-Content -Path $envFilePath

Write-Output "Conteúdo do arquivo .env modificado com sucesso."


# Caminho do diretório netflow_flowbix-main
$netflowDirectory = "./netflow_flowbix-main"

# Caminho das pastas a serem criadas
$dataDirectory = Join-Path $netflowDirectory "data"
$inputDataDirectory = Join-Path $dataDirectory "inputdata"

# Verifica se o diretório 'data' já existe, senão cria
if (-not (Test-Path -Path $dataDirectory -PathType Container)) {
    New-Item -Path $dataDirectory -ItemType Directory
}

# Verifica se o diretório 'inputdata' já existe, senão cria
if (-not (Test-Path -Path $inputDataDirectory -PathType Container)) {
    New-Item -Path $inputDataDirectory -ItemType Directory
}

Write-Output "Pastas 'data' e 'inputdata' criadas com sucesso dentro de netflow_flowbix-main."

# Caminho do arquivo docker-compose.yml dentro do diretório elastiflow
$elastiflowDockerComposeFilePath = "./elastiflow/docker-compose.yml"

# Executar docker-compose up --build -d dentro do diretório elastiflow
Invoke-Expression -Command "docker-compose -f $elastiflowDockerComposeFilePath up --build -d"


# Caminho do arquivo docker-compose.yml dentro do diretório netflow_flowbix-main
$netflowDockerComposeFilePath = "./netflow_flowbix-main/docker-compose.yml"

# Executar docker-compose up --build -d dentro do diretório netflow_flowbix-main
Invoke-Expression -Command "docker-compose -f $netflowDockerComposeFilePath up --build -d"


# Se as variáveis de usuário, token e clientID ainda não foram definidas, solicite ao usuário
if (-not $usuario) {
    $usuario = Read-Host "Digite seu nome de usuário do GitHub"
}

if (-not $token) {
    $token = Read-Host "Digite seu token de acesso do GitHub"
}

if (-not $clientID) {
    $clientID = Read-Host "Digite seu Client ID do GitHub"
}


# URL do repositório SCRIPTS
$urlRepositorio = "https://{$usuario}:$token@github.com/Flowbix/scripts.git"

# Diretório de destino para clonar o repositório
$diretorioDestino = "./scripts"

# Executar o comando git clone para baixar o repositório
git clone $urlRepositorio $diretorioDestino

Write-Output "Repositório SCRIPT baixado com sucesso."


# Caminho do arquivo setup.py
$setupFilePath = "./scripts/netflow/interfaces_routine/config/setup.py"

# Ler o conteúdo do arquivo setup.py
$setupContent = Get-Content -Path $setupFilePath -Raw

# Expressão regular para encontrar a variável CLIENT_ID no formato 'xxxxx-xxxx-xxxx-xxxx-xxxxx'
$regexPattern = "(?m)^CLIENT_ID\s*=\s*'[^']*'"

# Realizar o replace usando a regex
$setupContent = $setupContent -replace $regexPattern, "CLIENT_ID = '$novoValor'"

# Escrever o conteúdo modificado de volta para o arquivo setup.py
$setupContent | Set-Content -Path $setupFilePath

Write-Output "Variável CLIENT_ID no arquivo setup.py modificada com sucesso."

# Instalação de Python3, python3-pip, msql-connector-python e pysnmp

Invoke-Expression -Command "apt-get install -y python3"
Invoke-Expression -Command "apt-get install -y python3-pip"
Invoke-Expression -Command "pip install mysql-connector-python"
Invoke-Expression -Command "pip install pysnmp"

# Desinstalo o pyasn1 e instalo a versão pyasn1 versão 0.4.8 

# Invoke-Expression -Command "pip uninstall pyasn1 -y"
Invoke-Expression -Command "pip install pyasn1==0.4.8"


# Baixar e instalar o Node.js
Write-Output "Instalando NodeJS"
Invoke-WebRequest -Uri "https://nodejs.org/dist/v18.18.1/node-v18.18.1-linux-x64.tar.xz" -OutFile "node-v18.18.1-linux-x64.tar.xz"
tar -xf node-v18.18.1-linux-x64.tar.xz -C /usr/local --strip-components=1
rm node-v18.18.1-linux-x64.tar.xz

# Verificar a versão do Node.js instalada
$versaoNode = node -v
Write-Output "Versão Node $versaoNode"

Write-Output "Instalando npm"
curl -qL https://www.npmjs.com/install.sh | sh

# Baixar e instalar o npm
npm install -g npm@latest

# Verificar a versão do npm instalada
$versaoNpm = npm -v
Write-Output "Versão npm $versaoNpm"

Executa os processos em BackGround, instalado globalmente
npm install pm2 -g

# Mude o diretório para onde o seu script está localizado
Set-Location -Path "./scripts/netflow/interfaces_routine/"

# Agora você pode executar seu script Python
Invoke-Expression -Command "pm2 start 'python3 -m main'"

Invoke-Expression -Command "pm2 startup"

Invoke-Expression -Command "pm2 save"


