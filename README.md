# ImageNet Service

This is a small exploratory project to play around with ImageNet models and explore the Pytorch library.

The [Deploying PyTorch in Python via a REST API with Flask](https://pytorch.org/tutorials/intermediate/flask_rest_api_tutorial.html)
has been used as a reference and starting point for this project.

## Setup

### Local Install

First, you will need to configure a Python environment.

An `environment.yml` file has been provided to that effect.

This project assumes the use of `micromamba` and has only been tested under Linux OS.

To create the environment:

```shell
make create-env
```

If you are using a different Conda tool
```shell
make CONDA_TOOL="<YOUR_CONDA_TOOL>" create-env
```

The application and Python dependencies can then be installed
```shell
make install
```

### Docker Install

To build the application as a Docker container
```shell
make docker-build
```

To run the application
```shell
make docker-run
```

Or, with the application module mounted to the Docker container
for live-reload development
```shell
make docker-run-dev
```

### Development

This project uses Nox to automate linting checks, autoformatting and running tests.

Check lint
```shell
make check-lint
```

Fix lint
```shell
make fix-lint
```

Run tests
```shell
make test
```

To run all checks and fixes
```shell
nox
```