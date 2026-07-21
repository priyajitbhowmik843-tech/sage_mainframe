const fs = require('fs');

const injection = `                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: const Text("Personal Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Colors.black87),
                                const SizedBox(width: 6),
                                Text(
                                  employee.phone.isNotEmpty ? employee.phone : 'Not Provided',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 14, color: Colors.black87),
                                const SizedBox(width: 6),
                                Text(
                                  employee.email.isNotEmpty ? employee.email : 'Not Provided',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.black87),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    employee.address.isNotEmpty ? employee.address : 'Not Provided',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (employee.preferredName.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Preferred Name: " + employee.preferredName,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.workLocation.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.business, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Work Location: " + employee.workLocation,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.emergencyContact.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.warning, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Emergency Contact: " + employee.emergencyContact,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.professionalBio.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.description, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Bio: " + employee.professionalBio,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.keySkills.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.build, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Skills: " + employee.keySkills.join(', '),
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.strengths.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.fitness_center, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Strengths: " + employee.strengths.join(', '),
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.workStylePreference.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.track_changes, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Work Style: " + employee.workStylePreference,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            if (employee.interests.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.local_fire_department, size: 14, color: Colors.black87),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Interests: " + employee.interests,
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      EmployeeMetricsPanel(`;

function inject(file) {
    let code = fs.readFileSync(file, 'utf8');
    if (code.includes('const Text("Personal Details"')) {
        console.log("Already injected in " + file);
        return;
    }
    
    code = code.replace("                      EmployeeMetricsPanel(", injection);
    fs.writeFileSync(file, code, 'utf8');
    console.log("Injected in " + file);
}

inject('lib/screens/ceo_dashboard.dart');
inject('lib/screens/cofounder_dashboard.dart');
