exception InvalidModeForPreview

%bs.raw(`require("./WysiwygMarkdownEditor.css")`)
%bs.raw(`require("draft-js/dist/Draft.css")`)

let markdownToEditorState = (value : string) => {
  value
    -> DraftJs.Markdown.markdownToDraft
    -> DraftJs.convertFromRaw
    -> DraftJs.EditorState.createWithContent
}

let str = React.string

type mode =
  | Fullscreen
  | Windowed

type rec uploadState =
  | Uploading
  | ReadyToUpload(uploadError)
and uploadError = option<string>

type state = {
  id: string,
  mode: mode,
  editorState: DraftJs.EditorState.t,
  uploadState: uploadState,
}

type action =
  | ClickFullscreen
  | PressEscapeKey
  | SetUploadError(uploadError)
  | SetUploading
  | FinishUploading
  | SetEditorState(DraftJs.EditorState.t)

let reducer = (state, action) =>
  switch action {
  | ClickFullscreen =>
    let mode = switch state.mode {
    | Windowed => Fullscreen
    | Fullscreen => Windowed
    }
    {...state, mode: mode}
  | PressEscapeKey =>
    let mode = switch state.mode {
    | Windowed
    | Fullscreen =>
      Windowed
    }
    {...state, mode: mode}
  | SetUploadError(error) => {...state, uploadState: ReadyToUpload(error)}
  | SetUploading => {...state, uploadState: Uploading}
  | FinishUploading => {...state, uploadState: ReadyToUpload(None)}
  | SetEditorState(editorState) => {...state, editorState: editorState}
  }

let computeInitialState = ((value, textareaId, mode)) => {
  let id = switch textareaId {
  | Some(id) => id
  | None => DateTime.randomId()
  }

  let editorState = markdownToEditorState(value)

  {id: id, mode: mode, editorState: editorState, uploadState: ReadyToUpload(None)}
}

let containerClasses = mode =>
  switch mode {
  | Windowed => "relative bg-white"
  | Fullscreen => "bg-white fixed z-50 top-0 left-0 h-screen w-screen flex flex-col"
  }

let modeIcon = (desiredMode, currentMode) => {
  let icon = switch (desiredMode, currentMode) {
  | (#Fullscreen, Windowed) => "fas fa-expand"
  | (#Fullscreen, Fullscreen) => "fas fa-compress"
  }

  <FaIcon classes={"fa-fw " ++ icon} />
}

let onClickFullscreen = (state, send, _event) => {
  switch state.mode {
  | Windowed => TextareaAutosize.destroy(state.id)
  | Fullscreen => () // Do nothing here. We'll fix this in an effect.
  }

  send(ClickFullscreen)
}

let insertAt = (textToInsert, position, sourceText) => {
  let head = sourceText->String.sub(0, position)
  let tail = sourceText->String.sub(position, (sourceText |> String.length) - position)

  head ++ (textToInsert ++ tail)
}

let modifyInlineStyle = (editorState, handleStateChange, inlineStyle: DraftJs.inlineStyle) => {
  handleStateChange(DraftJs.RichUtils.toggleInlineStyle(editorState, inlineStyle))
}

let modifyBlockStyle = (editorState, handleStateChange, blockType: DraftJs.blockType) => {
  handleStateChange(DraftJs.RichUtils.toggleBlockType(editorState, blockType))
}

let controlsContainerClasses = mode =>
  "border bg-gray-100 text-sm px-2 flex justify-between items-end " ++
  switch mode {
  | Windowed => "rounded-t border-gray-400 sticky top-0 z-20"
  | Fullscreen => "border-gray-400 "
  }

let controls = (state, handleStateChange, send) => {
  let buttonClasses = "px-2 py-1 hover:bg-gray-300 hover:text-primary-500 focus:outline-none "
  let {editorState, mode} = state
  let curriedModifyInlineStyle = modifyInlineStyle(editorState, handleStateChange)
  let curriedModifyBlockStyle  = modifyBlockStyle(editorState, handleStateChange)

  <div className={controlsContainerClasses(state.mode)}>
    <div className="flex">
      <div className="bg-white border border-gray-400 rounded-t border-b-0">
        <button
          className=buttonClasses
          onClick={_ => curriedModifyInlineStyle(Bold)}>
          <i className="fas fa-bold fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyInlineStyle(Italic)}>
          <i className="fas fa-italic fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyInlineStyle(Underline)}>
          <i className="fas fa-underline fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyInlineStyle(Strikethrough)}>
          <i className="fas fa-strikethrough fa-fw" />
        </button>
      </div>
      <div className="bg-white border border-gray-400 rounded-t border-b-0 ml-2">
        <button
          className=buttonClasses
          onClick={_ => curriedModifyBlockStyle(Paragraph)}>
          <i className="fas fa-paragraph fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyBlockStyle(H1)}>
          <i className="fas fa-h1 fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyBlockStyle(H2)}>
          <i className="fas fa-h2 fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyBlockStyle(H3)}>
          <i className="fas fa-h3 fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyBlockStyle(Blockquote)}>
          <i className="fas fa-quote-right fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyBlockStyle(CodeBlock)}>
          <i className="fas fa-code fa-fw" />
        </button>
        <button
          className={buttonClasses ++ "border-l border-gray-400"}
          onClick={_ => curriedModifyBlockStyle(Unstyled)}>
          <i className="fas fa-remove-format fa-fw" />
        </button>
      </div>
    </div>
    <div className="py-1">
      <button
        className={buttonClasses ++ "rounded  ml-1 hidden md:inline"}
        onClick={onClickFullscreen(state, send)}>
        {modeIcon(#Fullscreen, mode)}
        {switch mode {
        | Fullscreen =>
          <span className="ml-2 text-xs font-semibold"> {"Exit full-screen" |> str} </span>
        | Windowed => React.null
        }}
      </button>
    </div>
  </div>
}

let modeClasses = mode =>
  switch mode {
  | Windowed => ""
  | Fullscreen => "flex flex-grow"
  }

let editorContainerClasses = mode =>
  "border-r border-gray-400 " ++
  switch mode {
  | Windowed => "border-l"
  | Fullscreen => "w-full"
  }

let focusOnEditor = id => {
  open Webapi.Dom
  document
  |> Document.getElementById(id)
  |> OptionUtils.flatMap(HtmlElement.ofElement)
  |> OptionUtils.mapWithDefault(element => element |> HtmlElement.focus, ())
}

let handleUploadFileResponse = (oldValue, state, send, onChange, json) => {
  let errors = json |> {
    open Json.Decode
    field("errors", array(string))
  }

  if errors == [] {
    let markdownEmbedCode = json |> {
      open Json.Decode
      field("markdownEmbedCode", string)
    }

    let insert = "\n" ++ (markdownEmbedCode ++ "\n")
    send(FinishUploading)
  } else {
    send(SetUploadError(Some("Failed to attach file! " ++ (errors |> Js.Array.joinWith(", ")))))
  }
}

let submitForm = (formId, oldValue, state, send, onChange) =>
  ReactDOMRe._getElementById(formId) |> OptionUtils.mapWithDefault(element => {
    let formData = DomUtils.FormData.create(element)

    Api.sendFormData(
      "/markdown_attachments/",
      formData,
      handleUploadFileResponse(oldValue, state, send, onChange),
      () =>
        send(
          SetUploadError(
            Some("An unexpected error occured! Please reload the page before trying again."),
          ),
        ),
    )
  }, ())

let attachFile = (fileFormId, oldValue, state, send, onChange, event) =>
  switch ReactEvent.Form.target(event)["files"] {
  | [] => ()
  | files =>
    let file = files[0]
    let maxFileSize = 5 * 1024 * 1024

    let error =
      file["size"] > maxFileSize
        ? Some("The maximum file size is 5 MB. Please select another file.")
        : None

    switch error {
    | Some(_) => send(SetUploadError(error))
    | None =>
      send(SetUploading)
      submitForm(fileFormId, oldValue, state, send, onChange)
    }
  }

let footerContainerClasses = mode =>
  "markdown-editor__footer-container border bg-gray-100 flex justify-end items-center " ++
  switch mode {
  | Windowed => "rounded-b border-gray-400"
  | Fullscreen => "border-gray-400"
  }

let footer = (fileUpload, oldValue, state, send, onChange) => {
  let {id} = state
  let fileFormId = id ++ "-file-form"
  let fileInputId = id ++ "-file-input"

  <div className={footerContainerClasses(state.mode)}>
    {<form
      className="flex items-center flex-wrap flex-1 text-sm font-semibold hover:bg-gray-300 hover:text-primary-500"
      id=fileFormId>
      <input name="authenticity_token" type_="hidden" value={AuthenticityToken.fromHead()} />
      <input
        className="hidden"
        type_="file"
        name="markdown_attachment[file]"
        id=fileInputId
        multiple=false
        onChange={attachFile(fileFormId, oldValue, state, send, onChange)}
      />
      {switch state.uploadState {
      | ReadyToUpload(error) =>
        <label className="text-xs px-3 py-2 flex-grow cursor-pointer" htmlFor=fileInputId>
          {switch error {
          | Some(error) =>
            <span className="text-red-500">
              <i className="fas fa-exclamation-triangle mr-2" /> {error |> str}
            </span>
          | None =>
            <span>
              <i className="far fa-file-image mr-2" /> {"Click here to attach a file." |> str}
            </span>
          }}
        </label>
      | Uploading =>
        <span className="text-xs px-3 py-2 flex-grow cursor-wait">
          <i className="fas fa-spinner fa-pulse mr-2" />
          {"Please wait for the file to upload..." |> str}
        </span>
      }}
    </form>->ReactUtils.nullUnless(fileUpload)}
    <a
      href="/help/markdown_editor"
      target="_blank"
      className="flex items-center px-3 py-2 hover:bg-gray-300 hover:text-secondary-500 cursor-pointer">
      <i className="fab fa-markdown text-sm" />
      <span className="text-xs ml-1 font-semibold hidden sm:inline"> {"Need help?" |> str} </span>
    </a>
  </div>
}

let textareaClasses = mode =>
  "w-full outline-none font-mono " ++
  switch mode {
  | Windowed => "p-3"
  | Fullscreen => "px-3 pt-4 pb-8 h-full resize-none"
  }

let onHandleKeyCommand = (handleStateChange, editorState, command) => {
  let newState = DraftJs.RichUtils.handleKeyCommand(editorState, command)
  switch newState {
    | Some(state) => {
      handleStateChange(state)
      true
    }
    | None => false
  }
}

let onChangeWrapper = (send, onChange, editorState) => {
  send(SetEditorState(editorState))
  editorState
    -> DraftJs.EditorState.getCurrentContent
    -> DraftJs.convertToRaw
    -> DraftJs.Markdown.draftToMarkdown
    -> onChange
}

let handleEscapeKey = (send, event) =>
  switch event |> Webapi.Dom.KeyboardEvent.key {
  | "Escape" => send(PressEscapeKey)
  | _anyOtherKey => ()
  }

@react.component
let make = (
  ~value,
  ~onChange,
  ~profile,
  ~textareaId=?,
  ~maxLength=1000,
  ~defaultMode=Windowed,
  ~placeholder=?,
  ~tabIndex=?,
  ~fileUpload=true,
) => {
  let (state, send) = React.useReducerWithMapState(
    reducer,
    (value, textareaId, defaultMode),
    computeInitialState,
  )

  // Reset autosize when switching from full-screen mode.
  React.useEffect1(() => {
    switch state.mode {
    | Windowed => TextareaAutosize.create(state.id)
    | Fullscreen => () // Do nothing. This was handled in the click handler.
    }

    Some(() => TextareaAutosize.destroy(state.id))
  }, [state.mode])

  // Use Escape key to close full-screen mode.
  React.useEffect0(() => {
    let curriedHandler = handleEscapeKey(send)
    let documentEventTarget = {
      open Webapi.Dom
      document |> Document.asEventTarget
    }

    documentEventTarget |> Webapi.Dom.EventTarget.addKeyDownEventListener(curriedHandler)

    Some(
      () =>
        documentEventTarget |> Webapi.Dom.EventTarget.removeKeyDownEventListener(curriedHandler),
    )
  })

  let handleStateChange = (editorState) => onChangeWrapper(send, onChange, editorState)

  <div className={containerClasses(state.mode)}>
    {controls(state, handleStateChange, send)}
    <div className={modeClasses(state.mode)}>
      <div className={editorContainerClasses(state.mode)}>
        <DisablingCover
          containerClasses="h-full"
          disabled={state.uploadState == Uploading}
          message="Uploading...">
          <div className={textareaClasses(state.mode)}>
            <DraftJs.Editor
              id=state.id
              editorState=state.editorState
              handleKeyCommand={(command) => onHandleKeyCommand(handleStateChange, state.editorState, command)}
              onChange={(state) => handleStateChange(state)}
              ariaLabel="Markdown editor"
              ?tabIndex
              ?placeholder
            />
          </div>
        </DisablingCover>
      </div>
    </div>
    {footer(fileUpload, value, state, send, onChange)}
  </div>
}
