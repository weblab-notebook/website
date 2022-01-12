let transOri = Mui.Menu.TransformOrigin.make(
  ~horizontal=Mui.Menu.Horizontal.int(0),
  ~vertical=Mui.Menu.Vertical.int(-40),
  (),
)

@react.component
let make = (~setLoginDialog) => {
  let session = React.useContext(Session.SessionContext.context)

  let (anchorEl, setAnchorEl) = React.useState(() => None)

  let handleClick = event => {
    let target = event->ReactEvent.Mouse.currentTarget
    setAnchorEl(_x => Some(target))
  }

  let handleClose = (_event, _reason) => {
    setAnchorEl(_x => None)
  }

  let theme = Mui.Core.useTheme()

  <Mui.Toolbar
    variant=#dense
    style={ReactDOM.Style.make(
      ~width="100%",
      ~maxHeight="56px",
      ~background="linear-gradient(135deg, #273377, #3949ab)",
      (),
    )}>
    <Mui.Box
      flexGrow={Mui.Box.Value.int(1)}
      ml={Mui.Box.Value.int(4)}
      pr={Mui.Box.Value.int(2)}
      style={ReactDOM.Style.make(~color="white", ())}>
      <Mui.Typography variant=#h4 style={ReactDOM.Style.make(~fontWeight="700", ~margin="8px", ())}>
        <Mui.Box component={Mui.Box.Component.string("span")}> {"Web"->React.string} </Mui.Box>
        <Mui.Box
          component={Mui.Box.Component.string("span")}
          style={ReactDOM.Style.make(~color=theme.palette.secondary.main, ())}>
          {"lab"->React.string}
        </Mui.Box>
      </Mui.Typography>
    </Mui.Box>
    <Mui.Box
      alignItems={Mui.Box.Value.string("center")}
      display={Mui.Box.Value.breakpointObj(
        Mui.Box.BreakpointObj.make(
          ~xs=Mui.Box.Value.string("none"),
          ~sm=Mui.Box.Value.string("flex"),
          ~md=Mui.Box.Value.string("flex"),
          (),
        ),
      )}>
      <Mui.Box mr={Mui.Box.Value.int(4)}>
        <Mui.Typography variant=#body1>
          <Link to="/hub" style={ReactDOM.Style.make(~color="white", ())}>
            {React.string("NotebookHub")}
          </Link>
        </Mui.Typography>
      </Mui.Box>
      <Mui.Box mr={Mui.Box.Value.int(4)}>
        <Mui.Typography variant=#body1>
          <Link to="/documentation" style={ReactDOM.Style.make(~color="white", ())}>
            {React.string("Documentation")}
          </Link>
        </Mui.Typography>
      </Mui.Box>
    </Mui.Box>
    <Mui.Box maxHeight={Mui.Box.Value.int(56)} width={Mui.Box.Value.int(80)}>
      {switch session {
      | None =>
        <Mui.Button onClick={_ => setLoginDialog(_ => true)} color=#secondary variant=#contained>
          {"Log in"->React.string}
        </Mui.Button>
      | Some(_session) => <>
          <Mui.Tooltip title={"Account"->React.string}>
            <Mui.IconButton
              onClick=handleClick
              style={ReactDOM.Style.make(~color="white", ~maxHeight="56", ~marginLeft="8px", ())}>
              <Images.AccountCircle fontSize="large" />
            </Mui.IconButton>
          </Mui.Tooltip>
          <Mui.Menu
            \"open"={Belt.Option.isSome(anchorEl)}
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
                let _ =
                  SupabaseAuth.signOut(SupabaseClient.supabase.auth)
                  |> Js.Promise.then_(_ => {
                    Js.Promise.resolve()
                  })
                  |> Js.Promise.catch(error => {
                    let exn = Js.Exn.anyToExnInternal(error)
                    Errors.alert(
                      exn
                      ->Js.Exn.asJsExn
                      ->Belt.Option.flatMap(Js.Exn.message)
                      ->Belt.Option.getWithDefault("Logout failed."),
                    )
                    Js.Promise.reject(exn)
                  })
              }}
              dense=true>
              <Mui.ListItemIcon> <Images.ExitToApp /> </Mui.ListItemIcon>
              <Mui.ListItemText> {"Logout"->React.string} </Mui.ListItemText>
            </Mui.MenuItem>
          </Mui.Menu>
        </>
      }}
    </Mui.Box>
  </Mui.Toolbar>
}
