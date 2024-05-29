#!/bin/bash
sudo -u ec2-user -i <<'EOF'
conda install -c conda-forge pyspark -y
EOF
