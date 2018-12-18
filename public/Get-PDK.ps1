function Get-PDK {
    $configurationEndpoint = "https://accounts.pdk.io/.well-known/openid-configuration"

    $global:configuration = Invoke-RestMethod -Method Get -Uri $configurationEndpoint
    return $global:configuration
}

Export-ModuleMember -Function 'Get-PDK'

