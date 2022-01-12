@val external import_: string => Js.Promise.t<'a> = "import"

let parse: string => Js.Promise.t<string> = input =>
  import_(%raw(`"@weblab-notebook/weblab-markdown"+""`))
  |> Js.Promise.then_(module_ => Js.Promise.resolve(module_["markdown"](input)))
  |> Js.Promise.catch(_ => Js.Promise.resolve("Failed to import module weblab-markdown"))
