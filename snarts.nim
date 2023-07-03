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
            ("""field '$#' of type '$#' is type '$#' but is required """ &
             """to be type '$#'""") %
            [`fieldName`, name(`T1`), name(`T1`.`field`), name(`T2`)])
      else:
        raise (ref AssertionDefect)(msg:
          """type '$#' does not have required field '$#'""" %
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

func statechart0*[St: enum; Ev: enum; Dm: object; Em: object]():
      auto =
  initStatechart[St, Ev, Dm, Em]()

func statechart1*[St: enum; Ev: enum; Dm: object; Em: object](
    name: string):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scName = (if name == "": Opt.none string else: Opt.some name))

func statechart1*[St: enum; Ev: enum; Dm: object; Em: object](
    initial: St):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial)

func statechart1*[St: enum; Ev: enum; Dm: object; Em: object](
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scChildren = children)

func statechart2*[St: enum; Ev: enum; Dm: object; Em: object](
    name: string,
    initial: St):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scName = (if name == "": Opt.none string else: Opt.some name))

func statechart2*[St: enum; Ev: enum; Dm: object; Em: object](
  name: string,
  children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scName = (if name == "": Opt.none string else: Opt.some name),
    scChildren = children)

func statechart2*[St: enum; Ev: enum; Dm: object; Em: object](
  initial: St,
  children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scChildren = children)

func statechart3*[St: enum; Ev: enum; Dm: object; Em: object](
  name: string,
  initial: St,
  children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initStatechart[St, Ev, Dm, Em](
    scInitial = Opt.some initial,
    scName = (if name == "": Opt.none string else: Opt.some name),
    scChildren = children)

func state0*[St: enum; Ev: enum; Dm: object; Em: object](): auto =
  initState[St, Ev, Dm, Em]()

# don't need `anon[N]` funcs, but do want a `macro anon` with `compiles(...)`
# branches that attempt `id =` and/or `initial =`
# actually... `anon[N]` funcs probably are needed, to work in concert with
# `macro anon`, i.e. to avoid the user having to think about when e.g. `initial
# = s1` vs. `s1` is appropriate
func anon0*[St: enum; Ev: enum; Dm: object; Em: object](): auto =
  initState[St, Ev, Dm, Em]()

func state1*[St: enum; Ev: enum; Dm: object; Em: object](
    id: St):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id)

func anon1*[St: enum; Ev: enum; Dm: object; Em: object](
    initial: St):
      auto =
 initState[St, Ev, Dm, Em](
   sInitial = Opt.some initial)

func state1*[St: enum; Ev: enum; Dm: object; Em: object](
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sChildren = children)

func state2*[St: enum; Ev: enum; Dm: object; Em: object](
    id: St,
    initial: St):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sInitial = Opt.some initial)

func state2*[St: enum; Ev: enum; Dm: object; Em: object](
    id: St,
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sChildren = children)

func anon2*[St: enum; Ev: enum; Dm: object; Em: object](
  initial: St,
  children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sInitial = Opt.some initial,
    sChildren = children)

func state3*[St: enum; Ev: enum; Dm: object; Em: object](
    id: St,
    initial: St,
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sInitial = Opt.some initial,
    sChildren = children)

macro fixup*(
    St, Ev, Dm, Em: typedesc,
    children: varargs[untyped]):
      untyped =
  when defined(debugMacros):
    debugEcho ""
    debugEcho St
    debugEcho Ev
    debugEcho Dm
    debugEcho Em
    debugEcho ""
    debugEcho treeRepr children
  var
    bracket: NimNode
    children = children
  if (children.len > 0) and
     (children.kind == nnkArgList):
    if children[0].kind == nnkBracket:
      bracket = children[0]
    elif (children[0].kind == nnkPrefix) and
         (children[0].len > 0) and
         (children[0][0] == ident "@") and
         (children[0].len > 1) and
         (children[0][1].kind == nnkBracket):
      bracket = children[0][1]
    elif (children[0].kind == nnkExprEqExpr) and
         (children[0].len > 0) and
         (children[0][0] == ident "children") and
         (children[0].len > 1) and
         (children[0][1].kind == nnkBracket):
      bracket = newNimNode(kind = nnkBracket)
      for i, node in children[0][1]:
        bracket.insert(i, node)
        children = newNimNode(kind = nnkArgList)
        children.insert(0, bracket)
    else:
      bracket = newNimNode(kind = nnkBracket)
      for i, node in children:
        bracket.insert(i, node)
      children = newNimNode(kind = nnkArgList)
      children.insert(0, bracket)

  for i, node in bracket:
    if (node.kind == nnkCall) and
       (node.len > 0) and
       (node[0].kind == nnkIdent) and
       # here should be instead variations of "state[N], etc."
       # for bare "anon", "state", et al. (i.e. macro invocations) will want a
       # branch that is supplying typedescs as first four arguments instead of
       # a bracket expression to instantiate a generic call
       # ($node[0] in ["anon", "state"]):
       ($node[0] in ["state0"]): # add other "state[N]", "parallel[N]", et al.
      let fixedup = node.copy
      fixedup[0] = newNimNode(kind = nnkBracketExpr)
      fixedup[0].insert(0, node[0])
      fixedup[0].insert(1, ident $St)
      fixedup[0].insert(2, ident $Ev)
      fixedup[0].insert(3, ident $Dm)
      fixedup[0].insert(4, ident $Em)
      bracket[i] = quote do:
        when compiles(`fixedup`):
          `fixedup`
        else:
          `node`
  result = quote do:
    `children`
  when defined(debugMacros):
    debugEcho ""
    debugEcho treeRepr children
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

# overloading an `untyped` parameter is presently unworkable, necessitating the
# approach below re: macros `statechart`, `state`, et al. (and incurring longer
# and more memory hungry compile times for the sake of expressivity)

macro statechart*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let argsLen = args.len
  when defined(debugMacros):
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      statechart0[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg = args[0]
      sc1a = quote do:
        statechart1[`St`, `Ev`, `Dm`, `Em`](
          `arg`)
      sc1b = quote do:
        statechart1[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`, `arg`))
    result = quote do:
      when compiles(`sc1a`):
        `sc1a`
      else:
        `sc1b`
  elif argsLen == 2:
    let
      arg1 = args[0]
      arg2 = args[1]
      sc2a = quote do:
        statechart2[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          `arg2`)
      sc2b = quote do:
        statechart2[`St`, `Ev`, `Dm`, `Em`](
          `arg2`,
          `arg1`)
      sc2c = quote do:
        statechart2[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          fixup(`St`, `Ev`, `Dm`, `Em`, `arg2`))
      sc2d = quote do:
        statechart2[`St`, `Ev`, `Dm`, `Em`](
          `arg2`,
          fixup(`St`, `Ev`, `Dm`, `Em`, `arg1`))
      sc2e = quote do:
        statechart1[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`, `arg1`, `arg2`))
    result = quote do:
      when compiles(`sc2a`):
        `sc2a`
      elif compiles(`sc2b`):
        `sc2b`
      elif compiles(`sc2c`):
        `sc2c`
      elif compiles(`sc2d`):
        `sc2d`
      else:
        `sc2e`
  elif argsLen == 3:
    # impl me
    # note: it will involve some fallbacks to statechart2() and statechart1()
    result = quote do:
      true
  # the following branch seems like it could be quite complex re: groupings,
  # i.e. 3rd position varargs and `children =` ... but maybe not so bad,
  # i.e. in the former the varargs can be "frozen" in 3rd position, while the
  # latter can be in 1st, 2nd, or 3rd position
  elif argsLen > 3:
    # impl me
    result = quote do:
      true
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""



# -----------------------------------------------------------------------------
# will need variations of transition macros/templates that allow for cond
# and/or exe to be untyped or concrete Cond/Exe

# earlier work re: snkTransition nodes was removed in the following commit, but
# that code can be a reference for how I was successfully building cond/exe
# procs:
# https://github.com/michaelsbradleyjr/snarts/commit/67800f924166391f9b64291f133b0dd662c117c2
