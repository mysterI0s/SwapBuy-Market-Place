from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import *
from .models import *
from services.models import *

from django.contrib.auth import authenticate


# Create Account User
class UserApplicationSignup(APIView):
    
    authentication_classes = []
    permission_classes = []
    
    def post(self, request, format=None):
        serializer = UserApplicationSerializer(data=request.data)
        if serializer.is_valid():
            user_application = serializer.save()
            # Create a wallet for the user application instance (not the user)
            UserWallet.objects.create(user=user_application)

            response_data = {
                'message': 'Signup successful',
                'UserApplication_id': user_application.id
            }
            return Response(response_data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



#  Login API for UserApplication or Delivery

class LoginView(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        user = User.objects.filter(username=username).first()
        if not user:
            return Response({'error': 'Username does not exist'}, status=status.HTTP_404_NOT_FOUND)

        # Try to authenticate
        authenticated_user = authenticate(request, username=username, password=password)
        if not authenticated_user:
            return Response({'error': 'Incorrect password'}, status=status.HTTP_401_UNAUTHORIZED)

        # Check if linked to UserApplication
        user_app = getattr(user, 'customer_user', None)
        if user_app:
            has_address = Address.objects.filter(user=user_app).exists()
            user_app_data = UserApplicationSerializer(user_app).data
            return Response({
                'message': 'Login successful',
                'role': 'UserApplication',
                'user_application_id': user_app.id,
                'has_address': has_address,
                'user_application_data': user_app_data
            }, status=status.HTTP_200_OK)

        # Check if linked to Delivery
        delivery = getattr(user, 'delivery_user', None)
        if delivery:
            join_request = Join_Request.objects.filter(delivery=delivery).first()
            join_request_data = JoinRequestSerializer(join_request).data if join_request else None
            return Response({
                'message': 'Login successful',
                'role': 'Delivery',
                'delivery_id': delivery.id,
                #'is_active': delivery.is_active,
                'delivery_data': DeliverySerializer(delivery).data,
                'join_request': join_request_data
            }, status=status.HTTP_200_OK)

        return Response({'error': 'User is not linked to a valid application type.'}, status=status.HTTP_400_BAD_REQUEST)


class UserApplicationProfileView(APIView):
    def get(self, request, userapplication_id):
        try:
            user_app = UserApplication.objects.get(id=userapplication_id)
            user_app_data = UserApplicationSerializer(user_app).data
            return Response({
                'message': 'UserApplication profile fetched successfully',
                'user_application_id': user_app.id,
                'user_application_data': user_app_data
            }, status=status.HTTP_200_OK)
        except UserApplication.DoesNotExist:
            return Response({'error': 'UserApplication profile not found'}, status=status.HTTP_404_NOT_FOUND)





# # Edit Profile API for UserApplication
    
from rest_framework.parsers import MultiPartParser, FormParser
from django.db import IntegrityError

class UserApplicationEditProfileAPI(APIView):
    parser_classes = (MultiPartParser, FormParser)
    authentication_classes = []
    permission_classes = []

    def put(self, request, userapplication_id):
        try:
            user_application = UserApplication.objects.get(id=userapplication_id)
        except UserApplication.DoesNotExist:
            return Response({'error': 'User Application not found'}, status=status.HTTP_404_NOT_FOUND)

        try:
            serializer = UserApplicationProfileSerializer(user_application, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'message': 'Profile updated successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except IntegrityError as e:
            error_message = str(e)
            if "user_user.username" in error_message:
                return Response({'error': 'Username already exists. Please choose a different username.'},
                                status=status.HTTP_400_BAD_REQUEST)
            elif "user_user.email" in error_message:
                return Response({'error': 'Email already exists. Please use a different email address.'},
                                status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({'error': 'Database integrity error.'},
                                status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                'error': 'An unexpected error occurred.',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    
# Password Update API for UserApplication
from django.contrib.auth.hashers import check_password
from django.contrib.auth.hashers import make_password
class PasswordUpdateView(APIView):
    
    authentication_classes = []
    permission_classes = []
    
    
    def put(self, request, userapplication_id):
        serializer = PasswordUpdateSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user_application = UserApplication.objects.get(id=userapplication_id)
            except UserApplication.DoesNotExist:
                return Response({'error': 'User application not found.'}, status=404)

            user = user_application.user
            old_password = serializer.validated_data['old_password']
            new_password = serializer.validated_data['new_password']

            if not user.check_password(old_password):
                return Response({'error': 'Incorrect old password.'}, status=400)

            user.set_password(new_password)
            user.save()

            return Response({'message': 'Password updated successfully.'}, status=200)
        else:
            return Response(serializer.errors, status=400)
        
        
# Forgot Username API for UserApplication (Send Email)                       
from rest_framework import status
from django.core.mail import send_mail
from django.http import JsonResponse
class UserApplicationForgotUsernameView(APIView):
    
    authentication_classes = []
    permission_classes = []
    
    
    def post(self, request):
        email = request.data.get("email")

        try:
            # Fetch the UserApplication instance through related User
            user_application = UserApplication.objects.get(user__email=email)
            user = user_application.user

            # Prepare the email content
            subject = "Your Username Request"
            message = (
                f"Hello {user.name},\n\n"
                f"Your username is: {user.username}\n\n"
                "If you did not request this email, please ignore it."
            )

            # Send the email
            send_mail(subject, message, 'no-reply@yourdomain.com', [user.email])

            return JsonResponse({"message": "Username sent to your email."}, status=200)

        except UserApplication.DoesNotExist:
            return JsonResponse({"error": "No account found with this email."}, status=404)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
        
        

# # Forgot Password API for UserApplication (Send Email)        
# from django.contrib.auth.tokens import default_token_generator
# from django.contrib.auth.hashers import make_password
# from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
# from django.shortcuts import render
# from django.utils.encoding import force_bytes
# from django.contrib.auth import get_user_model

# User = get_user_model()

# # Forgot password (send email)
# class UserApplicationForgotPasswordView(APIView):
    
#     authentication_classes = []
#     permission_classes = []
    
    
#     def post(self, request):
#         email = request.data.get("email")
#         if not email:
#             return JsonResponse({"error": "Email is required."}, status=400)
#         try:
#             user = User.objects.get(email=email)
#             user_application = user.customer_user  # check relation exists

#             uid = urlsafe_base64_encode(force_bytes(user.pk))
#             token = default_token_generator.make_token(user)
#             reset_link = f"http://localhost:8000/User/page-reset-password/{uid}/{token}/"

#             subject = "Password Reset Requested"
#             message = (
#                 f"Hello {user.name},\n\n"
#                 f"Click the link below to reset your password:\n{reset_link}\n\n"
#                 "If you didn’t request this, ignore this email."
#             )

#             send_mail(subject, message, 'no-reply@yourdomain.com', [user.email])
#             return JsonResponse({"message": "Password reset email sent."}, status=200)

#         except User.DoesNotExist:
#             return JsonResponse({"error": "No user found with this email."}, status=404)
#         except UserApplication.DoesNotExist:
#             return JsonResponse({"error": "No UserApplication found for this user."}, status=404)
#         except Exception as e:
#             return JsonResponse({"error": str(e)}, status=500)


# # Actually reset the password
# class UserApplicationResetPasswordView(APIView):
    
#     authentication_classes = []
#     permission_classes = []
    
    
#     def post(self, request, uidb64, token):
#         try:
#             uid = urlsafe_base64_decode(uidb64).decode()
#             user = User.objects.get(pk=uid)
#             user_application = user.customer_user

#             if not default_token_generator.check_token(user, token):
#                 return JsonResponse({"error": "Invalid or expired token."}, status=400)

#             new_password = request.data.get("new_password")
#             if not new_password:
#                 return JsonResponse({"error": "New password is required."}, status=400)

#             user.password = make_password(new_password)
#             user.save()
#             return JsonResponse({"message": "Password has been reset successfully."}, status=200)

#         except User.DoesNotExist:
#             return JsonResponse({"error": "Invalid user ID."}, status=404)
#         except UserApplication.DoesNotExist:
#             return JsonResponse({"error": "No UserApplication found for this user."}, status=404)
#         except Exception as e:
#             return JsonResponse({"error": str(e)}, status=500)


# # Render HTML form (still uses errors in template, but keeps logic consistent)
# class UserApplicationPasswordResetFormView(APIView):
#     def get(self, request, uidb64, token):
#         try:
#             uid = urlsafe_base64_decode(uidb64).decode()
#             user = User.objects.get(pk=uid)
#             user_application = user.customer_user

#             if default_token_generator.check_token(user, token):
#                 return render(request, 'reset_password.html', {'uidb64': uidb64, 'token': token})
#             else:
#                 return render(request, 'error.html', {'message': 'Invalid or expired token.'})

#         except User.DoesNotExist:
#             return render(request, 'error.html', {'message': 'Invalid user ID.'})
#         except UserApplication.DoesNotExist:
#             return render(request, 'error.html', {'message': 'No UserApplication found for this user.'})
#         except Exception as e:
#             return render(request, 'error.html', {'message': str(e)})






from django.core.files.storage import default_storage

class DeleteProfileImageAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def delete(self, request, userapplication_id):
        try:
            user_application = UserApplication.objects.get(id=userapplication_id)
        except UserApplication.DoesNotExist:
            return Response({"error": "User Application not found."}, status=status.HTTP_404_NOT_FOUND)

        user = user_application.user

        if user.profile_image:
            # delete the file from storage
            image_path = user.profile_image.path
            if default_storage.exists(image_path):
                default_storage.delete(image_path)
            
            # clear the field in the database
            user.profile_image = None
            user.save()

            return Response({"message": "Profile image deleted successfully."}, status=status.HTTP_200_OK)
        else:
            return Response({"message": "No profile image to delete."}, status=status.HTTP_200_OK)





##############################################################################################



# Get City Options API (Sorted A-Z)
class CityOptionsAPI(APIView):
    def get(self, request):
        cities_options = [display_name for _, display_name in Delivery.CITIES_OPTIONS]
        sorted_cities_options = sorted(cities_options)  # sorted A --> Z
        return Response(sorted_cities_options)





# from services.models import Join_Request

# Add Join Request (Delivery sends join request)
class JoinRequestDeliveryView(APIView):
    
    authentication_classes = []
    permission_classes = []

    def post(self, request, format=None):
        serializer = JoinDeliverySerializer(data=request.data)
        
        if serializer.is_valid():
            # Save delivery and create join request
            delivery = serializer.save()
            join_request = Join_Request.objects.create(delivery=delivery)
            join_request_serializer = JoinRequestSerializer(join_request)

            return Response({
                "message": "Join request sent successfully.",
                "delivery": serializer.data,
                "join_request": join_request_serializer.data
            }, status=status.HTTP_201_CREATED)

        # Build custom error messages
        errors = serializer.errors
        custom_messages = []

        # Handle user-related errors
        if 'user' in errors:
            if 'username' in errors['user']:
                custom_messages.append("Username already exists. Please use a different username.")
            if 'email' in errors['user']:
                custom_messages.append("This email is already registered. Please try a different email.")

        # Handle identity_number errors with detailed checks
        identity_number_value = str(request.data.get('identity_number', ''))
    
        if 'identity_number' in errors:
            for msg in errors['identity_number']:

                if identity_number_value == "":
                    custom_messages.append("The national ID field cannot be blank.")
                elif len(identity_number_value) != 10:
                    custom_messages.append("The national ID must be exactly 10 digits.")
                elif not identity_number_value.startswith(('0', '1')):
                    custom_messages.append("The national ID must start with 0 or 1 and be followed by 9 digits.")
                elif "already exists" in msg:
                    custom_messages.append("A delivery with this national ID already exists.")
                elif "may not be blank" in msg:
                    custom_messages.append("The national ID field cannot be blank.")
                else:
                    custom_messages.append("Invalid national ID format.")

        # If still no custom messages, show generic fallback
        if not custom_messages:
            custom_messages.append("Failed to send join request due to validation errors. Please check your input.")

        return Response({
            "error": "Failed to send join request.",
            "details": custom_messages
        }, status=status.HTTP_400_BAD_REQUEST)





# Nor use this
# from django.contrib.auth import authenticate


# class DeliveryLoginView(APIView):
#     authentication_classes = []  # No authentication required for login
#     permission_classes = []

#     def post(self, request):
#         username = request.data.get('username')
#         password = request.data.get('password')

#         # 1. Check if delivery exists by username
#         delivery = Delivery.objects.filter(user__username=username).first()
#         if not delivery:
#             return Response({'detail': 'Delivery not found'}, status=status.HTTP_404_NOT_FOUND)

#         # 2. Get the related user
#         user = delivery.user
#         if not user:
#             return Response({'detail': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

#         # 3. Try to authenticate the user
#         authenticated_user = authenticate(request, username=username, password=password)

#         # 4. Always return delivery and join request data, with extra info
#         join_request = Join_Request.objects.filter(delivery=delivery).first()
#         delivery_serializer = JoinDeliverySerializer(delivery)
#         join_request_serializer = JoinRequestSerializer(join_request) if join_request else None

#         response_data = {
#             'delivery': delivery_serializer.data,
#             'join_request': join_request_serializer.data if join_request else None,
#         }

 
#         return Response(response_data, status=status.HTTP_200_OK)




# View Delivery Profile        
class DeliveryProfileView(APIView):
    def get(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
            delivery_data = DeliverySerializer(delivery).data
            return Response({
                'message': 'Delivery profile fetched successfully',
                'delivery_id': delivery.id,
                'delivery_data': delivery_data
            }, status=status.HTTP_200_OK)
        except Delivery.DoesNotExist:
            return Response({'error': 'Delivery profile not found'}, status=status.HTTP_404_NOT_FOUND)






# UPDATE Delivery Profile and reset Join Request status

class DeliveryEditAPI(APIView):

    authentication_classes = []
    permission_classes = []
    
    def put(self, request, delivery_id):
        """
        Update the Delivery data by given ID,
        then reset the linked Join Request's status and description fields.
        """

        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({'detail': 'Delivery not found'}, status=status.HTTP_404_NOT_FOUND)
        
        try:
            serializer = DeliveryProfileSerializer(delivery, data=request.data, partial=False)
            if serializer.is_valid():
                serializer.save()

                # Reset the linked join request's status if it exists
                join_request = Join_Request.objects.filter(delivery=delivery).first()
                if join_request:
                    join_request.status = None
                    join_request.description = None
                    join_request.save()

                return Response({
                    'message': 'Information updated successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)

            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except IntegrityError as e:
            error_message = str(e)
            if "user_user.username" in error_message:
                return Response({'error': 'Username already exists. Please choose a different username.'},
                                status=status.HTTP_400_BAD_REQUEST)
            elif "user_user.email" in error_message:
                return Response({'error': 'Email already exists. Please use a different email address.'},
                                status=status.HTTP_400_BAD_REQUEST)
            
                
            elif "identity_number" in error_message:
                return Response({'error': 'Delivery with this National ID already exists. Please enter correct National ID.'},
                    status=status.HTTP_400_BAD_REQUEST)

            else:
                return Response({'error': 'Database integrity error.'},
                                status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                'error': 'An unexpected error occurred.',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)








from django.shortcuts import get_object_or_404
from django.http import Http404

# DELETE Join Request and related Delivery + User
class JoinRequestDeliveryDeleteView(APIView):
    
    
    authentication_classes = []
    permission_classes = []
    
    def delete(self, request, request_id):
        """
        Delete the Join Request linked to a Delivery,
        then delete the Delivery and the associated User.
        """
        try:
            join_request = get_object_or_404(Join_Request, id=request_id)

            delivery = join_request.delivery

            # Delete the join request first
            join_request.delete()

            # Delete Delivery and User if they exist
            if delivery:
                user = delivery.user
                delivery.delete()
                user.delete()

            return Response({
                'message': 'Join request, delivery, and associated user deleted successfully.'
            }, status=status.HTTP_200_OK)

        except Http404:
            return Response({'error': 'Join request not found.'}, status=status.HTTP_404_NOT_FOUND)

        except Exception as e:
            return Response({
                'error': 'An unexpected error occurred while deleting.',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)




# Edit Profile API for Delivery

from rest_framework.parsers import MultiPartParser, FormParser
from django.db import IntegrityError

class DeliveryEditProfileAPI(APIView):
    parser_classes = (MultiPartParser, FormParser)
    authentication_classes = []
    permission_classes = []

    def put(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({'error': 'Delivery not found'}, status=status.HTTP_404_NOT_FOUND)

        try:
            serializer = DeliveryProfileSerializer(delivery, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response({
                    'message': 'Profile updated successfully',
                    'data': serializer.data
                }, status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except IntegrityError as e:
            error_message = str(e)
            if "user_user.username" in error_message:
                return Response({'error': 'Username already exists. Please choose a different username.'},
                                status=status.HTTP_400_BAD_REQUEST)
            elif "user_user.email" in error_message:
                return Response({'error': 'Email already exists. Please use a different email address.'},
                                status=status.HTTP_400_BAD_REQUEST)
                
  
            elif "identity_number" in error_message:
                return Response({'error': 'Delivery with this National ID already exists. Please enter correct National ID.'},
                    status=status.HTTP_400_BAD_REQUEST)
                
                
            else:
                return Response({'error': 'Database integrity error.'},
                                status=status.HTTP_400_BAD_REQUEST)

        except Exception as e:
            return Response({
                'error': 'An unexpected error occurred.',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)






# View Approved Deliveries API
class ApprovedDeliveryListAPI(APIView):

    def get(self, request):
        # Retrieve all Delivery objects that have a related Join_Request with status=True
        deliveries = Delivery.objects.filter(join_request__status=True).distinct()
        serializer = DeliverySerializer(deliveries, many=True)
        return Response({'data': serializer.data}, status=status.HTTP_200_OK)





# Forgot username api for delivery (send email)
class DeliveryForgotUsernameView(APIView):
    
    authentication_classes = []
    permission_classes = []
    
    def post(self, request):
        email = request.data.get("email")

        try:
            # Fetch the Delivery instance through related User
            delivery = Delivery.objects.get(user__email=email)
            user = delivery.user

            # Prepare the email content
            subject = "Your Username Request"
            message = (
                f"Hello {user.name},\n\n"
                f"Your username is: {user.username}\n\n"
                "If you did not request this email, please ignore it."
            )

            # Send the email
            send_mail(subject, message, 'no-reply@yourdomain.com', [user.email])

            return JsonResponse({"message": "Username sent to your email."}, status=200)

        except Delivery.DoesNotExist:
            return JsonResponse({"error": "No account found with this email."}, status=404)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)

##############################

from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
from django.http import JsonResponse
from django.core.mail import send_mail
from django.contrib.auth.hashers import make_password
from rest_framework.views import APIView

from .models import User, Delivery, UserApplication

# -------------------------------
# UserApplication Forgot Password
# -------------------------------
class UserApplicationForgotPasswordView(APIView):
    
        
    authentication_classes = []
    permission_classes = []
    
    def post(self, request):
        email = request.data.get("email")
        try:
            user = User.objects.get(email=email)
            user_application = user.customer_user  # relation name
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = default_token_generator.make_token(user)
            reset_link = f"http://localhost:8000/User/page-reset-password/{uid}/{token}"
            
            subject = "Password Reset Requested"
            message = f"Hello {user_application.user.name},\n\nClick below to reset your password:\n{reset_link}\n\nIf you didn’t request this, ignore it."
            send_mail(subject, message, 'no-reply@yourdomain.com', [user.email])

            return JsonResponse({"message": "Password reset email sent."}, status=200)
        except UserApplication.DoesNotExist:
            return JsonResponse({"error": "No UserApplication found with this email."}, status=404)
        except User.DoesNotExist:
            return JsonResponse({"error": "No user found with this email."}, status=404)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)


# -------------------------------
# Delivery Forgot Password
# -------------------------------
class DeliveryForgotPasswordView(APIView):
    
        
    authentication_classes = []
    permission_classes = []
    
    def post(self, request):
        email = request.data.get("email")
        try:
            user = User.objects.get(email=email)
            delivery = user.delivery_user  # relation name
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            token = default_token_generator.make_token(user)
            reset_link = f"http://localhost:8000/User/page-reset-password/{uid}/{token}"
            
            subject = "Password Reset Requested"
            message = f"Hello {delivery.user.name},\n\nClick below to reset your password:\n{reset_link}\n\nIf you didn’t request this, ignore it."
            send_mail(subject, message, 'no-reply@yourdomain.com', [user.email])

            return JsonResponse({"message": "Password reset email sent."}, status=200)
        except Delivery.DoesNotExist:
            return JsonResponse({"error": "No Delivery found with this email."}, status=404)
        except User.DoesNotExist:
            return JsonResponse({"error": "No user found with this email."}, status=404)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)


# -------------------------------
# Common reset password for all
# -------------------------------
class UserResetPasswordView(APIView):
    
        
    authentication_classes = []
    permission_classes = []
    
    def post(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)

            if not default_token_generator.check_token(user, token):
                return JsonResponse({"error": "Invalid or expired token."}, status=400)

            new_password = request.data.get("new_password")
            if not new_password:
                return JsonResponse({"error": "New password not provided."}, status=400)

            user.password = make_password(new_password)
            user.save()

            return JsonResponse({"message": "Password has been reset successfully."}, status=200)

        except User.DoesNotExist:
            return JsonResponse({"error": "Invalid user ID."}, status=404)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)




from django.shortcuts import render


class UserPasswordResetFormView(APIView):
    def get(self, request, uidb64, token):
        return render(request, 'reset_password.html')






##########################

# User = get_user_model()

# # Forgot password (send email) for Delivery users
# class DeliveryForgotPasswordView(APIView):
#     authentication_classes = []
#     permission_classes = []

#     def post(self, request):
#         email = request.data.get("email")
#         if not email:
#             return JsonResponse({"error": "Email is required."}, status=400)
#         try:
#             user = User.objects.get(email=email)
#             delivery = user.delivery_user  # Change to delivery relation

#             uid = urlsafe_base64_encode(force_bytes(user.pk))
#             token = default_token_generator.make_token(user)
#             reset_link = f"http://localhost:8000/User/reset-password/{uid}/{token}/"

#             subject = "Password Reset Requested"
#             message = (
#                 f"Hello {user.name},\n\n"
#                 f"Click the link below to reset your password:\n{reset_link}\n\n"
#                 "If you didn’t request this, please ignore this email."
#             )

#             send_mail(subject, message, 'no-reply@yourdomain.com', [user.email])
#             return JsonResponse({"message": "Password reset email sent."}, status=200)

#         except User.DoesNotExist:
#             return JsonResponse({"error": "No user found with this email."}, status=404)
#         except Delivery.DoesNotExist:
#             return JsonResponse({"error": "No Delivery record found for this user."}, status=404)
#         except Exception as e:
#             return JsonResponse({"error": str(e)}, status=500)


# # Actually reset the password for Delivery users

# class DeliveryResetPasswordView(APIView):

#     authentication_classes = []
#     permission_classes = []
    
    
#     def post(self, request, uidb64, token):
#         try:
#             uid = urlsafe_base64_decode(uidb64).decode()
#             user = User.objects.get(pk=uid)
#             delivery = user.delivery_user

#             if not default_token_generator.check_token(user, token):
#                 return JsonResponse({"error": "Invalid or expired token."}, status=400)

#             new_password = request.data.get("new_password")
#             if not new_password:
#                 return JsonResponse({"error": "New password is required."}, status=400)

#             user.password = make_password(new_password)
#             user.save()
#             return JsonResponse({"message": "Password has been reset successfully."}, status=200)

#         except User.DoesNotExist:
#             return JsonResponse({"error": "Invalid user ID."}, status=404)
#         except UserApplication.DoesNotExist:
#             return JsonResponse({"error": "No delivery found for this user."}, status=404)
#         except Exception as e:
#             return JsonResponse({"error": str(e)}, status=500)











# # Render HTML form for Delivery password reset
# class DeliveryPasswordResetFormView(APIView):
#     def get(self, request, uidb64, token):
#         try:
#             uid = urlsafe_base64_decode(uidb64).decode()
#             user = User.objects.get(pk=uid)
#             delivery = user.delivery_user

#             if default_token_generator.check_token(user, token):
#                 return render(request, 'reset_password.html', {'uidb64': uidb64, 'token': token})
#             else:
#                 return render(request, 'error.html', {'message': 'Invalid or expired token.'})

#         except User.DoesNotExist:
#             return render(request, 'error.html', {'message': 'Invalid user ID.'})
#         except Delivery.DoesNotExist:
#             return render(request, 'error.html', {'message': 'No Delivery record found for this user.'})
#         except Exception as e:
#             return render(request, 'error.html', {'message': str(e)})



# Update delivery password API

class DeliveryPasswordUpdateView(APIView):
        
    authentication_classes = []
    permission_classes = []
    
    def put(self, request, delivery_id):
        serializer = PasswordUpdateSerializer(data=request.data)
        if serializer.is_valid():
            try:
                delivery = Delivery.objects.get(id=delivery_id)
            except Delivery.DoesNotExist:
                return Response({'error': 'Delivery not found.'}, status=404)
            
            old_password = serializer.validated_data['old_password']
            new_password = serializer.validated_data['new_password']

            if not delivery.user.check_password(old_password):
                return Response({'error': 'Invalid old password.'}, status=400)

            delivery.user.set_password(new_password)
            delivery.user.save()

            return Response({'message': 'Password updated successfully.'}, status=200)
        else:
            return Response(serializer.errors, status=400)





class DeleteDeliveryProfileImageAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def delete(self, request, delivery_id):
        try:
            delivery = Delivery.objects.get(id=delivery_id)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery not found."}, status=status.HTTP_404_NOT_FOUND)

        user = delivery.user

        if user.profile_image:
            image_path = user.profile_image.path
            # delete the actual file if exists
            if default_storage.exists(image_path):
                default_storage.delete(image_path)
            
            # clear the profile image field
            user.profile_image = None
            user.save()

            return Response({"message": "Profile image deleted successfully."}, status=status.HTTP_200_OK)
        else:
            return Response({"message": "No profile image to delete."}, status=status.HTTP_200_OK)






class UserApplicationListView(APIView):
    def get(self, request):
        applications = UserApplication.objects.all()
        data = [
            {
                'id': app.id,
                'user':app.user.id,
                'full_name': app.user.name,
                'username': app.user.username,
            }
            for app in applications
        ]
        return Response(data, status=status.HTTP_200_OK)


from rest_framework import viewsets
from services.models import Conversation, Message

class ConversationViewSet(viewsets.ModelViewSet):
    queryset = Conversation.objects.all()
    serializer_class = ConversationSerializer

class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer