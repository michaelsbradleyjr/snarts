{.push raises: [].}

import std/macros
from std/typetraits import nil
# import ./snarts/algos
import ./snarts/types

# export algos, types
export types

macro enforce(T1, T2: untyped; fieldName: static string): untyped =
  let field = ident fieldName
  result = quote do:
    static:
      when compiles(`T1`.`field`):
        if typeof(`T1`.`field`) isnot `T2`:
          raise (ref AssertionDefect)(msg:
            "field \"" & `fieldName` & "\" of type " & typetraits.name(`T1`) &
            " is type " & typetraits.name(`T1`.`field`) &
            " but is required to be type " & typetraits.name(`T2`))
      else:
        raise (ref AssertionDefect)(msg:
          "type " & typetraits.name(`T1`) & " does not have required field \"" &
          `fieldName` & "\"")

func initStatechart*[St: enum; Ev: enum; Dm: object; Em: object](
    scInitial: Opt[St] = Opt.none St,
    scName: Opt[string] = Opt.none string,
    scChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      Statechart[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  Statechart[St, Ev, Dm, Em](
    initial: scInitial,
    name: scName,
    children: @scChildren)

func initState*[St: enum; Ev: enum; Dm: object; Em: object](
    sId: Opt[St] = Opt.none St,
    sInitial: Opt[St] = Opt.none St,
    sChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkState,
    sId: sId,
    sInitial: sInitial,
    sChildren: @sChildren)

macro fixup(St, Ev, Dm, Em, children: untyped): auto =
  # if possible, fixup should only attempt to modify calls that are calls to
  # the macros defined in this module

  # would be nice if could recognize "bare call" to e.g. `final`, but would
  # need a macro overload of that name that takes zero arguments, and the call
  # itself would need to be swapped for the non-bare one with `St`, et
  # al. filled in

  when defined(debugMacros):
    debugEcho ""
    debugEcho treeRepr St
    debugEcho treeRepr Ev
    debugEcho treeRepr Dm
    debugEcho treeRepr Em
    debugEcho ""
    debugEcho treeRepr children
  var bracket: NimNode
  if children.len > 0:
    if children.kind == nnkBracket:
      bracket = children
    elif children.kind == nnkStmtList and
         children[0].kind == nnkBracket:
      bracket = children[0]
    elif children.kind == nnkStmtList and
         children[0].kind == nnkPrefix and
         children[0][0] == ident("@") and
         children[0][1].kind == nnkBracket:
      bracket = children[0][1]
    elif children.kind == nnkPrefix and
         children[0] == ident("@") and
         children[1].kind == nnkBracket:
      bracket = children[1]
  for n in bracket:
    if n.kind == nnkCall and n.len < 5:
      n.insert(1, ident $St)
      n.insert(2, ident $Ev)
      n.insert(3, ident $Dm)
      n.insert(4, ident $Em)
  when defined(debugMacros):
    debugEcho ""
    debugEcho treeRepr children
  result = quote do:
    `children`
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

template statechart*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scChildren = fixup(St, Ev, Dm, Em, children))

template statechart*(
    St, Ev, Dm, Em: typedesc,
    name: string,
    children: untyped):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scName = (if name == "": Opt.none string else: Opt.some name),
    scChildren = fixup(St, Ev, Dm, Em, children))

template statechart*(
    St, Ev, Dm, Em: typedesc,
    initial: St,
    children: untyped):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scChildren = fixup(St, Ev, Dm, Em, children))

template statechart*(
    St, Ev, Dm, Em: typedesc,
    name: string,
    initial: St,
    children: untyped):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scName = (if name == "": Opt.none string else: Opt.some name),
    scChildren = fixup(St, Ev, Dm, Em, children))

template anon*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      auto =
  initState[St, Ev, Dm, Em](
    sChildren = fixup(St, Ev, Dm, Em, children))

template anon*(
    St, Ev, Dm, Em: typedesc,
    initial: St,
    children: untyped):
      auto =
  initState[St, Ev, Dm, Em](
    sInitial = Opt.some initial,
    sChildren = fixup(St, Ev, Dm, Em, children))

template state*(
    St, Ev, Dm, Em: typedesc,
    id: St,
    children: untyped):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sChildren = fixup(St, Ev, Dm, Em, children))

template state*(
    St, Ev, Dm, Em: typedesc,
    id: St,
    initial: St,
    children: untyped):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sInitial = Opt.some initial,
    sChildren = fixup(St, Ev, Dm, Em, children))
