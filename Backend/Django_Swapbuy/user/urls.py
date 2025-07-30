from django.urls import path
from .views import *
from django.urls import *
from .views import *

from rest_framework.routers import DefaultRouter
from .views import ConversationViewSet, MessageViewSet

router = DefaultRouter()
router.register(r'conversations', ConversationViewSet)
router.register(r'messages', MessageViewSet)


app_name = "user"



urlpatterns = [
    path('signup/', UserApplicationSignup.as_view(), name='userapplication-signup'),
    path('api/login/', LoginView.as_view(), name='api-login'),
    path('profile/userapplication/<int:userapplication_id>/', UserApplicationProfileView.as_view(), name='userapplication-profile'),
    path('api/userapplication/<int:userapplication_id>/edit-profile/', UserApplicationEditProfileAPI.as_view(), name='userapplication-edit-profile'),
    path('api/userapplication/<int:userapplication_id>/update-password/', PasswordUpdateView.as_view(), name='userapplication-update-password'),
    path('api/userapplication/forgot-username/', UserApplicationForgotUsernameView.as_view(), name='userapplication-forgot-username'),
    path('api/userapplication/<int:userapplication_id>/delete-profile-image/', DeleteProfileImageAPI.as_view(), name='delete-profile-image'),
    
    path('api/delivery-cities/', CityOptionsAPI.as_view(), name='delivery-cities'),
    path('add-join-request/', JoinRequestDeliveryView.as_view(), name='add-join-request'),
    path('delivery/<int:delivery_id>/edit/', DeliveryEditAPI.as_view(), name='delivery-edit'),
    path('join-request/<int:request_id>/delete/', JoinRequestDeliveryDeleteView.as_view(), name='join-request-delete'),
    path('profile/delivery/<int:delivery_id>/', DeliveryProfileView.as_view(), name='delivery-profile'),
    path('api/delivery/<int:delivery_id>/edit-profile/', DeliveryEditProfileAPI.as_view(), name='delivery-edit-profile'),
    path('api/delivery/approved/', ApprovedDeliveryListAPI.as_view(), name='approved-delivery-list'),
    path('api/delivery/forgot-username/', DeliveryForgotUsernameView.as_view(), name='delivery-forgot-username'),



    # (can be reused for all)
    path('page-reset-password/<uidb64>/<token>/', UserPasswordResetFormView.as_view(), name='reset-password-form'),

  # UserApplication
    path('userapplication/forgot-password/', UserApplicationForgotPasswordView.as_view(), name='userapplication-forgot-password'),

    # Delivery
    path('delivery/forgot-password/', DeliveryForgotPasswordView.as_view(), name='delivery-forgot-password'),

    # Common Reset (can be reused for all)
    path('reset-password/<uidb64>/<token>/', UserResetPasswordView.as_view(), name='common-reset-password'),






    path('api/delivery/<int:delivery_id>/update-password/', DeliveryPasswordUpdateView.as_view(), name='delivery-update-password'),
    path('api/delivery/<int:delivery_id>/delete-profile-image/', DeleteDeliveryProfileImageAPI.as_view(), name='delete-delivery-profile-image'),
    #path('api/delivery/login/', DeliveryLoginView.as_view(), name='delivery-login'),


    path('user-applications/', UserApplicationListView.as_view(), name='user_application_list'),
    
    
    
    
    
    


  path('', include(router.urls)),

    
    
    
    
    

]