@val external import_: string => Js.Promise.t<'a> = "import"

let resetEnvs: unit => Js.Promise.t<unit> = () =>
  import_(%raw(`"@weblab-notebook/weblab-interpreter"+""`)) |> Js.Promise.then_(module_ =>
    Js.Promise.resolve(module_["reset_envs"]())
  )

let evalCell: string => Js.Promise.t<CellBase.output> = (input: string) =>
  import_(%raw(`"@weblab-notebook/weblab-interpreter"+""`))
  |> Js.Promise.then_(module_ => module_["eval_cell"](input))
  |> Js.Promise.then_(output => {
    switch Js.Types.classify(output) {
    | Js.Types.JSString(text) => Js.Promise.resolve(CellBase.TextPlain(text))
    | Js.Types.JSObject(_) => Js.Promise.resolve(CellBase.TextHTML(output["outerHTML"]))
    | _ => Js.Promise.reject(Js.Exn.anyToExnInternal("Wrong type of interpreter output."))
    }
  })
