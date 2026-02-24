from django.urls import path, include
from rest_framework import routers
# from api.views_ussd import ussd_callback
from .views import *
from rest_framework_simplejwt.views import TokenRefreshView, TokenObtainPairView
from django.conf.urls.static import static
from django.views.static import serve
from django.conf import settings



router = routers.DefaultRouter()

router.register("Multiplicator", MultiplicatorViewset)
router.register('Multiplicator_Roles', MultiplicatorRoleViewset)
router.register("user",UserViewset)
router.register("plantes", PlantViewset)
router.register("variete", VarietyViewset)
router.register("stock", StockViewset)
router.register("commande", CommandeViewset)
router.register("perte", PerteViewset)
router.register("note", NoteViewset)


urlpatterns = [
    path('', include(router.urls)),
    # path('ussd/', ussd_callback, name='ussd_callback'),
    path('api-auth/', include('rest_framework.urls')),
    path('login/', TokenPairViewset.as_view(), name='token_obtain_pair'),
    path('refresh/', TokenRefreshView.as_view()),
    
]