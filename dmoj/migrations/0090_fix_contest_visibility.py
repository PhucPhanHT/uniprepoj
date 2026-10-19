from django.db import migrations


def fix_visibility_forwards(apps, schema_editor):
    vendor = schema_editor.connection.vendor
    if vendor == 'postgresql':
        schema_editor.execute("""
            UPDATE judge_contest
            SET is_private = FALSE, is_organization_private = TRUE
            WHERE is_private = TRUE;
        """)
    elif vendor == 'mysql':
        schema_editor.execute("""
            UPDATE `judge_contest`
            SET `judge_contest`.`is_private` = 0, `judge_contest`.`is_organization_private` = 1
            WHERE `judge_contest`.`is_private` = 1;
        """)
    else:  # sqlite and others
        schema_editor.execute("""
            UPDATE judge_contest
            SET is_private = 0, is_organization_private = 1
            WHERE is_private = 1;
        """)


def fix_visibility_backwards(apps, schema_editor):
    vendor = schema_editor.connection.vendor
    if vendor == 'postgresql':
        schema_editor.execute("""
            UPDATE judge_contest
            SET is_private = is_organization_private;
        """)
    elif vendor == 'mysql':
        schema_editor.execute("""
            UPDATE `judge_contest`
            SET `judge_contest`.`is_private` = `judge_contest`.`is_organization_private`;
        """)
    else:  # sqlite and others
        schema_editor.execute("""
            UPDATE judge_contest
            SET is_private = is_organization_private;
        """)


class Migration(migrations.Migration):

    dependencies = [
        ('judge', '0089_submission_to_contest'),
    ]

    operations = [
        migrations.RunPython(fix_visibility_forwards, fix_visibility_backwards, elidable=True),
    ]

