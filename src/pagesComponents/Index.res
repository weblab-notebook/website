// Import the notebook to display as JSON
@module("/src/notebooks/welcome.json")
external welcomeNotebook: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(welcomeNotebook) {
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
        content="Weblab lets you write and evaluate Javascript in an interactive notebook. It gives you a great environment to build Machine learning and Data Science applications."
      />
    </ReactHelmet>
    <Notebook location name="welcome.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "Index")

let default = make
