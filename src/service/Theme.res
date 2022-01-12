%%raw(`import "@fontsource/noto-sans"`)
%%raw(`import "@fontsource/noto-serif"`)
%%raw(`import "@fontsource/noto-mono"`)

type mode = Light | Dark

let getThemeProto = mode => {
  open Mui.ThemeOptions
  make(
    ~palette=PaletteOptions.make(
      ~\"type"=if mode {
        "dark"
      } else {
        "light"
      },
      ~primary=Primary.make(~main="#3949ab", ~dark="#273377", ~light="#606dbb", ()),
      ~secondary=Secondary.make(~main="#ff3d00", ~dark="#b22a00", ~light="#ff6333", ()),
      ~text={
        if mode {
          TypeText.make(~primary="#dadada", ())
        } else {
          TypeText.make()
        }
      },
      (),
    ),
    ~typography=Typography.make(~fontFamily="Noto Sans, Arial", ~fontSize=14.0, ()),
    (),
  )
}

let getMode = (theme: Mui.Theme.t) => {
  if theme.palette.\"type" == "dark" {
    Dark
  } else {
    Light
  }
}

module Styles = %makeStyles(
  _theme => {
    wrapper: ReactDOM.Style.make(
      ~display="grid",
      ~gridTemplateRows="56px 32px 1fr",
      ~transition="0.2s",
      ~transitionProperty="gridTemplateColumns",
      (),
    ),
    topbar: ReactDOM.Style.make(
      ~gridRow="1",
      ~gridColumnStart="1",
      ~gridColumnEnd="4",
      ~zIndex="50",
      (),
    ),
    sidebar: ReactDOM.Style.make(
      ~position="fixed",
      ~height="100%",
      ~left="0px",
      ~top="0px",
      ~zIndex="60",
      (),
    ),
    sidepane: ReactDOM.Style.make(
      ~position="sticky",
      ~gridRowStart="2",
      ~gridRowEnd="3",
      ~gridColumn="2",
      ~top="0px",
      ~overflow="hidden",
      ~height="100vh",
      ~zIndex="40",
      (),
    ),
  }
)
