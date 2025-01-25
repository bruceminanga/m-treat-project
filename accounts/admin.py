from django import forms
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserChangeForm, UserCreationForm
from .models import Patient


class PatientChangeForm(UserChangeForm):
    class Meta:
        model = Patient
        fields = "__all__"


class PatientCreationForm(UserCreationForm):
    class Meta:
        model = Patient
        fields = ("username", "email")


class PatientAdmin(UserAdmin):
    form = PatientChangeForm
    add_form = PatientCreationForm

    # Customize list display
    list_display = ("username", "email", "phone", "is_staff")

    # Customize fieldsets for editing
    fieldsets = (
        (None, {"fields": ("username", "password")}),
        ("Personal Info", {"fields": ("email", "phone", "age", "address")}),
        ("Permissions", {"fields": ("is_active", "is_staff", "is_superuser")}),
        ("Important dates", {"fields": ("last_login", "date_joined")}),
    )

    # Customize add form
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("username", "email", "password1", "password2"),
            },
        ),
    )


# Register the Patient model with the custom admin class
admin.site.register(Patient, PatientAdmin)
