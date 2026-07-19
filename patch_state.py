import sys

with open('lib/state/app_state.dart', 'r') as f:
    content = f.read()

new_code = '''
class PoolData {
  final double income;
  final double expenses;
  final double netBalance;
  final Map<String, double> shares;

  PoolData({required this.income, required this.expenses, required this.shares}) : netBalance = income - expenses;
}

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
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) { serviceType = matchedClient.serviceType; meId = matchedClient.marketingExecutiveId; break; }
        }
      }
      
      if (serviceType == 'Video Production') continue; // Skip video production

      if (f.isIncome) {
        inc += f.amount;
        double amt = f.amount;
        if (serviceType == 'Marketing' && meId != null && meId.isNotEmpty) {
          double comm = amt * 0.20; marketingEx += comm; amt -= comm;
        }
        if (serviceType.toLowerCase().contains('commerce')) { ritam += amt * 0.80; priyajit += amt * 0.20; }
        else { ritam += amt * 0.50; priyajit += amt * 0.50; }
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
        for (var cl in _clients) {
          if (f.label.contains(cl.name)) { serviceType = cl.serviceType; break; }
        }
      }
      
      if (serviceType != 'Video Production') continue;

      if (f.isIncome) {
        inc += f.amount;
        ritam += f.amount * 0.20; priyajit += f.amount * 0.80;
      } else {
        if (f.category == 'Commission') continue;
        exp += f.amount;
        ritam -= f.amount * 0.50; priyajit -= f.amount * 0.50;
      }
    }
    return PoolData(income: inc, expenses: exp, shares: {'ritam': ritam, 'priyajit': priyajit});
  }
'''

# We need to replace the Map<String, double> get profitShares { ... } block
import re
pattern = r'Map<String, double> get profitShares \{.*?(?=  void approveClientConversion)'
replacement = new_code + '\n'

new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('lib/state/app_state.dart', 'w') as f:
    f.write(new_content)
