from django.contrib.auth.models import AbstractUser
from django.db import models


class Patient(AbstractUser):
    """
    Custom user model for patients with additional fields
    Extends Django's built-in AbstractUser for authentication
    """

    phone = models.CharField(max_length=15, blank=True, null=True)
    age = models.IntegerField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.username

    class Meta:
        # This helps prevent potential conflicts
        verbose_name = "Patient"
        verbose_name_plural = "Patients"
