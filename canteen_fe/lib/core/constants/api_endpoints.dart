//Base Url

//Use this for testing
const String baseUrl = 'http://192.168.13.74:8000/api';


//sub Url
const String userUrl = '$baseUrl/user';
const String mealsUrl = '$baseUrl/meals';
const String priceUrl = '$baseUrl/price';
const String guestsUrl = '$baseUrl/guests';
const String metaUrl = '$baseUrl/meta';
const String exportUrl = '$baseUrl/export';


//Auth Url
const String loginUrl = '$userUrl/login';
const String signupUrl = '$userUrl/signup';
const String changepinUrl = '$userUrl/change-pin';
const String logoutUrl = '$userUrl/logout';


//User Url
const String informdailyUrl = '$userUrl/inform-daily';
const String markinformedUrl = '$userUrl/mark-informed';

//Admin and superadmin access
const String informedusersUrl = '$userUrl/informed-users';


//Superadmin Access
const String updateUserRoleUrl = '$userUrl/update-role';
String deleteUserUrl(String userId) => '$userUrl/$userId';
//Use above del func like this 

// final response = await http.delete(
//   Uri.parse(deleteUserUrl('64b92fa7a1c98b3d9e6f31a4')),
//   headers: {
//     'Authorization': 'Bearer $yourToken',
//     'Content-Type': 'application/json',
//   },
// );

