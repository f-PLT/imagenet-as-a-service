#
# This is a multi-stage docker file. Composed of 3 stages
#

#
# Stage 1 : Conda env creation and unpacking
#
FROM continuumio/miniconda3 AS build-python-env

# Create python environment
ARG USER_NAME=worker
ENV HOME_DIR=/home/${USER_NAME}
ENV ENV_DIR=${HOME_DIR}/opt/venv
ENV CONDA_ENVIRONMENT=imagenet-service

COPY environment.yml .

RUN mkdir -p ${ENV_DIR}
RUN conda env create -f environment.yml && \
    conda install -c conda-forge conda-pack

# Convert conda environment to simple virtual environment
RUN conda-pack -n ${CONDA_ENVIRONMENT} -o /tmp/env.tar && \
    cd ${ENV_DIR} && \
    tar xf /tmp/env.tar && \
    rm /tmp/env.tar &&\
    ${ENV_DIR}/bin/conda-unpack


#
# Stage 2: Installing requirements
#
FROM python:3.11-slim as install-requirements

ARG USER_NAME=worker
ENV POETRY_NO_INTERACTION=1
ENV POETRY_CACHE_DIR=/tmp/poetry_cache
ENV HOME_DIR=/home/${USER_NAME}
ENV ENV_DIR=${HOME_DIR}/opt/venv
ENV PATH=${ENV_DIR}/bin:$PATH


# Copy over python environment from previous stage
COPY --from=build-python-env ${ENV_DIR} ${ENV_DIR}

# Install dependencies
COPY pyproject.toml poetry.lock environment.yml ./

RUN touch README.md && \
    poetry config virtualenvs.create false --local && \
    poetry install --without dev --no-root && \
    rm -rf $POETRY_CACHE_DIR

#
# Stage 3: Installing runtime environment
#
FROM python:3.11-slim as runtime

ENV POETRY_NO_INTERACTION=1
ENV POETRY_CACHE_DIR=/tmp/poetry_cache

ARG USER_NAME=worker
ARG USER_ID=10000
ARG GROUP_NAME=workers
ARG GROUP_ID=10000

ENV HOME_DIR=/home/${USER_NAME}
ENV ENV_DIR=${HOME_DIR}/opt/venv
ENV IMAGENET_SERVICE_DIR=${HOME_DIR}/imagenet-service
ENV PATH=${ENV_DIR}/bin:$PATH

# Create base structure and permissions
USER root
RUN mkdir -p ${IMAGENET_SERVICE_DIR} && \
    groupadd -g ${GROUP_ID} -r ${GROUP_NAME} && \
    useradd -u ${USER_ID} ${USER_NAME} -g ${GROUP_NAME} && \
    chown -R ${USER_NAME}:${GROUP_NAME} ${HOME_DIR} && \
    chmod 1777 -R ${HOME_DIR}
# Copy over python environment from previous stage
COPY --chown=${USER_NAME}:${GROUP_NAME} --from=install-requirements ${ENV_DIR} ${ENV_DIR}

# Copy application related files
COPY --chown=${USER_NAME}:${GROUP_NAME} pyproject.toml poetry.lock environment.yml ${IMAGENET_SERVICE_DIR}
COPY --chown=${USER_NAME}:${GROUP_NAME} imagenet_service ${IMAGENET_SERVICE_DIR}/imagenet_service
COPY --chown=${USER_NAME}:${GROUP_NAME} static ${IMAGENET_SERVICE_DIR}/static

# Install package
USER ${USER_NAME}
WORKDIR ${IMAGENET_SERVICE_DIR}
RUN touch README.md && \
    poetry config virtualenvs.create false --local && \
    poetry install --without dev && \
    rm -rf $POETRY_CACHE_DIR

WORKDIR ${IMAGENET_SERVICE_DIR}/imagenet_service
# Application runtime
ENTRYPOINT [ "uvicorn", "main:app", "--host", "0.0.0.0" ]
