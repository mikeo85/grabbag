#!/bin/bash
############################################################
# Get the absolute filename & path in a POSIX-compliant way
# i.e. no assumption that secondary tools are installed
# ==========================================================
# Source: https://stackoverflow.com/a/21188136
############################################################

function get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

function get_abs_filepath() {
  # $1 : relative filename or path
  echo "$(cd "$(dirname "$1")" && pwd)/"
}
