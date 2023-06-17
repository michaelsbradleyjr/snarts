{.push raises: [].}

import std/[macros, typetraits]
# import ./snarts/algos
import ./snarts/types

# export algos
export types

template fixup(St, Ev, M, Evm, node: untyped) =

  # fixup should only attempt to modify calls that are calls to the macros
  # defined in this module

  var brack: NimNode
  if node.len > 0:
    if node.kind == nnkBracket:
      brack = node
    elif node.kind == nnkStmtList and node[0].kind == nnkBracket:
      brack = node[0]
    elif node.kind == nnkStmtList and
         node[0].kind == nnkPrefix and
         node[0][0] == ident("@") and
         node[0][1].kind == nnkBracket:
      brack = node[0][1]
    elif node.kind == nnkPrefix and
         node[0] == ident("@") and
         node[1].kind == nnkBracket:
      brack = node[1]
  for n in brack:
    if n.kind == nnkCall:
      n.insert(1, ident $St)
      n.insert(2, ident $Ev)
      n.insert(3, ident $M)
      n.insert(4, ident $Evm)

macro statechart*[S: enum](
    St: typedesc,
    Ev: typedesc,
    M: typedesc,
    Evm: typedesc,
    name: string,
    initial: S,
    children: untyped): auto =

  # need to assert that typeof(S) is St
  # need to assert that typeof(M.id) is St
  # need to assert that typeof(Evm.name) is Ev

  debugEcho ""
  debugEcho treeRepr children

  fixup(St, Ev, M, Evm, children)
  let tName = bindSym"name"
  result = quote do:
    Statechart[`St`, `Ev`, `M`, `Evm`](
      initial: Opt.some `initial`,
      name: (if `name` == "": Opt.none SpecName else: Opt.some SpecName `name`),
      dataModel: SpecName `tName` `M`,
      children: @`children`,
      eventModel: SpecName `tName` `Evm`,
      events: SpecName `tName` `Ev`,
      states: SpecName `tName` `St`)

  # debugEcho ""
  # debugEcho treeRepr result
  debugEcho ""
  debugEcho toStrLit result
  debugEcho ""

# kind and other fields needs to be a match for invocation of `state`,
# `parallel`, et al. (e.g. `state` has `sChildren` while `parallel`) has
# `pChildren`

macro state*[S: enum](
    St: typedesc[S],
    Ev: typedesc,
    M: typedesc,
    Evm: typedesc,
    id: S,
    initial: S,
    children: untyped): auto =

  # need to assert that typeof(S) is St
  # need to assert that typeof(M.id) is St
  # need to assert that typeof(Evm.name) is Ev

  debugEcho ""
  debugEcho treeRepr children

  fixup(St, Ev, M, Evm, children)
  result = quote do:
    StatechartNode[`St`, `Ev`, `M`, `Evm`](
      kind: snkState,
      sId: Opt.some `id`,
      sInitial: Opt.some `initial`,
      sChildren: @`children`)

  # debugEcho ""
  # debugEcho treeRepr result
  debugEcho ""
  debugEcho toStrLit result
  debugEcho ""

# macro atomic*()

# macro parallel*()

# almost there, but transition has several fields to consider
# -----------------------------------------------------------
# macro transition*(
#     St: typedesc,
#     Ev: typedesc,
#     M: typedesc,
#     Evm: typedesc,
#     exe: untyped): auto =
#   # debugEcho ""
#   # debugEcho treeRepr exe
#   let
#     data = ident "data"
#     event = ident "event"
#     config = ident "config"
#   result = quote do:
#     StatechartNode[`St`, `Ev`, `M`, `Evm`](
#       kind: snkTransition,
#       exe: proc(`data`: `M`, `event`: `Evm`, `config`: Configuration[`St`])
#              {.nimcall, noSideEffect.} = `exe`)
#   # debugEcho ""
#   # debugEcho treeRepr result
#   # debugEcho toStrLit result
#   # debugEcho ""
