#!/bin/bash

rm -rf build
mkdir -p ./build/debug
odin build ./src -out:./build/debug/raylodin -debug
