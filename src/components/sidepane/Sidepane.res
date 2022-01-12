module Styles = %makeStyles(
  _theme => {
    sideboard2Tab: ReactDOM.Style.make(
      ~padding="0px",
      ~display="flex",
      ~flexDirection="column",
      ~maxHeight="100vh",
      (),
    ),
    tabHeading: ReactDOM.Style.make(~display="inline", ()),
    closeButton: ReactDOM.Style.make(~float="right", ()),
  }
)

@react.component
let make = (~activeTab, ~children: React.element) => {
  let classes = Styles.useStyles()

  <Mui.Box style={ReactDOM.Style.make(~minWidth="256px", ~maxWidth="256px", ~height="100vh", ())}>
    <MuiLab.TabContext value=activeTab>
      {children->React.Children.mapWithIndex((elem, i) =>
        <MuiLab.TabPanel value={string_of_int(i)} className=classes.sideboard2Tab>
          elem
        </MuiLab.TabPanel>
      )}
    </MuiLab.TabContext>
  </Mui.Box>
}
