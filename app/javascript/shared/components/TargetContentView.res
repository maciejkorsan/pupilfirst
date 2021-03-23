%bs.raw(`require("./TargetContentView.css")`)

let str = React.string

let renderBlockClasses = block =>
  switch block |> ContentBlock.blockType {
  | Markdown(_) => "mt-6"
  | File(_) => "mt-6"
  | Image(_) => "mt-6"
  | Embed(_) => "mt-6 pb-7"
  | CoachingSession(_) => "mt-6 pb-7"
  }

let markdownContentBlock = markdown => <MarkdownBlock markdown profile=Markdown.Permissive />

let fileContentBlock = (url, title, filename) =>
  <a
    className="flex justify-between bg-white border rounded-lg px-6 py-4 items-center shadow hover:border-gray-500 hover:bg-gray-100 hover:text-primary-500 hover:shadow-md"
    target="_blank"
    href=url>
    <div className="flex items-center">
      <FaIcon classes="text-4xl text-gray-800 far fa-file-alt" />
      <div className="pl-4 leading-tight">
        <div className="text-lg font-semibold"> {title |> str} </div>
        <div className="text-sm italic text-gray-600"> {filename |> str} </div>
      </div>
    </div>
    <div> <FaIcon classes="text-2xl fas fa-download" /> </div>
  </a>

let imageContentBlock = (url, caption, width) =>
  <div className="rounded-lg bg-white text-center">
    <img className={"mx-auto w-auto md:" ++ ContentBlock.widthToClass(width)} src=url alt=caption />
    <div className="px-4 py-2 text-sm italic"> {caption |> str} </div>
  </div>

let embedContentBlock = embedCode =>
  <div className="learn-content-block__embed" dangerouslySetInnerHTML={"__html": embedCode} />

let coachingSessionBlock = () => {
  let coachingLink = "https://calendly.com/mpraglowski/online"

  let openCalendly = %raw(`
    function (link) {
      Calendly.initPopupWidget({url: link});
      return false
    }
  `)

  <a
    className="flex justify-between bg-white border rounded-lg px-6 py-4 items-center shadow hover:border-gray-500 hover:bg-gray-100 hover:text-primary-500 hover:shadow-md"
    onClick={_ => {openCalendly(coachingLink)}}
    href="#">
    <div className="flex items-center">
      <FaIcon classes="text-4xl text-gray-800 far fa-calendar" />
      <div className="pl-4 leading-tight">
        <div className="text-lg font-semibold"> {"Schedule coaching session" |> str} </div>
      </div>
    </div>
  </a>
}

@react.component
let make = (~contentBlocks) =>
  <div className="text-base" id="learn-component">
    {contentBlocks |> ContentBlock.sort |> Array.map(block => {
      let renderedBlock = switch block |> ContentBlock.blockType {
      | Markdown(markdown) => markdownContentBlock(markdown)
      | File(url, title, filename) => fileContentBlock(url, title, filename)
      | Image(url, caption, width) => imageContentBlock(url, caption, width)
      | Embed(_url, embedCode, _requestType, _lastResolvedAt) =>
        embedCode->Belt.Option.mapWithDefault(React.null, code => embedContentBlock(code))
      | CoachingSession(_lastResolvedAt) => coachingSessionBlock()
      }

      <div className={renderBlockClasses(block)} key={block |> ContentBlock.id}>
        renderedBlock
      </div>
    }) |> React.array}
  </div>
