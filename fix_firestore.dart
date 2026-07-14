
import "dart:io";

void main() {
  final file = File("lib/models/models.dart");
  String content = file.readAsStringSync();

  // Fix Client.toFirestore
  String oldToFirestore = """  Map<String, dynamic> toFirestore() => {
      'clientId': id,
      'name': name,
      'contactName': contact.name,
      'contactEmail': contact.email,
      'contactPhone': contact.phone,
      'contactAddress': contact.address,
      'contactWebsite': contact.website,
      'agreementTerms': agreementTerms,
      'paymentTerms': paymentTerms,
      'discountPercent': discountPercent,
      'resourceLinks': resourceLinks,
      'postRequirements': postRequirements,
      'contractDate': Timestamp.fromDate(contractDate),
      'status': status,
      'remarks': remarks,
      'packageType': packageType,
      'contractPeriod': contractPeriod,
      'monthlyPayable': monthlyPayable,
      'weeklyReels': weeklyReels,
      'weeklyPosts': weeklyPosts,
      'weeklyCarousels': weeklyCarousels,
      'weeklyStories': weeklyStories,
      'campaigns': campaigns,
      'campaignReach': campaignReach,
      'paymentsDue': paymentsDue,
      'followUpDates': followUpDates,
      'notes': notes,
      'conversionProbability': conversionProbability,
      'retentionHealth': retentionHealth,
      'nextDueDate': nextDueDate,""";

  String newToFirestore = """  Map<String, dynamic> toFirestore() => {
      'clientId': id,
      'name': name,
      'contactName': contact.name,
      'contactEmail': contact.email,
      'contactPhone': contact.phone,
      'contactAddress': contact.address,
      'contactWebsite': contact.website,
      'agreementTerms': agreementTerms,
      'paymentTerms': paymentTerms,
      'discountPercent': discountPercent,
      'resourceLinks': resourceLinks,
      'postRequirements': postRequirements,
      'contractDate': Timestamp.fromDate(contractDate),
      'status': status,
      'remarks': remarks,
      'packageType': packageType,
      'contractPeriod': contractPeriod,
      'monthlyPayable': monthlyPayable,
      'weeklyReels': weeklyReels,
      'weeklyPosts': weeklyPosts,
      'weeklyCarousels': weeklyCarousels,
      'weeklyStories': weeklyStories,
      'campaigns': campaigns,
      'campaignReach': campaignReach,
      'paymentsDue': paymentsDue,
      'followUpDates': followUpDates,
      'notes': notes,
      'conversionProbability': conversionProbability,
      'retentionHealth': retentionHealth,
      'nextDueDate': nextDueDate,
      'isWebsiteHandlingActive': isWebsiteHandlingActive,
      'websiteHandlingFee': websiteHandlingFee,""";

  content = content.replaceAll(oldToFirestore, newToFirestore);

  // Fix Client.fromFirestore
  String oldFromFirestore = """      isPaidForMonth: data['isPaidForMonth'] ?? false,
      assignedVideographerId: data['assignedVideographerId'],
      sessionRate: (data['sessionRate'] ?? 0).toDouble(),
      serviceType: data['serviceType'] ?? 'Social Media Management',
      hasMarketingCommission: data['hasMarketingCommission'] ?? false,
      marketingExecutiveId: data['marketingExecutiveId'],
      source: data['source'] ?? 'Inbound',
      isApprovedByCeo: data['isApprovedByCeo'] ?? false,
      contractDate: (data['contractDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      previousStatus: data['previousStatus'] ?? 'Lead',
      paidTill: data['paidTill'],
      ecomPaymentType: data['ecomPaymentType'] ?? 'Fixed Retainer',
      clientSkuRate: (data['clientSkuRate'] ?? 0).toDouble(),
      clientDuplicateSkuRate: (data['clientDuplicateSkuRate'] ?? 0).toDouble(),
      clientCatalogueRate: (data['clientCatalogueRate'] ?? 0).toDouble(),
    );
  }""";

  String newFromFirestore = """      isPaidForMonth: data['isPaidForMonth'] ?? false,
      assignedVideographerId: data['assignedVideographerId'],
      sessionRate: (data['sessionRate'] ?? 0).toDouble(),
      serviceType: data['serviceType'] ?? 'Social Media Management',
      hasMarketingCommission: data['hasMarketingCommission'] ?? false,
      marketingExecutiveId: data['marketingExecutiveId'],
      source: data['source'] ?? 'Inbound',
      isApprovedByCeo: data['isApprovedByCeo'] ?? false,
      contractDate: (data['contractDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      previousStatus: data['previousStatus'] ?? 'Lead',
      paidTill: data['paidTill'],
      ecomPaymentType: data['ecomPaymentType'] ?? 'Fixed Retainer',
      clientSkuRate: (data['clientSkuRate'] ?? 0).toDouble(),
      clientDuplicateSkuRate: (data['clientDuplicateSkuRate'] ?? 0).toDouble(),
      clientCatalogueRate: (data['clientCatalogueRate'] ?? 0).toDouble(),
      isWebsiteHandlingActive: data['isWebsiteHandlingActive'] ?? false,
      websiteHandlingFee: (data['websiteHandlingFee'] ?? 0).toDouble(),
    );
  }""";

  if (content.contains(oldFromFirestore)) {
    content = content.replaceAll(oldFromFirestore, newFromFirestore);
  }

  file.writeAsStringSync(content);
  print("Updated models.dart to include websiteHandling in Firestore serialization.");
}

