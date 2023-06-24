import pkg/snarts
import pkg/unittest2

# in tests `let` is preferred to `const` because the latter does not generate
# coverate data

suite "Templates":
  test "combinations of usage should not cause compile-time errors":
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
      state1 = state(States, Events, Data, Event, st1, st2): []

      spec1 = statechart(States, Events, Data, Event, "snart1", st1, [])

      spec2 = statechart(States, Events, Data, Event, "snart1", st1, @[])

      spec3 = statechart(States, Events, Data, Event, "snart1", st1): []

      spec4 = statechart(States, Events, Data, Event, "snart1", st1): @[]

      spec5 = statechart(States, Events, Data, Event, "snart1", st1): [
        state1
      ]

      spec6 = statechart(States, Events, Data, Event, "snart1", st1): [
        state1,
        state(States, Events, Data, Event, st1, st2, []),
        state1
      ]

      spec7 = statechart(States, Events, Data, Event, "snart1", st1): [
        state1,
        state(st1, st2, []),
        state1
      ]

    echo ""
    echo state1
    echo ""
    echo spec1
    echo ""
    echo spec2
    echo ""
    echo spec3
    echo ""
    echo spec4
    echo ""
    echo spec5
    echo ""
    echo spec6
    echo ""
    echo spec7

    check:
      spec1.St is States
      spec1.Ev is Events
      spec1.Dm is Data
      spec1.Em is Event

    let
      tran1 = initTransition[States, Events, Data, Event]()

    echo ""
    echo tran1

    echo ""

suite "Validation":
  test "statechart must have one or more children":
    check: true
