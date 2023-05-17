# Configurar Ambiente
- Tarefas correm em PowerShellVersion = '5.1.0'
- O Módulo ActiveDirectory apenas corre em windows server 2016.
- A utilizar Powershell 7.0.0 ou acima, apenas em windows server 2019.

## Módulos Compilados
> Install-Module Microsoft.PowerShell.SecretManagement,Microsoft.PowerShell.SecretStore

## Secret Vault/Store
- Cofre guarda credenciais da conta $username, a qual corre as tarefas agendadas.
- Registar o vault
> Register-SecretVault -Name credenciais -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

- Registar os secrets
> Set-Secret** -Name 'Secret' -Secret (Read-Host -AsSecureString)
Set-Secret** -Name 'Secret' -Secret (Read-Host -AsSecureString)

- Recuperar o secret
> Get-Secret -Name 'Secret' -AsPlainText TestSecret

