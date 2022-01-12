open HubBase

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
let make = () => {
  // Use Hooks to define internal state

  let (session, setSession) = React.useState(() => None)
  let (state, dispatch) = React.useReducer(
    reducer,
    {myNotebooks: None, mostViewed: None, mostViewedCount: None, search: None},
  )

  let (loginDialog, setLoginDialog) = React.useState(() => false)

  let (activeTab, setActiveTab) = React.useState(() => "0")
  let toggle_active_tab = React.useCallback2(tab => {
    if activeTab != tab {
      setActiveTab(_x => tab)
    }
  }, (activeTab, setActiveTab))

  let (darkMode, setDarkMode) = React.useState(() => false)

  let globClasses = Theme.Styles.useStyles()
  let classes = Styles.useStyles()

  // Run computations when component initializes or session updates

  React.useEffect0(() => {
    setSession(_ => SupabaseAuth.session(SupabaseClient.supabase.auth)->Js.Nullable.toOption)
    SupabaseAuth.onAuthStateChange(SupabaseClient.supabase.auth, (_, session) =>
      setSession(_ => session->Js.Nullable.toOption)
    )
    asyncReducer(dispatch, AsyncInitialize(session))
    None
  })

  React.useEffect1(() => {
    asyncReducer(dispatch, AsyncInitializeMyNotebooks(session))
    None
  }, [session])

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

  let myNotebooks = React.useMemo1(() => {
    state.myNotebooks->Belt.Option.map(myNotebooks => {
      <>
        <Mui.Typography
          variant=#h5
          className=classes.heading
          style={ReactDOM.Style.make(
            ~backgroundColor=theme.palette.primary.main,
            ~borderRadius="4px",
            ~color="white",
            (),
          )}>
          {"My Notebooks"->React.string}
        </Mui.Typography>
        <Mui.Box className=classes.grid>
          {myNotebooks
          ->Belt.HashMap.Int.toArray
          ->Belt.Array.map(tup =>
            <NotebookCard
              key={"mynotebooks" ++ string_of_int(fst(tup))} notebook={snd(tup)} dispatch owner=Own
            />
          )
          ->React.array}
        </Mui.Box>
      </>
    })
  }, [state])

  let mostViewed = React.useMemo1(() => {
    state.mostViewed
    ->MyOption.zip(state.mostViewedCount)
    ->Belt.Option.map(tuple => {
      <>
        <Mui.Typography
          variant=#h5
          className=classes.heading
          style={ReactDOM.Style.make(
            ~backgroundColor=theme.palette.primary.main,
            ~borderRadius="4px",
            ~color="white",
            (),
          )}>
          {"Most Viewed"->React.string}
        </Mui.Typography>
        <Mui.Box className=classes.grid>
          {fst(tuple)
          ->Belt.Array.mapWithIndex((i, x) =>
            <NotebookCard key={"mostviewed" ++ string_of_int(i)} notebook=x dispatch owner=Others />
          )
          ->React.array}
        </Mui.Box>
        <Mui.Box height={Mui.Box.Value.int(64)} width={Mui.Box.Value.string("100%")}>
          <Mui.Button
            onClick={_ => asyncReducer(dispatch, AsyncLoadMostViewed(snd(tuple)))}
            color=#primary
            variant=#outlined
            style={ReactDOM.Style.make(~position="absolute", ~left="48%", ())}>
            <Images.ExpandMore /> {"Load more"->React.string}
          </Mui.Button>
        </Mui.Box>
      </>
    })
  }, [state.mostViewed])

  let search = React.useMemo1(() => {
    state.search->Belt.Option.map(arr => {
      <Mui.Box className=classes.grid>
        {arr
        ->Belt.Array.mapWithIndex((i, x) =>
          <NotebookCard key={"search" ++ string_of_int(i)} notebook=x dispatch owner=Others />
        )
        ->React.array}
      </Mui.Box>
    })
  }, [state.search])

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
            ~md=Mui.Box.Value.string("48px auto 1fr"),
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
            <HubDashboard>
              <Search dispatch />
              {switch (search, myNotebooks, mostViewed) {
              | (Some(arr), _, _) => arr
              | (None, Some(myNotebooks), None) => myNotebooks
              | (None, None, Some(mostViewed)) => mostViewed
              | (None, Some(myNotebooks), Some(mostViewed)) => <> myNotebooks mostViewed </>
              | (None, None, None) => React.null
              }}
            </HubDashboard>
          </main>
        </Mui.Box>
      </Mui.Box>
      <Login loginDialog setLoginDialog />
    </Session.SessionContext.Provider>
  </Mui.ThemeProvider>
}

React.setDisplayName(make, "Hub")

let default = make
