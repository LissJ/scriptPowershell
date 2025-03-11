$diasInatividade = 90
$dataLimite = (Get-Date).AddDays(-$diasInatividade)

$caminhoArquivoCSV = "C:\Users\Administrator\userDesabilitado\usuarioDesativado.csv"

$caminhoRelatorio = "C:\Users\Administrator\userDesabilitado\usuarioDesativado_log.csv"

If (!(Test-Path "C:\Users\Administrator")) {
    New-Item -ItemType Directory -Path "C:\Users\Administrator\userDesabilitado"
}

$usuariosCSV = Import-Csv -Path $CaminhoArquivoCSV -Delimiter ";"

$contasInativas = Get-ADUser -Filter {LastLogonDate -lt $dataLimite -and Enabled -eq $true} -Properties LastLogonDate
if ($contasInativas) {
    $contasInativas | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $caminhoRelatorio -NoTypeInformation -Append
    Write-Host "As contas inativas foram registradas em $caminhoRelatorio"

    foreach ($conta in $contasInativas) {
        # desativando a conta
        Disable-ADAccount -Identity $conta.SamAccountName
        Write-Host "Conta bloqueada: $($conta.SamAccountName)"
    }

    Write-Host "Programa executado com sucesso. As contas inativas foram bloqueadas."
} else {
    Write-Host "Nao existem contas inativas no momento."
}

$contasDesabilitadas = Get-ADUser -Filter {Enabled -eq $false} -Properties SamAccountName, Name

if ($contasDesabilitadas) {
    Write-Host "As contas ja foram desabilitadas:"
    $contasDesabilitadas | Select-Object Name, SamAccountName | Format-Table -AutoSize
} else {
    Write-Host "Nenhuma conta desabilitada foi encontrada."
}

foreach ($usuarioCSV in $usuariosCSV) {
    $nomeUsuario = $usuarioCSV.Nome
    $grupoUsuario = $usuarioCSV.Grupo

    $user = Get-ADUser -Filter {SamAccountName -eq $nomeUsuario} -Properties SamAccountName, Enabled
    if ($user) {
        if ($user.Enabled) {
            Disable-ADAccount -Identity $user
            Write-Host "A conta $nomeUsuario foi desativada."

        } else {
            Write-Host "A conta $nomeUsuario ja esta desativada."
        }
    } else {
        Write-Host "O usuario $nomeUsuario nao encontrado no Active Directory."
    }
}

Write-Host "O processo de desativacao de contas do arquivo CSV concluido. Encerrado"