{.push raises: [].}

import std/macros
from std/typetraits import nil
# import ./snarts/algos
import ./snarts/types

# export algos, types
export types

macro convention(T1, T2: untyped, field: static string): untyped =
  let
    field = ident field
    fieldName = $field
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

func init*[St: enum, Ev: enum, Dm, Em](
    T: typedesc[Statechart[St, Ev, Dm, Em]],
    initial: Opt[St] = Opt.none St,
    name: Opt[string] = Opt.none string,
    children: openArray[StatechartNode[St, Ev, Dm, Em]] = []): T =
  convention(Dm, St, "id")
  convention(Em, Ev, "name")
  T(initial: initial,
    name: name,
    children: @children)

# works
# -----
# macro statechart*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     minitial: S,
#     mname: string,
#     mchildren: untyped):
#     auto =
#   result = quote do:
#     init[`St`, `Ev`, `Dm`, `Em`](Statechart,
#       initial = Opt.some `minitial`,
#       name = (if `mname` == "": Opt.none string else: Opt.some `mname`),
#       children = `mchildren`)
#
#   debugEcho toStrLit result

# works
# -----
# template statechart*[S: enum](
#     St: typedesc[S], Ev, Dm, Em: typedesc,
#     tinitial: S,
#     tname: string,
#     tchildren: untyped):
#     auto =
#   Statechart[St, Ev, Dm, Em].init(
#     initial = Opt.some tinitial,
#     name = (if tname == "": Opt.none string else: Opt.some tname),
#     children = tchildren)

# works
# -----
# template statechart*(
#     St, Ev, Dm, Em: typedesc,
#     tinitial: St,
#     tname: string,
#     tchildren: untyped):
#     auto =
#   Statechart[St, Ev, Dm, Em].init(
#     initial = Opt.some tinitial,
#     name = (if tname == "": Opt.none string else: Opt.some tname),
#     children = tchildren)

# works
# -----
# template statechart*[St, Ev, Dm, Em](
#     tinitial: St,
#     tname: string,
#     tchildren: untyped):
#     auto =
#   Statechart[St, Ev, Dm, Em].init(
#     initial = Opt.some tinitial,
#     name = (if tname == "": Opt.none string else: Opt.some tname),
#     children = tchildren)

# ? which one will work with fixup

macro fixup(St, Ev, Dm, Em, children: untyped) =
  debugEcho ""
  debugEcho treeRepr St
  debugEcho treeRepr Ev
  debugEcho treeRepr Dm
  debugEcho treeRepr Em
  debugEcho ""
  debugEcho treeRepr children
  debugEcho ""

template statechart*(
    St, Ev, Dm, Em: typedesc,
    tchildren: untyped):
    auto =
  fixup(St, Ev, Dm, Em, tchildren)
  Statechart[St, Ev, Dm, Em].init(
    children = tchildren)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    tinitial: St,
    tchildren: untyped):
    auto =
  fixup(St, Ev, Dm, Em, tchildren)
  Statechart[St, Ev, Dm, Em].init(
    initial = Opt.some tinitial,
    children = tchildren)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    tname: string,
    tchildren: untyped):
    auto =
  fixup(St, Ev, Dm, Em, tchildren)
  Statechart[St, Ev, Dm, Em].init(
    name = (if tname == "": Opt.none string else: Opt.some tname),
    children = tchildren)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    tinitial: St,
    tname: string,
    tchildren: untyped):
    auto =
  fixup(St, Ev, Dm, Em, tchildren)
  Statechart[St, Ev, Dm, Em].init(
    initial = Opt.some tinitial,
    name = (if tname == "": Opt.none string else: Opt.some tname),
    children = tchildren)


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
