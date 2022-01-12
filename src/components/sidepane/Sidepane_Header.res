@react.component
let make = (~toggle_sidebar, ~children) => {
  let theme = Mui.Core.useTheme()
  let darkMode = Theme.getMode(theme)
  <Mui.Toolbar variant=#dense>
    <Mui.Box flexGrow={Mui.Box.Value.int(1)}>
      <Mui.Typography
        variant=#h6
        color={switch darkMode {
        | Theme.Light => #primary
        | Theme.Dark => #textPrimary
        }}>
        children
      </Mui.Typography>
    </Mui.Box>
    <Mui.Tooltip title={React.string("Close sidepane")}>
      <Mui.Button
        onClick={_event => toggle_sidebar(false)}
        size=#small
        color={switch darkMode {
        | Theme.Light => #primary
        | Theme.Dark => #default
        }}>
        <Images.Close fontSize="small" />
      </Mui.Button>
    </Mui.Tooltip>
  </Mui.Toolbar>
}
