$tasksUrl = "https://firestore.googleapis.com/v1/projects/sageosf-cf0dc/databases/(default)/documents/tasks"
$response = Invoke-RestMethod -Uri $tasksUrl

if ($response.documents) {
    foreach ($doc in $response.documents) {
        $assignedTo = $doc.fields.assignedTo.stringValue
        if ($assignedTo -eq "EMP-SOU-002") {
            $body = @{
                fields = @{
                    isPaidToVideographer = @{ booleanValue = $true }
                    isPaymentAcknowledgedByVideographer = @{ booleanValue = $true }
                }
            } | ConvertTo-Json
            
            $patchUrl = "https://firestore.googleapis.com/v1/$($doc.name)?updateMask.fieldPaths=isPaidToVideographer&updateMask.fieldPaths=isPaymentAcknowledgedByVideographer"
            Invoke-RestMethod -Uri $patchUrl -Method Patch -Body $body -ContentType "application/json"
            Write-Host "Marked task as paid for $($doc.name)"
        }
    }
}
Write-Host "Done."
