#!/usr/bin/env bash
set -x
set -eo pipefail

function usage_string() {
    echo "Usage: $0 [true|false]"
    echo "Please provide 'true' or 'false' as the first argument to skip or use Docker."
    exit 1
}

# Check if the first argument is provided and valid
if [ -z "$1" ]; then
    # If the first argument is not provided, try to get SKIP_DOCKER from the environment variable
    SKIP_DOCKER="${SKIP_DOCKER}"
    if [ -z "$SKIP_DOCKER" ]; then
        usage_string
    fi
else
    # If the first argument is provided, use it
    if [ "$1" = "true" ] || [ "$1" = "false" ]; then
    SKIP_DOCKER="$1"
fi

# check if psql & sqlx-cli are installed
if ! [ -x "$(command -v sqlx)" ]; then
  echo >&2 "error: sqlx is not installed"
  exit 1
fi

# superuser
SUPER_USER="${POSTGRES_USER:=postgres}"
SUPER_USER_PASSWORD="${POSTGRES_PASSWORD:=password}"
# app user
APP_USER="${APP_USER:=app}"
APP_USER_PWD="${APP_USER_PWD:=secret}"
APP_DB_NAME="${POSTGRES_DB:=newsletter}"
# db settings
DB_PORT="${POSTGRES_PORT:=5432}"
DB_HOST="${POSTGRES_HOST:=localhost}"

# launch postgres via docker if container not exists
CONTAINER_NAME="postgres"
if [ "${SKIP_DOCKER}" = "false" ]; then
  docker run \
    --env POSTGRES_USER=${SUPER_USER} \
    --env POSTGRES_PASSWORD=${SUPER_USER_PASSWORD} \
    --health-cmd="pg_isready -U ${SUPER_USER} || exit 1" \
    --health-interval=1s \
    --health-timeout=5s \
    --health-retries=5 \
    --publish "${DB_PORT}":5432 \
    --detach \
    --name "${CONTAINER_NAME}" \
    postgres -N 1000 # increase max num of connections to 1000 for testing purposes
fi

# wait until db is ready before continue
until [ "$(docker inspect -f "{{.State.Health.Status}}" ${CONTAINER_NAME})" == "healthy" ]; do
  >&2 echo "Postgres is still unavailable - sleeping"
  sleep 2
done
>&2 echo "Postgres container is ready on port ${DB_PORT}"

CREATE_QUERY="CREATE USER ${APP_USER} WITH PASSWORD '${APP_USER_PWD}';"
docker exec -it "${CONTAINER_NAME}" psql -U "${SUPER_USER}" -c "${CREATE_QUERY}"

# create newsletter table and grant privileges
GRANT_QUERY="ALTER USER ${APP_USER} CREATEDB;"
docker exec -it "${CONTAINER_NAME}" psql -U "${SUPER_USER}" -c "${GRANT_QUERY}"

DATABASE_URL=postgres://${APP_USER}:${APP_USER_PWD}@${DB_HOST}:${DB_PORT}/${APP_DB_NAME}
DATABASE_URL=postgres://postgres:password@localhost:5432/newsletter
export DATABASE_URL
sqlx database create
sqlx migrate run
#
>&2 echo "postgres has been migrated, ready to go"
