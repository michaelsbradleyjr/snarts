{.push raises: [].}

import std/[macros, strutils, typetraits]
import ./snarts/algos

export algos

macro enforce(T1, T2: typedesc; fieldName: static string): untyped =
  let field = ident fieldName
  result = quote do:
    static:
      when compiles(`T1`.`field`):
        if typeof(`T1`.`field`) isnot `T2`:
          raise (ref AssertionDefect)(msg:
            "field \"$#\" of type $# is type $# but is required to be type $#" %
            [`fieldName`, name(`T1`), name(`T1`.`field`), name(`T2`)])
      else:
        raise (ref AssertionDefect)(msg:
          "type $# does not have required field \"$#\"" %
          [name(`T1`), `fieldName`])

func initStatechart*[St: enum; Ev: enum; Dm: object; Em: object](
    scInitial: Opt[St] = Opt.none St,
    scName: Opt[string] = Opt.none string,
    scChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      Statechart[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  Statechart[St, Ev, Dm, Em](
    scInitial: scInitial,
    scName: scName,
    scChildren: @scChildren)

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

func initParallel*[St: enum; Ev: enum; Dm: object; Em: object](
    pId: Opt[St] = Opt.none St,
    pChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkParallel,
    pId: pId,
    pChildren: @pChildren)

func initTransition*[St: enum; Ev: enum; Dm: object; Em: object](
    tEvent: Opt[Ev] = Opt.none Ev,
    tCond: Opt[Cond] = Opt.none Cond,
    tTarget: Opt[St] = Opt.none St,
    tKind: TransitionKind = tkExternal,
    tExe: Opt[Exe] = Opt.none Exe):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkTransition,
    tEvent: tEvent,
    tCond: tCond,
    tTarget: tTarget,
    tKind: tKind,
    tExe: tExe)

func initInitial*[St: enum; Ev: enum; Dm: object; Em: object](
    iChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkInitial,
    iChildren: @iChildren)

func initFinal*[St: enum; Ev: enum; Dm: object; Em: object](
    fId: Opt[St] = Opt.none St,
    fChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkFinal,
    fId: fId,
    fChildren: @fChildren)

func initOnEntry*[St: enum; Ev: enum; Dm: object; Em: object](
    oExe: Exe()):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkOnEntry,
    oExe: oExe)

func initOnExit*[St: enum; Ev: enum; Dm: object; Em: object](
    oExe: Exe()):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkOnExit,
    oExe: oExe)

func initHistory*[St: enum; Ev: enum; Dm: object; Em: object](
    hId: Opt[St] = Opt.none St,
    hKind: HistoryKind = hkShallow,
    hChildren: openArray[StatechartNode[St, Ev, Dm, Em]] = []):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkHistory,
    hId: hId,
    hKind: hKind,
    hChildren: @hChildren)

func fixup(St, Ev, Dm, Em, children: NimNode): NimNode =
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
    elif children.kind == nnkPrefix and
         children[0] == ident("@") and
         children.len > 1 and
         children[1].kind == nnkBracket:
      bracket = children[1]
    elif children.kind == nnkStmtList and
         children[0].kind == nnkPrefix and
         children[0].len > 0 and
         children[0][0] == ident("@") and
         children[0].len > 1 and
         children[0][1].kind == nnkBracket:
      bracket = children[0][1]
  for i, node in bracket:
    # bare `anon`, `state`, et al. can lead to surprises, not supported for now
    # -------------------------------------------------------------------------
    # if (node.kind == nnkIdent) and
    #    ($node in ["anon", "state", ...]):
    #   let fixedup = newCall(
    #     node,
    #     ident $St, ident $Ev, ident $Dm, ident $Em)
    #   bracket[i] = quote do:
    #     when compiles(`fixedup`):
    #       `fixedup`
    #     else:
    #       `node`
    if (node.kind == nnkCall) and
         (node.len > 0) and
         # expand to include "parallel", et al.
         ($node[0] in ["anon", "state"]) and
         (node.len < 5):
      let fixedup = node.copy
      fixedup.insert(1, ident $St)
      fixedup.insert(2, ident $Ev)
      fixedup.insert(3, ident $Dm)
      fixedup.insert(4, ident $Em)
      bracket[i] = quote do:
        when compiles(`fixedup`):
          `fixedup`
        else:
          `node`
  when defined(debugMacros):
    debugEcho ""
    debugEcho treeRepr children
  result = quote do:
    `children`
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro statechart0(
    St, Ev, Dm, Em: typedesc):
      untyped =
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`]()

template statechart*(
    St, Ev, Dm, Em: typedesc):
      untyped =
  statechart0(St, Ev, Dm, Em)

macro statechart1a(
    St, Ev, Dm, Em: typedesc,
    name: string):
      untyped =
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`](
      scName = (if `name` == "": Opt.none string else: Opt.some `name`))

template statechart*(
    St, Ev, Dm, Em: typedesc,
    name: string):
      untyped =
  statechart1a(St, Ev, Dm, Em, name)

macro statechart1b[S](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    initial: S):
      untyped =
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`](
      scInitial = Opt.some `initial`)

template statechart*[S](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    initial: S):
      untyped =
  statechart1b(St, Ev, Dm, Em, initial)

macro statechart1c(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      untyped =
  let scChildren = fixup(St, Ev, Dm, Em, children)
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`](
      scChildren = `scChildren`)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      untyped =
  statechart1c(St, Ev, Dm, Em, children)

macro statechart2a(
    St, Ev, Dm, Em: typedesc,
    name: string,
    children: untyped):
      untyped =
  let scChildren = fixup(St, Ev, Dm, Em, children)
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`](
      scName = (if `name` == "": Opt.none string else: Opt.some `name`),
      scChildren = `scChildren`)

template statechart*(
    St, Ev, Dm, Em: typedesc,
    name: string,
    children: untyped):
      untyped =
  statechart2a(St, Ev, Dm, Em, name, children)

macro statechart2b[S](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    initial: S,
    children: untyped):
      untyped =
  let scChildren = fixup(St, Ev, Dm, Em, children)
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`](
      scInitial = Opt.some `initial`,
      scChildren = `scChildren`)

template statechart*[S](
  St: typedesc[S]; Ev, Dm, Em: typedesc,
  initial: S,
  children: untyped):
    untyped =
  statechart2b(St, Ev, Dm, Em, initial, children)

macro statechart3[S](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    name: string,
    initial: S,
    children: untyped):
      untyped =
  let scChildren = fixup(St, Ev, Dm, Em, children)
  result = quote do:
    initStatechart[`St`, `Ev`, `Dm`, `Em`](
      scInitial = Opt.some `initial`,
      scName = (if `name` == "": Opt.none string else: Opt.some `name`),
      scChildren = `scChildren`)

template statechart*[S](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    name: string,
    initial: S,
    children: untyped):
      untyped =
  statechart3(St, Ev, Dm, Em, name, initial, children)

template anon*(): untyped = 0

template state*(): untyped = 0

macro state0(
    St, Ev, Dm, Em: typedesc):
      untyped =
  result = quote do:
    initState[`St`, `Ev`, `Dm`, `Em`]()

template anon*(
    St, Ev, Dm, Em: typedesc):
      untyped =
  state0(St, Ev, Dm, Em)

template state*(
    St, Ev, Dm, Em: typedesc):
      untyped =
  state0(St, Ev, Dm, Em)

template anon*(x: untyped): untyped = 0

template state*(x: untyped): untyped = 0

macro state1a[S: enum](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    id: S):
      untyped =
  result = quote do:
    initState[`St`, `Ev`, `Dm`, `Em`](
      sId = Opt.some `id`)

template state*[S: enum](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    id: S):
      untyped =
  state1a(St, Ev, Dm, Em, id)

macro state1b[S: enum](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    initial: S):
      untyped =
  result = quote do:
    initState[`St`, `Ev`, `Dm`, `Em`](
      sInitial = Opt.some `initial`)

template anon*[S: enum](
    St: typedesc[S]; Ev, Dm, Em: typedesc,
    initial: S):
      untyped =
  state1b(St, Ev, Dm, Em, initial)

macro state1c(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      untyped =
  let sChildren = fixup(St, Ev, Dm, Em, children)
  result = quote do:
    initState[`St`, `Ev`, `Dm`, `Em`](
      sChildren = `sChildren`)

template anon*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      untyped =
  state1c(St, Ev, Dm, Em, children)

template state*(
    St, Ev, Dm, Em: typedesc,
    children: untyped):
      untyped =
  state1c(St, Ev, Dm, Em, children)

# ^ working
# ------------------------------------------------------------------------------

# work through
# ------------------------------------------------------------------------------

# macro state2a[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     id: S,
#     initial: S):
#       untyped =
#   result = quote do:
#     initState[`St`, `Ev`, `Dm`, `Em`](
#       sId = Opt.some `id`,
#       sInitial = Opt.some `initial`)

# template state*[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     id: S,
#     initial: S):
#       untyped =
#   state2a(St, Ev, Dm, Em, id, initial)

# macro state2b[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     id: S,
#     children: untyped):
#       untyped =
#   let sChildren = fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     initState[`St`, `Ev`, `Dm`, `Em`](
#       sId = Opt.some `id`,
#       sChildren = `sChildren`)

# template state*[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     id: S,
#     children: untyped):
#       untyped =
#   state2b(St, Ev, Dm, Em, id, children)

# macro state2c[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     initial: S,
#     children: untyped):
#       untyped =
#   let sChildren = fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     initState[`St`, `Ev`, `Dm`, `Em`](
#       sInitial = Opt.some `initial`,
#       sChildren = `sChildren`)

# template anon*[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     initial: S,
#     children: untyped):
#       untyped =
#   state2c(St, Ev, Dm, Em, initial, children)

# macro state3[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     id: S,
#     initial: S,
#     children: untyped):
#       untyped =
#   let sChildren = fixup(St, Ev, Dm, Em, children)
#   result = quote do:
#     initState[`St`, `Ev`, `Dm`, `Em`](
#       sId = Opt.some `id`,
#       sInitial = Opt.some `initial`,
#       sChildren = `sChildren`)

# template state*[S: enum](
#     St: typedesc[S]; Ev, Dm, Em: typedesc,
#     id: S,
#     initial: S,
#     children: untyped):
#       untyped =
#   state3(St, Ev, Dm, Em, id, initial, children)

# -----------------------------------------------------------------------------

# need variations of transition macros/templates that allow for cond and/or exe
# to be untyped or concrete Cond/Exe

# macro transition2[S: enum; E: enum](
#     St: typedesc[S]; Ev: typedesc[E]; Dm, Em: typedesc,
#     event: E,
#     target: S):
#       untyped =
#   result = quote do:
#     initTransition[`St`, `Ev`, `Dm`, `Em`](
#       tEvent = Opt.some `event`,
#       tTarget = Opt.some `target`)

# template transition*[S: enum; E: enum](
#     St: typedesc[S]; Ev: typedesc[E]; Dm, Em: typedesc,
#     event: E,
#     target: S):
#       untyped =
#   transition2(St, Ev, Dm, Em, event, target)
