open Jest
open ReactTestUtils

RangeMock.setup()

describe("Cell test", () => {
  open Expect
  // Here, we prepare an empty ref that will eventually be
  // the root node for our test
  let container = ref(None)

  // Before each test, creates a new div root
  beforeEach(prepareContainer(container))
  // After each test, removes the div
  afterEach(cleanupContainer(container))

  test("can render DOM elements", () => {
    // The following function gives us the div
    let container = getContainer(container)

    let cellState = NotebookBase.defaultCell(~source="let a = 5; a", ())
    let selectedCell = %raw(`undefined`)
    let notebookDispatch = %raw(`undefined`)
    // Most of the ReactTestUtils API is there
    act(() => {
      ReactDOM.render(<Cell cellState selectedCell notebookDispatch />, container)
    })

    expect(
      container
      // We also provide some basic DOM querying utilities
      // to ease your tests
      ->DOM.findBySelectorAndPartialTextContent("span", "let")
      ->Belt.Option.isSome,
    ) |> toBe(true)
  })
})
