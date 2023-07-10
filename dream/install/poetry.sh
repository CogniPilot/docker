#!/bin/bash
set -e
set -x

curl -sSL https://install.python-poetry.org | sudo POETRY_HOME=/opt/poetry python3 -

