type login = {
  email: string,
  password: string,
  alert: option<string>,
}

type loginActions = ChangeEmail(string) | ChangePassword(string) | SetAlert(string) | Clear

let loginReducer = (state, action) => {
  switch action {
  | ChangeEmail(newEmail) => {...state, email: newEmail}
  | ChangePassword(newPassword) => {...state, password: newPassword}
  | SetAlert(alert) => {...state, alert: Some(alert)}
  | Clear => {email: "", password: "", alert: None}
  }
}

type registration = {
  email: string,
  password: string,
  secondPassword: string,
  alert: option<string>,
  success: option<string>,
}

type registrationActions =
  | ChangeEmail(string)
  | ChangePassword(string)
  | ChangeSecondPassword(string)
  | SetAlert(string)
  | Success(string)
  | Clear

let registrationReducer = (state, action) => {
  switch action {
  | ChangeEmail(newEmail) => {...state, email: newEmail}
  | ChangePassword(newPassword) => {...state, password: newPassword}
  | ChangeSecondPassword(newPassword) => {...state, secondPassword: newPassword}
  | SetAlert(alert) => {...state, alert: Some(alert)}
  | Success(success) => {
      email: "",
      password: "",
      secondPassword: "",
      alert: None,
      success: Some(success),
    }
  | Clear => {email: "", password: "", secondPassword: "", alert: None, success: None}
  }
}

type reset = {email: string, alert: option<string>, success: option<string>}

type resetAction = ChangeEmail(string) | SetAlert(string) | Success(string) | Clear

let resetReducer = (state, action) => {
  switch action {
  | ChangeEmail(newEmail) => {...state, email: newEmail}
  | SetAlert(alert) => {...state, alert: Some(alert)}
  | Success(success) => {email: "", alert: None, success: Some(success)}
  | Clear => {email: "", alert: None, success: None}
  }
}

let strongPassword = password => {
  let regex = Js.Re.fromString("(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})")
  regex->Js.Re.test_(password)
}

let samePassword = (password1, password2) => {
  Js.String.startsWith(password1, password2)
}
