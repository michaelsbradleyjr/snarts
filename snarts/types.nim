# Adapted from: https://www.w3.org/TR/2015/REC-scxml-20150901/
# State Chart XML (SCXML): State Machine Notation for Control Abstraction
# W3C Recommendation 01 September 2015

# TODO
# * consider "done." events, etc. in relation to states; maybe could have a
#   `setup` macro {.setup.} that can be used when declaring the Ev enum type,
#   which would extend it with `any`, `done`, etc.
# * likewise consider a `setup` macro {.setup.} that can be used when declaring
#   the St enum type, which would extend it with `root`, etc.
# * consider toStrLit and parseStmt (std/macros) in relation to oExe, tCond,
#   tExe; not sure yet of the interplay with let/const and snarts/algos.compile

{.push raises: [].}

# import std/[sets, tables]
import std/sets
import pkg/stew/results

export results

type
  CompilerError* = object of CatchableError
    errors*: seq[ValidationError]
    spec*: string
    dataModel*: string
    eventModel*: string
    events*: string
    states*: string

  # ?? do the members need to carry more information, e.g. State objects per
  # the disabled code below
  Configuration*[St: enum] = OrderedSet[St]

  HistoryKind* = enum
    hkShallow, hkDeep

  # Machine*[St: enum; Ev: enum; Dm; Em] = object
  #   configuration*: Configuration[St]
  #   statesToInvoke*: OrderedSet[...]
  #   data*: T
  #   internalQueue*: seq[Em]
  #   externalQueue*: seq[Em]
  #   historyValue*: Table[...] # not sure yet about key,value types
  #   running*: bool

  # StateKind* = enum
  #   skState
  #   skParallel
  #   skInitial
  #   skFinal
  #   skHistory

  # State*[St: enum] = object
  #   case kind*: StateKind
  #   of skState:
  #     sId*: Opt[St]
  #     sInitial*: Opt[St]
  #   of skParallel:
  #     pId*: Opt[St]
  #   of skInitial:
  #     discard
  #   of skFinal:
  #     fId*: Opt[St]
  #   of skHistory:
  #     hId*: Opt[St]
  #     hKind*: HistoryKind

  Statechart*[St: enum; Ev: enum; Dm: object; Em: object] = object
    initial*: Opt[St]
    name*: Opt[string]
    children*: seq[StatechartNode[St, Ev, Dm, Em]]

  StatechartNodeKind* = enum
    snkState
    snkParallel
    snkTransition
    snkInitial
    snkFinal
    snkOnEntry
    snkOnExit
    snkHistory

  StatechartNode*[St: enum; Ev: enum; Dm: object; Em: object] = object
    case kind*: StatechartNodeKind
    of snkState:
      sId*: Opt[St]
      sInitial*: Opt[St]
      sChildren*: seq[StatechartNode[St, Ev, Dm, Em]]
    of snkParallel:
      pId*: Opt[St]
      pChildren*: seq[StatechartNode[St, Ev, Dm, Em]]
    of snkTransition:
      tEvent*: Opt[Ev]
      tCond*: Opt[
        proc(data: Dm, event: Em, config: Configuration[St]): bool
          {.nimcall, noSideEffect, raises: [].}]
      tTarget*: Opt[St]
      tKind*: TransitionKind
      tExe*: Opt[
        proc(data: ref Dm, event: Em, config: Configuration[St])
          {.nimcall, noSideEffect, raises: [].}]
    of snkInitial:
      iChildren*: seq[StatechartNode[St, Ev, Dm, Em]]
    of snkFinal:
      fId*: Opt[St]
      fChildren*: seq[StatechartNode[St, Ev, Dm, Em]]
    of snkOnEntry, snkOnExit:
      oExe*: (
        proc(data: ref Dm, event: Em, config: Configuration[St])
          {.nimcall, noSideEffect, raises: [].})
    of snkHistory:
      hId*: Opt[St]
      hKind*: HistoryKind
      hChildren*: seq[StatechartNode[St, Ev, Dm, Em]]

  TransitionKind* = enum
    tkExternal, tkInternal

  ValidationDefect* = object of Defect

  ValidationError* = object of CatchableError
