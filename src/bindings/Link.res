@module("gatsby-theme-material-ui") @react.component
external make: (
  ~to: string,
  ~children: React.element,
  ~style: ReactDOM.Style.t=?,
) => React.element = "Link"
