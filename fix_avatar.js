const fs = require('fs');
let code = fs.readFileSync('lib/widgets/team_members_view.dart', 'utf8');

const target = `                      Container(
                        margin: const EdgeInsets.only(right: 16, top: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            availableAvatars[emp.avatarIndex % availableAvatars.length],
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                          ),
                        ),
                      ),`;

const replacement = `                      Container(
                        margin: const EdgeInsets.only(right: 16, top: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                        ),
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.7,
                            child: Image.asset(
                              availableAvatars[emp.avatarIndex % availableAvatars.length],
                              fit: BoxFit.cover,
                              width: 64,
                              height: 64,
                            ),
                          ),
                        ),
                      ),`;

if (code.includes('availableAvatars[emp.avatarIndex % availableAvatars.length]')) {
    code = code.replace(target, replacement);
    fs.writeFileSync('lib/widgets/team_members_view.dart', code, 'utf8');
    console.log('Fixed avatar sizing');
} else {
    console.log('Target not found');
}
