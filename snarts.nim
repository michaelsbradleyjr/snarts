{.push raises: [].}

import std/[macros, typetraits]
import ./snarts/algos

export algos

type Void* = object

func init*(T: typedesc[Void]): T =
  Void()

macro atomic*(): auto =
  result = quote do:
    State(kind: skState)

macro atomic*(id: string): auto =
  result = quote do:
    State(kind: skState, id: Opt.some StateId `id`)

macro state*(children: openArray[State]): auto =
  result = quote do:
    State(kind: skState, children: @`children`)

macro state*(id: string, children: openArray[State]): auto =
  result = quote do:
    State(kind: skState, children: @`children`, id: Opt.some StateId `id`)

macro statechart*(children: openArray[State]): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[Void](children: @`children`, model: ModelName(Void.`tName`))

macro statechart*(name: string, children: openArray[State]): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[Void](children: @`children`, model: ModelName(Void.`tName`),
      name: Opt.some ChartName `name`)

macro statechart*(T: typedesc, children: openArray[State]): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[`T`](children: @`children`, model: ModelName(`T`.`tName`))

macro statechart*(T: typedesc, name: string, children: openArray[State]): auto =
  let tName = bindSym"name"
  result = quote do:
    Statechart[`T`](children: @`children`, model: ModelName(`T`.`tName`),
      name: Opt.some ChartName `name`)
