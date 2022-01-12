@react.component
let make = (~toggle_sidebar) => {
  let theme = Mui.Core.useTheme()
  let darkMode = Theme.getMode(theme)
  <>
    <Sidepane_Header toggle_sidebar>
      <Link
        style={ReactDOM.Style.make(
          ~color={
            switch darkMode {
            | Theme.Light => theme.palette.primary.main
            | Theme.Dark => theme.palette.text.primary
            }
          },
          (),
        )}
        to="/documentation">
        {"Documentation"->React.string}
      </Link>
    </Sidepane_Header>
    <Mui.Divider />
    <Mui.List component={Mui.List.Component.string("nav")}>
      <Mui.ListItem button=true>
        <Mui.ListItemText>
          <Mui.Typography>
            <Link
              style={ReactDOM.Style.make(
                ~color={
                  switch darkMode {
                  | Theme.Light => theme.palette.primary.main
                  | Theme.Dark => theme.palette.text.primary
                  }
                },
                (),
              )}
              to="/documentation/getting_started">
              {"Getting started"->React.string}
            </Link>
          </Mui.Typography>
        </Mui.ListItemText>
      </Mui.ListItem>
      <Mui.ListItem button=true>
        <Mui.ListItemText>
          <Mui.Typography>
            <Link
              style={ReactDOM.Style.make(
                ~color={
                  switch darkMode {
                  | Theme.Light => theme.palette.primary.main
                  | Theme.Dark => theme.palette.text.primary
                  }
                },
                (),
              )}
              to="/documentation/guides_and_tutorials">
              {"Guides and Tutorials"->React.string}
            </Link>
          </Mui.Typography>
        </Mui.ListItemText>
      </Mui.ListItem>
      <Mui.ListItem button=true>
        <Mui.ListItemText>
          <Mui.Typography>
            <Link
              style={ReactDOM.Style.make(
                ~color={
                  switch darkMode {
                  | Theme.Light => theme.palette.primary.main
                  | Theme.Dark => theme.palette.text.primary
                  }
                },
                (),
              )}
              to="/documentation/interface">
              {"The Weblab interface"->React.string}
            </Link>
          </Mui.Typography>
        </Mui.ListItemText>
      </Mui.ListItem>
      <Mui.ListItem button=true>
        <Mui.ListItemText>
          <Mui.Typography>
            <Link
              style={ReactDOM.Style.make(
                ~color={
                  switch darkMode {
                  | Theme.Light => theme.palette.primary.main
                  | Theme.Dark => theme.palette.text.primary
                  }
                },
                (),
              )}
              to="/documentation/javascript">
              {"Javascript"->React.string}
            </Link>
          </Mui.Typography>
        </Mui.ListItemText>
      </Mui.ListItem>
    </Mui.List>
  </>
}
