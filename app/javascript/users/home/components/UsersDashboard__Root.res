%bs.raw(`require("courses/shared/background_patterns.css")`)
%bs.raw(`require("./UserDashboard__Root.css")`)

let t = I18n.t(~scope="components.UsersDashboard__Root")

open UsersDashboard__Types

let str = React.string

type view =
  | ShowCourses
  | ShowCommunities
  | ShowCertificates

let headerSectiom = (userName, userTitle, avatarUrl, showUserEdit) =>
  <div className="max-w-4xl mx-auto pt-12 flex items-center justify-between px-3 lg:px-0">
    <div className="flex">
      {switch avatarUrl {
      | Some(src) =>
        <img
          className="w-16 h-16 rounded-full border object-cover border-gray-400 rounded-full overflow-hidden flex-shrink-0 mr-4"
          src
        />
      | None =>
        <Avatar
          name=userName
          className="w-16 h-16 mr-4 border border-gray-400 rounded-full overflow-hidden flex-shrink-0"
        />
      }}
      <div className="text-sm flex flex-col justify-center">
        <div className="text-black font-bold inline-block"> {userName->str} </div>
        <div className="text-gray-600 inline-block"> {userTitle->str} </div>
      </div>
    </div>
    {ReactUtils.nullUnless(
      <a className="btn" href="/user/edit">
        <i className="fas fa-edit text-xs md:text-sm mr-2" />
        <span> {t("edit_profile")->str} </span>
      </a>,
      showUserEdit,
    )}
  </div>

let navButtonClasses = selected =>
  "font-semibold border-b-2 border-transparent text-sm py-4 mr-6 focus:outline-none " ++ (
    selected ? "text-primary-500 border-primary-500" : ""
  )

let navSection = (view, setView, communities, issuedCertificates) =>
  <div className="border-b mt-6">
    <div className="flex max-w-4xl mx-auto px-3 lg:px-0">
      <button
        className={navButtonClasses(view == ShowCourses)} onClick={_ => setView(_ => ShowCourses)}>
        <i className="fas fa-book text-xs md:text-sm mr-2" /> <span> {t("my_courses")->str} </span>
      </button>
      {ReactUtils.nullUnless(
        <button
          className={navButtonClasses(view == ShowCommunities)}
          onClick={_ => setView(_ => ShowCommunities)}>
          <i className="fas fa-users text-xs md:text-sm mr-2" />
          <span> {t("communities")->str} </span>
        </button>,
        ArrayUtils.isNotEmpty(communities),
      )}
      {ReactUtils.nullUnless(
        <button
          className={navButtonClasses(view == ShowCertificates)}
          onClick={_ => setView(_ => ShowCertificates)}>
          <i className="fas fa-certificate text-xs md:text-sm mr-2" />
          <span> {t("certificates")->str} </span>
        </button>,
        ArrayUtils.isNotEmpty(issuedCertificates),
      )}
    </div>
  </div>

let coursesSection = (courses, communities, currentSchoolAdmin) =>
  <div className="w-full max-w-4xl mx-auto">
    {ReactUtils.nullUnless(
      <div
        className="flex flex-col mx-auto bg-white rounded-md border p-6 justify-center items-center mt-4">
        <FaIcon classes="fas fa-book text-5xl text-gray-400" />
        <h4 className="mt-3 text-base md:text-lg text-center font-semibold">
          {t("empty_courses")->str}
        </h4>
      </div>,
      ArrayUtils.isEmpty(courses),
    )}
    <div className="flex flex-wrap flex-1 lg:-mx-5">
      {Js.Array.map(course => <UsersDashboard__CourseCard key={course->Course.id} course communities currentSchoolAdmin />, courses)->React.array}
    </div>
  </div>

let communitiesSection = communities =>
  <div className="w-full max-w-4xl mx-auto">
    <div className="flex flex-wrap flex-1 lg:-mx-5">
      {Js.Array.map(
        community =>
          <div
            key={community->Community.id}
            className="flex w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
            <a
              className="w-full h-full shadow rounded-lg hover:shadow-lg"
              href={Community.path(community)}>
              <div
                className="user-dashboard-community__cover flex w-full bg-gray-600 h-40 svg-bg-pattern-5 items-center justify-center p-4 shadow rounded-t-lg"
              />
              <div className="w-full flex justify-between items-center flex-wrap px-4 pt-2 pb-4">
                <h4 className="font-bold text-sm pt-2 leading-tight">
                  {Community.name(community)->str}
                </h4>
                <div className="btn btn-small btn-primary-ghost mt-2">
                  {t("cta.visit_community")->str}
                </div>
              </div>
            </a>
          </div>,
        communities,
      )->React.array}
    </div>
  </div>

let certificatesSection = issuedCertificates =>
  <div className="w-full max-w-4xl mx-auto">
    <div className="flex flex-wrap flex-1 lg:-mx-5">
      {Js.Array.map(
        issuedCertificate =>
          <div
            key={issuedCertificate->IssuedCertificate.id}
            className="flex w-full px-3 lg:px-5 md:w-1/2 mt-6 md:mt-10">
            <a
              className="w-full h-full shadow rounded-lg hover:shadow-lg"
              href={"/c/" ++ issuedCertificate->IssuedCertificate.serialNumber}>
              <div
                className="user-dashboard-community__cover flex w-full bg-gray-600 h-40 svg-bg-pattern-5 items-center justify-center p-4 shadow rounded-t-lg"
              />
              <div className="w-full flex justify-between items-center flex-wrap px-4 pt-2 pb-4">
                <div>
                  <h4 className="font-bold text-sm pt-2 leading-tight">
                    {IssuedCertificate.courseName(issuedCertificate)->str}
                  </h4>
                  <div className="text-xs">
                    <span> {"Issued on:"->str} </span>
                    <span className="ml-1">
                      {issuedCertificate
                      ->IssuedCertificate.createdAt
                      ->DateFns.formatPreset(~short=true, ~year=true, ())
                      ->str}
                    </span>
                  </div>
                </div>
                <div className="btn btn-small btn-primary-ghost mt-2">
                  {t("cta.view_certificate")->str}
                </div>
              </div>
            </a>
          </div>,
        issuedCertificates,
      )->React.array}
    </div>
  </div>

@react.component
let make = (
  ~currentSchoolAdmin,
  ~courses,
  ~communities,
  ~showUserEdit,
  ~userName,
  ~userTitle,
  ~avatarUrl,
  ~issuedCertificates,
) => {
  let (view, setView) = React.useState(() => ShowCourses)
  <div className="bg-gray-100">
    <div className="bg-white">
      {headerSectiom(userName, userTitle, avatarUrl, showUserEdit)}
      {navSection(view, setView, communities, issuedCertificates)}
    </div>
    <div className="pb-8">
      {switch view {
      | ShowCourses => coursesSection(courses, communities, currentSchoolAdmin)
      | ShowCommunities => communitiesSection(communities)
      | ShowCertificates => certificatesSection(issuedCertificates)
      }}
    </div>
  </div>
}
