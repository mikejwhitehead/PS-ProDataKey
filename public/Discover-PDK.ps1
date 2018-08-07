function Discover-PDK {
$configurationEndpoint = "https://accounts.pdk.io/.well-known/openid-configuration"

$global:configuration = Invoke-RestMethod -Method Get -Uri $configurationEndpoint

$global:authEndpoint = $configuration.authorization_endpoint
$global:tokenEndpoint = $configuration.token_endpoint
}

Export-ModuleMember -Function 'Discover-PDK'

