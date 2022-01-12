@react.component
let make = (~children) => {
  let theme = Mui.Core.useTheme()

  <Mui.Container style={ReactDOM.Style.make(~zIndex="20", ~paddingTop="8px", ())}>
    <Mui.Box
      boxShadow={Mui.Box.Value.int(2)}
      borderRadius={Mui.Box.Value.int(4)}
      style={ReactDOM.Style.make(
        ~minHeight="100vh",
        ~backgroundColor=theme.palette.background.default,
        ~padding="2rem",
        (),
      )}>
      <Mui.List> {children} </Mui.List>
    </Mui.Box>
  </Mui.Container>
}
