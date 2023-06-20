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
