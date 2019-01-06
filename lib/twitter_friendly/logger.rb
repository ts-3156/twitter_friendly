require 'forwardable'
require 'fileutils'
require 'logger'

module TwitterFriendly
  class Logger
    extend Forwardable
    def_delegators :@logger, :debug, :info, :warn, :level

    def initialize(options = {})
      path = options[:log_dir] || File.join('.twitter_friendly')
      FileUtils.mkdir_p(path) unless File.exists?(path)

      @logger = ::Logger.new(File.join(path, 'twitter_friendly.log'))
      @logger.level = options[:log_level] || :debug
    end
  end
end