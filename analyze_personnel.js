const fs = require('fs');

const content = fs.readFileSync('current_buildPersonnelTab_ceo.txt', 'utf8');

// Find the start of the employees map
const empMapStart = content.indexOf('...state.employees.asMap().entries.map((entry) {');
if (empMapStart === -1) {
    console.error("Could not find employees map");
    process.exit(1);
}

const beforeEmpMap = content.substring(0, empMapStart);
console.log("Found employees map at index", empMapStart);

// find where the employees map ends
const empMapEnd = content.indexOf('        }).toList(),', empMapStart);
console.log("Employees map ends at index", empMapEnd);

