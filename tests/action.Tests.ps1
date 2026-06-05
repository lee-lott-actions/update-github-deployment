Describe "Set-DeploymentStatus" {
    BeforeAll {
        $script:DeploymentId = "123"
        $script:State        = "success"
        $script:Description  = "Deployment completed successfully"
        $script:OrgName      = "test-org"
        $script:RepoName     = "test-repo"
        $script:Token        = "fake-token"
        $script:MockApiUrl   = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }

    BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }

    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

    Context "Success Cases" {
        It "unit: Set-DeploymentStatus succeeds with HTTP 201" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 201
                    Content    = '{"id": "456", "state": "success"}'
                }
            }

            Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=success"
            $output | Should -Contain "deployment_status_id=456"
            $output | Should -Contain "deployment_status_state=success"
        }
    }

    Context "HTTP Failure Cases" {
        It "unit: Set-DeploymentStatus fails with HTTP 404" {
            Mock Invoke-WebRequest {
                [PSCustomObject]@{
                    StatusCode = 404
                    Content    = '{"message":"Deployment not found"}'
                }
            }

            Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Should -Contain "error-message=Error: Deployment status update failed. Status code: 404"
        }
    }

    Context "Parameter Validation Failure Cases" {
        It "unit: Set-DeploymentStatus fails with empty DeploymentId" {
            Set-DeploymentStatus -DeploymentId "" -State $State -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Should -Contain "error-message=Missing required parameters: DeploymentId, State, Description, OrgName, RepoName, and Token must be provided."
        }

        It "unit: Set-DeploymentStatus throws exception if State is empty" {
            {
                Set-DeploymentStatus `
                    -DeploymentId $DeploymentId `
                    -State "" `
                    -Description $Description `
                    -OrgName $OrgName `
                    -RepoName $RepoName `
                    -Token $Token
            } | Should -Throw
        }

        It "unit: Set-DeploymentStatus throws exception if State is not valid" {
            {
                Set-DeploymentStatus `
                    -DeploymentId $DeploymentId `
                    -State "INVALID_TYPE" `
                    -Description $Description `
                    -OrgName $OrgName `
                    -RepoName $RepoName `
                    -Token $Token
            } | Should -Throw
        }        

        It "unit: Set-DeploymentStatus fails with empty Description" {
            Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description "" -OrgName $OrgName -RepoName $RepoName -Token $Token
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Should -Contain "error-message=Missing required parameters: DeploymentId, State, Description, OrgName, RepoName, and Token must be provided."
        }

        It "unit: Set-DeploymentStatus fails with empty OrgName" {
            Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description $Description -OrgName "" -RepoName $RepoName -Token $Token
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Should -Contain "error-message=Missing required parameters: DeploymentId, State, Description, OrgName, RepoName, and Token must be provided."
        }

        It "unit: Set-DeploymentStatus fails with empty RepoName" {
            Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description $Description -OrgName $OrgName -RepoName "" -Token $Token
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Should -Contain "error-message=Missing required parameters: DeploymentId, State, Description, OrgName, RepoName, and Token must be provided."
        }

        It "unit: Set-DeploymentStatus fails with empty Token" {
            Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description $Description -OrgName $OrgName -RepoName $RepoName -Token ""
            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Should -Contain "error-message=Missing required parameters: DeploymentId, State, Description, OrgName, RepoName, and Token must be provided."
        }
    }

    Context "Exception Failure Cases" {
        It "unit: Set-DeploymentStatus fails with exception" {
            Mock Invoke-WebRequest { throw "API Error" }

            try {
                Set-DeploymentStatus -DeploymentId $DeploymentId -State $State -Description $Description -OrgName $OrgName -RepoName $RepoName -Token $Token
            } catch {}

            $output = Get-Content $env:GITHUB_OUTPUT
            $output | Should -Contain "result=failure"
            $output | Where-Object { $_ -match "^error-message=Error: Deployment status update failed. Exception: " } |
                Should -Not -BeNullOrEmpty
        }
    }
}
