import json
from channels.generic.websocket import AsyncWebsocketConsumer
from asgiref.sync import sync_to_async
from services.models import Conversation, Message
from user.models import User
from django.db.models import Q

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.conversation_id = self.scope['url_route']['kwargs']['conversation_id']
        self.room_group_name = f'chat_{self.conversation_id}'

        # Join the conversation group
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        # Leave the conversation group
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        message_content = data.get('message', '')
        user_id = self.scope["user"].id  # Get the ID of the connected user

        # Get user IDs from the incoming data
        user1_id = data.get('user1_id')
        user2_id = data.get('user2_id')

        try:
            # Fetch User objects based on IDs
            user1 = await sync_to_async(User.objects.get)(id=user1_id)
            user2 = await sync_to_async(User.objects.get)(id=user2_id)

            # Check for an existing conversation regardless of order
            conversation = await sync_to_async(Conversation.objects.filter(
                Q(user1=user1, user2=user2) | Q(user1=user2, user2=user1)
            ).first)()

            if not conversation:
                # Create a new conversation if none exists
                conversation = await sync_to_async(Conversation.objects.create)(
                    user1=user1,
                    user2=user2
                )

            # Determine the sender
            sender = user1 if user_id == user1.id else user2

            # Save the message
            message = Message(conversation=conversation, sender=sender, content=message_content)
            await sync_to_async(message.save)()

            # Send the message to the group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': message.content,
                    'sender_id': sender.id,
                    'sender_name': sender.name  # Assuming `name` is a field in User
                }
            )
        except User.DoesNotExist:
            print(f"User not found: user1_id={user1_id} or user2_id={user2_id}")
        except Exception as e:
            print(f"Error handling message: {e}")

    async def chat_message(self, event):
        message = event['message']
        sender_id = event['sender_id']
        sender_name = event['sender_name']
        await self.send(text_data=json.dumps({
            'message': message,
            'sender_id': sender_id,
            'sender_name': sender_name
        }))