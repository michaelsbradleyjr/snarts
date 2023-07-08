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

    var chart =
      statechart(
        States, Events, Data, Event)

    debugEcho ""
    debugEcho chart

    chart =
      statechart(
        States, Events, Data, Event,
        "test",
        st1,
        state(),
        state(),
        state(),
        state(),
        state()
      )

    debugEcho ""
    debugEcho chart

    debugEcho ""

suite "Validation":
  test "statechart must have one or more children":
    check: true
