#!/bin/bash
docker run --rm --name joinmy-dev-db -e POSTGRES_PASSWORD=postgres -e POSTGRES_USERNAME=postgres -e POSTGRES_DB=joinmy_dev -i -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data  postgres
