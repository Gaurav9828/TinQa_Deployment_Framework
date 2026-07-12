#!/usr/bin/env bash
###############################################################################
#
# TinQa Deployment Framework
#
# File        : python.sh
# Version     : 1.0.0
#
# Description :
# Creates a fake Python runtime inside the sandbox.
#
###############################################################################

set -Eeuo pipefail

###############################################################################
# Directories
###############################################################################

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SANDBOX_DIR="${TEST_DIR}/sandbox"

VENV_DIR="${SANDBOX_DIR}/opt/tinqa/venv"

###############################################################################
# Fake Python
###############################################################################

create_python_binary() {

    mkdir -p "${VENV_DIR}/bin"

cat > "${VENV_DIR}/bin/python" <<'EOF'
#!/usr/bin/env bash

echo "Python 3.11.2"

exit 0
EOF

    chmod +x "${VENV_DIR}/bin/python"

}

###############################################################################
# Fake Pip
###############################################################################

create_pip_binary() {

cat > "${VENV_DIR}/bin/pip" <<'EOF'
#!/usr/bin/env bash

echo "pip 24.0"

exit 0
EOF

    chmod +x "${VENV_DIR}/bin/pip"

}

###############################################################################
# Fake Activate Script
###############################################################################

create_activate_script() {

cat > "${VENV_DIR}/bin/activate" <<'EOF'
#!/usr/bin/env bash

export VIRTUAL_ENV="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export PATH="${VIRTUAL_ENV}/bin:${PATH}"
EOF

}

###############################################################################
# Fake Site-Packages
###############################################################################

create_site_packages() {

    mkdir -p \
        "${VENV_DIR}/lib/python3.11/site-packages"

}

###############################################################################
# Fake Installed Packages
###############################################################################

create_packages() {

cat > "${VENV_DIR}/installed_packages.txt" <<EOF
fastapi
uvicorn
pybluez
requests
EOF

}

###############################################################################
# Fake Requirements
###############################################################################

create_requirements() {

cat > "${SANDBOX_DIR}/opt/tinqa/requirements.txt" <<EOF
fastapi
uvicorn
pybluez
requests
EOF

}

###############################################################################
# Fake Version File
###############################################################################

create_python_version() {

cat > "${VENV_DIR}/PYTHON_VERSION" <<EOF
3.11.2
EOF

}

###############################################################################
# Initialize Python
###############################################################################

initialize_python() {

    create_python_binary

    create_pip_binary

    create_activate_script

    create_site_packages

    create_packages

    create_requirements

    create_python_version

}

###############################################################################
# Public API
###############################################################################

export -f \
create_python_binary \
create_pip_binary \
create_activate_script \
create_site_packages \
create_packages \
create_requirements \
create_python_version \
initialize_python