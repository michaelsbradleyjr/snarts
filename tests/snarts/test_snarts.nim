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
        evA

      Data = object
        id: States

      Event = object
        name: Events

    # should turn the `debugEcho`s into `check: ...` where rhs is equivalent
    # expected StateChart/Node instance composed with raw constructors:
    # `Statechart[States, Events, Data, Event](...)`

    # variations of `statechart()` should be tested *after* variations of
    # `state()`, `parallel()`, et al.

    let chart0 =
      statechart(
        States, Events, Data, Event)

    debugEcho ""
    debugEcho chart0

    let chart1a =
      statechart(
        States, Events, Data, Event,
        "chart1a")

    debugEcho ""
    debugEcho chart1a

    let chart1b =
      statechart(
        States, Events, Data, Event,
        name = "chart1b")

    debugEcho ""
    debugEcho chart1b

    let chart1c =
      statechart(
        States, Events, Data, Event,
        st1)

    debugEcho ""
    debugEcho chart1c

    let chart1d =
      statechart(
        States, Events, Data, Event,
        initial = st1)

    debugEcho ""
    debugEcho chart1d

    let chart1e =
      statechart(
        States, Events, Data, Event,
        state())

    debugEcho ""
    debugEcho chart1e

    let chart1f =
      statechart(
        States, Events, Data, Event,
        [state()])

    debugEcho ""
    debugEcho chart1f

    let chart1g =
      statechart(
        States, Events, Data, Event,
        children = [state()])

    debugEcho ""
    debugEcho chart1g

    let chart2a =
      statechart(
        States, Events, Data, Event,
        "chart2a",
        st1)

    debugEcho ""
    debugEcho chart2a

    let chart2b =
      statechart(
        States, Events, Data, Event,
        st1,
        "chart2b")

    debugEcho ""
    debugEcho chart2b

    let chart2c =
      statechart(
        States, Events, Data, Event,
        name = "chart2c",
        st1)

    debugEcho ""
    debugEcho chart2c

    let chart2d =
      statechart(
        States, Events, Data, Event,
        st1,
        name = "chart2d")

    debugEcho ""
    debugEcho chart2d

    let chart2e =
      statechart(
        States, Events, Data, Event,
        "chart2e",
        initial = st1)

    debugEcho ""
    debugEcho chart2e

    let chart2f =
      statechart(
        States, Events, Data, Event,
        initial = st1,
        "chart2f")

    debugEcho ""
    debugEcho chart2f

    let chart2g =
      statechart(
        States, Events, Data, Event,
        name = "chart2g",
        initial = st1)

    debugEcho ""
    debugEcho chart2g

    let chart2h =
      statechart(
        States, Events, Data, Event,
        initial = st1,
        name = "chart2h")

    debugEcho ""
    debugEcho chart2h

    let chart2i =
      statechart(
        States, Events, Data, Event,
        "chart2i",
        state())

    debugEcho ""
    debugEcho chart2i

    let chart2j =
      statechart(
        States, Events, Data, Event,
        state(),
        "chart2j")

    debugEcho ""
    debugEcho chart2j

    let chart2k =
      statechart(
        States, Events, Data, Event,
        "chart2k",
        [state()])

    debugEcho ""
    debugEcho chart2k

    let chart2l =
      statechart(
        States, Events, Data, Event,
        [state()],
        "chart2l")

    debugEcho ""
    debugEcho chart2l

    let chart2m =
      statechart(
        States, Events, Data, Event,
        "chart2m",
        children = [state()])

    debugEcho ""
    debugEcho chart2m

    let chart2n =
      statechart(
        States, Events, Data, Event,
        children = [state()],
        "chart2n")

    debugEcho ""
    debugEcho chart2n

    let chart2o =
      statechart(
        States, Events, Data, Event,
        name = "chart2o",
        state())

    debugEcho ""
    debugEcho chart2o

    let chart2p =
      statechart(
        States, Events, Data, Event,
        state(),
        name = "chart2p")

    debugEcho ""
    debugEcho chart2p

    let chart2q =
      statechart(
        States, Events, Data, Event,
        name = "chart2q",
        [state()])

    debugEcho ""
    debugEcho chart2q

    let chart2r =
      statechart(
        States, Events, Data, Event,
        [state()],
        name = "chart2r")

    debugEcho ""
    debugEcho chart2r

    let chart2s =
      statechart(
        States, Events, Data, Event,
        name = "chart2s",
        children = [state()])

    debugEcho ""
    debugEcho chart2s

    let chart2t =
      statechart(
        States, Events, Data, Event,
        children = [state()],
        name = "chart2t")

    debugEcho ""
    debugEcho chart2t

    let chart2u =
      statechart(
        States, Events, Data, Event,
        st1,
        state())

    debugEcho ""
    debugEcho chart2u

    let chart2v =
      statechart(
        States, Events, Data, Event,
        state(),
        st1)

    debugEcho ""
    debugEcho chart2v

    let chart2w =
      statechart(
        States, Events, Data, Event,
        st1,
        [state()])

    debugEcho ""
    debugEcho chart2w

    let chart2x =
      statechart(
        States, Events, Data, Event,
        [state()],
        st1)

    debugEcho ""
    debugEcho chart2x

    let chart2y =
      statechart(
        States, Events, Data, Event,
        st1,
        children = [state()])

    debugEcho ""
    debugEcho chart2y

    let chart2z =
      statechart(
        States, Events, Data, Event,
        children = [state()],
        st1)

    debugEcho ""
    debugEcho chart2z

    let chart2aa =
      statechart(
        States, Events, Data, Event,
        initial = st1,
        state())

    debugEcho ""
    debugEcho chart2aa

    let chart2ab =
      statechart(
        States, Events, Data, Event,
        state(),
        initial = st1)

    debugEcho ""
    debugEcho chart2ab

    let chart2ac =
      statechart(
        States, Events, Data, Event,
        initial = st1,
        [state()])

    debugEcho ""
    debugEcho chart2ac

    let chart2ad =
      statechart(
        States, Events, Data, Event,
        [state()],
        initial = st1)

    debugEcho ""
    debugEcho chart2ad

    let chart2ae =
      statechart(
        States, Events, Data, Event,
        initial = st1,
        children = [state()])

    debugEcho ""
    debugEcho chart2ae

    let chart2af =
      statechart(
        States, Events, Data, Event,
        children = [state()],
        initial = st1)

    debugEcho ""
    debugEcho chart2af

    let chart2ag =
      statechart(
        States, Events, Data, Event,
        state(), state())

    debugEcho ""
    debugEcho chart2ag

    # !!! chart3 !!!

    # let chart3 =



    debugEcho ""



suite "Validation":
  test "statechart must have one or more children":
    check: true
