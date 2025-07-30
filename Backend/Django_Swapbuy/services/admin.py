from django.contrib import admin
from .models import *
# Register your models here.

class AddressAdmin(admin.ModelAdmin):
    actions = None
    
    list_display = ('user', 'street','building_number' ,'neighborhood', 'city', 'postal_code', 'country', 'description')
    search_fields = ('user__user__username', 'user__user__name','street', 'neighborhood', 'city', 'postal_code', 'country')
    list_filter = ('user', 'city', 'country')

class UserWalletAdmin(admin.ModelAdmin):
    actions = None

    list_display = ('user', 'balance')
    search_fields = ('user__username', 'user__name')
    list_filter = ('user',)

class ComplaintAdmin(admin.ModelAdmin):
    actions = None
    
    list_display = ('user', 'subject', 'created_at')
    search_fields = ('user__user__username', 'user__user__email', 'user__user__name', 'subject', 'message')
    list_filter = ('created_at','user')



#from rangefilter.filters import NumericRangeFilter
class ProductAdmin(admin.ModelAdmin):
    actions = None
  
    list_display = ('name','description' ,'price', 'condition', 'status', 'id_buyer','id_address' ,'added_at')
    search_fields = ('name', 'description', 'id_buyer__user__username', 'id_buyer__user__name')
    list_filter = ('condition', 'status', 'added_at', 'id_buyer','id_address__city')
    #list_filter = ('condition', 'status', 'added_at', 'id_buyer','id_address__city',('price', NumericRangeFilter))






class JoinRequestAdmin(admin.ModelAdmin):
    actions = None

    list_display = ('delivery', 'status', 'date_time')
    search_fields = ('delivery__user__username', 'delivery__user__name', 'delivery__city')
    list_filter = ('status', 'date_time')


class WishlistAdmin(admin.ModelAdmin):
    actions = None
    list_display = ('user', 'get_products_count')
    search_fields = ('user__user__username', 'user__user__name', 'products__name')
    list_filter = ('user',)

    def get_products_count(self, obj):
        return obj.products.count()
    get_products_count.short_description = "Number of Products"




from django.contrib import admin
from .models import RequestSwap

class RequestSwapAdmin(admin.ModelAdmin):
    actions = None
    list_display = (
        'requester_name', 'product_offered', 'product_requested',
        'status', 'payment_method', 'payment_status',
        'delivery_type', 'created_at'
    )
    search_fields = (
        'requester__user__username', 'requester__user__name',
        'product_offered__name', 'product_requested__name'
    )
    list_filter = (
        'status', 'payment_method', 'payment_status', 'delivery_type', 'created_at','product_offered','product_requested'
    )

    def requester_name(self, obj):
        return obj.requester.user.name if obj.requester and obj.requester.user else "-"
    requester_name.short_description = "Requester"




class SwapOrderAdmin(admin.ModelAdmin):
    actions = None

    list_display = (
        'id', 'swap_request_info', 'total_amount', 'order_status', 
        'payer_name', 'delivery_person_name', 'created_at'
    )
    search_fields = (
        'swap_request__requester__user__username',
        'swap_request__requester__user__name',
        'payer_of_difference__user__name',
        'id_delivery__user__name'
    )
    list_filter = ('order_status', 'created_at')

    def swap_request_info(self, obj):
        return f"Swap #{obj.swap_request.id} by {obj.swap_request.requester.user.name}"
    swap_request_info.short_description = "Swap Request"

    def payer_name(self, obj):
        return obj.payer_of_difference.user.name if obj.payer_of_difference else "-"
    payer_name.short_description = "Payer of Difference"

    def delivery_person_name(self, obj):
        return obj.id_delivery.user.name if obj.id_delivery else "-"
    delivery_person_name.short_description = "Delivery Person"



admin.site.register(Address, AddressAdmin)
admin.site.register(UserWallet, UserWalletAdmin)
admin.site.register(Complaint, ComplaintAdmin)
admin.site.register(Product, ProductAdmin)
admin.site.register(Join_Request, JoinRequestAdmin)

admin.site.register(Wishlist, WishlistAdmin)
admin.site.register(RequestSwap, RequestSwapAdmin)
admin.site.register(SwapOrder, SwapOrderAdmin)


admin.site.register(RequestBuying)
admin.site.register(BuyOrder)




admin.site.register(Conversation)
admin.site.register(Message)