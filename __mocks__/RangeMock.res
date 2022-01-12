type t
@new external createRange: unit => 'a = "Range"
@val external document: 'a = "document"

let setup = () => {
  document["createRange"] = () => {
    let range = createRange()
    range["getBoundingClientRect"] = Jest.JestJs.fn(() => ())
    range["getClientRects"] = () => {
      {"item": () => None, "length": 0}
    }
    range
  }
}
