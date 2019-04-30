[@bs.config {jsx: 3}];

open QuestionsShow__Types;

let str = React.string;

type action =
  | ToggleShowAnswers
  | AddComment(Comment.t)
  | AddAnswer(Answer.t);
type state = {
  answers: list(Answer.t),
  comments: list(Comment.t),
  userData: list(UserData.t),
  showAnswers: bool,
};

let reducer = (state, action) =>
  switch (action) {
  | ToggleShowAnswers => {...state, showAnswers: !state.showAnswers}
  | AddComment(comment) => {
      ...state,
      comments: Comment.addComment(state.comments, comment),
    }
  | AddAnswer(answer) => {
      ...state,
      answers: Answer.addAnswer(state.answers, answer),
    }
  };

[@react.component]
let make =
    (
      ~authenticityToken,
      ~question,
      ~answers,
      ~comments,
      ~userData,
      ~currentUserId,
    ) => {
  let (state, dispatch) =
    React.useReducer(
      reducer,
      {showAnswers: true, answers, comments, userData},
    );
  let addCommentCB = comment => dispatch(AddComment(comment));
  let addAnswerCB = answer => {
    dispatch(AddAnswer(answer));
    dispatch(ToggleShowAnswers);
  };
  <div className="flex flex-1 bg-grey-lighter">
    <div className="flex-1 flex flex-col">
      <div className="flex-col px-6 py-2 items-center justify-between">
        <div className="max-w-md w-full flex justify-center mb-4">
          <a href="#"> {React.string("back")} </a>
        </div>
        <div
          className="max-w-md w-full flex mx-auto items-center justify-center relative shadow bg-white rounded-lg">
          <div className="flex w-full">
            <div className="flex flex-1 flex-col">
              <div className="text-lg border-b-2 py-4 px-6">
                <span className="text-black font-semibold">
                  {question |> Question.title |> str}
                </span>
              </div>
              <div className="py-4 px-6 leading-normal text-sm">
                {question |> Question.description |> str}
              </div>
              <div className="flex flex-row justify-between px-6">
                <div className="px-2 pt-6 text-center">
                  <i className="fal fa-comment-lines text-xl text-grey-dark" />
                  <p className="text-xs pt-1">
                    {
                      state.comments
                      |> Comment.commentsForQuestion
                      |> List.length
                      |> string_of_int
                      |> str
                    }
                  </p>
                </div>
                <QuestionsShow__UserShow
                  userProfile={
                    userData |> UserData.user(question |> Question.userId)
                  }
                  createdAt={question |> Question.createdAt}
                />
              </div>
            </div>
          </div>
        </div>
        <QuestionsShow__CommentShow
          comments={state.comments |> Comment.commentsForQuestion}
          userData
        />
        <QuestionsShow__AddComment
          authenticityToken
          commentableType="Question"
          commentableId={question |> Question.id}
          addCommentCB
          currentUserId
        />
        <div
          className="max-w-md w-full justify-center mx-auto mb-4 py-4 border-b-2">
          <div className="flex justify-between items-end">
            <span className="text-lg font-semibold">
              {
                (
                  state.showAnswers ?
                    (state.answers |> List.length |> string_of_int)
                    ++ " Answers" :
                    "Add Your Answer"
                )
                |> str
              }
            </span>
            <button
              onClick={_ => dispatch(ToggleShowAnswers)}
              className="bg-indigo-dark hover:bg-blue-dark text-white font-bold py-2 px-4 shadow rounded focus:outline-none">
              {(state.showAnswers ? "Add your answer" : "Show Answers") |> str}
            </button>
          </div>
        </div>
        {
          state.showAnswers ?
            state.answers
            |> List.map(answer => {
                 let userProfile =
                   userData |> UserData.user(answer |> Answer.userId);
                 let commentsForAnswer =
                   state.comments
                   |> Comment.commentsForAnswer(answer |> Answer.id);
                 <div className="flex flex-col" key={answer |> Answer.id}>
                   <div
                     className="max-w-md w-full flex mx-auto items-center justify-center relative shadow bg-white rounded-lg mt-4">
                     <div className="flex w-full">
                       <div className="flex flex-1 flex-col">
                         <div className="py-4 px-6 leading-normal text-sm">
                           {answer |> Answer.description |> str}
                         </div>
                         <div className="flex flex-row justify-between px-6">
                           <div className="px-2 pt-6 text-center">
                             <i
                               className="fal fa-comment-lines text-xl text-grey-dark"
                             />
                             <p className="text-xs pt-1">
                               {
                                 commentsForAnswer
                                 |> List.length
                                 |> string_of_int
                                 |> str
                               }
                             </p>
                           </div>
                           <QuestionsShow__UserShow
                             userProfile
                             createdAt={answer |> Answer.createdAt}
                           />
                         </div>
                       </div>
                     </div>
                   </div>
                   <QuestionsShow__CommentShow
                     comments=commentsForAnswer
                     userData
                   />
                   <QuestionsShow__AddComment
                     authenticityToken
                     commentableType="Answer"
                     commentableId={answer |> Answer.id}
                     addCommentCB
                     currentUserId
                   />
                 </div>;
               })
            |> Array.of_list
            |> ReasonReact.array :
            <QuestionsShow__AddAnswer
              question
              authenticityToken
              currentUserId
              addAnswerCB
            />
        }
      </div>
    </div>
  </div>;
};