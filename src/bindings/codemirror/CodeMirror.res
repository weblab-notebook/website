@module("@codemirror/view") external editorView: 'editorView = "EditorView"
@module("@codemirror/view") @new external newEditorView: 'a => 'editorView = "EditorView"
@module("@codemirror/view") external keymap: 'keymap = "keymap"
@module("@codemirror/view")
external highlightSpecialChars: unit => 'extension = "highlightSpecialChars"
@module("@codemirror/view")
external drawSelection: unit => 'extension = "drawSelection"
@module("@codemirror/state") external editorState: 'b = "EditorState"
@module("@codemirror/history") external history: unit => 'extension = "history"
@module("@codemirror/history") external historyKeymap: Js.Array.t<'c> = "historyKeymap"
@module("@codemirror/fold") external foldKeymap: Js.Array.t<'c> = "foldKeymap"
@module("@codemirror/language") external indentOnInput: unit => 'extension = "indentOnInput"
@module("@codemirror/commands") external defaultKeymap: Js.Array.t<'c> = "defaultKeymap"
@module("@codemirror/commands") external indentWithTab: Js.Array.t<'c> = "indentWithTab"
@module("@codemirror/matchbrackets")
external bracketMatching: unit => 'extension = "bracketMatching"
@module("@codemirror/closebrackets") external closeBrackets: unit => 'extension = "closeBrackets"
@module("@codemirror/closebrackets")
external closeBracketsKeymap: Js.Array.t<'c> = "closeBracketsKeymap"
@module("@codemirror/search")
external highlightSelectionMatches: unit => 'extension = "highlightSelectionMatches"
@module("@codemirror/search") external searchKeymap: Js.Array.t<'c> = "searchKeymap"
@module("@codemirror/autocomplete") external autocompletion: unit => 'extension = "autocompletion"
@module("@codemirror/autocomplete") external completionKeymap: Js.Array.t<'c> = "completionKeymap"
@module("@codemirror/comment") external commentKeymap: Js.Array.t<'c> = "commentKeymap"
@module("@codemirror/rectangular-selection")
external rectangularSelection: unit => 'extension = "rectangularSelection"
@module("@codemirror/highlight")
external defaultHighlightStyle: 'd = "defaultHighlightStyle"
@module("@codemirror/theme-one-dark")
external oneDarkHighlightStyle: 'd = "oneDarkHighlightStyle"
@module("@codemirror/lint") external lintKeymap: Js.Array.t<'c> = "lintKeymap"
@module("@codemirror/lang-javascript") external javascript: unit => 'e = "javascript"
@module("@codemirror/lang-javascript")
external javascriptLanguage: 'g = "javascriptLanguage"
@module("@codemirror/lang-markdown") external markdown: unit => 'f = "markdown"
@send external focus: Dom.element => unit = "focus"
@send external blur: Dom.element => unit = "blur"

module MyCodeMirror = {
  @react.component
  let make = (
    ~component,
    ~inputRef,
    ~source,
    ~cell_type,
    ~cellDispatch,
    ~onKeyDown,
    ~onFocus,
    ~className,
    ~onBlur,
    ~onChange,
    ~darkMode,
  ) => {
    let ref = React.useRef(Js.Nullable.null)
    let setRef = element => ref.current = element
    React.useImperativeHandle0(inputRef, () =>
      {
        "focus": () => {
          ref.current->Js.Nullable.toOption->Belt.Option.forEach(x => x->focus)
        },
        "blur": () => {
          ref.current->Js.Nullable.toOption->Belt.Option.forEach(x => x->blur)
        },
      }
    )
    let props = {
      "inputRef": ref,
      "setInputRef": setRef,
      "source": source,
      "cell_type": cell_type,
      "cellDispatch": cellDispatch,
      "onKeyDown": onKeyDown,
      "onFocus": onFocus,
      "className": className,
      "onBlur": onBlur,
      "onChange": onChange,
      "darkMode": darkMode,
    }
    React.createElement(component, props)
  }
}

@react.component
let make = (
  ~inputRef: React.ref<Dom.htmlElement>,
  ~setInputRef,
  ~source,
  ~cell_type,
  ~cellDispatch,
  ~onKeyDown,
  ~onFocus,
  ~className,
  ~onBlur,
  ~onChange,
  ~darkMode,
) => {
  React.useEffect1(() => {
    let onUpdate = () =>
      editorView["updateListener"]["of"](.v => {
        let value = v["state"]["doc"]["toString"](.)
        if value != source.contents {
          cellDispatch(CellBase.ChangeCellText(value))
        }
      })
    let globalJavaScriptCompletions = javascriptLanguage["data"]["of"](. {
      "autocomplete": AutoComplete.completeFromGlobalScope,
    })
    let view = newEditorView({
      "state": editorState["create"](. {
        "doc": source.contents,
        "extensions": [
          highlightSpecialChars(),
          history(),
          drawSelection(),
          editorState["allowMultipleSelections"]["of"](. true),
          indentOnInput(),
          editorView["lineWrapping"],
          if darkMode {
            oneDarkHighlightStyle["fallback"]
          } else {
            defaultHighlightStyle["fallback"]
          },
          bracketMatching(),
          closeBrackets(),
          autocompletion(),
          rectangularSelection(),
          highlightSelectionMatches(),
          keymap["of"](.
            Js.Array.concatMany(
              [
                closeBracketsKeymap,
                searchKeymap,
                historyKeymap,
                foldKeymap,
                commentKeymap,
                completionKeymap,
                lintKeymap,
                indentWithTab,
              ],
              defaultKeymap,
            ),
          ),
          editorView["theme"](. {
            "&.cm-editor.cm-focused": {
              "outline": "none",
            },
          }),
          switch cell_type {
          | CellBase.Code => javascript()
          | CellBase.Markdown => markdown()
          },
          globalJavaScriptCompletions,
          onUpdate(),
        ],
      }),
      "parent": inputRef.current,
    })
    Some(() => {view["destroy"](.)})
  }, [darkMode])
  <div
    ref={ReactDOM.Ref.callbackDomRef(setInputRef)}
    onKeyDown
    onFocus
    className
    onBlur
    onChange
    style={ReactDOM.Style.make(~width="100%", ())}
  />
}
