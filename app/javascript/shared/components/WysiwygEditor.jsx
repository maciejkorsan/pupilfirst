import React from 'react';
import { draftToMarkdown, markdownToDraft } from 'markdown-draft-js';
import {Editor, EditorState, ContentState, RichUtils, convertToRaw, convertFromRaw, CompositeDecorator} from 'draft-js';

const markdownToEditorState = (value) => {
  if (!value) {
    return EditorState.createEmpty();
  }
  const rawData = markdownToDraft(value, {
    remarkablePreset: 'full',
    remarkableOptions: {
      html: true,
      enable: {
        block: 'table',
        core: ['abbr']
      }
    }
  });
  const contentState = convertFromRaw(rawData);
  return EditorState.createWithContent(contentState);
}

const getInitialState = (value) => {
  const state = {
    editorState: markdownToEditorState(value),
    value,
  }
  return state;
}

class WysiwygEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = getInitialState(props.value);
  }

  static getDerivedStateFromProps(props, state) {
    return props.value != state.value ?
      getInitialState(props.value) : null;
  }

  handleKeyCommand(editorState, command, onChange) {
    const newState = RichUtils.handleKeyCommand(editorState, command);
    if (newState) {
      this.onEditorStateChange(newState, onChange);
      return true;
    }

    return false;
  }

  onEditorStateChange(editorState, onChange) {
    const content = editorState.getCurrentContent();
    const rawObject = convertToRaw(content);
    const value = draftToMarkdown(rawObject);
    onChange(value);
    this.setState({
      editorState,
      value,
    });
  }

  render() {
    const { id, ariaLabel, tabIndex, placeholder, onChange } = this.props;
    const { editorState } = this.state;
    return (
      <Editor
        id={id}
        editorState={editorState}
        handleKeyCommand={(command) => this.handleKeyCommand(editorState, command, onChange)}
        onChange={(state) => this.onEditorStateChange(state, onChange)}
        ariaLabel={ariaLabel}
        tabIndex={tabIndex}
        placeholder={placeholder}
      />
    );
  }
}

export default function JsEditor(props) {
  return (
    <WysiwygEditor {...props} />
  );
};
