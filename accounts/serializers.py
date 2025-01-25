from rest_framework import serializers
from .models import Patient


class PatientRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for patient registration with validation
    """

    password = serializers.CharField(
        write_only=True, required=True, style={"input_type": "password"}
    )
    confirm_password = serializers.CharField(
        write_only=True, required=True, style={"input_type": "password"}
    )

    class Meta:
        model = Patient
        fields = ["username", "email", "phone", "password", "confirm_password"]
        extra_kwargs = {"email": {"required": True}}

    def validate(self, data):
        """
        Check that the two password entries match
        """
        if data["password"] != data["confirm_password"]:
            raise serializers.ValidationError({"password": "Passwords do not match."})
        return data

    def create(self, validated_data):
        """
        Create and return a new Patient instance
        """
        validated_data.pop("confirm_password")
        user = Patient.objects.create_user(**validated_data)
        return user
