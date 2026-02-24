from rest_framework.permissions import BasePermission
from api.models import *
from rest_framework.permissions import IsAuthenticated

class IsAllowedUser(BasePermission):
    """
    Autorise :
    - les superusers
    - les multiplicateurs validés (quel que soit leur type)
    - les cultivateurs
    """
    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False
        if user.is_superuser:
            return True
        try:
            multiplicator = Multiplicator.objects.get(user=user)
        except Multiplicator.DoesNotExist:
            return False

        if multiplicator.types == 'cultivateurs':
            return True
        return multiplicator.is_validated


class IsSuperuserOrMultiplicator(BasePermission):
    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False

        if user.is_superuser:
            return True

        try:
            m = user.multiplicator
        except Multiplicator.DoesNotExist:
            return False
        return request.user.is_authenticated and m.is_validated
    
class IsCultivateur(BasePermission):
    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False
        return Multiplicator.objects.filter(user=user, types='cultivateurs').exists()


class IsAnonymous(BasePermission):
    def has_permission(self, request, view):
        return not request.user or not request.user.is_authenticated