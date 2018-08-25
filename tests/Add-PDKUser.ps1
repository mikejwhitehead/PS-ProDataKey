Import-Module .\PS-ProDataKey.psm1

$PDKClientId = '5b60600f9f83fc6c36cf1021'
$PDKClientSecret = 'AO1cXvXq7dFKPy3Haw4edWfNpuDj5omy'
$PDKPanelId = '1070DLI'

$FirstName = "Test"
$LastName = "User2"


$PDKUser = Add-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -FirstName $FirstName -LastName $LastName -Pin "1234" -ActiveDate "2018-08-20" -ExpiryDate "2018-08-25"