# TASK:  "pwsh -NoProfile -ExecutionPolicy Bypass -File 'C:\dev\pwsh-edu-graph\src\private\Scripts\UploadDadosAD.ps1.ps1' -LogResults"
Import-Module 'C:\dev\pwsh-edu-graph\pwsh-edu-graph.psm1'
New-GraphUploadSession | Invoke-LargeItemUpload