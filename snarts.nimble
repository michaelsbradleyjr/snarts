packageName  = "snarts"
version      = "0.1.0"
author       = "Michael Bradley, Jr."
description  = "Executable Statecharts for Nim"
license      = "Apache License 2.0 or MIT"
installDirs  = @["snarts"]
installFiles = @["LICENSE", "LICENSE-APACHEv2", "LICENSE-MIT", "snarts.nim"]

requires "nim >= 1.2.8",
         "chronos",
         "stew",
         "unittest2"
