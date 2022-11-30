#Requires -Version 7

Begin {
    $ErrorActionPreference = 'stop'
}

Process {
    if ($null -eq (Get-Command "mkcert" -ErrorAction SilentlyContinue)) {
        Write-Error "mkcert must be installed first: https://github.com/FiloSottile/mkcert"
        Exit
    }

    $caDir = "$(mkcert -CAROOT)"
    $caCrtPath = Join-Path $caDir "rootCA.pem"
    $caKeyPath = Join-Path $caDir "rootCA-key.pem"

    # Copy mkcert CA root certificate to this directory
    Copy-Item $caCrtPath $PSScriptRoot -Verbose -Force -ErrorAction Stop
    Copy-Item $caKeyPath $PSScriptRoot -Verbose -Force -ErrorAction Stop

    Write-Host -ForegroundColor Green "mkcert CA root certificate has been copied, you can install the chart now"
}
