
import "dart:io";
import "package:sage_mainframe/models/models.dart";
import "package:sage_mainframe/services/invoice_service.dart";

void main() async {
  final client = Client(
    id: "test",
    name: "Dakshinayan",
    contact: ClientContact(name: "Priyajit", email: "test@test.com", phone: "123", address: "Bolpur", website: "test"),
    contractDate: DateTime.now(),
    serviceType: "Marketing",
    packageType: "Growth Package",
    weeklyPosts: 5,
    weeklyReels: 2,
  );
  
  try {
    final pdfBytes = await InvoiceGenerator.generateInvoiceBytes(client, DateTime.now(), 134, []);
    File("test_out.pdf").writeAsBytesSync(pdfBytes);
    print("Saved test_out.pdf, size: ${pdfBytes.length}");
  } catch (e, stack) {
    print("Error: $e\n$stack");
  }
}

