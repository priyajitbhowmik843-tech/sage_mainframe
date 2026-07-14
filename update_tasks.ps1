$tasksUrl = "https://firestore.googleapis.com/v1/projects/sageosf-cf0dc/databases/(default)/documents/tasks"
$response = Invoke-RestMethod -Uri $tasksUrl
if ($response.documents) {
    foreach ($doc in $response.documents) {
        $delUrl = "https://firestore.googleapis.com/v1/$($doc.name)"
        Invoke-RestMethod -Uri $delUrl -Method Delete
    }
}

$newTasks = @(
    @{ fields = @{
        title = @{ stringValue = "Dakshinayan Session" }; clientId = @{ stringValue = "CLT-45330562" };
        assignedTo = @{ stringValue = "EMP-POU-001" }; assignedBy = @{ stringValue = "CEO-SOH-001" };
        isCompleted = @{ booleanValue = $true }; isSubmitted = @{ booleanValue = $true }; taskType = @{ stringValue = "Session" };
        isApprovedByVideographer = @{ booleanValue = $true }; isPaidToVideographer = @{ booleanValue = $false }; isPaymentAcknowledgedByVideographer = @{ booleanValue = $false };
        deadline = @{ timestampValue = "2026-06-10T06:00:00Z" }; completedAt = @{ timestampValue = "2026-06-10T06:00:00Z" };
    }},
    @{ fields = @{
        title = @{ stringValue = "Alivia Session" }; clientId = @{ stringValue = "CLT-45151194" };
        assignedTo = @{ stringValue = "EMP-POU-001" }; assignedBy = @{ stringValue = "CEO-SOH-001" };
        isCompleted = @{ booleanValue = $true }; isSubmitted = @{ booleanValue = $true }; taskType = @{ stringValue = "Session" };
        isApprovedByVideographer = @{ booleanValue = $true }; isPaidToVideographer = @{ booleanValue = $false }; isPaymentAcknowledgedByVideographer = @{ booleanValue = $false };
        deadline = @{ timestampValue = "2026-06-14T06:00:00Z" }; completedAt = @{ timestampValue = "2026-06-14T06:00:00Z" };
    }},
    @{ fields = @{
        title = @{ stringValue = "Bne ad shoot" }; clientId = @{ stringValue = "CLT-45785189" };
        assignedTo = @{ stringValue = "EMP-POU-001" }; assignedBy = @{ stringValue = "CEO-SOH-001" };
        isCompleted = @{ booleanValue = $true }; isSubmitted = @{ booleanValue = $true }; taskType = @{ stringValue = "Session" };
        isApprovedByVideographer = @{ booleanValue = $true }; isPaidToVideographer = @{ booleanValue = $false }; isPaymentAcknowledgedByVideographer = @{ booleanValue = $false };
        deadline = @{ timestampValue = "2026-06-15T06:00:00Z" }; completedAt = @{ timestampValue = "2026-06-15T06:00:00Z" };
    }},
    @{ fields = @{
        title = @{ stringValue = "Ms Session" }; clientId = @{ stringValue = "CLT-45518934" };
        assignedTo = @{ stringValue = "EMP-POU-001" }; assignedBy = @{ stringValue = "CEO-SOH-001" };
        isCompleted = @{ booleanValue = $true }; isSubmitted = @{ booleanValue = $true }; taskType = @{ stringValue = "Session" };
        isApprovedByVideographer = @{ booleanValue = $true }; isPaidToVideographer = @{ booleanValue = $false }; isPaymentAcknowledgedByVideographer = @{ booleanValue = $false };
        deadline = @{ timestampValue = "2026-06-17T06:00:00Z" }; completedAt = @{ timestampValue = "2026-06-17T06:00:00Z" };
    }},
    @{ fields = @{
        title = @{ stringValue = "Riddhi Siddhi Session" }; clientId = @{ stringValue = "CL-96032" };
        assignedTo = @{ stringValue = "EMP-POU-001" }; assignedBy = @{ stringValue = "CEO-SOH-001" };
        isCompleted = @{ booleanValue = $true }; isSubmitted = @{ booleanValue = $true }; taskType = @{ stringValue = "Session" };
        isApprovedByVideographer = @{ booleanValue = $true }; isPaidToVideographer = @{ booleanValue = $false }; isPaymentAcknowledgedByVideographer = @{ booleanValue = $false };
        deadline = @{ timestampValue = "2026-06-30T06:00:00Z" }; completedAt = @{ timestampValue = "2026-06-30T06:00:00Z" };
    }},
    @{ fields = @{
        title = @{ stringValue = "New Gaandheswari Session" }; clientId = @{ stringValue = "CLT-46021546" };
        assignedTo = @{ stringValue = "EMP-SOU-002" }; assignedBy = @{ stringValue = "CEO-SOH-001" };
        isCompleted = @{ booleanValue = $true }; isSubmitted = @{ booleanValue = $true }; taskType = @{ stringValue = "Session" };
        isApprovedByVideographer = @{ booleanValue = $true }; isPaidToVideographer = @{ booleanValue = $false }; isPaymentAcknowledgedByVideographer = @{ booleanValue = $false };
        deadline = @{ timestampValue = "2026-06-18T06:00:00Z" }; completedAt = @{ timestampValue = "2026-06-18T06:00:00Z" };
    }}
)

foreach ($task in $newTasks) {
    $json = $task | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Uri $tasksUrl -Method Post -Body $json -ContentType "application/json"
}
Write-Host "Recreated tasks with fixed timezone offsets successfully."
