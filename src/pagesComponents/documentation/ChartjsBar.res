// Import the notebook to display as JSON
@module("/src/notebooks/chartjs_bar.json")
external chartjsBar: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(chartjsBar) {
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
    <ReactHelmet>
      <meta name="description" content="Create bar plots with chart.js." />
    </ReactHelmet>
    <Notebook location name="chartjs_bar_plot.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "TFJSExample1")

let default = make
