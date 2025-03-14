# criar usuários e grupos no powershell

### definindo variáveis
```
ConvertTo-SecureString
-AsPlainText
-Force
```
- o comando __ConvertTo-SecureString__ faz com que a senha seja convertida em um formato de string seguro;
- o comando __-AsPlainText__ informa que a senha será inserida em formato de texto;
- e o comando __-Force__ autoriza a conversão da senha, sem a necessidade de alguma autorização.
```
$dominio = "hostname.unique"
$ouUsuarios = "OU=Usuarios,DC=hostname,DC=unique"
$ouGrupos = "OU=Grupos,DC=hostname,DC=unique"
```
- a variável __dominio__ define o dominio que os usuários gerados irão pertencer
- a variável __ouUsuarios__ define a unidade organizacional (OU) que os usuários gerados irão pertencer
- a variável __ouGrupos__ define a unidade organizacional (OU) que os grupos gerados irão pertencer
