from rest_framework import status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from .serializers import PatientRegistrationSerializer


@api_view(["POST"])
@permission_classes([AllowAny])
def register_patient(request):
    # Only allow POST requests
    if request.method != "POST":
        return Response(
            {"error": "Only POST requests are allowed for registration"},
            status=status.HTTP_405_METHOD_NOT_ALLOWED,
        )
    serializer = PatientRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(
            {"message": "User registered successfully", "user": serializer.data},
            status=status.HTTP_201_CREATED,
        )

    # Log validation errors
    print("Validation Errors:", serializer.errors)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_patient_profile(request):
    """
    Retrieve patient's profile data
    """
    patient = request.user
    return Response(
        {"username": patient.username, "email": patient.email, "phone": patient.phone}
    )
