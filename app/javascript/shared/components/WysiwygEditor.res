%bs.raw(`require("./WysiwygEditor.css")`)

module JsComponent = {
  @bs.module("./WysiwygEditor") @react.component
  external make: (
    ~tabIndex: int=?,
    ~placeholder: string=?,
    ~ariaLabel: string=?,
    ~onChange: string => unit,
    ~id: string=?,
    ~value: string=?,
  ) => React.element = "default";
}

@react.component
let make =
    (
      ~tabIndex=?,
      ~placeholder=?,
      ~ariaLabel,
      ~onChange,
      ~id,
      ~value,
    ) =>  {
  <JsComponent
    ?tabIndex
    ?placeholder
    ariaLabel
    onChange
    id
    value
  />
}
