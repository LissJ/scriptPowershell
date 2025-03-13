$csv = "C:\Users\Administrator\usuariosGerados\lista_usuarios.csv"
$senha = ConvertTo-SecureString "senhaPadrao123!" -AsPlainText -Force
$dominio = "hostname.unique"
$ouUsuarios = "OU=Usuarios,DC=hostname,DC=unique"
$ouGrupos = "OU=Grupos,DC=hostname,DC=unique"

Import-Csv -Path $csv -Delimiter ";" | ForEach-Object {
    $nome = $_.Nome
    $grupo = $_.Grupo
    $UPN = "$nome@$dominio"

    # criando um usuário, se não existir
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$nome'" -ErrorAction SilentlyContinue)) {
        Write-Host "Criando usuario: $nome"
        New-ADUser -Name $nome -SamAccountName $nome -UserPrincipalName $UPN `
                   -AccountPassword $senha -Enabled $true -PasswordNeverExpires $false `
                   -Path $ouUsuarios

        Set-ADUser -Identity $nome -ChangePasswordAtLogon $true
        Write-Host "Usuario $nome criado e senha forçada para alteracao no primeiro login."
    } else {
        Write-Host "Usuario $nome ja existe."
    }

    # criando um grupo, se não existir
    if (-not (Get-ADGroup -Filter "Name -eq '$grupo'" -ErrorAction SilentlyContinue)) {
        Write-Host "Criando grupo: $grupo"
        New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security -Path $ouGrupos
        Write-Host "Grupo $grupo criado."
    }

    # adicionando o usuário ao grupo criado
    if (-not (Get-ADGroupMember -Identity $grupo | Where-Object { $_.SamAccountName -eq $nome })) {
        Add-ADGroupMember -Identity $grupo -Members $nome
        Write-Host "Usuario $nome adicionado ao grupo $grupo."
    } else {
        Write-Host "Usuario $nome ja faz parte do grupo $grupo."
    }
}
