let zip = (opt1, opt2) => {
  switch (opt1, opt2) {
  | (Some(x1), Some(x2)) => Some((x1, x2))
  | _ => None
  }
}
