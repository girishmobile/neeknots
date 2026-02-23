import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neeknots/models/product_model.dart' hide Variants, Images;

import '../core/component/component.dart';
import '../core/firebase/auth_service.dart';
import '../main.dart';
import '../models/product_details_model.dart';
import '../service/api_config.dart';
import '../service/gloable_status_code.dart';
import '../service/network_repository.dart';

class ProductProvider with ChangeNotifier {
  var tetName = TextEditingController();
  var tetDesc = TextEditingController();
  var tetQty = TextEditingController();
  var tetPrice = TextEditingController();

  List<Images> productImages = [];

  final Map<int, TextEditingController> qtyControllers = {};
  final Map<int, TextEditingController> priceControllers = {};

  // initialize controllers based on variants

  void initializeVariantController(List<Variants>? variants) {
    qtyControllers.clear();
    priceControllers.clear();
    if (variants != null) {
      for (final v in variants) {
        final key = v.id ?? 0;

        qtyControllers[key] = TextEditingController(
          text: v.inventoryQuantity?.toString() ?? '',
        );
        priceControllers[key] = TextEditingController(text: v.price ?? '');
      }
    }
  }

  // dispose controllers to avoid memory leaks
  void disposeControllers() {
    for (final c in qtyControllers.values) {
      c.dispose();
    }
    for (final c in priceControllers.values) {
      c.dispose();
    }
    qtyControllers.clear();
    priceControllers.clear();
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  String _searchQuery = "";

  String get searchQuery => _searchQuery;
  String _selectedCategory = "All";
  String _selectedStatus = "All";

  // Expose current filter values
  String get selectedCategory => _selectedCategory;

  String get selectedStatus => _selectedStatus;

  List<Products> get filteredProducts {
    return _products.where((p) {
      final matchesSearch = p.title.toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      return matchesSearch;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;

    if (status == "all") {
      _lastId = null;
      _products.clear();
      getProductList(context: navigatorKey.currentContext!);
    } else {
      _lastId = null;
      _products.clear();
      getProductList(context: navigatorKey.currentContext!, status: status);
    }

    notifyListeners();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Draft":
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _status = "Active";

  String get status => _status;

  void setFilter(String value) {
    _status = value;
    notifyListeners();
  }

  bool _isEdit = false;

  bool get isEdit => _isEdit;

  void toggleEdit() {
    _isEdit = !_isEdit;
    notifyListeners();
  }

  void setEdit(bool value) {
    _isEdit = value;
    notifyListeners();
  }

  void reset() {
    _searchQuery = "";
    _selectedCategory = "All";
    _selectedStatus = "All";
    _status = "Active";
    _isEdit = false;
    _currentIndex = 0;
    _imageFiles.clear();
    tetName.clear();
    tetDesc.clear();
    tetPrice.clear();
    tetQty.clear();
    notifyListeners();
  }

  File? _imageFile;

  File? get imageFile => _imageFile;

  void setImageFilePath({required File img}) {
    _imageFile = img;
    notifyListeners();
  }

  void imagePathClear() {
    _imageFile = null;
    notifyListeners();
  }

  final List<File> _imageFiles = [];

  List<File> get imageFiles => _imageFiles;

  void addImage(File file) {
    _imageFiles.add(file);
    notifyListeners();
  }

  void removeImage(int index) {
    _imageFiles.removeAt(index);

    notifyListeners();
  }

  String addProductStatus = "Active";
  String category = "Category 1";

  //--------------------------------------------------------------API Calling -----------------------------------------------------
  bool _isFetching = false;
  bool _isImageUpdating = false;

  bool get isFetching => _isFetching;

  bool get isImageUpdating => _isImageUpdating;

  bool _hasMore = true;
  final int _limit = 100; // items per page
  bool get hasMore => _hasMore;
  List<Products> _products = [];

  List<Products> get products => _products;
  int? _lastId; // last fetched product ID
  int _currentPage = 0;

  int get currentPage => _currentPage;

  Future<void> getProductListPagination({
    int? limit,
    String? status,
    required BuildContext context,
    bool reset = false,
  }) async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    notifyListeners();

    try {
      final effectiveLimit = limit ?? _limit;

      if (reset) {
        _lastId = null;
        _products.clear();
        _hasMore = true;
        _currentPage = 0;
      }

      String url =
          '${await ApiConfig.productsUrl}?limit=$effectiveLimit&order=id+asc&status=$status';
      if (status != null && status.isNotEmpty) url += "&status=$status";
      if (_lastId != null) url += '&since_id=$_lastId';

      final response = await callGETMethod(url: url);

      if (globalStatusCode == 200) {
        final fetchedProducts =
            ProductModel.fromJson(json.decode(response)).products ?? [];

        if (fetchedProducts.isNotEmpty) {
          // Remove duplicates before adding
          final newItems = fetchedProducts
              .where((p) => !_products.any((e) => e.id == p.id))
              .toList();

          if (newItems.isNotEmpty) {
            _products.addAll(newItems);
            _products.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));

            _lastId = newItems.last.id;
            _currentPage++;
          } else {
            // No new items → stop pagination
            _hasMore = false;
          }
        } else {
          _hasMore = false;
        }
        // stop fetching if we have loaded all 278
        if (_products.length >= 278) {
          _hasMore = false;
          //   debugPrint("✅ Loaded all 278 products.");
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint("⚠️ Unexpected Error: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> getProductList({
    int? limit,

    String? status,
    required BuildContext context,
  }) async {
    _isFetching = true;
    notifyListeners();

    try {
      final effectiveLimit = limit ?? _limit;

      String url =
          '${await ApiConfig.productsUrl}?limit=$effectiveLimit&order=id+asc';

      if (status != null && status.isNotEmpty) {
        final encodedTitle = "&status=$status";
        url += encodedTitle;
      }

      if (_lastId != null) {
        url += '&since_id=$_lastId';
      }

      final response = await callGETMethod(url: url);

      if (globalStatusCode == 200) {
        final fetchedProducts =
            ProductModel.fromJson(json.decode(response)).products ?? [];

        if (fetchedProducts.isEmpty || fetchedProducts.length < _limit) {
          _hasMore = false;
        }

        if (fetchedProducts.isNotEmpty) {
          if (_lastId == null /*|| searchTitle != null*/ ) {
            _products.clear();
          }
          _products.addAll(fetchedProducts);
          _lastId = fetchedProducts.last.id; // move cursor forward
        }

        notifyListeners();
      }
      _isFetching = false;
      notifyListeners();
    } catch (e) {
      _products.clear();
      debugPrint("⚠️ Unexpected Error: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  void resetProducts() {
    _products = [];

    _hasMore = true;
    _lastId = null;
    notifyListeners();
  }

  ProductDetailsModel? _productDetailsModel;

  ProductDetailsModel? get productDetailsModel => _productDetailsModel;

  void setIsImageUpdating(bool val) {
    _isImageUpdating = val;
    notifyListeners();
  }

  Future<void> getProductById({required String productId}) async {
    try {
      final url = "${await ApiConfig.getImageUrl}/$productId.json";
      final response = await callGETMethod(url: url);
      if (globalStatusCode == 200) {
        final jsonData = json.decode(response);

        _productDetailsModel = ProductDetailsModel.fromJson(
          jsonData['product'],
        );
      }
    } catch (e) {
      debugPrint("⚠️ Unexpected Error: $e");
    } finally {}
  }

  int _totalProductCount = 0;

  int get totalProductCount => _totalProductCount;

  Future<void> getTotalProductCount() async {
    _isFetching = true;
    notifyListeners();
    try {
      final response = await callGETMethod(
        url: await ApiConfig.totalProductUrl,
      );

      if (globalStatusCode == 200) {
        final data = json.decode(response);

        _totalProductCount = data["count"] ?? 0;
        _isFetching = false;
        notifyListeners();
      }
    } catch (e) {
      _totalProductCount = 0;
      _isFetching = false;
      notifyListeners();
    }

    _isFetching = false;
    notifyListeners();
  }

  Future<void> fetchImagesForProduct(ProductDetailsModel product) async {
    if (product.variants == null) return;

    _isFetching = true;
    notifyListeners();

    await Future.wait(
      product.variants!.map((item) async {
        item.imageUrl = await fetchProductImage(
          productId: item.productId ?? 0,
          variantId: item.id ?? 0,
        );
      }),
    );

    _isFetching = false;
    notifyListeners();
  }

  final AuthService _authService = AuthService();

  Future<String?> addProductInFirebase({
    required String name,
    required String image,
    required bool status,
    required int productID,
  }) async {
    try {
      final productCollection = await _authService.getStoreSubCollection(
        _authService.productCollection,
      );
      // 🔹 2. Add new filter
      final _ = await productCollection.add({
        "name": name,
        "image": image,
        "product_id": productID,
        "status": status,
        "created_date": DateTime.now(),
      });

      notifyListeners();

      // _setLoading(false);
      return null; // means success
    } catch (e) {
      debugPrint("Error adding new filter: $e");
      //_setLoading(false);
      return "Error adding new filter";
    }
  }

  Future<void> uploadProductImage({
    required String imagePath,
    required int productId,
    required String productName,
  }) async {
    _isImageUpdating = true;
    notifyListeners();

    final bytes = await File(imagePath).readAsBytes();

    final base64Image = base64Encode(bytes);

    String? result = await addProductInFirebase(
      status: false,
      name: productName,
      image: base64Image,
      productID: productId,
    );

    _isImageUpdating = false;
    notifyListeners();

    // Agar result null hai => success
    if (result == null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text("Product uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> updateProductStatus({
    required String uid,
    required String title,
  }) async {
    try {
      final productCollection = await _authService.getStoreSubCollection(
        _authService.productCollection,
      );
      await productCollection.doc(uid).update({
        "status": true,
        //"approved_date": DateTime.now(), // optional
        title: DateTime.now(), // optional
      });
      //   await getAllPendingRequest();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateProductStatusWeb({
    required String uid,
    required String storeName, // you must pass the store name or store docId
    required String title,
  }) async {
    try {
      /*final productCollection = await _authService.getStoreSubCollection(
        _authService.productCollection,
      );*/
      final productCollection = _firestore
          .collection(storeName)
          .doc(_authService.productCollection)
          .collection(_authService.productCollection)
          .doc(uid); // actual product document ID

      /*await productCollection.update({
        "status": true,
        title: DateTime.now(),
      });
      print("✅ Product $uid approved successfully");*/
      await productCollection.delete();
      //   await getAllPendingRequest();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadProductImageViaAdmin({
    required String imagePath,
    required int productId,
    required String uid,
  }) async {
    _isImageUpdating = true;
    notifyListeners();

    final urlString =
        "${await ApiConfig.baseUrl}/products/$productId/images.json";

    final response = await callPostMethodWithToken(
      body: {
        "image": {"attachment": imagePath},
      },
      url: urlString,
    );

    if (globalStatusCode == 200) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text("Product Approved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      await updateProductStatus(uid: uid, title: "approved_date");

      final data = json.decode(response);
      final imageJson = data["image"];

      if (imageJson != null) {
        //  final newImage = Images.fromJson(imageJson);
        // productImages.add(newImage);
        _isImageUpdating = false;
        notifyListeners(); // ✅ UI refresh
      }
    } else {
      _isImageUpdating = false;
      notifyListeners();
    }
  }

  Future<void> uploadProductImageViaAdminWeb({
    required String imagePath,
    required int productId,
    required String storeRoom,
    required String uid,
  }) async {
    _isImageUpdating = true;
    notifyListeners();

    try {
      final urlString =
          "${await ApiConfig.baseUrl}/products/$productId/images.json";

      final response = await callPostMethodWithToken(
        body: {
          "image": {"attachment": imagePath},
        },
        url: urlString,
      );

      if (globalStatusCode == 200) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text("Product Approved successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        await updateProductStatusWeb(
          uid: uid,
          title: "approved_date",
          storeName: storeRoom,
        );

        final data = json.decode(response);
        final imageJson = data["image"];

        if (imageJson != null) {
          //  final newImage = Images.fromJson(imageJson);
          // productImages.add(newImage);
          _isImageUpdating = false;
          notifyListeners(); // ✅ UI refresh
        }
      } else {
        _isImageUpdating = false;
        notifyListeners();
      }
    } catch (e) {
      showCommonDialog(title: "e$e", context: navigatorKey.currentContext!);
    }
  }

  Future<void> deleteProductImage({
    required int imageId,
    required int productId,
    required ProductProvider provider,
  }) async {
    _isImageUpdating = true;
    notifyListeners();
    final urlString =
        "${await ApiConfig.baseUrl}/products/$productId/images/$imageId.json";

    await callDeleteMethod(url: urlString);

    if (globalStatusCode == 200) {
      productImages.removeWhere((img) => img.id == imageId);

      if (currentIndex >= productImages.length && currentIndex > 0) {
        setCurrentIndex(productImages.length - 1); // ✅ Correct
      }
      _isImageUpdating = false;
      notifyListeners();
    } else {
      _isImageUpdating = false;
      notifyListeners();
    }
  }

  Future<void> updateProductById({
    String? title,
    String? description,
    required int productId,
    List<Map<String, dynamic>>? variants,
  }) async {
    final urlString = "${await ApiConfig.baseUrl}/products/$productId.json";

    final Map<String, dynamic> productData = {"id": productId};
    if (title != null) productData["title"] = title;
    if (description != null) productData["body_html"] = description;
    if (variants != null) productData["variants"] = variants;
    final _ = await callPutMethodWithToken(
      params: {"product": productData},
      url: urlString,
    );
    if (globalStatusCode == 200) {
    } else {}
  }

  DateTime? _startDate;
  DateTime? _endDate;

  DateTime? get startDate => _startDate;

  DateTime? get endDate => _endDate;

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearDateRange() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<Map<String, dynamic>> _allPendingRequest = [];

  List<Map<String, dynamic>> get allPendingRequest => _allPendingRequest;

  Future<void> getAllPendingRequest() async {
    _setLoading(true);
    try {
      final productCollection = await _authService.getStoreSubCollection(
        _authService.productCollection,
      );
      final snapshot = await productCollection
          .where('status', isEqualTo: false) // ← only false status
          .orderBy('created_date', descending: true)
          .get();

      _allPendingRequest = snapshot.docs.map((doc) {
        return {
          "id": doc.id, // ← Firestore document ID
          "name": doc['name'] ?? '',
          "status": doc['status'] ?? '',
          "created_date": doc['created_date'] ?? '',
          "image": doc['image'] ?? '',
          "product_id": doc['product_id'] ?? '',
        };
      }).toList();

      // Initialize counts to 0
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      notifyListeners();
      debugPrint("Error fetching filter list: $e");
    }
  }

  int _pendingCount = 0; // Provider me variable define karo
  int get pendingCount => _pendingCount;

  Future<void> getCountPendingRequest() async {
    _setLoading(true);
    try {
      final productCollection = await _authService.getStoreSubCollection(
        _authService.productCollection,
      );
      final snapshot = await productCollection
          .where('status', isEqualTo: false) // only false status
          .orderBy('created_date', descending: true)
          .get();
      _pendingCount = snapshot.docs.length;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _pendingCount = 0;
      _setLoading(false);
      notifyListeners();
      debugPrint("Error fetching pending products: $e");
    }
  }
}
