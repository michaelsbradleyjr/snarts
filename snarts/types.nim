# Adapted from: https://www.w3.org/TR/2015/REC-scxml-20150901/
# State Chart XML (SCXML): State Machine Notation for Control Abstraction
# W3C Recommendation 01 September 2015

# TODO
# * consider whether event and IDs could be enums supplied as generic params
# * reconsider usages of distinct string
# * consider wrapping everything in a StatechartNode type that uses case with
#   StatechartNodeKind; State (with its StateKind) would be one of the cases
#   e.g. snkState

when (NimMajor, NimMinor) >= (1, 4):
  {.push raises: [].}
else:
  {.push raises: [Defect].}

import std/[sets, tables]
import pkg/stew/results

export results

type
  ChartName* = distinct string

  ModelName* = distinct string

  Event* = object

  StateId* = distinct string

  # ?? should be a func (proc {.pure.})
  Action* = object

  # ?? should be a proc
  Invocation* = object

  Transition* = object

  StateKind* = enum
    skState
    skFinal,
    skHistory,
    skInitial,
    skParallel

  State* = object
    case kind*: StateKind
    of skState:
      children*: seq[State]
      id*: Opt[StateId]
      initial*: Opt[StateId]
      invocations*: seq[Invocation]
      onEntry*: seq[Action]
      onExit*: seq[Action]
      transitions*: seq[Transition]
    # of skParallel:
    #   children: seq[State]
    #   id: Opt[StateId]
    #   invocations: seq[Invocation]
    #   onEntry: seq[Action]
    #   onExit: seq[Action]
    #   transitions: seq[Transition]
    # get rid of else:
    else:
      discard

  Statechart*[T] = object
    children*: seq[State]
    initial*: Opt[StateId]
    model*: ModelName
    name*: Opt[ChartName]

  ValidationDefect* = object of Defect

  ValidationError* = object of CatchableError

  CompilerError* = object of CatchableError
    errors*: seq[ValidationError]
    model*: string
    spec*: string

  Configuration* = OrderedSet[State]

  EventLoop* = object

  Machine*[T] = object
    configuration*: Configuration
    data*: T
    externalQueue*: seq[Event]
    historyValue*: Table[int, int] # not sure yet about key,value types
    internalQueue*: seq[Event]
    eventLoop*: EventLoop
    running*: bool
    statesToInvoke*: OrderedSet[State]

func `$`*(x: ChartName): string =
  x.string

func `$`*(x: ModelName): string =
  x.string

func `$`*(x: StateId): string =
  x.string
