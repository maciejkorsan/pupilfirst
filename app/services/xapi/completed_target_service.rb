module Xapi
  class CompletedTargetService < Xapi::BaseService
    def initialize(agent, target)
      @agent = agent
      @object = object(target)
      @statement = Xapi.create_statement(actor: @agent, verb: verb, object: @object)
    end

    private

    def verb
      Xapi.create_verb(id: 'https://w3id.org/xapi/dod-isd/verbs/completed-assignment', name: 'completed assignment')
    end

    def object(target)
      params = {
          id: url_helpers.target_url(target, host: target.course.school.domains.primary.fqdn),
          name: target.title,
          description: target.description,
          type: "http://activitystrea.ms/schema/1.0/task"
      }

      Xapi.create_activity(params)
    end
  end
end
