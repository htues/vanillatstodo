#!/bin/bash
docker compose run --rm terraform terraform fmt -recursive
docker compose run --rm terraform terraform fmt -check -diff
