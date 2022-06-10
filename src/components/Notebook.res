// Read environment variable GOOGLE_SITE_VERIFICATION
@scope(("process", "env")) @val
external googleSiteVerification: string = "GOOGLE_SITE_VERIFICATION"

let supabase = SupabaseClient.supabase

// Set the inital State

let initialFiles = Belt.HashSet.String.make(~hintSize=10)

let titleSEO = ref(Some("Dashbook - Big Data Platform"))

@react.component
let make = (~location: Webapi.Dom.Location.t, ~name, ~initialIndices, ~initialCells) => {
  // Use Hooks to define internal state

  let (notebookState, notebookDispatch) = React.useReducer(
    NotebookBase.notebookReducer,
    (
      {
        name: name,
        count: initialIndices->Belt.List.length,
        indices: initialIndices,
        cells: initialCells,
      }: NotebookBase.notebookState
    ),
  )

  let selectedCell = React.useRef(None)

  let (filesState, filesDispatch) = React.useReducer(
    FilesBase.filesReducer,
    ({files: initialFiles}: FilesBase.filesState),
  )

  let (session, setSession) = React.useState(() => None)

  let (loginDialog, setLoginDialog) = React.useState(() => false)

  let (darkMode, setDarkMode) = React.useState(() => false)

  let (activeTab, setActiveTab) = React.useState(() => "0")
  let toggle_active_tab = React.useCallback2(tab => {
    if activeTab != tab {
      setActiveTab(_x => tab)
    }
  }, (activeTab, setActiveTab))

  let classes = Theme.Styles.useStyles()

  // Run computations when component initializes or session updates

  React.useEffect0(() => {
    setDarkMode(_ => Theme.initializeDarkMode())
    // If an URL is passed as a UrlSearchParam, it is tried to open the notebook from that url
    if location->Webapi.Dom.Location.search != "" {
      let url =
        Webapi.Url.URLSearchParams.make(location->Webapi.Dom.Location.search)
        ->Webapi.Url.URLSearchParams.get("url")
        ->Belt.Option.getWithDefault("")
      let _ =
        url->Fetch.fetch
        |> Js.Promise.then_(x => {
          x |> Fetch.Response.text
        })
        |> Js.Promise.then_(text => {
          NotebookFormat.parseCell(
            Js.Global.decodeURIComponent(text),
          )->NotebookFormat.convertNotebookJSONtoRE
        })
        |> Js.Promise.then_(x => {
          let oldName =
            Js.String2.split(url, "/")->Js.Array2.pop->Belt.Option.getWithDefault("notebook.ijsnb")
          let name = if (
            LocalStorage.localStorage
            ->LocalStorage.getItem(oldName)
            ->Js.Nullable.toOption
            ->Belt.Option.isSome
          ) {
            Window.prompt(
              "A notebook with that name exists already. Please rename the notebook.",
              oldName,
            )
            ->Js.Nullable.toOption
            ->Belt.Option.getWithDefault(oldName)
          } else {
            oldName
          }
          let welcomeNotebook =
            x->Belt.Result.getWithDefault(Belt.Array.make(1, NotebookBase.defaultCell()))
          let initialIndices =
            welcomeNotebook->Belt.Array.mapWithIndex((i, _) => i)->Belt.List.fromArray
          let initialCells =
            welcomeNotebook->Belt.Array.mapWithIndex((i, e) => (i, e))->Belt.HashMap.Int.fromArray
          filesDispatch(
            Setup(
              name,
              FilesBase.Notebook(NotebookFormat.notebookCopytoString(initialIndices, initialCells)),
            ),
          )
          notebookDispatch(
            NotebookBase.OpenNotebook({
              name: name,
              count: welcomeNotebook->Belt.Array.length,
              indices: initialIndices,
              cells: initialCells,
            }),
          )
          Js.Promise.resolve()
        })
        |> Js.Promise.catch(x => {
          Errors.alert("Error: Failed to load notebook from url.")
          Js.Promise.reject(Js.Exn.anyToExnInternal(x))
        })
    } else {
      // If no notebook is passed as UrlSearchParam, the default notebook is opened
      filesDispatch(
        Setup(
          name,
          FilesBase.Notebook(
            NotebookFormat.notebookCopytoString(notebookState.indices, notebookState.cells),
          ),
        ),
      )
    }
    setSession(_ => SupabaseAuth.session(supabase.auth)->Js.Nullable.toOption)
    SupabaseAuth.onAuthStateChange(supabase.auth, (_, session) =>
      setSession(_ => session->Js.Nullable.toOption)
    )
    titleSEO.contents = None
    None
  })

  // Memoize values that are used by the component later.

  let theme = React.useMemo1(() => Mui.Theme.create(Theme.getThemeProto(darkMode)), [darkMode])

  let topbar = React.useMemo0(() => <Topbar setLoginDialog />)
  let sidebar = React.useMemo2(
    () =>
      <Sidebar toggle_sidebar=SidebarsBase.toggle_sidebar activeTab toggle_active_tab>
        <Mui.Tooltip title={React.string("Files")}> <Images.Folder /> </Mui.Tooltip>
        <Mui.Tooltip title={React.string("Documentation")}> <Images.MenuBook /> </Mui.Tooltip>
        <Mui.Tooltip title={React.string("Settings")}> <Images.Settings /> </Mui.Tooltip>
      </Sidebar>,
    (activeTab, toggle_active_tab),
  )
  let sidepane = React.useMemo6(
    () =>
      <Sidepane activeTab>
        <Sidepane_Files
          toggle_sidebar=SidebarsBase.toggle_sidebar
          filesState
          filesDispatch
          notebookName=notebookState.name
          notebookDispatch
        />
        <Sidepane_Documentation toggle_sidebar=SidebarsBase.toggle_sidebar />
        <Sidepane_Settings toggle_sidebar=SidebarsBase.toggle_sidebar darkMode setDarkMode />
      </Sidepane>,
    (activeTab, filesState, filesDispatch, notebookState, notebookDispatch, darkMode),
  )
  let menu = React.useMemo4(
    () => <Menu notebookState notebookDispatch filesDispatch />,
    (notebookState, notebookDispatch, filesState, filesDispatch),
  )
  let cells = React.useMemo2(
    () =>
      notebookState.indices
      ->Belt.List.toArray
      ->Belt.Array.map(i => (
        i,
        notebookState.cells
        ->Belt.HashMap.Int.get(i)
        ->Belt.Option.getWithDefault(NotebookBase.defaultCell()),
      ))
      ->Belt.Array.map(x =>
        <Cell
          key={notebookState.name ++ "_" ++ string_of_int(fst(x))}
          cellState={snd(x)}
          notebookDispatch
          selectedCell
        />
      )
      ->React.array,
    (notebookState, notebookDispatch),
  )

  // Return the component

  <Mui.ThemeProvider theme>
    <Session.SessionContext.Provider value=session>
      <Mui.CssBaseline />
      <ReactHelmet>
        <link rel="icon" href="favicon.png" type_="image/png" />
        <title>
          {titleSEO.contents
          ->Belt.Option.getWithDefault("Dashbook - " ++ notebookState.name)
          ->React.string}
        </title>
        <meta name="google-site-verification" content=googleSiteVerification />
        <script type_="application/ld+json">
          {`{
          "@context": "https://schema.org",
          "@type": "WebApplication",
          "headline": "Run code and visualize data in an interactive notebook.",
          "applicationCategory": "Machine Learning, Data Science",
          "operatingSystem": "Windows, MacOS, Linux",
          "image": "https://www.weblab.ai/landing1x1.svg"
        }`->React.string}
        </script>
      </ReactHelmet>
      <Mui.Box
        className=classes.sidebar
        boxShadow={Mui.Box.Value.int(2)}
        bgcolor={Mui.Box.Value.string(theme.palette.background.default)}>
        <nav> sidebar </nav>
      </Mui.Box>
      <Mui.Box
        className=classes.wrapper
        id="wrapper"
        gridTemplateColumns={Mui.Box.Value.breakpointObj(
          Mui.Box.BreakpointObj.make(
            ~xs=Mui.Box.Value.string("48px 0px 1fr"),
            ~sm=Mui.Box.Value.string("48px 0px 1fr"),
            ~md=Mui.Box.Value.string("48px auto 1fr"),
            (),
          ),
        )}>
        <Mui.Box className=classes.topbar boxShadow={Mui.Box.Value.int(2)}> topbar </Mui.Box>
        <Mui.Box
          className=classes.sidepane
          boxShadow={Mui.Box.Value.int(3)}
          bgcolor={Mui.Box.Value.string(theme.palette.background.default)}>
          sidepane
        </Mui.Box>
        <Mui.Box
          gridRow={Mui.Box.Value.string("2")}
          gridColumn={Mui.Box.Value.string("3")}
          style={ReactDOM.Style.make(~position="sticky", ~top="0px", ())}
          boxShadow={Mui.Box.Value.int(2)}
          display={Mui.Box.Value.string("flex")}
          bgcolor={Mui.Box.Value.string(theme.palette.background.default)}
          overflow={Mui.Box.Value.string("auto")}
          zIndex=30>
          menu
        </Mui.Box>
        <Mui.Box
          gridRow={Mui.Box.Value.string("3")}
          gridColumn={Mui.Box.Value.string("3")}
          bgcolor={Mui.Box.Value.string(theme.palette.action.selected)}>
          <main> <Dashboard> cells </Dashboard> </main>
        </Mui.Box>
      </Mui.Box>
      <Login loginDialog setLoginDialog />
    </Session.SessionContext.Provider>
  </Mui.ThemeProvider>
}

React.setDisplayName(make, "Notebook")

let default = make
