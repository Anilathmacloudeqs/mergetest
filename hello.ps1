# hello.ps1

# Define variables
$repository = $env:GITHUB_REPOSITORY
$mainBranch = "main"
$releaseBranch = "release"

# Set up Git configuration
git config --global user.email "anilathma@cloudeqs.com"
git config --global user.name "Anilathmacloudeqs"

# Download only the latest version of hello.py from the main branch
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/$repository/$mainBranch/hello.py" -OutFile "hello.py"

# Switch to the release branch
git checkout -b $releaseBranch

# Overwrite hello.py in the release branch
Copy-Item -Path "hello.py" -Destination "hello.py" -Force

# Commit and push changes to the release branch
git add .
git commit -m "Update hello.py in $releaseBranch"
git push --set-upstream origin $releaseBranch
