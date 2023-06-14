{.push raises: [].}

import std/[macros, typetraits]
# import ./snarts/algos
import ./snarts/types

# export algos
export types

type
  None* = enum
    none

  Void = object

# func init*(T: typedesc[Void]): T =
#   Void()

# macro atomic*(): auto =
#   result = quote do:
#     State(kind: skState)

# macro atomic*(id: string): auto =
#   result = quote do:
#     State(kind: skState, id: Opt.some StateId `id`)

# macro state*(children: openArray[State]): auto =
#   result = quote do:
#     State(kind: skState, children: @`children`)

# macro statechart*(children: openArray[State]): auto =
#   let tName = bindSym"name"
#   result = quote do:
#     Statechart[Void](children: @`children`, model: ModelName(Void.`tName`))

# macro statechart*(name: string, children: openArray[State]): auto =
#   let tName = bindSym"name"
#   result = quote do:
#     Statechart[Void](children: @`children`, model: ModelName(Void.`tName`),
#       name: Opt.some ChartName `name`)

# macro statechart*(T: typedesc, children: openArray[State]): auto =
#   let tName = bindSym"name"
#   result = quote do:
#     Statechart[`T`](children: @`children`, model: ModelName(`T`.`tName`))

# macro statechart*(T: typedesc, name: string, children: openArray[State]): auto =
#   let tName = bindSym"name"
#   result = quote do:
#     Statechart[`T`](children: @`children`, model: ModelName(`T`.`tName`),
#       name: Opt.some ChartName `name`)



# the new way of things
# ------------------------------------------------------------------------------

macro state*(
    St: typedesc[enum],
    Ev: typedesc[enum],
    Evd: typedesc,
    children: untyped): auto =
  result = quote do:
    StatechartNode[`St`, `Ev`, `Evd`](
      kind: snkState,
      sChildren: @`children`)

# macro state*[S: enum](
#   St: typedesc[enum],
#   Ev: typedesc[enum],
#   Evd: typedesc,
#   id: S,
#   children: untyped): auto =
#     result = quote do:
#       StatechartNode[`St`, `Ev`, `Evd`](
#         kind: snkState,
#         sId: Opt.some `id`,
#         sChildren: @`children`)

# macro state*[S: enum](
#   St: typedesc[enum],
#   Ev: typedesc[enum],
#   Evd: typedesc,
#   initial: S,
#   children: untyped): auto =
#     result = quote do:
#       StatechartNode[`St`, `Ev`, `Evd`](
#         kind: snkState,
#         sInitial: Opt.some `initial`,
#         sChildren: @`children`)

macro state*[S: enum](
  St: typedesc[enum],
  Ev: typedesc[enum],
  Evd: typedesc,
  id: S,
  initial: S,
  children: untyped): auto =
    result = quote do:
      StatechartNode[`St`, `Ev`, `Evd`](
        kind: snkState,
        sId: Opt.some `id`,
        sInitial: Opt.some `initial`,
        sChildren: @`children`)

macro parallel*(
  St: typedesc[enum],
  Ev: typedesc[enum],
  Evd: typedesc,
  children: untyped): auto =
    result = quote do:
      StatechartNode[`St`, `Ev`, `Evd`](
        kind: snkParallel,
        pChildren: @`children`)

macro parallel*[S: enum](
  St: typedesc[enum],
  Ev: typedesc[enum],
  Evd: typedesc,
  id: S,
  children: untyped): auto =
    result = quote do:
      StatechartNode[`St`, `Ev`, `Evd`](
        kind: snkParallel,
        pId: Opt.some `id`,
        pChildren: @`children`)

macro statechart*(children: untyped): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[Void, None, None, Void](
      dataModel: ModelName `tName` Void,
      children: @`children`,
      eventModel: ModelName `tName` Void,
      eventSpec: EventSpec `tName` None,
      stateSpec: StateSpec `tName` None)

macro statechart*(
    name: string,
    children: untyped): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[Void, None, None, Void](
      name: Opt.some ChartName `name`,
      dataModel: ModelName `tName` Void,
      children: @`children`,
      eventModel: ModelName `tName` Void,
      eventSpec: EventSpec `tName` None,
      stateSpec: StateSpec `tName` None)

macro statechart*[S: enum](
    St: typedesc[enum],
    initial: S,
    children: untyped): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[Void, `St`, None, Void](
      initial: Opt.some `initial`,
      dataModel: ModelName `tName` Void,
      children: @`children`,
      eventModel: ModelName `tName` Void,
      eventSpec: EventSpec `tName` None,
      stateSpec: StateSpec `tName` `St`)

macro statechart*(
    T: typedesc,
    St: typedesc[enum],
    Ev: typedesc[enum],
    Evd: typedesc,
    name: string,
    children: untyped): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[`T`, `St`, `Ev`, `Evd`](
      name: Opt.some ChartName `name`,
      dataModel: ModelName `tName` `T`,
      children: @`children`,
      eventModel: ModelName `tName` `Evd`,
      eventSpec: EventSpec `tName` `Ev`,
      stateSpec: StateSpec `tName` `St`)

macro statechart*[S: enum](
    T: typedesc,
    St: typedesc[enum],
    Ev: typedesc[enum],
    Evd: typedesc,
    name: string,
    initial: S,
    children: untyped): auto =

  debugEcho ""
  debugEcho treeRepr children

  if children[0].len > 0:
    for node in children[0]:

      debugEcho ""
      debugEcho node.kind
      debugEcho treeRepr node

      if node.kind == nnkCall:
        # add check if it's a `state` Call
        if node[0] == ident "state":
          if node.len == 2:
            let node1 = node[1]
            node[1] = ident $St
            node.add ident $Ev
            node.add ident $Evd
            node.add node1
        elif node[0] == ident "parallel":
          if node.len == 2:
            let node1 = node[1]
            node[1] = ident $St
            node.add ident $Ev
            node.add ident $Evd
            node.add node1

        debugEcho ""
        debugEcho treeRepr node

  debugEcho ""

  let tName = bindSym"name"
  result = quote do:
    Statechart[`T`, `St`, `Ev`, `Evd`](
      initial: Opt.some `initial`,
      name: Opt.some ChartName `name`,
      dataModel: ModelName `tName` `T`,
      children: @`children`,
      eventModel: ModelName `tName` `Evd`,
      eventSpec: EventSpec `tName` `Ev`,
      stateSpec: StateSpec `tName` `St`)
