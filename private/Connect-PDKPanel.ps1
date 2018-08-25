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
    $PDKSession = (Invoke-WebRequest -Uri $PDKTokenEndpoint -ContentType 'application/x-www-form-urlencoded' -Headers @{Authorization = $BasicAuth} -Method Post -Body $Body).Content | ConvertFrom-Json
    $PDKSession | Add-Member -MemberType NoteProperty -Name 'expires_at' -Value (Get-Date).AddSeconds($PDKSession.expires_in)

    # Get PDK Panel Token
    $PDKPanelToken = (Invoke-WebRequest -Method Post -Uri "https://accounts.pdk.io/api/panels/$PDKPanelId/token" -Headers @{Authorization = "Bearer $($PDKSession.id_token)"} -ContentType 'application/x-www-form-urlencoded').Content | ConvertFrom-Json

    $Headers = @{
        "Authorization"="Bearer $($PDKSession.id_token)"
    }
    # Get PDK Panel
    $PDKPanel = Invoke-RestMethod -Method Get -Uri "https://accounts.pdk.io/api/panels/$PDKPanelId" -Headers $Headers | Select-Object *,@{N="panel_token";E={$PDKPanelToken.token}}
    $PDKPanelAttributes = $PDKPanel.PSObject.Properties | Where-Object {$_.MemberType -eq 'NoteProperty'} | Select-Object Name,MemberType
    foreach ($Attribute in $PDKPanelAttributes){
        $PDKSession | Add-Member -MemberType $Attribute.MemberType -Name $Attribute.Name -Value $PDKPanel.$($Attribute.Name)
    }

    $PDKSession
}

Export-ModuleMember -Function 'Connect-PDKPanel'
