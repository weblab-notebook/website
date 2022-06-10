let theme = Mui.Theme.create(Theme.getThemeProto(false))

let supabase = SupabaseClient.supabase

type login = {
  password: string,
  secondPassword: string,
}

type loginActions = ChangePassword(string) | ChangeSecondPassword(string) | Clear

let loginReducer = (state, action) => {
  switch action {
  | ChangePassword(newPassword) => {...state, password: newPassword}
  | ChangeSecondPassword(newPassword) => {...state, secondPassword: newPassword}
  | Clear => {password: "", secondPassword: ""}
  }
}

@react.component
let make = (~location: Webapi.Dom.Location.t) => {
  let (reset, resetDispatch) = React.useReducer(loginReducer, {password: "", secondPassword: ""})
  let (resetAlert, setResetAlert) = React.useState(() => None)
  let (accessToken, setAccessToken) = React.useState(() => None)

  let (loading, setLoading) = React.useState(() => false)

  React.useEffect0(() => {
    let params = Webapi.Url.URLSearchParams.make(
      location->Webapi.Dom.Location.hash->Js.String2.replace("#", ""),
    )
    let access_tokenOption = params->Webapi.Url.URLSearchParams.get("access_token")
    let typeOption = params->Webapi.Url.URLSearchParams.get("type")
    switch (typeOption, access_tokenOption) {
    | (Some(type_), Some(access_token)) =>
      if type_ == "recovery" {
        setAccessToken(_ => Some(access_token))
      }
    | (_, _) => ()
    }
    None
  })

  let submitLogin = (evt, token) => {
    ReactEvent.Form.preventDefault(evt)
    if !LoginBase.samePassword(reset.password, reset.secondPassword) {
      setResetAlert(_ => Some("Both passwords must be the same."))
    } else if !LoginBase.strongPassword(reset.password) {
      setResetAlert(_ => Some(
        "Password must be at least 8 characters long and must contain at least one uppercase letter, one lowercase letter, one digit and one special character.",
      ))
    } else {
      setLoading(_ => true)
      let _ =
        supabase.auth.api->SupabaseAuth.Api.updateUser(token, {"password": reset.password})
        |> Js.Promise.then_((
          response: {
            "data": Js.Nullable.t<SupabaseAuth.data>,
            "error": Js.Nullable.t<SupabaseAuth.error>,
          },
        ) => {
          switch response["error"]->Js.Nullable.toOption {
          | None => {
              setLoading(_ => false)
              resetDispatch(Clear)
              Js.Promise.resolve()
            }
          | Some(error) => Js.Promise.reject(Js.Exn.raiseError(error.message))
          }
        })
        |> Js.Promise.catch(error => {
          setLoading(_ => false)
          setResetAlert(_ => Some(
            Js.Exn.anyToExnInternal(error)
            ->Js.Exn.asJsExn
            ->Belt.Option.flatMap(Js.Exn.message)
            ->Belt.Option.getWithDefault("Log in failed."),
          ))
          Js.Promise.resolve()
        })
    }
  }
  <Mui.ThemeProvider theme>
    <ReactHelmet>
      <link rel="icon" href="/favicon.png" type_="image/png" />
      <title> {"Weblab Password Reset"->React.string} </title>
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
        align=#center
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
      {switch accessToken {
      | Some(token) =>
        <Mui.Box
          display={Mui.Box.Value.string("flex")}
          flexDirection={Mui.Box.Value.string("column")}
          gridGap={Mui.Box.Value.int(24)}
          alignItems={Mui.Box.Value.string("center")}
          clone=true>
          <form onSubmit={evt => submitLogin(evt, token)}>
            <Mui.FormGroup>
              <Mui.FormControlLabel
                value={Mui.Any.make(reset.password)}
                onChange={evt =>
                  resetDispatch(ChangePassword(ReactEvent.Form.currentTarget(evt)["value"]))}
                label={<Mui.FormLabel> {"New Password"->React.string} </Mui.FormLabel>}
                labelPlacement=#top
                control={<Mui.TextField variant=#outlined margin=#dense \"type"="password" />}
              />
            </Mui.FormGroup>
            <Mui.FormGroup>
              <Mui.FormControlLabel
                value={Mui.Any.make(reset.secondPassword)}
                onChange={evt =>
                  resetDispatch(ChangeSecondPassword(ReactEvent.Form.currentTarget(evt)["value"]))}
                label={<Mui.FormLabel> {"Repeat Password"->React.string} </Mui.FormLabel>}
                labelPlacement=#top
                control={<Mui.TextField variant=#outlined margin=#dense \"type"="password" />}
              />
            </Mui.FormGroup>
            {switch resetAlert {
            | None => React.null
            | Some(str) =>
              <Mui.Typography color=#error display=#initial> {str->React.string} </Mui.Typography>
            }}
            <Mui.Button
              variant=#contained
              color=#primary
              disabled=loading
              \"type"={Mui.Button.Type.string("submit")}
              style={ReactDOM.Style.make(~margin="16px", ())}>
              {"Reset Password"->React.string}
            </Mui.Button>
          </form>
        </Mui.Box>
      | None =>
        <Mui.Typography align=#center>
          {"The URL is incorrect. Request another reset link."->React.string}
        </Mui.Typography>
      }}
    </Mui.Box>
  </Mui.ThemeProvider>
}

React.setDisplayName(make, "ResetPassword")

let default = make
