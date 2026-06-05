function function-name {
    param (
        [string]$Input1,
        [string]$Input2,
        [string]$Input3,
		[string]$Token
    )

    # Validate required inputs
    if (
        [string]::IsNullOrEmpty($Input1) -or
        [string]::IsNullOrEmpty($Input2) -or
        [string]::IsNullOrEmpty($Input3)
    ) {        
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: Input1, Input2, and Input3 must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Write-Host "Error: Missing required parameters"
        return
    }   

    # Use MOCK_API if set, otherwise default to GitHub API
    $githubApiUrl = $env:MOCK_API
	if (-not $githubApiUrl) { $githubApiUrl = "https://api.github.com" }
	$uri = "$githubApiUrl/your/api/call"
	
    $headers = @{
		Authorization = "Bearer $Token"
		"Accept" = "application/vnd.github+json"
		"X-GitHub-Api-Version" = "2026-03-10"
		"Content-Type" = "application/json"		
	}

	try {
		Write-Output "Attempting to run action"
		$response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get -SkipHttpErrorCheck

        if ($response.StatusCode -eq 200) {
            Write-Host "Call Succeeded"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
        } else {
			$errorMsg = "Error: Call Failed. HTTP Status: $($response.StatusCode)"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
			Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
			Write-Host $errorMsg
        }
	} catch {
		$errorMsg = "Error: Call Failed. Exception: $($_.Exception.Message)"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg	
	}
}
