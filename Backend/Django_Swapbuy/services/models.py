from django.db import models



class Address(models.Model):
    user = models.ForeignKey(
        to='user.UserApplication',
        verbose_name="UserApplication",
        on_delete=models.CASCADE,
        null=False,
        blank=False
    )
    street = models.CharField(max_length=255, verbose_name="Street Address", null=False, blank=False)
    neighborhood = models.CharField(max_length=100, verbose_name="Neighborhood", null=True, blank=True)
    building_number = models.CharField(max_length=50, verbose_name="Building Number", null=True, blank=True)
    
    Damascus = "Damascus"
    Aleppo = "Aleppo"
    Homs = "Homs"
    Latakia = "Latakia"
    Tartus = "Tartus"
    Daraa = "Daraa"
    Deir_Ezzor = "Deir Ezzor"

    CITIES_OPTIONS = (
        (Damascus, "Damascus"),
        (Aleppo, "Aleppo"),
        (Homs, "Homs"),
        (Latakia, "Latakia"),
        (Tartus, "Tartus"),
        (Daraa, "Daraa"),
        (Deir_Ezzor, "Deir Ezzor"),
    )
    
    city = models.CharField("City", max_length=100, null=False, blank=False, choices=CITIES_OPTIONS)
    description = models.TextField("Description", max_length=5000, null=True, blank=True)

    postal_code = models.CharField(max_length=20, verbose_name="Postal Code", null=False, blank=False)
    country = models.CharField(max_length=100, verbose_name="Country", null=False, blank=False)


    def __str__(self):
        return f"{self.street}, {self.neighborhood}, {self.city}, {self.postal_code}, {self.country}"

    class Meta:
        verbose_name = "Address"
        verbose_name_plural = "Addresses"
        ordering = ['user', 'city']  # ordering




class UserWallet(models.Model):
    user = models.OneToOneField(
    to='user.UserApplication', verbose_name="User", on_delete=models.CASCADE, null=False)

    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)

    # def __str__(self):
    #     return f"{self.user.first_name} {self.user.last_name}'s Wallet - Balance: {self.balance}"

    def __str__(self):
        return f"{self.user.user.name}'s Wallet - Balance: {self.balance}"

    class Meta:
        verbose_name = "User Wallet"
        verbose_name_plural = "User Wallets"
        ordering = ['user']  # Ensures records are ordered by the associated user's name






class Complaint(models.Model):
    subject = models.CharField("Subject", max_length=25, null=False, blank=False)
    message = models.CharField("Message", max_length=1000, null=False, blank=False)
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.ForeignKey(
        to='user.UserApplication', verbose_name="UserApplication", on_delete=models.CASCADE, null=False)


    def __str__(self):
        return f"{self.user.user.name}: {self.subject}"

    class Meta:
        verbose_name = "Complaint"
        verbose_name_plural = "Complaints"





class Product(models.Model):
    name = models.CharField("Name", max_length=255, null=False, blank=False)
    description = models.TextField("Description", max_length=5000, null=True, blank=True)
    
    price = models.FloatField("Price", null=False, blank=False)
    quantity_available = models.IntegerField("Quantity Available", null=False, blank=False)
    image = models.ImageField("Product Image", upload_to='products/', null=False, blank=False)
    video_file = models.FileField("Video File", upload_to='videos/', null=False, blank=False)
    added_at = models.DateTimeField(auto_now_add=True)

      
    # Product condition choices
    Brand_New = "Brand New"
    Like_New = "Like New"
    Good_Condition = "Good Condition"
    Fair_Condition = "Fair Condition"
    Poor_Condition = "Poor Condition"

    CONDITION_OPTIONS = (
        (Brand_New, "Brand New"),
        (Like_New, "Like New"),
        (Good_Condition, "Good Condition"),
        (Fair_Condition, "Fair Condition"),
        (Poor_Condition, "Poor Condition"),
    )  
      
      
    condition = models.CharField("Product Condition", max_length=50, choices=CONDITION_OPTIONS, null=False, blank=False)
    
    
    # # Status choices
    # Available = "available"
    # Sold = "sold"

    # STATUS_OPTIONS = (
    #     (Available, "Available"),
    #     (Sold, "Sold"),
    # )
    
    Available = "Available"
    Not_Available = "Not Available"
    
    STATUS_OPTIONS = (
    ("Available", "Available"),      # المنتج متوفر (للبيع أو الاستبدال)
    ("Not Available", "Not Available"),  # المنتج غير متوفر (تم بيعه، أو مستبدل، أو غير متوفر لأي سبب)
)
    
    status = models.CharField("Status", max_length=20, choices=STATUS_OPTIONS, default=Available, null=False, blank=False)
   
   
   # Foreign keys for relationships
    id_buyer = models.ForeignKey('user.UserApplication', verbose_name="Buyer", on_delete=models.CASCADE)
    id_address = models.ForeignKey(Address, on_delete=models.CASCADE, verbose_name="Address", null=False, blank=False)


    # def __str__(self):
    #     buyer_name = f"{self.id_buyer.user.first_name} {self.id_buyer.user.father_name} {self.id_buyer.user.last_name}"
    #     return f"{self.name} ({self.condition}, {self.status}) - Buyer: {buyer_name}"

    def __str__(self):
        buyer_name = f"{self.id_buyer.user.name}"
        return f"{self.name}, {self.price} $ - Buyer: {buyer_name}"


    class Meta:
        verbose_name = "Product"
        verbose_name_plural = "Products"
        ordering = ['name']  




from django.utils import timezone

class Join_Request(models.Model):
    date_time = models.DateTimeField("Date Time", null=False, blank=False, default=timezone.now)
    status = models.BooleanField(
        ('Status Join Request'),
        default=None,
        help_text='Accepted/Rejected',
        null=True,
        blank=True
    )
    description = models.CharField("Description", max_length=1000, null=True, blank=True)
    delivery = models.ForeignKey(
        to='user.Delivery',
        verbose_name="Delivery",
        on_delete=models.CASCADE,
        null=True,
        blank=True
    )

    def __str__(self):
        delivery_name = self.delivery.user.username if self.delivery else "No Delivery"
        status_str = "Pending"
        if self.status is True:
            status_str = "Accepted"
        elif self.status is False:
            status_str = "Rejected"
        return f"Join Request by {delivery_name} - Status: {status_str} on {self.date_time.strftime('%Y-%m-%d %H:%M')}"

    class Meta:
        verbose_name = "Join Request"
        verbose_name_plural = "Join Requests"
        ordering = ['date_time']



from user.models import *


class Wishlist(models.Model):
    user = models.OneToOneField(
        'user.UserApplication', on_delete=models.CASCADE, related_name="wishlist"
    )
    products = models.ManyToManyField(Product, related_name="wishlists", blank=True)

    def __str__(self):
        return f"Wishlist of {self.user.user.name}"
    
    
   


# class RequestSwap(models.Model):
#     requester = models.ForeignKey('user.UserApplication', on_delete=models.CASCADE, related_name='swap_requests_made')
#     product_offered = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='swap_offers')  # المنتج الذي يعرضه المستخدم للتبديل
#     product_requested = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='swap_requests_received')  # المنتج المطلوب للتبديل
#     created_at = models.DateTimeField(default=timezone.now)
#     status_choices = (
#         ('Pending', 'Pending'),
#         ('Accepted', 'Accepted'),
#         ('Rejected', 'Rejected'),
#         ('Cancelled', 'Cancelled'),
#     )
#     status = models.CharField(max_length=20, choices=status_choices, default='pending')

#     def __str__(self):
#         return f"Swap Request by {self.requester.user.name}: Offer {self.product_offered.name} for {self.product_requested.name} ({self.status})"






class RequestSwap(models.Model):
    requester = models.ForeignKey(
        'user.UserApplication',
        verbose_name="Requester",
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='swap_requests_made'
    )
    product_offered = models.ForeignKey(
        'Product',
        verbose_name="Product Offered",
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='swap_offers'
    )
    product_requested = models.ForeignKey(
        'Product',
        verbose_name="Product Requested",
        null=False,
        blank=False,
        on_delete=models.CASCADE,
        related_name='swap_requests_received'
    )
    created_at = models.DateTimeField(
        verbose_name="Created At",
        default=timezone.now
    )

    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Accepted', 'Accepted'),
        ('Rejected', 'Rejected'),
        ('Cancelled', 'Cancelled'),
    ]
    status = models.CharField(
        verbose_name="Status",
        max_length=20,
        choices=STATUS_CHOICES,
        null=False,
        blank=False,
        default='Pending'
    )

    PAYMENT_METHOD_CHOICES = [
        ('Cash', 'Cash'),
        ('Wallet', 'Wallet'),
    ]
    payment_method = models.CharField(
        verbose_name="Payment Method",
        max_length=20,
        choices=PAYMENT_METHOD_CHOICES,
        null=False,
        blank=False,
        #default='Wallet',
        help_text="Set only if payment is required"
    )

    PAYMENT_STATUS_CHOICES = [
        ('Paid', 'Paid'),
        ('Unpaid', 'Unpaid'),
        ('No Payment Required', 'No Payment Required'),
    ]
    payment_status = models.CharField(
        verbose_name="Payment Status",
        max_length=20,
        choices=PAYMENT_STATUS_CHOICES,
        null=True,
        blank=True
    )


    id_address = models.ForeignKey('Address', verbose_name="Address",on_delete=models.CASCADE,null=False,blank=False )
    
    
    DELIVERY_TYPE_CHOICES = [
        ('Hand Delivery', 'Hand Delivery'),  # تسليم باليد
        ('Home Delivery', 'Home Delivery'),  # دليفري
    ]
    
    
    delivery_type = models.CharField(
        verbose_name="Delivery Type",
        max_length=20,
        choices=DELIVERY_TYPE_CHOICES,
        null=False,
        blank=False,
        help_text="Specify if delivery is hand delivery or home delivery"
    )
    
    
    
    
    
    def __str__(self):
        return (f"Swap by {self.requester.user.name}: "
                f"{self.product_offered.name} ↔ {self.product_requested.name} "
                f"({self.status}, Payment: {self.payment_status})")



    class Meta:
        verbose_name = "Request Swap"
        verbose_name_plural = "Request Swaps"
        ordering = ['-created_at']





from django.core.exceptions import ValidationError

class SwapOrder(models.Model):
    swap_request = models.OneToOneField(
        'RequestSwap',
        on_delete=models.CASCADE,
        related_name='order',
        verbose_name="Swap Request"
    )
    total_amount = models.FloatField("Total Amount", null=False, blank=False)
    
    
    payer_of_difference = models.ForeignKey(
    'user.UserApplication',
    on_delete=models.CASCADE,
    null=True,
    blank=True,
    related_name='swap_orders_paying',
    verbose_name="Payer of Difference"
    )
    # حالات الطلب
    ORDER_STATUS_CHOICES = [
    ('Pending', 'Pending'),               # قيد الانتظار (في انتظار قبول أو معالجة)
    ('Accepted', 'Accepted'),             # تم قبول الطلب (بداية التحضير أو تأكيده)
    ('Preparing', 'Preparing'),           # يتم تجهيز الطلب
    ('Out for Delivery', 'Out for Delivery'), # الطلب في الطريق مع الدليفري
    ('Delivered', 'Delivered'),           # تم التوصيل
    ]
    
    
    order_status = models.CharField(
        "Order Status",
        max_length=30,
        choices=ORDER_STATUS_CHOICES,
        default='Pending',
        null=False,
        blank=False
    )

    # الدليفري
    id_delivery = models.ForeignKey(
        'user.Delivery',
        on_delete=models.SET_NULL,
        verbose_name="Delivery Person",
        null=True,
        blank=True,
        related_name='swap_orders'
    )

    # تقييمات
    # delivery_rating = models.PositiveSmallIntegerField("Delivery Rating (1-5)",null=True,blank=True)
    # delivery_comment = models.TextField("Delivery Comment",null=True,blank=True)



    # تقييم الدليفري من المشتري
    buyer_delivery_rating = models.PositiveSmallIntegerField("Delivery Rating by Buyer (1-5)", null=True, blank=True)
    buyer_delivery_comment = models.TextField("Delivery Comment by Buyer", null=True, blank=True)

    # تقييم الدليفري من البائع
    seller_delivery_rating = models.PositiveSmallIntegerField("Delivery Rating by Seller (1-5)", null=True, blank=True)
    seller_delivery_comment = models.TextField("Delivery Comment by Seller", null=True, blank=True)


    seller_rating = models.PositiveSmallIntegerField("Seller Rating (1-5)",null=True,blank=True)
    seller_comment = models.TextField("Seller Comment",null=True,blank=True)

    buyer_rating = models.PositiveSmallIntegerField("Buyer Rating (1-5)",null=True,blank=True)
    buyer_comment = models.TextField("Buyer Comment",null=True, blank=True)

    created_at = models.DateTimeField("Created At", default=timezone.now)

    def __str__(self):
        return f"SwapOrder #{self.id} - Swap #{self.swap_request.id} - {self.order_status}"

    class Meta:
        verbose_name = "Swap Order"
        verbose_name_plural = "Swap Orders"
        ordering = ['-created_at']

    def clean(self):
        # Validate ratings between 1 and 5
        for field in ['buyer_delivery_rating', 'seller_delivery_rating', 'seller_rating', 'buyer_rating']:
            value = getattr(self, field)
            if value is not None and not (1 <= value <= 5):
                raise ValidationError({field: "Rating must be between 1 and 5."})






class RequestBuying(models.Model):
    requester = models.ForeignKey(
        'user.UserApplication',
        verbose_name="Requester",
        on_delete=models.CASCADE,
        related_name='buy_requests_made'
    )
    product_requested = models.ForeignKey(
        'Product',
        verbose_name="Product Requested",
        on_delete=models.CASCADE,
        related_name='buy_requests_received'
    )
    created_at = models.DateTimeField(
        verbose_name="Created At",
        default=timezone.now
    )

    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Accepted', 'Accepted'),
        ('Rejected', 'Rejected'),
        ('Cancelled', 'Cancelled'),
    ]
    status = models.CharField(
        verbose_name="Status",
        max_length=20,
        choices=STATUS_CHOICES,
        default='Pending'
    )

    PAYMENT_METHOD_CHOICES = [
        ('Cash', 'Cash'),
        ('Wallet', 'Wallet'),
    ]
    payment_method = models.CharField(
        verbose_name="Payment Method",
        max_length=20,
        choices=PAYMENT_METHOD_CHOICES,
        null=False,
        blank=False,
        help_text="Payment method must be either Cash or Wallet"
    )

    PAYMENT_STATUS_CHOICES = [
        ('Paid', 'Paid'),
        ('Unpaid', 'Unpaid'),
    ]
    payment_status = models.CharField(
        verbose_name="Payment Status",
        max_length=20,
        choices=PAYMENT_STATUS_CHOICES,
        default='Unpaid',
        null=False,
        blank=False,
    )



    id_address = models.ForeignKey('Address', verbose_name="Address",on_delete=models.CASCADE,null=False,blank=False )
    
    
    DELIVERY_TYPE_CHOICES = [
        ('Hand Delivery', 'Hand Delivery'),  # تسليم باليد
        ('Home Delivery', 'Home Delivery'),  # دليفري
    ]
    delivery_type = models.CharField(
        verbose_name="Delivery Type",
        max_length=20,
        choices=DELIVERY_TYPE_CHOICES,
        null=False,
        blank=False,
        help_text="Specify if delivery is hand delivery or home delivery"
    )
    
    



    def __str__(self):
        return (f"Buy Request by {self.requester.user.name}: "
                f"{self.product_requested.name} ({self.status}, Payment: {self.payment_status})")
        
        
    class Meta:
        verbose_name = "Request Buying"
        verbose_name_plural = "Request Buyings"
        ordering = ['-created_at']








class BuyOrder(models.Model):
    buy_request = models.OneToOneField(
        'RequestBuying',
        on_delete=models.CASCADE,
        related_name='order',
        verbose_name="Buy Request"
    )


    ORDER_STATUS_CHOICES = [
        ('Pending', 'Pending'),               # قيد الانتظار (في انتظار قبول أو معالجة)
        ('Accepted', 'Accepted'),             # تم قبول الطلب (بداية التحضير أو تأكيده)
        ('Preparing', 'Preparing'),           # يتم تجهيز الطلب
        ('Out for Delivery', 'Out for Delivery'), # الطلب في الطريق مع الدليفري
        ('Delivered', 'Delivered'),           # تم التوصيل
    ]

    order_status = models.CharField(
        "Order Status",
        max_length=30,
        choices=ORDER_STATUS_CHOICES,
        default='Pending',
        null=False,
        blank=False
    )

    id_delivery = models.ForeignKey(
        'user.Delivery',
        on_delete=models.SET_NULL,
        verbose_name="Delivery Person",
        null=True,
        blank=True,
        related_name='buy_orders'
    )

    # تقييمات
    # delivery_rating = models.PositiveSmallIntegerField("Delivery Rating (1-5)", null=True, blank=True)
    # delivery_comment = models.TextField("Delivery Comment", null=True, blank=True)
    
    
    # تقييم الدليفري من المشتري
    buyer_delivery_rating = models.PositiveSmallIntegerField("Delivery Rating by Buyer (1-5)", null=True, blank=True)
    buyer_delivery_comment = models.TextField("Delivery Comment by Buyer", null=True, blank=True)

    # تقييم الدليفري من البائع
    seller_delivery_rating = models.PositiveSmallIntegerField("Delivery Rating by Seller (1-5)", null=True, blank=True)
    seller_delivery_comment = models.TextField("Delivery Comment by Seller", null=True, blank=True)


    seller_rating = models.PositiveSmallIntegerField("Seller Rating (1-5)", null=True, blank=True)
    seller_comment = models.TextField("Seller Comment", null=True, blank=True)

    buyer_rating = models.PositiveSmallIntegerField("Buyer Rating (1-5)", null=True, blank=True)
    buyer_comment = models.TextField("Buyer Comment", null=True, blank=True)

    created_at = models.DateTimeField("Created At", default=timezone.now)

    def __str__(self):
        return f"BuyOrder #{self.id} - Buy Request #{self.buy_request.id} - {self.order_status}"

    class Meta:
        verbose_name = "Buy Order"
        verbose_name_plural = "Buy Orders"
        ordering = ['-created_at']

    def clean(self):
        # Validate ratings between 1 and 5
        for field in ['buyer_delivery_rating', 'seller_delivery_rating', 'seller_rating', 'buyer_rating']:
            value = getattr(self, field)
            if value is not None and not (1 <= value <= 5):
                raise ValidationError({field: "Rating must be between 1 and 5."})







class Conversation(models.Model):
    user1 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user1_conversations')
    user2 = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user2_conversations')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Chat between {self.user1} and {self.user2}"

    class Meta:
        verbose_name = "Conversation"
        verbose_name_plural = "Conversations"
        ordering = ['-created_at']
        unique_together = ('user1', 'user2')

class Message(models.Model):
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message from {self.sender} in conversation {self.conversation.id} at {self.timestamp}"

    class Meta:
        verbose_name = "Message"
        verbose_name_plural = "Messages"
        ordering = ['timestamp']