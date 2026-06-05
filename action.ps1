function Set-DeploymentStatus {
    param (
		[string]$DeploymentId,
		[ValidateSet("error", "failure", "inactive", "in_progress", "queued", "pending", "success")]
		[string]$State,
		[string]$Description,
		[string]$OrgName,
		[string]$RepoName,
		[string]$Token
    )

    # Validate required inputs
	if ([string]::IsNullOrEmpty($DeploymentId) -or
		[string]::IsNullOrEmpty($State) -or
		[string]::IsNullOrEmpty($Description) -or
		[string]::IsNullOrEmpty($OrgName) -or
		[string]::IsNullOrEmpty($RepoName) -or
		[string]::IsNullOrEmpty($Token))
	{      
		Write-Output "Error: Missing required parameters"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: DeploymentId, State, Description, OrgName, RepoName, and Token must be provided."
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		return
	}

    # Use MOCK_API if set, otherwise default to GitHub API
	$githubApiUrl = $env:MOCK_API
	if (-not $githubApiUrl) { $githubApiUrl = "https://api.github.com" }
	$uri = "$githubApiUrl/repos/$OrgName/$RepoName/deployments/$DeploymentId/statuses"
		
    $headers = @{
		Authorization = "Bearer $Token"
		"Accept" = "application/vnd.github+json"
		"X-GitHub-Api-Version" = "2026-03-10"
		"Content-Type" = "application/json"		
	}

	$body = @{
		state        = $State
		description  = $Description
	} | ConvertTo-Json

	try {
		Write-Output "Updating deployment status for deployment id $DeploymentId"
		$response = Invoke-WebRequest -Uri $uri -Headers $headers -Method POST -Body $body -SkipHttpErrorCheck

        if ($response.StatusCode -eq 201) {
			$deploymentStatus = $response.Content | ConvertFrom-Json
			Add-Content -Path $env:GITHUB_OUTPUT -Value "deployment_status_id=$($deploymentStatus.id)"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "deployment_status_state=$($deploymentStatus.state)"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
			Write-Host "Deployment status updated. ID: $($deploymentStatus.id), State: $($deploymentStatus.state)"
        } else {
			$errorMsg = "Error: Deployment status update failed. Status code: $($response.StatusCode)"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
			Write-Host $errorMsg
        }
	} catch {
		$errorMsg = "Error: Deployment status update failed. Exception: $($_.Exception.Message)"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
	}
}
