param (
    [Parameter(Mandatory = $true)]
    [String]
    $TargetBranch,

    [Parameter(Mandatory = $true)]
    [string]
    $SourceTag,

    [Parameter(Mandatory = $false)]
    [string]
    $svc_repos_email = " ",

    [Parameter(Mandatory = $false)]
    [string]
    $svc_repos_username = " "


)

git config --global user.name 'Paramjit' 
git config --global user.email 'params@cloudeqs.com'
git config pull.rebase false 
git config --list
git branch
Write-Host "testing the git tag list"
git tag
Write-Host "testing after git tag"

Write-Host "getting commit id for $($SourceTag)"
$commitid = (git log -n 1 )[0].split(" ")[-1]

Write-Host "commit id is $($commitid)"

Write-Host "## Executing git fetch"
git fetch

Write-Host "## Executing git checkout $($TargetBranch)."
git checkout $TargetBranch

Write-Host "## Executing git cherry-pick -m 1 $commitid -X ours"
git cherry-pick -m 1 $commitid -X ours

Write-Host "## Executing git push origin $($TargetBranch) --verbose"
git push origin $($TargetBranch) --verbose


Write-Host "Check if merge was successfull."
$TargetAfterMerge = (git log -n 1 )[0].split(" ")[-1]

Write-Host "$($TargetBranch) branch is at commit ID $($TargetAfterMerge)"

Write-Host "##vso[task.setvariable variable=commitid;]$($TargetAfterMerge)"
