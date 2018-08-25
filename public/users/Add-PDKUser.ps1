function Add-PDKUser {
    Param(
        # Your PDK ClientId
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(Mandatory = $true)]
        [string]
        $PDKClientSecret,
        # Your PDK Panel Id
        [Parameter(Mandatory = $true)]
        [string]
        $PDKPanelId,
        # The new users firstname
        [Parameter(Mandatory=$true)]
        [string]
        $FirstName,
        # The new users lastname
        [Parameter(Mandatory=$true)]
        [string]
        $LastName,
        # The users active date (YYYY-MM-DD)
        [Parameter()]
        [datetime]
        $ActiveDate,
        # The users expiry date (YYYY-MM-DD)
        [Parameter()]
        [datetime]
        $ExpiryDate,
        # The users Pin
        [Parameter()]
        [int]
        $Pin,
        # The users duress pin (default is 9 + PIN)
        [Parameter()]
        [int]
        $DuressPin="9" + $Pin,
        # Set the users partiion
        [Parameter()]
        [int]
        $Partition=0
    )

    if (!$Global:PDKPanelSession){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($Global:PDKPanelSession.expires_at).AddSeconds(-5))){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($Global:PDKPanelSession.id -ne $PDKPanelId){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKPersonObject = @"
{
    "firstName": "$FirstName",
    "lastName": "$LastName",
    "partition": $Partition,
    "activeDate": "$($ActiveDate.ToString("yyyy-MM-dd"))",
    "expireDate": "$($ExpiryDate.ToString("yyyy-MM-dd"))",
    "pin": "$Pin",
    "duressPin": "$DuressPin"
}
"@
    $PDKPersonEndpoint = "$($PDKPanelSession.uri)api/persons"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKPersonObject = (Invoke-WebRequest -Method Post -Uri $PDKPersonEndpoint -Headers $Headers -ContentType "application/json" -Body $PDKPersonObject).Content | ConvertFrom-Json
    $Global:PDKPanelSession = $null
    $PDKPersonObject
}

Export-ModuleMember -Function 'Add-PDKUser'