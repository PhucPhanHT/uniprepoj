#!/usr/bin/env python
import os
import sys

try:
    import MySQLdb  # noqa: F401, imported for side effect
except ImportError:
    try:
        import dmoj_install_pymysql  # noqa: F401, imported for side effect
    except ImportError:
        try:
            import pymysql
            pymysql.install_as_MySQLdb()
        except ImportError:
            pass

if __name__ == '__main__':
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

    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'dmoj.settings')

    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)

