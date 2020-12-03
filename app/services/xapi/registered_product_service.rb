module Xapi
  class RegisteredProductService < Xapi::BaseService
    def initialize(agent, course)
      @agent = agent
      @verb = verb
      @object = object(course)
    end

    def set_statement
      @statement = Xapi.create_statement(actor: @agent, verb: verb, object: @object)
    end

    private

    def verb
      Xapi.create_verb(id: 'http://adlnet.gov/expapi/verbs/registered', name: 'registered')
    end

    def object(course)
      params = {
          id: url_helpers.course_url(course, host: course.school.domains.primary.fqdn),
          name: course.name,
          type: 'http://adlnet.gov/expapi/activities/product',
          description: course.description
      }

      if course.ends_at.present?
        elapsed_seconds = ((course.end_at - DateTime.now) * 24 * 60 * 60).to_i
        iso8601_duration = ActiveSupport::Duration.build(elapsed_seconds).iso8601
        params.merge!(extensions: { "http://id.tincanapi.com/extension/planned-duration" => iso8601_duration } )
      end

      Xapi.create_activity(params)
    end
  end
end
