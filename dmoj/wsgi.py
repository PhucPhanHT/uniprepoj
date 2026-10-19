import os
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dmoj.settings')

try:
    import MySQLdb  # noqa: F401, imported for side effect
except ImportError:
    import pymysql

    pymysql.install_as_MySQLdb()

# Django 4+ compatibility shim for legacy apps (reversion, etc.)
try:
    import django.utils.translation
    if not hasattr(django.utils.translation, 'ugettext'):
        django.utils.translation.ugettext = django.utils.translation.gettext
    if not hasattr(django.utils.translation, 'ugettext_lazy'):
        django.utils.translation.ugettext_lazy = django.utils.translation.gettext_lazy
    if not hasattr(django.utils.translation, 'ungettext'):
        django.utils.translation.ungettext = django.utils.translation.ngettext
    if not hasattr(django.utils.translation, 'ungettext_lazy'):
        django.utils.translation.ungettext_lazy = django.utils.translation.ngettext_lazy
except Exception:
    pass

from django.core.wsgi import get_wsgi_application  # noqa: E402, django must be imported here
application = get_wsgi_application()
