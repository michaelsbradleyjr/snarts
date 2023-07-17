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
      "has no child states" in res.error.errors[0].msg
