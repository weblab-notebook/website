@val external location: Dom.location = "location"
@set external setHref: (Dom.location, string) => unit = "href"

let transOri = Mui.Menu.TransformOrigin.make(
  ~horizontal=Mui.Menu.Horizontal.int(0),
  ~vertical=Mui.Menu.Vertical.int(-40),
  (),
)

module Styles = %makeStyles(
  _theme => {
    cardMedia: ReactDOM.Style.make(
      ~height="128px",
      ~overflow="hidden",
      ~fontSize="8px",
      ~margin="12px",
      (),
    ),
  }
)

@react.component
let make = (~notebook: SupabaseDatabase.notebook, ~dispatch, ~owner) => {
  let (anchorEl, setAnchorEl) = React.useState(() => None)

  let handleClick = event => {
    let target = event->ReactEvent.Mouse.currentTarget
    setAnchorEl(_x => Some(target))
  }

  let handleClose = (_event, _reason) => {
    setAnchorEl(_x => None)
  }

  let classes = Styles.useStyles()
  let session = React.useContext(Session.SessionContext.context)

  let mySession =
    session
    ->MyOption.zip(notebook.owner_id->Js.Nullable.toOption)
    ->Belt.Option.flatMap(tuple =>
      switch owner {
      | HubBase.Own =>
        if fst(tuple).user.id == snd(tuple) {
          Some(fst(tuple))
        } else {
          None
        }
      | HubBase.Others => None
      }
    )

  {
    switch notebook.name->Js.Nullable.toOption {
    | Some(name) =>
      <Mui.Card
        style={ReactDOM.Style.make(
          ~display="flex",
          ~flexDirection="column",
          ~minWidth="256px",
          (),
        )}>
        {switch notebook.preview->Js.Nullable.toOption {
        | Some(svg) =>
          <Mui.CardMedia className=classes.cardMedia>
            {HtmlReactParser.htmlReactParser(svg)}
          </Mui.CardMedia>
        | None =>
          <Mui.CardMedia className=classes.cardMedia>
            <Images.Description fontSize="large" color="primary" />
          </Mui.CardMedia>
        }}
        <Mui.Divider />
        <Mui.CardContent style={ReactDOM.Style.make(~padding="12px", ())}>
          <Mui.Typography
            variant=#h6 style={ReactDOM.Style.make(~paddingBottom="4px", ~overflow="hidden", ())}>
            {name->Js.String2.replace(".ijsnb", "")->React.string}
          </Mui.Typography>
          <Mui.Typography variant=#subtitle2 color=#textSecondary>
            {("Views: " ++
            string_of_int(
              (
                notebook.views
                ->Js.Nullable.toOption
                ->Belt.Option.getWithDefault(({count: 0}: SupabaseDatabase.view))
              ).count,
            ))->React.string}
          </Mui.Typography>
          <Mui.Typography variant=#subtitle2 color=#textSecondary>
            {switch notebook.public->Js.Nullable.toOption {
            | Some(public) =>
              if public {
                "public"->React.string
              } else {
                "private"->React.string
              }
            | None => React.null
            }}
          </Mui.Typography>
          <Mui.Box
            display={Mui.Box.Value.string("flex")}
            flexWrap={Mui.Box.Value.string("wrap")}
            gridGap={Mui.Box.Value.int(4)}
            mt={Mui.Box.Value.int(1)}>
            {switch notebook.tags->Js.Nullable.toOption {
            | Some(arr) =>
              arr
              ->Js.String2.splitByRe(%re("/\s*[,;]\s*/"))
              ->Js.Array2.map(tag =>
                switch tag {
                | Some(str) => <Mui.Chip label={str->React.string} size=#small color=#primary />
                | None => React.null
                }
              )
              ->React.array
            | None => React.null
            }}
          </Mui.Box>
        </Mui.CardContent>
        <Mui.CardActions style={ReactDOM.Style.make(~marginTop="auto", ())}>
          {switch (notebook.url->Js.Nullable.toOption, notebook.id->Js.Nullable.toOption) {
          | (Some(url), Some(row_id)) =>
            <Mui.Tooltip title={"Open"->React.string}>
              <Mui.IconButton
                size=#small
                href={"/?url=" ++ url}
                onClick={evt => {
                  ReactEvent.Mouse.preventDefault(evt)
                  let target = ReactEvent.Mouse.currentTarget(evt)["href"]
                  let _ =
                    SupabaseClient.supabase->SupabaseDatabase.rpc(
                      "incrementviews",
                      Some({"row_id": row_id}),
                    )
                    |> Js.Promise.then_((
                      response: {
                        "data": Js.Nullable.t<array<SupabaseDatabase.notebook>>,
                        "error": Js.Nullable.t<SupabaseDatabase.error>,
                      },
                    ) => {
                      switch (
                        response["data"]->Js.Nullable.toOption,
                        response["error"]->Js.Nullable.toOption,
                      ) {
                      | (Some(_), None) => Js.Promise.resolve()
                      | (_, Some(error)) =>
                        Js.Promise.reject(Errors.Message(error.message)->Errors.toExn)
                      | (None, None) => Js.Promise.resolve()
                      }
                    })
                    |> Js.Promise.catch(error => {
                      Error(Errors.fromPromiseError(error))->Errors.alertError
                      Js.Promise.resolve()
                    })
                    |> Js.Promise.then_(_ => {
                      location->setHref(target)
                      Js.Promise.resolve()
                    })
                }}>
                <Images.OpenInNew />
              </Mui.IconButton>
            </Mui.Tooltip>
          | (_, _) => React.null
          }}
          <Mui.Tooltip title={"More"->React.string}>
            <Mui.IconButton
              size=#small onClick=handleClick style={ReactDOM.Style.make(~marginLeft="auto", ())}>
              <Images.MoreVert />
            </Mui.IconButton>
          </Mui.Tooltip>
          <Mui.Menu
            \"open"={anchorEl->Belt.Option.isSome}
            keepMounted=true
            variant=#menu
            anchorEl={Mui.Any.make(anchorEl)}
            transformOrigin=transOri
            onClose={handleClose}
            transitionDuration={Mui.Menu.TransitionDuration.float(0.2)}
            \"MenuListProps"={"dense": true, "disablePadding": true}>
            {switch notebook.url->Js.Nullable.toOption {
            | Some(url) =>
              <Mui.MenuItem>
                <Mui.ListItemIcon> <Images.SaveAlt fontSize="small" /> </Mui.ListItemIcon>
                <Mui.ListItemText>
                  <a
                    download=name
                    href={url}
                    target="_blank"
                    style={ReactDOM.Style.make(
                      ~textDecoration="none",
                      ~color="black",
                      ~fontSize="14px",
                      (),
                    )}>
                    {"Download"->React.string}
                  </a>
                </Mui.ListItemText>
              </Mui.MenuItem>
            | None => React.null
            }}
            {switch (
              mySession,
              notebook.name->Js.Nullable.toOption,
              notebook.id->Js.Nullable.toOption,
              notebook.public->Js.Nullable.toOption,
              notebook.tags->Js.Nullable.toOption,
            ) {
            | (Some(session), Some(name), Some(id), Some(public), Some(tags)) =>
              [
                <Mui.MenuItem
                  dense=true
                  onClick={evt => {
                    handleClose(evt, "")
                    HubBase.asyncReducer(
                      dispatch,
                      HubBase.AsyncUpdateMyNotebook(
                        id,
                        {...notebook, public: Some(!public)->Js.Nullable.fromOption},
                      ),
                    )
                  }}>
                  <Mui.ListItemIcon>
                    {if public {
                      <Images.Lock fontSize="small" />
                    } else {
                      <Images.LockOpen fontSize="small" />
                    }}
                  </Mui.ListItemIcon>
                  <Mui.ListItemText>
                    {if public {
                      "Make private"->React.string
                    } else {
                      "Make public"->React.string
                    }}
                  </Mui.ListItemText>
                </Mui.MenuItem>,
                <Mui.MenuItem
                  dense=true
                  onClick={evt => {
                    handleClose(evt, "")
                    switch Window.prompt("Please enter new tags.", tags)->Js.Nullable.toOption {
                    | Some(newTags) =>
                      HubBase.asyncReducer(
                        dispatch,
                        HubBase.AsyncUpdateMyNotebook(
                          id,
                          {
                            ...notebook,
                            tags: Some(newTags)->Js.Nullable.fromOption,
                          },
                        ),
                      )
                    | None => ()
                    }
                  }}>
                  <Mui.ListItemIcon> <Images.LocalOffer fontSize="small" /> </Mui.ListItemIcon>
                  <Mui.ListItemText> {"Change tags"->React.string} </Mui.ListItemText>
                </Mui.MenuItem>,
                <Mui.MenuItem
                  dense=true
                  onClick={evt => {
                    handleClose(evt, "")
                    HubBase.asyncReducer(dispatch, HubBase.AsyncRemoveMyNotebook(session, name, id))
                  }}>
                  <Mui.ListItemIcon> <Images.Delete fontSize="small" /> </Mui.ListItemIcon>
                  <Mui.ListItemText> {"Delete"->React.string} </Mui.ListItemText>
                </Mui.MenuItem>,
              ]->React.array
            | _ => React.null
            }}
          </Mui.Menu>
        </Mui.CardActions>
      </Mui.Card>
    | None => React.null
    }
  }
}
