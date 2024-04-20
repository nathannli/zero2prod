#!/usr/bin/env bash
set -x
set -eo pipefail

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

# launch postgres via docker
docker run \
	-e POSTGRES_USER=${DB_USER} \
	-e POSTGRES_PASSWORD=${DB_PASSWORD} \
	-e POSTGRES_DB=${DB_NAME} \
	-p "${DB_PORT}":5432 \
	-d postgres \
	postgres -N 1000 # increase max num of connections to 1000 for testing purposes
