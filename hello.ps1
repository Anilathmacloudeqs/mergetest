# Set GitHub repository details
$githubUsername = "Anilathmacloudeqs"
$repository = "mergetest"
$patToken = "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"  # Replace this with your actual access token

# Create the GitHub repository URL
$repoUrl = "https://github.com/$githubUsername/$repository"

# Create the API URL to list files in the repository
$apiUrl = "https://api.github.com/repos/$githubUsername/$repository/contents"

# Make a request to GitHub API to get the list of files
$headers = @{
    Authorization = "Bearer $patToken"
    Accept = "application/vnd.github.v3+json"
}

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    # Print the names of all files in the repository
    foreach ($file in $response) {
        if ($file.type -eq "file") {
            Write-Output $file.name
        }
    }
}
catch {
    Write-Error "Error accessing GitHub API: $_"
    throw
}
