#!/bin/sh
env=$(whereis env | cut -d ' ' -f2)
find . -name "*.sh" -exec sed -i 's|#!/usr/bin/env bash|#!'"$env"' bash|g' {} \;
