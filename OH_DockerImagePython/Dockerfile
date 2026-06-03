##########################################################
#
# Copyright (c) 2025-2026 Alexander Behring
#
# This program and the accompanying materials are made available
# under the terms of the Apache License 2.0 which is available at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# SPDX-License-Identifier: Apache-2.0
#
#
# Dockerfile to create an Openhab image
# with GraalPy and needed Python modules installed
#

ARG OPENHAB_VERSION="5.1.4"


###########################################
# Create Base Image to be reused by Builds
###########################################
# * incl. req package list
# * updated system
# * installed runtime dependencies
# * Graalpy with symlink indpendend of version

FROM openhab/openhab:${OPENHAB_VERSION}-debian AS tmp_base_buildimage
ARG GRAALPY_VERSION="25.0.1"
ARG GRAALPY_SHA256="5ac049e3e13a9b04eead81851e59dfc794278ffec1933ff429378c1a70c88d32"

#
# Install GraalPy into the image
#
WORKDIR /opt
ADD	https://github.com/oracle/graalpython/releases/download/graal-${GRAALPY_VERSION}/graalpy-community-${GRAALPY_VERSION}-linux-amd64.tar.gz .
# &&\
RUN	echo "${GRAALPY_SHA256} *graalpy-community-${GRAALPY_VERSION}-linux-amd64.tar.gz" | sha256sum -c &&\
	tar -xvzf graalpy-community-${GRAALPY_VERSION}-linux-amd64.tar.gz &&\
	rm graalpy-community-${GRAALPY_VERSION}-linux-amd64.tar.gz &&\
	# Create a vers.-independend symlink
	ln -s /opt/graalpy-community-${GRAALPY_VERSION}-linux-amd64 /opt/graalpy;

#
# General prep
#
# Copy list of required packages
RUN mkdir /tmp/install
WORKDIR /tmp/install
ADD --chmod=444 py_packages_native.txt /tmp/install
ADD --chmod=444 py_packages_graalpy.txt /tmp/install

#
# Install native pacakges
#
RUN set -eux; \
# Install required runtime dependencies (Optional)
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        bash python3 pip python3-venv python3-dev patchelf ;




###########################################
# Build wheels in separate image
###########################################
# so we only take the result (and leave clutter behind)
#
FROM tmp_base_buildimage AS tmp_buildimage

#
# General prep
#
# Copy list of required packages
# in baseimage

#
# Installation
#
RUN set -eux; \
# update & install in baseimage
# Install required build dependencies (Optional)
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential ; \
# Create a standard venv with the packages that are used by native script
	python3 -m venv /venvs/std_native; \
# Ensure latest pip is used
	/venvs/std_native/bin/pip install --upgrade pip; \
# Prepare python packages
    /venvs/std_native/bin/pip wheel \
        --wheel-dir=/root/native_wheels \
        -r /tmp/install/py_packages_native.txt

#
# Install GraalPy into the image
# in baseimage

#
# Create a GraalPy venv and produce wheels in it
#
# Attention! Some packages wont compile natively GraalPy:
# * msgpack (used by influxdb) -> MSGPACK_PUREPYTHON=1
#
RUN	/opt/graalpy/bin/graalpy -m venv /venvs/graalpy; \
	MSGPACK_PUREPYTHON=1 /venvs/graalpy/bin/pip wheel \
		--wheel-dir=/root/graal_wheels \
		-r /tmp/install/py_packages_graalpy.txt


###########################################
# Build the final image
###########################################
#
FROM tmp_base_buildimage

# Other args must come after FROM, as otherwise, they would not be accessible from the script
ARG RUN_GID="1001"

#
# General prep
#
# Copy list of required packages
# in baseimage
#
# Copy created wheels
COPY --from=tmp_buildimage /root/native_wheels /root/native_wheels
COPY --from=tmp_buildimage /root/graal_wheels /root/graal_wheels

#
# Install native pacakges
#
RUN set -eux; \
# update & install in baseimage
# only clean ...
    DEBIAN_FRONTEND=noninteractive apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
# Create a standard venv with the packages that are used by native script
	python3 -m venv /venvs/std_native; \
# Ensure latest pip is used
	/venvs/std_native/bin/pip install --upgrade pip; \
# Install python packages and cleanup
    /venvs/std_native/bin/pip install \
        --no-index \
		--find-links=/root/native_wheels \
        -r /tmp/install/py_packages_native.txt; \
    rm -rf /root/native_wheels


#
# Install GraalPy into the image
# in baseimage

#
# Create a GraalPy venv and install wheels used by Python 3 Binding scripts in it
#
# The venv target dir (which is linked) must match your "venv path" of openHAB Python3 binding
# Wheels were produced in temp. image. There, any compilation errors were taken care of.
#
RUN	/opt/graalpy/bin/graalpy -m venv /venvs/graalpy; \
	rm -rf /openhab/userdata/cache/org.openhab.automation.pythonscripting/venv; \
	ln -s /openhab/userdata/cache/org.openhab.automation.pythonscripting/venv /venvs/graalpy; \
	/venvs/graalpy/bin/pip install \
		--no-index \
		--find-links=/root/graal_wheels \
		-r /tmp/install/py_packages_graalpy.txt; \
    rm -rf /root/graal_wheels

# Set GID to run as
ENV GROUP_ID=${RUN_GID}

#
# Init scripts run on each container startup
#
# E.g. to ensure that the /venvs/graalpy is used instead of
# the venv dir in userdata/cache
#
ADD cont-init.d/* /etc/cont-init.d/

# Return to openhab dir
WORKDIR /openhab