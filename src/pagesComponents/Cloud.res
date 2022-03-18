module Styles = %makeStyles(
  _theme => {
    grid: ReactDOM.Style.make(
      ~display="grid",
      ~gridTemplateColumns="1fr 1fr 1fr 1fr",
      ~gridGap="24px",
      ~padding="24px",
      (),
    ),
    heading: ReactDOM.Style.make(~padding="16px", ()),
  }
)

@react.component
let make = (
  ~pageContext: {"priceData": array<Stripe.price>, "productData": array<Stripe.product>},
) => {
  // Use Hooks to define internal state

  let (session, setSession) = React.useState(() => None)

  let (loginDialog, setLoginDialog) = React.useState(() => false)

  let (activeTab, setActiveTab) = React.useState(() => "0")
  let toggle_active_tab = React.useCallback2(tab => {
    if activeTab != tab {
      setActiveTab(_x => tab)
    }
  }, (activeTab, setActiveTab))

  let (darkMode, setDarkMode) = React.useState(() => false)

  let globClasses = Theme.Styles.useStyles()
  let _classes = Styles.useStyles()

  // Run computations when component initializes or session updates

  React.useEffect0(() => {
    setSession(_ => SupabaseAuth.session(SupabaseClient.supabase.auth)->Js.Nullable.toOption)
    SupabaseAuth.onAuthStateChange(SupabaseClient.supabase.auth, (_, session) =>
      setSession(_ => session->Js.Nullable.toOption)
    )
    setDarkMode(_ => Theme.initializeDarkMode())
    None
  })

  // Memoize values that are used by the component later.

  let theme = React.useMemo1(() => Mui.Theme.create(Theme.getThemeProto(darkMode)), [darkMode])

  let topbar = React.useMemo0(() => <Topbar setLoginDialog />)

  let sidebar = React.useMemo2(
    () =>
      <Sidebar toggle_sidebar=SidebarsBase.toggle_sidebar activeTab toggle_active_tab>
        <Mui.Tooltip title={React.string("Settings")}> <Images.Settings /> </Mui.Tooltip>
      </Sidebar>,
    (activeTab, toggle_active_tab),
  )

  let sidepane = React.useMemo2(
    () =>
      <Sidepane activeTab>
        <Sidepane_Settings toggle_sidebar=SidebarsBase.toggle_sidebar darkMode setDarkMode />
      </Sidepane>,
    (activeTab, darkMode),
  )

  let productData =
    pageContext["productData"]->Js.Array2.map(x => (x.id, x))->Belt.HashMap.String.fromArray

  // Return the component

  <Mui.ThemeProvider theme>
    <Session.SessionContext.Provider value=session>
      <Mui.CssBaseline />
      <BsReactHelmet>
        <link rel="icon" href="/favicon.png" type_="image/png" />
        <title> {"Weblab NotebookHub"->React.string} </title>
      </BsReactHelmet>
      <Mui.Box
        className=globClasses.sidebar
        boxShadow={Mui.Box.Value.int(2)}
        bgcolor={Mui.Box.Value.string(theme.palette.background.default)}>
        <nav> sidebar </nav>
      </Mui.Box>
      <Mui.Box
        className=globClasses.wrapper
        id="wrapper"
        gridTemplateColumns={Mui.Box.Value.breakpointObj(
          Mui.Box.BreakpointObj.make(
            ~xs=Mui.Box.Value.string("48px 0px 1fr"),
            ~sm=Mui.Box.Value.string("48px 0px 1fr"),
            ~md=Mui.Box.Value.string("48px 0px 1fr"),
            (),
          ),
        )}>
        <Mui.Box className=globClasses.topbar boxShadow={Mui.Box.Value.int(2)}> topbar </Mui.Box>
        <Mui.Box
          className=globClasses.sidepane
          boxShadow={Mui.Box.Value.int(3)}
          bgcolor={Mui.Box.Value.string(theme.palette.background.default)}>
          sidepane
        </Mui.Box>
        <Mui.Box style={ReactDOM.Style.make(~gridRow="3", ~gridColumn="3", ())}>
          <main>
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
              {switch session {
              | Some(session) => <>
                  <Mui.Box
                    display={Mui.Box.Value.string("flex")}
                    flexDirection={Mui.Box.Value.string("row")}>
                    {pageContext["priceData"]
                    ->Belt.Array.map(price => {
                      switch productData->Belt.HashMap.String.get(price.product) {
                      | Some(product) =>
                        <Mui.Card>
                          <Mui.CardHeader title={product.name->React.string} />
                          <Mui.CardContent>
                            <Mui.Typography>
                              {string_of_int(price.unit_amount / 100)->React.string}
                            </Mui.Typography>
                          </Mui.CardContent>
                          <Mui.CardActions>
                            <Mui.Button
                              variant=#contained
                              onClick={_ => {
                                let _ =
                                  Bs_fetch.fetchWithInit(
                                    "https://us-central1-scenic-treat-317309.cloudfunctions.net/subscription-test",
                                    Bs_fetch.RequestInit.make(
                                      ~method_=Bs_fetch.Post,
                                      ~headers=Bs_fetch.HeadersInit.make({
                                        "Content-Type": "application/json",
                                      }),
                                      ~body=Bs_fetch.BodyInit.make(
                                        Js.Json.stringifyAny({
                                          "access_token": session.access_token,
                                        })->Belt.Option.getWithDefault(""),
                                      ),
                                      (),
                                    ),
                                  )
                                  |> Js.Promise.then_(Bs_fetch.Response.json)
                                  |> Js.Promise.then_(response => {
                                    Js.Console.log(response)
                                    Js.Promise.resolve(Some(response))
                                  })
                                  |> Js.Promise.catch(error => {
                                    Error(Errors.fromPromiseError(error))->Errors.alertError
                                    Js.Promise.resolve(None)
                                  })
                              }}>
                              {"Subscribe"->React.string}
                            </Mui.Button>
                          </Mui.CardActions>
                        </Mui.Card>
                      | None => React.null
                      }
                    })
                    ->React.array}
                  </Mui.Box>
                </>
              | None => React.null
              }}
            </Mui.Box>
          </main>
        </Mui.Box>
      </Mui.Box>
      <Login loginDialog setLoginDialog />
    </Session.SessionContext.Provider>
  </Mui.ThemeProvider>
}

React.setDisplayName(make, "Cloud")

let default = make
