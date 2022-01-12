type userAction = Login(SupabaseAuth.user) | Logout

module SessionContext = {
  let context = React.createContext(None)

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value: option<SupabaseAuth.session>, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

let userReducer = (_state, userAction) => {
  switch userAction {
  | Login(user) => Some(user)
  | Logout => None
  }
}
