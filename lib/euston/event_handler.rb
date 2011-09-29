module Euston
  module EventHandler
    extend ActiveSupport::Concern

    module ClassMethods
      def subscribes type, version, &consumer
        define_method "__event_handler__#{type}__#{version}" do |*args|
          instance_exec *args, &consumer
        end
      end
    end
  end
end
