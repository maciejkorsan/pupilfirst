module TimelineEvents
  class AfterMarkingAsCompleteJob < ApplicationJob
    queue_as :default

    def perform(submission)
      # Refuse to process submissions from reviewed targets.
      return if submission.evaluation_criteria.exists?

      user = submission.founders.first.user
      send_xapi_statement(completed_target_event_for(user.to_xapi_agent, submission.target))

      if TimelineEvents::WasLastTargetService.new(submission).was_last_target?
        send_xapi_statement(completed_course_event_for(user.to_xapi_agent, submission.target.course))
        Startups::IssueCertificateService.new(submission.founders.first.startup).execute
      end
    end

    private

    def completed_target_event_for(user, target)
      Xapi::CompletedTargetService.new(user, target)
    end

    def completed_course_event_for(user, course)
      Xapi::CompletedProductService.new(user, course)
    end

    def send_xapi_statement(event)
      event.set_statement
      event.delay.persist
    end
  end
end
