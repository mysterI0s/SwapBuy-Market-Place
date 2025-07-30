class AppApi {
  static String url = "http://10.0.2.2:8000";
  static String urlimage = "http://10.0.2.2:8000/Storage";

  ////////////////////////// Customer Section //////////////////////////

  //Auth
  static String LOGIN = '/User/api/login/';
  static String REGISTER = '/User/signup/';

  //Profile
  static String UPDATEPROFILE(id) =>
      '/User/api/userapplication/$id/edit-profile/';
  static String PROFILE(id) => '/User/profile/userapplication/$id/';
  static String DeleteImageProfile(id) =>
      '/User/api/userapplication/$id/delete-profile-image/';

  //Password
  static String FORGETPASSWORD = '/User/userapplication/forgot-password/';
  static String UPDATEPASSWORD(id) =>
      '/User/api/userapplication/$id/update-password/';

  //Username
  static String FORGETUSERNAME = '/User/api/userapplication/forgot-username/';

  //Address
  static String AddAddress(int id) => '/Service/api/$id/add-address/';
  static String Address(int id) => '/Service/api/userapp/$id/addresses/';
  static String EditAddress(int id) => '/Service/api/userapp/$id/edit-address/';
  static String DeleteAddress(int id) =>
      '/Service/api/userapp/$id/delete-address/';

  //Status
  static String STATUSOPTIONS = '/Service/api/product/status-options/';

  //Condition
  static String CONDITIONOPTIONS = '/Service/api/product/conditions-options/';

  //City
  static String CITIES = '/Service/api/cities/';

  //Product
  static String AddProduct(int id) => '/Service/api/$id/add-product/';
  static String Products(int id) => '/Service/api/user-products/$id/';
  static String EditProduct(int id) => '/Service/api/product/$id/edit/';
  static String DeleteProduct(int id) => '/Service/api/product/$id/delete/';

  //All Product
  static String AllProduct = '/Service/api/products/';

  //Complint
  static String SendComplint(int id) => '/Service/api/$id/submit-complaint/';

  //Wallet
  static String WalletBalance(int id) =>
      '/Service/api/userapplication/$id/wallet/';

  //Search
  static String SearchProduct(String q) => '/Service/products/search/?q=$q';

  //Filter
  static String FilterProduct(
    var min_price,
    var max_price,
    var condition,
    var status,
    var city,
    var order_by,
  ) =>
      '/Service/products/filter/?min_price=$min_price&max_price=$max_price&condition=$condition&status=$status&city=$city&order_by=$order_by';

  //WishList
  static String ProductsWishList(int id) => '/Service/wishlist/$id/products/';
  static String AddProductWishList(int id) => '/Service/wishlist/add/$id/';
  static String RemoveProductWishList(int userId, int productid) =>
      '/Service/wishlist/remove/$userId/$productid/';

  //Swap
  static String RequestSwap(int iduser, int idproduct) =>
      '/Service/api/request-swap/$iduser/$idproduct/';
  static String UpdateSwap(int idswap) =>
      '/Service/api/request-swap/$idswap/update-offered/';
  static String CanceleSwap(int idswap) =>
      '/Service/api/request-swap/$idswap/cancel/';
  static String ListReceivedSwap(int iduser, String order) =>
      '/Service/api/user/$iduser/received-swaps/?order=$order';
  static String ListSentSwap(int iduser, String order) =>
      '/Service/api/user/$iduser/sent-swaps/?order=$order';

  // Process Swap Request
  static String ProcessSwapRequest(int swapRequestId) =>
      '/Service/api/swap-requests/$swapRequestId/process/';

  //Buy
  static String RequestBuy(int iduser, int idproduct) =>
      '/Service/api/request-buy/requester/$iduser/product/$idproduct/';
  static String UpdateBuy(int idbuy) =>
      '/Service/api/buy-requests/$idbuy/update/';
  static String CanceleBuy(int idrequest) =>
      '/Service/api/buy-request/$idrequest/cancel/';
  static String ListReceivedBuy(int iduser, String order) =>
      '/Service/api/user/$iduser/buy-requests-received/?order=$order';
  static String ListSentBuy(int iduser, String order) =>
      '/Service/api/user/$iduser/sent-buy-requests/?order=$order';

  // Process Buy Request
  static String ProcessBuyRequest(int buyRequestId) =>
      '/Service/api/buy-requests/$buyRequestId/process/';

  ////////////////////////// Delivery Section //////////////////////////

  //Auth
  static String REGISTERDelivery = '/User/add-join-request/';

  //Join Request
  static String DeliveryUpdateRequest(int id) => '/User/delivery/$id/edit/';
  static String DeliveryDeleteRequest(int id) =>
      '/User/join-request/$id/delete/';

  //Password
  static String FORGETPASSWORDDelivery = '/User/delivery/forgot-password/';
  static String UPDATEPASSWORDDelivery(id) =>
      '/User/api/delivery/$id/update-password/';

  //Username
  static String FORGETUSERNAMEDelivery = '/User/api/delivery/forgot-username/';

  //Profile
  static String UPDATEPROFILEDelivery(id) =>
      '/User/api/delivery/$id/edit-profile/';
  static String PROFILEDelivery(id) => '/User/profile/delivery/$id/';
  static String DeleteImageProfileDelivery(id) =>
      '/User/api/delivery/$id/delete-profile-image/';

  ////////////////////////// Delivery Order Management //////////////////////////

  // Available Orders for Delivery
  static String AvailableSwapOrdersForDelivery =
      '/Service/delivery/orders/available/';
  static String AvailableBuyOrdersForDelivery =
      '/Service/api/buy-orders/available-for-delivery/';
  static String AvailableOrdersForDeliveryByCity(int deliveryId) =>
      '/Service/delivery/$deliveryId/orders-available/';
  static String AvailableBuyOrdersForDeliveryByCity(int deliveryId) =>
      '/Service/api/buy-orders/available-for-delivery/$deliveryId/';

  // Accept/Reject Orders
  static String AcceptSwapOrder(int orderId, int deliveryId) =>
      '/Service/delivery/orders/$orderId/$deliveryId/process/';
  static String AcceptBuyOrder(int orderId, int deliveryId) =>
      '/Service/api/buy-orders/$orderId/delivery/$deliveryId/process/';

  // Update Order Status
  static String UpdateSwapOrderStatus(int orderId) =>
      '/Service/orders/$orderId/update-status/';
  static String UpdateBuyOrderStatus(int orderId) =>
      '/Service/api/buy-orders/$orderId/update-status/';

  // Get Orders for Specific Delivery Person
  static String SwapOrdersForDelivery(int deliveryId) =>
      '/Service/api/swap-orders/for-delivery/$deliveryId/';
  static String BuyOrdersForDelivery(int deliveryId) =>
      '/Service/api/buy-orders/for-delivery/$deliveryId/';

  // Order Details
  static String SwapOrderDetail(int orderId) => '/Service/orders/$orderId/';
  static String BuyOrderDetail(int orderId) =>
      '/Service/api/buy-orders/$orderId/detail/';

  // Order Status Options
  static String SwapOrderStatusOptions = '/Service/delivery/order_status/';
  static String BuyOrderStatusOptions = '/Service/delivery/buy-order-status/';

  // Accepted Orders for Delivery
  static String AcceptedOrdersForDelivery(int deliveryId) =>
      '/Service/delivery/$deliveryId/accepted-orders/';

  // Delivered Orders for Delivery
  static String DeliveredOrdersForDelivery(int deliveryId) =>
      '/Service/delivery/$deliveryId/delivered-orders/';

  // Rating APIs
  static String RateSwapOrderDelivery(int orderId) =>
      '/Service/swap-order/$orderId/rate-delivery/';
  static String RateSwapOrderSeller(int orderId) =>
      '/Service/swap-order/$orderId/rate-seller/';
  static String RateSwapOrderBuyer(int orderId) =>
      '/Service/swap-order/$orderId/rate-buyer/';
  static String RateBuyOrderDelivery(int orderId) =>
      '/Service/api/buy-orders/$orderId/rate-delivery/';
  static String RateBuyOrderSeller(int orderId) =>
      '/Service/api/buy-orders/$orderId/rate-seller/';
  static String RateBuyOrderBuyer(int orderId) =>
      '/Service/api/buy-orders/$orderId/rate-buyer/';

  // Ratings Summary
  static String SwapDeliveryRatings(int deliveryId) =>
      '/Service/api/swap-orders/delivery/$deliveryId/ratings/';
  static String SwapSellerRatings(int userId) =>
      '/Service/api/swap-orders/seller/$userId/ratings/';
  static String SwapBuyerRatings(int userId) =>
      '/Service/api/swap-orders/buyer/$userId/ratings/';
  static String BuyDeliveryRatings(int deliveryId) =>
      '/Service/buy-orders/delivery/$deliveryId/ratings/';
  static String BuySellerRatings(int userId) =>
      '/Service/buy-orders/seller/$userId/ratings/';
  static String BuyBuyerRatings(int userId) =>
      '/Service/buy-orders/buyer/$userId/ratings/';
  static String UserAverageRating(int userId) =>
      '/Service/api/swap-orders/user/$userId/average-ratings/';
  static String BuyUserAverageRating(int userId) =>
      '/Service/buy-orders/user/$userId/average-ratings/';

  // Chat/Conversation APIs
  static String CreateConversation(int user1Id, int user2Id) =>
      '/Service/create-conversations/$user1Id/$user2Id/';
  static String GetAllConversations(int userId) =>
      '/Service/conversations/$userId/';
  static String GetAllMessagesForConversation(int conversationId) =>
      '/Service/conversations/messages/$conversationId/';
}
