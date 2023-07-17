import std/macros
import pkg/snarts
import pkg/unittest2

# in tests `let` is preferred to `const` for defining `type Statechart`
# instances because usage of `const` does not generate coverage data

suite "DSL front-end":
  # this suite is not testing the construction of valid statecharts; rather,
  # it's testing that usages of macros `statechart`, `state`, et al., and the
  # macros they call in turn, produce the expected instances of types
  # `Statechart` and `StatechartNode`

  type
    States = enum
      st1, st2

    Events = enum
      evA

    Data = object
      id: States

    Event = object
      name: Events

  macro toString(x: untyped): string =
    let s = toStrLit x
    result = quote do:
      `s`

  let
    aChild = state(States, Events, Data, Event)
    aCond = Cond(toString((block: debugEcho config)))
    aEvent = evA
    aExe = Exe(toString((block: debugEcho config)))
    aName = "test"
    aState = st1

  proc aCall(): auto =
    state(
      States, Events, Data, Event,
      st2)

  var
    spec =
      statechart(States, Events, Data, Event)

    spex =
      Statechart[States, Events, Data, Event]()

  test "statechart":
    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        "test")

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.some "test",
        scChildren: @[])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        st1)

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some st1,
        scName: Opt.none string,
        scChildren: @[])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        [aCall(), aChild, state()])

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        "test",
        st1)

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some st1,
        scName: Opt.some "test",
        scChildren: @[])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        "test",
        [aCall(), aChild, state()])

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.some "test",
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        st1,
        [aCall(), aChild, state()])

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some st1,
        scName: Opt.none string,
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        aName,
        aState,
        [aCall(), aChild, state()])

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some aState,
        scName: Opt.some aName,
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial = aState,
        name = aName,
        [aCall(), aChild, state()])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial = aState,
        name = aName,
        aCall(),
        aChild,
        state())

    check: spec == spex

  test "state":
    spec =
      statechart(
        States, Events, Data, Event,
        state())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.none States,
            sChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        state(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.some st1,
            sInitial: Opt.none States,
            sChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        state(
          [aCall(), aChild, state()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.none States,
            sChildren: @[
              aCall(),
              aChild,
              state(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        state(
          st1,
          st2))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.some st1,
            sInitial: Opt.some st2,
            sChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        state(
          st1,
          [aCall(), aChild, state()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.some st1,
            sInitial: Opt.none States,
            sChildren: @[
              aCall(),
              aChild,
              state(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        state(
          initial = st2,
          id = st1,
          [aCall(), aChild, state()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.some st1,
            sInitial: Opt.some st2,
            sChildren: @[
              aCall(),
              aChild,
              state(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        state(
          initial = st2,
          id = st1,
          aCall(),
          aChild,
          state()))

    check: spec == spex

  test "anon":
    spec =
      statechart(
        States, Events, Data, Event,
        anon())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.none States,
            sChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        anon(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.some st1,
            sChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        anon(
          [aCall(), aChild, anon()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.none States,
            sChildren: @[
              aCall(),
              aChild,
              anon(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        anon(
          st1,
          [aCall(), aChild, anon()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.some st1,
            sChildren: @[
              aCall(),
              aChild,
              anon(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        anon(
          initial = st1,
          aCall(),
          aChild,
          anon()))

    check: spec == spex

  test "parallel":
    spec =
      statechart(
        States, Events, Data, Event,
        parallel())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.none States,
            pChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        parallel(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.some st1,
            pChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        parallel(
          [aCall(), aChild, parallel()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.none States,
            pChildren: @[
              aCall(),
              aChild,
              parallel(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        parallel(
          st1,
          [aCall(), aChild, parallel()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.some st1,
            pChildren: @[
              aCall(),
              aChild,
              parallel(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        parallel(
          id = st1,
          [aCall(), aChild, parallel()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.some st1,
            pChildren: @[
              aCall(),
              aChild,
              parallel(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        parallel(
          id = st1,
          aCall(),
          aChild,
          parallel()))

    check: spec == spex

  test "transition":
    spec =
      statechart(
        States, Events, Data, Event,
        transition())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          st1,
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          st1,
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          (block: debugEcho config),
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          st1,
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          st1,
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          (block: debugEcho config),
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          st1,
          (block: debugEcho config),
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          st1,
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          (block: debugEcho config),
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          st1,
          (block: debugEcho config),
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          st1,
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          st1,
          (block: debugEcho config),
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          evA,
          st1,
          (block: debugEcho config),
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.some aExe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          event = aEvent,
          target = aState,
          cond = (block: debugEcho config),
          exe = (block: debugEcho config),
          kind = tkInternal))

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        transition(
          exe = (block: debugEcho config),
          target = aState,
          event = aEvent,
          kind = tkInternal,
          cond = (block: debugEcho config)))

    check: spec == spex

  test "guard":
    spec =
      statechart(
        States, Events, Data, Event,
        guard())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          st1,
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          st1,
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          st1,
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkExternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          st1,
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.none Cond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.none States,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          st1,
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.none Events,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          evA,
          st1,
          (block: debugEcho config),
          tkInternal))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkTransition,
            tEvent: Opt.some evA,
            tCond: Opt.some aCond,
            tTarget: Opt.some st1,
            tKind: tkInternal,
            tExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          event = aEvent,
          target = aState,
          cond = (block: debugEcho config),
          kind = tkInternal))

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        guard(
          target = aState,
          event = aEvent,
          kind = tkInternal,
          cond = (block: debugEcho config)))

    check: spec == spex

  test "initial":
    spec =
      statechart(
        States, Events, Data, Event,
        initial())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial(
          [aCall(), aChild, initial()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              aCall(),
              aChild,
              initial(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial(
          aCall()))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              aCall()])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial(
          aChild))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              aChild])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial(
          initial()))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              initial(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        initial(
          aCall(),
          aChild,
          initial()))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              aCall(),
              aChild,
              initial(States, Events, Data, Event)])])

    check: spec == spex

  test "final":
    spec =
      statechart(
        States, Events, Data, Event,
        final())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.none States,
            fChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        final(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.some st1,
            fChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        final(
          [aCall(), aChild, final()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.none States,
            fChildren: @[
              aCall(),
              aChild,
              final(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        final(
          st1,
          [aCall(), aChild, final()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.some st1,
            fChildren: @[
              aCall(),
              aChild,
              final(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        final(
          id = st1,
          [aCall(), aChild, final()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.some st1,
            fChildren: @[
              aCall(),
              aChild,
              final(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        final(
          id = st1,
          aCall(),
          aChild,
          final()))

    check: spec == spex

  test "onEntry":
    spec =
      statechart(
        States, Events, Data, Event,
        onEntry())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnEntry,
            oExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        onEntry(
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnEntry,
            oExe: Opt.some aExe)])

    check: spec == spex

  test "onExit":
    spec =
      statechart(
        States, Events, Data, Event,
        onExit())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnExit,
            oExe: Opt.none Exe)])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        onExit(
          (block: debugEcho config)))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnExit,
            oExe: Opt.some aExe)])

    check: spec == spex

  test "history":
    spec =
      statechart(
        States, Events, Data, Event,
        history())

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.none States,
            hKind: hkShallow,
            hChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          st1))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.some st1,
            hKind: hkShallow,
            hChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          hkDeep))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.none States,
            hKind: hkDeep,
            hChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          [aCall(), aChild, history()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.none States,
            hKind: hkShallow,
            hChildren: @[
              aCall(),
              aChild,
              history(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          st1,
          hkDeep))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.some st1,
            hKind: hkDeep,
            hChildren: @[])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          st1,
          [aCall(), aChild, history()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.some st1,
            hKind: hkShallow,
            hChildren: @[
              aCall(),
              aChild,
              history(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          hkDeep,
          [aCall(), aChild, history()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.none States,
            hKind: hkDeep,
            hChildren: @[
              aCall(),
              aChild,
              history(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          kind = hkDeep,
          id = st1,
          [aCall(), aChild, history()]))

    spex =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.some st1,
            hKind: hkDeep,
            hChildren: @[
              aCall(),
              aChild,
              history(States, Events, Data, Event)])])

    check: spec == spex

    spec =
      statechart(
        States, Events, Data, Event,
        history(
          kind = hkDeep,
          id = st1,
          aCall(),
          aChild,
          history()))

    check: spec == spex
