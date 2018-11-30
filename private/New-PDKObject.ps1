function New-PDKCardObject ($PanelId,$PanelName,$Id,$FirstName,$LastName,[string[]]$CardNumber,$EmployeeID,$Enabled){
    $Cards = @()
    foreach ($Card in $CardNumber){
        $CardProps = @{
            panelId=$PanelId
            panelName=$PanelName
            id=$Id
            firstName=$FirstName
            lastName=$LastName
            cardNumber=$Card
            employeeId=$EmployeeID
            enabled=$Enabled
        }

        $Cards += New-Object psobject  -Property $CardProps
    }

    return $Cards
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