// Architecture of the notebook:
//
// The state of all Cells is stored in the parent Notebook component. This way the Notebook component can access the state of each cell.
// However, this would normally lead to a rerender of the whole notebook component when a single cell gets modified.
// To overcome this, the entries in the cellState that need to be accessed from the Notebook and the Cell are wrapped in a ref (see https://rescript-lang.org/docs/manual/latest/mutation).
// The ref is essentially an object wrapped around the entry. Now the entry of the object can be changed without triggering a rerender of the whole notebook, since from React's perspective the object didn't change.
// To trigger a rerender in the corresponding Cell, the reducers of the Cell component need to create a new state record.

// The type for the cell state

type cellState = {
  cell_type: CellBase.cell_type,
  metadata: string,
  source: ref<string>,
  outputs: ref<array<CellBase.output>>,
  display_input: ref<string>,
  index: int,
}

// The type for the notebook state

type notebookState = {
  name: string,
  count: int,
  indices: Belt.List.t<int>,
  cells: Belt.HashMap.Int.t<cellState>,
}

let defaultCell = (
  ~cell_type=CellBase.Code,
  ~metadata="",
  ~source="",
  ~outputs=[CellBase.TextPlain("")],
  ~display_input="inline-block",
  ~index=0,
  (),
) => {
  cell_type: cell_type,
  metadata: metadata,
  source: ref(source),
  outputs: ref(outputs),
  display_input: ref(display_input),
  index: index,
}

// Actions for the notebook reducer

type notebookActions =
  | AddCodeCell(option<int>)
  | AddMarkdownCell(option<int>)
  | DeleteCell(option<int>)
  | MoveCellUp(option<int>)
  | MoveCellDown(option<int>)
  | OpenNotebook(notebookState)
  | DisplayCellOutput(int, array<CellBase.output>, string)
  | ChangeNotebookName(string)
  | ClearCodeOutput(option<int>)
  | ClearAllCodeOutput

// Reducer for the notebook component

let notebookReducer = (state, action) => {
  switch action {
  | AddCodeCell(sel) =>
    switch sel
    ->Belt.Option.flatMap(i =>
      state.indices
      ->Belt.List.mapWithIndex((index, x) => {
        if x == i {
          Some(index)
        } else {
          None
        }
      })
      ->Belt.List.getBy(y => Belt.Option.isSome(y))
    )
    ->Belt.Option.flatMap(x => {
      x->Belt.Option.flatMap(y => {
        state.indices->Belt.List.splitAt(y + 1)
      })
    })
    ->Belt.Option.map(((head, tail)) => {
      Belt.List.concat(head, Belt.List.concat(list{state.count}, tail))
    }) {
    | Some(list) => {
        ...state,
        count: state.count + 1,
        indices: list,
        cells: {
          state.cells->Belt.HashMap.Int.set(
            state.count,
            defaultCell(~cell_type=CellBase.Code, ~index={state.count}, ()),
          )
          state.cells
        },
      }
    | None => {
        ...state,
        count: state.count + 1,
        indices: Belt.List.concat(state.indices, list{state.count}),
        cells: {
          state.cells->Belt.HashMap.Int.set(
            state.count,
            defaultCell(~cell_type=CellBase.Code, ~index={state.count}, ()),
          )
          state.cells
        },
      }
    }
  | AddMarkdownCell(sel) =>
    switch sel
    ->Belt.Option.flatMap(i =>
      state.indices
      ->Belt.List.mapWithIndex((index, x) => {
        if x == i {
          Some(index)
        } else {
          None
        }
      })
      ->Belt.List.getBy(y => Belt.Option.isSome(y))
    )
    ->Belt.Option.flatMap(x => {
      x->Belt.Option.flatMap(y => {
        state.indices->Belt.List.splitAt(y + 1)
      })
    })
    ->Belt.Option.map(((head, tail)) => {
      Belt.List.concat(head, Belt.List.concat(list{state.count}, tail))
    }) {
    | Some(list) => {
        ...state,
        count: state.count + 1,
        indices: list,
        cells: {
          state.cells->Belt.HashMap.Int.set(
            state.count,
            defaultCell(~cell_type=CellBase.Markdown, ~index={state.count}, ()),
          )
          Js.log(defaultCell(~cell_type=CellBase.Markdown, ~index={state.count}, ()))
          state.cells
        },
      }
    | None => {
        ...state,
        count: state.count + 1,
        indices: Belt.List.concat(state.indices, list{state.count}),
        cells: {
          state.cells->Belt.HashMap.Int.set(
            state.count,
            defaultCell(~cell_type=CellBase.Markdown, ~index={state.count}, ()),
          )
          state.cells
        },
      }
    }
  | DeleteCell(i) =>
    switch i->Belt.Option.flatMap(i =>
      state.indices
      ->Belt.List.mapWithIndex((index, x) => {
        if x == i {
          Some(index)
        } else {
          None
        }
      })
      ->Belt.List.getBy(y => Belt.Option.isSome(y))
      ->Belt.Option.flatMap(x => {
        x->Belt.Option.flatMap(y => {
          state.indices->Belt.List.splitAt(y)
        })
      })
      ->Belt.Option.flatMap(((head, tail)) => {
        Belt.List.tail(tail)->Belt.Option.map(z => {
          state.cells->Belt.HashMap.Int.remove(i)
          Belt.List.concat(head, z)
        })
      })
    ) {
    | Some(list) => {...state, cells: state.cells, indices: list}
    | None => state
    }
  | MoveCellUp(i) =>
    switch i
    ->Belt.Option.flatMap(i =>
      state.indices
      ->Belt.List.mapWithIndex((index, x) => {
        if x == i {
          Some(index)
        } else {
          None
        }
      })
      ->Belt.List.getBy(y => Belt.Option.isSome(y))
    )
    ->Belt.Option.flatMap(x => {
      x->Belt.Option.flatMap(y => {
        state.indices->Belt.List.splitAt(y - 1)
      })
    })
    ->Belt.Option.map(((head, tail)) => {
      switch tail {
      | list{} => head
      | list{cell} => Belt.List.concat(head, list{cell})
      | list{cell, next} => Belt.List.concat(head, list{next, cell})
      | list{cell, next, ...newtail} =>
        Belt.List.concat(head, Belt.List.concat(list{next, cell}, newtail))
      }
    }) {
    | Some(list) => {...state, indices: list}
    | None => state
    }
  | MoveCellDown(i) =>
    switch i
    ->Belt.Option.flatMap(i =>
      state.indices
      ->Belt.List.mapWithIndex((index, x) => {
        if x == i {
          Some(index)
        } else {
          None
        }
      })
      ->Belt.List.getBy(y => Belt.Option.isSome(y))
    )
    ->Belt.Option.flatMap(x => {
      x->Belt.Option.flatMap(y => {
        state.indices->Belt.List.splitAt(y)
      })
    })
    ->Belt.Option.map(((head, tail)) => {
      switch tail {
      | list{} => head
      | list{cell} => Belt.List.concat(head, list{cell})
      | list{cell, next} => Belt.List.concat(head, list{next, cell})
      | list{cell, next, ...newtail} =>
        Belt.List.concat(head, Belt.List.concat(list{next, cell}, newtail))
      }
    }) {
    | Some(list) => {...state, indices: list}
    | None => state
    }
  | OpenNotebook(newState) => newState
  | DisplayCellOutput(i, outputs, display_input) =>
    let cellStateOpt = state.cells->Belt.HashMap.Int.get(i)
    cellStateOpt
    ->Belt.Option.map(cellState => {
      cellState.outputs.contents = outputs
      cellState.display_input.contents = display_input
      ()
    })
    ->Belt.Option.getWithDefault()
    {...state, cells: state.cells}
  | ChangeNotebookName(name) => {...state, name: name}
  | ClearCodeOutput(i) => {
      let _ = i->Belt.Option.flatMap(k =>
        state.indices
        ->Belt.List.get(k)
        ->Belt.Option.flatMap(j => state.cells->Belt.HashMap.Int.get(j))
        ->Belt.Option.map(cellState => {
          switch cellState.cell_type {
          | Code => cellState.outputs.contents = [TextPlain("")]
          | Markdown => ()
          }
        })
      )
      {...state, cells: state.cells}
    }
  | ClearAllCodeOutput => {
      state.cells->Belt.HashMap.Int.forEach((_key, cellState) => {
        switch cellState.cell_type {
        | Code => cellState.outputs.contents = [TextPlain("")]
        | Markdown => ()
        }
      })
      {...state, cells: state.cells}
    }
  }
}

let evalCell = (~cellState: cellState, ~notebookDispatch) =>
  switch cellState.cell_type {
  | Code =>
    WeblabInterpreter.evalCell(cellState.source.contents)
    |> Js.Promise.then_(output =>
      Js.Promise.resolve(
        notebookDispatch(DisplayCellOutput(cellState.index, [output], "inline-block")),
      )
    )
    |> Js.Promise.catch(_ =>
      Js.Promise.resolve(
        notebookDispatch(
          DisplayCellOutput(
            cellState.index,
            [CellBase.TextPlain("Could not evaluate code input")],
            "inline-block",
          ),
        ),
      )
    )
  | Markdown =>
    WeblabMarkdown.parse(cellState.source.contents)
    |> Js.Promise.then_(output =>
      Js.Promise.resolve(
        notebookDispatch(DisplayCellOutput(cellState.index, [CellBase.TextPlain(output)], "none")),
      )
    )
    |> Js.Promise.catch(_ =>
      Js.Promise.resolve(
        notebookDispatch(
          DisplayCellOutput(
            cellState.index,
            [CellBase.TextPlain("Could not parse markdown input")],
            "inline-block",
          ),
        ),
      )
    )
  }
