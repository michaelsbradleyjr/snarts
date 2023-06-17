# Adapted from: https://www.w3.org/TR/2015/REC-scxml-20150901/
# State Chart XML (SCXML): State Machine Notation for Control Abstraction
# W3C Recommendation 01 September 2015

# TODO
# * consider "done." events, etc. in relation to states; maybe could have a
#   `setup` macro {.setup.} that can be used when declaring the Ev enum type,
#   which would extend it with `any`, `done`, etc.
# * likewise consider a `setup` macro {.setup.} that can be used when declaring
#   the St enum type, which would extend it with `root`, etc.

{.push raises: [].}

# import std/[sets, tables]
import std/sets
import pkg/stew/results

export results

type
  CompilerError* = object of CatchableError
    errors*: seq[ValidationError]
    spec*: SpecName
    dataModel*: SpecName
    eventModel*: SpecName
    events*: SpecName
    states*: SpecName

  # ?? do the members need to carry more information, e.g. State objects
  Configuration*[St: enum] = OrderedSet[St]

  HistoryKind* = enum
    hkShallow, hkDeep

  # Machine*[T; St: enum; Ev: enum; Evd] = object
  #   configuration*: Configuration[St]
  #   statesToInvoke*: OrderedSet[StatechartNode[St, Ev]]
  #   data*: T
  #   internalQueue*: seq[Event[Ev, Evd]]
  #   externalQueue*: seq[Event[Ev, Evd]]
  #   historyValue*: Table[int, int] # not sure yet about key,value types
  #   running*: bool

  SpecName* = distinct string

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
  #     hType*: HistoryKind

  Statechart*[St: enum; Ev: enum; M; Evm] = object
    initial*: Opt[St]
    name*: Opt[SpecName]
    dataModel*: SpecName
    children*: seq[StatechartNode[St, Ev, M, Evm]]
    eventModel*: SpecName
    events*: SpecName
    states*: SpecName

  StatechartNodeKind* = enum
    snkState
    snkParallel
    snkTransition
    snkInitial
    snkFinal
    snkOnEntry
    snkOnExit
    snkHistory

  StatechartNode*[St: enum; Ev: enum; M; Evm] = object
    case kind*: StatechartNodeKind
    of snkState:
      sId*: Opt[St]
      sInitial*: Opt[St]
      sChildren*: seq[StatechartNode[St, Ev, M, Evm]]
    of snkParallel:
      pId*: Opt[St]
      pChildren*: seq[StatechartNode[St, Ev, M, Evm]]
    of snkTransition:
      tEvent*: Opt[Ev]
      tCond*: proc(data: M, event: Evm, config: Configuration[St]): bool
                {.nimcall, noSideEffect, raises: [].}
      tTarget*: Opt[St]
      tType*: TransitionKind
      tExe*: proc(data: ref M, event: Evm, config: Configuration[St])
               {.nimcall, noSideEffect, raises: [].}
    of snkInitial:
      iChildren*: seq[StatechartNode[St, Ev, M, Evm]]
    of snkFinal:
      fId*: Opt[St]
      fChildren*: seq[StatechartNode[St, Ev, M, Evm]]
    of snkOnEntry, snkOnExit:
      oExe*: proc(data: ref M, event: Evm, config: Configuration[St])
               {.nimcall, noSideEffect, raises: [].}
    of snkHistory:
      hId*: Opt[St]
      hType*: HistoryKind
      hChildren*: seq[StatechartNode[St, Ev, M, Evm]]

  TransitionKind* = enum
    tkExternal, tkInternal

  ValidationDefect* = object of Defect

  ValidationError* = object of CatchableError

func `$`*(x: SpecName): string =
  x.string
