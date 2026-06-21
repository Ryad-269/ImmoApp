
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from properties.views import PropertyViewSet, UserInfoView
from django.http import HttpResponse
from properties.views import RegisterView
from django.conf import settings  
from django.conf.urls.static import static

router = DefaultRouter()
router.register(r'properties', PropertyViewSet, basename='property')

def home(request):
    return HttpResponse("Bienvenue sur ImmoDakar")

urlpatterns = [
    path('api/register/', RegisterView.as_view(), name='register'),
    path('', home), 
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api/token/', TokenObtainPairView.as_view()),
    path('api/token/refresh/', TokenRefreshView.as_view()),
    path('api/user/', UserInfoView.as_view()),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)