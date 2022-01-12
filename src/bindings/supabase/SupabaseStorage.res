type storage

type error = {message: string, status: int}

@send external from: (storage, string) => storage = "from"

@send
external uploadNotebook: (
  storage,
  string,
  string,
) => Js.Promise.t<{
  "data": Js.Nullable.t<{
    "Key": string,
  }>,
  "error": Js.Nullable.t<error>,
}> = "upload"

@send
external updateNotebook: (
  storage,
  string,
  string,
) => Js.Promise.t<{
  "data": Js.Nullable.t<{
    "Key": string,
  }>,
  "error": Js.Nullable.t<error>,
}> = "update"

@send
external removeNotebook: (
  storage,
  array<string>,
) => Js.Promise.t<{
  "data": Js.Nullable.t<{
    "Key": string,
  }>,
  "error": Js.Nullable.t<error>,
}> = "remove"

@send
external getPublicURL: (
  storage,
  string,
) => {"publicURL": Js.Nullable.t<string>, "error": Js.Nullable.t<error>} = "getPublicUrl"

let catch = response => {
  response |> Js.Promise.then_((
    response: {"data": Js.Nullable.t<{"Key": string}>, "error": Js.Nullable.t<error>},
  ) => {
    switch (response["data"]->Js.Nullable.toOption, response["error"]->Js.Nullable.toOption) {
    | (Some(data), None) => Js.Promise.resolve(data)
    | (_, Some(err)) => Js.Promise.reject(raise(Errors.Message(err.message)->Errors.toExn))
    | (_, _) =>
      Js.Promise.reject(raise(Errors.Message("Invalid response from storage.")->Errors.toExn))
    }
  })
}

let catchUnit = response => {
  response |> Js.Promise.then_((
    response: {"data": Js.Nullable.t<{"Key": string}>, "error": Js.Nullable.t<error>},
  ) => {
    switch (response["data"]->Js.Nullable.toOption, response["error"]->Js.Nullable.toOption) {
    | (Some(_), None) => Js.Promise.resolve()
    | (_, Some(err)) => Js.Promise.reject(raise(Errors.Message(err.message)->Errors.toExn))
    | (_, _) =>
      Js.Promise.reject(raise(Errors.Message("Invalid response from storage.")->Errors.toExn))
    }
  })
}
