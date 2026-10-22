<#
.SYNOPSIS
    Reports active Okta users and whether they have MFA enrolled.

.DESCRIPTION
    Pulls every active user from the Okta org, checks each user's enrolled
    factors, exports the results to a CSV, and lists users with no MFA.

.NOTES
    Requires PowerShell 7.
    Reads the API token from the OKTA_API_TOKEN environment variable.
    Never hardcode the token in this file.

.EXAMPLE
    $env:OKTA_API_TOKEN = "your_token_here"
    .\Get-MfaReport.ps1
#>

param(
    [string]$OktaUrl    = "https://integrator-8743535.okta.com",
    [string]$OutputPath = ".\mfa-report.csv"
)

# Stop if the token isn't set
if (-not $env:OKTA_API_TOKEN) {
    Write-Error "OKTA_API_TOKEN environment variable is not set."
    exit 1
}

$headers = @{
    Authorization = "SSWS $env:OKTA_API_TOKEN"
    Accept        = "application/json"
}

# Get all active users. FollowRelLink follows Okta's pagination links automatically.
$filter = [uri]::EscapeDataString('status eq "ACTIVE"')
$pages  = Invoke-RestMethod -Uri "$OktaUrl/api/v1/users?filter=$filter&limit=200" -Headers $headers -FollowRelLink
$users  = $pages | ForEach-Object { $_ }

# Check each user's enrolled factors
$report = foreach ($user in $users) {
    $factors = Invoke-RestMethod -Uri "$OktaUrl/api/v1/users/$($user.id)/factors" -Headers $headers
    $active  = @($factors | Where-Object { $_.status -eq "ACTIVE" })

    [PSCustomObject]@{
        Name        = "$($user.profile.firstName) $($user.profile.lastName)"
        Login       = $user.profile.login
        Department  = $user.profile.department
        FactorCount = $active.Count
        Factors     = ($active.factorType -join ", ")
        MfaEnrolled = $active.Count -gt 0
    }
}

# Export the full report and show who is missing MFA
$report | Export-Csv -Path $OutputPath -NoTypeInformation

$missing = @($report | Where-Object { -not $_.MfaEnrolled })
Write-Host "Checked $($report.Count) active users. $($missing.Count) have no MFA enrolled." -ForegroundColor Cyan
$missing | Format-Table Name, Login, Department -AutoSize

Write-Host "Full report saved to $OutputPath"
