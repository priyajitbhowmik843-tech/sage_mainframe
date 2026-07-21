import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  final poolDataClass = '''
class PoolData {
  final double income;
  final double expenses;
  final double netBalance;
  final Map<String, double> shares;

  PoolData({required this.income, required this.expenses, required this.shares}) : netBalance = income - expenses;
}
''';

  if (!content.contains('class PoolData')) {
    content = content.replaceFirst(
      'class AppState extends ChangeNotifier {',
      poolDataClass + '\nclass AppState extends ChangeNotifier {',
    );
  }

  final replacement = '''
  PoolData get mainPool {
    double inc = 0, exp = 0;
    double ritam = 0.0, priyajit = 0.0, marketingEx = 0.0;
    for (var f in _finances) {
      String serviceType = f.serviceType ?? 'Miscellaneous';
      String? meId = f.marketingExecutiveId;
      if (f.clientId != null) {
        final c = _clients.firstWhere((cl) => cl.id == f.clientId, orElse: () => Client(id: '', name: '', contact: ClientContact(name: '', email: '', phone: ''), contractDate: DateTime.now()));
        if (c.id.isNotEmpty) { serviceType = f.serviceType ?? c.serviceType; meId = c.marketingExecutiveId; }
      } else {
        Client? matchedClient;
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) { matchedClient = cl; break; }
        }
        if (matchedClient != null) {
          serviceType = matchedClient.serviceType;
          meId = matchedClient.marketingExecutiveId;
        }
      }
      
      if (serviceType == 'Video Production') continue;

      if (f.isIncome) {
        inc += f.amount;
        double amt = f.amount;
        double pAmt = amt;
        if (serviceType == 'Marketing' && meId != null && meId.isNotEmpty) {
          double comm = amt * 0.20; marketingEx += comm; pAmt -= comm;
        }
        if (serviceType.toLowerCase().contains('commerce')) { ritam += pAmt * 0.80; priyajit += pAmt * 0.20; }
        else { ritam += pAmt * 0.50; priyajit += pAmt * 0.50; }
      } else {
        if (f.category == 'Commission') continue;
        exp += f.amount;
        ritam -= f.amount * 0.50; priyajit -= f.amount * 0.50;
      }
    }
    return PoolData(income: inc, expenses: exp, shares: {'ritam': ritam, 'priyajit': priyajit, 'marketingEx': marketingEx});
  }

  PoolData get videoPool {
    double inc = 0, exp = 0;
    double ritam = 0.0, priyajit = 0.0;
    for (var f in _finances) {
      String serviceType = f.serviceType ?? 'Miscellaneous';
      if (f.clientId != null) {
        final c = _clients.firstWhere((cl) => cl.id == f.clientId, orElse: () => Client(id: '', name: '', contact: ClientContact(name: '', email: '', phone: ''), contractDate: DateTime.now()));
        if (c.id.isNotEmpty) { serviceType = f.serviceType ?? c.serviceType; }
      } else {
        Client? matchedClient;
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) { matchedClient = cl; break; }
        }
        if (matchedClient != null) {
          serviceType = matchedClient.serviceType;
        }
      }
      
      if (serviceType != 'Video Production') continue;

      if (f.isIncome) {
        inc += f.amount;
        double amt = f.amount;
        ritam += amt * 0.20; priyajit += amt * 0.80;
      } else {
        if (f.category == 'Commission') continue;
        exp += f.amount;
        ritam -= f.amount * 0.50; priyajit -= f.amount * 0.50;
      }
    }
    return PoolData(income: inc, expenses: exp, shares: {'ritam': ritam, 'priyajit': priyajit});
  }

  Map<String, double> get profitShares {
''';

  final regex = RegExp(r'  Map<String, double> get profitShares \{');
  content = content.replaceFirst(regex, replacement);

  file.writeAsStringSync(content);
}
