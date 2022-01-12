@react.component
let make = (~toggle_sidebar, ~darkMode, ~setDarkMode) => {
  <>
    <Sidepane_Header toggle_sidebar> {"Settings"->React.string} </Sidepane_Header>
    <Mui.Divider />
    <Mui.List dense=true style={ReactDOM.Style.make(~paddingLeft="16px", ())}>
      <Mui.ListItem dense=true>
        <Mui.ListItemText>
          <Mui.FormGroup>
            <Mui.FormControlLabel
              control={<Mui.Switch
                checked=darkMode onChange={_ => setDarkMode(_ => !darkMode)} size=#small
              />}
              label={<Mui.Typography
                variant=#body2 style={ReactDOM.Style.make(~paddingLeft="8px", ())}>
                {"Dark mode"->React.string}
              </Mui.Typography>}
            />
          </Mui.FormGroup>
        </Mui.ListItemText>
      </Mui.ListItem>
    </Mui.List>
  </>
}
