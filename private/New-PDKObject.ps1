function New-PDKCardObject ($PanelId,$PanelName,$Id,$FirstName,$LastName,$Cards,$EmployeeID,$Enabled){
    $CardsObject = @()
    foreach ($Card in $Cards){
        $CardProps = @{
            panelId=$PanelId
            panelName=$PanelName
            id=$Id.ToString()
            firstName=$FirstName
            lastName=$LastName
            cardNumber=$Card.cardNumber
            cardDescription=$Card.description
            employeeId=$EmployeeID
            enabled=$Enabled
        }

        $CardsObject += New-Object psobject  -Property $CardProps
    }

    return $CardsObject
}


function New-PDKGroupObject ($PanelId,$PanelName,$Id,$FirstName,$LastName,$Groups,$EmployeeID,$Enabled){

    $GroupProps = @{
        panelId=$PanelId
        panelName=$PanelName
        id=$Id
        firstName=$FirstName
        lastName=$LastName
        groupId=$Groups.id -join ','
        groupName=$Groups.name -join ','
        employeeId=$EmployeeID
        enabled=$Enabled
    }

    $GroupsObject = New-Object psobject -Property $GroupProps

    return $GroupsObject
}

#Export-ModuleMember -Function 'New-PDKGroupObject','New-PDKCardObject'