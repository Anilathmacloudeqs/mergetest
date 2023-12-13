- name: Execute PowerShell Script
  shell: pwsh
  run: |
    $sourceBranch = "main"
    $destinationBranch = "release"
    $fileToPush = "hello.py"
    
    # Set Git user information
    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Actions"
    
    # Fetch the release branch (create it if it doesn't exist)
    git fetch origin "${destinationBranch}:${destinationBranch}"
    
    # Checkout the release branch
    git checkout $destinationBranch
    
    # Copy the file from main branch to release branch
    git checkout $sourceBranch -- $fileToPush
    
    # Stage and commit changes
    git add $fileToPush
    git commit -m "Update $fileToPush from $sourceBranch to $destinationBranch"
    
    # Push changes to the release branch using the personal access token
    git push origin $destinationBranch
  env:
    GITHUB_TOKEN: ${{ secrets.GH_TOKEN }}
