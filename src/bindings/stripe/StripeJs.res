type stripeJs

@module("@stripe/stripe-js")
external loadStripe: string => Js.Promise.t<stripeJs> = "loadStripe"

@send
external redirectToCheckout: (stripeJs, {"sessionId": string}) => Js.Promise.t<unit> =
  "redirectToCheckout"
