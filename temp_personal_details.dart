                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.phone.isNotEmpty ? p.phone : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.email.isNotEmpty ? p.email : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.address.isNotEmpty ? p.address : 'Not Provided',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.description,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Bio: ${p.professionalBio.isNotEmpty ? p.professionalBio : 'Not Provided'}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (p.keySkills.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.build,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Skills: ${p.keySkills.join(', ')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "System Core Persona",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "ACCESS: FULL",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        ...state.employees.asMap().entries.map((entry) {
          final i = entry.key + AppState.personas.length;
          final employee = entry.value;
          final color = _getRoleColor(employee.role);
          final isVideo =
              (employee.hasRole('videographer') ||
                  employee.hasRole('videographer/cinematographer')) &&
              (employee.videoEditorPayType != 'Salary' &&
                  employee.monthlySalary == 0);
          final isVideoEditorPerVideo =
              employee.hasRole('video editor') &&
              (employee.videoEditorPayType == 'Per Video Rate' &&
                  employee.monthlySalary == 0);
          final isEcomExec = employee.hasRole('ecom executive');
          final isVideoEditor = employee.hasRole('video editor');
          final isGraphicsEditor = employee.hasRole('graphics editor') && employee.monthlySalary == 0;
          final isME =
              employee.hasRole('marketing executive') ||
              employee.hasRole('marketing') ||
              employee.hasRole('page management executive');

          double pendingVideoPayout = 0;
          int unpaidVideosCount = 0;
          double pendingSessionPayout = 0;
          int unpaidSessionsCount = 0;
          double pendingDesignPayout = 0;
          int unpaidDesignsCount = 0;

          if (isGraphicsEditor) {
            final unpaidDesigns = state.tasks
                .where((t) => t.assignedTo == employee.id && t.isCompleted && !t.isPaidToGraphicsEditor)
                .toList();
            unpaidDesignsCount = unpaidDesigns.length;
            pendingDesignPayout = unpaidDesignsCount * employee.perDesignRate;
          }

          if (isVideo) {
            final unpaidSessions = state.tasks
                .where(
                  (t) =>
                      t.assignedTo == employee.id &&
                      t.taskType == 'Session' &&
                      t.isCompleted &&
                      !t.isPaidToVideographer,
                )
                .toList();
            unpaidSessionsCount = unpaidSessions.length;
            for (final t in unpaidSessions) {
              final c = state.clients
                  .where((c) => c.id == t.clientId)
                  .firstOrNull;
              if (c != null) pendingSessionPayout += c.sessionRate;
            }
          }
          if (isVideoEditorPerVideo) {
            final unpaidVideos = state.tasks
                .where(
                  (t) =>
                      t.assignedTo == employee.id &&
                      t.taskType != 'Session' &&
                      t.isCompleted &&
                      !t.isPaidToVideographer,
                )
                .toList();
            unpaidVideosCount = unpaidVideos.length;
            pendingVideoPayout = unpaidVideosCount * employee.perVideoRate;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color,
              image: const DecorationImage(
                image: AssetImage('assets/logo/1l.png'),
                fit: BoxFit.scaleDown,
                opacity: 0.15,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ExpansionTile(
              controller: _empExpControllers.putIfAbsent(
                employee.id,
                () => ExpansionTileController(),
              ),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _empExpControllers.forEach((key, controller) {
                    if (key != employee.id && controller.isExpanded)
                      controller.collapse();
                  });
                }
              },
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              title: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.asset(
                        availableAvatars[employee.avatar %
                            availableAvatars.length],
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.preferredName.isNotEmpty
                              ? employee.preferredName
                              : employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${employee.role}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            employee.phone.isNotEmpty
                                ? employee.phone
                                : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            employee.email.isNotEmpty
                                ? employee.email
                                : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              employee.address.isNotEmpty
                                  ? employee.address
                                  : 'Not Provided',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (employee.preferredName.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Preferred Name: ${employee.preferredName}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.workLocation.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Work Location: ${employee.workLocation}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.emergencyContact.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Emergency Contact: ${employee.emergencyContact}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.professionalBio.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.description,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Bio: ${employee.professionalBio}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.keySkills.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.build,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Skills: ${employee.keySkills.join(', ')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.strengths.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Strengths: ${employee.strengths.join(', ')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.workStylePreference.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.track_changes,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Work Style: ${employee.workStylePreference}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.interests.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Interests: ${employee.interests}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
