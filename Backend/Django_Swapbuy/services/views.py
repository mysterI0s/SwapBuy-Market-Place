from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import *
from user.models import *
from .serializers import *
from user.serializers import *


# Get City Options API (Sorted A-Z)
class CityOptionsAPI(APIView):
    def get(self, request):
        cities_options = [display_name for _, display_name in Address.CITIES_OPTIONS]
        sorted_cities_options = sorted(cities_options)  # sorted A --> Z
        return Response(sorted_cities_options)


# Add Address API for UserApplication
class AddressCreateView(APIView):
    authentication_classes = []
    permission_classes = []
    
    
    def post(self, request, user_application_id):
        # Check if the UserApplication exists
        try:
            user_application = UserApplication.objects.get(id=user_application_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User application not found."}, status=status.HTTP_404_NOT_FOUND)

        # Prepare the data with the user_application id
        data = request.data.copy()
        data['user'] = user_application.id  # field name in your Address model is 'user'

        # Serialize and save
        serializer = AddressSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'message': 'Address added successfully.',
                'data': serializer.data
            }, status=status.HTTP_201_CREATED)
        
        return Response({
            'error': 'Failed to add address.',
            'details': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
        

# Display addresses of a specific user
class UserApplicationAddressesAPIView(APIView):
    def get(self, request, user_application_id):
        addresses = Address.objects.filter(user_id=user_application_id)
        
        if not addresses.exists():
            return Response({"error": "No addresses found for this user."}, status=status.HTTP_404_NOT_FOUND)

        serializer = AddressSerializer(addresses, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)





# Edit specific address 
class EditAddressAPIView(APIView):
    authentication_classes = []
    permission_classes = []
    
    
    def put(self, request, address_id):
        try:
            address = Address.objects.get(id=address_id)
        except Address.DoesNotExist:
            return Response({"error": "Address not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = AddressSerializer(address, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response({
                'message': 'Address updated successfully.',
                'data': serializer.data
            }, status=status.HTTP_200_OK)
        
        return Response({
            'error': 'Failed to update address.',
            'details': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)





# Delete Specific Address
class DeleteAddressAPIView(APIView):
    authentication_classes = []
    permission_classes = []
    
    
    def delete(self, request, address_id):
        try:
            address = Address.objects.get(id=address_id)
        except Address.DoesNotExist:
            return Response({"error": "Address not found"}, status=status.HTTP_404_NOT_FOUND)

        address.delete()
        return Response({"message": "Address deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
    
    


# Display address info a specific address

class AddressDetailAPIView(APIView):
    def get(self, request, address_id):
        """
        Retrieve details of a specific address by its ID.
        """
        try:
            # Retrieve the address by its ID
            address = Address.objects.get(id=address_id)
        except Address.DoesNotExist:
            # Return an error if the address does not exist
            return Response({"error": "Address not found."}, status=status.HTTP_404_NOT_FOUND)

        # Serialize and return the address details
        serializer = AddressSerializer(address)
        return Response(serializer.data, status=status.HTTP_200_OK)



##############################################################################################


# Display wallet balance for a specific UserApplication

class UserWalletBalanceAPIView(APIView):
    def get(self, request, user_application_id):
        try:
            wallet = UserWallet.objects.get(user_id=user_application_id)
            return Response({
                "user_application_id": user_application_id,
                "balance": str(wallet.balance)  # convert Decimal to string for JSON safety
            }, status=status.HTTP_200_OK)
        except UserWallet.DoesNotExist:
            return Response({
                "error": "No wallet found for this user."
            }, status=status.HTTP_404_NOT_FOUND)




# User Submit Complaint
class SubmitComplaintAPI(APIView):
    authentication_classes = []
    permission_classes = []
    
    def post(self, request, user_app_id):
        try:
            user_app = UserApplication.objects.get(id=user_app_id)
        except UserApplication.DoesNotExist:
            return Response(
                {"error": "UserApplication not found."},
                status=status.HTTP_404_NOT_FOUND
            )
        
        serializer = ComplaintSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user_app)
            return Response(
                {
                    "message": "Complaint submitted successfully.",
                    "complaint": serializer.data
                },
                status=status.HTTP_201_CREATED
            )
        
        return Response(
            {"error": "Invalid data.", "details": serializer.errors},
            status=status.HTTP_400_BAD_REQUEST
        )








##############################################################################################


# Get Condition Options API 
class ConditionOptionsAPI(APIView):
    def get(self, request):
        conditions_options = [display_name for _, display_name in Product.CONDITION_OPTIONS]
        return Response(conditions_options)





# Get Status Options API 
class StatusOptionsAPI(APIView):
    def get(self, request):
        status_options = [display_name for _, display_name in Product.STATUS_OPTIONS]
        return Response(status_options)






from rest_framework.parsers import MultiPartParser, FormParser


class AddProductAPIView(APIView):
    parser_classes = [MultiPartParser, FormParser]  # to handle file uploads
    authentication_classes = []
    permission_classes = []
    
    def post(self, request, user_app_id):
        # Validate UserApplication exists
        try:
            buyer = UserApplication.objects.get(id=user_app_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "Buyer (UserApplication) not found."}, status=status.HTTP_404_NOT_FOUND)
        
        # Optional: Validate address ID provided and belongs to user
        address_id = request.data.get("id_address")
        if not address_id:
            return Response({"error": "Address ID (id_address) is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            address = Address.objects.get(id=address_id, user=buyer)
        except Address.DoesNotExist:
            return Response({"error": "Address not found or does not belong to this user."}, status=status.HTTP_404_NOT_FOUND)

        # Prepare data for serializer, include buyer and address
        data = request.data.copy()
        data['id_buyer'] = buyer.id
        data['id_address'] = address.id

        serializer = ProductSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return Response({
                "message": "Product added successfully.",
                "product": serializer.data
            }, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)













from datetime import date
from rest_framework.pagination import PageNumberPagination

# List products with pagination (6 per page), ordered by newest first.
class ProductListView(APIView):
    def get(self, request):
        paginator = PageNumberPagination()
        paginator.page_size = 6  # 6 per page

        products = Product.objects.all().order_by('-added_at')
        paginated_products = paginator.paginate_queryset(products, request)

        response_data = []
        for product in paginated_products:
            product_data = {
                "product": ProductSerializer(product, context={'request': request}).data,
                "address": AddressSerializer(product.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product.id_buyer, context={'request': request}).data if product.id_buyer else None
            }
            response_data.append(product_data)

        return paginator.get_paginated_response(response_data)


# List products for a specific UserApplication (buyer)
class UserProductsListView(APIView):
    def get(self, request, user_app_id):
        paginator = PageNumberPagination()
        
        # Filter products for this user and order by newest
        products = Product.objects.filter(id_buyer_id=user_app_id).order_by('-added_at')
        paginated_products = paginator.paginate_queryset(products, request)
        

        response_data = []
        for product in paginated_products:
            product_data = {
                "product": ProductSerializer(product, context={'request': request}).data,
                "address": AddressSerializer(product.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product.id_buyer, context={'request': request}).data if product.id_buyer else None
            }
            response_data.append(product_data)

        return paginator.get_paginated_response(response_data)




# Edit specific product
class ProductEditAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def put(self, request, product_id):
        try:
            product_obj = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({'detail': 'Product not found'}, status=404)

        serializer = EditProductSerializer(product_obj, data=request.data, partial=True)
        if serializer.is_valid():
            updated_product = serializer.save()
            
            # Build full product info with address and buyer
            product_requested_data = {
                "product": ProductSerializer(updated_product, context={'request': request}).data,
                "address": AddressSerializer(updated_product.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(updated_product.id_buyer, context={'request': request}).data 
                        if updated_product.id_buyer else None
            }
            
            return Response({
                "message": "Product updated successfully.",
                "product_info": product_requested_data
            }, status=200)

        return Response(serializer.errors, status=400)


# Delete a specific product by ID
class DeleteProductAPI(APIView):
    
    authentication_classes = []
    permission_classes = []
    
    
    
    def delete(self, request, product_id):
        try:
            product = Product.objects.get(id=product_id)
            product.delete()
            return Response(
                {"message": "Product deleted successfully."},
                status=status.HTTP_200_OK
            )
        except Product.DoesNotExist:
            return Response(
                {"error": "Product not found."},
                status=status.HTTP_404_NOT_FOUND
            )



from django.db.models import Q

# Search products by name or description (case-insensitive) with pagination
class SearchProductView(APIView):
    def get(self, request):
        paginator = PageNumberPagination()
        
        print(f"Query parameters: {request.query_params}")
        search_query = request.query_params.get('q', '').strip()
        print(f"Search query: '{search_query}'")

        if not search_query:
            return Response({"error": "Search query cannot be empty."}, status=status.HTTP_400_BAD_REQUEST)

        # Search by name or description
        products = Product.objects.filter(
            Q(name__icontains=search_query) | Q(description__icontains=search_query)
        )
        print(f"Number of products found: {products.count()}")

        paginated_products = paginator.paginate_queryset(products, request)

        response_data = []
        for product in paginated_products:
            product_requested_data = {
                "product": ProductSerializer(product, context={'request': request}).data,
                "address": AddressSerializer(product.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product.id_buyer, context={'request': request}).data if product.id_buyer else None
            }
            response_data.append(product_requested_data)

        return paginator.get_paginated_response(response_data)





from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response
from rest_framework import status
from .models import Product
from .serializers import ProductSerializer

# Filter products by price, condition, status with optional ordering
class ProductFilterView(APIView):
    def get(self, request):
        paginator = PageNumberPagination()
        products = Product.objects.all()

        # Filter params
        min_price = request.query_params.get('min_price')
        max_price = request.query_params.get('max_price')
        condition = request.query_params.get('condition')
        status_param = request.query_params.get('status')
        order_by = request.query_params.get('order_by')  # optional
        city = request.query_params.get('city')  

        # Apply filters
        if min_price is not None:
            products = products.filter(price__gte=float(min_price))
        
        if max_price is not None:
            products = products.filter(price__lte=float(max_price))
        
        if condition is not None:
            products = products.filter(condition=condition)
        
        if status_param is not None:
            products = products.filter(status=status_param)
            
        if city is not None:
            # Filter products whose related address city matches the filter (case-insensitive)
            products = products.filter(id_address__city__iexact=city)

        # Apply ordering only if provided
        if order_by == "added_oldest":
            # Order products by oldest added date first (ascending)
            products = products.order_by('added_at')
        elif order_by == "added_newest":
            # Order products by newest added date first (descending)
            products = products.order_by('-added_at')
        elif order_by == "price_low_high":
            # Order products by price from lowest to highest
            products = products.order_by('price')
        elif order_by == "price_high_low":
            # Order products by price from highest to lowest
            products = products.order_by('-price')
                    
            
        else:
            # If no order_by is provided, default ordering is newest to oldest
            products = products.order_by('-added_at')

        # Pagination
        paginated_products = paginator.paginate_queryset(products, request)

        response_data = []
        for product in paginated_products:
            product_requested_data = {
                "product": ProductSerializer(product, context={'request': request}).data,
                "address": AddressSerializer(product.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product.id_buyer, context={'request': request}).data if product.id_buyer else None
            }
            response_data.append(product_requested_data)

        return paginator.get_paginated_response(response_data)


##########################################################################################



from django.shortcuts import get_object_or_404
class AddProductToWishlistView(APIView):
    authentication_classes = []  
    permission_classes = []      

    def post(self, request, user_application_id):
        # Check if the UserApplication exists
        try:
            user_app = UserApplication.objects.get(id=user_application_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User application not found."}, status=status.HTTP_404_NOT_FOUND)

        # Get the product_id from the request data
        product_id = request.data.get('product_id')
        if not product_id:
            return Response({"error": "product_id is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Check if the product exists
        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({"error": "Product not found."}, status=status.HTTP_404_NOT_FOUND)

        # Get or create the user's wishlist
        wishlist, created = Wishlist.objects.get_or_create(user=user_app)

        # Check if the product is already in the wishlist
        if wishlist.products.filter(id=product.id).exists():
            return Response({"message": "Product already in wishlist."}, status=status.HTTP_200_OK)

        # Add the product to the wishlist
        wishlist.products.add(product)
        wishlist.save()

        return Response({
            "message": f"Product '{product.name}' added to wishlist successfully.",
            "wishlist_id": wishlist.id,
            "products_count": wishlist.products.count()
        }, status=status.HTTP_201_CREATED)
        
        
        
        
        
        

#  remove a product from a user’s wishlist 

class RemoveProductFromWishlistView(APIView):
    authentication_classes = []  
    permission_classes = []      

    def delete(self, request, user_application_id, product_id):
        # Check if the UserApplication exists
        try:
            user_app = UserApplication.objects.get(id=user_application_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User application not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the wishlist exists for this user
        try:
            wishlist = user_app.wishlist
        except Wishlist.DoesNotExist:
            return Response({"error": "This user does not have a wishlist."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the product exists
        try:
            product = Product.objects.get(id=product_id)
        except Product.DoesNotExist:
            return Response({"error": "Product not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the product is actually in the user's wishlist
        if not wishlist.products.filter(id=product_id).exists():
            return Response({"message": "Product is not in the wishlist."}, status=status.HTTP_200_OK)

        # Remove the product from the wishlist
        wishlist.products.remove(product)
        wishlist.save()

        return Response({
            "message": f"Product '{product.name}' removed from wishlist.",
            "remaining_products_count": wishlist.products.count()
        }, status=status.HTTP_200_OK)




# View List all products in a user's wishlist

class WishlistProductsView(APIView):
    authentication_classes = []  
    permission_classes = []     

    def get(self, request, user_application_id):
        # Check if the UserApplication exists
        try:
            user_app = UserApplication.objects.get(id=user_application_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User application not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the user has a wishlist
        try:
            wishlist = user_app.wishlist
        except Wishlist.DoesNotExist:
            return Response({"message": "This user does not have a wishlist."}, status=status.HTTP_200_OK)

        # Get all products in the wishlist
        products = wishlist.products.all()

        # If wishlist is empty, return a simple message
        if not products.exists():
            return Response({
                "wishlist_id": wishlist.id,
                "products_count": 0,
                "message": "The wishlist is empty."
            }, status=status.HTTP_200_OK)

        # Build custom list with product + address data
        data = []
        for product in products:
            product_data = ProductSerializer(product, context={'request': request}).data
            address_data = AddressSerializer(product.id_address, context={'request': request}).data
            data.append({
                "product": product_data,
                "address": address_data
            })

        return Response({
            "wishlist_id": wishlist.id,
            "products_count": products.count(),
            "products": data
        }, status=status.HTTP_200_OK)





##########################################################################################




# Get status RequestSwap API 
class StatusRequestSwapOptionsAPI(APIView):
    def get(self, request):
        status_options = [display_name for _, display_name in RequestSwap.STATUS_CHOICES]
        return Response(status_options)




# Get payment_method RequestSwap API 
class PaymentMethodRequestSwapOptionsAPI(APIView):
    def get(self, request):
        payment_method_options = [display_name for _, display_name in RequestSwap.PAYMENT_METHOD_CHOICES]
        return Response(payment_method_options)



# Get payment_status RequestSwap API 
class PaymentStatusRequestSwapOptionsAPI(APIView):
    def get(self, request):
        payment_status_options = [display_name for _, display_name in RequestSwap.PAYMENT_STATUS_CHOICES]
        return Response(payment_status_options)





# Get delivery_type RequestSwap API 
class DeliveryTypeRequestSwapOptionsAPI(APIView):
    def get(self, request):
        delivery_type_options = [display_name for _, display_name in RequestSwap.DELIVERY_TYPE_CHOICES]
        return Response(delivery_type_options)








# Create a swap request between two products
class RequestSwapCreateAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request, requester_id, product_requested_id):
        # Fetch requester
        requester = get_object_or_404(UserApplication, pk=requester_id)

        # Fetch requested product
        product_requested = get_object_or_404(Product, pk=product_requested_id)

        # Get offered product id from request data
        product_offered_id = request.data.get('product_offered')
        if not product_offered_id:
            return Response({"error": "product_offered is required."}, status=status.HTTP_400_BAD_REQUEST)

        product_offered = get_object_or_404(Product, pk=product_offered_id)

        # Get id_address from request data
        id_address = request.data.get('id_address')
        if not id_address:
            return Response({"error": "Selected address is required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            address = Address.objects.get(pk=id_address)
        except Address.DoesNotExist:
            return Response({"error": "Address not found."}, status=status.HTTP_404_NOT_FOUND)

        # Get delivery_type from request data
        delivery_type = request.data.get('delivery_type')
        if not delivery_type:
            return Response({"error": "Delivery type is required."}, status=status.HTTP_400_BAD_REQUEST)
        if delivery_type not in dict(RequestSwap.DELIVERY_TYPE_CHOICES):
            return Response({"error": f"Delivery type must be one of {list(dict(RequestSwap.DELIVERY_TYPE_CHOICES).keys())}."}, status=status.HTTP_400_BAD_REQUEST)

        # Get payment_method from request data
        payment_method = request.data.get('payment_method')
        if not payment_method:
            return Response({"error": "Payment method is required."}, status=status.HTTP_400_BAD_REQUEST)
        if payment_method not in dict(RequestSwap.PAYMENT_METHOD_CHOICES):
            return Response({"error": f"Payment method must be one of {list(dict(RequestSwap.PAYMENT_METHOD_CHOICES).keys())}."}, status=status.HTTP_400_BAD_REQUEST)

        # Check availability of requested product
        if product_requested.status != "Available":
            return Response({"error": f"The requested product '{product_requested.name}' is not available."},
                            status=status.HTTP_400_BAD_REQUEST)

        # Check availability of offered product
        if product_offered.status != "Available":
            return Response({"error": f"The offered product '{product_offered.name}' is not available."},
                            status=status.HTTP_400_BAD_REQUEST)

        # Ensure the requester is not trying to swap for their own product
        if requester == product_requested.id_buyer:
            return Response(
                {"error": "You cannot create a swap request on your own products."},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Prepare data for serializer
        data = {
            "requester": requester.id,
            "product_offered": product_offered.id,
            "product_requested": product_requested.id,
            "id_address": address.id,
            "delivery_type": delivery_type,
            "payment_method": payment_method
        }

        serializer = RequestSwapSerializer(data=data)
        if serializer.is_valid():
            swap_request = serializer.save()

            product_offered_data = {
                "product": ProductSerializer(product_offered, context={'request': request}).data,
                "address": AddressSerializer(product_offered.id_address, context={'request': request}).data
            }
            product_requested_data = {
                "product": ProductSerializer(product_requested, context={'request': request}).data,
                "address": AddressSerializer(product_requested.id_address, context={'request': request}).data
            }
            requester_data = UserApplicationSerializer(requester, context={'request': request}).data
            selected_address_data = AddressSerializer(address, context={'request': request}).data

            return Response({
                "message": "Swap request sent successfully.",
                "requester": requester_data,
                "product_offered": product_offered_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data,
                "swap_request": RequestSwapSerializer(swap_request, context={'request': request}).data
            }, status=status.HTTP_201_CREATED)

        return Response({"error": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)


# View all products user sent in swaps
class UserSentSwapsAPIView(APIView):
    """
    List all swap requests sent by this user (products offered by the user),
    with full details: swap info, requester, offered product + address, requested product + address.
    Supports ordering by created_at using query param 'order':
      - "added_oldest" for ascending (oldest first)
      - "added_newest" for descending (newest first, default)
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, user_id):
        try:
            user = UserApplication.objects.get(pk=user_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        # Get order param from query params
        order = request.query_params.get('order', 'added_newest').lower()
        if order == "added_oldest":
            swaps = RequestSwap.objects.filter(requester=user).order_by('created_at')
        elif order == "added_newest":
            swaps = RequestSwap.objects.filter(requester=user).order_by('-created_at')
        else:
            # Default ordering: newest first
            swaps = RequestSwap.objects.filter(requester=user).order_by('-created_at')

        result = []
        for swap in swaps:
            swap_data = RequestSwapSerializer(swap, context={'request': request}).data
            requester_data = UserApplicationSerializer(swap.requester, context={'request': request}).data

            product_offered_data = {
                "product": ProductSerializer(swap.product_offered, context={'request': request}).data,
                "address": AddressSerializer(swap.product_offered.id_address, context={'request': request}).data
            }

            product_requested_data = {
                "product": ProductSerializer(swap.product_requested, context={'request': request}).data,
                "address": AddressSerializer(swap.product_requested.id_address, context={'request': request}).data
            }


            selected_address_data = AddressSerializer(swap.id_address, context={'request': request}).data

            result.append({
                "swap_request": swap_data,
                "requester": requester_data,
                "product_offered": product_offered_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            })
     

        return Response(
            {
                "message": "List of swap requests sent by user.",
                "sent_swaps": result
            },
            status=status.HTTP_200_OK
        )

# View all products user receives swap requests for
class UserReceivedSwapsAPIView(APIView):
    """
    List all swap requests targeting this user's products (products requested from this user),
    with full details: swap info, requester, offered product + address, requested product + address.
    Supports ordering by created_at using query param 'order':
      - "added_oldest" for ascending (oldest first)
      - "added_newest" for descending (newest first, default)
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, user_id):
        try:
            user = UserApplication.objects.get(pk=user_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        # Get order param from query params
        order = request.query_params.get('order', 'added_newest').lower()
        if order == "added_oldest":
            swaps = RequestSwap.objects.filter(product_requested__id_buyer=user).order_by('created_at')
        elif order == "added_newest":
            swaps = RequestSwap.objects.filter(product_requested__id_buyer=user).order_by('-created_at')
        else:
            swaps = RequestSwap.objects.filter(product_requested__id_buyer=user).order_by('-created_at')

        result = []
        for swap in swaps:
            swap_data = RequestSwapSerializer(swap, context={'request': request}).data
            requester_data = UserApplicationSerializer(swap.requester, context={'request': request}).data

            product_offered_data = {
                "product": ProductSerializer(swap.product_offered, context={'request': request}).data,
                "address": AddressSerializer(swap.product_offered.id_address, context={'request': request}).data
            }

            product_requested_data = {
                "product": ProductSerializer(swap.product_requested, context={'request': request}).data,
                "address": AddressSerializer(swap.product_requested.id_address, context={'request': request}).data
            }

            selected_address_data = AddressSerializer(swap.id_address, context={'request': request}).data


            result.append({
                "swap_request": swap_data,
                "requester": requester_data,
                "product_offered": product_offered_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            })

        return Response(
            {
                "message": "List of swap requests received on user's products.",
                "received_swaps": result
            },
            status=status.HTTP_200_OK
        )





# Update offered product + other details in swap request
class RequestSwapUpdateProductOfferedAPIView(APIView):
    """
    API endpoint to partially update a swap request.
    You can update: product_offered, payment_method, delivery_type, id_address.
    - Only allowed if the swap status is not Accepted or Cancelled.
    - If previously Rejected, resets to Pending and updates created_at.
    """

    authentication_classes = []
    permission_classes = []

    def put(self, request, swap_id):
        # Fetch the swap request
        try:
            swap_request = RequestSwap.objects.get(pk=swap_id)
        except RequestSwap.DoesNotExist:
            return Response({"error": "Swap request not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check swap status
        if swap_request.status in ["Accepted", "Cancelled"]:
            return Response(
                {"error": f"Cannot update swap request because it is '{swap_request.status}'."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get optional fields from request
        new_product_offered_id = request.data.get("product_offered")
        new_payment_method = request.data.get("payment_method")
        new_delivery_type = request.data.get("delivery_type")
        new_id_address = request.data.get("id_address")

        # Update offered product if provided
        if new_product_offered_id:
            try:
                new_product_offered = Product.objects.get(pk=new_product_offered_id)
            except Product.DoesNotExist:
                return Response({"error": "New offered product not found."}, status=status.HTTP_404_NOT_FOUND)
            if new_product_offered.status != "Available":
                return Response(
                    {"error": f"The offered product '{new_product_offered.name}' is not available."},
                    status=status.HTTP_400_BAD_REQUEST
                )
            swap_request.product_offered = new_product_offered

        # Always check requested product availability
        if swap_request.product_requested.status != "Available":
            return Response(
                {"error": f"The requested product '{swap_request.product_requested.name}' is not available."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update payment method if provided
        if new_payment_method:
            swap_request.payment_method = new_payment_method

        # Update delivery type if provided
        if new_delivery_type:
            swap_request.delivery_type = new_delivery_type

        # Update address if provided
        if new_id_address:
            try:
                new_address = Address.objects.get(pk=new_id_address)
            except Address.DoesNotExist:
                return Response({"error": "Selected address not found."}, status=status.HTTP_404_NOT_FOUND)
            swap_request.id_address = new_address

        # If it was rejected before, reset to pending and update time
        if swap_request.status == "Rejected":
            swap_request.status = "Pending"
            swap_request.created_at = timezone.now()

        swap_request.save()

        # Build detailed product + address info for response
        product_offered_data = {
            "product": ProductSerializer(swap_request.product_offered, context={'request': request}).data,
            "address": AddressSerializer(swap_request.product_offered.id_address, context={'request': request}).data
        }
        product_requested_data = {
            "product": ProductSerializer(swap_request.product_requested, context={'request': request}).data,
            "address": AddressSerializer(swap_request.product_requested.id_address, context={'request': request}).data
        }

        selected_address_data = AddressSerializer(swap_request.id_address, context={'request': request}).data

        return Response(
            {
                "message": "Swap request updated successfully.",
                "swap_request": RequestSwapSerializer(swap_request, context={'request': request}).data,
                "product_offered": product_offered_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            },
            status=status.HTTP_200_OK
        )




# Update details of a buy request
class RequestBuyingUpdateAPIView(APIView):
    """
    API endpoint to partially update a buy request.
    You can update: payment_method, delivery_type, id_address.
    - Only allowed if the buy request status is not Accepted or Cancelled.
    - If previously Rejected, resets to Pending and updates created_at.
    """

    authentication_classes = []
    permission_classes = []

    def put(self, request, buy_request_id):
        # Fetch the buy request
        try:
            buy_request = RequestBuying.objects.get(pk=buy_request_id)
        except RequestBuying.DoesNotExist:
            return Response({"error": "Buy request not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check buy request status
        if buy_request.status in ["Accepted", "Cancelled"]:
            return Response(
                {"error": f"Cannot update buy request because it is '{buy_request.status}'."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Always check requested product availability
        if buy_request.product_requested.status != "Available":
            return Response(
                {"error": f"The requested product '{buy_request.product_requested.name}' is not available."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get optional fields from request
        new_payment_method = request.data.get("payment_method")
        new_delivery_type = request.data.get("delivery_type")
        new_id_address = request.data.get("id_address")

        # Update payment method if provided
        if new_payment_method:
            buy_request.payment_method = new_payment_method

        # Update delivery type if provided
        if new_delivery_type:
            buy_request.delivery_type = new_delivery_type

        # Update selected address if provided
        if new_id_address:
            try:
                new_address = Address.objects.get(pk=new_id_address)
            except Address.DoesNotExist:
                return Response({"error": "Selected address not found."}, status=status.HTTP_404_NOT_FOUND)
            buy_request.id_address = new_address

        # If previously rejected, reset to pending and update time
        if buy_request.status == "Rejected":
            buy_request.status = "Pending"
            buy_request.created_at = timezone.now()

        buy_request.save()

        # Build detailed response
        product_requested = buy_request.product_requested
        product_requested_data = {
            "product": ProductSerializer(product_requested, context={'request': request}).data,
            "address": AddressSerializer(product_requested.id_address, context={'request': request}).data,
            "buyer": UserApplicationSerializer(product_requested.id_buyer, context={'request': request}).data if product_requested.id_buyer else None
        }

        selected_address_data = AddressSerializer(buy_request.id_address, context={'request': request}).data

        return Response(
            {
                "message": "Buy request updated successfully.",
                "buy_request": RequestBuyingSerializer(buy_request, context={'request': request}).data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            },
            status=status.HTTP_200_OK
        )



# cancel a swap request
class RequestSwapCancelAPIView(APIView):
    """
    API endpoint to cancel a swap request.
    - Only allowed if status is not Accepted or already Cancelled.
    """

    authentication_classes = []
    permission_classes = []

    def put(self, request, swap_id):
        try:
            swap_request = RequestSwap.objects.get(pk=swap_id)
        except RequestSwap.DoesNotExist:
            return Response({"error": "Swap request not found."}, status=status.HTTP_404_NOT_FOUND)

        if swap_request.status == "Accepted":
            return Response(
                {"error": "Cannot cancel a swap request that is already accepted."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if swap_request.status == "Cancelled":
            return Response(
                {"error": "Swap request is already cancelled."},
                status=status.HTTP_400_BAD_REQUEST
            )


        if swap_request.status == "Rejected":
            return Response(
                {"error": "Cannot cancel a swap request that is already rejected."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update status to Cancelled
        swap_request.status = "Cancelled"
        swap_request.save()

        return Response(
            {
                "message": "Swap request cancelled successfully.",
                "swap_request": RequestSwapSerializer(swap_request, context={'request': request}).data
            },
            status=status.HTTP_200_OK
        )



# View List all swap requests involving a specific product (offered or requested)
class RequestSwapListForProductAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, product_id):
        # Get order param from query params
        order = request.query_params.get('order', 'added_newest').lower()

        # Build base queryset
        swaps = RequestSwap.objects.filter(
            models.Q(product_offered_id=product_id) | models.Q(product_requested_id=product_id)
        ).select_related('requester__user', 'product_offered__id_address', 'product_requested__id_address')

        # Apply ordering
        if order == "added_oldest":
            swaps = swaps.order_by('created_at')
        elif order == "added_newest":
            swaps = swaps.order_by('-created_at')
        else:
            # Default ordering
            swaps = swaps.order_by('-created_at')

        if not swaps.exists():
            return Response({
                "message": "No swap requests found for this product."
            }, status=status.HTTP_200_OK)

        # Build structured list of swap requests
        swap_requests_data = []
        for swap in swaps:
            product_offered_data = {
                "product": ProductSerializer(swap.product_offered, context={'request': request}).data,
                "address": AddressSerializer(swap.product_offered.id_address, context={'request': request}).data
            }
            product_requested_data = {
                "product": ProductSerializer(swap.product_requested, context={'request': request}).data,
                "address": AddressSerializer(swap.product_requested.id_address, context={'request': request}).data
            }

            selected_address_data = AddressSerializer(swap.id_address, context={'request': request}).data
            
            
            swap_requests_data.append({
                "swap_request": RequestSwapSerializer(swap, context={'request': request}).data,
                "product_offered": product_offered_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            })

        return Response({
            "product_id": product_id,
            "swap_requests_count": swaps.count(),
            "swap_requests": swap_requests_data
        }, status=status.HTTP_200_OK)





from django.db import transaction
from django.core.exceptions import ObjectDoesNotExist
from decimal import Decimal

class ProcessSwapRequestAPIView(APIView):
    """
    API to process (accept or reject) a swap request.
    - Determines who pays the difference based on ownership and product prices.
    - Supports Cash and Wallet payments.
    - Marks products as Not Available when accepted.
    """

    authentication_classes = []
    permission_classes = []

    def post(self, request, swap_request_id):
        try:
            swap_request = RequestSwap.objects.get(id=swap_request_id)
        except RequestSwap.DoesNotExist:
            return Response({"error": "Swap request not found."}, status=status.HTTP_404_NOT_FOUND)

        if swap_request.status != 'Pending':
            return Response({"error": "This swap request is already processed."}, status=status.HTTP_400_BAD_REQUEST)

        action = request.data.get("action")
        if action not in ["accept", "reject"]:
            return Response({"error": "Invalid action. Must be 'accept' or 'reject'."}, status=status.HTTP_400_BAD_REQUEST)

        product_offered = swap_request.product_offered
        product_requested = swap_request.product_requested

        # Extract prices
        price_offered = product_offered.price
        price_requested = product_requested.price

        # Get owners (buyers) of products
        owner_offered = product_offered.id_buyer
        owner_requested = product_requested.id_buyer

        # Check if products are still available
        if product_offered.status == "Not Available" or product_requested.status == "Not Available":
            return Response({
                "error": "Cannot process this swap request because one or both products are already Not Available.",
                "product_offered_status": product_offered.status,
                "product_requested_status": product_requested.status
            }, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            if action == "accept":
                total_amount = Decimal(str(abs(price_requested - price_offered)))

                payer_of_difference = None
                receiver = None
                payment_status = "No Payment Required"
                payment_method = swap_request.payment_method

                # Determine who pays the difference based on who owns which product
                if price_offered > price_requested:
                    # The offered product (owner_offered) is more expensive, so owner_requested pays
                    payer_of_difference = owner_requested
                    receiver = owner_offered
                elif price_requested > price_offered:
                    # The requested product (owner_requested) is more expensive, so owner_offered pays
                    payer_of_difference = owner_offered
                    receiver = owner_requested

                # Handle payment if there is a price difference
                if total_amount > 0:
                    if payment_method == "Cash":
                        payment_status = "Unpaid"
                    elif payment_method == "Wallet":
                        try:
                            payer_wallet = UserWallet.objects.get(user=payer_of_difference)
                            receiver_wallet = UserWallet.objects.get(user=receiver)
                        except ObjectDoesNotExist:
                            return Response({
                                "error": "One of the users does not have a wallet."
                            }, status=status.HTTP_400_BAD_REQUEST)

                        if payer_wallet.balance < total_amount:
                            return Response({
                                "error": "Insufficient wallet funds.",
                                "payer_id": payer_of_difference.id,
                                "needed_amount": total_amount,
                                "current_balance": payer_wallet.balance
                            }, status=status.HTTP_400_BAD_REQUEST)

                        # Transfer funds
                        payer_wallet.balance -= total_amount
                        receiver_wallet.balance += total_amount
                        payer_wallet.save()
                        receiver_wallet.save()
                        payment_status = "Paid"

                # Mark both products as not available
                product_offered.status = "Not Available"
                product_requested.status = "Not Available"
                product_offered.save()
                product_requested.save()

                # Create the swap order (without payment_method field since your model does not have it)
                order = SwapOrder.objects.create(
                    swap_request=swap_request,
                    total_amount=total_amount,
                    payer_of_difference=payer_of_difference,
                    order_status='Pending'
                )

                # Update the swap request status
                swap_request.status = "Accepted"
                swap_request.payment_status = payment_status
                swap_request.save()

                return Response({
                    "message": "Swap request accepted. Products marked as Not Available and order created.",
                    "order_id": order.id,
                    "total_amount": total_amount,
                    "payer_of_difference_id": payer_of_difference.id if payer_of_difference else None,
                    "receiver_id": receiver.id if receiver else None,
                    "payment_method": payment_method,
                    "payment_status": payment_status
                }, status=status.HTTP_200_OK)

            else:
                # If rejected
                swap_request.status = "Rejected"
                swap_request.save()
                return Response({
                    "message": "Swap request has been rejected.",
                    "swap_request_id": swap_request.id,
                    "status": swap_request.status
                }, status=status.HTTP_200_OK)


# View detailed information for a specific swap request
class SwapRequestDetailAPIView(APIView):
    """
    Retrieve detailed information for a specific swap request,
    including seller and buyer details, and linked order if exists.
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, swap_request_id):
        try:
            swap_request = RequestSwap.objects.get(id=swap_request_id)
        except RequestSwap.DoesNotExist:
            return Response({"error": "Swap request not found."}, status=status.HTTP_404_NOT_FOUND)
        
        # serialize swap request data
        swap_data = {
            "id": swap_request.id,
            "status": swap_request.status,
            "payment_method": swap_request.payment_method,
            "payment_status": swap_request.payment_status,
            "delivery_type": swap_request.delivery_type,
            "created_at": swap_request.created_at,
            "requester": {
                "id": swap_request.requester.id,
                "name": swap_request.requester.user.name
            }
        }

        # serialize detailed offered product and seller
        product_offered = swap_request.product_offered
        product_offered_data = {
            "product": ProductSerializer(product_offered, context={'request': request}).data,
            "address": AddressSerializer(product_offered.id_address, context={'request': request}).data,
            "seller": UserApplicationSerializer(product_offered.id_buyer, context={'request': request}).data
                          if product_offered.id_buyer else None
        }

        # serialize detailed requested product and buyer
        product_requested = swap_request.product_requested
        product_requested_data = {
            "product": ProductSerializer(product_requested, context={'request': request}).data,
            "address": AddressSerializer(product_requested.id_address, context={'request': request}).data,
            "buyer": UserApplicationSerializer(product_requested.id_buyer, context={'request': request}).data
                          if product_requested.id_buyer else None
        }

        # try get linked order if exists
        order_data = None
        if hasattr(swap_request, 'order'):
            order = swap_request.order
            order_data = {
                "id": order.id,
                "total_amount": order.total_amount,
                "payer_of_difference": {
                    "id": order.payer_of_difference.id,
                    "name": order.payer_of_difference.user.name
                } if order.payer_of_difference else None,
                "order_status": order.order_status,
                "id_delivery": order.id_delivery.id if order.id_delivery else None,
                "created_at": order.created_at,                
                "ratings": {
                    "delivery_rating_by_buyer": order.buyer_delivery_rating,
                    "delivery_comment_by_buyer": order.buyer_delivery_comment,
    
                    "delivery_rating_by_seller": order.seller_delivery_rating,
                    "delivery_comment_by_seller": order.seller_delivery_comment,
    
                    "seller_rating": order.seller_rating,
                    "seller_comment": order.seller_comment,
    
                    "buyer_rating": order.buyer_rating,
                    "buyer_comment": order.buyer_comment,
                }

            }

        return Response({
            "swap_request": swap_data,
            "product_offered": product_offered_data,
            "product_requested": product_requested_data,
            "order": order_data
        }, status=status.HTTP_200_OK)







from django.db.models import Q
class DeliveryAcceptOrderAPIView(APIView):
    """
    API for a delivery person to accept or reject a delivery order.
    This only works if:
      - the order has not yet been assigned to a delivery person,
      - and it is still in 'Pending' status,
      - and the delivery type is 'Home Delivery'.
    """

    authentication_classes = []
    permission_classes = []

    def post(self, request, order_id, delivery_id):
        action = request.data.get("action")  # must be 'accept' or 'reject'

        if action not in ["accept", "reject"]:
            return Response({"error": "Invalid action. Must be 'accept' or 'reject'."},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            order = SwapOrder.objects.get(
                id=order_id,
                id_delivery__isnull=True,
                order_status="Pending",
                swap_request__delivery_type="Home Delivery"
            )
        except SwapOrder.DoesNotExist:
            return Response({
                "error": "Order not found, already assigned, not pending, or not a home delivery."
            }, status=status.HTTP_404_NOT_FOUND)

        if action == "accept":
            try:
                delivery = Delivery.objects.get(id=delivery_id)
            except Delivery.DoesNotExist:
                return Response({"error": "Delivery person not found."},
                                status=status.HTTP_404_NOT_FOUND)

            order.id_delivery = delivery
            order.order_status = "Accepted"
            order.save()

            return Response({
                "message": f"Order -{order.id}- accepted by delivery person #{delivery.id}."
            }, status=status.HTTP_200_OK)

        else:
            return Response({
                "message": f"Order -{order.id}- was not accepted by delivery person."
            }, status=status.HTTP_200_OK)


class AvailableOrdersForDeliveryAPIView(APIView):
    """
    API to list all orders currently available for a delivery person to accept.
    Returns detailed info including order, delivery address, seller and buyer.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request):
        # Get orders that:
        # - do not have a delivery person assigned yet
        # - are in a status that can be delivered
        # - and require home delivery
        orders = SwapOrder.objects.filter(
            id_delivery__isnull=True,
            order_status="Pending",
            swap_request__delivery_type="Home Delivery"
        ).order_by('-created_at')

        # Format the detailed response data
        data = []
        for order in orders:
            swap = order.swap_request
            product_offered = swap.product_offered
            product_requested = swap.product_requested

            # Build JSON structure
            data.append({
                "order_id": order.id,
                "total_amount": order.total_amount,
                "status": order.order_status,
                "created_at": order.created_at,
                "order_status": order.order_status,
                "id_delivery": order.id_delivery,

                "delivery_type": swap.delivery_type,
                "payment_method": swap.payment_method,
                "payment_status": swap.payment_status,

                 "payer_of_difference": {
                    "id": order.payer_of_difference.id if order.payer_of_difference else None,
                    "name": order.payer_of_difference.user.name if order.payer_of_difference else None
                },

        "delivery_address": AddressSerializer(swap.id_address, context={'request': request}).data,

                "seller": {
                    "id": product_offered.id_buyer.id if product_offered.id_buyer else None,
                    "name": product_offered.id_buyer.user.name if product_offered.id_buyer else None,
                    "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                    "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None,
                    "address": AddressSerializer(product_offered.id_address, context={'request': request}).data if product_offered.id_address else None,
                },

                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                    "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None
                },

                "products": {
                    "offered": {
                        "id": product_offered.id,
                        "name": product_offered.name,
                        "price": product_offered.price
                    },
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                }
            })

        return Response(data, status=status.HTTP_200_OK)





class AvailableOrdersForDeliveryByCityAPIView(APIView):
    """
    API to list all orders currently available for a delivery person to accept.
    Filters orders by delivery city matching delivery person's city.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request, delivery_id):
        # Get Delivery instance by ID from URL
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery person not found."}, status=status.HTTP_404_NOT_FOUND)

        delivery_city = delivery.city

        orders = SwapOrder.objects.filter(
            id_delivery__isnull=True,
            order_status="Pending",
            swap_request__delivery_type="Home Delivery",
            swap_request__id_address__city=delivery_city
        ).order_by('-created_at')

        data = []
        for order in orders:
            swap = order.swap_request
            product_offered = swap.product_offered
            product_requested = swap.product_requested

            data.append({
                "order_id": order.id,
                "total_amount": order.total_amount,
                "status": order.order_status,
                "created_at": order.created_at,
                "order_status": order.order_status,
                "id_delivery": order.id_delivery,

                "delivery_type": swap.delivery_type,
                "payment_method": swap.payment_method,
                "payment_status": swap.payment_status,

                "payer_of_difference": {
                    "id": order.payer_of_difference.id if order.payer_of_difference else None,
                    "name": order.payer_of_difference.user.name if order.payer_of_difference else None
                },

                "delivery_address": AddressSerializer(swap.id_address, context={'request': request}).data,

                "seller": {
                    "id": product_offered.id_buyer.id if product_offered.id_buyer else None,
                    "name": product_offered.id_buyer.user.name if product_offered.id_buyer else None,
                    "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                    "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None,
                    "address": AddressSerializer(product_offered.id_address, context={'request': request}).data if product_offered.id_address else None,
                },

                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                    "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None
                },

                "products": {
                    "offered": {
                        "id": product_offered.id,
                        "name": product_offered.name,
                        "price": product_offered.price
                    },
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                }
            })

        return Response(data, status=status.HTTP_200_OK)



# Get SwapOrder Options API 
class OrderStatusSwapOrderOptionsAPI(APIView):
    def get(self, request):
        order_status_options = [display_name for _, display_name in SwapOrder.ORDER_STATUS_CHOICES]
        return Response(order_status_options)





# Update the status of a SwapOrder
class UpdateSwapOrderStatusAPIView(APIView):
    """
    API to update SwapOrder status.
    If status set to 'Delivered', update linked RequestSwap.payment_status
    to 'Paid' only if current payment_status is 'Unpaid'.
    """

    authentication_classes = []
    permission_classes = []

    def put(self, request, order_id):
        new_status = request.data.get('order_status')

        if new_status not in dict(SwapOrder.ORDER_STATUS_CHOICES).keys():
            return Response({
                "error": "Invalid order status."
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            order = SwapOrder.objects.get(id=order_id)
        except SwapOrder.DoesNotExist:
            return Response({
                "error": "Order not found."
            }, status=status.HTTP_404_NOT_FOUND)

        order.order_status = new_status
        order.save()

        if new_status == "Delivered":
            swap_request = order.swap_request
            if swap_request.payment_status == "Unpaid":
                swap_request.payment_status = "Paid"
                swap_request.save()

        return Response({
            "message": f"Order status updated to {new_status}.",
            "order_id": order.id,
            "order_status": order.order_status,
            "payment_status": order.swap_request.payment_status
        }, status=status.HTTP_200_OK)








class SwapOrdersForSpecificDeliveryAPIView(APIView):
    """
    API to list all SwapOrders assigned to a specific delivery person.
    Shows detailed order info, payer of difference, buyer, seller, 
    offered and requested products, delivery address, and ratings.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({
                "error": "Delivery person not found."
            }, status=status.HTTP_404_NOT_FOUND)

        # Get SwapOrders assigned to this delivery
        orders = SwapOrder.objects.filter(
            id_delivery=delivery
        ).order_by('-created_at')

        data = []
        for order in orders:
            swap = order.swap_request
            product_offered = swap.product_offered
            product_requested = swap.product_requested

            data.append({
                "order_id": order.id,
                "total_amount": order.total_amount,
                "order_status": order.order_status,
                "created_at": order.created_at,

                "delivery_type": swap.delivery_type,
                "payment_method": swap.payment_method,
                "payment_status": swap.payment_status,

                "payer_of_difference": {
                    "id": order.payer_of_difference.id if order.payer_of_difference else None,
                    "name": order.payer_of_difference.user.name if order.payer_of_difference else None
                },

                "delivery_address": {
                    "street": swap.id_address.street,
                    "neighborhood": swap.id_address.neighborhood,
                    "building_number": swap.id_address.building_number,
                    "city": swap.id_address.city,
                    "description": swap.id_address.description,
                    "postal_code": swap.id_address.postal_code,
                    "country": swap.id_address.country,
                },

                "seller": {
                    "id": product_offered.id_buyer.id if product_offered.id_buyer else None,
                    "name": product_offered.id_buyer.user.name if product_offered.id_buyer else None,
                    "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                    "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None,
                    "address": AddressSerializer(product_offered.id_address, context={'request': request}).data if product_offered.id_address else None,
                },

                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                    "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None
                },

                "products": {
                    "offered": {
                        "id": product_offered.id,
                        "name": product_offered.name,
                        "price": product_offered.price
                    },
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                },

                "delivery_person": {
                    "id": delivery.id,
                    "name": delivery.user.name,
                    "email": delivery.user.email,
                    "phone": delivery.user.phone
                },


                "ratings": {
                    "delivery_rating_by_buyer": order.buyer_delivery_rating,
                    "delivery_comment_by_buyer": order.buyer_delivery_comment,
    
                    "delivery_rating_by_seller": order.seller_delivery_rating,
                    "delivery_comment_by_seller": order.seller_delivery_comment,
    
                    "seller_rating": order.seller_rating,
                    "seller_comment": order.seller_comment,
    
                    "buyer_rating": order.buyer_rating,
                    "buyer_comment": order.buyer_comment,
                }
            })
            

        return Response(data, status=status.HTTP_200_OK)



# view to get detailed info for a specific swap order
class SwapOrderDetailAPIView(APIView):
    """
    API to retrieve detailed info for a specific swap order,
    including products, buyer, seller, delivery address, payer, and delivery person.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request, order_id):
        try:
            order = SwapOrder.objects.select_related(
                'swap_request__product_offered__id_buyer__user',
                'swap_request__product_requested__id_buyer__user',
                'swap_request__id_address',
                'payer_of_difference__user',
                'id_delivery__user'
            ).get(id=order_id)
        except SwapOrder.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        swap = order.swap_request
        product_offered = swap.product_offered
        product_requested = swap.product_requested

        data = {
            "order_id": order.id,
            "swap_request_id": swap.id,
            "total_amount": order.total_amount,
            "order_status": order.order_status,
            "created_at": order.created_at,

            "delivery_type": swap.delivery_type,
            "payment_method": swap.payment_method,
            "payment_status": swap.payment_status,

            "payer_of_difference": {
                "id": order.payer_of_difference.id if order.payer_of_difference else None,
                "name": order.payer_of_difference.user.name if order.payer_of_difference else None,
            },

            "delivery_address": {
                "street": swap.id_address.street,
                "neighborhood": swap.id_address.neighborhood,
                "building_number": swap.id_address.building_number,
                "city": swap.id_address.city,
                "description": swap.id_address.description,
                "postal_code": swap.id_address.postal_code,
                "country": swap.id_address.country,
            },

            "seller": {
                "id": product_offered.id_buyer.id if product_offered.id_buyer else None,
                "name": product_offered.id_buyer.user.name if product_offered.id_buyer else None,
                "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None,
                "address": AddressSerializer(product_offered.id_address, context={'request': request}).data if product_offered.id_address else None,
            },

            "buyer": {
                "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None,
            },

            "products": {
                "offered": {
                    "id": product_offered.id,
                    "name": product_offered.name,
                    "price": product_offered.price,
                },
                "requested": {
                    "id": product_requested.id,
                    "name": product_requested.name,
                    "price": product_requested.price,
                },
            },

            "delivery_person": {
                "id": order.id_delivery.id if order.id_delivery else None,
                "name": order.id_delivery.user.name if order.id_delivery and order.id_delivery.user else None,
                "email": order.id_delivery.user.email if order.id_delivery and order.id_delivery.user else None,
                "phone": order.id_delivery.user.phone if order.id_delivery and order.id_delivery.user else None,
            }
        }

        return Response(data, status=status.HTTP_200_OK)







        
        
# Rate delivery
class RateSwapOrderDeliveryAPIView(APIView):
    authentication_classes = []  
    permission_classes = []

    def put(self, request, order_id):
        order = get_object_or_404(SwapOrder, id=order_id)

        if order.order_status != 'Delivered':
            return Response({"error": "You can only rate delivery after the order has been delivered."},
                            status=status.HTTP_400_BAD_REQUEST)

        delivery_rating = request.data.get('delivery_rating')
        delivery_comment = request.data.get('delivery_comment')
        rater_type = request.data.get('rater_type')  # "buyer" أو "seller"

        if delivery_rating is None:
            return Response({"error": "delivery_rating is required."}, status=status.HTTP_400_BAD_REQUEST)
        if rater_type not in ['buyer', 'seller']:
            return Response({"error": "rater_type must be either 'buyer' or 'seller'."},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            delivery_rating = int(delivery_rating)
        except ValueError:
            return Response({"error": "delivery_rating must be an integer."}, status=status.HTTP_400_BAD_REQUEST)

        if not (1 <= delivery_rating <= 5):
            return Response({"error": "delivery_rating must be between 1 and 5."},
                            status=status.HTTP_400_BAD_REQUEST)

        if rater_type == 'buyer':
            order.buyer_delivery_rating = delivery_rating
            order.buyer_delivery_comment = delivery_comment
        else:  # seller
            order.seller_delivery_rating = delivery_rating
            order.seller_delivery_comment = delivery_comment

        order.save()

        return Response({
            "message": f"Delivery has been rated successfully by the {rater_type}.",
            "order_id": order.id,
            "delivery_rating": delivery_rating,
            "delivery_comment": delivery_comment,
            "delivery_person": {
                "id": order.id_delivery.id if order.id_delivery else None,
                "name": order.id_delivery.user.name if order.id_delivery and order.id_delivery.user else None
            }
        }, status=status.HTTP_200_OK)

        
        
# Rate seller
class RateSwapOrderSellerAPIView(APIView):
    authentication_classes = []
    permission_classes = []


    def put(self, request, order_id):
        order = get_object_or_404(SwapOrder, id=order_id)

        if order.order_status != 'Delivered':
            return Response({"error": "You can only rate seller after the order has been delivered."}, status=status.HTTP_400_BAD_REQUEST)

        seller_rating = request.data.get('seller_rating')
        seller_comment = request.data.get('seller_comment')

        if seller_rating is None:
            return Response({"error": "seller_rating is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        if not (1 <= int(seller_rating) <= 5):
            return Response({"error": "seller_rating must be between 1 and 5."}, status=status.HTTP_400_BAD_REQUEST)

        order.seller_rating = seller_rating
        order.seller_comment = seller_comment
        order.save()

        return Response({
            "message": "Seller has been rated successfully for this swap order.",
            "order_id": order.id,
            "seller_rating": seller_rating,
            "seller_comment": seller_comment,
            "seller": {
                "id": order.swap_request.product_offered.id_buyer.id,
                "name": order.swap_request.product_offered.id_buyer.user.name
            }
        }, status=status.HTTP_200_OK)


# Rate buyer
class RateSwapOrderBuyerAPIView(APIView):
    
    authentication_classes = []
    permission_classes = []


    def put(self, request, order_id):
        order = get_object_or_404(SwapOrder, id=order_id)

        if order.order_status != 'Delivered':
            return Response({"error": "You can only rate buyer after the order has been delivered."}, status=status.HTTP_400_BAD_REQUEST)

        buyer_rating = request.data.get('buyer_rating')
        buyer_comment = request.data.get('buyer_comment')

        if buyer_rating is None:
            return Response({"error": "buyer_rating is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        if not (1 <= int(buyer_rating) <= 5):
            return Response({"error": "buyer_rating must be between 1 and 5."}, status=status.HTTP_400_BAD_REQUEST)

        order.buyer_rating = buyer_rating
        order.buyer_comment = buyer_comment
        order.save()

        return Response({
            "message": "Buyer has been rated successfully for this swap order.",
            "order_id": order.id,
            "buyer_rating": buyer_rating,
            "buyer_comment": buyer_comment,
             "buyer": {
                "id": order.swap_request.product_requested.id_buyer.id,
                "name": order.swap_request.product_requested.id_buyer.user.name
            }
        }, status=status.HTTP_200_OK)





##########################################################################################



# Get status RequestBuying API 
class StatusRequestBuyingOptionsAPI(APIView):
    def get(self, request):
        status_options = [display_name for _, display_name in RequestBuying.STATUS_CHOICES]
        return Response(status_options)




# Get payment_method RequestBuying API 
class PaymentMethodRequestBuyingOptionsAPI(APIView):
    def get(self, request):
        payment_method_options = [display_name for _, display_name in RequestBuying.PAYMENT_METHOD_CHOICES]
        return Response(payment_method_options)



# Get payment_status RequestBuying API 
class PaymentStatusRequestBuyingOptionsAPI(APIView):
    def get(self, request):
        payment_status_options = [display_name for _, display_name in RequestBuying.PAYMENT_STATUS_CHOICES]
        return Response(payment_status_options)




# Get delivery_type RequestBuying API 
class DeliveryTypeRequestBuyingOptionsAPI(APIView):
    def get(self, request):
        delivery_type_options = [display_name for _, display_name in RequestBuying.DELIVERY_TYPE_CHOICES]
        return Response(delivery_type_options)





# Create a buy request for a product
class RequestBuyingCreateAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request, requester_id, product_requested_id):
        # Fetch requester
        try:
            requester = UserApplication.objects.get(pk=requester_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User application not found."}, status=status.HTTP_404_NOT_FOUND)

        # Fetch requested product
        try:
            product_requested = Product.objects.get(pk=product_requested_id)
        except Product.DoesNotExist:
            return Response({"error": "Requested product not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check availability of requested product
        if product_requested.status != "Available":
            return Response(
                {"error": f"The requested product '{product_requested.name}' is not available."},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Check requester cannot be the owner (seller) of the product
        if requester == product_requested.id_buyer:
            return Response(
                {"error": "You cannot create a buy request for your own product."},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Extract additional fields from request data
        payment_method = request.data.get('payment_method')
        delivery_type = request.data.get('delivery_type')
        id_address = request.data.get('id_address')

        # Prepare data for serializer
        data = {
            "requester": requester.id,
            "product_requested": product_requested.id,
            "payment_method": payment_method,
            "delivery_type": delivery_type,
            "id_address": id_address
        }

        serializer = RequestBuyingSerializer(data=data)
        if serializer.is_valid():
            buy_request = serializer.save()

            # Prepare detailed product data
            product_requested_data = {
                "product": ProductSerializer(product_requested, context={'request': request}).data,
                "address": AddressSerializer(product_requested.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product_requested.id_buyer, context={'request': request}).data if product_requested.id_buyer else None
            }

            # Serialize requester info
            requester_data = UserApplicationSerializer(requester, context={'request': request}).data

            # Serialize the selected delivery address info
            selected_address_data = AddressSerializer(buy_request.id_address, context={'request': request}).data

            return Response(
                {
                    "message": "Buy request sent successfully.",
                    "requester": requester_data,
                    "product_requested": product_requested_data,
                    "selected_address": selected_address_data,
                    "buy_request": RequestBuyingSerializer(buy_request, context={'request': request}).data
                },
                status=status.HTTP_201_CREATED
            )

        return Response({"error": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)



# View all buy requests user sent
class UserSentBuyRequestsAPIView(APIView):
    """
    List all buy requests sent by this user (products requested by the user),
    with full details: buy request info, requester, requested product + address + buyer + selected address.
    Supports ordering by created_at using query param 'order':
      - "added_oldest" for ascending (oldest first)
      - "added_newest" for descending (newest first, default)
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, user_id):
        try:
            user = UserApplication.objects.get(pk=user_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        order = request.query_params.get('order', 'added_newest').lower()
        if order == "added_oldest":
            buy_requests = RequestBuying.objects.filter(requester=user).order_by('created_at')
        elif order == "added_newest":
            buy_requests = RequestBuying.objects.filter(requester=user).order_by('-created_at')
        else:
            buy_requests = RequestBuying.objects.filter(requester=user).order_by('-created_at')

        result = []
        for buy in buy_requests:
            buy_data = RequestBuyingSerializer(buy, context={'request': request}).data
            requester_data = UserApplicationSerializer(buy.requester, context={'request': request}).data

            product_requested = buy.product_requested
            product_requested_data = {
                "product": ProductSerializer(product_requested, context={'request': request}).data,
                "address": AddressSerializer(product_requested.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product_requested.id_buyer, context={'request': request}).data
                    if product_requested.id_buyer else None
            }

            # New: selected address data for this buy request
            selected_address_data = AddressSerializer(buy.id_address, context={'request': request}).data \
                if hasattr(buy, 'id_address') and buy.id_address else None

            result.append({
                "buy_request": buy_data,
                "requester": requester_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            })

        return Response(
            {
                "message": "List of buy requests sent by user.",
                "sent_buy_requests": result
            },
            status=status.HTTP_200_OK
        )



# View all buy requests received on user's products
class UserReceivedBuyRequestsAPIView(APIView):
    """
    List all buy requests targeting this user's products (products requested from this user),
    with full details: buy request info, requester, requested product + address + buyer + selected address.
    Supports ordering by created_at using query param 'order':
      - "added_oldest" for ascending (oldest first)
      - "added_newest" for descending (newest first, default)
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, user_id):
        try:
            user = UserApplication.objects.get(pk=user_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        # Determine order
        order = request.query_params.get('order', 'added_newest').lower()
        if order == "added_oldest":
            buy_requests = RequestBuying.objects.filter(product_requested__id_buyer=user).order_by('created_at')
        else:
            buy_requests = RequestBuying.objects.filter(product_requested__id_buyer=user).order_by('-created_at')

        result = []
        for buy in buy_requests:
            buy_data = RequestBuyingSerializer(buy, context={'request': request}).data
            requester_data = UserApplicationSerializer(buy.requester, context={'request': request}).data

            product_requested = buy.product_requested
            product_requested_data = {
                "product": ProductSerializer(product_requested, context={'request': request}).data,
                "address": AddressSerializer(product_requested.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(product_requested.id_buyer, context={'request': request}).data
                    if product_requested.id_buyer else None
            }

            selected_address_data = AddressSerializer(buy.id_address, context={'request': request}).data \
                if hasattr(buy, 'id_address') and buy.id_address else None

            result.append({
                "buy_request": buy_data,
                "requester": requester_data,
                "product_requested": product_requested_data,
                "selected_address": selected_address_data
            })

        return Response(
            {
                "message": "List of buy requests received on user's products.",
                "received_buy_requests": result
            },
            status=status.HTTP_200_OK
        )



# Cancel a buy request
class RequestBuyingCancelAPIView(APIView):
    """
    API endpoint to cancel a buy request.
    - Only allowed if status is not Accepted, Rejected or already Cancelled.
    """

    authentication_classes = []
    permission_classes = []

    def put(self, request, buy_id):
        try:
            buy_request = RequestBuying.objects.get(pk=buy_id)
        except RequestBuying.DoesNotExist:
            return Response({"error": "Buy request not found."}, status=status.HTTP_404_NOT_FOUND)

        if buy_request.status == "Accepted":
            return Response(
                {"error": "Cannot cancel a buy request that is already accepted."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if buy_request.status == "Cancelled":
            return Response(
                {"error": "Buy request is already cancelled."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if buy_request.status == "Rejected":
            return Response(
                {"error": "Cannot cancel a buy request that is already rejected."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update status to Cancelled
        buy_request.status = "Cancelled"
        buy_request.save()

        return Response(
            {
                "message": "Buy request cancelled successfully.",
                "buy_request": RequestBuyingSerializer(buy_request, context={'request': request}).data
            },
            status=status.HTTP_200_OK
        )





# View List all buying requests involving a specific product
class RequestBuyingListForProductAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, product_id):
        # Get order param from query params
        order = request.query_params.get('order', 'added_newest').lower()

        if order == "added_oldest":
            buy_requests = RequestBuying.objects.filter(
                product_requested_id=product_id
            ).select_related('requester__user', 'product_requested__id_address').order_by('created_at')
        elif order == "added_newest":
            buy_requests = RequestBuying.objects.filter(
                product_requested_id=product_id
            ).select_related('requester__user', 'product_requested__id_address').order_by('-created_at')
        else:
            # Default ordering: newest first
            buy_requests = RequestBuying.objects.filter(
                product_requested_id=product_id
            ).select_related('requester__user', 'product_requested__id_address').order_by('-created_at')

        if not buy_requests.exists():
            return Response({
                "message": "No buying requests found for this product."
            }, status=status.HTTP_200_OK)

        # Build structured list of buy requests
        buy_requests_data = []
        for buy_request in buy_requests:
            product_requested_data = {
                "product": ProductSerializer(buy_request.product_requested, context={'request': request}).data,
                "address": AddressSerializer(buy_request.product_requested.id_address, context={'request': request}).data,
                "buyer": UserApplicationSerializer(
                    buy_request.product_requested.id_buyer,
                    context={'request': request}
                ).data if buy_request.product_requested.id_buyer else None
            }

            buy_requests_data.append({
                "buy_request": RequestBuyingSerializer(buy_request, context={'request': request}).data,
                "product_requested": product_requested_data
            })

        return Response({
            "product_id": product_id,
            "buy_requests_count": buy_requests.count(),
            "buy_requests": buy_requests_data
        }, status=status.HTTP_200_OK)







# Not use

class RequestBuyingListAPIView(APIView):
    """
    API to view all buy requests.
    Returns a list of all buy requests with full serialization.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request):
        buy_requests = RequestBuying.objects.all().order_by('-created_at')
        serializer = RequestBuyingSerializer(buy_requests, many=True, context={'request': request})
        return Response({
            "count": buy_requests.count(),
            "buy_requests": serializer.data
        }, status=status.HTTP_200_OK)


# process (accept or reject) a buy request
class ProcessBuyRequestAPIView(APIView):
    """
    API to process (accept or reject) a buy request.
    - Supports Cash and Wallet payments.
    - Marks product as Not Available when accepted.
    - Creates a BuyOrder.
    """

    authentication_classes = []
    permission_classes = []

    def post(self, request, buy_request_id):
        try:
            buy_request = RequestBuying.objects.get(id=buy_request_id)
        except RequestBuying.DoesNotExist:
            return Response({"error": "Buy request not found."}, status=status.HTTP_404_NOT_FOUND)

        if buy_request.status != 'Pending':
            return Response({"error": "This buy request is already processed."}, status=status.HTTP_400_BAD_REQUEST)

        action = request.data.get("action")
        if action not in ["accept", "reject"]:
            return Response({"error": "Invalid action. Must be 'accept' or 'reject'."}, status=status.HTTP_400_BAD_REQUEST)

        # Extract related objects
        product = buy_request.product_requested
        buyer = buy_request.requester
        seller = product.id_buyer
        payment_method = buy_request.payment_method
        total_amount = Decimal(str(product.price))
        payment_status = "Unpaid"

        # Check product availability
        if product.status == "Not Available":
            return Response({"error": "This product is already Not Available."}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            if action == "accept":
                # Handle payment
                if payment_method == "Cash":
                    payment_status = "Unpaid"
                elif payment_method == "Wallet":
                    try:
                        buyer_wallet = UserWallet.objects.get(user=buyer)
                        seller_wallet = UserWallet.objects.get(user=seller)
                    except ObjectDoesNotExist:
                        return Response({
                            "error": "Buyer or seller does not have a wallet."
                        }, status=status.HTTP_400_BAD_REQUEST)

                    if buyer_wallet.balance < total_amount:
                        return Response({
                            "error": "Insufficient wallet funds.",
                            "buyer_id": buyer.id,
                            "needed_amount": total_amount,
                            "current_balance": buyer_wallet.balance
                        }, status=status.HTTP_400_BAD_REQUEST)

                    # Transfer funds
                    buyer_wallet.balance -= total_amount
                    seller_wallet.balance += total_amount
                    buyer_wallet.save()
                    seller_wallet.save()
                    payment_status = "Paid"

                # Mark product as Not Available
                product.status = "Not Available"
                product.save()

                # Update buy request
                buy_request.status = "Accepted"
                buy_request.payment_status = payment_status
                buy_request.save()

                # Create the BuyOrder
                order = BuyOrder.objects.create(
                    buy_request=buy_request,
                    order_status="Pending"
                )

                return Response({
                    "message": "Buy request accepted. Product marked as Not Available and order created.",
                    "order_id": order.id,
                    "total_amount": total_amount,
                    "buyer_id": buyer.id,
                    "seller_id": seller.id,
                    "payment_method": payment_method,
                    "payment_status": payment_status
                }, status=status.HTTP_200_OK)

            else:
                # Reject case
                buy_request.status = "Rejected"
                buy_request.save()
                return Response({
                    "message": "Buy request has been rejected.",
                    "buy_request_id": buy_request.id,
                    "status": buy_request.status
                }, status=status.HTTP_200_OK)








# View detailed information for a specific buy request

class BuyRequestDetailAPIView(APIView):
    """
    Retrieve detailed information for a specific buy request,
    including product, buyer, seller, and linked order if exists.
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, buy_request_id):
        try:
            buy_request = RequestBuying.objects.get(id=buy_request_id)
        except RequestBuying.DoesNotExist:
            return Response({"error": "Buy request not found."}, status=status.HTTP_404_NOT_FOUND)

        # serialize buy request data
        buy_data = {
            "id": buy_request.id,
            "status": buy_request.status,
            "payment_method": buy_request.payment_method,
            "payment_status": buy_request.payment_status,
            "delivery_type": buy_request.delivery_type,
            "created_at": buy_request.created_at,
            "requester": {
                "id": buy_request.requester.id,
                "name": buy_request.requester.user.name
            }
        }

        # serialize product + seller
        product = buy_request.product_requested
        product_data = {
            "product": ProductSerializer(product, context={'request': request}).data,
            "address": AddressSerializer(product.id_address, context={'request': request}).data,
            "seller": UserApplicationSerializer(product.id_buyer, context={'request': request}).data
                        if product.id_buyer else None
        }

        # serialize requester details
        requester_data = UserApplicationSerializer(buy_request.requester, context={'request': request}).data

        # serialize selected delivery address
        selected_address_data = AddressSerializer(buy_request.id_address, context={'request': request}).data

        # try get linked buy order
        order_data = None
        if hasattr(buy_request, 'order'):
            order = buy_request.order
            order_data = {
                "id": order.id,
                "order_status": order.order_status,
                "id_delivery": order.id_delivery.id if order.id_delivery else None,
                "created_at": order.created_at,
            
                "ratings": {
                    "delivery_rating_by_buyer": order.buyer_delivery_rating,
                    "delivery_comment_by_buyer": order.buyer_delivery_comment,
    
                    "delivery_rating_by_seller": order.seller_delivery_rating,
                    "delivery_comment_by_seller": order.seller_delivery_comment,
    
                    "seller_rating": order.seller_rating,
                    "seller_comment": order.seller_comment,
    
                    "buyer_rating": order.buyer_rating,
                    "buyer_comment": order.buyer_comment,
                }

            }            
            

        return Response({
            "buy_request": buy_data,
            "product_requested": product_data,
            "requester": requester_data,
            "selected_address": selected_address_data,
            "order": order_data
        }, status=status.HTTP_200_OK)








from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q

class DeliveryAcceptBuyOrderAPIView(APIView):
    """
    API for a delivery person to accept or reject a delivery order for buy requests.
    Only allowed if:
      - the order is not yet assigned to a delivery person,
      - the order status is 'Pending',
      - and the delivery type is 'Home Delivery'.
    """

    authentication_classes = []
    permission_classes = []

    def post(self, request, order_id, delivery_id):
        action = request.data.get("action")  # must be 'accept' or 'reject'

        if action not in ["accept", "reject"]:
            return Response({"error": "Invalid action. Must be 'accept' or 'reject'."},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            order = BuyOrder.objects.get(
                id=order_id,
                id_delivery__isnull=True,
                order_status="Pending",
                buy_request__delivery_type="Home Delivery"
            )
        except BuyOrder.DoesNotExist:
            return Response({
                "error": "Order not found, already assigned, not pending, or not a home delivery."
            }, status=status.HTTP_404_NOT_FOUND)

        if action == "accept":
            try:
                delivery = Delivery.objects.get(id=delivery_id)
            except Delivery.DoesNotExist:
                return Response({"error": "Delivery person not found."},
                                status=status.HTTP_404_NOT_FOUND)

            order.id_delivery = delivery
            order.order_status = "Accepted"
            order.save()

            return Response({
                "message": f"Order -{order.id}- accepted by delivery person #{delivery.id}."
            }, status=status.HTTP_200_OK)

        else:
            return Response({
                "message": f"Order -{order.id}- was not accepted by delivery person."
            }, status=status.HTTP_200_OK)






class AvailableBuyOrdersForDeliveryAPIView(APIView):
    """
    API to list all buy orders currently available for delivery persons to accept.
    Returns detailed info including order, delivery address, buyer, seller, and product.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request):
        # Get orders that:
        # - do not have a delivery person assigned yet
        # - are still pending
        # - require home delivery
        orders = BuyOrder.objects.filter(
            id_delivery__isnull=True,
            order_status="Pending",
            buy_request__delivery_type="Home Delivery"
        ).order_by('-created_at')

        data = []
        for order in orders:
            buy_request = order.buy_request
            product = buy_request.product_requested

            # Build JSON response
            data.append({
                "order_id": order.id,
                "status": order.order_status,
                "created_at": order.created_at,

                "delivery_type": buy_request.delivery_type,
                "payment_method": buy_request.payment_method,
                "payment_status": buy_request.payment_status,

                "delivery_address": AddressSerializer(buy_request.id_address, context={'request': request}).data,

                "buyer": {
                    "id": buy_request.requester.id,
                    "name": buy_request.requester.user.name,
                    "email": buy_request.requester.user.email,
                    "phone": buy_request.requester.user.phone
                },

                "seller": {
                    "id": product.id_buyer.id if product.id_buyer else None,
                    "name": product.id_buyer.user.name if product.id_buyer else None,
                    "email": product.id_buyer.user.email if product.id_buyer else None,
                    "phone": product.id_buyer.user.phone if product.id_buyer else None,
                    "address": AddressSerializer(product.id_address, context={'request': request}).data if product.id_address else None,
                        
                },

                "product": {
                    "id": product.id,
                    "name": product.name,
                    "price": product.price,
                    "status": product.status,
                    "condition": product.condition
                }
            })

        return Response(data, status=status.HTTP_200_OK)






class AvailableBuyOrdersForDeliveryByCityAPIView(APIView):
    """
    API to list all buy orders available for a delivery person to accept,
    filtered by delivery city matching the delivery person's city.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery person not found."}, status=status.HTTP_404_NOT_FOUND)

        delivery_city = delivery.city

        orders = BuyOrder.objects.filter(
            id_delivery__isnull=True,
            order_status="Pending",
            buy_request__delivery_type="Home Delivery",
            buy_request__id_address__city=delivery_city
        ).order_by('-created_at')

        data = []
        for order in orders:
            buy_request = order.buy_request
            product = buy_request.product_requested

            data.append({
                "order_id": order.id,
                "status": order.order_status,
                "created_at": order.created_at,

                "delivery_type": buy_request.delivery_type,
                "payment_method": buy_request.payment_method,
                "payment_status": buy_request.payment_status,

                "delivery_address": AddressSerializer(buy_request.id_address, context={'request': request}).data,

                "buyer": {
                    "id": buy_request.requester.id,
                    "name": buy_request.requester.user.name,
                    "email": buy_request.requester.user.email,
                    "phone": buy_request.requester.user.phone
                },

                "seller": {
                    "id": product.id_buyer.id if product.id_buyer else None,
                    "name": product.id_buyer.user.name if product.id_buyer else None,
                    "email": product.id_buyer.user.email if product.id_buyer else None,
                    "phone": product.id_buyer.user.phone if product.id_buyer else None,
                    "address": AddressSerializer(product.id_address, context={'request': request}).data if product.id_address else None,
                },

                "product": {
                    "id": product.id,
                    "name": product.name,
                    "price": product.price,
                    "status": product.status,
                    "condition": product.condition
                }
            })

        return Response(data, status=status.HTTP_200_OK)




# Get BuyOrder Options API 
class OrderStatusBuyOrderOptionsAPI(APIView):
    def get(self, request):
        order_status_options = [display_name for _, display_name in BuyOrder.ORDER_STATUS_CHOICES]
        return Response(order_status_options)



# Update BuyOrder status
class UpdateBuyOrderStatusAPIView(APIView):
    """
    API to update BuyOrder status.

    - Updates the `order_status` field of BuyOrder.
    - If the new status is set to 'Delivered', it will also update
      the linked RequestBuying's payment_status to 'Paid' if it was still 'Unpaid'.
    """

    authentication_classes = []
    permission_classes = []

    def put(self, request, order_id):
        # Get the new status from request body
        new_status = request.data.get('order_status')

        # Validate that the new_status is a valid choice
        if new_status not in dict(BuyOrder.ORDER_STATUS_CHOICES).keys():
            return Response({
                "error": "Invalid order status."
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Fetch the BuyOrder object by ID
            order = BuyOrder.objects.get(id=order_id)
        except BuyOrder.DoesNotExist:
            return Response({
                "error": "Buy order not found."
            }, status=status.HTTP_404_NOT_FOUND)

        # Update the order status
        order.order_status = new_status
        order.save()

        # If status changed to Delivered, also mark payment as Paid if it was Unpaid
        if new_status == "Delivered":
            buy_request = order.buy_request
            if buy_request.payment_status == "Unpaid":
                buy_request.payment_status = "Paid"
                buy_request.save()

        # Return success response with updated info
        return Response({
            "message": f"Buy order status updated to {new_status}.",
            "order_id": order.id,
            "order_status": order.order_status,
            "payment_status": order.buy_request.payment_status
        }, status=status.HTTP_200_OK)





class BuyOrdersForSpecificDeliveryAPIView(APIView):
    """
    API to list all BuyOrders assigned to a specific delivery person.
    Shows order details, buyer, seller, delivery address, and product.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({
                "error": "Delivery person not found."
            }, status=status.HTTP_404_NOT_FOUND)

        # Get BuyOrders assigned to this delivery
        orders = BuyOrder.objects.filter(
            id_delivery=delivery
        ).order_by('-created_at')

        data = []
        for order in orders:
            buy_request = order.buy_request
            product = buy_request.product_requested

            data.append({
                "order_id": order.id,
                "order_status": order.order_status,
                "created_at": order.created_at,

                "delivery_type": buy_request.delivery_type,
                "payment_method": buy_request.payment_method,
                "payment_status": buy_request.payment_status,

                "delivery_address": AddressSerializer(
                    buy_request.id_address, context={'request': request}
                ).data,

                "buyer": {
                    "id": buy_request.requester.id,
                    "abstract_user_id": buy_request.requester.user.id,  # <-- Added field
                    "name": buy_request.requester.user.name,
                    "email": buy_request.requester.user.email,
                    "phone": buy_request.requester.user.phone
                },

                "seller": {
                    "id": product.id_buyer.id if product.id_buyer else None,
                    "abstract_user_id": product.id_buyer.user.id if product.id_buyer else None,  # <-- Added field
                    "name": product.id_buyer.user.name if product.id_buyer else None,
                    "email": product.id_buyer.user.email if product.id_buyer else None,
                    "phone": product.id_buyer.user.phone if product.id_buyer else None,
                    "address": AddressSerializer(product.id_address, context={'request': request}).data if product.id_address else None,
                },

                "product": {
                    "id": product.id,
                    "name": product.name,
                    "price": product.price,
                    "status": product.status,
                    "condition": product.condition
                },
            
                "ratings": {
                    "delivery_rating_by_buyer": order.buyer_delivery_rating,
                    "delivery_comment_by_buyer": order.buyer_delivery_comment,
    
                    "delivery_rating_by_seller": order.seller_delivery_rating,
                    "delivery_comment_by_seller": order.seller_delivery_comment,
    
                    "seller_rating": order.seller_rating,
                    "seller_comment": order.seller_comment,
    
                    "buyer_rating": order.buyer_rating,
                    "buyer_comment": order.buyer_comment,
                }

            })

        return Response(data, status=status.HTTP_200_OK)




class BuyOrderDetailAPIView(APIView):
    """
    API to retrieve detailed info for a specific buy order,
    including product, buyer, seller, delivery address, and delivery person.
    """

    authentication_classes = []
    permission_classes = []

    def get(self, request, order_id):
        try:
            order = BuyOrder.objects.select_related(
                'buy_request__product_requested__id_buyer__user',
                'buy_request__id_address',
                'buy_request__requester__user',
                'id_delivery__user'
            ).get(id=order_id)
        except BuyOrder.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        buy_request = order.buy_request
        product = buy_request.product_requested

        data = {
            "order_id": order.id,
            "order_status": order.order_status,
            "created_at": order.created_at,

            "delivery_type": buy_request.delivery_type,
            "payment_method": buy_request.payment_method,
            "payment_status": buy_request.payment_status,

            "delivery_address": {
                "street": buy_request.id_address.street,
                "neighborhood": buy_request.id_address.neighborhood,
                "building_number": buy_request.id_address.building_number,
                "city": buy_request.id_address.city,
                "description": buy_request.id_address.description,
                "postal_code": buy_request.id_address.postal_code,
                "country": buy_request.id_address.country,
            },

            "buyer": {
                "id": buy_request.requester.id,
                "abstract_user_id": buy_request.requester.user.id,  # <-- Added field
                "name": buy_request.requester.user.name,
                "email": buy_request.requester.user.email,
                "phone": buy_request.requester.user.phone
            },

            "seller": {
                "id": product.id_buyer.id if product.id_buyer else None,
                "abstract_user_id": product.id_buyer.user.id if product.id_buyer else None,  # <-- Added field
                "name": product.id_buyer.user.name if product.id_buyer else None,
                "email": product.id_buyer.user.email if product.id_buyer else None,
                "phone": product.id_buyer.user.phone if product.id_buyer else None,
                "address": AddressSerializer(product.id_address, context={'request': request}).data if product.id_address else None,
            },

            "product": {
                "id": product.id,
                "name": product.name,
                "price": product.price,
                "status": product.status,
                "condition": product.condition
            },

            "delivery_person": {
                "id": order.id_delivery.id if order.id_delivery else None,
                "name": order.id_delivery.user.name if order.id_delivery and order.id_delivery.user else None,
                "email": order.id_delivery.user.email if order.id_delivery and order.id_delivery.user else None,
                "phone": order.id_delivery.user.phone if order.id_delivery and order.id_delivery.user else None,
            },

            "ratings": {
                "delivery_rating_by_buyer": order.buyer_delivery_rating,
                "delivery_comment_by_buyer": order.buyer_delivery_comment,
                "delivery_rating_by_seller": order.seller_delivery_rating,
                "delivery_comment_by_seller": order.seller_delivery_comment,
                "seller_rating": order.seller_rating,
                "seller_comment": order.seller_comment,
                "buyer_rating": order.buyer_rating,
                "buyer_comment": order.buyer_comment
            }
        }

        return Response(data, status=status.HTTP_200_OK)







# Rate delivery
class RateBuyOrderDeliveryAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def put(self, request, order_id):
        order = get_object_or_404(BuyOrder, id=order_id)

        if order.order_status != 'Delivered':
            return Response({"error": "You can only rate delivery after the order has been delivered."},
                            status=status.HTTP_400_BAD_REQUEST)

        delivery_rating = request.data.get('delivery_rating')
        delivery_comment = request.data.get('delivery_comment')
        rater_type = request.data.get('rater_type')  # expected "buyer" or "seller"

        if delivery_rating is None:
            return Response({"error": "delivery_rating is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        if rater_type not in ['buyer', 'seller']:
            return Response({"error": "rater_type must be either 'buyer' or 'seller'."},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            delivery_rating = int(delivery_rating)
        except ValueError:
            return Response({"error": "delivery_rating must be an integer."}, status=status.HTTP_400_BAD_REQUEST)

        if not (1 <= delivery_rating <= 5):
            return Response({"error": "delivery_rating must be between 1 and 5."},
                            status=status.HTTP_400_BAD_REQUEST)

        if rater_type == 'buyer':
            order.buyer_delivery_rating = delivery_rating
            order.buyer_delivery_comment = delivery_comment
        else:  # rater_type == 'seller'
            order.seller_delivery_rating = delivery_rating
            order.seller_delivery_comment = delivery_comment

        order.save()

        return Response({
            "message": f"Delivery has been rated successfully by the {rater_type}.",
            "order_id": order.id,
            "delivery_rating": delivery_rating,
            "delivery_comment": delivery_comment,
            "delivery_person": {
                "id": order.id_delivery.id if order.id_delivery else None,
                "name": order.id_delivery.user.name if order.id_delivery and order.id_delivery.user else None
            }
        }, status=status.HTTP_200_OK)






# Rate seller
class RateBuyOrderSellerAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def put(self, request, order_id):
        order = get_object_or_404(BuyOrder, id=order_id)

        if order.order_status != 'Delivered':
            return Response({"error": "You can only rate seller after the order has been delivered."}, status=status.HTTP_400_BAD_REQUEST)

        seller_rating = request.data.get('seller_rating')
        seller_comment = request.data.get('seller_comment')

        if seller_rating is None:
            return Response({"error": "seller_rating is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        if not (1 <= int(seller_rating) <= 5):
            return Response({"error": "seller_rating must be between 1 and 5."}, status=status.HTTP_400_BAD_REQUEST)

        order.seller_rating = seller_rating
        order.seller_comment = seller_comment
        order.save()

        return Response({
            "message": "Seller has been rated successfully for this buy order.",
            "order_id": order.id,
            "seller_rating": seller_rating,
            "seller_comment": seller_comment,
            "seller": {
                "id": order.buy_request.product_requested.id_buyer.id if order.buy_request.product_requested.id_buyer else None,
                "name": order.buy_request.product_requested.id_buyer.user.name if order.buy_request.product_requested.id_buyer else None
            }
        }, status=status.HTTP_200_OK)



# Rate buyer
class RateBuyOrderBuyerAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def put(self, request, order_id):
        order = get_object_or_404(BuyOrder, id=order_id)

        if order.order_status != 'Delivered':
            return Response({"error": "You can only rate buyer after the order has been delivered."}, status=status.HTTP_400_BAD_REQUEST)

        buyer_rating = request.data.get('buyer_rating')
        buyer_comment = request.data.get('buyer_comment')

        if buyer_rating is None:
            return Response({"error": "buyer_rating is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        if not (1 <= int(buyer_rating) <= 5):
            return Response({"error": "buyer_rating must be between 1 and 5."}, status=status.HTTP_400_BAD_REQUEST)

        order.buyer_rating = buyer_rating
        order.buyer_comment = buyer_comment
        order.save()

        return Response({
            "message": "Buyer has been rated successfully for this buy order.",
            "order_id": order.id,
            "buyer_rating": buyer_rating,
            "buyer_comment": buyer_comment,
            "buyer": {
                "id": order.buy_request.requester.id,
                "name": order.buy_request.requester.user.name
            }
        }, status=status.HTTP_200_OK)








################################################################################################################


from django.db.models import Avg, Count, Q

class DeliveryRatingsSummaryAPIView(APIView):
    """
    API to get average delivery ratings for each delivery person,
    across SwapOrder and BuyOrder, including all comments.
    """

    def get(self, request):
        response_data = []

        deliveries = Delivery.objects.all()

        for delivery in deliveries:
            # بيانات SwapOrder - تقييمات المشتري
            swap_buyer_qs = SwapOrder.objects.filter(
                id_delivery=delivery, buyer_delivery_rating__isnull=False)
            swap_buyer_stats = swap_buyer_qs.aggregate(
                avg=Avg('buyer_delivery_rating'),
                count=Count('buyer_delivery_rating')
            )
            swap_buyer_comments = swap_buyer_qs.values_list('buyer_delivery_comment', flat=True)

            # بيانات SwapOrder - تقييمات البائع
            swap_seller_qs = SwapOrder.objects.filter(
                id_delivery=delivery, seller_delivery_rating__isnull=False)
            swap_seller_stats = swap_seller_qs.aggregate(
                avg=Avg('seller_delivery_rating'),
                count=Count('seller_delivery_rating')
            )
            swap_seller_comments = swap_seller_qs.values_list('seller_delivery_comment', flat=True)

            # بيانات BuyOrder - تقييمات المشتري
            buy_buyer_qs = BuyOrder.objects.filter(
                id_delivery=delivery, buyer_delivery_rating__isnull=False)
            buy_buyer_stats = buy_buyer_qs.aggregate(
                avg=Avg('buyer_delivery_rating'),
                count=Count('buyer_delivery_rating')
            )
            buy_buyer_comments = buy_buyer_qs.values_list('buyer_delivery_comment', flat=True)

            # بيانات BuyOrder - تقييمات البائع
            buy_seller_qs = BuyOrder.objects.filter(
                id_delivery=delivery, seller_delivery_rating__isnull=False)
            buy_seller_stats = buy_seller_qs.aggregate(
                avg=Avg('seller_delivery_rating'),
                count=Count('seller_delivery_rating')
            )
            buy_seller_comments = buy_seller_qs.values_list('seller_delivery_comment', flat=True)

            # حساب المتوسطات الإجمالية لكل دور
            def weighted_avg(avg1, count1, avg2, count2):
                total_count = (count1 or 0) + (count2 or 0)
                if total_count == 0:
                    return 0, 0
                total_sum = (avg1 or 0)* (count1 or 0) + (avg2 or 0) * (count2 or 0)
                return round(total_sum / total_count, 2), total_count

            buyer_avg, buyer_count = weighted_avg(
                swap_buyer_stats['avg'], swap_buyer_stats['count'],
                buy_buyer_stats['avg'], buy_buyer_stats['count']
            )

            seller_avg, seller_count = weighted_avg(
                swap_seller_stats['avg'], swap_seller_stats['count'],
                buy_seller_stats['avg'], buy_seller_stats['count']
            )

            # المتوسط العام (كوسط بين تقييمات المشتري والبائع)
            overall_sum = (buyer_avg * buyer_count) + (seller_avg * seller_count)
            overall_count = buyer_count + seller_count
            overall_avg = round(overall_sum / overall_count, 2) if overall_count > 0 else 0

            delivery_data = {
                "delivery_id": delivery.id,
                "delivery_name": delivery.user.name,
                # تقييمات المشتري
                "buyer_avg": buyer_avg,
                "buyer_count": buyer_count,
                "buyer_comments": list(filter(None, swap_buyer_comments)) + list(filter(None, buy_buyer_comments)),
                # تقييمات البائع
                "seller_avg": seller_avg,
                "seller_count": seller_count,
                "seller_comments": list(filter(None, swap_seller_comments)) + list(filter(None, buy_seller_comments)),
                # التقييم العام
                "overall_avg": overall_avg,
                "overall_count": overall_count,
            }

            response_data.append(delivery_data)

        # ترتيب حسب overall_avg من الأعلى للأقل
        response_data = sorted(response_data, key=lambda x: x['overall_avg'], reverse=True)
        
        
        return Response(response_data, status=status.HTTP_200_OK)

from django.db.models import Avg, Count



class UserRatingsSummaryAPIView(APIView):
    """
    API to get average buyer, seller, total ratings and all comments for each user,
    across SwapOrder and BuyOrder combined.
    """

    def get(self, request):
        response_data = []
        users = UserApplication.objects.all()

        for user in users:
            # ========== Buyer ratings ==========
            swap_buyer_orders = SwapOrder.objects.filter(
                swap_request__requester=user,
                buyer_rating__isnull=False
            )
            buy_buyer_orders = BuyOrder.objects.filter(
                buy_request__requester=user,
                buyer_rating__isnull=False
            )

            swap_buyer_stats = swap_buyer_orders.aggregate(
                avg_swap=Avg('buyer_rating'), count_swap=Count('buyer_rating')
            )
            buy_buyer_stats = buy_buyer_orders.aggregate(
                avg_buy=Avg('buyer_rating'), count_buy=Count('buyer_rating')
            )

            swap_buyer_comments = swap_buyer_orders.exclude(
                buyer_comment__isnull=True).exclude(buyer_comment=""
            ).values_list('buyer_comment', flat=True)
            buy_buyer_comments = buy_buyer_orders.exclude(
                buyer_comment__isnull=True).exclude(buyer_comment=""
            ).values_list('buyer_comment', flat=True)

            buyer_total_count = swap_buyer_stats['count_swap'] + buy_buyer_stats['count_buy']
            buyer_total_sum = (
                (swap_buyer_stats['avg_swap'] or 0) * swap_buyer_stats['count_swap'] +
                (buy_buyer_stats['avg_buy'] or 0) * buy_buyer_stats['count_buy']
            )
            buyer_overall_avg = buyer_total_sum / buyer_total_count if buyer_total_count else 0

            # ========== Seller ratings ==========
            swap_seller_orders = SwapOrder.objects.filter(
                swap_request__product_offered__id_buyer=user,
                seller_rating__isnull=False
            )
            buy_seller_orders = BuyOrder.objects.filter(
                buy_request__product_requested__id_buyer=user,
                seller_rating__isnull=False
            )

            swap_seller_stats = swap_seller_orders.aggregate(
                avg_swap=Avg('seller_rating'), count_swap=Count('seller_rating')
            )
            buy_seller_stats = buy_seller_orders.aggregate(
                avg_buy=Avg('seller_rating'), count_buy=Count('seller_rating')
            )

            swap_seller_comments = swap_seller_orders.exclude(
                seller_comment__isnull=True).exclude(seller_comment=""
            ).values_list('seller_comment', flat=True)
            buy_seller_comments = buy_seller_orders.exclude(
                seller_comment__isnull=True).exclude(seller_comment=""
            ).values_list('seller_comment', flat=True)

            seller_total_count = swap_seller_stats['count_swap'] + buy_seller_stats['count_buy']
            seller_total_sum = (
                (swap_seller_stats['avg_swap'] or 0) * swap_seller_stats['count_swap'] +
                (buy_seller_stats['avg_buy'] or 0) * buy_seller_stats['count_buy']
            )
            seller_overall_avg = seller_total_sum / seller_total_count if seller_total_count else 0

            # ========== Total combined ==========
            total_count = buyer_total_count + seller_total_count
            total_sum = buyer_total_sum + seller_total_sum
            total_overall_avg = total_sum / total_count if total_count else 0

            # ========== Build response ==========
            user_data = {
                "user_id": user.id,
                "user_name": user.user.name,
                "buyer_avg": round(buyer_overall_avg, 2),
                "buyer_count": buyer_total_count,
                "seller_avg": round(seller_overall_avg, 2),
                "seller_count": seller_total_count,
                "total_avg": round(total_overall_avg, 2),
                "total_count": total_count,
                "buyer_comments": list(swap_buyer_comments) + list(buy_buyer_comments),
                "seller_comments": list(swap_seller_comments) + list(buy_seller_comments),
            }

            response_data.append(user_data)
            
        # ========== Sort by total_avg descending ==========
        response_data.sort(key=lambda x: x["total_avg"], reverse=True)

        return Response(response_data, status=status.HTTP_200_OK)


##################################################################################################
class AcceptedOrdersForDeliveryAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery person not found."}, status=status.HTTP_404_NOT_FOUND)

        # استعلام طلبات المبادلة المقبولة المخصصة لهذا الدليفري 
        swap_orders = SwapOrder.objects.filter(
            id_delivery=delivery,
            order_status="Accepted",
        ).order_by('-created_at')

        # استعلام طلبات الشراء المقبولة المخصصة لهذا الدليفري
        buy_orders = BuyOrder.objects.filter(
            id_delivery=delivery,
            order_status="Accepted",
        ).order_by('-created_at')

        data = []

        for order in swap_orders:
            swap = order.swap_request
            product_offered = swap.product_offered
            product_requested = swap.product_requested

            data.append({
                "order_id": order.id,
                "request_type": "Swap",
                "total_amount": order.total_amount,
                "status": order.order_status,
                "created_at": order.created_at,
                "delivery_type": swap.delivery_type,
                "payment_method": swap.payment_method,
                "payment_status": swap.payment_status,
                "payer_of_difference": {
                    "id": order.payer_of_difference.id if order.payer_of_difference else None,
                    "name": order.payer_of_difference.user.name if order.payer_of_difference else None
                },
                "delivery_address": AddressSerializer(swap.id_address, context={'request': request}).data,
                "seller": {
                    "id": product_offered.id_buyer.id if product_offered.id_buyer else None,
                    "name": product_offered.id_buyer.user.name if product_offered.id_buyer else None,
                    "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                    "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None,
                    "address": AddressSerializer(product_offered.id_address, context={'request': request}).data if product_offered.id_address else None,
                },
                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                    "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None
                },
                "products": {
                    "offered": {
                        "id": product_offered.id,
                        "name": product_offered.name,
                        "price": product_offered.price
                    },
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                }
            })

        for order in buy_orders:
            buy = order.buy_request
            product_requested = buy.product_requested

            data.append({
                "order_id": order.id,
                "request_type": "Buy",
                "status": order.order_status,
                "created_at": order.created_at,
                "delivery_type": buy.delivery_type,
                "payment_method": buy.payment_method,
                "payment_status": buy.payment_status,
                "delivery_address": AddressSerializer(buy.id_address, context={'request': request}).data,
                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                    "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None
                },
                "products": {
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                }
            })

        return Response(data, status=status.HTTP_200_OK)






class DeliveredOrdersForDeliveryAPIView(APIView):
    authentication_classes = []
    permission_classes = []

    def get(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery person not found."}, status=status.HTTP_404_NOT_FOUND)

        swap_orders = SwapOrder.objects.filter(
            id_delivery=delivery,
            order_status="Delivered"
        ).order_by('-created_at')

        buy_orders = BuyOrder.objects.filter(
            id_delivery=delivery,
            order_status="Delivered"
        ).order_by('-created_at')

        data = []

        for order in swap_orders:
            swap = order.swap_request
            product_offered = swap.product_offered
            product_requested = swap.product_requested

            data.append({
                "order_id": order.id,
                "request_type": "Swap",
                "total_amount": order.total_amount,
                "status": order.order_status,
                "created_at": order.created_at,
                "delivery_type": swap.delivery_type,
                "payment_method": swap.payment_method,
                "payment_status": swap.payment_status,
                "payer_of_difference": {
                    "id": order.payer_of_difference.id if order.payer_of_difference else None,
                    "name": order.payer_of_difference.user.name if order.payer_of_difference else None
                },
                "delivery_address": AddressSerializer(swap.id_address, context={'request': request}).data,
                "seller": {
                    "id": product_offered.id_buyer.id if product_offered.id_buyer else None,
                    "name": product_offered.id_buyer.user.name if product_offered.id_buyer else None,
                    "email": product_offered.id_buyer.user.email if product_offered.id_buyer else None,
                    "phone": product_offered.id_buyer.user.phone if product_offered.id_buyer else None,
                    "address": AddressSerializer(product_offered.id_address, context={'request': request}).data if product_offered.id_address else None,
                },
                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                    "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None
                },
                "products": {
                    "offered": {
                        "id": product_offered.id,
                        "name": product_offered.name,
                        "price": product_offered.price
                    },
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                }
            })

        for order in buy_orders:
            buy = order.buy_request
            product_requested = buy.product_requested

            data.append({
                "order_id": order.id,
                "request_type": "Buy",
                "status": order.order_status,
                "created_at": order.created_at,
                "delivery_type": buy.delivery_type,
                "payment_method": buy.payment_method,
                "payment_status": buy.payment_status,
                "delivery_address": AddressSerializer(buy.id_address, context={'request': request}).data,
                "buyer": {
                    "id": product_requested.id_buyer.id if product_requested.id_buyer else None,
                    "name": product_requested.id_buyer.user.name if product_requested.id_buyer else None,
                    "email": product_requested.id_buyer.user.email if product_requested.id_buyer else None,
                    "phone": product_requested.id_buyer.user.phone if product_requested.id_buyer else None
                },
                "products": {
                    "requested": {
                        "id": product_requested.id,
                        "name": product_requested.name,
                        "price": product_requested.price
                    }
                }
            })

        return Response(data, status=status.HTTP_200_OK)






###################################################################



from django.db.models import Q

class ConversationView(APIView):
    authentication_classes = []
    permission_classes = []




    def post(self, request, user1_id, user2_id):
        user1 = get_object_or_404(User, id=user1_id)
        user2 = get_object_or_404(User, id=user2_id)

        # Check for an existing conversation between the users
        conversation = Conversation.objects.filter(
            Q(user1=user1, user2=user2) | Q(user1=user2, user2=user1)
        ).first()

        if conversation:
            # If conversation exists, return its details without creating a new one
            return Response({
                'conversation_id': conversation.id,
                'created': False
            }, status=status.HTTP_200_OK)
        else:
            # Create a new conversation if none exists
            conversation = Conversation.objects.create(
                user1=user1,
                user2=user2
            )
            return Response({
                'conversation_id': conversation.id,
                'created': True
            }, status=status.HTTP_201_CREATED)

    def get(self, request, user1_id, user2_id):
        user1 = get_object_or_404(User, id=user1_id)
        user2 = get_object_or_404(User, id=user2_id)

        # Fetch the conversation regardless of order
        conversation = get_object_or_404(
            Conversation,
            Q(user1=user1, user2=user2) | Q(user1=user2, user2=user1)
        )

        return Response({
            'conversation_id': conversation.id,
            'user1_id': conversation.user1.id,
            'user2_id': conversation.user2.id,
            'created_at': conversation.created_at
        })
        
        



class ConversationAPIView(APIView):
    def get(self, request, user_id):
        # Retrieve all conversations involving the user
        conversations = Conversation.objects.filter(Q(user1_id=user_id) | Q(user2_id=user_id))
        
        # Serialize the data
        serializer = InfoConversationSerializer(conversations, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class ConversationMessagesView(APIView):
    def get(self, request, conversation_id):
        # Filter messages by conversation_id
        messages = Message.objects.filter(conversation_id=conversation_id)

        # Serialize the messages
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)




#############################################////////////////////////////////////////////////////
