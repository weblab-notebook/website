// Import the notebook to display as JSON
@module("/src/notebooks/getting_started.json")
external gettingStarted: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(gettingStarted) {
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
      <meta
        name="description"
        content="Getting started guide if you are new to Jupyter/Weblab notebooks, Javascript, or programming in general."
      />
    </BsReactHelmet>
    <Notebook location name="getting_started.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "GettingStarted")

let default = make
