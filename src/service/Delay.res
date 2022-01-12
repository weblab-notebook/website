@val external setTimeout: (unit => unit, int) => int = "setTimeout"
@val external clearTimeout: int => unit = "clearTimeout"

let timer = ref(0)

let delay = (fn, ms) => {
  args => {
    clearTimeout(timer.contents)
    timer.contents = setTimeout(() => fn(args), ms->Belt.Option.getWithDefault(0))
  }
}
