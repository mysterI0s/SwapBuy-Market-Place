from rest_framework import serializers
from django.contrib.auth.models import User
from .models import *
from services.models import *

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

        
class UserApplicationSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = UserApplication
        fields = ('user', 'birth_date')



    def create(self, validated_data):
        user_data = validated_data.pop('user')
        user = User.objects.create_user(**user_data)
        user_application = UserApplication.objects.create(user=user, **validated_data)
        return user_application





# class EditUserAfterSerializer(serializers.ModelSerializer):
#     profile_image = serializers.ImageField(required=False)
#     username = serializers.CharField(required=False)
#     email = serializers.CharField(required=False)


#     class Meta:
#         model = User
#         fields = [
#             'name', 'phone', 'gender',
#             'email', 'username', 'profile_image'
#         ]





class EditUserAfterSerializer(serializers.ModelSerializer):
    profile_image = serializers.ImageField(required=False)
    username = serializers.CharField(required=False)
    email = serializers.CharField(required=False)

    class Meta:
        model = User
        fields = [
            'name', 'phone', 'gender',
            'email', 'username', 'profile_image'
        ]





class UserApplicationProfileSerializer(serializers.ModelSerializer):
    user = EditUserAfterSerializer()

    class Meta:
        model = UserApplication
        fields = ('user', 'birth_date')

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', None)
        if user_data:
            user = instance.user
            user_serializer = EditUserAfterSerializer(instance=user, data=user_data, partial=True)
            user_serializer.is_valid(raise_exception=True)
            user_serializer.save()
        return super().update(instance, validated_data)




class PasswordUpdateSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)        


##################################################################################################



class DeliverySerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Delivery
        fields = ('id', 'user', 'identity_number', 'birth_date', 'city', 'address')








class JoinRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = Join_Request
        fields = '__all__'




class JoinUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

    def to_internal_value(self, data):
        data['is_active'] = False
        return super().to_internal_value(data)
    

class JoinDeliverySerializer(serializers.ModelSerializer):
    user = JoinUserSerializer()

    class Meta:
        model = Delivery
        fields = ('user','identity_number', 'birth_date', 'city', 'address')

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        user = User.objects.create_user(**user_data)
        delivery = Delivery.objects.create(user=user, **validated_data)
        return delivery



class DeliveryProfileSerializer(serializers.ModelSerializer):
    user = EditUserAfterSerializer()
    identity_number = serializers.CharField(required=False)

    class Meta:
        model = Delivery
        fields = ['user', 'identity_number', 'birth_date', 'city', 'address']

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', None)
        if user_data:
            user = instance.user
            user_serializer = EditUserAfterSerializer(instance=user, data=user_data, partial=True)
            user_serializer.is_valid(raise_exception=True)
            user_serializer.save()
        
        return super().update(instance, validated_data)









class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ['id', 'conversation', 'sender', 'content', 'timestamp']

class ConversationSerializer(serializers.ModelSerializer):
    messages = MessageSerializer(many=True, read_only=True)

    class Meta:
        model = Conversation
        fields = ['id', 'user1', 'user2', 'created_at', 'messages']
