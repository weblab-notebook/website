@react.component
let make = (~children) => {
  let session = React.useContext(Session.SessionContext.context)
  let theme = Mui.Core.useTheme()

  <Mui.Container>
    {switch session {
    | None =>
      <Mui.Box margin={Mui.Box.Value.int(2)} clone=true>
        <Mui.Card>
          <Mui.CardContent style={ReactDOM.Style.make(~textAlign="center", ())}>
            <Mui.Typography
              variant=#h3 color=#primary style={ReactDOM.Style.make(~fontWeight="700", ())}>
              <Mui.Box width={Mui.Box.Value.int(64)} height={Mui.Box.Value.int(64)} clone=true>
                <Images.Logo />
              </Mui.Box>
              {"Notebook"->React.string}
              <Mui.Box
                display={Mui.Box.Value.string("inline")}
                style={ReactDOM.Style.make(~color=theme.palette.secondary.main, ())}>
                {"Hub"->React.string}
              </Mui.Box>
            </Mui.Typography>
            <Mui.Typography variant=#subtitle1>
              {"Share your notebooks with the world."->React.string}
            </Mui.Typography>
          </Mui.CardContent>
        </Mui.Card>
      </Mui.Box>
    | Some(_) => React.null
    }}
    {children->React.Children.toArray->React.array}
  </Mui.Container>
}
