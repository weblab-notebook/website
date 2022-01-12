// Import the notebook to display as JSON
@module("/src/notebooks/regression_training.json")
external regressionTraining: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(regressionTraining) {
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
        content="Prediction of 2D data with Linear regression model from Tensorflow.js."
      />
    </BsReactHelmet>
    <Notebook location name="regression_training.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "RegressionTraining")

let default = make
