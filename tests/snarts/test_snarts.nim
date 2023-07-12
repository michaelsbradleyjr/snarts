import pkg/snarts
import pkg/unittest2

# in tests `let` is preferred to `const` because the latter does not generate
# coverate data

func `==`[St, Ev, Dm, Em](a, b: StatechartNode[St, Ev, Dm, Em]): bool =
  if a.kind != b.kind:
    result = false
  else:
    case a.kind
    of snkState:
      result = (
        (a.sId == b.sId) and
        (a.sInitial == b.sInitial) and
        (a.sChildren == b.sChildren))
    else:
      result = false

func `==`[St, Ev, Dm, Em](a, b: Statechart[St, Ev, Dm, Em]): bool =
  (a.scInitial == b.scInitial) and
  (a.scName == b.scName) and
  (a.scChildren == b.scChildren)

suite "DSL front-end":
  test "usage variations and combinations should not cause compile-time errors":
    type
      States = enum
        st1, st2

      Events = enum
        evA, evB

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
      aChild

    var
      chart =
        statechart(States, Events, Data, Event)

      chexp =
        Statechart[States, Events, Data, Event]()

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        "test")

    chexp = Statechart[States, Events, Data, Event](
      scInitial: Opt.none States,
      scName: Opt.some "test",
      scChildren: @[])

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        name = "test")

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        st1)

    chexp = Statechart[States, Events, Data, Event](
      scInitial: Opt.some st1,
      scName: Opt.none string,
      scChildren: @[])

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        initial = st1)

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        [])

    chexp = Statechart[States, Events, Data, Event](
      scInitial: Opt.none States,
      scName: Opt.none string,
      scChildren: @[])

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        children = [])

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        aName,
        aState,
        [aCall(), aChild])

    chexp = Statechart[States, Events, Data, Event](
      scInitial: Opt.some aState,
      scName: Opt.some aName,
      scChildren: @[aCall(), aChild])

    check: chart == chexp

    chart =
      statechart(States, Events, Data, Event,
        initial = aState,
        name = aName,
        aCall(),
        aChild)

    check: chart == chexp

suite "Validation":
  test "statechart must have one or more children":
    check: true
