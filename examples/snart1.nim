{.push raises: [].}

import pkg/snarts

type
  States = enum
    st1, st2, st3

  Events = enum
    evA, evB

  Data = object
    case id: States
    else:
      discard

  Event = object
    case name: Events
    else:
      discard

let # const
  state1 = state(States, Events, Data, Event, st1, st2): []

  spec1 = statechart(States, Events, Data, Event, st1, "snart1", [])

  spec2 = statechart(States, Events, Data, Event, st1, "snart1", @[])

  spec3 = statechart(States, Events, Data, Event, st1, "snart1"): []

  spec4 = statechart(States, Events, Data, Event, st1, "snart1"): @[]

  spec5 = statechart(States, Events, Data, Event, st1, "snart1"): [
    state1
  ]

  spec6 = statechart(States, Events, Data, Event, st1, "snart1"): [
    state1,
    state(States, Events, Data, Event, st1, st2, []),
    state1
  ]

  spec7 = statechart(States, Events, Data, Event, st1, "snart1"): [
    state1,
    state(st1, st2, []),
    state1
  ]

echo ""
echo state1
echo ""
echo spec1.St
echo spec1.Ev
echo spec1.Dm
echo spec1.Em
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

echo ""
