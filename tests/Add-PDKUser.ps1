Remove-Module *
Remove-Variable * -ErrorAction 'Ignore'
Import-Module .\PS-ProDataKey.psm1

$PDKClientId = '5b60600f9f83fc6c36cf1021'
$PDKClientSecret = 'AO1cXvXq7dFKPy3Haw4edWfNpuDj5omy'
$PDKPanelId = '1070DLI'

$FirstName = "Mike"
$LastName = "Whitehead"


$PDKUser = Add-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -FirstName $FirstName -LastName $LastName -ExpiryDate (Get-Date).AddDays(30) -Pin 1234

$PDKUser = Add-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -FirstName $FirstName -LastName $LastName -Pin "4321" -ActiveDate "2018-08-20" -ExpiryDate "2018-08-25"
$PDKUser
# Update User (All Fields)
Update-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -FirstName $FirstName -LastName $LastName -Pin "1234" -ActiveDate ("2018-08-20" -as [datetime]) -ExpiryDate ("2018-08-25" -as [datetime]) -PDKUserId $PDKUser.Id -Enabled $false

# Enable User
Update-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUser.id -Enabled $true

# Disable User
Update-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUser.id -Enabled $false

# Change Firstname
Update-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -FirstName Sam -PDKUserId $PDKUser.id

# Change Lastname
Update-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -LastName Sam -PDKUserId $PDKUser.id

# Remove User
Remove-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUser.id

# Get User
$users = Get-PDKUsers -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId



