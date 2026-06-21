from django.db import models
from django.contrib.auth.models import User

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