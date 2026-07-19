const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}
const db = admin.firestore();

async function fix() {
  const empRef = db.collection('employees').doc('EMP-POU-001');
  const doc = await empRef.get();
  if (doc.exists) {
    const data = doc.data();
    let pm = data.pendingPayMonth || '';
    let amt = data.pendingPayAmount || 0;
    
    const items = pm.split(',').map(s => s.trim());
    let removed = false;
    const newItems = items.filter(item => {
      if (item.includes('Biswanath emporium')) {
        removed = true;
        return false;
      }
      return true;
    });
    
    if (removed) {
      let newPm = newItems.join(', ');
      if (newPm === '') newPm = null;
      let newAmt = amt - 3000;
      if (newAmt < 0) newAmt = 0;
      
      await empRef.update({
        pendingPayMonth: newPm,
        pendingPayAmount: newAmt
      });
      console.log('Fixed EMP-POU-001: pm=' + newPm + ' amt=' + newAmt);
    } else {
      console.log('Nothing to remove');
    }
  }
}
fix().then(() => process.exit(0)).catch(console.error);
