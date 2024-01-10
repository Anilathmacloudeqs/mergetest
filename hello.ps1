# hello.ps1

# Define variables
$repository = $env:GITHUB_REPOSITORY
$mainBranch = "main"
$releaseBranch = "release"
$patToken = $env:PAT_TOKEN

# Set up Git configuration
git config --global user.email "anilathma@cloudeqs.com"
git config --global user.name "Anilathmacloudeqs"

# Clone the repository
git clone "https://github.com/$repository.git" repo
cd repo

# Switch to the main branch
git checkout $mainBranch

# Copy hello.py to the release branch
git checkout -b $releaseBranch
git checkout $mainBranch -- hello.py

# Commit and push changes to the release branch
git add .
git commit -m "Push hello.py to $releaseBranch"
git push --set-upstream origin $releaseBranch
