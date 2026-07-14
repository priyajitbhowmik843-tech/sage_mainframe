$tasksUrl = "https://firestore.googleapis.com/v1/projects/sageosf-cf0dc/databases/(default)/documents/tasks"
$response = Invoke-RestMethod -Uri $tasksUrl

if ($response.documents) {
    foreach ($doc in $response.documents) {
        $title = $doc.fields.title.stringValue
        if ($title -eq "Bne ad shoot" -or $title -match "Biswanath") {
            $delUrl = "https://firestore.googleapis.com/v1/$($doc.name)"
            Invoke-RestMethod -Uri $delUrl -Method Delete
            Write-Host "Deleted task: $title"
        }
    }
}
Write-Host "Done."
