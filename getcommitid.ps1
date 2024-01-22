<#
 Description: PowerShell Script to get commit id for specific tag and set it to pipeline variable
 Author: Paramjit Singh
#>

[CmdletBinding()]
param (
    # Name of the Source Tag
    [Parameter(Mandatory = $true)]
    [string]
    $SourceTag
)



Write-Host "##change Executing git pull on $($SourceTag)"
git pull origin $SourceTag
#git checkout $SourceTag



Write-Host "getting commit id for $($SourceTag)"
$commitid = (git log -n 1 $SourceTag)[0].split(" ")[-1]

Write-Host "commit id is $($commitid)"

Write-Host "##vso[task.setvariable variable=commitid;]$($commitid)"