module Styles = %makeStyles(
  _theme => {
    tabButton: ReactDOM.Style.make(~minWidth="40px", ()),
    svg: ReactDOM.Style.make(~verticalAlign="middle", ~maxHeight="40px", ~maxWidth="40px", ()),
  }
)

@react.component
let make = (~toggle_sidebar, ~activeTab, ~toggle_active_tab, ~children) => {
  let classes = Styles.useStyles()

  <>
    <Mui.Box
      style={ReactDOM.Style.make(
        ~width="48px",
        ~height="56px",
        ~textAlign="center",
        ~lineHeight="56px",
        (),
      )}>
      <Mui.Link href="/">
        <Images.Logo color="secondary" fontSize="large" className=classes.svg />
      </Mui.Link>
    </Mui.Box>
    <Mui.Tabs orientation=#vertical value={Mui.Any.make(activeTab)} textColor=#primary>
      {children->React.Children.mapWithIndex((elem, i) =>
        <Mui.Tab
          label={elem}
          value={Mui.Any.fromString(string_of_int(i))}
          onClick={_event => {
            toggle_active_tab(string_of_int(i))
            toggle_sidebar(true)
            ()
          }}
          className=classes.tabButton
        />
      )}
    </Mui.Tabs>
  </>
}
