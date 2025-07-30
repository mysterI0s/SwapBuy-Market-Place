from django.urls import path
from .views import *
app_name = "services"

urlpatterns = [
    path('api/cities/', CityOptionsAPI.as_view(), name='cities'),
    path('api/<int:user_application_id>/add-address/', AddressCreateView.as_view(), name='add-user-address'),
    path('api/userapp/<int:user_application_id>/addresses/', UserApplicationAddressesAPIView.as_view(), name='customer-addresses'),
    path('api/userapp/<int:address_id>/edit-address/', EditAddressAPIView.as_view(), name='edit-address'),
    path('api/userapp/<int:address_id>/delete-address/', DeleteAddressAPIView.as_view(), name='delete-address'),
    path('api/address-info/<int:address_id>/', AddressDetailAPIView.as_view(), name= 'view-address-info'),

    
    path('api/userapplication/<int:user_application_id>/wallet/', UserWalletBalanceAPIView.as_view(), name='user-wallet-balance'),
    path('api/<int:user_app_id>/submit-complaint/', SubmitComplaintAPI.as_view(), name='submit-complaint'),
    
    
    
    
    path('api/product/conditions-options/', ConditionOptionsAPI.as_view(), name='conditions-options'),
    path('api/product/status-options/', StatusOptionsAPI.as_view(), name='status-options'),
    path('api/<int:user_app_id>/add-product/', AddProductAPIView.as_view(), name='add-product'),
    path('api/products/', ProductListView.as_view(), name='product-list'),
    path('api/user-products/<int:user_app_id>/', UserProductsListView.as_view(), name='user-product-list'),
    path('api/product/<int:product_id>/edit/', ProductEditAPI.as_view(), name='edit-product'),
    path('api/product/<int:product_id>/delete/', DeleteProductAPI.as_view(), name='delete-product'),
    path('products/search/', SearchProductView.as_view(), name='search-products'),
    path('products/filter/', ProductFilterView.as_view(), name='product-filter'),
    
    
    
    path('wishlist/add/<int:user_application_id>/', AddProductToWishlistView.as_view(), name='add-product-to-wishlist'),
    path('wishlist/remove/<int:user_application_id>/<int:product_id>/', RemoveProductFromWishlistView.as_view(), name='remove-product-from-wishlist'),
    path('wishlist/<int:user_application_id>/products/', WishlistProductsView.as_view(), name='wishlist-products'),
    
    
    path('api/status-request-swap/', StatusRequestSwapOptionsAPI.as_view(), name='status-request-swap'),
    path('api/payment-method-request-swap/', PaymentMethodRequestSwapOptionsAPI.as_view(), name='payment-method-request-swap'),        
    path('api/payment-status-request-swap/', PaymentStatusRequestSwapOptionsAPI.as_view(), name='payment-status-request-swap'),    
    path('api/delivery-type-request-swap/', DeliveryTypeRequestSwapOptionsAPI.as_view(), name='delivery-type-request-swap'),
    path('api/request-swap/<int:requester_id>/<int:product_requested_id>/', RequestSwapCreateAPIView.as_view(), name='request-swap-create'),
    path('api/user/<int:user_id>/sent-swaps/', UserSentSwapsAPIView.as_view(), name='user-sent-swaps'),
    path('api/user/<int:user_id>/received-swaps/', UserReceivedSwapsAPIView.as_view(), name='user-received-swaps'),
    path('api/request-swap/<int:swap_id>/update-offered/', RequestSwapUpdateProductOfferedAPIView.as_view(), name='update-request-swap-offered'),
    path('api/request-swap/<int:swap_id>/cancel/',RequestSwapCancelAPIView.as_view(),name='request-swap-cancel'),
    path('api/product/<int:product_id>/swap-requests/', RequestSwapListForProductAPI.as_view(), name='product-swap-requests'),   
    
    path('api/swap-requests/<int:swap_request_id>/process/', ProcessSwapRequestAPIView.as_view(), name='process_swap_request'),
    path('api/swap-requests/<int:swap_request_id>/detail/', SwapRequestDetailAPIView.as_view(), name='swap-request-detail'),
    
    path('delivery/orders/<int:order_id>/<int:delivery_id>/process/', DeliveryAcceptOrderAPIView.as_view(), name='delivery-process-order'),
    path('delivery/orders/available/', AvailableOrdersForDeliveryAPIView.as_view(), name='available-orders-for-delivery'),
    path('delivery/<int:delivery_id>/orders-available/', AvailableOrdersForDeliveryByCityAPIView.as_view(), name='delivery-orders-available-by-city'),
    path('delivery/order_status/', OrderStatusSwapOrderOptionsAPI.as_view(), name='order-status'),
    path('orders/<int:order_id>/update-status/', UpdateSwapOrderStatusAPIView.as_view(), name='update-order-status'),
    path('api/swap-orders/for-delivery/<int:delivery_id>/', SwapOrdersForSpecificDeliveryAPIView.as_view(),name='swap-orders-for-specific-delivery'),
    path('orders/<int:order_id>/', SwapOrderDetailAPIView.as_view(), name='order-detail'),    
    
    path('swap-order/<int:order_id>/rate-delivery/', RateSwapOrderDeliveryAPIView.as_view(), name='rate-swap-order-delivery'),
    path('swap-order/<int:order_id>/rate-seller/', RateSwapOrderSellerAPIView.as_view(), name='rate-swap-order-seller'),
    path('swap-order/<int:order_id>/rate-buyer/', RateSwapOrderBuyerAPIView.as_view(), name='rate-swap-order-buyer'),
    
    
     
    # path("api/swap-orders/delivery/<int:delivery_id>/ratings/", SwapDeliveryRatingsAPIView.as_view(),name="swaporder-delivery-ratings"),    
    # path("api/swap-orders/seller/<int:user_id>/ratings/",SwapSellerRatingsAPIView.as_view(),name="swaporder-seller-ratings"),
    # path("api/swap-orders/buyer/<int:user_id>/ratings/",SwapBuyerRatingsAPIView.as_view(),name="swaporder-buyer-ratings"),
    # path("api/swap-orders/user/<int:user_id>/average-ratings/",UserAverageRatingAPIView.as_view(),name="swaporder-user-average-ratings"),
    
    
    
    
    path('api/status-request-buy/', StatusRequestBuyingOptionsAPI.as_view(), name='status-request-buy'),
    path('api/payment-method-request-buy/', PaymentMethodRequestBuyingOptionsAPI.as_view(), name='payment-method-request-buy'),        
    path('api/payment-status-request-buy/', PaymentStatusRequestBuyingOptionsAPI.as_view(), name='payment-status-request-buy'),    
    path('api/delivery-type-request-buy/', DeliveryTypeRequestBuyingOptionsAPI.as_view(), name='delivery-type-request-buy'),
    path('api/request-buy/requester/<int:requester_id>/product/<int:product_requested_id>/',RequestBuyingCreateAPIView.as_view(), name='buy-request-create'),
    path('api/buy-requests/<int:buy_request_id>/update/', RequestBuyingUpdateAPIView.as_view(), name='buy-request-update'),
    path('api/user/<int:user_id>/sent-buy-requests/', UserSentBuyRequestsAPIView.as_view(), name='user-sent-buy-requests'),
    path('api/user/<int:user_id>/buy-requests-received/', UserReceivedBuyRequestsAPIView.as_view(), name='user-received-buy-requests'),
    path('api/buy-request/<int:buy_id>/cancel/', RequestBuyingCancelAPIView.as_view(), name='cancel-buy-request'), 
    path('api/product/<int:product_id>/buy-requests/', RequestBuyingListForProductAPI.as_view(), name='product-buy-requests'),   
    
    
    path('api/all-buy-requests/', RequestBuyingListAPIView.as_view(), name='buy-request-list'),
    
    
    path('api/buy-requests/<int:buy_request_id>/process/', ProcessBuyRequestAPIView.as_view(), name='process-buy-request'),
    path('api/buy-requests/<int:buy_request_id>/', BuyRequestDetailAPIView.as_view(), name='buy-request-detail'),
    path('api/buy-orders/<int:order_id>/delivery/<int:delivery_id>/process/',DeliveryAcceptBuyOrderAPIView.as_view(), name='buy-order-delivery-process'), 
    path('api/buy-orders/available-for-delivery/', AvailableBuyOrdersForDeliveryAPIView.as_view(),name='available-buy-orders-for-delivery'),   
    path('api/buy-orders/available-for-delivery/<int:delivery_id>/',AvailableBuyOrdersForDeliveryByCityAPIView.as_view(),name='available-buy-orders-for-delivery-by-city'),    
    path('delivery/buy-order-status/', OrderStatusBuyOrderOptionsAPI.as_view(), name='buy-order-status'),
    path('api/buy-orders/<int:order_id>/update-status/', UpdateBuyOrderStatusAPIView.as_view(),name='update-buy-order-status'),
    path('api/buy-orders/for-delivery/<int:delivery_id>/',BuyOrdersForSpecificDeliveryAPIView.as_view(), name='buy-orders-for-specific-delivery'),
    path('api/buy-orders/<int:order_id>/detail/',BuyOrderDetailAPIView.as_view(),name='buy-order-detail'),


    path('api/buy-orders/<int:order_id>/rate-delivery/', RateBuyOrderDeliveryAPIView.as_view(), name='rate-buy-order-delivery'),
    path('api/buy-orders/<int:order_id>/rate-seller/', RateBuyOrderSellerAPIView.as_view(), name='rate-buy-order-seller'),
    path('api/buy-orders/<int:order_id>/rate-buyer/', RateBuyOrderBuyerAPIView.as_view(), name='rate-buy-order-buyer'),



    # path('buy-orders/delivery/<int:delivery_id>/ratings/', BuyDeliveryRatingsAPIView.as_view(), name='buy-delivery-ratings'),
    # path('buy-orders/seller/<int:user_id>/ratings/', BuySellerRatingsAPIView.as_view(), name='buy-seller-ratings'),
    # path('buy-orders/buyer/<int:user_id>/ratings/', BuyBuyerRatingsAPIView.as_view(), name='buy-buyer-ratings'),
    # path('buy-orders/user/<int:user_id>/average-ratings/', BuyUserAverageRatingAPIView.as_view(), name='buy-user-average-ratings'),


    # path('combined/user/<int:user_id>/average-ratings/', CombinedUserAverageRatingAPIView.as_view(), name='combined-user-average-ratings'),
    # path('combined/delivery/<int:delivery_id>/ratings/', CombinedDeliveryRatingAPIView.as_view(), name='combined-delivery-ratings'),

    path('delivery/ratings-summary/', DeliveryRatingsSummaryAPIView.as_view(), name='delivery-ratings-summary'),
    path('user/ratings-summary/', UserRatingsSummaryAPIView.as_view(), name='user-ratings-summary'),
    
    path('delivery/<int:delivery_id>/accepted-orders/', AcceptedOrdersForDeliveryAPIView.as_view(), name='accepted-orders-for-delivery'),
    path('delivery/<int:delivery_id>/delivered-orders/', DeliveredOrdersForDeliveryAPIView.as_view(), name='delivered-orders-for-delivery'),


    path('create-conversations/<int:user1_id>/<int:user2_id>/', ConversationView.as_view(), name='create-conversation'),
    path('conversations/<int:user_id>/', ConversationAPIView.as_view(), name='user_conversations'),
    path('conversations/messages/<int:conversation_id>/', ConversationMessagesView.as_view(), name='conversation_messages'),
    
    
    
    
    
    
]