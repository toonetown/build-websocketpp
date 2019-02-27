## Websocket++ Packaging ##

This project provides a script which will package Websocket++ headers in a similar manner to the other `build-*` projects.  It contains as a submodule, [toonetown/websocketpp][websocketpp-release] git project.

[websocketpp-release]: https://github.com/toonetown/websocketpp

### Requirements ###

This library is header-only and the script just copies the headers into a package.

     
### Build Steps ###

You can package this by using the `build.sh` script:

    ./build.sh [/path/to/websocketpp-dist] package </path/to/output/directory>

Run `./build.sh` itself to see details on its options.

You can modify the execution of the scripts by setting various environment variables.  See the script sources for lists of these variables.
