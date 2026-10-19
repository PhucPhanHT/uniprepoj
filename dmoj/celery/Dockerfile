FROM ndoj/ndoj-base

ENTRYPOINT celery -A dmoj_celery worker -l info --concurrency=2
