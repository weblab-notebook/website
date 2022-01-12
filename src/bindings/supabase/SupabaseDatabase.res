type view = {count: int}

type notebook = {
  id: Js.Nullable.t<int>,
  name: Js.Nullable.t<string>,
  owner_id: Js.Nullable.t<string>,
  public: Js.Nullable.t<bool>,
  views: Js.Nullable.t<view>,
  preview: Js.Nullable.t<string>,
  created: Js.Nullable.t<string>,
  tags: Js.Nullable.t<string>,
  url: Js.Nullable.t<string>,
}

type table

type error = {message: string, status: int}

@send external from: (SupabaseClient.supabaseClient, string) => table = "from"

@send
external selectNotebook: (
  table,
  option<string>,
  option<'selectOptions>,
) => Js.Promise.t<{
  "data": Js.Nullable.t<array<notebook>>,
  "error": Js.Nullable.t<error>,
}> = "select"

@send
external insertNotebook: (
  table,
  notebook,
) => Js.Promise.t<{
  "data": Js.Nullable.t<array<notebook>>,
  "error": Js.Nullable.t<error>,
}> = "insert"

@send
external updateNotebook: (
  table,
  notebook,
) => Js.Promise.t<{
  "data": Js.Nullable.t<array<notebook>>,
  "error": Js.Nullable.t<error>,
}> = "update"

@send
external deleteNotebook: table => Js.Promise.t<{
  "data": Js.Nullable.t<array<notebook>>,
  "error": Js.Nullable.t<error>,
}> = "delete"

@send
external rpc: (
  SupabaseClient.supabaseClient,
  string,
  option<'a>,
) => Js.Promise.t<{
  "data": Js.Nullable.t<array<notebook>>,
  "error": Js.Nullable.t<error>,
}> = "rpc"

@send
external textSearch: (
  Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
  string,
  string,
) => Js.Promise.t<{
  "data": Js.Nullable.t<array<notebook>>,
  "error": Js.Nullable.t<error>,
}> = "textSearch"

module Modifiers = {
  @send
  external limit: (
    Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
    int,
    option<'limitOptions>,
  ) => Js.Promise.t<{
    "data": Js.Nullable.t<array<notebook>>,
    "error": Js.Nullable.t<error>,
  }> = "limit"
  @send
  external order: (
    Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
    string,
    option<'orderOptions>,
  ) => Js.Promise.t<{
    "data": Js.Nullable.t<array<notebook>>,
    "error": Js.Nullable.t<error>,
  }> = "order"

  @send
  external range: (
    Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
    int,
    int,
    option<'rangeOptions>,
  ) => Js.Promise.t<{
    "data": Js.Nullable.t<array<notebook>>,
    "error": Js.Nullable.t<error>,
  }> = "range"
}

module Filters = {
  @send
  external eqString: (
    Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
    string,
    string,
  ) => Js.Promise.t<{
    "data": Js.Nullable.t<array<notebook>>,
    "error": Js.Nullable.t<error>,
  }> = "eq"

  @send
  external matchNotebook: (
    Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
    {"name": Js.Nullable.t<string>, "owner_id": Js.Nullable.t<string>},
  ) => Js.Promise.t<{
    "data": Js.Nullable.t<array<notebook>>,
    "error": Js.Nullable.t<error>,
  }> = "match"
  @send
  external matchId: (
    Js.Promise.t<{"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>}>,
    {"id": Js.Nullable.t<int>},
  ) => Js.Promise.t<{
    "data": Js.Nullable.t<array<notebook>>,
    "error": Js.Nullable.t<error>,
  }> = "match"
}

let catch = response => {
  response |> Js.Promise.then_((
    response: {"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>},
  ) => {
    switch (response["data"]->Js.Nullable.toOption, response["error"]->Js.Nullable.toOption) {
    | (Some(data), None) => Js.Promise.resolve(data)
    | (_, Some(err)) => Js.Promise.reject(raise(Errors.Message(err.message)->Errors.toExn))
    | (_, _) =>
      Js.Promise.reject(raise(Errors.Message("Invalid response from database.")->Errors.toExn))
    }
  })
}

let catchUnit = response => {
  response |> Js.Promise.then_((
    response: {"data": Js.Nullable.t<array<notebook>>, "error": Js.Nullable.t<error>},
  ) => {
    switch (response["data"]->Js.Nullable.toOption, response["error"]->Js.Nullable.toOption) {
    | (Some(_), None) => Js.Promise.resolve()
    | (_, Some(err)) => Js.Promise.reject(raise(Errors.Message(err.message)->Errors.toExn))
    | (_, _) =>
      Js.Promise.reject(raise(Errors.Message("Invalid response from database.")->Errors.toExn))
    }
  })
}
