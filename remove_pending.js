const fs = require('fs');

const file = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/ceo_dashboard.dart";
let text = fs.readFileSync(file, "utf-8");

// Remove _teamSubTab declaration
text = text.replace(/  String _teamSubTab = 'MEMBERS'; \/\/ 'MEMBERS' or 'REVIEWS'\n/g, "");

// Remove the Row with buttons
const startStr = `        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _teamSubTab = 'MEMBERS'),`;
const endStr = `        const SizedBox(height: 16),

        if (_teamSubTab == 'MEMBERS') ...[`;

const startIndex = text.indexOf(startStr);
const endIndex = text.indexOf(endStr);

if (startIndex !== -1 && endIndex !== -1) {
    text = text.substring(0, startIndex) + text.substring(endIndex + `        const SizedBox(height: 16),\n\n        if (_teamSubTab == 'MEMBERS') ...[\n`.length);
    console.log("Removed buttons and MEMBERS if statement");
} else {
    console.log("Could not find buttons");
}

// Remove the closing bracket of MEMBERS and the PENDING WORK block
// Finding the closing bracket:
const endMembersStr = `          }),
        ],

        if (_teamSubTab == 'PENDING WORK') ...[`;
const endPendingStr = `                ),
              );
            }),
        ],
      ],
    );
  }`;

const endMembersIndex = text.indexOf(endMembersStr);
const endPendingIndex = text.indexOf(endPendingStr);

if (endMembersIndex !== -1 && endPendingIndex !== -1) {
    const afterPendingIndex = endPendingIndex + `                ),
              );
            }),
        ],`.length;
    
    text = text.substring(0, endMembersIndex + `          }),`.length) + "\n      ],\n    );\n  }";
    console.log("Removed PENDING WORK block");
} else {
    console.log("Could not find PENDING WORK block");
}

fs.writeFileSync(file, text, "utf-8");
