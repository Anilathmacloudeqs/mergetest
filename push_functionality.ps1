# push_functionality.ps1

param (
    [string]$username = 'YourGitHubUsername',
    [string]$repository = 'YourGitHubRepository',
    [string]$sourceBranch = 'main',
    [string]$destinationBranch = 'release',
    [string]$filePath = 'hello.ps1',
    [string]$commitMessage = 'Commit message',
    [string]$githubToken = 'YourGitHubAccessToken'
)

# GitHub API URLs
$sourceApiUrl = "https://api.github.com/repos/$username/$repository/contents/$filePath?ref=$sourceBranch"
$destinationApiUrl = "https://api.github.com/repos/$username/$repository/contents/$filePath?ref=$destinationBranch"
$destinationShaUrl = "https://api.github.com/repos/$username/$repository/git/refs/heads/$destinationBranch"

# Headers for GitHub API requests
$headers = @{
    'Authorization' = "token $githubToken"
}
Write-Host "starting AWS_GIT_PUSH."

# Fetch source file content
$sourceFileResponse = Invoke-RestMethod -Uri $sourceApiUrl -Headers $headers -Method Get

# Fetch destination commit SHA
$destinationShaResponse = Invoke-RestMethod -Uri $destinationShaUrl -Headers $headers -Method Get

if ($sourceFileResponse -and $destinationShaResponse) {
    $sourceFileContent = $sourceFileResponse.content
    $sourceCommitSha = $sourceFileResponse.sha

    $destinationCommitSha = $destinationShaResponse.object.sha

    # Check if the content needs to be updated
    if ($sourceCommitSha -eq $destinationCommitSha) {
        Write-Host "File '$filePath' is already up to date in the '$destinationBranch' branch."
    }
    else {
        # Fetch existing file content in the destination branch
        $existingFileResponse = Invoke-RestMethod -Uri $destinationApiUrl -Headers $headers -Method Get

        if ($existingFileResponse -and $existingFileResponse.statusCode -eq 404) {
            # File doesn't exist in the destination branch, create it

            # Decode the new file content
            $newDecodedContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($sourceFileContent))

            # Encode the new content
            $encodedContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($newDecodedContent))

            # Create a new commit with the file content
            $commitPayload = @{
                'message' = $commitMessage
                'content' = $encodedContent
                'branch' = $destinationBranch
            }

            $commitUrl = "https://api.github.com/repos/$username/$repository/contents/$filePath"
            $commitResponse = Invoke-RestMethod -Uri $commitUrl -Headers $headers -Method Put -Body ($commitPayload | ConvertTo-Json)

            if ($commitResponse.statusCode -eq 200 -or $commitResponse.statusCode -eq 201) {
                Write-Host "File '$filePath' successfully pushed to the '$destinationBranch' branch."
            }
            else {
                Write-Error "Error: Unable to push file. Status code: $($commitResponse.statusCode)"
                Write-Error $commitResponse | ConvertTo-Json
            }
        }
        elseif ($existingFileResponse) {
            $existingFileContent = $existingFileResponse.content
            $existingFileSha = $existingFileResponse.sha

            # Decode the new file content
            $newDecodedContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($sourceFileContent))

            # Encode the new content
            $encodedContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($newDecodedContent))

            # Create a new commit with the replaced content
            $commitPayload = @{
                'message' = $commitMessage
                'content' = $encodedContent
                'sha' = $existingFileSha
                'branch' = $destinationBranch
            }

            $commitUrl = "https://api.github.com/repos/$username/$repository/contents/$filePath"
            $commitResponse = Invoke-RestMethod -Uri $commitUrl -Headers $headers -Method Put -Body ($commitPayload | ConvertTo-Json)

            if ($commitResponse.statusCode -eq 200 -or $commitResponse.statusCode -eq 201) {
                Write-Host "File '$filePath' successfully pushed to the '$destinationBranch' branch."
            }
            else {
                Write-Error "Error: Unable to push file. Status code: $($commitResponse.statusCode)"
                Write-Error $commitResponse | ConvertTo-Json
            }
        }
        else {
            Write-Error "Error: Unable to fetch existing file content. Status code: $($existingFileResponse.statusCode)"
            Write-Error $existingFileResponse | ConvertTo-Json
        }
    }
}
else {
    Write-Error "Error: Unable to fetch source file or destination SHA."
}
