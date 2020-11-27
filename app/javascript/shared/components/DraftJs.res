module ContentState = {
  type t = Js.t<{.}>
}

module EditorState = {
  type t = Js.t<{.}>

  @bs.module("draft-js") @bs.scope("EditorState") external createEmpty: () => t = "createEmpty"
  let createEmpty = createEmpty
  @bs.module("draft-js") @bs.scope("EditorState") external createWithContent: (ContentState.t) => t = "createWithContent"
  let createWithContent = (raw) => createWithContent(raw)

  @bs.send external getCurrentContent: (t) => ContentState.t = "getCurrentContent"
  let getCurrentContent = (state: t) => getCurrentContent(state)
}

module RawDraftContentState = {
  type t = Js.t<{.}>
}

type inlineStyle =
  | Bold
  | Italic
  | Code
  | Underline
  | Strikethrough

module RichUtils = {
  @bs.module("draft-js") @bs.scope("RichUtils") external handleKeyCommand: (EditorState.t, string) => Js.Nullable.t<EditorState.t> = "handleKeyCommand"
  let handleKeyCommand = (state, command) => handleKeyCommand(state, command)->Js.Nullable.toOption

  let inlineStyleToCode = (inlineStyle) => {
    switch inlineStyle {
      | Bold => "BOLD"
      | Italic => "ITALIC"
      | Code => "CODE"
      | Underline => "UNDERLINE"
      | Strikethrough => "STRIKETHROUGH"
    }
  }

  @bs.module("draft-js") @bs.scope("RichUtils") external toggleInlineStyle: (EditorState.t, string) => EditorState.t = "toggleInlineStyle"
  let toggleInlineStyle = (state, inlineStyle) => toggleInlineStyle(state, inlineStyleToCode(inlineStyle))
}

@bs.module("draft-js") external convertToRaw: (ContentState.t) => RawDraftContentState.t = "convertToRaw"
let convertToRaw = (value) => convertToRaw(value)

@bs.module("draft-js") external convertFromRaw: (RawDraftContentState.t) => ContentState.t = "convertFromRaw"
let convertFromRaw  = (value) => convertFromRaw(value)


module Markdown = {
  @bs.module("markdown-draft-js") external draftToMarkdown: (RawDraftContentState.t) => string = "draftToMarkdown"
  let draftToMarkdown  = (value) => draftToMarkdown(value)

  @bs.module("markdown-draft-js") external markdownToDraft: (string) => RawDraftContentState.t = "markdownToDraft"
  let markdownToDraft  = (value) => markdownToDraft(value)
}

module Editor = {
  @bs.module("draft-js") @react.component
  external make: (
    ~id: string=?,
    ~editorState: EditorState.t=?,
    ~handleKeyCommand: string => bool,
    ~onChange: Js.t<{.}> => unit,
    ~ariaLabel: string=?,
    ~tabIndex: int=?,
    ~placeholder: string=?,
  ) => React.element = "Editor";
}

@react.component
let make =
    (
      ~id,
      ~editorState,
      ~handleKeyCommand,
      ~onChange,
      ~ariaLabel,
      ~tabIndex=?,
      ~placeholder=?,
    ) =>  {
  <Editor
    id
    editorState
    handleKeyCommand
    onChange
    ariaLabel
    ?tabIndex
    ?placeholder
  />
}

