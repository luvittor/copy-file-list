# Obter o caminho do diretório onde o script está localizado
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Caminho para o arquivo .env (na mesma pasta do script)
$envFilePath = Join-Path -Path $scriptDir -ChildPath ".env"

Write-Output "Lendo parâmetros do arquivo .env em: $envFilePath"

# Carregar os parâmetros do arquivo .env
$parameters = @{
    FILE_LIST_PATH = ""
    SOURCE_DIR = ""
    DESTINATION_DIR = ""
}

Get-Content $envFilePath | ForEach-Object {
    if ($_ -match "^\s*([^#;].*?)\s*=\s*(.*?)\s*$") {
        $key = $matches[1]
        $value = $matches[2]
        if ($parameters.ContainsKey($key)) {
            # Converter o caminho relativo para absoluto, se necessário
            $parameters[$key] = (Resolve-Path -Path (Join-Path -Path $scriptDir -ChildPath $value)).Path
            Write-Output "Parâmetro carregado: $key = $($parameters[$key])"
        }
    }
}

# Usar os parâmetros carregados
$fileListPath = $parameters['FILE_LIST_PATH']
$sourceDir = $parameters['SOURCE_DIR']
$destinationDir = $parameters['DESTINATION_DIR']

Write-Output "Iniciando processo de cópia dos arquivos..."
Write-Output "Lista de arquivos: $fileListPath"
Write-Output "Diretório de origem: $sourceDir"
Write-Output "Diretório de destino: $destinationDir"

# Verificar se a pasta de destino existe; se não, criar
if (!(Test-Path -Path $destinationDir)) {
    Write-Output "Pasta de destino não existe. Criando: $destinationDir"
    New-Item -Path $destinationDir -ItemType Directory -Force
} else {
    Write-Output "Pasta de destino já existe: $destinationDir"
}

# Ler cada linha do arquivo de lista
Get-Content $fileListPath | ForEach-Object {
    # Combina o caminho da origem com o caminho relativo do arquivo
    $sourceFilePath = Join-Path -Path $sourceDir -ChildPath $_

    # Cria o caminho da nova pasta e subpasta no destino
    $destinationFilePath = Join-Path -Path $destinationDir -ChildPath $_

    # Cria a estrutura de diretórios necessária
    $destinationDirPath = Split-Path -Parent $destinationFilePath
    if (!(Test-Path -Path $destinationDirPath)) {
        Write-Output "Criando diretório: $destinationDirPath"
        New-Item -Path $destinationDirPath -ItemType Directory -Force
    }

    # Copia o arquivo para o destino, mantendo a estrutura
    Write-Output "Copiando arquivo: $sourceFilePath -> $destinationFilePath"
    Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Force
}

Write-Output "Processo de cópia concluído!"
