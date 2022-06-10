let theme = Mui.Theme.create(Theme.getThemeProto(false))

@react.component
let make = () => {
  <Mui.ThemeProvider theme>
    <ReactHelmet>
      <link rel="icon" href="/favicon.png" type_="image/png" />
      <title> {"Weblab Email Verification"->React.string} </title>
    </ReactHelmet>
    <Mui.Box
      margin={Mui.Box.Value.string("auto")}
      width={Mui.Box.Value.string("40%")}
      height={Mui.Box.Value.string("40%")}
      style={ReactDOM.Style.make(
        ~position="absolute",
        ~left="0",
        ~right="0",
        ~top="0",
        ~bottom="0",
        (),
      )}>
      <Mui.Typography
        variant=#h3
        color=#primary
        style={ReactDOM.Style.make(~fontWeight="700", ~marginBottom="32px", ())}>
        <Mui.Box width={Mui.Box.Value.int(64)} height={Mui.Box.Value.int(64)} clone=true>
          <Images.Logo />
        </Mui.Box>
        {"Web"->React.string}
        <Mui.Box
          display={Mui.Box.Value.string("inline")}
          style={ReactDOM.Style.make(~color=theme.palette.secondary.main, ())}>
          {"lab"->React.string}
        </Mui.Box>
      </Mui.Typography>
      <Mui.Typography variant=#body1>
        {"You have successfully verified your Email."->React.string}
      </Mui.Typography>
    </Mui.Box>
  </Mui.ThemeProvider>
}

React.setDisplayName(make, "VerifyEmail")

let default = make
