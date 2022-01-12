@react.component
let make = (~dispatch) => {
  let (search, setSearch) = React.useState(() => "")

  let theme = Mui.Core.useTheme()
  let darkMode = Theme.getMode(theme)

  let delayedSearch = evt => {
    let value = ReactEvent.Form.target(evt)["value"]
    setSearch(_ => value)
    if value == "" {
      Delay.delay(() => dispatch(HubBase.ClearSearch), Some(0))()
    } else {
      Delay.delay(x => HubBase.asyncReducer(dispatch, HubBase.AsyncSearch(x)), Some(1000))(value)
    }
  }

  <Mui.Box display={Mui.Box.Value.string("flex")} padding={Mui.Box.Value.int(6)}>
    <Mui.TextField
      value={Mui.TextField.Value.string(search)}
      color={switch darkMode {
      | Theme.Light => #primary
      | Theme.Dark => #secondary
      }}
      variant=#outlined
      fullWidth=true
      autoFocus=true
      onChange={delayedSearch}
      label={"Search tags"->React.string}
    />
  </Mui.Box>
}
