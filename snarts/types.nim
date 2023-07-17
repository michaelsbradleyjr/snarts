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
  # placeholder
  Actor*[St: enum; Ev: enum; Dm: object; Em: object] = object

  # some of these fields may not be needed, will become more clear as the
  # various ValidatorErrors take shape
  CompilerError* = object of CatchableError
    errors*: seq[ValidationError]
    specName*: string
    dataModel*: string
    eventModel*: string
    events*: string
    states*: string

  Cond* = distinct string

  # ?? do the members need to carry more information, e.g. State objects per
  # the disabled code below
  Configuration*[St: enum] = OrderedSet[St]

  Exe* = distinct string

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

  Statechart*[St: enum; Ev: enum; Dm: object; Em: object] {.pure.} = object
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

  StatechartNode*[St: enum; Ev: enum; Dm: object; Em: object] {.pure.} = object
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

func `$`*(x: Cond): string =
  x.string

func `$`*(x: Exe): string =
  x.string

func `==`*(a, b: Cond): bool =
  a.string == b.string

func `==`*(a, b: Exe): bool =
  a.string == b.string

func `==`*[St, Ev, Dm, Em](
    a, b: StatechartNode[St, Ev, Dm, Em]):
      bool =
  if a.kind != b.kind:
    result = false
  else:
    when (NimMajor, NimMinor, NimPatch) > (1, 6, 10):
      {.push warning[BareExcept]: off.}
    case a.kind
    of snkState:
      try:
        result = (
          (a.sId == b.sId) and
          (a.sInitial == b.sInitial) and
          (a.sChildren == b.sChildren))
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    of snkParallel:
      try:
        result = (
          (a.pId == b.pId) and
          (a.pChildren == b.pChildren))
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    of snkTransition:
      try:
        result = (
          (a.tEvent == b.tEvent) and
          (a.tCond == b.tCond) and
          (a.tTarget == b.tTarget) and
          (a.tKind == b.tKind) and
          (a.tExe == b.tExe))
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    of snkInitial:
      try:
        result = (
          a.iChildren == b.iChildren)
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    of snkFinal:
      try:
        result = (
          (a.fId == b.fId) and
          (a.fChildren == b.fChildren))
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    of snkOnEntry, snkOnExit:
      try:
        result = (
          a.oExe == b.oExe)
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    of snkHistory:
      try:
        result = (
          (a.hId == b.hId) and
          (a.hKind == b.hKind) and
          (a.hChildren == b.hChildren))
      except Exception as e:
        raise (ref Defect)(msg: e.msg)
    when (NimMajor, NimMinor, NimPatch) > (1, 6, 10):
      {.pop.}
