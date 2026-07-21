import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  final oldBlock =
      '''    // 1. Process all finance entries for R&P cumulative (matches ledger exactly)
    for (var f in _finances) {
      if (f.isIncome) {
        double amt = f.amount;
        double pAmt = amt;

        // Determine service type and ME from the FinanceEntry or matching Client
        String serviceType = f.serviceType ?? 'Miscellaneous';
        String? meId = f.marketingExecutiveId;

        if (f.clientId != null) {
          final c = _clients.firstWhere(
            (cl) => cl.id == f.clientId,
            orElse: () => Client(
              id: '',
              name: '',
              contact: ClientContact(name: '', email: '', phone: ''),
              contractDate: DateTime.now(),
            ),
          );
          if (c.id.isNotEmpty) {
            serviceType = f.serviceType ?? c.serviceType;
            meId = c.marketingExecutiveId;
          }
        } else {
          Client? matchedClient;
          for (var cl in _clients) {
            if (f.label.contains(cl.name)) {
              matchedClient = cl;
              break;
            }
          }
          if (matchedClient != null) {
            serviceType = f.serviceType ?? matchedClient.serviceType;
            meId = matchedClient.marketingExecutiveId;
          }
        }

        // Apply ME commission ONLY if serviceType is Marketing
        if (serviceType == 'Marketing' && meId != null && meId.isNotEmpty) {
          double comm = amt * 0.20;
          marketingEx += comm;
          pAmt -= comm;
        }

        // Apply co-founder splits based on serviceType
        if (serviceType.toLowerCase().contains('commerce')) {
          ritam += pAmt * 0.80;
          priyajit += pAmt * 0.20;
        } else if (serviceType == 'Video Production') {
          ritam += pAmt * 0.20;
          priyajit += pAmt * 0.80;
        } else {
          ritam += pAmt * 0.50;
          priyajit += pAmt * 0.50;
        }
      } else {
        // Skip actual commission payouts from R&P deduction (they belong to ME)
        if (f.category == 'Commission') continue;

        if (serviceType.toLowerCase().contains('commerce')) {
          ritam -= f.amount * 0.80;
          priyajit -= f.amount * 0.20;
        } else if (serviceType == 'Video Production') {
          ritam -= f.amount * 0.20;
          priyajit -= f.amount * 0.80;
        } else {
          ritam -= f.amount * 0.50;
          priyajit -= f.amount * 0.50;
        }
      }
    }''';

  final newBlock =
      '''    // 1. Process all finance entries for R&P cumulative (matches ledger exactly)
    for (var f in _finances) {
      // Determine service type and ME from the FinanceEntry or matching Client
      String serviceType = f.serviceType ?? 'Miscellaneous';
      String? meId = f.marketingExecutiveId;

      if (f.clientId != null) {
        final c = _clients.firstWhere(
          (cl) => cl.id == f.clientId,
          orElse: () => Client(
            id: '',
            name: '',
            contact: ClientContact(name: '', email: '', phone: ''),
            contractDate: DateTime.now(),
          ),
        );
        if (c.id.isNotEmpty) {
          serviceType = f.serviceType ?? c.serviceType;
          meId = c.marketingExecutiveId;
        }
      } else {
        Client? matchedClient;
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) {
            matchedClient = cl;
            break;
          }
        }
        if (matchedClient != null) {
          serviceType = f.serviceType ?? matchedClient.serviceType;
          meId = matchedClient.marketingExecutiveId;
        }
      }

      if (f.isIncome) {
        double amt = f.amount;
        double pAmt = amt;

        // Apply ME commission ONLY if serviceType is Marketing
        if (serviceType == 'Marketing' && meId != null && meId.isNotEmpty) {
          double comm = amt * 0.20;
          marketingEx += comm;
          pAmt -= comm;
        }

        // Apply co-founder splits based on serviceType
        if (serviceType.toLowerCase().contains('commerce')) {
          ritam += pAmt * 0.80;
          priyajit += pAmt * 0.20;
        } else if (serviceType == 'Video Production') {
          ritam += pAmt * 0.20;
          priyajit += pAmt * 0.80;
        } else {
          ritam += pAmt * 0.50;
          priyajit += pAmt * 0.50;
        }
      } else {
        // Skip actual commission payouts from R&P deduction (they belong to ME)
        if (f.category == 'Commission') continue;

        if (serviceType.toLowerCase().contains('commerce')) {
          ritam -= f.amount * 0.80;
          priyajit -= f.amount * 0.20;
        } else if (serviceType == 'Video Production') {
          ritam -= f.amount * 0.20;
          priyajit -= f.amount * 0.80;
        } else {
          ritam -= f.amount * 0.50;
          priyajit -= f.amount * 0.50;
        }
      }
    }''';

  content = content.replaceFirst(oldBlock, newBlock);
  file.writeAsStringSync(content);
}
