function Get-PDK {
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("dev","prod")]
        [string[]]$Environment
    )

    switch ($environment) {
        dev { $credPath = "$PSScriptRoot\..\private\credentials_dev.json" }
        prod { $credPath = "$PSScriptRoot\..\private\credentials.json" }
        Default { $credPath = "$PSScriptRoot\..\private\credentials.json" }
    }

    $configurationEndpoint = "https://accounts.pdk.io/.well-known/openid-configuration"

    $creds = Get-Content $credPath | ConvertFrom-Json
    $global:clientId = $creds.clientId
    $global:clientSecret = $creds.clientSecret
    $global:configuration = Invoke-RestMethod -Method Get -Uri $configurationEndpoint

    $global:authEndpoint = $configuration.authorization_endpoint
    $global:tokenEndpoint = $configuration.token_endpoint

    "clientId=$global:clientId"
    "authorization_endpoint=$global:authEndpoint"
    "token_endpoint=$global:tokenEndpoint"
}

Export-ModuleMember -Function 'Get-PDK'

