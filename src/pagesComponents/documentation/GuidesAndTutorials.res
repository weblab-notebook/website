// Import the notebook to display as JSON
@module("/src/notebooks/guides_and_tutorials.json")
external guidesAndTutorials: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(guidesAndTutorials) {
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
        content="Find guides and tutorials regarding topics such as machine learning, data science, data visualization, and programming."
      />
    </ReactHelmet>
    <Notebook location name="guides_and_tutorials.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "GuidesAndTutorials")

let default = make
