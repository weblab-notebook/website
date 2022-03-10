open CellBase

let evalCell = (
  ~cellState: NotebookBase.cellState,
  ~cellDispatch,
  ~setSpinner,
  ~ref: React.ref<'a>,
) =>
  switch cellState.cell_type {
  | Code =>
    setSpinner(_ => Some())
    WeblabInterpreter.evalCell(cellState.source.contents)
    |> Js.Promise.then_(output => {
      setSpinner(_ => None)
      ref.current
      ->Js.Nullable.toOption
      ->Belt.Option.flatMap(Webapi.Dom.Element.nextElementSibling)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.lastElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.asHtmlElement)
      ->Belt.Option.map(element => {
        element->Webapi.Dom.HtmlElement.focus
      })
      ->Belt.Option.getWithDefault()
      Js.Promise.resolve(cellDispatch(DisplayCellOutput([output], "inline-block")))
    })
    |> Js.Promise.catch(_ => {
      Js.Promise.resolve(
        cellDispatch(
          DisplayCellOutput([TextPlain("Could not evaluate code input")], "inline-block"),
        ),
      )
    })
  | Markdown =>
    WeblabMarkdown.parse(cellState.source.contents)
    |> Js.Promise.then_(output => {
      ref.current
      ->Js.Nullable.toOption
      ->Belt.Option.flatMap(Webapi.Dom.Element.nextElementSibling)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.lastElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.firstElementChild)
      ->Belt.Option.flatMap(Webapi.Dom.Element.asHtmlElement)
      ->Belt.Option.map(element => {
        element->Webapi.Dom.HtmlElement.focus
      })
      ->Belt.Option.getWithDefault()
      Js.Promise.resolve(cellDispatch(DisplayCellOutput([TextPlain(output)], "none")))
    })
    |> Js.Promise.catch(_ => {
      Js.Promise.resolve(
        cellDispatch(
          DisplayCellOutput([TextPlain("Could not parse markdown input")], "inline-block"),
        ),
      )
    })
  }

@react.component
let make = (
  ~cellState: NotebookBase.cellState,
  ~notebookDispatch: NotebookBase.notebookActions => unit,
  ~selectedCell: React.ref<option<int>>,
) => {
  let (state, cellDispatch) = React.useReducer(
    cellReducer,
    {
      cell_type: cellState.cell_type,
      source: cellState.source,
      outputs: cellState.outputs,
      display_input: cellState.display_input,
    },
  )
  let (focused, setFocused) = React.useState(_ => None)
  let (hover, setHover) = React.useState(() => None)
  let (spinner, setSpinner) = React.useState(() => None)

  let theme = Mui.Core.useTheme()

  let darkMode = Theme.getMode(theme)

  let ref = React.useRef(Js.Nullable.null)
  let setRef = element => ref.current = element

  <Mui.ListItem
    ref={ReactDOM.Ref.callbackDomRef(setRef)}
    key={"li_" ++ string_of_int(cellState.index)}
    dense=true
    button=false
    style={ReactDOM.Style.make(~display="block", ())}>
    <div onMouseOver={_ => setHover(_ => Some())} onMouseLeave={_ => setHover(_ => None)}>
      <Mui.Box style={ReactDOM.Style.make(~position="relative", ())}>
        <Mui.TextField
          variant=#outlined
          style={ReactDOM.Style.make(
            ~display=state.display_input.contents,
            ~backgroundColor=theme.palette.action.hover,
            ~fontFamily="Noto Mono",
            (),
          )}
          color={switch darkMode {
          | Theme.Light => #primary
          | Theme.Dark => #secondary
          }}
          fullWidth=true
          multiline=true
          margin=#dense
          \"InputProps"={
            "inputComponent": CodeMirror.MyCodeMirror.make,
            "inputProps": {
              "component": CodeMirror.make,
              "source": state.source,
              "cell_type": state.cell_type,
              "cellDispatch": cellDispatch,
              "onKeyDown": {
                evt =>
                  if (
                    ReactEvent.Keyboard.key(evt) == "Enter" &&
                      ReactEvent.Keyboard.shiftKey(evt) == true
                  ) {
                    ReactEvent.Keyboard.preventDefault(evt)
                    let _ = evalCell(~cellState, ~cellDispatch, ~setSpinner, ~ref)
                  }
              },
              "onFocus": {
                _evt => {
                  setFocused(_ => Some())
                  selectedCell.current = Some(cellState.index)
                }
              },
              "onBlur": {
                _evt => setFocused(_ => None)
              },
              "darkMode": switch darkMode {
              | Theme.Light => false
              | Theme.Dark => true
              },
            },
          }
        />
        {switch (focused, hover, cellState.cell_type) {
        | (None, None, _) => React.null
        | (None, Some(_), Markdown) => React.null
        | (_, _, _) =>
          <Mui.Box
            zIndex=5
            style={ReactDOM.Style.make(~position="absolute", ~bottom="-16px", ~left="16px", ())}>
            <Mui.ButtonGroup
              size=#small
              style={ReactDOM.Style.make(~backgroundColor=theme.palette.background.paper, ())}>
              <Mui.Tooltip title={"Run"->React.string}>
                <Mui.Button
                  onMouseDown={_ => {
                    let _ = evalCell(~cellState, ~cellDispatch, ~setSpinner, ~ref)
                  }}
                  style={ReactDOM.Style.make(
                    ~color={
                      switch darkMode {
                      | Theme.Light => theme.palette.primary.main
                      | Theme.Dark => theme.palette.text.primary
                      }
                    },
                    (),
                  )}>
                  <Images.PlayArrow fontSize="small" />
                </Mui.Button>
              </Mui.Tooltip>
              <Mui.Tooltip title={"Move cell up"->React.string}>
                <Mui.Button
                  onMouseDown={_ => notebookDispatch(NotebookBase.MoveCellUp(selectedCell.current))}
                  color={switch darkMode {
                  | Theme.Light => #primary
                  | Theme.Dark => #default
                  }}>
                  <Images.ArrowUpward fontSize="small" />
                </Mui.Button>
              </Mui.Tooltip>
              <Mui.Tooltip title={"Move cell down"->React.string}>
                <Mui.Button
                  onMouseDown={_ =>
                    notebookDispatch(NotebookBase.MoveCellDown(selectedCell.current))}
                  color={switch darkMode {
                  | Theme.Light => #primary
                  | Theme.Dark => #default
                  }}>
                  <Images.ArrowDownward fontSize="small" />
                </Mui.Button>
              </Mui.Tooltip>
              <Mui.Tooltip title={React.string("Clear output")}>
                <Mui.Button
                  onMouseDown={_ =>
                    notebookDispatch(NotebookBase.ClearCodeOutput(selectedCell.current))}
                  color={switch darkMode {
                  | Theme.Light => #primary
                  | Theme.Dark => #default
                  }}>
                  <Images.Clear fontSize="small" />
                </Mui.Button>
              </Mui.Tooltip>
              <Mui.Tooltip title={React.string("Delete cell")}>
                <Mui.Button
                  onMouseDown={_ => notebookDispatch(NotebookBase.DeleteCell(selectedCell.current))}
                  color={switch darkMode {
                  | Theme.Light => #primary
                  | Theme.Dark => #default
                  }}>
                  <Images.Delete fontSize="small" />
                </Mui.Button>
              </Mui.Tooltip>
            </Mui.ButtonGroup>
          </Mui.Box>
        }}
      </Mui.Box>
      {switch cellState.cell_type {
      | Code =>
        switch spinner {
        | Some(_) =>
          <Mui.CircularProgress
            size={Mui.CircularProgress.Size.int(24)} style={ReactDOM.Style.make(~margin="8px", ())}
          />
        | None =>
          React.array(
            cellState.outputs.contents->Belt.Array.mapWithIndex((i, output) => {
              switch Js.Null.return(outputToReactElement(output))->Js.Null.toOption {
              | Some(element) =>
                <Mui.Typography
                  variant=#body1
                  key={"output_" ++ string_of_int(cellState.index) ++ "_" ++ string_of_int(i)}
                  style={ReactDOM.Style.make(
                    ~padding="8px",
                    ~marginTop="8px",
                    ~maxHeight="512px",
                    ~overflow="auto",
                    ~whiteSpace="pre-wrap",
                    ~fontFamily="Noto Mono",
                    (),
                  )}>
                  {element}
                </Mui.Typography>
              | None => React.null
              }
            }),
          )
        }
      | Markdown =>
        React.array([
          <div
            key={"div_" ++ string_of_int(cellState.index)}
            onDoubleClick={evt => {
              ReactEvent.Mouse.preventDefault(evt)
              cellDispatch(ResetCellOutput)
            }}>
            <Mui.Box
              style={ReactDOM.Style.make(
                ~fontFamily="Noto Serif",
                ~overflow="inherit",
                ~fontSize="16px",
                (),
              )}>
              {HtmlReactParser.htmlReactParser(outputToString(cellState.outputs.contents[0]))}
            </Mui.Box>
          </div>,
        ])
      }}
      <Mui.Box style={ReactDOM.Style.make(~position="relative", ())}>
        <Mui.Divider
          light=true
          style={ReactDOM.Style.make(
            ~opacity=switch hover {
            | Some(_) => "1"
            | None => "0"
            },
            (),
          )}
        />
        <Mui.Box
          zIndex=3
          style={ReactDOM.Style.make(
            ~position="absolute",
            ~width="100%",
            ~margin="0 auto",
            ~left="0",
            ~right="0",
            ~top="-12px",
            ~textAlign="center",
            ~visibility=switch hover {
            | Some(_) => "visible"
            | None => "hidden"
            },
            (),
          )}>
          <Mui.ButtonGroup
            size=#small
            style={ReactDOM.Style.make(~backgroundColor=theme.palette.background.paper, ())}>
            <Mui.Tooltip title={"Add code cell"->React.string}>
              <Mui.Button
                onMouseDown={_ => notebookDispatch(NotebookBase.AddCodeCell(Some(cellState.index)))}
                color={switch darkMode {
                | Theme.Light => #primary
                | Theme.Dark => #default
                }}>
                <Images.Code fontSize="small" />
              </Mui.Button>
            </Mui.Tooltip>
            <Mui.Tooltip title={"Add markdown cell"->React.string}>
              <Mui.Button
                onMouseDown={_ =>
                  notebookDispatch(NotebookBase.AddMarkdownCell(Some(cellState.index)))}
                color={switch darkMode {
                | Theme.Light => #primary
                | Theme.Dark => #default
                }}>
                <Images.Subject fontSize="small" />
              </Mui.Button>
            </Mui.Tooltip>
          </Mui.ButtonGroup>
        </Mui.Box>
      </Mui.Box>
    </div>
  </Mui.ListItem>
}
