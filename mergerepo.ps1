<#
 Description: PowerShell Script to merge two branches
 Author: Paramjit Singh
#>

[CmdletBinding()]
param (
    # Name of Target branch 
    [Parameter(Mandatory = $true)]
    [String]
    $TargetBranch,

    # Name of the Source Tag
    [Parameter(Mandatory = $true)]
    [string]
    $SourceTag,

    # Email Id of User
    [Parameter(Mandatory = $false)]
    [string]
    $svc_repos_email = " ",

    # Username of User
    [Parameter(Mandatory = $false)]
    [string]
    $svc_repos_username = " "


)

Write-Host "getting commit id for $($SourceTag)"
$commitid = (git log -n 1 $SourceTag)[0].split(" ")[-1]

Write-Host "commit id is $($commitid)"

$userEmailId = $svc_repos_username -eq " "  ?  $env:BUILD_REQUESTEDFOREMAIL : $svc_repos_email
$Name = $svc_repos_username -eq " " ?  $env:BUILD_REQUESTEDFOR : $svc_repos_username

<#
$userEmailId = $svc_repos_username -eq " "  ?  $env:BUILD_REQUESTEDFOREMAIL : $svc_repos_email
$Name = $svc_repos_username -eq " " ?  $env:BUILD_REQUESTEDFOR : $svc_repos_username
Write-Host "user $($userEmailId)"
Write-Host "user $($Name)"

Write-Host "Setting up git configs"

git config pull.rebase false 
git config --list
#>

git config --global user.email $userEmailId
git config --global user.name $Name
git config pull.rebase false 
git config --list

#git fetch --all
#Write-Host "## Executing git fetch $($TargetBranch)"
#git fetch $TargetBranch

Write-Host "## Executing git fetch"
git fetch

Write-Host "## Executing git checkout $($TargetBranch)."
git checkout $TargetBranch

#Write-Host "## Fetching last commit on $($TargetBranch)."
#$lastCommit = (git log -n 1 $TargetBranch)[0].split(" ")[-1]

#Write-Host "## Fetching the filenames changed between commits."
#$files = git diff --name-only $lastCommit $SourceTag

#Write-Host "##vso[task.setvariable variable=files;]$($files)"

#Write-Host "## Executing git pull on $($SourceTag)."
#git pull origin $SourceTag
Write-Host "## Executing git cherry-pick -m 1 $commitid -X ours"
git cherry-pick -m 1 $commitid -X ours

Write-Host "## Executing git push origin $($TargetBranch) --verbose"
git push origin $($TargetBranch) --verbose


Write-Host "Check if merge was successfull."
$TargetAfterMerge = (git log -n 1 $TargetBranch)[0].split(" ")[-1]

Write-Host "$($TargetBranch) branch is at commit ID $($TargetAfterMerge)"

Write-Host "##vso[task.setvariable variable=commitid;]$($TargetAfterMerge)"

#$MergeDiff = git diff --name-only $TargetAfterMerge $SourceTag

#Write-Host "Merge Differernce = $($MergeDiff)"
#Write-Host "Merge was successfully completed.... !!!!"
#if ($MergeDiff) {
#    Write-Error "Merge was not completed Successfully"
#    exit 1
#}
#else {
#    Write-Host "Merge was successfully completed.... !!!!"
#}