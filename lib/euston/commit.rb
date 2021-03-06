module Euston
  class Commit
    def initialize options
      defaults = {
        id: Uuid.generate,
        sequence: 1,
        commands: [],
        events: [],
        timestamp: Time.now.utc,
        duration: nil
      }

      options = defaults.merge options

      @commands           = options[:commands]
      @duration           = options[:duration]
      @message_source_id  = options[:message_source_id]
      @events             = options[:events]
      @id                 = options[:id]
      @origin             = options[:origin]
      @sequence           = options[:sequence]
      @timestamp          = options[:timestamp]

      @origin[:headers].delete :origin unless @origin.nil?
    end

    def store_command command
      @commands << marshal_dup(command.to_hash)
    end

    def store_event event
      @events << marshal_dup(event.to_hash).tap { |e| e[:headers][:sequence] = @sequence + @events.length }
    end

    attr_reader :commands, :message_source_id, :events, :id, :origin, :sequence, :timestamp
    attr_accessor :duration

    def empty?
      @commands.empty? && @events.empty?
    end
  end
end
