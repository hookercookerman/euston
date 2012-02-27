module Euston
  class Message
    def self.version version, &block
      raise 'Version numbers must be specified as an Integer' unless version.is_a?(Integer)

      namespaces = self.to_s.split '::'
      class_name = namespaces.pop
      message_type = class_name.underscore
      
      namespace = Object
    
      while (ns = namespaces.shift)
        namespace = namespace.const_get ns
      end

      klass = Class.new do
        extend ActiveModel::Naming
        include ActiveModel::Validations
        include ActiveModel::Validations::Callbacks

        after_validation do
          id = @headers[:id]

          unless id.is_a?(String) && id =~ /^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}$/
            errors[:base] << "Id specified in the headers of a #{class_name} message must be a string Uuid"
          end
        end

        def self.headers hash
          MessageBuilder.new self, hash
        end

        def to_hash
          { headers: @headers, body: @body }
        end

        def read_attribute_for_validation key
          @body[key]
        end
      end

      namespace.const_set "#{class_name}_v#{version}", klass
      
      klass.class_eval <<-EOC, __FILE__, __LINE__ + 1
        def initialize headers = nil, body = nil
          if !headers.nil? && body.nil?
            headers, body = nil, headers
          end

          raise 'Headers must be supplied to #{class_name} messages as a Hash' unless headers.nil? || headers.is_a?(Hash)
          raise 'Body must be supplied to #{class_name} messages as a Hash'    unless body.nil?    || body.is_a?(Hash)

          if headers.nil?
            @headers = { id: Uuid.generate }
          else
            @headers = Marshal.load(Marshal.dump headers)
          end

          @headers.merge! type: :#{message_type}, version: #{version}
          @body = body || {}
        end
      EOC

      klass.class_exec &block
      
      versions[version] = klass
    end

    def self.v version
      versions[version]
    end

    def self.versions
      @versions ||= {}
    end
  end

  class MessageBuilder
    def initialize type, headers
      @type = type
      @headers = headers
    end

    def body hash = {}
      @type.new @headers, hash
    end
  end

  class Command < Message; end
  class Event   < Message; end
end