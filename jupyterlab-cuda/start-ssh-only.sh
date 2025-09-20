#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH with provided public key"
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        cd /root/.ssh
        echo $PUBLIC_KEY >> authorized_keys
        chmod 700 -R /root/.ssh
        cd /
        service ssh start
        echo "SSH service started"
    fi
}

# Start jupyter lab
start_jupyter() {
    if [[ $JUPYTER_PASSWORD ]]; then
        echo "Starting Jupyter Lab..."
        cd /
        # Run Jupyter as root with full privileges
        jupyter lab --allow-root --no-browser --port=8888 --ip=0.0.0.0 \
            --NotebookApp.allow_origin='*' \
            --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
            --ServerApp.token=$JUPYTER_PASSWORD \
            --ServerApp.allow_origin=* \
            --ServerApp.preferred_dir=/workspace \
            --ServerApp.root_dir=/
        echo "JupyterLab started with password authentication"
    else
        echo "JUPYTER_PASSWORD not set, skipping JupyterLab startup"
    fi
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

echo "Pod Started"

setup_ssh
start_jupyter

echo "Start script finished, pod is ready to use."

sleep infinity
