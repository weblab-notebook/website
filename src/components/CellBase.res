type output =
  | TextPlain(string)
  | TextHTML(string)
  | ImagePNG(string)

type cell_type =
  | Code
  | Markdown

// The state of each cell is stored in the parent Notebook component. To have a convenient access to its state, each Cell gets an own state record.
// To ensure that the cellState in the Notebook component and each state in the Cell component are equal, the refs of the cellState are copied to the state in each Cell.
// This way the cellState in the Notebook component and the state in the Cell component point the the identical ref (which is an object) and therefore they are always equal.
// However, to force a rerender of the Cell component when its state changes, the cellReducer has to always return a new state record.

type state = {
  cell_type: cell_type,
  source: ref<string>,
  outputs: ref<array<output>>,
  display_input: ref<string>,
}

let outputToString = output => {
  switch output {
  | TextPlain(text) => text
  | TextHTML(text) => text
  | ImagePNG(text) => text
  }
}

let outputToReactElement = output => {
  switch output {
  | TextPlain(text) =>
    if text != "" {
      text->React.string
    } else {
      React.null
    }
  | TextHTML(text) => text->HtmlReactParser.htmlReactParser
  | ImagePNG(text) => text->React.string
  }
}

type cellAction =
  | ChangeCellText(string)
  | DisplayCellOutput(array<output>, string)
  | ResetCellOutput
  | HideInput

let cellReducer = (state, action) => {
  switch action {
  | ChangeCellText(input) => {
      state.source.contents = input
      {...state, cell_type: state.cell_type}
    }
  | DisplayCellOutput(outputs, display_input) => {
      state.outputs.contents = outputs
      state.display_input.contents = display_input
      {...state, cell_type: state.cell_type}
    }
  | ResetCellOutput => {
      state.outputs.contents = [TextPlain("")]
      state.display_input.contents = "inline-block"
      {...state, cell_type: state.cell_type}
    }
  | HideInput => {
      state.display_input.contents = "none"
      {...state, cell_type: state.cell_type}
    }
  }
}
