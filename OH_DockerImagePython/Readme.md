# OH_DockerImagePython

Dockerfile to create an Openhab image with GraalPy and needed Python modules installed.
This allows for example to run different scripts with different dependencies.

Graalypy is installed and a symlink is provided in folder */opt/graalpy*.

You can define which packages are installed in the global system and in the venv:
* py_packages_graalpy.txt - list of packages to installe in Graalypy venv
* py_packages_native.txt - list of packages to install system wide

Furthermore, start scripts are included that:
* 00-reset-acls.sh - reset the ACLs to ensure accessibility for e.g. backups or edits
* 01-EnsureVenvSimlink.sh - ensures that the venv is available via /

The image build process includes building wheels for all packages required. Thereby,
some packages seem to require specific build flags (otherwise also won't install).
See Dockerfile to adjust these.

Further configuration options in Dockerfile:
* RUN_GID - the GID to run Openhab with
* GRAALPY_SHA256 - the hash for the Graalpy version to install
* GRAALPY_VERSION - the Graalpy version to installe


## Commands to build:
Basic w/ cache:
```
docker build -t openhab-python:5.1.4 .
# Only specific stages:
docker build --target tmp_base_buildimage -t tmp_base_buildimage .
docker build --target tmp_buildimage -t tmp_buildimage .
```

More sophisticated with args set:
```
docker build --build-arg OPENHAB_VERSION=5.1.4-debian --build-arg LOCALPATH="./" --progress=plain --no-cache -t openhab-python:5.1.4 .
```

## Adjust to new OH version
- update ARGs to match new OH version
- Check for used Graal version (variable graalvm.version): https://github.com/openhab/openhab-addons/blob/5.1.x/pom.xml
- Update GRAALPY_ version and SHA256 (later from website) - NOTE THAT MUST BE DONE IN MULTIPLE PLACES!
  https://github.com/oracle/graalpython/releases/download/graal-${GRAALPY_VERSION}/graalpy-community-${GRAALPY_VERSION}-linux-amd64.tar.gz.sha256

## Remarks
- The OH maintainers use the debian version for general / latest tags -> use this
- Some ARGs are given multiple times, as they must be defaulted after EVERY
  FROM clause. Otherwise, they have no value set
