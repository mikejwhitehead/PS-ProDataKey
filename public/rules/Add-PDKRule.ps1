function Add-PDKRule {
    [cmdletbinding(DefaultParameterSetName='GroupRule')]
    Param(
        # Your PDK Panel Id
        [Parameter(
            Position=0,
            Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKPanelId,
        # PDK Group Id
        [Parameter(
            Position=1,
            ParameterSetName='GroupRule',
            Mandatory=$true)]
        [int]
        $PDKGroupId,
        # PDK User Id
        [Parameter(
            Position=1,
            ParameterSetName='UserRule',
            Mandatory=$true)]   
        [int]
        $PDKUserId,
        # PDK Rule Type
        [Parameter(
            Position=2,
            Mandatory=$true)]
        [ValidateSet('door','elevator','event')]
        [string]
        $PDKRuleType,
        # Recurring Rule
        [Parameter(
            Position=3,
            ParameterSetName='Recurring',
            Mandatory=$true)]
        [ValidateSet('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')]
        [string[]]
        $Recurance,
        [Parameter(
            Position=3,
            ParameterSetName='SingleDate',
            Mandatory=$true)]
        [ValidateScript({$_ -gt (Get-Date)})]
        [datetime]
        $SingleDate,
        # PDK Rule Start Time
        [Parameter(
            Position=4,
            Mandatory=$true)]  
        [datetime]
        $PDKRuleStartTime,
        # PDK Rule Stop Time
        [Parameter(
            Position=5,
            Mandatory=$true)]
        [datetime]
        $PDKRuleStopTime,
        # A PDK Panel Web Session Object
        [Parameter(
            Position=6,
            Mandatory=$true,
            ParameterSetName='Session')]
        [psobject]
        $PDKPanelSession,
        # Your PDK ClientId
        [Parameter(
            Position=6,
            Mandatory=$true,
            ParameterSetName='Login')]
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKClientId,
        # Your PDK Client Secret
        [Parameter(
            Position=7,
            Mandatory=$true,
            ParameterSetName='Login')] 
        [ValidateNotNullOrEmpty()]
        [string]
        $PDKClientSecret
    )
    # DynamicParam {

    #     if ($PDKRuleType -eq 'door' -or $PDKRuleType -eq 'elevator') {
    #         $ParamDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    #     }

    #     if ($PDKRuleType -eq 'door') {

    #         ## Allow parameter
    #         $AllowAttribute = New-Object System.Management.Automation.ParameterAttribute -Property @{
    #             Position = 8
    #             Mandatory = $true
    #             HelpMessage = 'Select whether this is a deny or allow rule'
    #         }

    #         $AttributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]  
    #         $AttributeCollection.Add($AllowAttribute)
    #         $AllowParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Allow', [bool], $AttributeCollection)
    #         $ParamDictionary.Add('Allow', $AllowParam)

    #         ## Doors Parameter
    #         $DoorsAttribute = New-Object System.Management.Automation.ParameterAttribute -Property @{
    #             Position = 9
    #             Mandatory = $true
    #             HelpMessage = 'The door id(s) on which the rule should be performed'
    #         }

    #         $AttributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]  
    #         $AttributeCollection.Add($DoorsAttribute)
    #         $DoorsParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Doors', [int], $AttributeCollection)
    #         $ParamDictionary.Add('Doors', $DoorsParam)
    #     }

    #     if ($PDKRuleType -eq 'elevator') {
    #         ## Floor Groups Parameter
    #         $FloorGroupsAttribute = New-Object System.Management.Automation.ParameterAttribute -Property @{
    #             Position = 8
    #             Mandatory = $true
    #             HelpMessage = 'Floor Group ids on which rule should be performed'
    #         }

    #         $AttributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]  
    #         $AttributeCollection.Add($FloorGroupsAttribute)
    #         $FloorGroupsParam = New-Object System.Management.Automation.RuntimeDefinedParameter('FloorGroups', [int[]], $AttributeCollection)
    #         $ParamDictionary.Add('FloorGroups', $FloorGroupsParam)
    #     }

    #     if ($PDKRuleType -eq 'door' -or $PDKRuleType -eq 'elevator') {
            
    #         ## Authentication Policy Parameter
    #         $AuthenticationPolicyAttribute = New-Object System.Management.Automation.ParameterAttribute -Property @{
    #             Position = 10
    #             Mandatory = $true
    #             HelpMessage = 'Authentication policy that should be applied on the certain Device'
    #         }

    #         $AttributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]  
    #         $AttributeCollection.Add($AuthenticationPolicyAttribute)
    #         $ValidValues = @('cardOnly','pinOnly','cardOrPin','cardAndPin')
    #         $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidValues)
    #         $AttributeCollection.Add($ValidateSetAttribute)
    #         $AuthenticationPolicyParam = New-Object System.Management.Automation.RuntimeDefinedParameter('AuthenticationPolicy', [string], $AttributeCollection)
    #         $ParamDictionary.Add('AuthenticationPolicy', $AuthenticationPolicyParam)

    #     }
    # }

    Begin {

    }
    Process {

        if (!$PDKPanelSession){
            $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
        }
        elseif (((Get-Date) -ge [datetime]($PDKPanelSession.expires_at).AddSeconds(-5))){
            $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId
        }
        elseif ($PDKPanelSession.id -ne $PDKPanelId){
            $PDKPanelSession = Connect-PDKPanel -PDKClientId $PDKClientId -PDKClientSecret $PDKClientSecret -PDKPanelId $PDKPanelId        
        }

        if ($PDKGroupId) {
            $PDKRuleEndpoint = "https://$($PDKPanelId).pdk.io/api/groups/$($PDKGroupId)/rules"
        } elseif ($PDKUserId) {
            $PDKRuleEndpoint = "https://$($PDKPanelId).pdk.io/api/persons/$($PDKUserId)/rules"
        }

        if ($PDKRuleType -eq 'door') {

            $Request = @{
                type=$PDKRuleType
                startTime=$PDKRuleStartTime.ToString('HH:mm')
                stopTime=$PDKRuleStopTime.ToString('HH:mm')
                recurring=$Recurance
                allow=$Allow
                doors=$Doors
                authenticationPolicy=$AuthenticationPolicy
            } | ConvertTo-Json
            
        }

        return $Request
    }
}

#Add-PDKRule -  