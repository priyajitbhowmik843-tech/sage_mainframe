$tasks = @(
    @{
        "fields" = @{
            "title" = @{ "stringValue" = "Session 1 (Restored)" };
            "description" = @{ "stringValue" = "Recovered session from June." };
            "assignedTo" = @{ "stringValue" = "EMP-POU-001" };
            "assignedBy" = @{ "stringValue" = "CEO-SOH-001" };
            "isCompleted" = @{ "booleanValue" = $true };
            "isSubmitted" = @{ "booleanValue" = $true };
            "taskType" = @{ "stringValue" = "Session" };
            "isApprovedByVideographer" = @{ "booleanValue" = $true };
            "isPaidToVideographer" = @{ "booleanValue" = $false };
            "isPaymentAcknowledgedByVideographer" = @{ "booleanValue" = $false };
            "deadline" = @{ "timestampValue" = "2026-06-15T18:30:00Z" };
            "createdAt" = @{ "timestampValue" = "2026-06-10T18:30:00Z" };
            "completedAt" = @{ "timestampValue" = "2026-06-15T18:30:00Z" };
            "submittedAt" = @{ "timestampValue" = "2026-06-15T18:30:00Z" };
        }
    },
    @{
        "fields" = @{
            "title" = @{ "stringValue" = "Session 2 (Restored)" };
            "description" = @{ "stringValue" = "Recovered session from June." };
            "assignedTo" = @{ "stringValue" = "EMP-POU-001" };
            "assignedBy" = @{ "stringValue" = "CEO-SOH-001" };
            "isCompleted" = @{ "booleanValue" = $true };
            "isSubmitted" = @{ "booleanValue" = $true };
            "taskType" = @{ "stringValue" = "Session" };
            "isApprovedByVideographer" = @{ "booleanValue" = $true };
            "isPaidToVideographer" = @{ "booleanValue" = $false };
            "isPaymentAcknowledgedByVideographer" = @{ "booleanValue" = $false };
            "deadline" = @{ "timestampValue" = "2026-06-18T18:30:00Z" };
            "createdAt" = @{ "timestampValue" = "2026-06-12T18:30:00Z" };
            "completedAt" = @{ "timestampValue" = "2026-06-18T18:30:00Z" };
            "submittedAt" = @{ "timestampValue" = "2026-06-18T18:30:00Z" };
        }
    },
    @{
        "fields" = @{
            "title" = @{ "stringValue" = "Session 3 (Restored)" };
            "description" = @{ "stringValue" = "Recovered session from June." };
            "assignedTo" = @{ "stringValue" = "EMP-POU-001" };
            "assignedBy" = @{ "stringValue" = "CEO-SOH-001" };
            "isCompleted" = @{ "booleanValue" = $true };
            "isSubmitted" = @{ "booleanValue" = $true };
            "taskType" = @{ "stringValue" = "Session" };
            "isApprovedByVideographer" = @{ "booleanValue" = $true };
            "isPaidToVideographer" = @{ "booleanValue" = $false };
            "isPaymentAcknowledgedByVideographer" = @{ "booleanValue" = $false };
            "deadline" = @{ "timestampValue" = "2026-06-22T18:30:00Z" };
            "createdAt" = @{ "timestampValue" = "2026-06-15T18:30:00Z" };
            "completedAt" = @{ "timestampValue" = "2026-06-22T18:30:00Z" };
            "submittedAt" = @{ "timestampValue" = "2026-06-22T18:30:00Z" };
        }
    },
    @{
        "fields" = @{
            "title" = @{ "stringValue" = "Session 4 (Restored)" };
            "description" = @{ "stringValue" = "Recovered session from June." };
            "assignedTo" = @{ "stringValue" = "EMP-POU-001" };
            "assignedBy" = @{ "stringValue" = "CEO-SOH-001" };
            "isCompleted" = @{ "booleanValue" = $true };
            "isSubmitted" = @{ "booleanValue" = $true };
            "taskType" = @{ "stringValue" = "Session" };
            "isApprovedByVideographer" = @{ "booleanValue" = $true };
            "isPaidToVideographer" = @{ "booleanValue" = $false };
            "isPaymentAcknowledgedByVideographer" = @{ "booleanValue" = $false };
            "deadline" = @{ "timestampValue" = "2026-06-26T18:30:00Z" };
            "createdAt" = @{ "timestampValue" = "2026-06-20T18:30:00Z" };
            "completedAt" = @{ "timestampValue" = "2026-06-26T18:30:00Z" };
            "submittedAt" = @{ "timestampValue" = "2026-06-26T18:30:00Z" };
        }
    },
    @{
        "fields" = @{
            "title" = @{ "stringValue" = "Video Editing Task (Restored)" };
            "description" = @{ "stringValue" = "Recovered task from June." };
            "assignedTo" = @{ "stringValue" = "EMP-SOU-002" };
            "assignedBy" = @{ "stringValue" = "CEO-SOH-001" };
            "isCompleted" = @{ "booleanValue" = $true };
            "isSubmitted" = @{ "booleanValue" = $true };
            "taskType" = @{ "stringValue" = "Task" };
            "isApprovedByVideographer" = @{ "booleanValue" = $true };
            "isPaidToVideographer" = @{ "booleanValue" = $false };
            "isPaymentAcknowledgedByVideographer" = @{ "booleanValue" = $false };
            "deadline" = @{ "timestampValue" = "2026-06-20T18:30:00Z" };
            "createdAt" = @{ "timestampValue" = "2026-06-15T18:30:00Z" };
            "completedAt" = @{ "timestampValue" = "2026-06-20T18:30:00Z" };
            "submittedAt" = @{ "timestampValue" = "2026-06-20T18:30:00Z" };
        }
    }
)

$url = "https://firestore.googleapis.com/v1/projects/sageosf-cf0dc/databases/(default)/documents/tasks"

foreach ($task in $tasks) {
    $json = $task | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Uri $url -Method Post -Body $json -ContentType "application/json"
}
Write-Host "Data restored successfully."
