class UserModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String canteenRole;
  final bool informDaily;
  final bool informed;
  final String? division;
  final String? department;
  final String? designation;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.canteenRole,
    required this.informDaily,
    required this.informed,
    this.division,
    this.department,
    this.designation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      canteenRole: json['canteenRole']?? 'user',
      informDaily: json['informDaily']?? false,
      informed: json['informed']?? false,
      division: json['division']?? '',
      department: json['department']?? '',
      designation: json['designation']?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "canteenRole": canteenRole,
      "informDaily": informDaily,
      "informed": informed,
      "division": division,
      "department": department,
      "designation": designation,
    };
  }
}
