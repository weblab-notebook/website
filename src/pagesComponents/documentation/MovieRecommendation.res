// Import the notebook to display as JSON
@module("/src/notebooks/movie_recommendation.json")
external movieRecommendation: NotebookFormat.notebookJSON = "default"

// Convert the JSON to a Rescript notebook type
let welcomeNotebook = switch NotebookFormat.convertNotebookJSONtoRESync(movieRecommendation) {
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
        content="Train a neural network with collaborative filtering to give movie recommendations to users based on their ratings of movies they have already watched."
      />
    </BsReactHelmet>
    <Notebook location name="movie_recommendation.ijsnb" initialIndices initialCells />
  </>
}

React.setDisplayName(make, "movieRecommendation")

let default = make
