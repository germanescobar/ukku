#!/usr/bin/env bash

command="/exec $@"
docker run -t -i -e DATABASE_URL=postgres://app:5tgbnhy6@postgres/app --link postgres:postgres app /bin/bash -c "$command"