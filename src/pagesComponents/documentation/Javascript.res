// Import the notebook to display as JSON
@module("/src/notebooks/javascript.json")
external javascript: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(javascript) {
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
      <meta
        name="description"
        content="Find information on importing javascript modules and asynchronous programming."
      />
    </ReactHelmet>
    <Notebook location name="javascript.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "Javascript")

let default = make
