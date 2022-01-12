open LoginBase

let supabase = SupabaseClient.supabase

@react.component
let make = (~loginDialog, ~setLoginDialog) => {
  let (login, loginDispatch) = React.useReducer(
    loginReducer,
    {email: "", password: "", alert: None},
  )
  let (registration, registrationDispatch) = React.useReducer(
    registrationReducer,
    {email: "", password: "", secondPassword: "", alert: None, success: None},
  )
  let (reset, resetDispatch) = React.useReducer(
    resetReducer,
    {email: "", alert: None, success: None},
  )

  let (tab, setTab) = React.useState(() => "0")
  let (loading, setLoading) = React.useState(() => false)

  let submitLogin = evt => {
    ReactEvent.Form.preventDefault(evt)
    setLoading(_ => true)
    let _ =
      SupabaseAuth.signIn(
        supabase.auth,
        {"email": Some(login.email), "password": Some(login.password), "provider": None},
      )
      |> Js.Promise.then_((
        response: {
          "user": Js.Nullable.t<SupabaseAuth.user>,
          "data": Js.Nullable.t<SupabaseAuth.data>,
          "session": Js.Nullable.t<SupabaseAuth.session>,
          "error": Js.Nullable.t<SupabaseAuth.error>,
        },
      ) => {
        switch response["error"]->Js.Nullable.toOption {
        | None => {
            setLoading(_ => false)
            setLoginDialog(_ => false)
            loginDispatch(Clear)
            Js.Promise.resolve()
          }
        | Some(error) => Js.Promise.reject(Js.Exn.raiseError(error.message))
        }
      })
      |> Js.Promise.catch(error => {
        setLoading(_ => false)
        loginDispatch(
          SetAlert(
            Js.Exn.anyToExnInternal(error)
            ->Js.Exn.asJsExn
            ->Belt.Option.flatMap(Js.Exn.message)
            ->Belt.Option.getWithDefault("Log in failed."),
          ),
        )
        Js.Promise.resolve()
      })
  }

  let submitRegistration = evt => {
    ReactEvent.Form.preventDefault(evt)
    if !LoginBase.samePassword(registration.password, registration.secondPassword) {
      registrationDispatch(SetAlert("Both passwords must be the same."))
    } else if !LoginBase.strongPassword(registration.password) {
      registrationDispatch(
        SetAlert(
          "Password must be at least 8 characters long and must contain at least one uppercase letter, one lowercase letter, one digit and one special character.",
        ),
      )
    } else {
      setLoading(_ => true)
      let _ =
        SupabaseAuth.signUp(
          supabase.auth,
          {"email": registration.email, "password": registration.password},
        )
        |> Js.Promise.then_((
          response: {
            "user": Js.Nullable.t<SupabaseAuth.user>,
            "data": Js.Nullable.t<SupabaseAuth.data>,
            "session": Js.Nullable.t<SupabaseAuth.session>,
            "error": Js.Nullable.t<SupabaseAuth.error>,
          },
        ) => {
          switch response["error"]->Js.Nullable.toOption {
          | None => {
              setLoading(_ => false)
              registrationDispatch(Success("A verification email has been sent to your address."))
              Js.Promise.resolve()
            }
          | Some(error) => Js.Promise.reject(Js.Exn.raiseError(error.message))
          }
        })
        |> Js.Promise.catch(error => {
          setLoading(_ => false)
          registrationDispatch(
            SetAlert(
              Js.Exn.anyToExnInternal(error)
              ->Js.Exn.asJsExn
              ->Belt.Option.flatMap(Js.Exn.message)
              ->Belt.Option.getWithDefault("Check your email for the login link!"),
            ),
          )
          Js.Promise.resolve()
        })
    }
  }

  let submitReset = evt => {
    ReactEvent.Form.preventDefault(evt)
    setLoading(_ => true)
    let _ =
      SupabaseAuth.resetPasswordForEmail(supabase.auth.api, reset.email)
      |> Js.Promise.then_((
        response: {
          "data": Js.Nullable.t<SupabaseAuth.data>,
          "error": Js.Nullable.t<SupabaseAuth.error>,
        },
      ) => {
        switch response["error"]->Js.Nullable.toOption {
        | None => {
            setLoading(_ => false)
            resetDispatch(Success("A password reset email has been sent to your email address."))
            Js.Promise.resolve()
          }
        | Some(error) => Js.Promise.reject(Js.Exn.raiseError(error.message))
        }
      })
      |> Js.Promise.catch(error => {
        setLoading(_ => false)
        resetDispatch(
          SetAlert(
            Js.Exn.anyToExnInternal(error)
            ->Js.Exn.asJsExn
            ->Belt.Option.flatMap(Js.Exn.message)
            ->Belt.Option.getWithDefault("Please verify that the Email is correct."),
          ),
        )
        Js.Promise.resolve()
      })
  }

  let signInOAuth = (provider, evt) => {
    ReactEvent.Mouse.preventDefault(evt)
    setLoading(_ => true)
    let _ =
      SupabaseAuth.signIn(
        supabase.auth,
        {"email": None, "password": None, "provider": Some(provider)},
      )
      |> Js.Promise.then_((
        response: {
          "user": Js.Nullable.t<SupabaseAuth.user>,
          "data": Js.Nullable.t<SupabaseAuth.data>,
          "session": Js.Nullable.t<SupabaseAuth.session>,
          "error": Js.Nullable.t<SupabaseAuth.error>,
        },
      ) => {
        switch response["error"]->Js.Nullable.toOption {
        | None => {
            setLoading(_ => false)
            setLoginDialog(_ => false)
            loginDispatch(Clear)
            Js.Promise.resolve()
          }
        | Some(error) => Js.Promise.reject(Js.Exn.raiseError(error.message))
        }
      })
      |> Js.Promise.catch(error => {
        setLoading(_ => false)
        loginDispatch(
          SetAlert(
            Js.Exn.anyToExnInternal(error)
            ->Js.Exn.asJsExn
            ->Belt.Option.flatMap(Js.Exn.message)
            ->Belt.Option.getWithDefault("Log in failed."),
          ),
        )
        Js.Promise.resolve()
      })
  }

  <Mui.Dialog \"open"=loginDialog onClose={(_evt, _reason) => setLoginDialog(_ => false)}>
    <Mui.Tabs
      indicatorColor=#secondary textColor=#primary value={Mui.Any.make(tab)} variant=#fullWidth>
      <Mui.Tab
        value={Mui.Any.make("0")} label={"Log in"->React.string} onClick={_ => setTab(_ => "0")}
      />
      <Mui.Tab
        value={Mui.Any.make("1")} label={"Register"->React.string} onClick={_ => setTab(_ => "1")}
      />
    </Mui.Tabs>
    <MuiLab.TabContext value=tab>
      <MuiLab.TabPanel value="0">
        <Mui.DialogContent>
          <Mui.Box
            display={Mui.Box.Value.string("flex")}
            flexDirection={Mui.Box.Value.string("column")}
            gridGap={Mui.Box.Value.int(24)}
            alignItems={Mui.Box.Value.string("center")}
            clone=true>
            <form onSubmit=submitLogin>
              <Mui.FormGroup>
                <Mui.FormControlLabel
                  value={Mui.Any.make(login.email)}
                  onChange={evt =>
                    loginDispatch(ChangeEmail(ReactEvent.Form.currentTarget(evt)["value"]))}
                  label={<Mui.FormLabel> {"Email"->React.string} </Mui.FormLabel>}
                  labelPlacement=#top
                  control={<Mui.TextField
                    variant=#outlined margin=#dense autoFocus=true \"type"="email"
                  />}
                />
              </Mui.FormGroup>
              <Mui.FormGroup>
                <Mui.FormControlLabel
                  value={Mui.Any.make(login.password)}
                  onChange={evt =>
                    loginDispatch(ChangePassword(ReactEvent.Form.currentTarget(evt)["value"]))}
                  label={<Mui.FormLabel> {"Password"->React.string} </Mui.FormLabel>}
                  labelPlacement=#top
                  control={<Mui.TextField variant=#outlined margin=#dense \"type"="password" />}
                />
              </Mui.FormGroup>
              {switch login.alert {
              | None => React.null
              | Some(str) => <MuiLab.Alert severity=#error> {str->React.string} </MuiLab.Alert>
              }}
              <Mui.Button
                variant=#contained
                color=#primary
                disabled=loading
                \"type"={Mui.Button.Type.string("submit")}
                style={ReactDOM.Style.make(~margin="12px", ())}>
                {"Log in"->React.string}
              </Mui.Button>
              <Mui.Typography>
                {"Forgotten your passord? "->React.string}
                <Mui.Link href="#" rel=#noopener onClick={_ => setTab(_ => "2")}>
                  {"Reset your Password"->React.string}
                </Mui.Link>
                {"."->React.string}
              </Mui.Typography>
            </form>
          </Mui.Box>
          <Mui.Divider
            variant=#fullWidth
            style={ReactDOM.Style.make(~marginTop="32px", ~marginBottom="32px", ())}
          />
          <Mui.Box
            display={Mui.Box.Value.string("flex")}
            flexDirection={Mui.Box.Value.string("column")}
            gridGap={Mui.Box.Value.int(16)}
            alignItems={Mui.Box.Value.string("center")}>
            <Mui.Button
              startIcon={<Images.Github />}
              onClick={signInOAuth("github")}
              variant=#contained
              disabled=loading>
              {"Sign in with Github"->React.string}
            </Mui.Button>
            <Mui.Button
              startIcon={<Images.Google className="MuiSvgIcon-root" />}
              onClick={signInOAuth("google")}
              variant=#contained
              disabled=loading>
              {"Sign in with Google"->React.string}
            </Mui.Button>
          </Mui.Box>
        </Mui.DialogContent>
      </MuiLab.TabPanel>
      <MuiLab.TabPanel value="1">
        <Mui.DialogContent>
          <Mui.Box
            display={Mui.Box.Value.string("flex")}
            flexDirection={Mui.Box.Value.string("column")}
            gridGap={Mui.Box.Value.int(24)}
            alignItems={Mui.Box.Value.string("center")}
            clone=true>
            <form onSubmit=submitRegistration>
              <Mui.FormGroup>
                <Mui.FormControlLabel
                  value={Mui.Any.make(registration.email)}
                  onChange={evt =>
                    registrationDispatch(ChangeEmail(ReactEvent.Form.currentTarget(evt)["value"]))}
                  label={<Mui.FormLabel> {"Email"->React.string} </Mui.FormLabel>}
                  labelPlacement=#top
                  control={<Mui.TextField
                    variant=#outlined margin=#dense autoFocus=true \"type"="email"
                  />}
                />
              </Mui.FormGroup>
              <Mui.FormGroup>
                <Mui.FormControlLabel
                  value={Mui.Any.make(registration.password)}
                  onChange={evt =>
                    registrationDispatch(
                      ChangePassword(ReactEvent.Form.currentTarget(evt)["value"]),
                    )}
                  label={<Mui.FormLabel> {"Password"->React.string} </Mui.FormLabel>}
                  labelPlacement=#top
                  control={<Mui.TextField variant=#outlined margin=#dense \"type"="password" />}
                />
              </Mui.FormGroup>
              <Mui.FormGroup>
                <Mui.FormControlLabel
                  value={Mui.Any.make(registration.secondPassword)}
                  onChange={evt =>
                    registrationDispatch(
                      ChangeSecondPassword(ReactEvent.Form.currentTarget(evt)["value"]),
                    )}
                  label={<Mui.FormLabel> {"Repeat Password"->React.string} </Mui.FormLabel>}
                  labelPlacement=#top
                  control={<Mui.TextField variant=#outlined margin=#dense \"type"="password" />}
                />
              </Mui.FormGroup>
              {switch registration.alert {
              | None => React.null
              | Some(str) => <MuiLab.Alert severity=#error> {str->React.string} </MuiLab.Alert>
              }}
              <Mui.Typography display=#initial>
                {"By signing up you agree to our "->React.string}
                <Link to="/privacy-policy"> {"privacy policy"->React.string} </Link>
                {"."->React.string}
              </Mui.Typography>
              <Mui.Button
                variant=#contained
                color=#primary
                disabled=loading
                \"type"={Mui.Button.Type.string("submit")}
                style={ReactDOM.Style.make(~margin="12px", ())}>
                {"Sign up"->React.string}
              </Mui.Button>
              {switch registration.success {
              | None => React.null
              | Some(str) => <MuiLab.Alert color=#success> {str->React.string} </MuiLab.Alert>
              }}
            </form>
          </Mui.Box>
        </Mui.DialogContent>
      </MuiLab.TabPanel>
      <MuiLab.TabPanel value="2">
        <Mui.DialogContent>
          <Mui.Box
            display={Mui.Box.Value.string("flex")}
            flexDirection={Mui.Box.Value.string("column")}
            gridGap={Mui.Box.Value.int(24)}
            alignItems={Mui.Box.Value.string("center")}
            clone=true>
            <form onSubmit=submitReset>
              <Mui.FormGroup>
                <Mui.FormControlLabel
                  value={Mui.Any.make(reset.email)}
                  onChange={evt =>
                    resetDispatch(ChangeEmail(ReactEvent.Form.currentTarget(evt)["value"]))}
                  label={<Mui.FormLabel> {"Email"->React.string} </Mui.FormLabel>}
                  labelPlacement=#top
                  control={<Mui.TextField
                    variant=#outlined margin=#dense autoFocus=true \"type"="email"
                  />}
                />
              </Mui.FormGroup>
              {switch reset.alert {
              | None => React.null
              | Some(str) => <MuiLab.Alert severity=#error> {str->React.string} </MuiLab.Alert>
              }}
              <Mui.Button
                variant=#contained
                color=#primary
                disabled=loading
                \"type"={Mui.Button.Type.string("submit")}
                style={ReactDOM.Style.make(~margin="12px", ())}>
                {"Reset Password"->React.string}
              </Mui.Button>
              {switch reset.success {
              | None => React.null
              | Some(str) => <MuiLab.Alert severity=#success> {str->React.string} </MuiLab.Alert>
              }}
            </form>
          </Mui.Box>
        </Mui.DialogContent>
      </MuiLab.TabPanel>
    </MuiLab.TabContext>
  </Mui.Dialog>
}
