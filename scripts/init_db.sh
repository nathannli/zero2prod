#!/usr/bin/env bash
set -x
set -eo pipefail

# check if psql & sqlx-cli are installed
if ! [ -x "$(command -v psql)" ]; then
	echo >&2 "error: psql is not installed"
	exit 1
fi
if ! [ -x "$(command -v sqlx)" ]; then
	echo >&2 "error: sqlx is not installed"
	exit 1
fi

# check if a custom user has been set, else use 'postgres'
DB_USER="${POSTGRES_USER:=postgres}"
# check if custom password has been set, else use 'password'
DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
# check if custom db has been set, else use 'newsletter'
DB_NAME="${POSTGRES_DB:=newsletter}"
# check if custom port has been set, else use 5432
DB_PORT="${POSTGRES_PORT:=5432}"
# check if custom host has been set, else local
DB_HOST="${POSTGRES_HOST:=localhost}"

# launch postgres via docker if container not exists
if [[ -z "${SKIP_DOCKER}" ]]; then
	docker run \
		-e POSTGRES_USER=${DB_USER} \
		-e POSTGRES_PASSWORD=${DB_PASSWORD} \
		-e POSTGRES_DB=${DB_NAME} \
		-p "${DB_PORT}":5432 \
		-d postgres \
		postgres -N 1000 # increase max num of connections to 1000 for testing purposes
fi

# wait until db is ready before continue
export PGPASSWORD="${DB_PASSWORD}"
until psql -h "${DB_HOST}" -U "${DB_USER}" -p "${DB_PORT}" -d "postgres" -c '\q'; do
	>&2 echo "still making Postgres container.."
	sleep 2
done

>&2 echo "Postgres container is ready on port ${DB_PORT}"

DATABASE_URL=postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
export DATABASE_URL
sqlx database create
sqlx migrate run

>&2 echo "postgres has been migrated, ready to go"
