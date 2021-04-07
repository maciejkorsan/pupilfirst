let t = I18n.t(~scope="components.UsersDashboard__Root")

open UsersDashboard__Types

let str = React.string

let courseLink = (href, title, icon) =>
  <a
    key=href
    href
    className="px-2 py-1 mr-2 mt-2 rounded text-sm bg-gray-100 text-gray-800 hover:bg-gray-200 hover:text-primary-500">
    <i className=icon /> <span className="font-semibold ml-2"> {title->str} </span>
  </a>

let ctaButton = (title, href) =>
  <a
    href
    className="w-full bg-gray-200 mt-4 px-6 py-4 flex text-sm font-semibold justify-between items-center cursor-pointer text-primary-500 hover:bg-gray-300">
    <span> <i className="fas fa-book" /> <span className="ml-2"> {title->str} </span> </span>
    <i className="fas fa-arrow-right" />
  </a>

let ctaText = (message, icon) =>
  <div
    className="w-full bg-red-100 text-red-600 mt-4 px-6 py-4 flex text-sm font-semibold justify-center items-center ">
    <span> <i className=icon /> <span className="ml-2"> {message->str} </span> </span>
  </div>

let studentLink = (courseId, suffix) => "/courses/" ++ (courseId ++ ("/" ++ suffix))

let callToAction = (course, currentSchoolAdmin) =>
  if currentSchoolAdmin {
    #ViewCourse
  } else if course->Course.author {
    #EditCourse
  } else if course->Course.review {
    #ReviewSubmissions
  } else if course->Course.exited {
    #DroppedOut
  } else if course->Course.ended {
    #CourseEnded
  } else if course->Course.accessEnded {
    #AccessEnded
  } else {
    #ViewCourse
  }

let ctaFooter = (course, currentSchoolAdmin) => {
  let courseId = Course.id(course)

  switch callToAction(course, currentSchoolAdmin) {
  | #ViewCourse => ctaButton(t("cta.view_course"), studentLink(courseId, "curriculum"))
  | #EditCourse =>
    ctaButton(t("cta.edit_curriculum"), "/school/courses/" ++ (courseId ++ "/curriculum"))
  | #ReviewSubmissions => ctaButton(t("cta.review_submissions"), studentLink(courseId, "review"))
  | #DroppedOut => ctaText(t("cta.dropped_out"), "fas fa-user-slash")
  | #AccessEnded => ctaText(t("cta.access_ended"), "fas fa-history")
  | #CourseEnded => ctaText(t("cta.course_ended"), "fas fa-history")
  }
}

let communityLinks = (communityIds, communities) => Js.Array.map(id => {
    let community = Js.Array.find(c => Community.id(c) == id, communities)
    switch community {
    | Some(c) =>
      <a
        key={Community.id(c)}
        href={Community.path(c)}
        className="px-2 py-1 mr-2 mt-2 rounded text-sm bg-gray-100 text-gray-800 hover:bg-gray-200 hover:text-primary-500">
        <i className="fas fa-users" />
        <span className="font-semibold ml-2"> {Community.name(c)->str} </span>
      </a>
    | None => React.null
    }
  }, communityIds)->React.array

let courseLinks = (course, currentSchoolAdmin, communities) => {
  let courseId = Course.id(course)
  let cta = callToAction(course, currentSchoolAdmin)

  <div className="flex flex-wrap px-4 mt-2">
    {ReactUtils.nullUnless(
      courseLink(
        "/school/courses/" ++ (courseId ++ "/curriculum"),
        "Edit Curriculum",
        "fas fa-check-square",
      ),
      Course.author(course) && cta != #EditCourse,
    )}
    {ReactUtils.nullUnless(
      courseLink(studentLink(courseId, "curriculum"), t("cta.view_curriculum"), "fas fa-book"),
      cta != #ViewCourse,
    )}
    {ReactUtils.nullUnless(
      courseLink(studentLink(courseId, "leaderboard"), t("cta.leaderboard"), "fas fa-calendar-alt"),
      Course.enableLeaderboard(course),
    )}
    {ReactUtils.nullUnless(
      courseLink(
        studentLink(courseId, "review"),
        t("cta.review_submissions"),
        "fas fa-check-square",
      ),
      Course.review(course) && cta != #ReviewSubmissions,
    )}
    {ReactUtils.nullUnless(
      courseLink(studentLink(courseId, "students"), t("cta.my_students"), "fas fa-user-friends"),
      Course.review(course),
    )}
    {communityLinks(Course.linkedCommunities(course), communities)}
  </div>
}

@react.component
let make = (
  ~course,
  ~communities,
  ~currentSchoolAdmin
) =>
  <div
    key={course->Course.id}
    ariaLabel={course->Course.name}
    className="course-card">
    <div
      key={course->Course.id}
      className="flex overflow-hidden shadow bg-white rounded-lg flex flex-col justify-between h-full">
      <div>
        <div className="relative">
          <div className="relative pb-1/2 bg-gray-800">
            {switch course->Course.thumbnailUrl {
            | Some(url) => <img className="absolute h-full w-full object-cover" src=url />
            | None =>
              <div
                className="user-dashboard-course__cover absolute h-full w-full svg-bg-pattern-1"
              />
            }}
          </div>
          <div
            className="user-dashboard-course__title-container absolute w-full flex items-center h-16 bottom-0 z-50"
            key={course->Course.id}>
            <h4
              className="user-dashboard-course__title text-white font-semibold leading-tight pl-6 pr-4 text-lg md:text-xl">
              {Course.name(course)->str}
            </h4>
          </div>
        </div>
        <div
          className="user-dashboard-course__description text-sm px-6 pt-4 w-full leading-relaxed">
          {Course.description(course)->str}
        </div>
        {if course->Course.exited && (!(course->Course.review) && !(course->Course.author)) {
          <div className="text-sm py-4 bg-red-100 rounded mt-2 px-6">
            {t("course_locked_message")->str}
          </div>
        } else {
          <div> {courseLinks(course, currentSchoolAdmin, communities)} </div>
        }}
      </div>
      <div> {ctaFooter(course, currentSchoolAdmin)} </div>
    </div>
  </div>
