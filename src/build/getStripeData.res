@scope(("process", "env")) @val
external stripeKey: string = "STRIPE_SECRET_KEY"

let stripe = Stripe.stripe(stripeKey)

let getPriceData = () => {
  stripe.prices->Stripe.Prices.list |> Js.Promise.then_(x => Js.Promise.resolve(x["data"]))
}

let getProductData = () => {
  stripe.products->Stripe.Products.list |> Js.Promise.then_(x => Js.Promise.resolve(x["data"]))
}
