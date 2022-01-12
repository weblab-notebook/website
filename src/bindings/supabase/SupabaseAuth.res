type user = {
  id: string,
  aud: string,
  role: string,
  email: string,
}
type session = {
  access_token: string,
  expires_at: int,
  expires_in: int,
  refresh_token: string,
  token_type: string,
  user: user,
}
type data = session

type api
type auth = {api: api}

type error = {message: string, status: int}

@send
external signUp: (
  auth,
  {"email": string, "password": string},
) => Js.Promise.t<{
  "user": Js.Nullable.t<user>,
  "data": Js.Nullable.t<data>,
  "session": Js.Nullable.t<session>,
  "error": Js.Nullable.t<error>,
}> = "signUp"

@send
external signIn: (
  auth,
  {"email": option<string>, "password": option<string>, "provider": option<string>},
) => Js.Promise.t<{
  "user": Js.Nullable.t<user>,
  "data": Js.Nullable.t<data>,
  "session": Js.Nullable.t<session>,
  "error": Js.Nullable.t<error>,
}> = "signIn"

@send external signOut: auth => Js.Promise.t<{"error": Js.Nullable.t<error>}> = "signOut"

@send external user: auth => Js.Nullable.t<user> = "user"

@send external session: auth => Js.Nullable.t<session> = "session"

@send
external onAuthStateChange: (auth, ('a, Js.Nullable.t<session>) => unit) => unit =
  "onAuthStateChange"

@send
external resetPasswordForEmail: (
  api,
  string,
) => Js.Promise.t<{
  "data": Js.Nullable.t<data>,
  "error": Js.Nullable.t<error>,
}> = "resetPasswordForEmail"

@send
external updateUser: (
  api,
  string,
  {"password": string},
) => Js.Promise.t<{
  "data": Js.Nullable.t<data>,
  "error": Js.Nullable.t<error>,
}> = "updateUser"
