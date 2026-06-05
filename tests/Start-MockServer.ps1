param(
    [int]$Port = 3000
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

Write-Host "Mock server listening on http://127.0.0.1:$Port..." -ForegroundColor Green

try {
	while ($listener.IsListening) {
		$context = $listener.GetContext()
		$request = $context.Request
		$response = $context.Response

		$path = $request.Url.LocalPath
		$method = $request.HttpMethod

		Write-Host "Mock intercepted: $method $path" -ForegroundColor Cyan

		$responseJson = $null
		$statusCode = 200
		
		# HealthCheck endpoint: GET /HealthCheck
		if ($method -eq "GET" -and $path -eq "/HealthCheck") {
			$statusCode = 200
			$responseJson = @{ status = "ok" } | ConvertTo-Json
		}
		elseif ($method -eq "POST" -and $path -match '^/repos/([^/]+)/([^/]+)/deployments/([^/]+)/statuses$') {
			$owner = $Matches[1]
            $repo = $Matches[2]
			$deploymentId = $Matches[3]

			$statusCode = 201
			$responseJson = @{
               id = '789'
			   state = 'success'
            } | ConvertTo-Json -Compress -Depth 10
		}
		else {
			$statusCode = 404
			$responseJson = @{ message = "Not Found" } | ConvertTo-Json
		}

		# Send response
		$response.StatusCode = $statusCode
		$response.ContentType = "application/json"
		$buffer = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
		$response.ContentLength64 = $buffer.Length
		$response.OutputStream.Write($buffer, 0, $buffer.Length)
		$response.Close()
	}
}
finally {
    $listener.Stop()
    $listener.Close()
    Write-Host "Mock server stopped." -ForegroundColor Yellow
}
