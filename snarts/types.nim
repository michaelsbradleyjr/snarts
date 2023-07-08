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

# import std/[macros, sets]
import std/sets
import pkg/results

export results

# macro Cond*(): untyped =
#   let
#     cond = genSym(nskProc, "cond")
#     config = ident "config"
#     data = ident "data"
#     event = ident "event"
#   result = quote do:
#     proc `cond`(`data`: Dm, `event`: Em, `config`: Configuration[St]): bool
#       {.nimcall, noSideEffect, raises: [].}
#     typeof(`cond`)

# macro Exe*(): untyped =
#   let
#     config = ident "config"
#     data = ident "data"
#     event = ident "event"
#     exe = genSym(nskProc, "exe")
#   result = quote do:
#     proc `exe`(`data`: ref Dm, `event`: Em, `config`: Configuration[St])
#       {.nimcall, noSideEffect, raises: [].}
#     typeof(`exe`)

type
  Cond* = distinct string

  Exe* = distinct string

type
  # placeholder
  Actor[St: enum; Ev: enum; Dm: object; Em: object] = object

  ActorRef*[St: enum; Ev: enum; Dm: object; Em: object] =
    ref Actor[St, Ev, Dm, Em]

  CompilerError* = object of CatchableError
    errors*: seq[ValidationError]
    spec*: string
    # or: object, object, enum, enum for types below; the downstream logic (for
    # raising ValidationDefect) could then handle stringification
    # ...bleh, above idea won't work because it's again typedesc as field,
    # which is problematic; instead remember that desired strings can be derived
    # from a Statechart instance:
    #   $chart0.St
    #   $chart0.Ev
    #   $chart0.Dm
    #   $chart0.Em
    dataModel*: string
    eventModel*: string
    events*: string
    states*: string

  # ?? do the members need to carry more information, e.g. State objects per
  # the disabled code below
  Configuration*[St: enum] = OrderedSet[St]

  HistoryKind* = enum
    hkShallow, hkDeep

  InterpreterError* = object of CatchableError

  # !! refactor
  # -----------
  # Machine*[St: enum; Ev: enum; Dm: object; Em: object] = object
  #   configuration*: Configuration[St]
  #   statesToInvoke*: OrderedSet[...]
  #   data*: T
  #   internalQueue*: seq[Em]
  #   externalQueue*: seq[Em]
  #   historyValue*: Table[...] # not sure yet about key,value types
  #   running*: bool

  # placeholder
  Machine*[St: enum; Ev: enum; Dm: object; Em: object] = object

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
    scInitial*: Opt[St]
    scName*: Opt[string]
    scChildren*: seq[StatechartNode[St, Ev, Dm, Em]]

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
      tCond*: Opt[Cond]
      tTarget*: Opt[St]
      tKind*: TransitionKind
      tExe*: Opt[Exe]
    of snkInitial:
      iChildren*: seq[StatechartNode[St, Ev, Dm, Em]]
    of snkFinal:
      fId*: Opt[St]
      fChildren*: seq[StatechartNode[St, Ev, Dm, Em]]
    of snkOnEntry, snkOnExit:
      oExe*: Opt[Exe]
    of snkHistory:
      hId*: Opt[St]
      hKind*: HistoryKind
      hChildren*: seq[StatechartNode[St, Ev, Dm, Em]]

  TransitionKind* = enum
    tkExternal, tkInternal

  ValidationDefect* = object of Defect

  ValidationError* = object of CatchableError
