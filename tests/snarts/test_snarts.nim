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

suite "Templates":
  test "combinations of usage should not cause compile-time errors":
    type
      States = enum
        st1, st2

      Events = enum
        evA

      Data = object
        id: States

      Event = object
        name: Events

    # rewrite this to be in a `check:` block/s instead of `let`; lhs of `==`
    # should be the template invocation as below and rhs should be
    # expected-to-match invocation of `StatechartNode(kind: ..., ...)`

    var chart = statechart(States, Events, Data, Event)

    check:
      statechart(States, Events, Data, Event) ==
        Statechart[States, Events, Data, Event]()

    check:
      statechart(States, Events, Data, Event, []) ==
        Statechart[States, Events, Data, Event](
          scChildren: @[])
      statechart(States, Events, Data, Event, children = []) ==
        Statechart[States, Events, Data, Event](
          scChildren: @[])
    chart = statechart(States, Events, Data, Event): []
    check:
      chart ==
        Statechart[States, Events, Data, Event](
          scChildren: @[])

    check:
      statechart(States, Events, Data, Event, "test", []) ==
        Statechart[States, Events, Data, Event](
          scName: Opt.some "test",
          scChildren: @[])
      statechart(States, Events, Data, Event, "test", children = []) ==
        Statechart[States, Events, Data, Event](
          scName: Opt.some "test",
          scChildren: @[])
    chart = statechart(States, Events, Data, Event, "test"): []
    check:
      chart ==
        Statechart[States, Events, Data, Event](
          scName: Opt.some "test",
          scChildren: @[])
    check:
      statechart(States, Events, Data, Event, name = "test", []) ==
        Statechart[States, Events, Data, Event](
          scName: Opt.some "test",
          scChildren: @[])

    let
      # chart0 = statechart(States, Events, Data, Event)

      # chart1a = statechart(States, Events, Data, Event, [])
      # chart1b = statechart(States, Events, Data, Event, children = [])
      # chart1c = statechart(States, Events, Data, Event): []

      # chart2a = statechart(States, Events, Data, Event, "test", [])
      # chart2b = statechart(States, Events, Data, Event, "test", children = [])
      # chart2c = statechart(States, Events, Data, Event, "test"): []
      # chart2d = statechart(States, Events, Data, Event, name = "test", [])
      chart2e = statechart(States, Events, Data, Event, name = "test", children = [])
      chart2f = statechart(States, Events, Data, Event, children = [], name = "test")
      chart2g = statechart(States, Events, Data, Event, name = "test"): []
      chart2h = statechart(States, Events, Data, Event, st1, [])
      chart2i = statechart(States, Events, Data, Event, st1, children = [])
      chart2j = statechart(States, Events, Data, Event, st1): []
      chart2k = statechart(States, Events, Data, Event, initial = st1, [])
      chart2l = statechart(States, Events, Data, Event, initial = st1, children = [])
      chart2m = statechart(States, Events, Data, Event, children = [], initial = st1)
      chart2n = statechart(States, Events, Data, Event, initial = st1): []

      chart3a = statechart(States, Events, Data, Event, "test", st1, [])
      chart3b = statechart(States, Events, Data, Event, "test", st1, children = [])
      chart3c = statechart(States, Events, Data, Event, "test", st1): []
      chart3d = statechart(States, Events, Data, Event, name = "test", st1, [])
      chart3e = statechart(States, Events, Data, Event, name = "test", st1, children = [])
      chart3f = statechart(States, Events, Data, Event, name = "test", st1): []
      chart3g = statechart(States, Events, Data, Event, "test", initial = st1, [])
      chart3h = statechart(States, Events, Data, Event, "test", initial = st1, children = [])
      chart3i = statechart(States, Events, Data, Event, "test", children = [], initial = st1)
      chart3j = statechart(States, Events, Data, Event, "test", initial = st1): []
      chart3k = statechart(States, Events, Data, Event, name = "test", initial = st1, [])
      chart3l = statechart(States, Events, Data, Event, name = "test", initial = st1, children = [])
      chart3m = statechart(States, Events, Data, Event, name = "test", children = [], initial = st1)
      chart3n = statechart(States, Events, Data, Event, initial = st1, name = "test", children = [])
      chart3o = statechart(States, Events, Data, Event, initial = st1, children = [], name = "test")
      chart3p = statechart(States, Events, Data, Event, children = [], name = "test", initial = st1)
      chart3q = statechart(States, Events, Data, Event, children = [], initial = st1, name = "test")
      chart3r = statechart(States, Events, Data, Event, name = "test", initial = st1): []

      state0a = state(States, Events, Data, Event)
      state0b = anon(States, Events, Data, Event)

    #   state1a = state(States, Events, Data, Event, st1)
    #   state1b = state(States, Events, Data, Event, id = st1)
    #   state1c = state(States, Events, Data, Event, [])
    #   state1d = state(States, Events, Data, Event, children = [])
    #   state1e = state(States, Events, Data, Event): []
    #   state1f = anon(States, Events, Data, Event, st1)
    #   state1g = anon(States, Events, Data, Event, initial = st2)
    #   state1h = anon(States, Events, Data, Event, [])
    #   state1i = anon(States, Events, Data, Event, children = [])
    #   state1j = anon(States, Events, Data, Event): []

    #   state2a = state(States, Events, Data, Event, st1, st2)
    #   state2b = state(States, Events, Data, Event, id = st1, st2)
    #   state2c = state(States, Events, Data, Event, id = st1, initial = st2)
    #   state2d = state(States, Events, Data, Event, initial = st2, id = st1)
    #   state2e = state(States, Events, Data, Event, st1, initial = st2)
    #   state2f = state(States, Events, Data, Event, st1, [])
    #   state2g = state(States, Events, Data, Event, st1): []
    #   state2h = state(States, Events, Data, Event, id = st1, [])
    #   state2i = state(States, Events, Data, Event, id = st1): []
    #   state2j = state(States, Events, Data, Event, id = st1, children = [])
    #   state2k = state(States, Events, Data, Event, children = [], id = st1)
    #   state2l = state(States, Events, Data, Event, st1, children = [])
    #   state2m = anon(States, Events, Data, Event, st1, [])
    #   state2n = anon(States, Events, Data, Event, st1): []
    #   state2o = anon(States, Events, Data, Event, initial = st2, [])
    #   state2p = anon(States, Events, Data, Event, initial = st2): []
    #   state2q = anon(States, Events, Data, Event, initial = st2, children = [])
    #   state2r = anon(States, Events, Data, Event, children = [], initial = st2)
    #   state2s = anon(States, Events, Data, Event, st2, children = [])

    #   state3a = state(States, Events, Data, Event, st1, st2, [])
    #   state3b = state(States, Events, Data, Event, st1, st2): []
    #   state3c = state(States, Events, Data, Event, id = st1, st2, [])
    #   state3d = state(States, Events, Data, Event, id = st1, st2): []
    #   state3e = state(States, Events, Data, Event, id = st1, initial = st2, [])
    #   state3f = state(States, Events, Data, Event, id = st1, initial = st2): []
    #   state3g = state(States, Events, Data, Event, id = st1, initial = st2, children = [])
    #   state3h = state(States, Events, Data, Event, id = st1, children = [], initial = st2)
    #   state3i = state(States, Events, Data, Event, initial = st2, id = st1, children = [])
    #   state3j = state(States, Events, Data, Event, initial = st2, children = [], id = st1)
    #   state3k = state(States, Events, Data, Event, children = [], id = st1, initial = st2)
    #   state3l = state(States, Events, Data, Event, children = [], initial = st2, id = st1)
    #   state3m = state(States, Events, Data, Event, st1, initial = st2, [])
    #   state3n = state(States, Events, Data, Event, st1, initial = st2): []
    #   state3o = state(States, Events, Data, Event, st1, initial = st2, children = [])
    #   state3p = state(States, Events, Data, Event, st1, children = [], initial = st2)
    #   state3q = state(States, Events, Data, Event, st1, st2, children = [])

    # --------------------------------------------------------------------------

    # do the following after all the variations for state, parallel,
    # etc. (though should probably be replaced with a fully macro-ized
    # randomized setup)

    # for now can work out issues when fixup is in play for state in statechart

    proc statePa(x: int): StatechartNode[States, Events, Data, Event] =
      state(States, Events, Data, Event)

    let
      stateVa = state(States, Events, Data, Event)

    let
      spec1 = statechart(States, Events, Data, Event, [
        state
      ])

    check:
      spec1 == Statechart[States, Events, Data, Event](
        scChildren: @[StatechartNode[States, Events, Data, Event](
          kind: snkState, sChildren: @[])])

    let
      spec2 = statechart(States, Events, Data, Event, [
        # `snarts.state()` doesn't work, need to understand better 0 and 1+ arg
        # forms of DotExpr:
        # -----------------------------------------------------------------
        # Bracket
        #   Call
        #     DotExpr
        #       Ident "snarts"
        #       Ident "state"
        state()
      ])

    check:
      spec2 == Statechart[States, Events, Data, Event](
        scChildren: @[StatechartNode[States, Events, Data, Event](
          kind: snkState, sChildren: @[])])

    let
      spec3 = statechart(States, Events, Data, Event, [
        anon
      ])

    check:
      spec3 == Statechart[States, Events, Data, Event](
        scChildren: @[StatechartNode[States, Events, Data, Event](
          kind: snkState, sChildren: @[])])

    let
      spec4 = statechart(States, Events, Data, Event, [
        anon()
      ])

    check:
      spec4 == Statechart[States, Events, Data, Event](
        scChildren: @[StatechartNode[States, Events, Data, Event](
          kind: snkState, sChildren: @[])])

    let
      spec5 = statechart(States, Events, Data, Event, [
        # want to explore this in relation to outerscope having `state` (or
        # `anon`, etc.) that's a proc and in collision with `snarts.state`, but
        # see comments above re: DotExpr
        statePa(123)
      ])

    check:
      spec5 == Statechart[States, Events, Data, Event](
        scChildren: @[StatechartNode[States, Events, Data, Event](
          kind: snkState, sChildren: @[])])

    let
      spec6 = statechart(States, Events, Data, Event, [
        # want to explore this in relation to outerscope having `state` (or
        # `anon`, etc.) that's a value and in collision with `snarts.state`,
        # but see comments above re: DotExpr
        stateVa
      ])

    check:
      spec6 == Statechart[States, Events, Data, Event](
        scChildren: @[StatechartNode[States, Events, Data, Event](
          kind: snkState, sChildren: @[])])

    # --------------------------------------------------------------------------

    # re-enable this check after working out all the above; leave it disabled
    # for now because with `-d:debugMacros` the output resulting from the code
    # below makes it more difficult to sort out what errored and why (i.e. as
    # the DSL front-end is sorted out)

    # check:
    #   statechart(States, Events, Data, Event, "", []) ==
    #     Statechart[States, Events, Data, Event]()
    #   statechart(States, Events, Data, Event, "", []) ==
    #     Statechart[States, Events, Data, Event](scName: Opt.none string)
    #   statechart(States, Events, Data, Event, "test", []) ==
    #     Statechart[States, Events, Data, Event](scName: Opt.some "test")

suite "Validation":
  test "statechart must have one or more children":
    check: true
