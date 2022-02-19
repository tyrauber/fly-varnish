#!/bin/sh

chown -R appuser:appgroup /app
su - appuser
exec "$@"