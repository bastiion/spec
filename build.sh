#!/usr/bin/env bash
#
# This is a convenient wrapper around the makefile for easier handling of the languages
#
# Inspired by https://gist.github.com/waylan/4080362

ProgName=$(basename $0)
subcommand=$1
case ${subcommand} in
    "-h" | "--help")
        echo "Usage: $ProgName <subcommand> [target]\n"
        echo "Command:"
        echo "   all  Build the English and the German version"
        echo "   en   Build the English version"
        echo "   de   Build the German version"
        ;;
    "")
        make OPARL_LANG=de $1
        make OPARL_LANG=en $1
        ;;
    "all")
        make OPARL_LANG=de $2
        make OPARL_LANG=en $2
        ;;
    "de")
        make OPARL_LANG=de $2
        ;;
    "en")
        make OPARL_LANG=de $2
        ;;
    *)
        make $1
        ;;
esac