Describe "Function-Name" {
    BeforeAll {
        $script:Input1   = "input-1"
        $script:Input2   = "input-2"
        $script:Input3   = "input-3"
        $script:Token      = "fake-token"
        $script:MockApiUrl = "http://127.0.0.1:3000"
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
	    It "unit: Function-Name succeeds with HTTP 200" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 200; Content = '{}' }
	        }
	        Function-Name -Input1 $Input1 -Input2 $Input2 -Input3 $Input3 -Token $Token 
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	    }
	}

	Context "HTTP Failure Cases" {
	    It "unit: Function-Name fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message":"Repository not found"}' }
	        }
	        Function-Name -Input1 $Input1 -Input2 $Input2 -Input3 $Input3 -Token $Token 
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Error: Call Failed. HTTP Status: 404"
	    }
	}

	Context "Parameter Validation Failure Cases" {
	    It "unit: Function-Name fails with empty Input1" {
	        Function-Name -Input1 "" -Input2 $Input2 -Input3 $Input3 -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Input1, Input2, and Input3 must be provided."
	    }

	    It "unit: Function-Name fails with empty Input2" {
	        Function-Name -Input1 $Input1 -Input2 "" -Input3 $Input3 -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Input1, Input2, and Input3 must be provided."
	    }
      
      It "unit: Function-Name fails with empty Input3" {
	        Function-Name -Input1 $Input1 -Input2 $Input2 -Input3 "" -Token $Token
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Input1, Input2, and Input3 must be provided."
	    }
      	
	    It "unit: Function-Name fails with empty Token" {
	        Function-Name -RepoName $RepoName -Token ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "error-message=Missing required parameters: Input1, Input2, and Input3 must be provided."
	    }
	}

	Context "Exception Failure Cases" {
		It "unit: Function-Name fails with exception" {
			Mock Invoke-WebRequest { throw "API Error" }
	
			try {
				Function-Name -Input1 $Input1 -Input2 $Input2 -Input3 $Input3 -Token $Token 
			} catch {}
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Where-Object { $_ -match "^error-message=Error: Call Failed. Exception:" } |
				Should -Not -BeNullOrEmpty
		}		
	}
}
