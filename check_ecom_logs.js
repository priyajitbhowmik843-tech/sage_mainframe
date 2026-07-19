const fs = require('fs');
const data = JSON.parse(fs.readFileSync('C:/Users/Priyajit Bhowmik/.gemini/antigravity/brain/d855886f-d8e2-4d1b-8c83-289637657c6b/.system_generated/steps/538/output.txt', 'utf8'));
const clients = data.data.documents.filter(d => d.path.startsWith('clients/'));
const clientsWithLogs = clients.filter(c => c.data.ecomSkuLogs && c.data.ecomSkuLogs.length > 0);
console.log('Clients with SKU logs count:', clientsWithLogs.length);
if (clientsWithLogs.length > 0) {
  console.log(clientsWithLogs.map(c => ({ name: c.data.name, status: c.data.status, ecomPaymentType: c.data.ecomPaymentType, serviceType: c.data.serviceType, logsCount: c.data.ecomSkuLogs.length })));
}
