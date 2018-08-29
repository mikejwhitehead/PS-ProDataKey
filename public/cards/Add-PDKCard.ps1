function Add-PDKCard {
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
        # Your PDK User Id
        [Parameter(Mandatory = $true)]
        [int]
        $PDKUserId,
        # Your PDK Card Number
        [Parameter(Mandatory=$true)]
        [int]
        $PDKCardNumber,
        # A description for your PDK Card
        [Parameter(Mandatory=$true)]
        [string]
        $PDKCardDescription
    )

    if (!$PDKPanelSession){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($PDKPanelSession.id -ne $PDKPanelId){
        $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKCardObject = @{
        cardNumber = $PDKCardNumber
        description = $PDKCardDescription
    }

    $PDKCardObject = $PDKCardObject | ConvertTo-Json
    $PDKCardEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)/cards"
    
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKCardObject = Invoke-WebRequest -Method Post -Uri $PDKCardEndpoint -Headers $Headers -ContentType "application/json" -Body $PDKCardObject
    $PDKPanelSession = $null
    Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId
}

Export-ModuleMember -Function 'Add-PDKCard'