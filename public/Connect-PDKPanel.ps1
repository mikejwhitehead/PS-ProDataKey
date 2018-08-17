function Connect-PDKPanel {
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
        $PDKPanelId
    )

    # Generate Authorization Header
    $BasicAuth = "Basic " + ([System.Convert]::ToBase64String(([System.Text.Encoding]::ASCII.GetBytes("${PDKClientId}:${PDKClientSecret}"))))

    # PDK Authentication Request Payload
    $Body = @{
    "grant_type" = "client_credentials"
    }

    # PDK Token Endpoint
    $PDKTokenEndpoint = 'https://accounts.pdk.io/oauth2/token'

    # Get ID and Access token from PDK
    $PDKSession = Invoke-RestMethod -Uri $PDKTokenEndpoint -ContentType 'application/x-www-form-urlencoded' -Headers @{Authorization = $BasicAuth} -Method Post -Body $Body

    # Get PDK Panel Token
    $PDKPanelToken = Invoke-RestMethod -Method Post -Uri "https://accounts.pdk.io/api/panels/$PDKPanelId/token" -Headers @{Authorization = "Bearer $($PDKSession.id_token)"} -ContentType 'application/x-www-form-urlencoded'

    $Headers = @{
        "Authorization"="Bearer $($PDKSession.id_token)"
    }
    # Get PDK Panel
    $PDKPanel = Invoke-RestMethod -Method Get -Uri "https://accounts.pdk.io/api/panels/$PDKPanelId" -Headers $Headers
    $Headers = @{
        "Authorization"="Bearer $($PDKPanelToken.token)"
    }

    # Set Global PDK Panel Session variable
    $PDKPanel | Select-Object *,@{N="token";E={$PDKPanelToken.token}} | Set-Variable -Name PDKPanelSession -Scope Global
}

Export-ModuleMember -Function 'Connect-PDKPanel'

