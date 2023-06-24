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
      spec1a = statechart(States, Events, Data, Event, [])
      spec1b = statechart(States, Events, Data, Event, children = [])
      spec1c = statechart(States, Events, Data, Event): []
      spec2aa = statechart(States, Events, Data, Event, "spec2aa", [])
      spec2ab = statechart(States, Events, Data, Event, "spec2aa", children = [])
      spec2ac = statechart(States, Events, Data, Event, "spec2aa"): []
      spec2ba = statechart(States, Events, Data, Event, name = "spec2ab", [])
      spec2bb = statechart(States, Events, Data, Event, name = "spec2ab", children = [])
      spec2bc = statechart(States, Events, Data, Event, children = [], name = "spec2ab")
      spec2bd = statechart(States, Events, Data, Event, name = "spec2ab"): []
      spec2ca = statechart(States, Events, Data, Event, st1, [])
      spec2cb = statechart(States, Events, Data, Event, st1, children = [])
      spec2cc = statechart(States, Events, Data, Event, st1): []
      spec2da = statechart(States, Events, Data, Event, initial = st1, [])
      spec2db = statechart(States, Events, Data, Event, initial = st1, children = [])
      spec2dc = statechart(States, Events, Data, Event, children = [], initial = st1)
      spec2dd = statechart(States, Events, Data, Event, initial = st1): []
      spec3aa = statechart(States, Events, Data, Event, "spec3", st1, [])
      spec3ab = statechart(States, Events, Data, Event, "spec3", st1, children = [])
      spec3ac = statechart(States, Events, Data, Event, "spec3", st1): []
      spec3ba = statechart(States, Events, Data, Event, name = "spec3", st1, [])
      spec3bb = statechart(States, Events, Data, Event, name = "spec3", st1, children = [])
      spec3bc = statechart(States, Events, Data, Event, name = "spec3", st1): []
      spec3ca = statechart(States, Events, Data, Event, "spec3", initial = st1, [])
      spec3cb = statechart(States, Events, Data, Event, "spec3", initial = st1, children = [])
      spec3cc = statechart(States, Events, Data, Event, "spec3", children = [], initial = st1)
      spec3cd = statechart(States, Events, Data, Event, "spec3", initial = st1): []
      spec3da = statechart(States, Events, Data, Event, name = "spec3", initial = st1, [])
      spec3db = statechart(States, Events, Data, Event, name = "spec3", initial = st1, children = [])
      spec3dc = statechart(States, Events, Data, Event, name = "spec3", children = [], initial = st1)
      spec3dd = statechart(States, Events, Data, Event, initial = st1, name = "spec3", children = [])
      spec3de = statechart(States, Events, Data, Event, initial = st1, children = [], name = "spec3")
      spec3df = statechart(States, Events, Data, Event, children = [], name = "spec3", initial = st1)
      spec3dg = statechart(States, Events, Data, Event, children = [], initial = st1, name = "spec3")
      spec3dh = statechart(States, Events, Data, Event, name = "spec3", initial = st1): []

      state0a = state(States, Events, Data, Event)
      state0b = anon(States, Events, Data, Event)
      state1aa = state(States, Events, Data, Event, st1)
      state1ab = state(States, Events, Data, Event, id = st1)
      state1ba = anon(States, Events, Data, Event, st1)
      state1bb = anon(States, Events, Data, Event, initial = st1)
      state1ca = state(States, Events, Data, Event, [])
      state1cb = state(States, Events, Data, Event, children = [])
      state1cc = anon(States, Events, Data, Event, [])
      state1cd = anon(States, Events, Data, Event, children = [])

    # do these after all the variations for state, parallel, etc.
    # for now can work out issues when fixup is in play for state in statechart

    echo ""
    echo spec1a
    echo ""
    echo spec1b
    echo ""
    echo spec1c
    echo ""
    echo spec2aa
    echo ""
    echo spec2ab
    echo ""
    echo spec2ac
    echo ""
    echo spec2ba
    echo ""
    echo spec2bb
    echo ""
    echo spec2bc
    echo ""
    echo spec2bd
    echo ""
    echo spec2ca
    echo ""
    echo spec2cb
    echo ""
    echo spec2cc
    echo ""
    echo spec2da
    echo ""
    echo spec2db
    echo ""
    echo spec2dc
    echo ""
    echo spec2dd
    echo ""
    echo spec3aa
    echo ""
    echo spec3ab
    echo ""
    echo spec3ac
    echo ""
    echo spec3ba
    echo ""
    echo spec3bb
    echo ""
    echo spec3bc
    echo ""
    echo spec3ca
    echo ""
    echo spec3cb
    echo ""
    echo spec3cc
    echo ""
    echo spec3cd
    echo ""
    echo spec3da
    echo ""
    echo spec3db
    echo ""
    echo spec3dc
    echo ""
    echo spec3dd
    echo ""
    echo spec3de
    echo ""
    echo spec3df
    echo ""
    echo spec3dg
    echo ""
    echo spec3dh
    echo ""
    echo state0a
    echo ""
    echo state0b
    echo ""
    echo state1aa
    echo ""
    echo state1ab
    echo ""
    echo state1ba
    echo ""
    echo state1bb
    echo ""
    echo state1ca
    echo ""
    echo state1cb
    echo ""
    echo state1cc
    echo ""
    echo state1cd

    echo ""

    check:
      statechart(States, Events, Data, Event, "", []).scName == Opt.none string
      statechart(States, Events, Data, Event, "test", []).scName == Opt.some "test"

suite "Validation":
  test "statechart must have one or more children":
    check: true
