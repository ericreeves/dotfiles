#!/bin/bash
for p in "ipython"; do
    echo "--- Installing $p"
    pip3 install $p
done