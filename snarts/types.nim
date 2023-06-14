# Adapted from: https://www.w3.org/TR/2015/REC-scxml-20150901/
# State Chart XML (SCXML): State Machine Notation for Control Abstraction
# W3C Recommendation 01 September 2015

# TODO
# * ...

{.push raises: [].}

import std/[sets, tables]
import pkg/stew/results

export results

type
  ChartName* = distinct string

  CompilerError* = object of CatchableError
    errors*: seq[ValidationError]
    dataModel*: string
    eventModel*: string
    spec*: string

  # ?? could it be more simply `OrderedSet[St]`
  Configuration*[St: enum] = OrderedSet[State[St]]

  # need to consider "done." events, etc. in relation to states; maybe could
  # have a `setup` macro {.setup.} that can be used when declaring the Ev enum
  # type, which would extend it with `any`, `doneSt...`, etc.

  # ?? is a specific event type needed; maybe Evd is enough on its own so long
  # as it has a `name` field, with the recommendation being for that field to
  # have type Ev; could be an object or object variant, i.e. with
  # `case name: Ev`

  # maybe Nim's concepts and generics be used for the idea above, i.e. Event
  # has a field `name` that `is` generic parameter `Ev`; if that can work, then
  # would not need `Evd`, which would be helpful for simplifying the setup of a
  # statechart instance and its nodes
  Event*[Ev: enum; Evd] = object
    name*: Ev
    data*: Evd

  EventSpec* = distinct string

  # ?? does it need revision (probably), cf. notes above re: Event type
  Exe*[St: enum; Ev: enum; Evd] = object
    exe*: proc(
      T: typedesc,
      data: ref T,
      event: Event[Ev, Evd],
      config: Configuration[St]) {.noSideEffect.}

  # ?? same signature as Exe (but T vs. ref T), or can it be simplified
  # need to understand better what SCXML cond expects/supports
  Exp*[St: enum; Ev: enum; Evd] = object
    exp*: proc(
      T: typedesc,
      data: T,
      event: Event[Ev, Evd],
      config: Configuration[St]): bool {.noSideEffect.}

  HistoryKind* = enum
    hkShallow, hkDeep

  Machine*[T; St: enum; Ev: enum; Evd] = object
    configuration*: Configuration[St]
    statesToInvoke*: OrderedSet[StatechartNode[St, Ev]]
    data*: T
    internalQueue*: seq[Event[Ev, Evd]]
    externalQueue*: seq[Event[Ev, Evd]]
    historyValue*: Table[int, int] # not sure yet about key,value types
    running*: bool

  ModelName* = distinct string

  StateKind* = enum
    skState
    skParallel
    skInitial
    skFinal
    skHistory

  State*[St: enum] = object
    case kind*: StateKind
    of skState:
      sId*: Opt[St]
      sInitial*: Opt[St]
    of skParallel:
      pId*: Opt[St]
    of skInitial:
      discard
    of skFinal:
      fId*: Opt[St]
    of skHistory:
      hId*: Opt[St]
      hType*: HistoryKind

  StateSpec* = distinct string

  Statechart*[T; St: enum; Ev: enum; Evd] = object
    initial*: Opt[St]
    name*: Opt[ChartName]
    dataModel*: ModelName
    children*: seq[StatechartNode[St, Ev, Evd]]
    eventModel*: ModelName
    eventSpec*: EventSpec
    stateSpec*: StateSpec

  StatechartNodeKind* = enum
    snkState
    snkParallel
    snkTransition
    snkInitial
    snkFinal
    snkOnEntry
    snkOnExit
    snkHistory

  TransitionKind* = enum
    tkExternal, tkInternal

  StatechartNode*[St: enum; Ev: enum; Evd] = object
    case kind*: StatechartNodeKind
    of snkState:
      sId*: Opt[St]
      sInitial*: Opt[St]
      sChildren*: seq[StatechartNode[St, Ev, Evd]]
    of snkParallel:
      pId*: Opt[St]
      pChildren*: seq[StatechartNode[St, Ev, Evd]]
    of snkTransition:
      tEvent*: Opt[Event[Ev, Evd]]
      # tCond*: Opt[Exp[St, Ev, Evd]]
      tTarget*:  Opt[St]
      tType*: TransitionKind
      # tExe*: Exe[St, Ev, Evd]
    of snkInitial:
      iChildren*: seq[StatechartNode[St, Ev, Evd]]
    of snkFinal:
      fId*: Opt[St]
      fChildren*: seq[StatechartNode[St, Ev, Evd]]
    of snkOnEntry, snkOnExit:
      # oExe*: Exe[St, Ev, Evd]
      discard
    of snkHistory:
      hId*: Opt[St]
      hType*: HistoryKind
      hChildren*: seq[StatechartNode[St, Ev, Evd]]

  ValidationDefect* = object of Defect

  ValidationError* = object of CatchableError

func `$`*(x: ChartName): string =
  x.string

func `$`*(x: EventSpec): string =
  x.string

func `$`*(x: ModelName): string =
  x.string

func `$`*(x: StateSpec): string =
  x.string
