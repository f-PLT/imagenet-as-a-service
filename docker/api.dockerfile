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
ENV HOME_DIR=/home/${USER_NAME}
ENV ENV_DIR=${HOME_DIR}/opt/venv

ENV POETRY_NO_INTERACTION=1
ENV POETRY_CACHE_DIR=/tmp/poetry_cache

# Copy over python environment from previous stage
COPY --from=build-python-env ${ENV_DIR} ${ENV_DIR}

# Install project dependencies
COPY pyproject.toml poetry.lock environment.yml ./

ENV PATH ${ENV_DIR}/bin:$PATH

RUN touch README.md && \
    poetry config virtualenvs.create false --local && \
    poetry install --without dev --no-root && \
    rm -rf $POETRY_CACHE_DIR

#
# Stage 3 : Application runtime
#
FROM python:3.11-slim as runtime

# Configuration of runtime environment
USER root

ARG USER_NAME=worker
ARG USER_ID=10000
ARG GROUP_NAME=workers
ARG GROUP_ID=10000

ENV HOME_DIR=/home/${USER_NAME} 
ENV ENV_DIR=${HOME_DIR}/opt/venv
ENV IMAGENET_SERVICE_DIR=${HOME_DIR}/imagenet-service
ENV PATH=${ENV_DIR}/bin:$PATH

RUN mkdir -p ${IMAGENET_SERVICE_DIR} && \
    groupadd -g ${GROUP_ID} -r ${GROUP_NAME} && \
    useradd -u ${USER_ID} ${USER_NAME} -g ${GROUP_NAME} && \
    chown -R ${USER_NAME}:${GROUP_NAME} ${HOME_DIR} && \
    chmod 1777 -R ${HOME_DIR}

# Copy over python environment from previous stage
COPY --chown=${USER_NAME}:${GROUP_NAME} --from=install-requirements ${ENV_DIR} ${ENV_DIR}

# Copy application related files
COPY --chown=${USER_NAME}:${GROUP_NAME} api ${IMAGENET_SERVICE_DIR}/api
    
# Application runtime
USER ${USER_NAME}

WORKDIR ${IMAGENET_SERVICE_DIR}

ENTRYPOINT [ "uvicorn", "api.api:app", "--host", "0.0.0.0" ]
