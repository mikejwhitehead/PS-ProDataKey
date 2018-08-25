
Remove-Variable * -ErrorAction 'SilentlyContinue'
Import-Module .\PS-ProDataKey.psm1

$PDKClientId = '5b60600f9f83fc6c36cf1021'
$PDKClientSecret = 'AO1cXvXq7dFKPy3Haw4edWfNpuDj5omy'
#$PDKPanelId = '1070DLI'

$PDKPanels = (Import-Csv 'C:\Users\mike.whitehead\Desktop\PDK - Panel IDs.csv').PanelID
#$PDKPanels = $PDKPanels[0..1]
#$PDKPanelId = $PDKPanels

$PDKUsers = Get-PDKUsers -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanels

Remove-Module *

#$AllCards = @()
$PDKGroupMemberships = @()

foreach ($PDKUser in $PDKUsers)
{
    foreach ($Card in $PDKUser.cards){

        foreach ($Group in $PDKUser.groups){
            $GroupProps = @{
                "firstName"=$PDKUser.firstName
                "lastName"=$PDKUser.lastName
                "enabled"=$PDKUser.enabled
                "partition"=$PDKUser.partition
                "panelName"=$Card.panelName
                "panelId"=$Card.panelId
                "description"=$Card.description
                "cardNumber"=$Card.cardNumber
                "email"=$PDKUser.email
                "employeeID"=$PDKUser.employeeID
                "groupId"="$($Card.panelId)-$($Group.id)"
                "groupName"=$Group.name
                "groupPath"="$($Card.panelName)\$($Group.name)"
            }
               
    
            $GroupObject = New-Object psobject -Property $GroupProps
            $PDKGroupMemberships += $GroupObject
        }
    }
}    

#$Cards = $PDKUsers | Select-Object id,firstName,lastName,enabled,panelName,panelId,@{N="cardNumber";E={$_.cards.cardNumber}},@{N='description';E={$_.cards.description}}
#$PDKGroupMemberships | Where-Object {$_.lastName -like '*Sanders*'} | ForEach-Object {$_.userEmployeeID="X24004120"}
$PDKUsers | Export-Csv -Path D:\Development\pdkusers.csv -NoTypeInformation -Force
$PDKGroupMemberships | Export-Csv -Path D:\Development\pdkgroupmemberships.csv -NoTypeInformation -Force

$PDKGroups = $PDKGroupMemberships | Select-Object groupId,groupName,groupPath,panelId,panelName | sort-object -Property groupId -Unique
$PDKGroups | Export-Csv -Path D:\Development\pdkgroups.csv -NoTypeInformation -Force




