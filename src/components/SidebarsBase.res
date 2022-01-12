@get external style: Dom.element => Dom.cssStyleDeclaration = "style"
@set
external setGridTemplateColumns: (Dom.cssStyleDeclaration, string) => unit = "gridTemplateColumns"

let toggle_sidebar = toggle => {
  switch toggle {
  | false =>
    switch ReactDOM.querySelector("#wrapper") {
    | Some(divSidebar) => divSidebar->style->setGridTemplateColumns("48px 0px 1fr")
    | None => ()
    }
  | true =>
    switch ReactDOM.querySelector("#wrapper") {
    | Some(divSidebar) => divSidebar->style->setGridTemplateColumns("48px auto 1fr")
    | None => ()
    }
  }
}
