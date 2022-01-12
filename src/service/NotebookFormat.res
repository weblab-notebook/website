type outputJSON = {
  output_type: string,
  metadata: Js.Dict.t<string>,
  data: Js.Dict.t<string>,
}

type cellJSON = {
  cell_type: string,
  execution_count: option<int>,
  metadata: Js.Dict.t<string>,
  source: array<string>,
  outputs: option<array<outputJSON>>,
}

type notebookJSON = {
  nbformat: int,
  nbformat_minor: int,
  metadata: Js.Dict.t<Js.Dict.t<string>>,
  cells: array<cellJSON>,
}

@scope("JSON") @val
external parseCell: string => notebookJSON = "parse"

let parseJSONNotebook = json => {
  try {
    Ok(parseCell(json))
  } catch {
  | Js.Exn.Error(_) => Error(Errors.NoRegularJSONNotebook)
  }
}

let convertOutputJSONtoRE = jSONoutput => {
  let dataOpt = jSONoutput.data->Js.Dict.get("text/plain")
  switch dataOpt {
  | Some(data) => Ok(CellBase.TextPlain(data))
  | None => {
      let dataOpt = jSONoutput.data->Js.Dict.get("text/html")
      switch dataOpt {
      | Some(data) => Ok(CellBase.TextHTML(data))
      | None => {
          let dataOpt = jSONoutput.data->Js.Dict.get("image/png")
          switch dataOpt {
          | Some(data) => Ok(CellBase.ImagePNG(data))
          | None => Error(Errors.UnsupportedOutputType)
          }
        }
      }
    }
  }
}

let convertCellTypeJSONtoRE = cell_type => {
  if cell_type == "code" {
    Ok(CellBase.Code)
  } else if cell_type == "markdown" {
    Ok(CellBase.Markdown)
  } else {
    Error(Errors.UnsupportedCellType)
  }
}

let getDisplayInputFromCellType = cell_type => {
  switch cell_type {
  | CellBase.Code => "inline-block"
  | CellBase.Markdown => "none"
  }
}

let convertOutputREtoJSON = output => {
  switch output {
  | CellBase.TextPlain(text) => {
      output_type: "display_data",
      metadata: Js.Dict.empty(),
      data: Js.Dict.fromArray([("text/plain", text)]),
    }
  | CellBase.TextHTML(text) => {
      output_type: "display_data",
      metadata: Js.Dict.empty(),
      data: Js.Dict.fromArray([("text/html", text)]),
    }
  | CellBase.ImagePNG(text) => {
      output_type: "display_data",
      metadata: Js.Dict.empty(),
      data: Js.Dict.fromArray([("image/png", text)]),
    }
  }
}

let convertCellTypeREtoJSON = cell_type => {
  switch cell_type {
  | CellBase.Code => "code"
  | CellBase.Markdown => "markdown"
  }
}

@scope(("process", "env")) @val
external markdownOutput: string = "GATSBY_MARKDOWN_OUTPUT"

let convertCellStateToJSONCell = (state: NotebookBase.cellState) => {
  switch state.cell_type {
  | CellBase.Code => {
      cell_type: convertCellTypeREtoJSON(state.cell_type),
      execution_count: Some(0),
      metadata: Js.Dict.empty(),
      source: [state.source.contents],
      outputs: Some(
        state.outputs.contents->Belt.Array.map(output => convertOutputREtoJSON(output)),
      ),
    }
  | CellBase.Markdown => {
      cell_type: convertCellTypeREtoJSON(state.cell_type),
      execution_count: None,
      metadata: Js.Dict.empty(),
      source: [state.source.contents],
      outputs: if markdownOutput == "true" {
        Some(state.outputs.contents->Belt.Array.map(output => convertOutputREtoJSON(output)))
      } else {
        None
      },
    }
  }
}

let convertNotebookJSONtoRE = jsonNotebook => {
  jsonNotebook.cells
  ->Belt.Array.mapWithIndex((i, jsonCell) => {
    let outputs =
      jsonCell.outputs
      ->Belt.Option.map(outputs =>
        Js.Promise.resolve(
          outputs
          ->Belt.Array.map(output => convertOutputJSONtoRE(output))
          ->EveryResult.everyArrayResult,
        )
      )
      ->Belt.Option.getWithDefault(
        WeblabMarkdown.parse(
          Js.String.concatMany(jsonCell.source, ""),
        ) |> Js.Promise.then_(output => Js.Promise.resolve(Ok([CellBase.TextPlain(output)]))),
      )
    outputs |> Js.Promise.then_(outputs => {
      let cell_type = convertCellTypeJSONtoRE(jsonCell.cell_type)
      Js.Promise.resolve(
        (outputs, cell_type)
        ->EveryResult.everyTuple2Result
        ->Belt.Result.map(x =>
          NotebookBase.defaultCell(
            ~cell_type=snd(x),
            ~metadata=Js.Json.stringifyAny(jsonCell.metadata)->Belt.Option.getWithDefault(""),
            ~source=Js.String.concatMany(jsonCell.source, ""),
            ~outputs=fst(x),
            ~index=i,
            ~display_input=getDisplayInputFromCellType(snd(x)),
            (),
          )
        ),
      )
    })
  })
  ->Js.Promise.all |> Js.Promise.then_(x => Js.Promise.resolve(x->EveryResult.everyArrayResult))
}

let notebookOpen = (name, jsonNotebook, notebookDispatch) => {
  let _ =
    (convertNotebookJSONtoRE(jsonNotebook), WeblabInterpreter.resetEnvs())->Js.Promise.all2
    |> Js.Promise.then_(x => {
      Js.Promise.resolve(
        fst(x)
        ->Belt.Result.map(arr => {
          let cells = arr->Belt.Array.mapWithIndex((i, e) => (i, e))->Belt.HashMap.Int.fromArray
          let indices = arr->Belt.Array.mapWithIndex((i, _) => i)->Belt.List.fromArray
          notebookDispatch(
            NotebookBase.OpenNotebook({
              name: name,
              count: arr->Belt.Array.length,
              indices: indices,
              cells: cells,
            }),
          )
        })
        ->Errors.alertError,
      )
    })
    |> Js.Promise.catch(x => {
      Errors.alert("Error: Failed to open notebook.")
      Js.Promise.reject(Js.Exn.anyToExnInternal(x))
    })
}

let notebookCopytoString = (
  indices: Belt.List.t<int>,
  cells: Belt.HashMap.Int.t<NotebookBase.cellState>,
) => {
  let cellsJSON =
    indices
    ->Belt.List.toArray
    ->Belt.Array.map(i => cells->Belt.HashMap.Int.get(i))
    ->Belt.Array.keepMap(x => x)
    ->Belt.Array.map(cellState => convertCellStateToJSONCell(cellState))
  let notebookJSON = {
    nbformat: 4,
    nbformat_minor: 0,
    metadata: Js.Dict.fromArray([
      ("kernel_info", Js.Dict.fromArray([("name", "Weblab")])),
      ("language_info", Js.Dict.fromArray([("name", "javascript")])),
    ]),
    cells: cellsJSON,
  }
  Belt.Option.getWithDefault(Js.Json.stringifyAny(notebookJSON), "Error: Failed to parse notebook.")
}

let convertNotebookJSONtoRESync = jsonNotebook => {
  jsonNotebook.cells
  ->Belt.Array.mapWithIndex((i, jsonCell) => {
    let outputs =
      jsonCell.outputs
      ->Belt.Option.map(outputs =>
        outputs
        ->Belt.Array.map(output => convertOutputJSONtoRE(output))
        ->EveryResult.everyArrayResult
      )
      ->Belt.Option.getWithDefault(Ok([CellBase.TextPlain("")]))
    let cell_type = convertCellTypeJSONtoRE(jsonCell.cell_type)
    (outputs, cell_type)
    ->EveryResult.everyTuple2Result
    ->Belt.Result.map(x =>
      NotebookBase.defaultCell(
        ~cell_type=snd(x),
        ~metadata=Js.Json.stringifyAny(jsonCell.metadata)->Belt.Option.getWithDefault(""),
        ~source=Js.String.concatMany(jsonCell.source, ""),
        ~outputs=fst(x),
        ~index=i,
        ~display_input=getDisplayInputFromCellType(snd(x)),
        (),
      )
    )
  })
  ->EveryResult.everyArrayResult
}
