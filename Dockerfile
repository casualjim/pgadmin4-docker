FROM python:3.7-alpine

ENV PGADMIN_VERSION=3.6 \
PYTHONDONTWRITEBYTECODE=1

# Install postgresql tools for backup/restore
RUN apk add --no-cache postgresql \
  && cp /usr/bin/psql /usr/bin/pg_dump /usr/bin/pg_dumpall /usr/bin/pg_restore /usr/local/bin/ \
  && apk del postgresql

RUN apk add --no-cache alpine-sdk postgresql-dev libffi-dev linux-headers \
  && echo "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN_VERSION}/pip/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl" | pip install --no-cache-dir -r /dev/stdin \
  && apk del alpine-sdk linux-headers \
  && addgroup -g 50 -S pgadmin \
  && adduser -D -S -h /pgadmin -s /sbin/nologin -u 1000 -G pgadmin pgadmin \
  && mkdir -p /pgadmin/config /pgadmin/storage \
  && chown -R 1000:50 /pgadmin

EXPOSE 5050

COPY LICENSE config_distro.py /usr/local/lib/python3.7/site-packages/pgadmin4/

USER pgadmin:pgadmin
CMD ["python", "./usr/local/lib/python3.7/site-packages/pgadmin4/pgAdmin4.py"]
VOLUME /pgadmin/