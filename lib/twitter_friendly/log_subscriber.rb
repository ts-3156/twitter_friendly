module TwitterFriendly
  module Logging
    def truncated_payload(payload)
      return '' if payload.empty?
      return payload.inspect if !payload.has_key?(:args) || !payload[:args].is_a?(Array) || payload[:args].empty? || !payload[:args][0].is_a?(Array)

      args = payload[:args].dup
      args[0] =
        if args[0].size > 3
          "[#{args[0].take(3).join(', ')} ... #{args[0].size}]"
        else
          args[0].inspect
        end

      {args: args}.merge(payload.except(:args)).inspect
    end

    module_function

    def logger
      @@logger
    end

    # Because TwitterFriendly::Logging is not inherited, passing an instance of logger via module function.
    def logger=(logger)
      @@logger = logger
    end
  end

  class TFLogSubscriber < ::ActiveSupport::LogSubscriber
    include Logging

    def start_processing(event)
      info do
        payload = event.payload
        operation = payload.delete(:operation)

        if payload[:super_operation]
          "TF::Started #{operation} in #{payload[:super_operation][0]} at #{Time.now}"
        else
          "TF::Started #{operation} at #{Time.now}"
        end
      end
    end

    def complete_processing(event)
      info do
        payload = event.payload
        operation = payload.delete(:operation)

        if payload.empty?
          "TF::Completed #{operation} in #{event.duration.round(1)}ms"
        else
          "TF::Completed #{operation} in #{event.duration.round(1)}ms #{truncated_payload(payload)}"
        end
      end
    end

    def collect(event)
      debug do
        payload = event.payload
        payload.delete(:name)
        operation = payload.delete(:operation)
        name = "  TW::#{operation.capitalize} #{payload[:args].last[:super_operation]} in #{payload[:args][0]} (#{event.duration.round(1)}ms)"
        name = color(name, BLUE, true)
        "  #{name}"
      end
    end

    def twitter_friendly_any(event)
      debug do
        payload = event.payload
        payload.delete(:name)
        operation = payload.delete(:operation).capitalize
        args = payload[:args]
        method_name = args.shift

        name = "  TW::#{operation} #{method_name} (#{event.duration.round(1)}ms)"
        c = (%i(Encode Decode).include?(operation.to_sym)) ? YELLOW : CYAN
        name = color(name, c, true)

        if args.size == 1 && args[0].is_a?(Hash) && args[0].empty?
          "  #{name}"
        else
          "  #{name} #{args[1]}"
        end
      end
    end

    %w(request encode decode).each do |operation|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{operation}(event)
          event.payload[:name] = '#{operation}'
          twitter_friendly_any(event)
        end
      METHOD
    end
  end

  class ASLogSubscriber < ::ActiveSupport::LogSubscriber
    include Logging

    def cache_any(event)
      debug do
        payload = event.payload
        operation = payload[:super_operation] == :fetch ? :fetch : payload[:name]
        hit = %i(read fetch).include?(operation.to_sym) && payload[:hit] ? ' (Hit)' : ''
        name = "  AS::#{operation.capitalize}#{hit} #{payload[:key].split('__')[1]} (#{event.duration.round(1)}ms)"
        name = color(name, MAGENTA, true)
        # :name, :expires_in, :super_operation, :hit, :race_condition_ttl, :tf_super_operation, :tf_super_super_operation
        "#{name} #{(payload.slice(:key).inspect)}"
      end
    end

    # Ignore generate and fetch_hit
    %w(read write delete exist?).each do |operation|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def cache_#{operation}(event)
          event.payload[:name] = '#{operation}'
          cache_any(event)
        end
      METHOD
    end
  end
end