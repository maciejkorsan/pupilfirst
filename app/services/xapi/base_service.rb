module Xapi
  class BaseService
    include RoutesResolvable
    attr_reader :agent, :object, :verb, :statement

    def persist
      Xapi.post_statement(remote_lrs: $remote_lrs, statement: @statement)
    end
  end
end
