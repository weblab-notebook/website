open Jest

describe("Test", () => {
  open Expect

  let testOutputJSON: NotebookFormat.outputJSON = {
    output_type: "display_data",
    metadata: Js.Dict.empty(),
    data: Js.Dict.fromArray([("text/plain", "success")]),
  }
  let result = NotebookFormat.convertOutputJSONtoRE(testOutputJSON)

  test("convertOutputJSONtoRE", () => {
    expect(result) |> toEqual(Ok(CellBase.TextPlain("success")))
  })

  let testCellState = NotebookBase.defaultCell(
    ~source="let a = 5; a",
    ~outputs=[CellBase.TextPlain("5")],
    (),
  )
  let result = NotebookFormat.convertCellStateToJSONCell(testCellState)

  test("convertCellStateToJSONCell cell_type", () => {
    expect(result.cell_type) |> toBe("code")
  })
  test("convertCellStateToJSONCell source", () => {
    expect(result.source[0]) |> toBe("let a = 5; a")
  })
  test("convertCellStateToJSONCell outputs", () => {
    expect(result.outputs->Belt.Option.map(arr => arr[0].data->Js.Dict.get("text/plain"))) |> toBe(
      Some(Some("5")),
    )
  })
})
