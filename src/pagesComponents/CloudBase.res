@scope(("process", "env")) @val
external stripeJsKey: string = "GATSBY_STRIPE_PUBLIC_KEY"

let stripeJsProm = StripeJs.loadStripe(stripeJsKey)

let processSubscription = (session: SupabaseAuth.session) => {
  let idProm =
    Bs_fetch.fetchWithInit(
      "https://us-central1-scenic-treat-317309.cloudfunctions.net/subscription-test",
      Bs_fetch.RequestInit.make(
        ~method_=Bs_fetch.Post,
        ~headers=Bs_fetch.HeadersInit.make({
          "Content-Type": "application/json",
        }),
        ~body=Bs_fetch.BodyInit.make(
          Js.Json.stringifyAny({
            "access_token": session.access_token,
          })->Belt.Option.getWithDefault(""),
        ),
        (),
      ),
    )
    |> Js.Promise.then_(Bs_fetch.Response.json)
    |> Js.Promise.then_(response => {
      switch response->Js.Json.classify {
      | Js.Json.JSONObject(dict) =>
        switch dict->Js.Dict.get("id") {
        | Some(jSONid) =>
          switch jSONid->Js.Json.classify {
          | Js.Json.JSONString(id) => Js.Promise.resolve(id)
          | _ =>
            Js.Promise.reject(
              Errors.Message("Error: The checkout session \"id\" is not a string")->Errors.toExn,
            )
          }
        | None =>
          Js.Promise.reject(
            Errors.Message(
              "Error: The response from starting the checkout session doesn't contain an \"id\" field",
            )->Errors.toExn,
          )
        }
      | _ =>
        Js.Promise.reject(
          Errors.Message(
            "Error: The response from starting the checkout session didn't containt a JSON Object.",
          )->Errors.toExn,
        )
      }
    })
  let _ =
    Js.Promise.all2((stripeJsProm, idProm))
    |> Js.Promise.then_(tuple => {
      let (stripeJs, id) = (fst(tuple), snd(tuple))
      stripeJs->StripeJs.redirectToCheckout({"sessionId": id})
    })
    |> Js.Promise.catch(error => {
      Error(Errors.fromPromiseError(error))->Errors.alertError
      Js.Promise.resolve()
    })
}
