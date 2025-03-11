$arquivo = "C:\Users\Administrator\userInativo\lista_demitidos.csv"
$relatorio = "C:\Users\Administrator\userInativo\demitidos.txt"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) { 
    Write-Host "Módulo Active Directory não encontrado. Programa encerrado."
    exit 
}

$demitidos = Import-Csv -Path $arquivo -Delimiter ";"

if (Test-Path $relatorio) {
    Remove-Item $relatorio
}

$demitidos | ForEach-Object {
    $nomeUsuario = $_.Nome
    $grupoUsuario = $_.Grupo
    $user = Get-ADUser -Filter {SamAccountName -eq $nomeUsuario} -Properties MemberOf, Enabled
    if ($user) {

        if ($user.Enabled) {
            Disable-ADAccount -Identity $user
            $user.MemberOf | ForEach-Object { 
                Remove-ADGroupMember -Identity $_ -Members $user -Confirm:$false 
            }

            $logEntry = [PSCustomObject]@{
                Usuario = $nomeUsuario
                Status = "Desativado"
                Data = Get-Date
                Grupo = $grupoUsuario
            }

            $logEntry | Export-Csv -Path $relatorio -Append -NoTypeInformation
            Write-Host "O usuario $nomeUsuario foi desativado e removido dos grupos."
        }
        else {
            Write-Host "O usuario $nomeUsuario ja foi desativado e removido dos grupos."
        }
    }
    else {
        Write-Host "O usuario $nomeUsuario nao foi encontrado no Active Directory."
    }
}
Write-Host "Programa executado com sucesso. Salvo em $relatorio."