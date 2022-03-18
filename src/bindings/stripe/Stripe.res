type price = {
  id: string,
  unit_amount: int,
  currency: string,
  product: string,
}
type prices

type product = {
  id: string,
  name: string,
  description: string,
}
type products
type stripeClient = {prices: prices, products: products}

@module("stripe")
external stripe: string => stripeClient = "Stripe"

module Prices = {
  @send external list: prices => Js.Promise.t<{"data": array<price>}> = "list"
}

module Products = {
  @send external list: products => Js.Promise.t<{"data": array<product>}> = "list"
}
