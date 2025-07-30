# 🔁 SwapBuy – Buy, Swap, and Deliver Marketplace (Flutter + Django)

SwapBuy is a mobile marketplace app where users can buy or swap products, manage orders via a delivery system, and communicate in real-time through a built-in chat system. It supports two user roles: normal users and delivery drivers.

This monorepo includes:
- 📱 Flutter frontend (MVC with Provider)
- 🐍 Django backend (clean architecture + Redis + WebSockets)

---

## 🚀 Features

- Buy and swap physical or digital products
- In-app digital wallet system
- Order delivery and tracking system
- Two distinct user roles: normal user and delivery driver
- User and delivery rating system
- Real-time chat using WebSockets
- Login, registration, and account management
- RESTful API with Django REST Framework

---

## 🧰 Tech Stack

### 📱 Frontend (Flutter)
- Flutter SDK
- Provider for state management
- HTTP package for API requests
- Shared Preferences for local memory caching
- WebSockets for real-time chat
- MVC architecture pattern

### 🖥️ Backend (Django)
- Django + Django REST Framework
- Django Channels with Redis for WebSockets
- PostgreSQL / SQLite (Database)
- daphne (ASGI server)
- django-cors-headers, django-filter
- Pillow, pytz, jazzmin for admin
- Clean Django app structure

---

## 📲 Frontend Setup

### ✅ Requirements
- Flutter installed: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Emulator or physical device

### 🚀 Run Locally
```bash
cd frontend
flutter pub get
flutter run
```
## 🔧 Backend Environment Setup

> 🖥️ Target OS: Windows (PowerShell compatible)  
> 🐍 Python 3.10+ required  
> 🗃️ Redis is required for real-time WebSocket functionality

---

### ✅ Step 1: Set Execution Policy (Windows Only)

Open **PowerShell as Administrator** and run:

```powershell
set-executionpolicy unrestricted
```
### ✅Step 2: Create and Activate Virtual Environment

```bash
python -m pip install --upgrade pip
python -m venv app_env
app_env\Scripts\Activate
```
### ✅ Step 3: Install Dependencies

```bash
pip install Django
pip install django-cors-headers 
pip install django-filter
pip install Pillow
pip install django-jazzmin
pip install pytz
pip install djangorestframework
pip install channels
pip install channels_redis
pip install daphne
```
### ✅ Step 4: Create the Django Project

```bash
cd path\to\your\backend
django-admin startproject Django_Swapbuy
cd Django_Swapbuy
```
### ✅ Step 5: Run Migrations & Superuser Setup

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
```
## Example credentials:
Username: admin
Password: 0000
Email: adminSwapBuy@gmail.com

### ✅ Step 7: Start the Development Server

```bash
python manage.py runserver
```
### ✅ Step 8: Start Redis Server
Make sure you have Redis installed.
```bash
.\redis-server.exe
```
