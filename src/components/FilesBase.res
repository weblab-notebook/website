type storage
@scope("window") @val external localStorage: storage = "localStorage"
@scope(("window", "localStorage")) @val external storageLength: int = "length"
@send external setItem: (storage, string, string) => unit = "setItem"
@send external getItem: (storage, string) => Js.Nullable.t<string> = "getItem"
@send external removeItem: (storage, string) => unit = "removeItem"
@send external key: (storage, int) => string = "key"

type file =
  | Notebook(string)
  | PythonNotebook(string)
  | PlainText(string)
  | JSON(string)

type filesState = {files: Belt.HashSet.String.t}

type filesActions =
  | AddFile(string, file)
  | Setup(string, file)
  | DeleteFile(string)
  | ChangeName(string, string)

let filesReducer = (state, action) => {
  switch action {
  | AddFile(name, file_) => {
      state.files->Belt.HashSet.String.add(name)
      switch file_ {
      | Notebook(file) =>
        let _ = localStorage->setItem(name, file)
      | PythonNotebook(file) =>
        let _ = localStorage->setItem(name, file)
      | PlainText(_) => ()
      | JSON(_) => ()
      }
      {files: state.files}
    }
  | Setup(name, file) => {
      for i in 0 to storageLength - 1 {
        let key = localStorage->key(i)
        if (
          key |> Js.String.endsWith(".ijsnb") ||
          key |> Js.String.endsWith(".ipynb") ||
          key |> Js.String.endsWith(".json") ||
          key |> Js.String.endsWith(".txt")
        ) {
          state.files->Belt.HashSet.String.add(key)
        }
      }
      state.files->Belt.HashSet.String.add(name)
      switch file {
      | Notebook(file) =>
        let _ = localStorage->setItem(name, file)
      | PythonNotebook(file) =>
        let _ = localStorage->setItem(name, file)
      | PlainText(_) => ()
      | JSON(_) => ()
      }
      {files: state.files}
    }
  | DeleteFile(name) => {
      state.files->Belt.HashSet.String.remove(name)
      localStorage->removeItem(name)
      {files: state.files}
    }
  | ChangeName(oldName, newName) => {
      if (
        state.files->Belt.HashSet.String.has(oldName) &&
          !(state.files->Belt.HashSet.String.has(newName))
      ) {
        localStorage
        ->getItem(oldName)
        ->Js.Nullable.toOption
        ->Belt.Option.forEach(item => {
          state.files->Belt.HashSet.String.remove(oldName)
          state.files->Belt.HashSet.String.add(newName)
          localStorage->setItem(newName, item)
          localStorage->removeItem(oldName)
        })
      }
      {files: state.files}
    }
  }
}

let getFileType = file => {
  let fileName = file->Webapi.File.name
  if fileName |> Js.String.endsWith(".ijsnb") {
    file->Webapi.File.text |> Js.Promise.then_(x => Js.Promise.resolve(Notebook(x)))
  } else if fileName |> Js.String.endsWith(".ipynb") {
    file->Webapi.File.text |> Js.Promise.then_(x => Js.Promise.resolve(PythonNotebook(x)))
  } else if fileName |> Js.String.endsWith(".json") {
    Js.Promise.resolve(JSON(Webapi.Url.createObjectURL(file)))
  } else if fileName |> Js.String.endsWith(".txt") {
    file->Webapi.File.text |> Js.Promise.then_(x => Js.Promise.resolve(PlainText(x)))
  } else {
    Js.Promise.reject(Js.Exn.anyToExnInternal("Wrong file extension"))
  }
}

let get = (files: Belt.HashSet.String.t, name) => {
  if files->Belt.HashSet.String.has(name) {
    if name |> Js.String.endsWith(".ijsnb") {
      switch localStorage->getItem(name)->Js.Nullable.toOption {
      | Some(item) => Ok(Notebook(item))
      | None => Error(Errors.FileNotFound)
      }
    } else if name |> Js.String.endsWith(".ipynb") {
      switch localStorage->getItem(name)->Js.Nullable.toOption {
      | Some(item) => Ok(PythonNotebook(item))
      | None => Error(Errors.FileNotFound)
      }
    } else if name |> Js.String.endsWith(".json") {
      switch localStorage->getItem(name)->Js.Nullable.toOption {
      | Some(item) => Ok(JSON(item))
      | None => Error(Errors.FileNotFound)
      }
    } else if name |> Js.String.endsWith(".txt") {
      switch localStorage->getItem(name)->Js.Nullable.toOption {
      | Some(item) => Ok(PlainText(item))
      | None => Error(Errors.FileNotFound)
      }
    } else {
      Error(Errors.FileTypeNotSupported)
    }
  } else {
    Error(Errors.FileNotFound)
  }
}

let fileOpen = (~name, ~files, ~notebookDispatch) => {
  files
  ->get(name)
  ->Belt.Result.map(x =>
    switch x {
    | Notebook(file) => {
        let _ =
          NotebookFormat.parseJSONNotebook(file)
          ->Belt.Result.map(x => {
            NotebookFormat.notebookOpen(name, x, notebookDispatch)
          })
          ->Errors.alertError
      }
    | PythonNotebook(file) => {
        let _ =
          NotebookFormat.parseJSONNotebook(file)
          ->Belt.Result.map(x => {
            NotebookFormat.notebookOpen(name, x, notebookDispatch)
          })
          ->Errors.alertError
      }
    | PlainText(_fileHandle) => ()
    | JSON(_json) => ()
    }
  )
  ->Errors.alertError
}
