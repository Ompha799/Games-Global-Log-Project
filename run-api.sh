$response = Invoke-WebRequest `
  -Uri "https://141d4ox6t2.execute-api.eu-west-1.amazonaws.com/prod/log" `
  -Headers @{ "x-api-key" = "P41SI6iM2O1wG9ku0VTIh2DeozZ0sg6Wi31fwyA2" } `
  -Method GET

$logs = $response.Content | ConvertFrom-Json

$logs | ForEach-Object {
  Write-Output "ID: $($_.ID), Message: $($_.Message), DateTime: $($_.DateTime)"
}




Invoke-WebRequest `
  -Uri "https://141d4ox6t2.execute-api.eu-west-1.amazonaws.com/prod/log" `
  -Headers @{ 
    "x-api-key" = "P41SI6iM2O1wG9ku0VTIh2DeozZ0sg6Wi31fwyA2"
    "Content-Type" = "application/json"
  } `
  -Method POST `
  -Body '{"severity": "info", "message": "Test log entry from PowerShell"}'
