from rest_framework import serializers
from django.contrib.auth.models import User
from .models import *
from user.models import *



class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = Address
        fields = '__all__'




class ComplaintSerializer(serializers.ModelSerializer):
    class Meta:
        model = Complaint
        fields = ['id', 'subject', 'message', 'created_at', 'user']
        read_only_fields = ['id', 'created_at', 'user']




class ProductSerializer(serializers.ModelSerializer):
      
    class Meta:
        model = Product
        fields = '__all__'



class EditProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ['name','description','price','quantity_available','image','video_file', 
                  'condition','status','id_address']
        
        
        




class WishlistSerializer(serializers.ModelSerializer):
      
    class Meta:
        model = Wishlist
        fields = '__all__'



class RequestSwapSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = RequestSwap
        fields = '__all__'
        
        



class RequestBuyingSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = RequestBuying
        fields = '__all__'
        
               
        
from rest_framework import serializers
from .models import Conversation, Message

class InfoConversationSerializer(serializers.ModelSerializer):
    user1_name = serializers.CharField(source='user1.name', read_only=True)
    user2_name = serializers.CharField(source='user2.name', read_only=True)

    class Meta:
        model = Conversation
        fields = ['id', 'user1', 'user1_name', 'user2', 'user2_name', 'created_at']


# class MessageSerializer(serializers.ModelSerializer):
#     sender_name = serializers.CharField(source='sender.name', read_only=True)

#     class Meta:
#         model = Message
#         fields = ['id', 'conversation', 'sender', 'sender_name', 'content', 'timestamp']





class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = '__all__'
        
        