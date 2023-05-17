class ConnectionHandler {
    hidden static [string]$ClientID    = ""
    hidden static [string]$TenantID    = ""
    hidden static [string]$SecretValue = ""

# default constructor
ConnectionHandler () {}

# constructor
ConnectionHandler (
        [string]$ID,
        [string]$Secret,
        [string]$Tenant
    ){
        $this.ClientID = $ID
        $this.SecretValue = $Secret
        $this.TenantID = $Tenant
    }

static [hashtable] Connect() {
      $tokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        Client_Id     = [ConnectionHandler]::ClientID
        Client_Secret = [ConnectionHandler]::SecretValue
      }
      $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$([ConnectionHandler]::TenantID)/oauth2/v2.0/token" -Method POST -Body $tokenBody
      [pscustomobject]$headers = @{
        "Authorization" = "Bearer $($tokenResponse.access_token)"
        "Content-type"  = "application/json"
      }
      return $headers
    }
}
