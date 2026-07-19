const fs = require('fs');
const data = JSON.parse(fs.readFileSync('C:/Users/Priyajit Bhowmik/.gemini/antigravity/brain/d855886f-d8e2-4d1b-8c83-289637657c6b/.system_generated/steps/538/output.txt', 'utf8'));

const poulom = data.data.documents.find(d => d.id === 'EMP-POU-001').data;
console.log('Poulom:', poulom.paymentCleared, poulom.monthlySalary);
