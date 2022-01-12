// Import the notebook to display as JSON
@module("/src/notebooks/transfer_learning_mobilenet.json")
external transferLearningMobilenet: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(transferLearningMobilenet) {
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
        name="description" content="Image Classification with Transfer Learning and MobileNet v2."
      />
    </BsReactHelmet>
    <Notebook location name="transfer_learning_mobilenet.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "TransferLearningMobilenet")

let default = make
