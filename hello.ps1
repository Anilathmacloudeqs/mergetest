Write-Host "Starting"

$username = "Anilathmacloudeqs"
$repository = "demotest"
$sourceBranch = "main"
$destinationBranch = "release"
$filePath = "hello.ps1"
$commitMessage = "Commit message"

$sourceApiUrl = "https://api.github.com/repos/$username/$repository/contents/$filePath?ref=$sourceBranch"
$destinationApiUrl = "https://api.github.com/repos/$username/$repository/contents/$filePath?ref=$destinationBranch"

# Use the secret PAT_TOKEN
$accessToken = $env:PAT_TOKEN
if (-not $accessToken) {
    Write-Error "Error: GitHub PAT_TOKEN not found in environment variables."
    return
}

$headers = @{
    Authorization = "token $accessToken"
}

$sourceFileResponse = Invoke-RestMethod -Uri $sourceApiUrl -Headers $headers -Method Get
Write-Host "Source API URL: $sourceApiUrl"

if ($sourceFileResponse.StatusCode -eq 200) {
    $sourceFileContent = $sourceFileResponse | ConvertFrom-Json
    $sourceCommitSha = $sourceFileContent.sha

    $decodedContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($sourceFileContent.content))

    $payload = @{
        message = $commitMessage
        content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($decodedContent))
        branch = $destinationBranch
        sha = $sourceCommitSha
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri $destinationApiUrl -Headers $headers -Method Put -Body $payload -ContentType "application/json"

    if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 200) {
        Write-Host "File '$filePath' successfully pushed to the '$destinationBranch' branch."
    } else {
        Write-Error "Error: Unable to push file. Status code: $($response.StatusCode)"
        Write-Error $response | ConvertTo-Json
    }
} else {
    Write-Error "Error: Unable to fetch source file. Status code: $($sourceFileResponse.StatusCode)"
}
