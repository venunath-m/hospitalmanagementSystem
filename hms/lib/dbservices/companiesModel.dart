class Company {
  final String logoUrl;
  final String gst;
  final String companyName;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final String branch;
  final String city;
  final String state;
  final String zip;
  final String country;
  Company({
    required this.logoUrl,
    required this.gst,
    required this.companyName,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.branch,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      logoUrl: json['logoUrl'] ?? '',
      gst: json['gstin'] ?? '',
      companyName: json['companyname'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['webSite'] ?? '',
      bankName: json['bankName'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      branch: json['branch'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
      country: json['country'] ?? '',
    );
  }
}
