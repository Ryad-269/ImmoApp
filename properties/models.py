from django.db import models
from django.contrib.auth.models import User
from PIL import Image
import os 

class Property(models.Model):
    STATUS_CHOICES = (
        ('pending', 'En attente'),
        ('approved', 'Approuvé'),
        ('rejected', 'Refusé'),
    )
    titre = models.CharField(max_length=200)
    description = models.TextField()
    prix = models.IntegerField()
    district = models.CharField(max_length=100)
    chambres = models.IntegerField()
    superficie = models.IntegerField(null=True, blank=True)
    photo = models.ImageField(upload_to='properties/', null=True, blank=True)
    proprietaire = models.ForeignKey(User, on_delete=models.CASCADE, related_name='annonces')
    statut = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre
    
    def save(self, *args, **kwargs):
        # Sauvegarder d'abord l'objet (pour que le fichier photo soit enregistré)
        super().save(*args, **kwargs)

        # Traiter l'image seulement si une photo existe
        if self.photo and self.photo.path:
            try:
                image_path = self.photo.path
                if os.path.exists(image_path):
                    with Image.open(image_path) as img:
                        # Convertir en RGB si nécessaire (pour PNG avec transparence)
                        if img.mode in ('RGBA', 'LA'):
                            img = img.convert('RGB')
                        
                        # Dimensions maximales
                        max_width = 800
                        max_height = 600
                        
                        # Redimensionner si l'image est trop grande
                        if img.width > max_width or img.height > max_height:
                            img.thumbnail((max_width, max_height), Image.Resampling.LANCZOS)
                        
                        # Sauvegarder avec compression (qualité 85)
                        img.save(image_path, quality=85, optimize=True)
            except Exception as e:
                print(f"Erreur lors du traitement de l'image : {e}")