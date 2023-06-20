{.push raises: [].}

import std/macros
from std/typetraits import nil
# import ./snarts/algos
import ./snarts/types

# export algos, types
export types

macro convention(T1, T2: untyped, fieldName: static string): untyped =
  let
    field = ident fieldName
  result = quote do:
    static:
      when compiles(`T1`.`field`):
        if typeof(`T1`.`field`) isnot `T2`:
          raise (ref ValidationDefect)(msg:
            "field \"" & `fieldName` & "\" of type " & typetraits.name(`T1`) &
            " is type " & typetraits.name(`T1`.`field`) &
            " but is required to be type " & typetraits.name(`T2`))
      else:
        raise (ref ValidationDefect)(msg:
          "type " & typetraits.name(`T1`) & " does not have required field \"" &
          `fieldName` & "\"")

func initStatechart[St: enum, Ev: enum, Dm, Em](
    scInitial: Opt[St] = Opt.none St,
    scName: Opt[string] = Opt.none string,
    scChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      Statechart[St, Ev, Dm, Em] =
  convention(Dm, St, "id")
  convention(Em, Ev, "name")
  Statechart[St, Ev, Dm, Em](
    initial: scInitial,
    name: scName,
    children: @scChildren)

func initState[St: enum, Ev: enum, Dm, Em](
    sId: Opt[St] = Opt.none St,
    sInitial: Opt[St] = Opt.none St,
    sChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      StatechartNode[St, Ev, Dm, Em] =
  convention(Dm, St, "id")
  convention(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkState,
    sId: sId,
    sInitial: sInitial,
    sChildren: @sChildren)

macro fixup(St, Ev, Dm, Em, children: untyped) =
  debugEcho ""
  debugEcho treeRepr St
  debugEcho treeRepr Ev
  debugEcho treeRepr Dm
  debugEcho treeRepr Em
  debugEcho ""
  debugEcho treeRepr children
  debugEcho ""

# macro fixup(St, Ev, Dm, Em, children: untyped) =
#   # if possible, fixup should only attempt to modify calls that are calls to
#   # the macros defined in this module
#
#   # would be nice if could recognize "bare call" to e.g. `atomic` or `final`,
#   # but would need a macro overload of that name that takes zero arguments, and
#   # the call itself would need to be swapped for the non-bare one with `St`, et
#   # al. filled in
#
#   debugEcho ""
#   debugEcho "FIXUP FIXUP FIXUP"
#   debugEcho ""
#   debugEcho treeRepr children
#   debugEcho ""
#
#   var bracket: NimNode
#   if children.len > 0:
#     if children.kind == nnkBracket:
#       bracket = children
#     elif children.kind == nnkStmtList and
#          children[0].kind == nnkBracket:
#       bracket = children[0]
#     elif children.kind == nnkStmtList and
#          children[0].kind == nnkPrefix and
#          children[0][0] == ident("@") and
#          children[0][1].kind == nnkBracket:
#       bracket = children[0][1]
#     elif children.kind == nnkPrefix and
#          children[0] == ident("@") and
#          children[1].kind == nnkBracket:
#       bracket = children[1]
#   if bracket.len < 5:
#     for n in bracket:
#       if n.kind == nnkCall:
#         n.insert(1, ident $St)
#         n.insert(2, ident $Ev)
#         n.insert(3, ident $Dm)
#         n.insert(4, ident $Em)
#
#   debugEcho "FIXED FIXED FIXED"
#   debugEcho ""
#   debugEcho treeRepr children
#   debugEcho ""

template statechart*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initStatechart[St, Ev, Dm, Em](
    scChildren = children)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    initial: St,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scChildren = children)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    name: string,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initStatechart[St, Ev, Dm, Em](
    scName = (if name == "": Opt.none string else: Opt.some name),
    scChildren = children)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    initial: St,
    name: string,
    children: untyped):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scName = (if name == "": Opt.none string else: Opt.some name),
    scChildren = children)

template atomic*(
    St, Ev, Dm, Em: typedesc):
      auto =
  initState[St, Ev, Dm, Em]()

template atomic*(
    St, Ev, Dm, Em: typedesc,
    id: St):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id)

template anon*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initState[St, Ev, Dm, Em](
    sChildren = children)

template anon*(
    St, Ev, Dm, Em: typedesc,
    initial: St,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initState[St, Ev, Dm, Em](
    sInitial = Opt.some initial,
    sChildren = children)

template state*(
    St, Ev, Dm, Em: typedesc,
    id: St,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sChildren = children)

template state*(
    St, Ev, Dm, Em: typedesc,
    id: St,
    initial: St,
    children: untyped):
      auto =
  fixup(St, Ev, Dm, Em, children)
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sInitial = Opt.some initial,
    sChildren = children)

# old stuff
# ------------------------------------------------------------------------------

# template fixup(St, Ev, Dm, Em, node: untyped) =
#   # if possible, fixup should only attempt to modify calls that are calls to
#   # the macros defined in this module

#   # would be nice if could recognize "bare call" to e.g. `atomic` or `final`,
#   # but would need a macro overload of that name that takes zero arguments, and
#   # the call itself would need to be swapped for the non-bare one with `St`, et
#   # al. filled in
#   var bracket: NimNode
#   if node.len > 0:
#     if node.kind == nnkBracket:
#       bracket = node
#     elif node.kind == nnkStmtList and
#          node[0].kind == nnkBracket:
#       bracket = node[0]
#     elif node.kind == nnkStmtList and
#          node[0].kind == nnkPrefix and
#          node[0][0] == ident("@") and
#          node[0][1].kind == nnkBracket:
#       bracket = node[0][1]
#     elif node.kind == nnkPrefix and
#          node[0] == ident("@") and
#          node[1].kind == nnkBracket:
#       bracket = node[1]
#   for n in bracket:
#     if n.kind == nnkCall:
#       n.insert(1, ident $St)
#       n.insert(2, ident $Ev)
#       n.insert(3, ident $Dm)
#       n.insert(4, ident $Em)

# macro statechart*(
#     St, Ev, Dm, Em: typedesc,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   let typeName = bindSym"name"
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     Statechart[`St`, `Ev`, `Dm`, `Em`](
#       initial: Opt.none `St`,
#       name: Opt.none SpecName,
#       dataModel: SpecName `typeName`(`Dm`),
#       children: @`children`,
#       eventModel: SpecName `typeName`(`Em`),
#       events: SpecName `typeName`(`Ev`),
#       states: SpecName `typeName`(`St`))
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro statechart*(
#     St, Ev, Dm, Em: typedesc,
#     name: string,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   let typeName = bindSym"name"
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     Statechart[`St`, `Ev`, `Dm`, `Em`](
#       initial: Opt.none `St`,
#       name: (if `name` == "": Opt.none SpecName else: Opt.some SpecName `name`),
#       dataModel: SpecName `typeName`(`Dm`),
#       children: @`children`,
#       eventModel: SpecName `typeName`(`Em`),
#       events: SpecName `typeName`(`Ev`),
#       states: SpecName `typeName`(`St`))
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro statechart*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     initial: S,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   let typeName = bindSym"name"
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     Statechart[`St`, `Ev`, `Dm`, `Em`](
#       initial: Opt.some `initial`,
#       name: Opt.none SpecName,
#       dataModel: SpecName `typeName`(`Dm`),
#       children: @`children`,
#       eventModel: SpecName `typeName`(`Em`),
#       events: SpecName `typeName`(`Ev`),
#       states: SpecName `typeName`(`St`))
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro statechart*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     name: string,
#     initial: S,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   let typeName = bindSym"name"
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     Statechart[`St`, `Ev`, `Dm`, `Em`](
#       initial: Opt.some `initial`,
#       name: (if `name` == "": Opt.none SpecName else: Opt.some SpecName `name`),
#       dataModel: SpecName `typeName`(`Dm`),
#       children: @`children`,
#       eventModel: SpecName `typeName`(`Em`),
#       events: SpecName `typeName`(`Ev`),
#       states: SpecName `typeName`(`St`))
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro atomic*(
#     St, Ev, Dm, Em: typedesc): auto =
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkState,
#       sId: Opt.none `St`,
#       sInitial: Opt.none `St`,
#       sChildren: @[])
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro atomic*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     id: S): auto =
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkState,
#       sId: Opt.some `id`,
#       sInitial: Opt.none `St`,
#       sChildren: @[])
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro state*(
#     St, Ev, Dm, Em: typedesc,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkState,
#       sId: Opt.none `St`,
#       sInitial: Opt.none `St`,
#       sChildren: @`children`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro state*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     id: S,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkState,
#       sId: Opt.some `id`,
#       sInitial: Opt.none `St`,
#       sChildren: @`children`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro state*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     initial: S,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkState,
#       sId: Opt.none `St`,
#       sInitial: Opt.some `initial`,
#       sChildren: @`children`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro state*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     id: S,
#     initial: S,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkState,
#       sId: Opt.some `id`,
#       sInitial: Opt.some `initial`,
#       sChildren: @`children`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro parallel*(
#     St, Ev, Dm, Em: untyped,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkParallel,
#       pId: Opt.none `St`,
#       pChildren: @`children`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro parallel*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     id: S,
#     children: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr children
#   fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkParallel,
#       pId: Opt.some `id`,
#       pChildren: @`children`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""

# macro transition*[S: enum, E: enum](
#     St: typedesc[S],
#     Ev: typedesc[E],
#     Dm: typedesc,
#     Em: typedesc,
#     event: E,
#     target: S,
#     kind: TransitionKind,
#     cond: untyped,
#     exe: untyped): auto =
#   debugEcho ""
#   debugEcho treeRepr cond
#   debugEcho ""
#   debugEcho treeRepr exe
#   let
#     data = ident "data"
#     config = ident "config"
#     pCond = genSym(nskProc, "cond")
#     pEvent = ident "event"
#     pExe = genSym(nskProc, "exe")
#   result = quote do:
#     assert typeof(`Dm`.id) is `St`
#     assert typeof(`Em`.name) is `Ev`
#     proc `pCond`(`data`: `Dm`, `pEvent`: `Em`, `config`: Configuration[`St`]):
#         bool {.nimcall, noSideEffect, raises: [].} =
#       `cond`
#     proc `pExe`(`data`: ref `Dm`, `pEvent`: `Em`, `config`: Configuration[`St`])
#         {.nimcall, noSideEffect, raises: [].} =
#       `exe`
#     StatechartNode[`St`, `Ev`, `Dm`, `Em`](
#       kind: snkTransition,
#       tEvent: Opt.some `event`,
#       tCond: Opt.some `pCond`,
#       tTarget: Opt.some `target`,
#       tKind: `kind`,
#       tExe: Opt.some `pExe`)
#   # debugEcho treeRepr result
#   debugEcho toStrLit result
#   debugEcho ""
