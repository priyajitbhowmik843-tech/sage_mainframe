const fs = require('fs');
const data = JSON.parse(fs.readFileSync('C:/Users/Priyajit Bhowmik/.gemini/antigravity/brain/d855886f-d8e2-4d1b-8c83-289637657c6b/.system_generated/steps/538/output.txt', 'utf8'));
const clients = data.data.documents.filter(d => d.path.startsWith('clients/'));
const ecomClients = clients.filter(c => c.data.clientType === 'E-Commerce' || c.data.clientType === 'E-commerce');
console.log('Ecom clients count:', ecomClients.length);
if (ecomClients.length > 0) {
  console.log(ecomClients.map(c => ({ name: c.data.name, paymentCleared: c.data.paymentCleared, ecomSkuLogs: c.data.ecomSkuLogs })));
}
