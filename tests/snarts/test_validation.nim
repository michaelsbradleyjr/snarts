import std/strutils
import pkg/snarts
import pkg/unittest2

suite "Validation":
  type
    States = enum
      st1, st2

    Events = enum
      evA

    Data = object
      id: States

    Event = object
      name: Events

  var
    spec = initStatechart[States, Events, Data, Event](
      scName = Opt.some "",
      scChildren = [
        state(States, Events, Data, Event)
    ])

    res = spec.compile

  test "statechart root's 'name' field must not contain an empty string":
    # let machine = res.expect
    check:
      res.isErr
      res.error.errors.len == 1
      "contain an empty string" in res.error.errors[0].msg

  test "statechart root must have one or more children":
    spec = statechart(States, Events, Data, Event)
    res = spec.compile

    # let machine = res.expect
    check:
      res.isErr
      res.error.errors.len == 1
      "must have one or more" in res.error.errors[0].msg

  test "statechart root must not have an 'initial' child":
    spec = statechart(
      States, Events, Data, Event, [
        initial(),
        initial()
    ])

    res = spec.compile

    # let machine = res.expect
    check:
      res.isErr
      res.error.errors.len == 1
      "must not have an 'initial'" in res.error.errors[0].msg

  test "statechart root must not have a 'history' child":
    spec = statechart(
      States, Events, Data, Event, [
        history(),
        history()
    ])

    res = spec.compile

    # let machine = res.expect
    check:
      res.isErr
      res.error.errors.len == 1
      "must not have a 'history'" in res.error.errors[0].msg
