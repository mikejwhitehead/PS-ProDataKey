function Get-PDKUsers {
    Param(
        # Your PDK ClientId
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKClientSecret,
        # Your PDK Panel Id
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]
        $PDKPanelId
    )

    foreach ($Id in $PDKPanelId){
        $env:PSPDKModulePath = (Get-Module -Name PS-ProDataKey | Select-Object Path).Path

        $Job = {
            $PDKClientId = $args[0]
            $PDKClientSecret = $args[1]
            $PDKPanelId = $args[2]

            if (!$PDKPanelSession){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
            }
            elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
            }
            elseif ($PDKPanelSession.id -ne $PDKPanelId){
                $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
            }
        
            $PDKPersonsEndpoint = "$($PDKPanelSession.uri)api/persons?page=0&per_page=50"
            $Headers = @{
                "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
            }
        
            $PDKPersonsObject = @()
            $PDKPersonsResponse = Invoke-WebRequest -Method Get -Uri $PDKPersonsEndpoint -Headers $Headers -ContentType "application/json"
            $PDKPersonsObjectCount = $PDKPersonsResponse.Headers.'X-Total-Count'
            $PDKPersonsObject += ($PDKPersonsResponse.Content | ConvertFrom-Json)
        
            if ($PDKPersonsResponse.Headers.Link){
                    $Links = @()
                    ($PDKPersonsResponse.Headers.Link -split ',').Trim() | ForEach-Object {
                    $Link = ($_ -split ';')
                    $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                            "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
                    $Links += $Link
                    }
                
                $PDKPersonsNextPage = ($Links | ? {$_.Relation -eq 'next'}).Link
            }
        
            while ($null -ne $PDKPersonsNextPage){
        
                $PDKPersonsResponse = Invoke-WebRequest -Method Get -Uri $PDKPersonsNextPage -Headers $Headers -ContentType "application/json"
                $PDKPersonsObject += ($PDKPersonsResponse.Content | ConvertFrom-Json)
        
                if ($PDKPersonsResponse.Headers.Link){
                    $Links = @()
                    ($PDKPersonsResponse.Headers.Link -split ',').Trim() | ForEach-Object {
                    $Link = ($_ -split ';')
                    $Link = New-Object psobject -Property @{"Link"=((($Link[0]) -replace '<','' -replace '>','')).Trim()
                                                            "Relation"=(($Link[1]) -replace "rel=`"","" -replace "`"","").Trim()}
                    $Links += $Link
                    }
                
                $PDKPersonsNextPage = ($Links | ? {$_.Relation -eq 'next'}).Link
                }
        
                else {$PDKPersonsNextPage = $null}
            }
        
            $PDKPersonsObject = $PDKPersonsObject | Select-Object *,@{N="panelName";E={$PDKPanelSession.name}},@{N="panelId";E={$PDKPanelSession.id}},@{N="uri";E={"$($PDKPanelSession.uri)api/persons/$($_.id)"}}
            
            if ($PDKPersonsObject.Count -ne $PDKPersonsObjectCount){
            
                throw "Failed to query all users from PDK panel $PDKPanelId"
        
            }
                
            foreach ($PDKPerson in $PDKPersonsObject){
                $PDKPanelId = $PDKPerson.panelId
                $PDKUserId = $PDKPerson.id
                $PDKPersonDetails = Get-PDKUser -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId -PDKUserId $PDKUserId | Select-Object cards,groups
                $PDKPerson | Add-Member -MemberType NoteProperty -Name 'cards' -Value $PDKPersonDetails.cards
                $PDKPerson | Add-Member -MemberType NoteProperty -Name 'groups' -Value $PDKPersonDetails.groups
        
                foreach ($PDKCard in $PDKPerson.cards){
                    $PDKCard | Add-Member -MemberType NoteProperty -Name 'panelId' -Value $PDKPanelId
                    $PDKCard | Add-Member -MemberType NoteProperty -Name 'panelName' -Value $PDKPerson.panelName
                }
            }
        
            $PDKPanelSession = $null
            if (!$PDKPersonsObject){
                return $null
            }
            else{
                $PDKPersonsObject | Select-Object *,@{N="fullName";E={$_.firstName + " " + $_.lastName}},@{N="email";E={$null}},@{N="employeeId";E={$null}}
            }
        }
            
        Start-Job -Name "panel-$Id" -ScriptBlock $Job -ArgumentList @($PDKClientId,$PDKClientSecret,$Id) -InitializationScript {Import-Module $env:PSPDKModulePath} | Out-Null
    }
    Get-Job | Wait-Job | Out-Null
    $PDKPersonsObject = Get-Job | Receive-Job 
    Get-Job | Remove-Job
    $PDKPersonsObject | Select-Object -Property * -ExcludeProperty RunspaceId
}

function Get-PDKUser {
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
        $PDKPanelId,
        # Your PDK User Id
        [Parameter(Mandatory = $true)]
        [int]
        $PDKUserId
    )

    if (!$Global:PDKPanelSession){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
    }
    elseif (((Get-Date) -ge [datetime]($Global:PDKPanelSession.expires_at).AddSeconds(-5))){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }
    elseif ($Global:PDKPanelSession.id -ne $PDKPanelId){
        $Global:PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
    }

    $PDKPersonsEndpoint = "$($PDKPanelSession.uri)api/persons/$($PDKUserId)"
    $Headers = @{
        "Authorization" = "Bearer $($PDKPanelSession.panel_token)"
    }

    $PDKPersonsResponse = (Invoke-WebRequest -Method Get -Uri $PDKPersonsEndpoint -Headers $Headers -ContentType "application/json").Content | ConvertFrom-Json
    $PDKPersonsResponse
}

Export-ModuleMember -Function 'Get-PDKUsers','Get-PDKUser'