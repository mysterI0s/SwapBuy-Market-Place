from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):

    # first_name = models.CharField(('First Name'), max_length=50, null=False, blank=False)
    # father_name = models.CharField("Father Name", max_length=50, null=False, blank=False)
    # last_name = models.CharField(('Last Name'), max_length=50, null=False, blank=False)
    name = models.CharField(('Full Name'), max_length=250, null=False, blank=False)
    phone = models.CharField("Phone Number", max_length=15, null=False)    
    email = models.EmailField("Email", null=False, blank=False, unique=True)
    
    MALE, FEMALE = "Male", "Female"
    GENDER_OPTIONS = (
        (MALE, "Male"),
        (FEMALE, "Female"),
    )

    gender = models.CharField(
        "Gender", choices=GENDER_OPTIONS, max_length=10, null=False, blank=False
    )
    
    profile_image = models.ImageField(
        "Profile Image", upload_to="profile_images", null=True, blank=True,
    )
    
    
    def __str__(self):
        return f"{self.username} - {self.email}"
 
    
    class Meta:
        verbose_name = "User"
        verbose_name_plural = "Users"
        ordering = ['name', 'username'] # this ensures default ordering by username

        



from django.core.validators import RegexValidator

class Delivery(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, null=False, related_name="delivery_user"
    )
    identity_number = models.CharField(
        max_length=10,
        unique=True,
        validators=[
            RegexValidator(
                regex=r'^[01]\d{9}$',
                message="The national ID must be exactly 10 digits long"
            )
        ],
        verbose_name="National ID"
    )
    
    birth_date = models.DateField("Date of Birth", null=False, blank=False)


    Damascus = "Damascus"
    Aleppo = "Aleppo"
    Homs = "Homs"
    Latakia = "Latakia"
    Tartus = "Tartus"
    Daraa = "Daraa"
    Deir_Ezzor = "Deir Ezzor"

    _CITIES_OPTIONS = (
        (Damascus, "Damascus"),
        (Aleppo, "Aleppo"),
        (Homs, "Homs"),
        (Latakia, "Latakia"),
        (Tartus, "Tartus"),
        (Daraa, "Daraa"),
        (Deir_Ezzor, "Deir Ezzor"),
    )
    
    # Sort alphabetically by display name
    CITIES_OPTIONS = sorted(_CITIES_OPTIONS, key=lambda x: x[1])

    city = models.CharField("City", max_length=100, null=False, blank=False, choices=CITIES_OPTIONS)
    address = models.CharField("Address", max_length=500, null=True, blank=True)

   
    def __str__(self):
        return f"Delivery: {self.user.username} - {self.identity_number}"

    class Meta:
        verbose_name = "Delivery"
        verbose_name_plural = "Deliveries"
        ordering = ['user__username']



class UserApplication(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, null=False, related_name="customer_user"
    )
    
    birth_date = models.DateField("Date of Birth", null=False, blank=False)

    def __str__(self):
        #full_name = f"{self.user.first_name} {self.user.last_name}"
        return f"User Application: {self.id} {self.user.name} - ({self.user.username})"

    class Meta:
        verbose_name = "User Application"
        verbose_name_plural = "User Applications"
        ordering = ['user__username']