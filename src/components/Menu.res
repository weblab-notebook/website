let transOri = Mui.Menu.TransformOrigin.make(
  ~horizontal=Mui.Menu.Horizontal.int(0),
  ~vertical=Mui.Menu.Vertical.int(-36),
  (),
)

@react.component
let make = (~notebookState: NotebookBase.notebookState, ~notebookDispatch, ~filesDispatch) => {
  let (anchorEl, setAnchorEl) = React.useState(() => None)
  let menuNumber = React.useRef(0)

  let handleClick = (number, event) => {
    let target = event->ReactEvent.Mouse.currentTarget
    setAnchorEl(_x => Some(target))
    menuNumber.current = number
  }

  let handleClose = (_event, _reason) => {
    setAnchorEl(_x => None)
  }

  let theme = Mui.Core.useTheme()
  let darkMode = Theme.getMode(theme)

  <Mui.Box
    flexDirection={Mui.Box.Value.string("row")} justifyItems={Mui.Box.Value.string("center")}>
    <Mui.Tooltip title={"File"->React.string}>
      <Mui.Button
        onClick={handleClick(0)}
        color={switch darkMode {
        | Theme.Light => #primary
        | Theme.Dark => #default
        }}
        size=#small
        style={ReactDOM.Style.make(~textTransform="none", ())}>
        <Mui.Typography> {"File"->React.string} </Mui.Typography>
      </Mui.Button>
    </Mui.Tooltip>
    <Mui.Menu
      \"open"={Belt.Option.isSome(anchorEl) && menuNumber.current == 0}
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
          filesDispatch(
            FilesBase.AddFile(
              notebookState.name,
              FilesBase.Notebook(
                NotebookFormat.notebookCopytoString(notebookState.indices, notebookState.cells),
              ),
            ),
          )
        }}
        dense=true>
        <Mui.ListItemIcon> <Images.Save fontSize="small" /> </Mui.ListItemIcon>
        <Mui.ListItemText> {"Save"->React.string} </Mui.ListItemText>
      </Mui.MenuItem>
    </Mui.Menu>
    <Mui.Tooltip title={"Cells"->React.string}>
      <Mui.Button
        onClick={handleClick(1)}
        color={switch darkMode {
        | Theme.Light => #primary
        | Theme.Dark => #default
        }}
        size=#small
        style={ReactDOM.Style.make(~textTransform="none", ())}>
        <Mui.Typography> {"Cells"->React.string} </Mui.Typography>
      </Mui.Button>
    </Mui.Tooltip>
    <Mui.Menu
      \"open"={Belt.Option.isSome(anchorEl) && menuNumber.current == 1}
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
          notebookState.indices->Belt.List.forEach(i =>
            notebookState.cells
            ->Belt.HashMap.Int.get(i)
            ->Belt.Option.map(cellState => {
              let _ = NotebookBase.evalCell(~cellState, ~notebookDispatch)
            })
          )
        }}
        dense=true>
        <Mui.ListItemIcon> <Images.DoubleArrow fontSize="small" /> </Mui.ListItemIcon>
        <Mui.ListItemText> {"Run all cells"->React.string} </Mui.ListItemText>
      </Mui.MenuItem>
      <Mui.MenuItem
        onClick={evt => {
          handleClose(evt, "")
          notebookDispatch(ClearAllCodeOutput)
        }}
        dense=true>
        <Mui.ListItemIcon> <Images.Clear fontSize="small" /> </Mui.ListItemIcon>
        <Mui.ListItemText> {"Clear all code outputs"->React.string} </Mui.ListItemText>
      </Mui.MenuItem>
    </Mui.Menu>
    <Mui.Tooltip title={"Kernel"->React.string}>
      <Mui.Button
        onClick={handleClick(2)}
        color={switch darkMode {
        | Theme.Light => #primary
        | Theme.Dark => #default
        }}
        size=#small
        style={ReactDOM.Style.make(~textTransform="none", ())}>
        <Mui.Typography> {"Kernel"->React.string} </Mui.Typography>
      </Mui.Button>
    </Mui.Tooltip>
    <Mui.Menu
      \"open"={Belt.Option.isSome(anchorEl) && menuNumber.current == 2}
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
          let _ = WeblabInterpreter.resetEnvs() |> Js.Promise.catch(error => {
            Error(Errors.fromPromiseError(error))->Errors.alertError
            Js.Promise.resolve()
          })
        }}
        dense=true>
        <Mui.ListItemIcon> <Images.Replay fontSize="small" /> </Mui.ListItemIcon>
        <Mui.ListItemText> {"Reset environment"->React.string} </Mui.ListItemText>
      </Mui.MenuItem>
      <Mui.MenuItem
        onClick={evt => {
          handleClose(evt, "")
          let _ =
            WeblabInterpreter.resetEnvs()
            |> Js.Promise.then_(_ => {
              notebookDispatch(ClearAllCodeOutput)
              Js.Promise.resolve()
            })
            |> Js.Promise.catch(error => {
              Error(Errors.fromPromiseError(error))->Errors.alertError
              Js.Promise.resolve()
            })
        }}
        dense=true>
        <Mui.ListItemIcon> <Images.Clear fontSize="small" /> </Mui.ListItemIcon>
        <Mui.ListItemText> {"Reset environment & code outputs"->React.string} </Mui.ListItemText>
      </Mui.MenuItem>
    </Mui.Menu>
  </Mui.Box>
}
