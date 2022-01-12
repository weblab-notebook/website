@react.component
let make = (
  ~toggle_sidebar,
  ~filesState: FilesBase.filesState,
  ~filesDispatch,
  ~notebookDispatch,
) => {
  let theme = Mui.Core.useTheme()
  let darkMode = Theme.getMode(theme)
  <>
    <Sidepane_Header toggle_sidebar> {"Local Files"->React.string} </Sidepane_Header>
    <Mui.Divider />
    <Mui.Box>
      <Mui.Tooltip title={React.string("New notebook")}>
        <Mui.Button
          color={switch darkMode {
          | Theme.Light => #primary
          | Theme.Dark => #default
          }}
          size=#small
          onClick={evt_ => {
            let name = ref("")
            if !(filesState.files->Belt.HashSet.String.has("untitled.ijsnb")) {
              name.contents = "untitled.ijsnb"
            } else {
              let i = ref(1)
              while (
                filesState.files->Belt.HashSet.String.has(
                  "untitled" ++ string_of_int(i.contents) ++ ".ijsnb",
                )
              ) {
                i.contents = i.contents + 1
              }
              name.contents = "untitled" ++ string_of_int(i.contents) ++ ".ijsnb"
            }
            let notebook = Belt.Array.make(1, NotebookBase.defaultCell())
            let indices = notebook->Belt.Array.mapWithIndex((i, _) => i)->Belt.List.fromArray
            let cells =
              notebook->Belt.Array.mapWithIndex((i, e) => (i, e))->Belt.HashMap.Int.fromArray
            let file = NotebookFormat.notebookCopytoString(indices, cells)
            filesDispatch(FilesBase.AddFile(name.contents, FilesBase.Notebook(file)))
          }}>
          <Images.NoteAdd fontSize="small" />
        </Mui.Button>
      </Mui.Tooltip>
      <Mui.Tooltip title={React.string("Upload file")}>
        <Mui.Button
          size=#small
          color={switch darkMode {
          | Theme.Light => #primary
          | Theme.Dark => #default
          }}>
          <Mui.InputLabel
            htmlFor="openNotebook"
            style={ReactDOM.Style.make(
              ~color={
                switch darkMode {
                | Theme.Light => theme.palette.primary.main
                | Theme.Dark => theme.palette.text.primary
                }
              },
              (),
            )}>
            <Images.Publish fontSize="small" />
          </Mui.InputLabel>
          <Mui.Input
            id="openNotebook"
            \"type"="file"
            style={ReactDOM.Style.make(~display="none", ())}
            inputProps={"accept": "application/.ijsnb"}
            onChange={evt => {
              ReactEvent.Form.preventDefault(evt)
              let file = ReactEvent.Form.target(evt)["files"][0]
              let _ =
                FilesBase.getFileType(file)
                |> Js.Promise.then_(x => {
                  filesDispatch(FilesBase.AddFile(file->Webapi.File.name, x))
                  Js.Promise.resolve()
                })
                |> Js.Promise.catch(x => {
                  Errors.alert(x)
                  Js.Promise.reject(Js.Exn.anyToExnInternal("Failed to add file."))
                })
            }}
          />
        </Mui.Button>
      </Mui.Tooltip>
    </Mui.Box>
    <Mui.Divider style={ReactDOM.Style.make(~marginBottom="8px", ())} />
    <Mui.Box
      border={Mui.Box.Value.int(1)}
      borderColor={Mui.Box.Value.string(theme.palette.action.disabledBackground)}
      borderRadius={Mui.Box.Value.int(8)}
      marginLeft={Mui.Box.Value.int(1)}
      marginRight={Mui.Box.Value.int(1)}
      marginBottom={Mui.Box.Value.int(1)}
      boxShadow={Mui.Box.Value.string("inset 0 0 4px " ++ theme.palette.action.disabledBackground)}
      height={Mui.Box.Value.string("100rem")}>
      <Mui.List dense=true>
        {filesState.files
        ->Belt.HashSet.String.toArray
        ->Belt.Array.map(name =>
          <FileItem key={"fi" ++ name} name filesState filesDispatch notebookDispatch />
        )
        ->React.array}
      </Mui.List>
    </Mui.Box>
  </>
}
