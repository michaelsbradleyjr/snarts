# Adapted from: https://www.w3.org/TR/2015/REC-scxml-20150901/
# State Chart XML (SCXML): State Machine Notation for Control Abstraction
# W3C Recommendation 01 September 2015

when (NimMajor, NimMinor) >= (1, 4):
  {.push raises: [].}
else:
  {.push raises: [Defect].}

import std/[sets, strutils, tables]
import ./types

export types

# don't delete, will be used eventually
# -------------------------------------
# proc box[T](x: T): ref T =
#   new result
#   result[] = x
#
# proc unbox[T](x: ref T): T =
#   result = x[]

func wrap(s: ChartName | StateId | string): string =
  let s = $s
  if s == "anonymous":
    "<<" & s & ">>"
  else:
    "\"" & s & "\""

func compile*[T](statechart: Statechart[T]): Result[Machine[T], CompilerError] =
  var
    errors: seq[ValidationError]
    # ids of states in statechart
    stateIds: seq[string]
    # states to validate
    states: seq[State]
  let scName =
    if statechart.name.isSome:
      $statechart.name.get
    else:
      "anonymous"
  if statechart.children.len == 0:
    errors.add ValidationError(msg: "statechart has no states in children")
  else:
    for child in statechart.children:
      case child.kind:
      of skInitial:
        errors.add ValidationError(
          msg: "statechart has a state of kind skInitial in children")
      of skHistory:
        errors.add ValidationError(
          msg: "statechart has a state of kind skHistory in children")
      else:
        states.add child
    var i = 0
    while i < states.len:
      let state = states[i]
      if state.kind != skInitial and state.id.isSome:
        stateIds.add $state.id.get
      for child in state.children:
        states.add child
      inc i
  if statechart.initial.isSome and $statechart.initial.get notin stateIds:
    errors.add ValidationError(
      msg: "statechart specifies initial state " & statechart.initial.get.wrap &
           " but no state in " & scName.wrap & " has that id")
  for state in states:
    # ... validation logic for this state ...
    # e.g. for each transition check that target state id is in stateIds
    # e.g. loop over children again (but shouldn't need descent) and check if
    # children are the wrong kind re: this state's kind, e.g. skFinal should
    # not have any children
    # e.g. a state of kind skInitial cannot have an id
    var sId = ""
    if state.id.isSome:
      sId = $state.id.get
      if state.kind == skInitial:
        errors.add ValidationError(
          msg: "state " & sId.wrap &
               " is of kind skInitial and cannot specify an id")
    else:
      sId = "anonymous"

    # this isn't correct, should check if initial is a descendent of this state
    # see section 3.11, as this is also the case for transition/history targets
    if state.initial.isSome and $state.initial.get notin stateIds:
      errors.add ValidationError(
        msg: "state " & sId.wrap & " specifies initial state " &
             state.initial.get.wrap & " but no state in " & scName.wrap &
             " has that id")
  if errors.len > 0:
    err CompilerError(msg: "Statechart " & scName.wrap & " is invalid",
      errors: errors, scName: scName)
  else:
    # need to return Machine instance (not ref!) populated with tables,
    # etc. but ensure that the instance can be stored in a const
    mixin init
    let computer = Machine[T](data: T.init)
    ok computer # Radiohead 1997, what a year!

proc tryGet*[T](machineRes: Result[Machine[T], CompilerError]): Machine[T] =
  if machineRes.isOk:
    machineRes.get
  else:
    let error = machineRes.unsafeError
    var msg = "\nStatechart " & error.scName.wrap & " had "
    if error.errors.len > 1:
      msg &= "validation errors\n"
      for i, error in error.errors.pairs:
        msg &= "[" & $(i + 1) & "] " & error.msg & "\n"
    else:
      msg &= "a validation error\n"
      msg &= "[X] " & error.errors[0].msg & "\n"
    raise (ref ValidationDefect)(msg: msg)



# old stuff from early experiments
# ------------------------------------------------------------------------------
# proc enterStates*(machine: ref Machine,
#     enabledTransitions: OrderedSet[Transition]) =
#   discard

# func isAtomic*(state: State): bool =
#   (state.kind == skFinal) or
#   (state.kind == skState and state.children.len == 0)

# func isCompound*(state: State): bool =
#   (state.kind == skState) and
#   (state.children.len > 0)

# func isPseudo*(state: State): bool =
#   state.kind in [skHistory, skInitial]

# func isTarget*(state: State): bool =
#   state.kind in [skFinal, skHistory, skParallel, skState]

# func kind*(state: State): StateKind =
#   state.kind

# proc new*(_: typedesc[Machine], dataModel: DataModel): ref Machine =
#   (ref Machine)(dataModel: dataModel, running: true)

# proc startEventLoop*(machine: ref Machine) =
#   machine.eventLoop = EventLoop()

# proc stop*(machine: ref Machine) =
#   machine.running = false

# func transition*(state: State): Transition =
#   Transition()

# func validate*(sc: Statechart): Result[void, ValidationError] =
#   # if [invalid]: err ValidationError(...:...)
#   # else:
#   ok()

# rename to start
# -----------------------------------------------------------------------
# proc interpret*(sc: Statechart, datamodel: DataModel, validate = true):
#     Result[ref Machine, ValidationError] =
#   if validate:
#     let res = sc.validate
#     if res.isErr: return err res.error
#   var machine = Machine.new(dataModel)
#   # machine.enterStates [sc.initial.transition].toOrderedSet()
#   # machine.startEventLoop()
#   ok machine
