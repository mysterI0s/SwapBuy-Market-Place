# user/backends.py

from django.contrib.auth.backends import ModelBackend

class InactiveAccountsBackend(ModelBackend):
    def user_can_authenticate(self, user):
        return True
