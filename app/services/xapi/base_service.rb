module Xapi
  class BaseService
    include RoutesResolvable

    def persist
      Xapi.post_statement(remote_lrs: $remote_lrs, statement: @statement)
    end
  end
end
