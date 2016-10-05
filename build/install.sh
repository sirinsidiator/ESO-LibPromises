#!/bin/bash

set -ev

if hash busted_bootstrap 2>/dev/null; then
    echo "Using cached busted"
else
    echo "busted not found in the cache, install dependencies anew..."
    # install a newer cmake since at this time Travis only has version 2.8.7
    yes | sudo add-apt-repository ppa:kalakris/cmake
    sudo apt-get update -qq
    # install lua
    pip install hererocks
    hererocks lua_install -r^ --$LUA
    export PATH=$PATH:$PWD/lua_install/bin
    # install luarocks
    sudo apt-get install cmake
    sudo apt-get install libev-dev
    luarocks install copas
    luarocks install lua-ev scm --server=http://luarocks.org/repositories/rocks-scm/
    luarocks install moonscript
    luarocks install lua_cliargs 2.5 # busted 1.11 doesn't work with lua_cliargs 3
    luarocks install busted 1.11.1-2 # busted 2.0 doesn't support async tests yet
    luarocks install luv # install luv for simulating setTimeout/zo_callLater
fi

exit 0;