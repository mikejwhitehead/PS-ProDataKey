# Load and Export the Functions 
#   Credit: https://github.com/RamblingCookieMonster/PSStackExchange

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Extension -eq ".ps1"} )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Extension -eq ".ps1"} )

#Import additional modules
#Import-Module ActiveDirectory

#Dot source the files
Foreach($PSFunction in @($Public + $Private))
{
    Try
    {
        . $PSFunction.FullName
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($psfunction.fullname): $_"
    }
}
