// Import the notebook to display as JSON
@module("/src/notebooks/plotly_getting_started.json")
external plotlyGettingStarted: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(plotlyGettingStarted) {
| Ok(x) => x
| Error(err) => {
    Errors.alert(err->Errors.getErrorMessage)
    Belt.Array.make(1, NotebookBase.defaultCell())
  }
}

// Compute indices and cells from the loaded notebook
let initialIndices = welcomeNotebook->Belt.Array.mapWithIndex((i, _) => i)->Belt.List.fromArray

let initialCells =
  welcomeNotebook->Belt.Array.mapWithIndex((i, e) => (i, e))->Belt.HashMap.Int.fromArray

// Create a React component that contains the notebook
@react.component
let make = (~location: Webapi.Dom.Location.t) => {
  <>
    <BsReactHelmet>
      <meta name="description" content="Getting started with visualizations using Plotly." />
    </BsReactHelmet>
    <Notebook location name="plotly_getting_started.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "PlotlyGettingStarted")

let default = make
