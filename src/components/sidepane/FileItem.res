let transOri = Mui.Menu.TransformOrigin.make(
  ~horizontal=Mui.Menu.Horizontal.int(-50),
  ~vertical=Mui.Menu.Vertical.int(0),
  (),
)

@react.component
let make = (
  ~name,
  ~notebookName,
  ~filesState: FilesBase.filesState,
  ~filesDispatch,
  ~notebookDispatch,
) => {
  let (state, dispatch) = React.useReducer(FileItemBase.reducer, {name: name, change: false})
  let (anchorEl, setAnchorEl) = React.useState(() => None)
  let (hover, setHover) = React.useState(() => None)

  let handleClick = event => {
    let target = event->ReactEvent.Mouse.currentTarget
    setAnchorEl(_x => Some(target))
  }

  let handleClose = (_event, _reason) => {
    setAnchorEl(_x => None)
  }

  let session = React.useContext(Session.SessionContext.context)

  let theme = Mui.Core.useTheme()
  let darkMode = Theme.getMode(theme)

  <Mui.ListItem
    style={ReactDOM.Style.make(
      ~color={
        switch darkMode {
        | Theme.Light => theme.palette.primary.main
        | Theme.Dark => theme.palette.text.primary
        }
      },
      (),
    )}>
    <Mui.Box
      display={Mui.Box.Value.string("flex")}
      flexDirection={Mui.Box.Value.string("row")}
      alignItems={Mui.Box.Value.string("center")}
      width={Mui.Box.Value.string("100%")}
      overflow={Mui.Box.Value.string("hidden")}>
      <Images.Description fontSize="small" />
      {if !state.change {
        <div
          onMouseOver={_ => setHover(_ => Some())}
          onMouseOut={_ => setHover(_ => None)}
          style={ReactDOM.Style.make(~width="100%", ())}>
          <Mui.Typography variant=#body2 style={ReactDOM.Style.make(~marginLeft="4px", ())}>
            <div onDoubleClick={_ => dispatch(FileItemBase.ShowTextfield)}>
              {name->React.string}
            </div>
          </Mui.Typography>
          <Mui.Box
            style={ReactDOM.Style.make(
              ~position="absolute",
              ~right="0",
              ~top="0",
              ~zIndex="45",
              ~backgroundColor=theme.palette.background.paper,
              ~visibility=switch hover {
              | Some(_) => "visible"
              | None => "hidden"
              },
              (),
            )}>
            <Mui.Tooltip title={React.string("More")}>
              <Mui.Button
                size=#small
                color={switch darkMode {
                | Theme.Light => #primary
                | Theme.Dark => #default
                }}
                onClick=handleClick>
                <Images.MoreHoriz fontSize="small" />
              </Mui.Button>
            </Mui.Tooltip>
            <Mui.Menu
              \"open"={anchorEl->Belt.Option.isSome}
              keepMounted=true
              variant=#menu
              anchorEl={Mui.Any.make(anchorEl)}
              transformOrigin=transOri
              onClose={handleClose}
              transitionDuration={Mui.Menu.TransitionDuration.float(0.2)}
              \"MenuListProps"={"dense": true, "disablePadding": true}>
              <Mui.MenuItem
                onClick={evt => {
                  handleClose(evt, "")
                  FilesBase.fileOpen(~name, ~files=filesState.files, ~notebookDispatch)
                }}
                dense=true>
                <Mui.ListItemIcon> <Images.OpenInNew fontSize="small" /> </Mui.ListItemIcon>
                <Mui.ListItemText> {"Open"->React.string} </Mui.ListItemText>
              </Mui.MenuItem>
              <Mui.MenuItem
                onClick={evt => {
                  handleClose(evt, "")
                }}
                dense=true>
                <Mui.ListItemIcon> <Images.SaveAlt fontSize="small" /> </Mui.ListItemIcon>
                <Mui.ListItemText>
                  <a
                    download=name
                    href={"data:application/json," ++
                    Js.Global.encodeURIComponent(
                      FilesBase.get(filesState.files, name)
                      ->Belt.Result.map(file =>
                        switch file {
                        | FilesBase.Notebook(text) => text
                        | FilesBase.PythonNotebook(text) => text
                        | FilesBase.PlainText(text) => text
                        | FilesBase.JSON(text) => text
                        }
                      )
                      ->Belt.Result.getWithDefault(""),
                    )}
                    style={ReactDOM.Style.make(
                      ~textDecoration="none",
                      ~color=theme.palette.text.primary,
                      ~fontSize="14px",
                      (),
                    )}>
                    {"Download"->React.string}
                  </a>
                </Mui.ListItemText>
              </Mui.MenuItem>
              {switch session {
              | Some(session) =>
                <Mui.MenuItem
                  onClick={evt => {
                    handleClose(evt, "")
                    let _ = HubBase.shareFileOnNotebookHub(
                      session,
                      filesState.files,
                      state.name,
                    ) |> Js.Promise.catch(error => {
                      Error(Errors.fromPromiseError(error))->Errors.alertError
                      Js.Promise.resolve()
                    })
                  }}
                  dense=true>
                  <Mui.ListItemIcon> <Images.CloudUpload fontSize="small" /> </Mui.ListItemIcon>
                  <Mui.ListItemText> {"Share on NotebookHub"->React.string} </Mui.ListItemText>
                </Mui.MenuItem>
              | None => React.null
              }}
              <Mui.MenuItem
                onClick={evt => {
                  handleClose(evt, "")
                  filesDispatch(FilesBase.DeleteFile(name))
                }}
                dense=true>
                <Mui.ListItemIcon> <Images.Delete fontSize="small" /> </Mui.ListItemIcon>
                <Mui.ListItemText> {"Delete"->React.string} </Mui.ListItemText>
              </Mui.MenuItem>
            </Mui.Menu>
          </Mui.Box>
        </div>
      } else {
        <Mui.TextField
          value={Mui.TextField.Value.string(state.name)}
          size=#small
          margin=#none
          variant=#outlined
          \"InputProps"={
            "onKeyDown": evt => {
              if (
                ReactEvent.Keyboard.key(evt) == "Enter" || ReactEvent.Keyboard.key(evt) == "Escape"
              ) {
                dispatch(FileItemBase.Send)
                if name != state.name {
                  filesDispatch(FilesBase.ChangeName(name, state.name))
                  if state.name == notebookName {
                    notebookDispatch(NotebookBase.ChangeNotebookName(state.name))
                  }
                }
              }
            },
          }
          onChange={evt => {
            dispatch(ChangeName(ReactEvent.Form.target(evt)["value"]))
          }}
        />
      }}
    </Mui.Box>
  </Mui.ListItem>
}
