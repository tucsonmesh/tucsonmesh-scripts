# Tucson Mesh Quick Analysis 

These are scripts and analysis notebooks to accomplish one-off or rarely data analysis tasks.

## Projects

- `google-maps-link`: Get a formatted address and a maps link that can be pasted into Trello when a card was created manually. This is to ensure that the `trello-to-geojson` script can get the coordinates for a card.
- `neighborhood-nodes`: Find potential nodes in a particular neighborhood that have not yet been surveyed.

## Assumptions

- Python 3.12+
- uv

## Install Python dependencies

```bash
uv sync
```

## Create an IPython kernel

To create an IPython kernel for running notebooks in JupyterLab, run:

```bash
uv run python -m ipykernel install --user --name tucsonmesh-quick-analysis --display-name "Python (tucsonmesh-quick-analysis)"
```

## Start Jupyter Lab

```
uv run jupyter lab
```

## Adding a new project

If your project is a task that uses manual data manipulation in a spreadsheet, or other command-line tools, you can just create a subdirectory of `projects` and document your process in a `README.md` file.

However, if you plan to use Python code, make sure you add your subdirectory to the uv workspace:

```
uv init --bare projects/your-new-task-slug
```

If you want to add additional Python packages used only by that task, use:

```
uv add --project your-new-task-slug somepythonpackage
```

