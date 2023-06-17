{.push raises: [].}

import pkg/snarts

type
  States = enum
    root, st1, st2

  Events = enum
    evA, evB

  Data = object
    case id: States
    else:
      x: string

  Event = object
    case name: Events
    of evA:
      y: int
    of evB:
      z: string

const
  spec1 = statechart(States, Events, Data, Event, "snart2", st1): []

  state1 = state(States, Events, Data, Event, st1, st2): []

  spec2 = statechart(States, Events, Data, Event, "", st1): [state1]

  spec3 = statechart(States, Events, Data, Event, "snart2", st1): [
    state(st1, st2, [])
  ]

  spec4 = statechart(States, Events, Data, Event, "snart2", st2): [
    state(st1, st2, []),
    state(st2, st1, [])
  ]

  spec5 = statechart(States, Events, Data, Event, "snart2", st2): @[
    state(st1, st2, [
      state(st2, st1, [
        state1,
        state(st2, st1, [])
    ])]),
    state(st1, st2, @[
      state(st2, st1, [state1, state1]),
      state1
    ])
  ]

echo ""
echo spec1
echo ""
echo state1
echo ""
echo spec2
echo ""
echo spec3
echo ""
echo spec4
echo ""
echo spec5

echo ""
