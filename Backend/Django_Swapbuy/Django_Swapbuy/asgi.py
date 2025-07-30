"""
ASGI config for Django_Swapbuy project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/asgi/
"""

import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from user import routing  # Ensure this is the correct import for your routing module

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Django_Swapbuy.settings')

# application = get_asgi_application()



# Create the ASGI application
application = ProtocolTypeRouter({
    "http": get_asgi_application(),  # Handles HTTP requests
    "websocket": AuthMiddlewareStack(  # Handles WebSocket connections
        URLRouter(
            routing.websocket_urlpatterns  # Ensure this is defined in your routing.py
        )
    ),
})