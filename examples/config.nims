import std/os

--path:".."

const
  cfgPath = currentSourcePath.parentDir
  topPath = cfgPath.parentDir
  cacheSubdirHead = joinPath(topPath, "nimcache")
  cacheSubdirTail = joinPath(relativePath(projectDir(), topPath), projectName())
  cacheSubdir = joinPath(cacheSubdirHead,
    (if defined(release): "release" else: "debug"), cacheSubdirTail)

switch("nimcache", cacheSubdir)

--panics:on
--threads:on
--tlsEmulation:off

--hint:"XCannotRaiseY:off"
--warning:"BareExcept:on"

when defined(release):
  --hints:off
  --opt:size
  --passC:"-flto"
  --passL:"-flto"
  --passL:"-s"
else:
  --debugger:native
  --define:debug
  --linetrace:on
  --stacktrace:on

# with `--passL:"-s"` macOS' Xcode's `ld` will report: "ld: warning: option -s
# is obsolete and being ignored"; however, the resulting binary will still be
# about 15K smaller; supplying `--define:strip` or `switch("define", "strip")`
# in config.nims does not produce an equivalent binary, though manually passing
# the same `--define/-d:strip` as an option to `nim c` on the command-line does
# produce an equivalent binary
