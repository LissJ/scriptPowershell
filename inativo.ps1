# Definir parâmetros
$diasInatividade = 90
$dataLimite = (Get-Date).AddDays(-$diasInatividade)
$caminhoArquivoCSV = "C:\Users\Administrator\userDesabilitado\usuarioDesativado.csv"
$caminhoRelatorio = "C:\Users\Administrator\userDesabilitado\usuarioDesativado_log.csv"
$acaoConta = "Desativar"  # "Remover" para excluir

# Criar diretório se necessário
If (!(Test-Path "C:\Users\Administrator\userDesabilitado")) { 
    New-Item -ItemType Directory -Path "C:\Users\Administrator\userDesabilitado" | Out-Null
    Write-Host "Diretório criado."
}

# Importar CSV e buscar contas inativas
$usuariosCSV = Import-Csv -Path $caminhoArquivoCSV -Delimiter ";"
Write-Host "Arquivo CSV importado."

$contasInativas = Get-ADUser -Filter {LastLogonDate -lt $dataLimite -and Enabled -eq $true} -Properties LastLogonDate
Write-Host "$($contasInativas.Count) contas inativas encontradas."

# Gerar relatório e desativar/remover contas inativas
$contasInativas | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $caminhoRelatorio -NoTypeInformation -Append
foreach ($conta in $contasInativas) {
    If ($acaoConta -eq "Desativar") { 
        Disable-ADAccount -Identity $conta.SamAccountName
        Write-Host "Conta desativada: $($conta.SamAccountName)"
    } ElseIf ($acaoConta -eq "Remover") { 
        Remove-ADUser -Identity $conta.SamAccountName -Confirm:$false
        Write-Host "Conta removida: $($conta.SamAccountName)"
    }
}

# Processar usuários do CSV
$usuariosCSV | ForEach-Object {
    $user = Get-ADUser -Filter {SamAccountName -eq $_.Nome} -Properties SamAccountName, Enabled
    If ($user -and $user.Enabled) { 
        Disable-ADAccount -Identity $user
        Write-Host "Conta desativada: $($_.Nome)"
    }
}

# Enviar notificação por e-mail
Send-MailMessage -To "admin@dominio.local" -From "notificacoes@dominio.local" -Subject "Relatório de Contas Inativas" -Body "Contas inativas processadas." -SmtpServer "smtp.dominio.local" -Attachments $caminhoRelatorio
Write-Host "Notificação por e-mail enviada."

Write-Host "Processo concluído."
