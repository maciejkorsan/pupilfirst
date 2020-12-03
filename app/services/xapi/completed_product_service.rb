module Xapi
  class CompletedProductService < Xapi::BaseService
    def initialize(agent, course)
      @agent = agent
      @object = object(course)
    end

    def set_statement
      @statement = Xapi.create_statement(actor: @agent, verb: verb, object: @object)
    end

    private

    def verb
      Xapi.create_verb(id: 'http://adlnet.gov/expapi/verbs/completed', name: 'completed')
    end

    def object(course)
      params = {
          id: url_helpers.course_url(course, host: course.school.domains.primary.fqdn),
          name: course.title,
          type: 'http://adlnet.gov/expapi/activities/product',
          description: course.description,
      }

      Xapi.create_activity(params)
    end
  end
end
