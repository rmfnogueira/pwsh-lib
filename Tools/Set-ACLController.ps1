function Set-ACLController {
    #Propagation Options --> [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
   #Type Options --> [enum]::GetValues('System.Securit y.AccessControl.AccessControlType')
   #╔═════════════╦═════════════╦═══════════════════════════════╦════════════════════════╦══════════════════╦═══════════════════════╦═════════════╦═════════════╗
   #║             ║ folder only ║ folder, sub-folders and files ║ folder and sub-folders ║ folder and files ║ sub-folders and files ║ sub-folders ║    files    ║
   #╠═════════════╬═════════════╬═══════════════════════════════╬════════════════════════╬══════════════════╬═══════════════════════╬═════════════╬═════════════╣
   #║ Propagation ║ none        ║ none                          ║ none                   ║ none             ║ InheritOnly           ║ InheritOnly ║ InheritOnly ║
   #║ Inheritance ║ none        ║ Container|Object              ║ Container              ║ Object           ║ Container|Object      ║ Container   ║ Object      ║
   #╚═════════════╩═════════════╩═══════════════════════════════╩════════════════════════╩══════════════════╩═══════════════════════╩═════════════╩═════════════╝
   #
   #$path PARAM
   #
   #
   # Get ACL 
   #Rights Options --> [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
   #Inheritance Options --> [enum]::GetValues('System.Security.AccessControl.Inheritance')
   param (
   
   )
   $ACL = Get-Acl -Path $path

   # Create the ACE
   $identity = 'domain\contoso'
   $rights = 'FullControl'
   $inheritance = 'ContainerInherit, ObjectInherit'
   $propagation = 'InheritOnly'
   $type = 'Allow'

   # Create New Rule
   $ACE = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$rights,$inheritance,$propagation,$type)

   #Foreach Object append new ace object entry
   $ACL.ForEach({$_.AddAccessRule($ACE)})

   #Foreach Object set New ACL
   $ACL | %{Set-Acl -Path $_.Path -AclObject $_}
}#Set-ACLController -> TODO: Params
