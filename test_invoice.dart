import "dart:io";
import "package:sage_mainframe/models/models.dart";
import "package:sage_mainframe/services/invoice_service.dart";

void main() async {
  final client = Client(
    id: "test",
    name: "Dakshinayan",
    contact: ClientContact(
      name: "Priyajit",
      email: "test@test.com",
      phone: "123",
      address: "Bolpur",
      website: "test",
    ),
    agreementTerms: "terms",
    paymentTerms: "terms",
    discountPercent: 0,
    resourceLinks: [],
    postRequirements: "reqs",
    contractDate: DateTime.now(),
    status: "Active",
    remarks: "remarks",
    packageType: "Growth Package",
    contractPeriod: "1 Month",
    monthlyPayable: 5100,
    weeklyReels: 8,
    weeklyPosts: 20,
    weeklyCarousels: 0,
    weeklyStories: 0,
    campaigns: [],
    campaignReach: 0,
    paymentsDue: 0,
    followUpDates: [],
    notes: "",
    conversionProbability: 0,
    retentionHealth: "Good",
    nextDueDate: DateTime.now(),
    ecomSkuLogs: [],
    monthlyDiscounts: {},
  );

  try {
    final pdf = await InvoiceGenerator.generateInvoice(
      client,
      DateTime.now(),
      132,
      [],
    );
    print("Generated PDF of length ${pdf.length}");
  } catch (e, stack) {
    print("Error: $e\n$stack");
  }
}
