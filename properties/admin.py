from django.contrib import admin
from .models import Property

@admin.register(Property)
class PropertyAdmin(admin.ModelAdmin):
    list_display = ('id', 'titre', 'prix', 'district', 'statut', 'proprietaire')
    list_filter = ('statut', 'district')
    search_fields = ('titre', 'description')