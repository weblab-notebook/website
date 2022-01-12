let everyArrayResult = (a : array<Belt.Result.t<'a,'b>>) => {
    a->Belt.Array.reduce(Ok([]),(array,b) => {switch array {
        | Ok(arr) => switch b {
            | Ok(e) => Ok(arr->Belt.Array.concat([e]))
            | Error(y) => Error(y)
        }
        | Error(x) => Error(x)
    }})
}

let everyTuple2Result = (x : ('a,'b)) => {
    switch x {
        | (Ok(a),Ok(b)) => Ok((a,b))
        | (Ok(_), Error(err)) => Error(err)
        | (Error(err), Ok(_)) => Error(err)
        | (Error(err1), Error(err2)) => Error(Errors.MultipleErrors(list{err1,err2}))
    }
}