function Remove-PDKCard {
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
        # A PDK Panel Web Session Object
        [Parameter(Mandatory = $false)]
        [psobject]
        $PDKPanelSession
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

    $PDKUser = Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKPanelSession $PDKPanelSession
    $PDKCardId = ($PDKUser.cards | Where-Object {$_.cardNumber -eq $PDKCardNumber}).id

    $PDKCardObject = $PDKCardObject | ConvertTo-Json
    $PDKCardEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)/cards/$($PDKCardId)"
    
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }
    $ErrorActionPreference = "SilentlyContinue"
    $PDKCardObject = Invoke-WebRequest -Method Delete -Uri $PDKCardEndpoint -Headers $Headers -ContentType "application/json" -UseBasicParsing
    $ErrorActionPreference = "Stop"
    $PDKPanelSession = $null
    Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId -PDKPanelSession $PDKPanelSession
}

Export-ModuleMember -Function 'Remove-PDKCard'