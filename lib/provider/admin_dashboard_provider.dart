import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/main.dart';

import '../core/firebase/FcmService.dart';
import '../core/firebase/auth_service.dart';
import '../core/hive/app_config_cache.dart';
import '../feature/admin/admin_home_page.dart';

class AdminDashboardProvider with ChangeNotifier {
  final tetFullName = TextEditingController();
  final tetEmail = TextEditingController();
  final tetPhone = TextEditingController();
  final tetCountryCodeController = TextEditingController();
  final tetStoreName = TextEditingController();
  final tetWebsiteUrl = TextEditingController();
  final tetAccessToken = TextEditingController();
  final tetVersionCode = TextEditingController();
  final tetAppLogo = TextEditingController();
  bool _status = false;

  bool get status => _status;

  void setStatus(bool value) {
    _status = value;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool _isUpdated = false;

  bool get isUpdated => _isUpdated;

  void _setUpdating(bool val) {
    _isUpdated = val;
    notifyListeners();
  }

  List<Map<String, dynamic>> _allUsers = [];

  List<Map<String, dynamic>> get allUsers => _allUsers;
  List<Map<String, dynamic>> _filteredUsers = [];

  List<Map<String, dynamic>> get userData => _filteredUsers;

  String _searchQuery = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUsers() async {
    _setLoading(true);
    try {
      final querySnapshot = await _firestore
          .collection(_authService.storesCollection)
          .get();
      _allUsers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data["uid"] = doc.id;
        return data;
      }).toList();

      applySearch(_searchQuery); // Apply any current search
      _setLoading(false);
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
    _setLoading(false);
  }

  void applySearch(String query) {
    _searchQuery = query.toLowerCase();

    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((user) {
        final name = user["name"]?.toString().toLowerCase() ?? "";
        final email = user["email"]?.toString().toLowerCase() ?? "";
        return name.contains(_searchQuery) || email.contains(_searchQuery);
      }).toList();
    }

    notifyListeners();
  }

  Future<void> updateUser({required String docId, String? token}) async {
    try {
      _setUpdating(true);
      notifyListeners();
      await FirebaseFirestore.instance
          .collection(_authService.storesCollection)
          .doc(docId)
          .update({
            "name": tetFullName.text.trim(),
            "email": tetEmail.text.trim(),
            "mobile": tetPhone.text.trim(),
            "store_name": tetStoreName.text.trim(),
            "accessToken": tetAccessToken.text.trim(),
            "version_code": tetVersionCode.text.trim(),
            "logo_url": tetAppLogo.text.trim(),
            "website_url": tetWebsiteUrl.text.trim(),
            "active_status": _status,
          });
      _setUpdating(false);
      notifyListeners();
      if (token != null && token.isNotEmpty) {

        getUsersByStoreName(tetStoreName.text.trim(),);
       // await sendFCMNotification(bodyMap: payload);
      }

      //fetchUsers();
      _setUpdating(false);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating user: $e");
      _setUpdating(false);
      notifyListeners();
    }
  }

  Future<void> updateUserStatus({
    required String docId,
    String? token,
    required bool status,
  }) async {
    try {
      _setUpdating(true);
      notifyListeners();
      await FirebaseFirestore.instance
          .collection(_authService.storesCollection)
          .doc(docId)
          .update({"active_status": status});
      _setUpdating(false);
      notifyListeners();
      if (token != null && token.isNotEmpty) {


        FcmService.sendToToken(deviceToken: token, title: tetFullName.text.trim(), body: status
          ? "Your account is activated, open the app"
          : "Your account has been deactivated, please contact support",);
       /* await sendPushNotification(fcmToken: token, title: tetFullName.text.trim(),  body: status
            ? "Your account is activated, open the app"
            : "Your account has been deactivated, please contact support",);*/
      }

      //fetchUsers();
      _setUpdating(false);
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating user: $e");
      _setUpdating(false);
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _contacts = [];

  List<Map<String, dynamic>> get contacts => _contacts;
  final AuthService _authService = AuthService();

  Future<void> getAllContactList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final users = await _authService.getAllContactList();

      _contacts = users; // Already a List<Map<String, dynamic>>
    } catch (e) {
      debugPrint("❌ Failed to fetch users: $e");
      _contacts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _contactCount = 0;

  int get contactCount => _contactCount;

  Future<void> getUnseenContactCount() async {
    _isLoading = true;
    notifyListeners();

    try {
      var count = await _authService.getUnseenContactCount();
      _contactCount = count ?? 0;
    } catch (e) {
      debugPrint("❌ Failed to fetch unseen count: $e");
      _contactCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsSeen() async {
    try {
      await _authService.markAllAsSeen();
      getUnseenContactCount();
      notifyListeners();

      debugPrint("✅ All contacts marked as seen");
    } catch (e) {
      debugPrint("❌ Failed to mark all as seen: $e");
    }
  }

  List<Map<String, dynamic>> _allOrderFilterList = [];

  List<Map<String, dynamic>> get allOrderFilterList => _allOrderFilterList;

  Future<void> getAllFilterOrderList() async {
    _setLoading(true);
    try {
      final users = await _authService.getAllFilterOrderList();

      _allOrderFilterList = users;
      notifyListeners();

      _setLoading(false);
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> updateAllStatusesToFirebase({required String storeName}) async {
    /* final contactCollection = await _authService.getStoreSubCollection(
      _authService.orderFilterCollection,
    );*/

    final contactCollection = _firestore
        .collection(storeName)
        .doc(_authService.orderFilterCollection)
        .collection(_authService.orderFilterCollection);
    _setLoading(true);
    try {
      final batch = _firestore.batch();
      for (var item in _allOrderFilterList) {
        final docRef = contactCollection.doc(item["id"]);
        batch.update(docRef, {"status": item["status"]});
      }
      await batch.commit();
      debugPrint("✅ All statuses updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating statuses: $e");
    }
    _setLoading(false);
  }

  /// 🟩 Update local checkbox state only (not Firebase yet)
  /*
  void toggleStatus(String uid, bool value) {
    final index = _allOrderFilterList.indexWhere((item) => item["uid"] == uid);
    if (index != -1) {
      _allOrderFilterList[index]["status"] = value;
      notifyListeners();
    }
  }
*/

  void toggleStatus(String uid, bool value) {
    final index = _allOrderFilterList.indexWhere((item) => item["id"] == uid);
    if (index != -1) {
      // Create a new map instead of mutating the old one
      final updatedItem = {..._allOrderFilterList[index], "status": value};
      _allOrderFilterList[index] = updatedItem;
      notifyListeners();
    }
  }

  Future<String?> addNewOrderFilter({
    required String name,
    required bool status,
    required String storeName,
  }) async {
    _setLoading(true);
    try {
      /*final contactCollection = await _authService.getStoreSubCollection(
        _authService.orderFilterCollection,
      );
*/
      final contactCollection = _firestore
          .collection(storeName)
          .doc(_authService.orderFilterCollection)
          .collection(_authService.orderFilterCollection);

      // 🔹 1. Check if name already exists (case-insensitive)
      final existing = await contactCollection
          .where("title", isEqualTo: name.trim())
          .get();

      if (existing.docs.isNotEmpty) {
        _setLoading(false);
        return "Filter with this name already exists!";
      }

      // 🔹 2. Add new filter
      final docRef = await contactCollection.add({
        "title": name.trim(),
        "status": status,
      });

      // 🔹 3. Update local list immediately
      _allOrderFilterList.add({
        "uid": docRef.id,
        "title": name.trim(),
        "status": status,
      });
      notifyListeners();

      _setLoading(false);
      return null; // means success
    } catch (e) {
      debugPrint("Error adding new filter: $e");
      _setLoading(false);
      return "Error adding new filter";
    }
  }

  Future<void> deleteOrderFilter({
    required String storeName,
    required String uid,
  }) async {
    try {
      // Get the collection reference
      final collectionRef = _firestore
          .collection(storeName)
          .doc(_authService.orderFilterCollection)
          .collection(_authService.orderFilterCollection);

      // Check if the document exists
      final docSnapshot = await collectionRef.doc(uid).get();
      if (!docSnapshot.exists) {
        debugPrint('❌ Document with uid $uid does not exist!');
        ScaffoldMessenger.of(
          navigatorKey.currentContext!,
        ).showSnackBar(SnackBar(content: Text('Document does not exist!')));
        return;
      }

      // Delete from Firestore
      await collectionRef.doc(uid).delete();

      // Remove from local list immediately
      _allOrderFilterList.removeWhere((item) => item["id"] == uid);
      notifyListeners();

      debugPrint("✅ Filter deleted: $uid");
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Deleted successfully')));
    } catch (e) {
      debugPrint("❌ Error deleting filter: $e");
      ScaffoldMessenger.of(
        navigatorKey.currentContext!,
      ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
    }
  }

  List<Map<String, dynamic>> activeFilters = [];

  Future<void> addFilter({
    required String title,
    String? status,
    String? financialStatus,
    String? fulfillmentStatus,
    String? createdMinDate,
    String? createdMaxDate,
  }) async {
    final lowerTitle = title.toLowerCase().trim();

    // Prevent duplicate
    final exists = activeFilters.any(
      (filter) => filter['title'].toString().toLowerCase() == lowerTitle,
    );
    if (exists) return;
    final contactCollection = await _authService.getStoreSubCollection(
      _authService.orderFilterCollection,
    );
    final docRef = await contactCollection.add({
      "title": title,
      "status": status,
      "financialStatus": financialStatus,
      "fulfillmentStatus": fulfillmentStatus,
      "createdMinDate": createdMinDate,
      "createdMaxDate": createdMaxDate,
    });

    activeFilters.add({
      "id": docRef.id,
      "title": title,
      "status": status,
      "financialStatus": financialStatus,
      "fulfillmentStatus": fulfillmentStatus,
      "createdMinDate": createdMinDate,
      "createdMaxDate": createdMaxDate,
    });

    notifyListeners();
  }

  List<Map<String, dynamic>> _storeCounts = [];

  List<Map<String, dynamic>> get storeCounts => _storeCounts;

 /* Future<void> getStoreUserCounts() async {
    _setLoading(true);
    notifyListeners();
    try {
      final querySnapshot = await _firestore
          .collection(_authService.storesCollection)
          .get();

      // Temporary map to count users per store
      final Map<String, int> countsMap = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final storeName = data['store_name'] ?? '';
        if (countsMap.containsKey(storeName)) {
          countsMap[storeName] = countsMap[storeName]! + 1;
        } else {
          countsMap[storeName] = 1;
        }
      }

      // Convert map to list of maps
      _storeCounts = countsMap.entries.map((e) {
        return {'store_name': e.key, 'count': e.value};
      }).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to fetch store counts: $e");
    }
  }
*/
  Future<void> getStoreUserCounts() async {
    _setLoading(true);
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection(_authService.storesCollection)
          .get();

      final Map<String, Map<String, dynamic>> storeMap = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final storeName = data['store_name'] ?? '';

        if (storeMap.containsKey(storeName)) {
          storeMap[storeName]!['count'] =
              (storeMap[storeName]!['count'] ?? 0) + 1;
        } else {
          storeMap[storeName] = {
            ...data,          // ✅ store full document data
            'uid': doc.id,    // ✅ store document id
            'count': 1        // ✅ store count
          };
        }
      }

      _storeCounts = storeMap.values.toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to fetch store counts: $e");
    }
  }

  Future<void> getUserStoresByEmail() async {
    _setLoading(true);
    notifyListeners();

    try {
      final email = await AppConfigCache.getUserEmail();

      final querySnapshot = await _firestore
          .collection('stores')
          .where('email', isEqualTo: email)
          .get();

      _storeCounts = querySnapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'uid': doc.id,
        };
      }).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      throw Exception("Failed to fetch stores: $e");
    }
  }

  List<Map<String, dynamic>> storeList = [];
  int userCount = 0;
  bool isLoadingUsers = false;

  Future<void> getAdminStoreUsers() async {
    try {
      isLoadingUsers = true;
      notifyListeners();

      final config = await AppConfigCache.loadConfig();
      final storeName = config["storeName"];

      if (storeName == null || storeName.isEmpty) {
        throw "Store name not found";
      }

      setStoreName(storeName );

      final querySnapshot = await FirebaseFirestore.instance
          .collection("stores")
          .where("store_name", isEqualTo: storeName)
          .get();

      storeList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data["uid"] = doc.id;
        return data;
      }).toList();

      userCount = storeList.length;
    } catch (e) {
      debugPrint("Error fetching users: $e");
    } finally {
      isLoadingUsers = false;
      notifyListeners();
    }
  }

  String? storeName;

  void setStoreName(String name) {
    storeName = name;
    notifyListeners();
  }

  Future<void> getUsersByStoreName(String storeName) async {
    try {
      _setLoading(true);
      notifyListeners();
      final querySnapshot = await _firestore
          .collection(_authService.storesCollection)
          .where('store_name', isEqualTo: storeName)
          .get();

      //if (querySnapshot.docs.isEmpty) return [];

      _allUsers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // optional: add document ID
        return data;
      }).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to fetch users for $storeName: $e");
    }
  }

  List<Map<String, dynamic>> _allPendingRequest = [];

  List<Map<String, dynamic>> get allPendingRequest => _allPendingRequest;
  Future<void> getStoreCollectionData({
    required String storeName,
    required String collectionName, // e.g., 'contact_us'
  }) async {
    _setLoading(true);
    notifyListeners();
    try {
      final querySnapshot = await _firestore
          .collection(storeName)
          .doc(collectionName) // if each store has a doc, adjust if needed
          .collection(collectionName)
          //   .where('status', isEqualTo: false) // ← only false status
          // .orderBy('created_date', descending: true)
          .get();

      final dataList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (collectionName == _authService.productCollection) {
        _allPendingRequest = dataList;
        notifyListeners();
      }
      if (collectionName == _authService.contactUsCollection) {
        _contacts = dataList;
        notifyListeners();
      }
      if (collectionName == _authService.orderFilterCollection) {
        _allOrderFilterList = dataList;
        notifyListeners();
      }

      _setLoading(false);
      notifyListeners();
      /* return dataList;*/
    } catch (e) {
      throw Exception("Failed to fetch $collectionName for $storeName: $e");
    }
  }

  final List<Color> professionColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.grey,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.tealAccent,
    Colors.yellowAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
    Colors.indigoAccent,
    Colors.limeAccent,
    Colors.amberAccent,
    Colors.deepOrangeAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.deepPurpleAccent,
    Colors.grey.shade300,
    Colors.grey.shade400,
    Colors.grey.shade500,
    Colors.blue.shade200,
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.orange.shade200,
    Colors.purple.shade200,
    Colors.teal.shade200,
    Colors.yellow.shade200,
    Colors.pink.shade200,
    Colors.cyan.shade200,
    Colors.indigo.shade200,
    Colors.lime.shade200,
    Colors.amber.shade200,
    Colors.deepOrange.shade200,
  ];
  Map<String, Color> professionColorMap = {};

  Color getProfessionColor(String profession, int index) {
    if (!professionColorMap.containsKey(profession)) {
      // Assign color based on index (wrap around if > 50)
      professionColorMap[profession] =
          professionColors[index % professionColors.length];
    }
    return professionColorMap[profession]!;
  }

  int _selectedIndex = 0;
  String? _selectedSection;
  final List<AdminUserModel> _users = [
    AdminUserModel(
      name: "Girish Chauhan",
      email: "girish@redefinesolution.com",
      phone: "9558697986",
      isActive: true,
    ),
    AdminUserModel(
      name: "Sameer Khan",
      email: "sammerkhan@example.com",
      phone: "9558697987",
      isActive: false,
    ),
    AdminUserModel(
      name: "Jane Smith",
      email: "jane@example.com",
      phone: "9558697988",
      isActive: true,
    ),
  ];
  final List<Map<String, dynamic>> dashboardItems = [
    {"title": "Users", "icon": Icons.people},
    {"title": "Orders", "icon": Icons.shopping_cart},
    {"title": "Products", "icon": Icons.inventory},
    {"title": "Contacts", "icon": Icons.contact_mail},
    {"title": "Filter", "icon": Icons.filter_alt},
  ];

  // Getters
  int get selectedIndex => _selectedIndex;

  String? get selectedSection => _selectedSection;

  List<AdminUserModel> get users => _users;

  // Methods
  void setSelectedStore(int index) {
    _selectedIndex = index;
    _selectedSection = null;
    notifyListeners();
  }

  void setSelectedSection(String? section) {
    _selectedSection = section;
    notifyListeners();
  }

  void toggleUserStatus(int index, bool value) {
    _users[index].isActive = value;
    notifyListeners();
  }

  int usersCount = 0;
  int ordersCount = 0;
  int productsCount = 0;
  int contactsCount = 0;

  Future<void> fetchStoreCounts({required String storeName}) async {
    _setLoading(true);
    notifyListeners();

    try {
      // Product count
      // ✅ Clear previous counts before fetching new data
      productsCount = 0;
      contactsCount = 0;
      ordersCount = 0;
      usersCount = 0;
      notifyListeners(); // optional — updates UI immediately if shown
      final productSnapshot = await _firestore
          .collection(storeName)
          .doc(
            _authService.productCollection,
          ) // if each store has a doc, adjust if needed
          .collection(_authService.productCollection)
          .where('status', isEqualTo: false) // ← only false status
          .orderBy('created_date', descending: true)
          .get();
      productsCount = productSnapshot.docs.length;

      final contactSnapshot = await _firestore
          .collection(storeName)
          .doc(_authService.contactUsCollection) // a document
          .collection(_authService.contactUsCollection)
          .get();

      // Contact Us count
      contactsCount = contactSnapshot.docs.length;

      final orderSnapshot = await _firestore
          .collection(storeName)
          .doc(_authService.orderFilterCollection) // a document
          .collection(_authService.orderFilterCollection)
          .get();
      ordersCount = orderSnapshot.docs.length;

      final usersSnapshot = await _firestore
          .collection(_authService.storesCollection)
          .where('store_name', isEqualTo: storeName)
          .get();
      usersCount = usersSnapshot.docs.length;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      /*  showCommonDialog(
        title: "title$contactsCount ${e}",
        context: navigatorKey.currentContext!,
      );*/
      _setLoading(false);
      notifyListeners();
      throw Exception("Failed to fetch counts for $storeName: $e");
    }
  }

  // Helper to get count by title
  int getCountForTitle(String title) {
    switch (title) {
      case "Users":
        return usersCount;
      case "Orders":
        return ordersCount;
      case "Products":
        return productsCount;
      case "Contacts":
        return contactsCount;
      default:
        return 0;
    }
  }
}
