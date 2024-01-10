# Set GitHub repository details
$githubUsername = "Anilathmacloudeqs"
$repository = "mergetest"
$patToken = $env:{{secrets.PAT_TOKEN}}  # Retrieve the access token from the repository secrets

# Create the GitHub repository URL
$repoUrl = "https://github.com/$githubUsername/$repository"

# Create the API URL to list files in the repository
$apiUrl = "$repoUrl/contents"

# Make a request to GitHub API to get the list of files
$headers = @{
    Authorization = "Bearer $patToken"
    Accept = "application/vnd.github.v3+json"
}

$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# Print the names of all files in the repository
foreach ($file in $response) {
    if ($file.type -eq "file") {
        Write-Output $file.name
    }
}
