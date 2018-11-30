function Get-ADP ($EmployeeId) {

    if (!$global:ADP){

        $global:ADP = Import-Csv C:\DataSources\NCHS_RES_Automation.csv
    }
    
    if ($EmployeeId){
        $adpObject = $global:ADP | Where-Object {$_.ParticipantFeedId -eq $EmployeeId}
    }
    else{
        $lastname = Read-Host "Lastname"
        $firstname = Read-Host "Firstname"
        if ($firstname -and $lastname){
            $adpObject = $global:ADP | Where-Object {$_.FirstName -eq $FirstName -and $_.LastName -eq $LastName}
        }
        else{
            $adpObject = $global:ADP | Where-Object {$_.LastName -eq $LastName}
        }
    }

    return $adpObject
}


function Search-ADP {
    param (
        [string]$EmployeeId,
        [string]$FirstName,
        [string]$LastName,
        $PDKUser,
        [switch]$Interactive,
        [switch]$Verbose
    )

    if ($Verbose) {
        $OldVerbose = $VerbosePreference
        $VerbosePreference = "continue"
    }
    
    if (!$Global:ADP) {
        $Global:ADP = Import-Csv C:\DataSources\NCHS_RES_Automation.csv | Select-Object ParticipantFeedId,FirstName,MiddleName,LastName,Email,HireDate,LocationGroup,DepartmentGroup,JobClassGroup,ReportsToGroup,JobTitleGroup,'Position Status','Termination Date' | Sort-Object -Unique -Property ParticipantFeedId
    }

    if ($EmployeeId){
        $adpObject = $ADP | Where-Object {$_.ParticipantFeedID -eq $EmployeeId} | Select-Object -First 1
    }
    elseif (!$EmployeeId) {

            $foundOnFirstName = $false

            $adpObject = $ADP | Where-Object {$_.FirstName -eq $FirstName -and $_.LastName -eq $LastName}

            if (!$adpObject) {

                $adpObject = $ADP | Where-Object {$_.LastName -eq $LastName}

                if (!$adpObject) {
                    $adpObject = $ADP | Where-Object {$_.FirstName -eq $FirstName}

                    if ($adpObject){

                        $foundOnFirstName = $true
                    }
                }

            }
    }

    if (!$adpObject) {

        Write-Verbose "No object found in ADP for: $FirstName $LastName"

        if ($Interactive) {
            Write-Host "No objects found in ADP that match: $FirstName $LastName" -ForegroundColor White
            $Description = $PDKUser.cards.description | Select-Object -First 1

            $PDKUserRecord = @"
=================================================
PDK Panel            : $($PDKUser.panelName)
FirstName            : $($PDKUser.firstName)
LastName             : $($PDKUser.lastName)
Decription           : $($Description)
Current Employee ID  : $($PDKUser.employeeId)
=================================================

"@
            $Menu = @{}
            $Item = 1
            Write-Host $PDKUserRecord -ForegroundColor White
            $Requery = $Item
            Write-Host "$Item`.) Provide new query`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "Provide new query")
            $Item++
            $Provide = $Item
            Write-Host "$Item`.) Provide employee number`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "Provide employee number")
            $Item++
            $NotEmployee = $Item
            Write-Host "$Item`.) Not an employee`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "Not an employee")
            $Item++
            $NoSelection = $Item
            Write-Host "$Item`.) No Selection`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "No Selection")

            [int]$Answer = Read-Host "Please select the above options"

            if ($Answer -eq $NotEmployee) {
                Write-Host "Marking PDK User $FirstName $LastName as not an employee" -ForegroundColor Green
                $EmployeeId = "Not an employee"
            }
            elseif ($Answer -eq $NoSelection) {
                Write-Host "Not assigning any EmployeeId to PDK User $FirstName $LastName" -ForegroundColor Red
                $EmployeeId = $null
            }
            elseif ($Answer -eq $Provide) {
                $EmployeeId = Read-Host "Please enter in employee Id"
                $adpObject = Get-ADP -EmployeeId $EmployeeId
                Write-Host "Assigning $EmployeeID to PDK User $FirstName $LastName" -ForegroundColor Green
            }
            elseif ($Answer -eq $Requery) {
                $adpObject = Get-ADP
            }

            
        }
        elseif (!$Interactive) {
            Write-Verbose "Not assigning any EmployeeId to PDK User $FirstName $LastName"
        }
        
    }
    if ($foundOnFirstName) {
        Write-Verbose "$($adpObject.count) objects found in ADP that match: $FirstName $LastName"
        if ($Interactive) {
            Write-Host "$($adpObject.count) objects found in ADP that match: $FirstName $LastName" -ForegroundColor White
            $Description = $PDKUser.cards.description | Select-Object -First 1

            $PDKUserRecord = @"
=================================================
PDK Panel            : $($PDKUser.panelName)
FirstName            : $($PDKUser.firstName)
LastName             : $($PDKUser.lastName)
Decription           : $($Description)
Current Employee ID  : $($PDKUser.employeeId)
=================================================

"@
            
            $Menu = @{}
            $Item = 1
            Write-Host $PDKUserRecord -ForegroundColor White
            foreach ($Object in $adpObject){
                $Record = @"
$Item`.) $($object.FirstName) $($object.LastName):
        Department  : $($Object.DepartmentGroup)
        JobTitle    : $($Object.JobTitleGroup)
        JobClass    : $($Object.JobClassGroup)
        Location    : $($Object.LocationGroup)
        EmployeeID  : $($Object.ParticipantFeedId)
        Status      : $($Object.'Position Status')
-------------------------------------------------
"@
                Write-Host $Record -ForegroundColor White
                $Menu.Add($Item, "$($object.FirstName) $($object.LastName)")
                $Item++
            }

            $Requery = $Item
            Write-Host "$Item`.) Provide new query`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "Provide new query")
            $Item++
            $Provide = $Item
            Write-Host "$Item`.) Provide employee number`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "Provide employee numbe")
            $Item++
            $NotEmployee = $Item
            Write-Host "$Item`.) Not an employee`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "Not an employee")
            $Item++
            $NoSelection = $Item
            Write-Host "$Item`.) No Selection`n-------------------------------------------------" -ForegroundColor White
            $Menu.Add($Item, "No Selection")


            [int]$Answer = Read-Host "Please select the above options"

            if ($Answer -eq $NotEmployee) {
                Write-Host "Marking PDK User $FirstName $LastName as not an employee" -ForegroundColor Green
                $EmployeeId = "Not an employee"
            }
            elseif ($Answer -eq $NoSelection) {
                Write-Host "Not assigning any EmployeeId to PDK User $FirstName $LastName" -ForegroundColor Red
                $EmployeeId = $null
            }
            elseif ($Answer -eq $Provide) {
                $EmployeeId = Read-Host "Please enter in employee Id"
                $adpObject = Get-ADP -EmployeeId $EmployeeId
                Write-Host "Assigning $EmployeeID to PDK User $FirstName $LastName" -ForegroundColor Green
            }
            elseif ($Answer -eq $Requery) {
                $adpObject = Get-ADP
            }
            else {
                $Selection = $Answer - 1
                $EmployeeId = $adpObject[$Selection].ParticipantFeedId
                Write-Host "Assigning $EmployeeID to PDK User $FirstName $LastName" -ForegroundColor Green
            }
        }
        elseif (!$Interactive) {
            Write-Verbose "Not assigning any EmployeeId to PDK User $FirstName $LastName"
        }
    }
    elseif (!$EmployeeId -and $adpObject.ParticipantFeedId){
            $EmployeeId = $adpObject.ParticipantFeedId
            Write-Verbose "Found ADP object with employee id $EmployeeID for: $FirstName $LastName"
    }

    $VerbosePreference = $OldVerbose
    return $EmployeeId
}

#Export-ModuleMember -Function Get-ADP,Search-ADP