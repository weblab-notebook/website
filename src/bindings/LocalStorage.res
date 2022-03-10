type storage
@scope("window") @val external localStorage: storage = "localStorage"
@scope(("window", "localStorage")) @val external storageLength: int = "length"
@send external setItem: (storage, string, string) => unit = "setItem"
@send external getItem: (storage, string) => Js.Nullable.t<string> = "getItem"
@send external removeItem: (storage, string) => unit = "removeItem"
@send external key: (storage, int) => string = "key"
