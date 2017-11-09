#!/usr/bin/env bash

mkdir tmp
cp -r demo tmp
cp -r src tmp
git checkout gh-pages
cp -r tmp/demo/* demo
cp -r tmp/src/* src
rm -r tmp
