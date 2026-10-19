from django.conf import settings
from django.conf.urls.static import static

# Serve static & media files directly when running standalone (e.g. Render / Cloud) without Nginx
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

