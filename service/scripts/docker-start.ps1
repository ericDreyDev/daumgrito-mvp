$dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

Write-Host "Iniciando Docker Desktop..."

Start-Process $dockerPath

Write-Host "Aguardando Docker iniciar..."

do {
    Start-Sleep -Seconds 3
    docker info *> $null
} until ($LASTEXITCODE -eq 0)

Write-Host "Docker iniciado com sucesso!"

Write-Host "Subindo containers..."

docker compose up -d

Write-Host "Containers iniciados!"