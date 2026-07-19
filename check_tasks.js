const fs = require('fs');

async function checkTasks() {
    const baseUrl = "https://firestore.googleapis.com/v1/projects/sageosf-cf0dc/databases/(default)/documents/tasks";
    
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
    
    const tasksOn18th = [];
    for (const task of allTasks) {
        const fields = task.fields || {};
        const deadline = fields.deadline?.timestampValue || "";
        if (deadline.includes("-07-18T") || deadline.includes("-07-18")) {
            tasksOn18th.push({
                title: fields.title?.stringValue,
                taskType: fields.taskType?.stringValue,
            });
        }
    }
    
    console.log("Tasks on the 18th:");
    console.log(JSON.stringify(tasksOn18th, null, 2));
}

checkTasks().catch(console.error);
