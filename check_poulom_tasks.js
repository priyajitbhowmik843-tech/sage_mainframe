const fs = require('fs');
const data = JSON.parse(fs.readFileSync('C:/Users/Priyajit Bhowmik/.gemini/antigravity/brain/d855886f-d8e2-4d1b-8c83-289637657c6b/.system_generated/steps/544/output.txt', 'utf8'));

const tasks = data.data.documents.filter(d => d.data.assignedTo === 'EMP-POU-001' && d.data.isCompleted && !d.data.isPaidToVideographer);
console.log(`Poulom unpaid completed tasks: ${tasks.length}`);
