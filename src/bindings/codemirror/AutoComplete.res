@module("@codemirror/language") external syntaxTree: 'editorState => 'tree = "syntaxTree"

let completePropertyAfter = ["PropertyName", ".", "?."]
let dontCompleteIn = [
  "TemplateString",
  "LineComment",
  "BlockComment",
  "VariableDefinition",
  "PropertyDefinition",
]

let completeProperties = (from, object) => {
  let options = []
  let _ =
    object
    ->Js.Dict.entries
    ->Js.Array2.map(tuple => {
      options->Js.Array2.push({
        "label": fst(tuple),
        "type": if snd(tuple) == "function" {
          "function"
        } else {
          "variable"
        },
      })
    })
  {
    "from": from,
    "options": options,
    "span": %re("/^[\w$]*$/"),
  }
}

let completeFromGlobalScope = (context: 'context) => {
  let nodeBefore = syntaxTree(context["state"])["resolveInner"](. context["pos"], -1)
  if (
    completePropertyAfter->Js.Array2.includes(nodeBefore["name"]) &&
      nodeBefore["parent"]["name"] == "MemberExpression"
  ) {
    let object = nodeBefore["parent"]["getChild"](. "Expression")
    if object["name"] == "VariableName" {
      let from = if %re("/\./")->Js.Re.test_(nodeBefore["name"]) {
        nodeBefore["to"]
      } else {
        nodeBefore["from"]
      }
      let variableName = context["state"]["sliceDoc"](. object["from"], object["to"])
      WeblabInterpreter.getType(variableName)
      |> Js.Promise.then_(type_ => {
        if type_ == "object" {
          WeblabInterpreter.listProperties(variableName)
        } else {
          Js.Promise.resolve(Js.Dict.empty())
        }
      })
      |> Js.Promise.then_(props => Js.Promise.resolve(completeProperties(from, props)))
    } else {
      Js.Promise.resolve(completeProperties(context["pos"], Js.Dict.empty()))
    }
  } else if nodeBefore["name"] == "VariableName" {
    WeblabInterpreter.listProperties("") |> Js.Promise.then_(props =>
      Js.Promise.resolve(completeProperties(nodeBefore["from"], props))
    )
  } else if context["explicit"] && !(dontCompleteIn->Js.Array2.includes(nodeBefore["name"])) {
    WeblabInterpreter.listProperties("") |> Js.Promise.then_(props =>
      Js.Promise.resolve(completeProperties(context["pos"], props))
    )
  } else {
    Js.Promise.resolve(completeProperties(context["pos"], Js.Dict.empty()))
  }
}
