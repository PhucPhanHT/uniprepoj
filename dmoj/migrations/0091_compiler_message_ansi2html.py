# -*- coding: utf-8 -*-
import lxml.html as lh
from django.db import migrations

try:
    from lxml_html_clean import clean_html
except ImportError:
    try:
        from lxml.html.clean import clean_html
    except ImportError:
        def clean_html(doc):
            return doc


def strip_error_html(apps, schema_editor):
    Submission = apps.get_model('judge', 'Submission')
    for sub in Submission.objects.filter(error__isnull=False).iterator():
        if sub.error:
            try:
                sub.error = clean_html(lh.fromstring(sub.error)).text_content()
                sub.save(update_fields=['error'])
            except Exception:
                pass


class Migration(migrations.Migration):

    dependencies = [
        ('judge', '0090_fix_contest_visibility'),
    ]

    operations = [
        migrations.RunPython(strip_error_html, migrations.RunPython.noop, atomic=True),
    ]
