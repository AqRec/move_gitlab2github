# Before executing this script, run in powershell as admin `Set-ExecutionPolicy RemoteSigned`, to enable powershell script execution.

# Define your GitLab and GitHub credentials
$gitlabUsername = "<gitlab account id>"
$githubUsername = "<github account id>"
$githubToken = ""    # on GitHub profile, click "Settings" -> "Developer settings" -> "Personal access tokens" -> "Generate new token"

# Define the list of GitLab repositories
$gitlabRepos = @(
    # "https://gitlab.com/<your gitlab id>/<your gitlab repo>.git",
)

$mainBranchName = "main"


# Function to create a GitHub repository
function Create-GitHubRepo {
    param (
        [string]$repoName
    )
    $url = "https://api.github.com/user/repos"
    $body = @{
        name = $repoName
        private = $true
    } | ConvertTo-Json
    $headers = @{
        Authorization = "token $githubToken"
        Accept = "application/vnd.github.v3+json"
    }
    Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body
}

# Loop through each GitLab repository
foreach ($repo in $gitlabRepos) {
    # Extract the repository name
    $repoName = ($repo -split "/")[-1] -replace ".git", ""

    # Create a private blank GitHub repository
    Create-GitHubRepo -repoName $repoName

    # Clone the GitLab repository
    git clone $repo

    # Change directory to the cloned repository
    Set-Location $repoName

    # Check if the default branch name is not $mainBranchName, create main branch
    if (-not (git branch --list $mainBranchName)) {
        git checkout -b $mainBranchName
    }

    # Add the GitHub remote
    git remote add github-origin "https://github.com/$githubUsername/$repoName.git"

    # Push to the GitHub repository
    git push -u github-origin $mainBranchName

    # Change back to the parent directory
    Set-Location ..
}
