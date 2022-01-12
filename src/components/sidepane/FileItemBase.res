type state = {
  name: string,
  change: bool,
}

type action =
  | ShowTextfield
  | ChangeName(string)
  | Send

let reducer = (state, action) => {
  switch action {
  | ShowTextfield => {...state, change: true}
  | ChangeName(name) => {...state, name: name}
  | Send => {...state, change: false}
  }
}
