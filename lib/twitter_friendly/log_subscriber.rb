module TwitterFriendly
  module Logging
    def truncated_payload(payload)
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

    def logger=(logger)
      @@logger = logger
    end
  end

  class TFLogSubscriber < ::ActiveSupport::LogSubscriber
    include Logging

    def start_processing(event)
      payload = event.payload
      name = "TF::Started #{payload.delete(:operation)}"
      debug do
        if payload[:super_operation]
          "  #{name} in #{payload[:super_operation]} at #{Time.now}"
        else
          "#{name} at #{Time.now}"
        end
      end
    end

    def complete_processing(event)
      payload = event.payload
      name = "TF::Completed #{payload.delete(:operation)} in #{event.duration.round(1)}ms"
      debug do
        "#{'  ' if payload[:super_operation]}#{name}#{" #{truncated_payload(payload)}" unless payload.empty?}"
      end
    end

    def twitter_friendly_any(event)
      payload = event.payload
      payload.delete(:name)
      operation = payload.delete(:operation)
      name =
          if operation.to_sym == :collect
            "  TW::#{operation.capitalize} #{payload[:args].last[:super_operation]} in #{payload[:args][0]} (#{event.duration.round(1)}ms)"
          else
            "  TW::#{operation.capitalize} #{payload[:args][0]} (#{event.duration.round(1)}ms)"
          end
      c =
          if %i(encode decode).include?(operation.to_sym)
            YELLOW
          elsif %i(collect).include?(operation.to_sym)
            BLUE
          else
            CYAN
          end
      name = color(name, c, true)
      debug { "  #{'  ' if payload[:tf_super_operation]}#{name}#{" #{truncated_payload(payload)}" unless payload.empty?}" }
    end

    %w(request encode decode collect).each do |operation|
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
      payload = event.payload
      operation = payload[:super_operation] == :fetch ? :fetch : payload[:name]
      hit = %i(read fetch).include?(operation.to_sym) && payload[:hit]
      name = "AS::#{operation.capitalize}#{' (Hit)' if hit} #{payload[:key].split(':')[1]} (#{event.duration.round(1)}ms)"
      name = color(name, MAGENTA, true)
      debug { "  #{'  ' if payload[:tf_super_operation]}#{name} #{(payload.except(:name, :expires_in, :super_operation, :hit, :race_condition_ttl, :tf_super_operation).inspect)}" }
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