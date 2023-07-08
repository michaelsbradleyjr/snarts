{.push raises: [].}

import std/[macros, sets, strutils, typetraits]
import ./snarts/algos

export algos

# overloading an `untyped` parameter is presently unworkable, necessitating the
# approach below re: macros `statechart`, `state`, `parallel`, et al.

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
    oExe: Opt[Exe] = Opt.none Exe):
      StatechartNode[St, Ev, Dm, Em] =
  enforce(Dm, St, "id")
  enforce(Em, Ev, "name")
  StatechartNode[St, Ev, Dm, Em](
    kind: snkOnEntry,
    oExe: oExe)

func initOnExit*[St: enum; Ev: enum; Dm: object; Em: object](
    oExe: Opt[Exe] = Opt.none Exe):
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

func state0*[St: enum; Ev: enum; Dm: object; Em: object]():
      auto =
  initState[St, Ev, Dm, Em]()

func state1*[St: enum; Ev: enum; Dm: object; Em: object](
    id: St):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id)

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

func state3*[St: enum; Ev: enum; Dm: object; Em: object](
    id: St,
    initial: St,
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sId = Opt.some id,
    sInitial = Opt.some initial,
    sChildren = children)

func anon0*[St: enum; Ev: enum; Dm: object; Em: object]():
      auto =
  initState[St, Ev, Dm, Em]()

func anon1*[St: enum; Ev: enum; Dm: object; Em: object](
    initial: St):
      auto =
 initState[St, Ev, Dm, Em](
   sInitial = Opt.some initial)

func anon1*[St: enum; Ev: enum; Dm: object; Em: object](
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sChildren = children)

func anon2*[St: enum; Ev: enum; Dm: object; Em: object](
    initial: St,
    children: openArray[StatechartNode[St, Ev, Dm, Em]]):
      auto =
  initState[St, Ev, Dm, Em](
    sInitial = Opt.some initial,
    sChildren = children)

const
  fixableFuncs = toHashSet([
    "anon0", "anon1", "anon2",
    "state0", "state1", "state2", "state3",
    "parallel0", "parallel1", "parallel2",
    "transition0", "transition1", "transition2", "transition3", "transition4",
      "transition5",
    "initial0", "initial1",
    "final0", "final1", "final2",
    "onEntry0", "onEntry1",
    "onExit0", "onExit1",
    "history0", "history1", "history2", "history3"
  ])

  fixableMacros = toHashSet([
    "anon", "state", "parallel", "transition", "initial", "final", "onEntry",
    "onExit", "history"
  ])

func isFixable(
    arg: NimNode):
      bool =
  when defined(debugMacros):
    debugEcho ""
    debugEcho "isFixable(" & $toStrLit(arg) & ")"
    debugEcho ""
    debugEcho treeRepr arg
  if arg.kind == nnkBracket:
    result = true
  elif (arg.kind == nnkPrefix) and
       (arg.len > 0) and
       (arg[0] == ident "@") and
       (arg.len > 1) and
       (arg[1].kind == nnkBracket):
    result = true
  elif (arg.kind == nnkExprEqExpr) and
       (arg.len > 0) and
       (arg[0] == ident "children"):
    result = true
  elif (arg.kind == nnkCall) and
       (arg.len > 0) and
       (arg[0].kind == nnkIdent) and
       (($arg[0] in fixableFuncs) or
        ($arg[0] in fixableMacros)):
    result = true
  when defined(debugMacros):
    debugEcho ""
    debugEcho result
    debugEcho ""

macro fixup(
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
    debugEcho "fixup(" & $toStrLit(children) & ")"
    debugEcho ""
    debugEcho "children.len: " & $children.len
    debugEcho ""
    debugEcho treeRepr children
  var
    bracket = newNimNode(kind = nnkBracket)
    children = children
  if (children.len > 0) and
     (children.kind == nnkArgList):
    if children[0].kind == nnkBracket:
      for i, node in children[0]:
        bracket.insert(i, node)
    elif (children[0].kind == nnkPrefix) and
         (children[0].len > 0) and
         (children[0][0] == ident "@") and
         (children[0].len > 1) and
         (children[0][1].kind == nnkBracket):
      for i, node in children[0][1]:
        bracket.insert(i, node)
    elif (children[0].kind == nnkExprEqExpr) and
         (children[0].len > 0) and
         (children[0][0] == ident "children") and
         (children[0].len > 1):
      if children[0][1].kind == nnkBracket:
        for i, node in children[0][1]:
          bracket.insert(i, node)
      elif (children[0][1].kind == nnkPrefix) and
           (children[0][1].len > 0) and
           (children[0][1][0] == ident "@") and
           (children[0][1].len > 1) and
           (children[0][1][1].kind == nnkBracket):
        for i, node in children[0][1][1]:
          bracket.insert(i, node)
      else:
        bracket.insert(0, children[0][1])
    else:
      for i, node in children:
        bracket.insert(i, node)
    children = newNimNode(kind = nnkArgList)
    children.insert(0, bracket)

  for i, node in bracket:
    if (node.kind == nnkCall) and
       (node.len > 0) and
       (node[0].kind == nnkIdent):
      var fixedup = node.copy
      if $fixedup[0] in fixableFuncs:
        fixedup[0] = newNimNode(kind = nnkBracketExpr)
        fixedup[0].insert(0, node[0])
        fixedup[0].insert(1, ident $St)
        fixedup[0].insert(2, ident $Ev)
        fixedup[0].insert(3, ident $Dm)
        fixedup[0].insert(4, ident $Em)
      elif $fixedup[0] in fixableMacros:
        if (fixedup.len < 2) or (fixedup[1] != ident $St):
          fixedup.insert(1, ident $St)
        if (fixedup.len < 3) or (fixedup[2] != ident $Ev):
          fixedup.insert(2, ident $Ev)
        if (fixedup.len < 4) or (fixedup[3] != ident $Dm):
          fixedup.insert(3, ident $Dm)
        if (fixedup.len < 5) or (fixedup[4] != ident $Em):
          fixedup.insert(4, ident $Em)
      bracket[i] = fixedup
  result = quote do:
    `children`
  when defined(debugMacros):
    debugEcho ""
    debugEcho treeRepr children
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro form1NoChildren(
    form: static string,
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let
    argsLen = args.len
    form0 = ident(form & "0")
    form1 = ident(form & "1")
  when defined(debugMacros):
    debugEcho ""
    debugEcho form & "(" & $toStrLit(args) & ")"
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      `form0`[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg1 = args[0]
    result = quote do:
      `form1`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`)
  else:
    raise (ref AssertionDefect)(
      msg: "macro '" & form &
           "' accepts at most 1 argument but was invoked with " & $argsLen)
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro form1WithChildren(
    form: static string,
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let
    argsLen = args.len
    form0 = ident(form & "0")
    form1 = ident(form & "1")
  when defined(debugMacros):
    debugEcho ""
    debugEcho form & "(" & $toStrLit(args) & ")"
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      `form0`[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg1 = args[0]
    result = quote do:
      `form1`[`St`, `Ev`, `Dm`, `Em`](
        fixup(`St`, `Ev`, `Dm`, `Em`,
          `arg1`))
  else:
    result = quote do:
      `form1`[`St`, `Ev`, `Dm`, `Em`](
        fixup(`St`, `Ev`, `Dm`, `Em`,
          `args`))
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro form2WithChildren(
    form: static string,
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let
    argsLen = args.len
    form0 = ident(form & "0")
    form1 = ident(form & "1")
    form2 = ident(form & "2")
  when defined(debugMacros):
    debugEcho ""
    debugEcho form & "(" & $toStrLit(args) & ")"
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      `form0`[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg1 = args[0]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg1`))
    else:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`)
  elif argsLen == 2:
    let
      arg1 = args[0]
      arg2 = args[1]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg1`,
            `arg2`))
    else:
      result = quote do:
        `form2`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg2`))
  else:
    let
      arg1 = args[0]
      arg2 = args[1..<(args.len)]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `args`))
    else:
      result = quote do:
        `form2`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg2`))
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro form3WithChildren(
    form: static string,
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let
    argsLen = args.len
    form0 = ident(form & "0")
    form1 = ident(form & "1")
    form2 = ident(form & "2")
    form3 = ident(form & "3")
  when defined(debugMacros):
    debugEcho ""
    debugEcho form & "(" & $toStrLit(args) & ")"
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      `form0`[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg1 = args[0]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg1`))
    else:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`)
  elif argsLen == 2:
    let
      arg1 = args[0]
      arg2 = args[1]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg1`,
            `arg2`))
    elif arg2.isFixable:
      result = quote do:
        `form2`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg2`))
    else:
      result = quote do:
        `form2`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          `arg2`)
  elif argsLen == 3:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg1`,
            `arg2`,
            `arg3`))
    elif arg2.isFixable:
      result = quote do:
        `form2`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg2`,
            `arg3`))
    else:
      result = quote do:
        `form3`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          `arg2`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg3`))
  else:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2..<(args.len)]
    if arg1.isFixable:
      result = quote do:
        `form1`[`St`, `Ev`, `Dm`, `Em`](
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `args`))
    elif arg2.isFixable:
      let
        rest = args[1..<(args.len)]
      result = quote do:
        `form2`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `rest`))
    else:
      result = quote do:
        `form3`[`St`, `Ev`, `Dm`, `Em`](
          `arg1`,
          `arg2`,
          fixup(`St`, `Ev`, `Dm`, `Em`,
            `arg3`))
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro form4NoChildren(
    form: static string,
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let
    argsLen = args.len
    form0 = ident(form & "0")
    form1 = ident(form & "1")
    form2 = ident(form & "2")
    form3 = ident(form & "3")
    form4 = ident(form & "4")
  when defined(debugMacros):
    debugEcho ""
    debugEcho form & "(" & $toStrLit(args) & ")"
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      `form0`[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg1 = args[0]
    result = quote do:
      `form1`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`)
  elif argsLen == 2:
    let
      arg1 = args[0]
      arg2 = args[1]
    result = quote do:
      `form2`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`)
  elif argsLen == 3:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2]
    result = quote do:
      `form3`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`,
        `arg3`)
  elif argsLen == 4:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2]
      arg4 = args[3]
    result = quote do:
      `form4`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`,
        `arg3`,
        `arg4`)
  else:
    raise (ref AssertionDefect)(
      msg: "macro '" & form &
           "' accepts at most 4 arguments but was invoked with " & $argsLen)
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro form5NoChildren(
    form: static string,
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  let
    argsLen = args.len
    form0 = ident(form & "0")
    form1 = ident(form & "1")
    form2 = ident(form & "2")
    form3 = ident(form & "3")
    form4 = ident(form & "4")
    form5 = ident(form & "5")
  when defined(debugMacros):
    debugEcho ""
    debugEcho form & "(" & $toStrLit(args) & ")"
    debugEcho ""
    debugEcho "args.len: " & $argsLen
    debugEcho ""
    debugEcho treeRepr args
  if argsLen == 0:
    result = quote do:
      `form0`[`St`, `Ev`, `Dm`, `Em`]()
  elif argsLen == 1:
    let
      arg1 = args[0]
    result = quote do:
      `form1`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`)
  elif argsLen == 2:
    let
      arg1 = args[0]
      arg2 = args[1]
    result = quote do:
      `form2`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`)
  elif argsLen == 3:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2]
    result = quote do:
      `form3`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`,
        `arg3`)
  elif argsLen == 4:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2]
      arg4 = args[3]
    result = quote do:
      `form4`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`,
        `arg3`,
        `arg4`)
  elif argsLen == 5:
    let
      arg1 = args[0]
      arg2 = args[1]
      arg3 = args[2]
      arg4 = args[3]
      arg5 = args[4]
    result = quote do:
      `form5`[`St`, `Ev`, `Dm`, `Em`](
        `arg1`,
        `arg2`,
        `arg3`,
        `arg4`,
        `arg5`)
  else:
    raise (ref AssertionDefect)(
      msg: "macro '" & form &
           "' accepts at most 5 arguments but was invoked with " & $argsLen)
  when defined(debugMacros):
    debugEcho ""
    debugEcho toStrLit result
    debugEcho ""

macro statechart*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form3WithChildren(
      "statechart",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro state*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form3WithChildren(
      "state",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro anon*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form2WithChildren(
      "anon",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro parallel*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form2WithChildren(
      "parallel",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro transition*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  for i, node in args:
    if node.kind == nnkBlockStmt:
      args[i] = toStrLit node
  result = quote do:
    form5NoChildren(
      "transition",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro guard*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  for i, node in args:
    if node.kind == nnkBlockStmt:
      args[i] = toStrLit node
  result = quote do:
    form4NoChildren(
      "guard",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro initial*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form1WithChildren(
      "initial",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro final*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form2WithChildren(
      "final",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro onEntry*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  for i, node in args:
    if node.kind == nnkBlockStmt:
      args[i] = toStrLit node
  result = quote do:
    form1NoChildren(
      "onEntry",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro onExit*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  for i, node in args:
    if node.kind == nnkBlockStmt:
      args[i] = toStrLit node
  result = quote do:
    form1NoChildren(
      "onExit",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

macro history*(
    St, Ev, Dm, Em: typedesc,
    args: varargs[untyped]):
      untyped =
  result = quote do:
    form3WithChildren(
      "history",
      `St`, `Ev`, `Dm`, `Em`,
      `args`)

# -----------------------------------------------------------------------------
# will need variations of transition macros/templates that allow for cond
# and/or exe to be untyped or concrete Cond/Exe

# earlier work re: snkTransition nodes was removed in the following commit, but
# that code can be a reference for how I was successfully building cond/exe
# procs:
# https://github.com/michaelsbradleyjr/snarts/commit/67800f924166391f9b64291f133b0dd662c117c2
