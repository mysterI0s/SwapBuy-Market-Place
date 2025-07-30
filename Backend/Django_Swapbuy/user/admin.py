from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import Group
from .models import User, Delivery, UserApplication

# Unregister the default Group model
admin.site.unregister(Group)

# Customize the User admin
class CustomUserAdmin(UserAdmin):
    
    actions = None

    list_display = (
        'username', 'name','email', 'phone', 'gender', 'is_superuser', 'is_active', 'date_joined'
    )
    list_filter = ('is_active', 'is_superuser', 'gender', 'date_joined')
    search_fields = ('username', 'email', 'phone', 'name')
    ordering = ('username', 'date_joined', 'name', 'name')

    fieldsets = (
        (None, {'fields': ('username', 'password', 'last_login', 'date_joined')}),
        ('Personal info', {
            'fields': (
                'name',
                'email', 'phone', 'gender', 'profile_image'
            )
        }),
        ('Permissions', {'fields': ('is_active', 'is_superuser')}),
    )

# Customize Delivery admin
class DeliveryAdmin(admin.ModelAdmin):
    actions = None

    list_display = ('user', 'identity_number', 'city','address' ,'birth_date')
    search_fields = ('user__username', 'user__name','identity_number', 'city')
    list_filter = ('city',)

# Customize UserApplication admin
class UserApplicationAdmin(admin.ModelAdmin):
    actions = None

  
    list_display = ('user', 'user_gender', 'birth_date')
    search_fields = ('user__username', 'user__name')
    list_filter = ('birth_date', 'user__gender')

    def user_gender(self, obj):
        return obj.user.gender
    user_gender.short_description = 'Gender'
    
    
    

# Register models
admin.site.register(User, CustomUserAdmin)
admin.site.register(Delivery, DeliveryAdmin)
admin.site.register(UserApplication, UserApplicationAdmin)
