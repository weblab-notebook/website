type owner = Own | Others

// Defines the state of the NotebookHub page

type state = {
  myNotebooks: option<Belt.HashMap.Int.t<SupabaseDatabase.notebook>>,
  mostViewed: option<array<SupabaseDatabase.notebook>>,
  mostViewedCount: option<int>,
  search: option<array<SupabaseDatabase.notebook>>,
}

// To fetch and display the data, two reducers are chained together.
// The first reducer is asynchronous, fetches the data and then calls the second synchronous reducer.
// The second reducer is used to update the UI

// Actions for the synchronous reducer

type actions =
  | Initialize(array<SupabaseDatabase.notebook>, array<SupabaseDatabase.notebook>)
  | InitializeMyNotebooks(array<SupabaseDatabase.notebook>)
  | ClearMyNotebooks
  | InitializeMostViewed(array<SupabaseDatabase.notebook>)
  | LoadMostViewed(array<SupabaseDatabase.notebook>)
  | Search(array<SupabaseDatabase.notebook>)
  | ClearSearch
  | RemoveMyNotebook(int)
  | UpdateMyNotebook(SupabaseDatabase.notebook)

// Actions for the asynchronous reducer

type asyncActions =
  | AsyncInitialize(option<SupabaseAuth.session>)
  | AsyncInitializeMyNotebooks(option<SupabaseAuth.session>)
  | AsyncLoadMostViewed(int)
  | AsyncRemoveMyNotebook(SupabaseAuth.session, string, int)
  | AsyncUpdateMyNotebook(int, SupabaseDatabase.notebook)
  | AsyncSearch(string)

let loadSize = 12

// Synchronous reducer

let reducer = (state, action) => {
  switch action {
  | Initialize(myNotebooks, mostViewed) => {
      search: None,
      myNotebooks: Some(
        myNotebooks
        ->Belt.Array.mapWithIndex((i, x) => (
          x.id->Js.Nullable.toOption->Belt.Option.getWithDefault(i),
          x,
        ))
        ->Belt.HashMap.Int.fromArray,
      ),
      mostViewed: Some(mostViewed),
      mostViewedCount: Some(1),
    }
  | InitializeMyNotebooks(myNotebooks) => {
      ...state,
      myNotebooks: Some(
        myNotebooks
        ->Belt.Array.mapWithIndex((i, x) => (
          x.id->Js.Nullable.toOption->Belt.Option.getWithDefault(i),
          x,
        ))
        ->Belt.HashMap.Int.fromArray,
      ),
      search: None,
    }
  | ClearMyNotebooks => {...state, myNotebooks: None}
  | InitializeMostViewed(mostViewed) => {
      ...state,
      mostViewed: Some(mostViewed),
      mostViewedCount: Some(1),
      search: None,
    }
  | Search(arr) => {
      ...state,
      search: Some(arr),
    }
  | LoadMostViewed(new) =>
    switch (state.mostViewed, state.mostViewedCount) {
    | (Some(old), Some(count)) => {
        ...state,
        mostViewed: Some(Belt.Array.concat(old, new)),
        mostViewedCount: Some(count + 1),
      }
    | _ => state
    }
  | ClearSearch => {...state, search: None}
  | RemoveMyNotebook(id) =>
    switch state.myNotebooks {
    | Some(myNotebooks) => {
        myNotebooks->Belt.HashMap.Int.remove(id)
        {...state, myNotebooks: Some(myNotebooks)}
      }
    | None => state
    }
  | UpdateMyNotebook(notebook) =>
    switch (state.myNotebooks, notebook.id->Js.Nullable.toOption) {
    | (Some(myNotebooks), Some(id)) => {
        myNotebooks->Belt.HashMap.Int.set(id, notebook)
        {...state, myNotebooks: Some(myNotebooks)}
      }
    | _ => state
    }
  }
}

// Asynchronous reducer

let asyncReducer = (dispatch, action) => {
  let _ = switch action {
  | AsyncInitialize(session) =>
    let myNotebooksProm = switch session {
    | Some(session) =>
      SupabaseClient.supabase
      ->SupabaseDatabase.from("notebooks")
      ->SupabaseDatabase.selectNotebook(Some("*, views (count)"), None)
      ->SupabaseDatabase.Filters.eqString("owner_id", session.user.id)
      ->SupabaseDatabase.catch
      |> Js.Promise.then_(data => Js.Promise.resolve(Some(data)))
      |> Js.Promise.catch(error => {
        Error(Errors.fromPromiseError(error))->Errors.alertError
        Js.Promise.resolve(None)
      })
    | None => Js.Promise.resolve(None)
    }
    let mostViewedProm =
      SupabaseClient.supabase
      ->SupabaseDatabase.from("notebooks")
      ->SupabaseDatabase.selectNotebook(Some("*, views (count)"), None)
      ->SupabaseDatabase.Modifiers.order(
        "count",
        Some({"foreignTable": "views", "ascending": false}),
      )
      ->SupabaseDatabase.Modifiers.limit(loadSize, None)
      ->SupabaseDatabase.catch
      |> Js.Promise.then_(data => Js.Promise.resolve(Some(data)))
      |> Js.Promise.catch(error => {
        Error(Errors.fromPromiseError(error))->Errors.alertError
        Js.Promise.resolve(None)
      })
    Js.Promise.all2((myNotebooksProm, mostViewedProm)) |> Js.Promise.then_(args => {
      switch args {
      | (Some(myNotebooks), Some(mostViewed)) => {
          dispatch(Initialize(myNotebooks, mostViewed))
          Js.Promise.resolve()
        }
      | (None, Some(mostViewed)) => {
          dispatch(InitializeMostViewed(mostViewed))
          Js.Promise.resolve()
        }
      | (_, None) => Js.Promise.resolve()
      }
    })
  | AsyncInitializeMyNotebooks(session) =>
    switch session {
    | Some(session) =>
      SupabaseClient.supabase
      ->SupabaseDatabase.from("notebooks")
      ->SupabaseDatabase.selectNotebook(Some("*, views (count)"), None)
      ->SupabaseDatabase.Filters.eqString("owner_id", session.user.id)
      ->SupabaseDatabase.catch
      |> Js.Promise.then_(myNotebooks => {
        dispatch(InitializeMyNotebooks(myNotebooks))
        Js.Promise.resolve()
      })
      |> Js.Promise.catch(error => {
        Error(Errors.fromPromiseError(error))->Errors.alertError
        Js.Promise.resolve()
      })
    | None => {
        dispatch(ClearMyNotebooks)
        Js.Promise.resolve()
      }
    }
  | AsyncLoadMostViewed(count) =>
    SupabaseClient.supabase
    ->SupabaseDatabase.from("notebooks")
    ->SupabaseDatabase.selectNotebook(Some("*, views (count)"), None)
    ->SupabaseDatabase.Modifiers.order("count", Some({"foreignTable": "views", "ascending": false}))
    ->SupabaseDatabase.Modifiers.range(count * loadSize, (count + 1) * loadSize - 1, None)
    ->SupabaseDatabase.catch
    |> Js.Promise.then_(mostViewed => {
      dispatch(LoadMostViewed(mostViewed))
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Error(Errors.fromPromiseError(error))->Errors.alertError
      Js.Promise.resolve()
    })
  | AsyncRemoveMyNotebook(session, name, id) =>
    SupabaseClient.supabase.storage
    ->SupabaseStorage.from("notebooks")
    ->SupabaseStorage.removeNotebook([session.user.id ++ "/" ++ name])
    ->SupabaseStorage.catchUnit
    |> Js.Promise.then_(_ => {
      SupabaseClient.supabase
      ->SupabaseDatabase.from("notebooks")
      ->SupabaseDatabase.deleteNotebook
      ->SupabaseDatabase.Filters.matchId({
        "id": Some(id)->Js.Nullable.fromOption,
      })
      ->SupabaseDatabase.catchUnit
    })
    |> Js.Promise.then_(_ => {
      dispatch(RemoveMyNotebook(id))
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Error(Errors.fromPromiseError(error))->Errors.alertError
      Js.Promise.resolve()
    })
  | AsyncUpdateMyNotebook(id, notebook) =>
    SupabaseClient.supabase
    ->SupabaseDatabase.from("notebooks")
    ->SupabaseDatabase.updateNotebook({...notebook, views: None->Js.Nullable.fromOption})
    ->SupabaseDatabase.Filters.matchId({"id": Some(id)->Js.Nullable.fromOption})
    ->SupabaseDatabase.catchUnit
    |> Js.Promise.then_(_ => {
      dispatch(UpdateMyNotebook(notebook))
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Error(Errors.fromPromiseError(error))->Errors.alertError
      Js.Promise.resolve()
    })
  | AsyncSearch(str) =>
    SupabaseClient.supabase
    ->SupabaseDatabase.from("notebooks")
    ->SupabaseDatabase.selectNotebook(Some("*, views (count)"), None)
    ->SupabaseDatabase.textSearch(
      "tags",
      str
      ->Js.String2.split(" ")
      ->Belt.Array.map(x => {"'" ++ x ++ "' "})
      ->Belt.Array.reduce("", Js.String2.concat)
      ->Js.String2.replaceByRe(%re("/(\s)\'/g"), " | "),
    )
    ->SupabaseDatabase.catch
    |> Js.Promise.then_(arr => {
      dispatch(Search(arr))
      Js.Promise.resolve()
    })
    |> Js.Promise.catch(error => {
      Error(Errors.fromPromiseError(error))->Errors.alertError
      Js.Promise.resolve()
    })
  }
}

let removeNotebookFromNotebookHub = (
  session: SupabaseAuth.session,
  name,
  notebook: SupabaseDatabase.notebook,
) => {
  SupabaseClient.supabase.storage
  ->SupabaseStorage.from("notebooks")
  ->SupabaseStorage.removeNotebook([session.user.id ++ "/" ++ name])
  ->SupabaseStorage.catchUnit
  |> Js.Promise.then_(_ => {
    SupabaseClient.supabase
    ->SupabaseDatabase.from("notebooks")
    ->SupabaseDatabase.deleteNotebook
    ->SupabaseDatabase.Filters.matchId({
      "id": notebook.id,
    })
    ->SupabaseDatabase.catchUnit
  })
  |> Js.Promise.catch(error => {
    Error(Errors.fromPromiseError(error))->Errors.alertError
    Js.Promise.resolve()
  })
}

type Errors.error += NoMarkdownInNotebook

let createPreview = (str: string) => {
  switch NotebookFormat.parseJSONNotebook(str)->Belt.Result.flatMap(notebook => {
    switch notebook.cells->Belt.Array.getBy(cell => cell.cell_type == "markdown") {
    | Some(cell) => Ok(cell)
    | None => Error(NoMarkdownInNotebook)
    }
  }) {
  | Ok(cell) => WeblabMarkdown.parse(cell.source[0])
  | Error(err) => Js.Promise.reject(raise(err->Errors.toExn))
  }
}

type Errors.error += FileExistsInStorage

let shareFileOnNotebookHub = (session: SupabaseAuth.session, files, name: string) => {
  switch files
  ->FilesBase.get(name)
  ->Belt.Result.map(file => {
    switch file {
    | Notebook(text) => text
    | PythonNotebook(text) => text
    | PlainText(text) => text
    | JSON(text) => text
    }
  }) {
  | Ok(file) => {
      let path = session.user.id ++ "/" ++ name
      let previewProm =
        createPreview(file)
        |> Js.Promise.then_(str => Js.Promise.resolve(Some(str)))
        |> Js.Promise.catch(err =>
          switch Errors.fromPromiseError(err) {
          | NoMarkdownInNotebook => Js.Promise.resolve(None)
          | x => Js.Promise.reject(Errors.toExn(x))
          }
        )
      let urlProm =
        SupabaseClient.supabase.storage
        ->SupabaseStorage.from("notebooks")
        ->SupabaseStorage.uploadNotebook(path, file)
        |> Js.Promise.then_((
          response: {
            "data": Js.Nullable.t<{
              "Key": string,
            }>,
            "error": Js.Nullable.t<SupabaseStorage.error>,
          },
        ) => {
          switch response["error"]->Js.Nullable.toOption {
          | None => Js.Promise.resolve()
          | Some(_) =>
            if Errors.confirm("The notebook already exists. Do you want to override it?") {
              Js.Promise.reject(raise(FileExistsInStorage->Errors.toExn))
            } else {
              Js.Promise.reject(
                raise(Errors.Message("The notebook wasn't uploaded to NotebookHub.")->Errors.toExn),
              )
            }
          }
        })
        |> Js.Promise.then_(_ => {
          Js.Promise.resolve(
            SupabaseClient.supabase.storage
            ->SupabaseStorage.from("notebooks")
            ->SupabaseStorage.getPublicURL(path),
          )
        })
        |> Js.Promise.then_((
          response: {
            "publicURL": Js.Nullable.t<string>,
            "error": Js.Nullable.t<SupabaseStorage.error>,
          },
        ) => {
          switch (
            response["error"]->Js.Nullable.toOption,
            response["publicURL"]->Js.Nullable.toOption,
          ) {
          | (_, Some(url)) => Js.Promise.resolve(url)
          | (_, None) =>
            Js.Promise.reject(raise(Errors.Message("Failed to get Public url.")->Errors.toExn))
          }
        })

      let insertProm =
        Js.Promise.all2((urlProm, previewProm))
        |> Js.Promise.then_(output =>
          SupabaseClient.supabase
          ->SupabaseDatabase.from("notebooks")
          ->SupabaseDatabase.insertNotebook({
            id: None->Js.Nullable.fromOption,
            name: Some(name)->Js.Nullable.fromOption,
            owner_id: Some(session.user.id)->Js.Nullable.fromOption,
            public: Some(true)->Js.Nullable.fromOption,
            views: None->Js.Nullable.fromOption,
            preview: snd(output)->Js.Nullable.fromOption,
            created: Some(
              Js.Date.make()->Js.Date.toISOString->Js.String2.slice(~from=0, ~to_=19),
            )->Js.Nullable.fromOption,
            tags: Some("data science")->Js.Nullable.fromOption,
            url: Some(fst(output))->Js.Nullable.fromOption,
          })
          ->SupabaseDatabase.catchUnit
        )
        |> Js.Promise.catch(err => {
          switch Errors.fromPromiseError(err) {
          | FileExistsInStorage =>
            SupabaseClient.supabase.storage
            ->SupabaseStorage.from("notebooks")
            ->SupabaseStorage.updateNotebook(path, file)
            ->SupabaseStorage.catchUnit
          | x => Js.Promise.reject(x->Errors.toExn)
          }
        })
        |> Js.Promise.then_(_ => {
          Js.Promise.resolve(
            SupabaseClient.supabase.storage
            ->SupabaseStorage.from("notebooks")
            ->SupabaseStorage.getPublicURL(path),
          )
        })
        |> Js.Promise.then_((
          response: {
            "publicURL": Js.Nullable.t<string>,
            "error": Js.Nullable.t<SupabaseStorage.error>,
          },
        ) => {
          switch (
            response["error"]->Js.Nullable.toOption,
            response["publicURL"]->Js.Nullable.toOption,
          ) {
          | (_, Some(url)) => Js.Promise.resolve(url)
          | (_, None) =>
            Js.Promise.reject(raise(Errors.Message("Failed to get Public url.")->Errors.toExn))
          }
        })
      Js.Promise.all2((insertProm, previewProm)) |> Js.Promise.then_(output =>
        SupabaseClient.supabase
        ->SupabaseDatabase.from("notebooks")
        ->SupabaseDatabase.updateNotebook({
          id: None->Js.Nullable.fromOption,
          name: Some(name)->Js.Nullable.fromOption,
          owner_id: Some(session.user.id)->Js.Nullable.fromOption,
          public: Some(true)->Js.Nullable.fromOption,
          views: None->Js.Nullable.fromOption,
          preview: snd(output)->Js.Nullable.fromOption,
          created: Some(
            Js.Date.make()->Js.Date.toISOString->Js.String2.slice(~from=0, ~to_=19),
          )->Js.Nullable.fromOption,
          tags: Some("data science")->Js.Nullable.fromOption,
          url: Some(fst(output))->Js.Nullable.fromOption,
        })
        ->SupabaseDatabase.Filters.matchNotebook({
          "name": Some(name)->Js.Nullable.fromOption,
          "owner_id": Some(session.user.id)->Js.Nullable.fromOption,
        })
        ->SupabaseDatabase.catchUnit
      )
    }

  | Error(err) => Js.Promise.reject(raise(err->Errors.toExn))
  }
}
