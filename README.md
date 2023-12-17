# ImageNet Service

This is a small exploratory project to play around with ImageNet models and explore the Pytorch library.

## Setup

### Local Install
First, you will need to configure a Python environment.

An `environment.yml` file has been provided to that effect.

This project assumes the use of `micromamba` and has only been tested under Linux OS.

To create the environment:

"""
$ make create-env
# OR
$ make CONDA_TOOL="your Conda tool" create-env
"""

The application and Python dependencies can then be installed
"""
$ make install
"""

### Docker Install

To build the application as a Docker container
"""
$ make docker-build
"""

To run the application
"""
$ make docker-run

# or, with the application module mounted to the Docker container 
# for live-reload development
$ make docker-run-dev
"
