from rest_framework import viewsets, permissions
from .models import Property
from .serializers import PropertySerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics
from django.contrib.auth.models import User
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from .serializers import UserSerializer

# Créez un sérialiseur simple pour l'utilisateur (à ajouter dans serializers.py)

class IsOwnerOrReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.proprietaire == request.user

class PropertyViewSet(viewsets.ModelViewSet):
    serializer_class = PropertySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]

    def get_queryset(self):
        queryset = Property.objects.filter(statut='approved')
        district = self.request.query_params.get('district')
        min_price = self.request.query_params.get('min_price')
        max_price = self.request.query_params.get('max_price')
        rooms = self.request.query_params.get('rooms')
        if district:
            queryset = queryset.filter(district=district)
        if min_price:
            queryset = queryset.filter(prix__gte=min_price)
        if max_price:
            queryset = queryset.filter(prix__lte=max_price)
        if rooms:
            queryset = queryset.filter(chambres=rooms)
        return queryset.order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(proprietaire=self.request.user)
    # ... etc.
class UserInfoView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        data = {
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'is_staff': user.is_staff,
            'is_superuser': user.is_superuser,
        }
        return Response(data)
    
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = UserSerializer