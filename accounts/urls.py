from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import register_patient, get_patient_profile

app_name = "accounts"

urlpatterns = [
    path("register/", register_patient, name="register"),
    path("login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("profile/", get_patient_profile, name="patient_profile"),
]
