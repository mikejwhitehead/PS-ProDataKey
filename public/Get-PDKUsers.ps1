function Get-PDKUsers {
    Param(
        # Your PDK ClientId
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientSecret
    
        )
    # Generate Authorization Header
    Connect-PDK -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret
    if (!$Global:PDKSession){
        "Could not connect to PDK"
    }

 
  
        # PDK Person Endpoint
        $PDKPersonEndpoint = "$($PDKPanel.uri)api/persons/9"
    
        # Get Persons from PDK
        $PDKPersons = Invoke-RestMethod -Uri $PDKPersonEndpoint -ContentType 'application/json' -Headers $Headers -Method Get

        $PDKPersons

}