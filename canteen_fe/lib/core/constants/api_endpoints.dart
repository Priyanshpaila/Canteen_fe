// Base URL
const String baseUrl = 'http://192.168.13.74:8000/api';

// Sub URLs
const String userUrl = '$baseUrl/users';
const String mealsUrl = '$baseUrl/meals';
const String priceUrl = '$baseUrl/price';
const String guestsUrl = '$baseUrl/guests';
const String metaUrl = '$baseUrl/meta';
const String exportUrl = '$baseUrl/export';

// Auth URLs
const String loginUrl = '$userUrl/login';
const String signupUrl = '$userUrl/signup';
const String changepinUrl = '$userUrl/change-pin';
const String logoutUrl = '$userUrl/logout';

// User URLs
const String informdailyUrl = '$userUrl/inform-daily';
const String markinformedUrl = '$userUrl/mark-informed';
const String informedusersUrl = '$userUrl/informed-users'; // Admin/Superadmin
const String profileUrl = '$userUrl/me'; 

// Superadmin
const String updateUserRoleUrl = '$userUrl/update-role';
const String getAllUserUrl = '$userUrl/users';
String deleteUserUrl(String userId) => '$userUrl/$userId';

// DIVISION
const String getAllDivisionsUrl = '$metaUrl/division';
const String createDivisionUrl = '$metaUrl/division';
String updateDivisionUrl(String id) => '$metaUrl/division/$id';
String deleteDivisionUrl(String id) => '$metaUrl/division/$id';

// DEPARTMENT
const String getAllDepartmentsUrl = '$metaUrl/department';
const String createDepartmentUrl = '$metaUrl/department';
String updateDepartmentUrl(String id) => '$metaUrl/department/$id';
String deleteDepartmentUrl(String id) => '$metaUrl/department/$id';

// DESIGNATION
const String getAllDesignationsUrl = '$metaUrl/designation';
const String createDesignationUrl = '$metaUrl/designation';
String updateDesignationUrl(String id) => '$metaUrl/designation/$id';
String deleteDesignationUrl(String id) => '$metaUrl/designation/$id';

// Meal Price URLs
const String setMealPriceUrl = priceUrl; // POST
const String getMealPricesUrl = priceUrl; // GET
String updateMealPriceUrl(String priceId) => '$priceUrl/$priceId'; // PATCH
String deleteMealPriceUrl(String priceId) => '$priceUrl/$priceId'; // DELETE

// Meal Endpoints (User, Admin, Superadmin access)
const String markMealUrl = mealsUrl; // POST /meals
const String getMealsUrl = mealsUrl; // GET /meals
String deleteMealUrl(String mealId) => '$mealsUrl/$mealId'; // DELETE /meals/:id

// Guest Meal Endpoints (Admin/Superadmin only)
const String createGuestMealUrl = guestsUrl; // POST /guests
const String getGuestMealsUrl = guestsUrl; // GET /guests
String updateGuestMealUrl(String id) => '$guestsUrl/$id'; // PUT /guests/:id
String deleteGuestMealUrl(String id) => '$guestsUrl/$id'; // DELETE /guests/:id

const String autoMarkMealsUrl = '$mealsUrl/auto-mark'; // POST /meals/auto-mark

// Export (Admin/Superadmin)
const String exportMonthlyMealsUrl =
    '$exportUrl/monthly-meals'; // GET /export/monthly-meals








//Use above del func like this 

// final response = await http.delete(
//   Uri.parse(deleteUserUrl('64b92fa7a1c98b3d9e6f31a4')),
//   headers: {
//     'Authorization': 'Bearer $yourToken',
//     'Content-Type': 'application/json',
//   },
// );