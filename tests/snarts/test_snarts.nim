import std/macros
import pkg/snarts
import pkg/unittest2

# in tests `let` is preferred to `const` because the latter does not generate
# coverage data

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

  let
    aChild = state(States, Events, Data, Event)
    aEvent = evA
    aName = "test"
    aState = st1

  proc aCall(): auto =
    state(
      States, Events, Data, Event,
      st2)

  macro toString(x: untyped): string =
    let s = toStrLit x
    result = quote do:
      `s`

  var
    chart =
      statechart(States, Events, Data, Event)

    chexp =
      Statechart[States, Events, Data, Event]()

  test "statechart":
    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        "test")

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.some "test",
        scChildren: @[])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        st1)

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some st1,
        scName: Opt.none string,
        scChildren: @[])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        [aCall(), aChild, state()])

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        "test",
        st1)

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some st1,
        scName: Opt.some "test",
        scChildren: @[])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        "test",
        [aCall(), aChild, state()])

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.some "test",
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        st1,
        [aCall(), aChild, state()])

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some st1,
        scName: Opt.none string,
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        aName,
        aState,
        [aCall(), aChild, state()])

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.some aState,
        scName: Opt.some aName,
        scChildren: @[
          aCall(),
          aChild,
          state(States, Events, Data, Event)])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial = aState,
        name = aName,
        [aCall(), aChild, state()])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial = aState,
        name = aName,
        aCall(),
        aChild,
        state())

    check: chart == chexp

  test "state":
    chart =
      statechart(
        States, Events, Data, Event,
        state())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.none States,
            sChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        state(
          st1))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.some st1,
            sInitial: Opt.none States,
            sChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        state(
          [aCall(), aChild, state()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        state(
          st1,
          st2))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.some st1,
            sInitial: Opt.some st2,
            sChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        state(
          st1,
          [aCall(), aChild, state()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        state(
          initial = st2,
          id = st1,
          [aCall(), aChild, state()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        state(
          initial = st2,
          id = st1,
          aCall(),
          aChild,
          state()))

    check: chart == chexp

  test "anon":
    chart =
      statechart(
        States, Events, Data, Event,
        anon())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.none States,
            sChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        anon(
          st1))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkState,
            sId: Opt.none States,
            sInitial: Opt.some st1,
            sChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        anon(
          [aCall(), aChild, anon()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        anon(
          st1,
          [aCall(), aChild, anon()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        anon(
          initial = st1,
          aCall(),
          aChild,
          anon()))

    check: chart == chexp

  test "parallel":
    chart =
      statechart(
        States, Events, Data, Event,
        parallel())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.none States,
            pChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        parallel(
          st1))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkParallel,
            pId: Opt.some st1,
            pChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        parallel(
          [aCall(), aChild, parallel()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        parallel(
          st1,
          [aCall(), aChild, parallel()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        parallel(
          id = st1,
          [aCall(), aChild, parallel()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        parallel(
          id = st1,
          aCall(),
          aChild,
          parallel()))

    check: chart == chexp

  test "transition":
    discard

  test "guard":
    discard

  test "initial":
    chart =
      statechart(
        States, Events, Data, Event,
        initial())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial(
          [aCall(), aChild, initial()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial(
          aCall()))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              aCall()])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial(
          aChild))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              aChild])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial(
          initial()))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkInitial,
            iChildren: @[
              initial(States, Events, Data, Event)])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        initial(
          aCall(),
          aChild,
          initial()))

    chexp =
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

    check: chart == chexp

  test "final":
    chart =
      statechart(
        States, Events, Data, Event,
        final())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.none States,
            fChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        final(
          st1))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkFinal,
            fId: Opt.some st1,
            fChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        final(
          [aCall(), aChild, final()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        final(
          st1,
          [aCall(), aChild, final()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        final(
          id = st1,
          [aCall(), aChild, final()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        final(
          id = st1,
          aCall(),
          aChild,
          final()))

    check: chart == chexp

  test "onEntry":
    chart =
      statechart(
        States, Events, Data, Event,
        onEntry())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnEntry,
            oExe: Opt.none Exe)])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        onEntry(
          block: debugEcho config))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnEntry,
            oExe: Opt.some Exe(toString(block: debugEcho config)))])

    check: chart == chexp

  test "onExit":
    chart =
      statechart(
        States, Events, Data, Event,
        onExit())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnExit,
            oExe: Opt.none Exe)])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        onExit(
          block: debugEcho config))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkOnExit,
            oExe: Opt.some Exe(toString(block: debugEcho config)))])

    check: chart == chexp

  test "history":
    chart =
      statechart(
        States, Events, Data, Event,
        history())

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.none States,
            hKind: hkShallow,
            hChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          st1))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.some st1,
            hKind: hkShallow,
            hChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          hkDeep))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.none States,
            hKind: hkDeep,
            hChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          [aCall(), aChild, history()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          st1,
          hkDeep))

    chexp =
      Statechart[States, Events, Data, Event](
        scInitial: Opt.none States,
        scName: Opt.none string,
        scChildren: @[
          StatechartNode[States, Events, Data, Event](
            kind: snkHistory,
            hId: Opt.some st1,
            hKind: hkDeep,
            hChildren: @[])])

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          st1,
          [aCall(), aChild, history()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          hkDeep,
          [aCall(), aChild, history()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          kind = hkDeep,
          id = st1,
          [aCall(), aChild, history()]))

    chexp =
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

    check: chart == chexp

    chart =
      statechart(
        States, Events, Data, Event,
        history(
          kind = hkDeep,
          id = st1,
          aCall(),
          aChild,
          history()))

    check: chart == chexp

suite "Validation":
  test "statechart must have one or more children":
    check: true
