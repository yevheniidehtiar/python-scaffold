#!/bin/bash

set -e

rm -rf my-project


project_types=("app" "package")
typing_options=("optional" "strict")

for project_type in "${project_types[@]}"; do
    for typing in "${typing_options[@]}"; do
        # Scaffold a Python project
        uvx copier copy --vcs-ref=HEAD . my-project \
            --defaults \
            --data project_type="$project_type" \
            --data project_name="My Project" \
            --data project_description="A Python $project_type that reticulates splines." \
            --data project_url="https://github.com/user/repo" \
            --data author_name="John Smith" \
            --data author_email="john@example.com" \
            --data python_version="3.10" \
            --data typing="$typing" \
            --data with_fastapi_api=true \
            --data with_typer_cli="$([ "$project_type" == "app" ] && echo false || echo true)"

        cd my-project
        git config --global init.defaultBranch main
        git init
        git checkout -b test
        git add .

        # Install dependencies
        uv sync --all-extras

        # Activate the virtual environment
        source ./.venv/bin/activate

        # Lint and test the project
        uv lock --check
        poe lint
        poe security-check
        poe test

        cd -
        rm -rf my-project
    done
done
