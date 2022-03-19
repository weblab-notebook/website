// declare type Tuple<T = any> = [T] | T[];
// declare type Await<T> = T extends Promise<infer V> ? V : never;
// declare type Config = {
//     lifespan?: number;
//     equal?: (a: any, b: any) => boolean;
// };
// declare const suspend: <Keys extends Tuple<unknown>, Fn extends (...keys: Keys) => Promise<unknown>>(fn: Fn, keys: Keys, config?: Config | undefined) => Await<ReturnType<Fn>>;
// declare const preload: <Keys extends Tuple<unknown>, Fn extends (...keys: Keys) => Promise<unknown>>(fn: Fn, keys: Keys, config?: Config | undefined) => undefined;
// declare const peek: <Keys extends Tuple<unknown>>(keys: Keys) => unknown;
// declare const clear: <Keys extends Tuple<unknown>>(keys?: Keys | undefined) => void;
// export { suspend, clear, preload, peek };
type options<'t> = {
  lifespan: option<int>,
  equal: option<('t, 't) => bool>,
}
@module("suspend-react")
external suspend: ('args => Js.Promise.t<'r>, 'args, option<options<'t>>) => 'r = "suspend"
