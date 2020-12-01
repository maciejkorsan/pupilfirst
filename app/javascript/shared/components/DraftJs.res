module DraftInlineStyle = {
  type t = Js.t<{.}>
}

module DraftBlockType = {
  type t = Js.t<{.}>
}

module ContentBlock = {
  type t = Js.t<{.}>

  @bs.send external getType: (t) => DraftBlockType.t = "getType"
  let getType = (block: t) => getType(block)
}

module ContentState = {
  type t = Js.t<{.}>

  @bs.send external getBlockForKey: (t, string) => ContentBlock.t = "getBlockForKey"
  let getBlockForKey = (state: t, key: string) => getBlockForKey(state, key)
}

module SelectionState = {
  type t = Js.t<{.}>

  @bs.send external getStartKey: (t) => string = "getStartKey"
  let getStartKey = (selection: t) => getStartKey(selection)
}

module EditorState = {
  type t = Js.t<{.}>

  @bs.module("draft-js") @bs.scope("EditorState") external createEmpty: () => t = "createEmpty"
  let createEmpty = createEmpty
  @bs.module("draft-js") @bs.scope("EditorState") external createWithContent: (ContentState.t) => t = "createWithContent"
  let createWithContent = (raw) => createWithContent(raw)

  @bs.send external getCurrentContent: (t) => ContentState.t = "getCurrentContent"
  let getCurrentContent = (state: t) => getCurrentContent(state)

  @bs.send external getSelection: (t) => SelectionState.t = "getSelection"
  let getSelection = (state: t) => getSelection(state)

  @bs.send external getCurrentInlineStyle: (t) => DraftInlineStyle.t = "getCurrentInlineStyle"
  let getCurrentInlineStyle = (state: t) => getCurrentInlineStyle(state)
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

type blockType =
  | Unstyled
  | Paragraph
  | H1
  | H2
  | H3
  | H4
  | H5
  | H6
  | Blockquote
  | UL
  | OL
  | CodeBlock

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

  let blockTypeToCode = (blockType) => {
    switch blockType {
      | Unstyled => "unstyled"
      | Paragraph => "paragraph"
      | H1 => "header-one"
      | H2 => "header-two"
      | H3 => "header-three"
      | H4 => "header-four"
      | H5 => "header-five"
      | H6 => "header-six"
      | Blockquote => "blockquote"
      | UL => "unordered-list-item"
      | OL => "ordered-list-item"
      | CodeBlock => "code-block"
    }
  }

  @bs.module("draft-js") @bs.scope("RichUtils") external toggleBlockType: (EditorState.t, string) => EditorState.t = "toggleBlockType"
  let toggleBlockType = (state, blockType) => toggleBlockType(state, blockTypeToCode(blockType))

  @bs.module("draft-js") @bs.scope("RichUtils") external getCurrentBlockType: (EditorState.t, string) => string = "getCurrentBlockType"
  let getCurrentBlockType = (state) => getCurrentBlockType(state)
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

