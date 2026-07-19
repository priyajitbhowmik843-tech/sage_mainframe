const fs = require('fs');

async function cleanOrphans() {
    const baseUrl = "https://firestore.googleapis.com/v1/projects/sageosf-cf0dc/databases/(default)/documents/tasks";
    
    console.log("Fetching tasks...");
    let allTasks = [];
    let pageToken = "";
    
    do {
        const url = pageToken ? `${baseUrl}?pageSize=300&pageToken=${pageToken}` : `${baseUrl}?pageSize=300`;
        const res = await fetch(url);
        const data = await res.json();
        
        if (data.documents) {
            allTasks = allTasks.concat(data.documents);
        }
        pageToken = data.nextPageToken;
    } while (pageToken);
    
    console.log(`Fetched ${allTasks.length} tasks.`);
    
    // Find all valid references
    // A reference is valid if the parent task has isSubmitted == true
    const validReferences = new Set();
    const parentUpdates = [];
    
    for (const task of allTasks) {
        const fields = task.fields || {};
        const uploadTaskId = fields.uploadTaskId?.stringValue;
        const isSubmitted = fields.isSubmitted?.booleanValue === true;
        
        if (uploadTaskId) {
            if (isSubmitted) {
                validReferences.add(uploadTaskId);
            } else {
                // If it's not submitted but has an uploadTaskId, we need to clear it so it doesn't stay referenced.
                // But for now, we just don't add it to validReferences.
            }
        }
    }
    
    let deletedCount = 0;
    
    for (const task of allTasks) {
        const fields = task.fields || {};
        const taskType = fields.taskType?.stringValue || "";
        const title = fields.title?.stringValue || "";
        
        if (taskType.startsWith("Upload Daily") || title.startsWith("Upload Daily")) {
            const taskId = task.name.split('/').pop();
            
            if (!validReferences.has(taskId)) {
                console.log(`Deleting orphaned task: ${taskId} - ${title}`);
                const delRes = await fetch(`https://firestore.googleapis.com/v1/${task.name}`, { method: 'DELETE' });
                if (delRes.ok) {
                    deletedCount++;
                } else {
                    console.error(`Failed to delete ${taskId}`);
                }
            }
        }
    }
    
    console.log(`Cleanup complete. Deleted ${deletedCount} orphaned tasks.`);
}

cleanOrphans().catch(console.error);
