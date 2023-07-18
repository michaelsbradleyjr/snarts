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
    spec = statechart(States, Events, Data, Event)
    res = spec.compile

  test "statechart must have one or more children":
    check:
      res.isErr
      res.error.errors.len == 1
      "has no children" in res.error.errors[0].msg

  test "statechart root must not have an 'initial' child":
    spec = statechart(
      States, Events, Data, Event, [
        initial(),
        initial()
    ])

    res = spec.compile

    check:
      res.isErr
      res.error.errors.len == 1
      "has an 'initial'" in res.error.errors[0].msg

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
      "has a 'history'" in res.error.errors[0].msg
