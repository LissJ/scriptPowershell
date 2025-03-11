$arquivoUsuarios = "C:\Users\Administrator\usuariosGerados\lista_usuarios.csv"
$SPadrao = "senhaPadrao123!"
$dominio = "hostname.unique" 

$usuarios = Import-Csv -Path "C:\Users\Administrator\usuariosGerados\lista_usuarios.csv" -Delimiter ";"
$usuarios | ForEach-Object { Write-Host "Usuario encontrado: $($_.Nome), Grupo: $($_.Grupo)" }


foreach ($usuario in $usuarios) {
    $SamAccountName = $usuario.Nome
    $UPN = "$SamAccountName@$dominio"
    $grupo = $usuario.Grupo

    if (-not (Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $usuario.Nome `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UPN `
                   -AccountPassword (ConvertTo-SecureString $SPadrao -AsPlainText -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -Path "CN=Computers,DC=hostname,DC=unique"
    } else {
        Write-Host "O usuario $SamAccountName ja existe. Proximo..."
    }

    if (-not (Get-ADGroup -Filter {Name -eq $grupo} -ErrorAction SilentlyContinue)) {
         New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security -Path "CN=Computers,DC=hostname,DC=unique"
         Write-Host "Grupo $grupo criado."
    }


    Add-ADGroupMember -Identity $grupo -Members $SamAccountName
    Write-Host "O usuario $SamAccountName foi adicionado ao grupo $grupo."
}