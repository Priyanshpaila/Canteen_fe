// providers/meta_providers.dart
import 'dart:convert';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final divisionCountProvider = FutureProvider<int>((ref) async {
  final res = await http.get(Uri.parse(getAllDivisionsUrl));
  if (res.statusCode == 200) {
    return jsonDecode(res.body)['count'] ?? 0;
  }
  return 0;
});

final departmentCountProvider = FutureProvider<int>((ref) async {
  final res = await http.get(Uri.parse(getAllDepartmentsUrl));
  if (res.statusCode == 200) {
    return jsonDecode(res.body)['count'] ?? 0;
  }
  return 0;
});

final designationCountProvider = FutureProvider<int>((ref) async {
  final res = await http.get(Uri.parse(getAllDesignationsUrl));
  if (res.statusCode == 200) {
    return jsonDecode(res.body)['count'] ?? 0;
  }
  return 0;
});
