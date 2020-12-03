type inlineStyle =
  | Bold
  | Italic
  | Code
  | Strikethrough

let inlineStyleString = (inlineStyle) =>
  switch inlineStyle {
  | Bold => "BOLD"
  | Italic => "ITALIC"
  | Code => "CODE"
  | Strikethrough => "STRIKETHROUGH"
  }

let parseInlineStyle = (code: string) =>
  switch code {
  | "BOLD" => Some(Bold)
  | "ITALIC" => Some(Italic)
  | "CODE" => Some(Code)
  | "STRIKETHROUGH" => Some(Strikethrough)
  | _ => None
  }

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

let blockTypeString = (blockType) =>
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

let parseBlockType = (code: string) =>
  switch code {
  | "unstyled" => Some(Unstyled)
  | "paragraph" => Some(Paragraph)
  | "header-one" => Some(H1)
  | "header-two" => Some(H2)
  | "header-three" => Some(H3)
  | "header-four" => Some(H4)
  | "header-five" => Some(H5)
  | "header-six" => Some(H6)
  | "blockquote" => Some(Blockquote)
  | "unordered-list-item" => Some(UL)
  | "ordered-list-item" => Some(OL)
  | "code-block" => Some(CodeBlock)
  | _ => None
  }

module ContentBlock = {
  type t = Js.t<{.}>

  @bs.send external getType: (t) => string = "getType"
  let getType = (block: t) => getType(block)

  @bs.send external findEntityRanges: (t, 'a, 'a) => unit = "findEntityRanges"
  let findEntityRanges = (block: t, filterFn, callback) => findEntityRanges(block, filterFn, callback)
}

module DraftEntityInstance = {
  type t = Js.t<{.}>

  type data = {
    url: string,
  }

  @bs.send external getData: (t) => data = "getData"
  let getData = (entity: t) => getData(entity)

  @bs.send external getType: (t) => string = "getType"
  let getType = (block: t) => getType(block)
}

module CharacterMetadata = {
  type t = Js.t<{.}>

  @bs.send external getEntity: (t) => Js.Nullable.t<string> = "getEntity"
  let getEntity = (state: t) => getEntity(state)
}

module ContentState = {
  type t = Js.t<{.}>

  @bs.send external getBlockForKey: (t, string) => ContentBlock.t = "getBlockForKey"
  let getBlockForKey = (state: t, key: string) => getBlockForKey(state, key)

  @bs.send external getEntity: (t, string) => DraftEntityInstance.t = "getEntity"
  let getEntity = (state: t, key: string) => getEntity(state, key)
}

module SelectionState = {
  type t = Js.t<{.}>

  @bs.send external getStartKey: (t) => string = "getStartKey"
  let getStartKey = (selection: t) => getStartKey(selection)
}

module CompositeDecorator = {
  type t = Js.t<{.}>
  @bs.module("draft-js") @bs.new external create: 'a => t = "CompositeDecorator"
}

module EditorState = {
  type t = Js.t<{.}>

  type decoratorParams = {
    contentState: ContentState.t,
    entityKey: string,
    children: React.element,
  }

  let findLinkEntities = (contentBlock, callback, contentState) => {
    let isLink = (state, key) => {
      let entity = ContentState.getEntity(state, key)
      let entityType = DraftEntityInstance.getType(entity)
      entityType === "LINK"
    }

    let filterFn = (state, character) => {
      let entityKey = CharacterMetadata.getEntity(character)

      switch Js.Nullable.toOption(entityKey) {
      | Some(key) => isLink(state, key)
      | _ => false
      }
    }

    ContentBlock.findEntityRanges(contentBlock, filterFn(contentState), callback)
  }

  let link = (props: decoratorParams) => {
    let entity = ContentState.getEntity(props.contentState, props.entityKey)
    let data = DraftEntityInstance.getData(entity)
    <a href={data.url}>props.children</a>
  }

  let decoratorStrategies = [
    {
      "strategy": findLinkEntities,
      "component": link,
    },
  ]
  let decorator = CompositeDecorator.create(decoratorStrategies)

  @bs.module("draft-js") @bs.scope("EditorState") external createEmpty: ('a) => t = "createEmpty"
  let createEmpty = createEmpty(decorator)
  @bs.module("draft-js") @bs.scope("EditorState") external createWithContent: (ContentState.t, 'a) => t = "createWithContent"
  let createWithContent = (raw) => createWithContent(raw, decorator)

  @bs.send external getCurrentContent: (t) => ContentState.t = "getCurrentContent"
  let getCurrentContent = (state: t) => getCurrentContent(state)

  @bs.send external getSelection: (t) => SelectionState.t = "getSelection"
  let getSelection = (state: t) => getSelection(state)

  @bs.send external getCurrentInlineStyle: (t) => string = "getCurrentInlineStyle"
  let getCurrentInlineStyle = (state: t) => getCurrentInlineStyle(state)
}

module RawDraftContentState = {
  type t = Js.t<{.}>
}

module RichUtils = {
  @bs.module("draft-js") @bs.scope("RichUtils") external handleKeyCommand: (EditorState.t, string) => Js.Nullable.t<EditorState.t> = "handleKeyCommand"
  let handleKeyCommand = (state, command) => handleKeyCommand(state, command)->Js.Nullable.toOption

  @bs.module("draft-js") @bs.scope("RichUtils") external toggleInlineStyle: (EditorState.t, string) => EditorState.t = "toggleInlineStyle"
  let toggleInlineStyle = (state, inlineStyle) => toggleInlineStyle(state, inlineStyleString(inlineStyle))

  @bs.module("draft-js") @bs.scope("RichUtils") external toggleBlockType: (EditorState.t, string) => EditorState.t = "toggleBlockType"
  let toggleBlockType = (state, blockType) => toggleBlockType(state, blockTypeString(blockType))

  @bs.module("draft-js") @bs.scope("RichUtils") external getCurrentBlockType: (EditorState.t, string) => string = "getCurrentBlockType"
  let getCurrentBlockType = (state) => getCurrentBlockType(state)
}

@bs.module("draft-js") external convertToRaw: (ContentState.t) => RawDraftContentState.t = "convertToRaw"
let convertToRaw = (value) => convertToRaw(value)

@bs.module("draft-js") external convertFromRaw: (RawDraftContentState.t) => ContentState.t = "convertFromRaw"
let convertFromRaw  = (value) => convertFromRaw(value)


module Markdown = {
  let draftToMarkdownOptions = {
    "styleItems": ()
  }

  @bs.module("markdown-draft-js") external draftToMarkdown: (RawDraftContentState.t, 'a) => string = "draftToMarkdown"
  let draftToMarkdown  = (value, options) => draftToMarkdown(value, options)

  let markdownToDraftOptions = {
    "blockStyles": {
      "del_open": "STRIKETHROUGH",
    },
    "remarkablePreset": "commonmark",
    "remarkableOptions": {
      "enable": {
        "core":  ["abbr"],
        "block": ["table"],
        "inline": ["links", "emphasis", "del"],
      }
    }
  }
  @bs.module("markdown-draft-js") external markdownToDraft: (string, 'a) => RawDraftContentState.t = "markdownToDraft"
  let markdownToDraft  = (value, options) => markdownToDraft(value, options)
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

