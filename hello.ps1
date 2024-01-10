# hello.ps1

# Define variables
$repository = $env:GITHUB_REPOSITORY
$mainBranch = "main"
$releaseBranch = "release"
$patToken = $env:PAT_TOKEN

# Set up Git configuration
git config --global user.email "anilathma@cloudeqs.com"
git config --global user.name "Anilathmacloudeqs"

# Fetch the latest changes without cloning the whole repository
git init
git remote add origin "https://github.com/$repository.git"
git fetch origin $mainBranch --depth 1

# Switch to the release branch
git checkout -b $releaseBranch

# Overwrite hello.py from the main branch
git checkout origin/$mainBranch -- hello.py

# Commit and push changes to the release branch
git add .
git commit -m "Update hello.py in $releaseBranch"
git push --set-upstream origin $releaseBranch
