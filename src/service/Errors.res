@val external alert: 'a => unit = "alert"
@val external confirm: string => bool = "confirm"

type rec error = ..

type error +=
  | NotTheRightFileExtension
  | NoRegularJSONNotebook
  | FileNotFound
  | FileTypeNotSupported
  | UnsupportedOutputType
  | UnsupportedCellType
  | HashmapToArrayConversionFailed
  | InsertNotebookSupabaseFailed
  | NoWeblabError
  | Message(string)
  | MultipleErrors(list<error>)

let rec getErrorMessage = err => {
  switch err {
  | NotTheRightFileExtension => "File has not the right extension."
  | NoRegularJSONNotebook => "Could not parse the JSON in the provided notebook."
  | FileNotFound => "The requested File cannot be found."
  | FileTypeNotSupported => "The file ttpe is not supported."
  | UnsupportedOutputType => "The output type is not supported."
  | UnsupportedCellType => "The cell type is not supported."
  | HashmapToArrayConversionFailed => "Conversion from Hashmap to Array failed."
  | InsertNotebookSupabaseFailed => "Coulnd't insert the notebook into the database."
  | NoWeblabError => "The Exception doesn't contain a Weblab Error."
  | Message(str) => str
  | MultipleErrors(errors) =>
    errors->Belt.List.reduce("", (str, error) => str ++ " " ++ getErrorMessage(error))
  | _ => "Internal Weblab error."
  }
}

let alertError = res => {
  switch res {
  | Ok(_) => ()
  | Error(err) => alert(getErrorMessage(err))
  }
}

exception WeblabError(error)

let toExn = err => {
  raise(WeblabError(err))
}

let fromExn = exn => {
  switch exn {
  | WeblabError(err) => err
  | _ => NoWeblabError
  }
}

let fromPromiseError = error => error->Js.Exn.anyToExnInternal->fromExn
