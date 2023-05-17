class ConnectionHandler {
    hidden static [string]$ClientID    = "2dce1e51-cb98-4336-b8ea-101045dd55c1"
    hidden static [string]$TenantID    = "33bb8434-a5cd-4507-a3f3-c4a3aee13daf"
    hidden static [string]$SecretValue = "~2.8Q~RiMRp0QB7mG4DB23U49oInSV6ATfpHoaTQ"

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
