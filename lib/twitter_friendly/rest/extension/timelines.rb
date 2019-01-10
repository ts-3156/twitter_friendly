module TwitterFriendly
  module REST
    module Extension
      module Timelines

        EVERY_DAY = (0..6)
        WDAY_COUNT = EVERY_DAY.map { |n| [n, 0] }.to_h
        WDAY_NIL_COUNT = EVERY_DAY.map { |n| [n, nil] }.to_h

        EVERY_HOUR = (0..23)
        HOUR_COUNT = EVERY_HOUR.map { |n| [n, 0] }.to_h
        HOUR_NIL_COUNT = EVERY_HOUR.map { |n| [n, nil] }.to_h

        def count_wday(times)
          times.each_with_object(WDAY_COUNT.dup) { |time, memo| memo[time.wday] += 1 }
        end

        def count_hour(times)
          times.each_with_object(HOUR_COUNT.dup) { |time, memo| memo[time.hour] += 1 }
        end

        # [
        #   {:name=>"Sun", :y=>111, :drilldown=>"Sun"},
        #   {:name=>"Mon", :y=>95,  :drilldown=>"Mon"},
        #   {:name=>"Tue", :y=>72,  :drilldown=>"Tue"},
        #   {:name=>"Wed", :y=>70,  :drilldown=>"Wed"},
        #   {:name=>"Thu", :y=>73,  :drilldown=>"Thu"},
        #   {:name=>"Fri", :y=>81,  :drilldown=>"Fri"},
        #   {:name=>"Sat", :y=>90,  :drilldown=>"Sat"}
        # ]
        def usage_stats_wday_series_data(times, day_names:)
          count_wday(times).map do |wday, count|
            {name: day_names[wday], y: count, drilldown: day_names[wday]}
          end
        end

        # [
        #   {
        #     :name=>"Sun",
        #     :id=>"Sun",
        #     :data=> [ ["0", 7], ["1", 12], ... , ["22", 10], ["23", 12] ]
        #   },
        #   ...
        #   {
        #     :name=>"Mon",
        #     :id=>"Mon",
        #     :data=> [ ["0", 22], ["1", 11], ... , ["22", 9], ["23", 14] ]
        #   }
        def usage_stats_wday_drilldown_series(times, day_names:)
          counts =
            EVERY_DAY.each_with_object(WDAY_NIL_COUNT.dup) do |wday, memo|
              memo[wday] = count_hour(times.select { |t| t.wday == wday })
            end

          counts.map { |wday, hour_count| [day_names[wday], hour_count] }.map do |wday, hour_count|
            {name: wday, id: wday, data: hour_count.map { |hour, count| [hour.to_s, count] }}
          end
        end

        # [
        #   {:name=>"0", :y=>66, :drilldown=>"0"},
        #   {:name=>"1", :y=>47, :drilldown=>"1"},
        #   ...
        #   {:name=>"22", :y=>73, :drilldown=>"22"},
        #   {:name=>"23", :y=>87, :drilldown=>"23"}
        # ]
        def usage_stats_hour_series_data(times)
          count_hour(times).map do |hour, count|
            {name: hour.to_s, y: count, drilldown: hour.to_s}
          end
        end

        # [
        #   {:name=>"0", :id=>"0", :data=>[["Sun", 7], ["Mon", 22], ["Tue", 8], ["Wed", 9], ["Thu", 9], ["Fri", 6], ["Sat", 5]]},
        #   {:name=>"1", :id=>"1", :data=>[["Sun", 12], ["Mon", 11], ["Tue", 5], ["Wed", 5], ["Thu", 0], ["Fri", 8], ["Sat", 6]]},
        #   ...
        # ]
        def usage_stats_hour_drilldown_series(times, day_names:)
          counts =
            EVERY_HOUR.each_with_object(HOUR_NIL_COUNT.dup) do |hour, memo|
              memo[hour] = count_wday(times.select { |t| t.hour == hour })
            end

          counts.map do |hour, wday_count|
            {name: hour.to_s, id: hour.to_s, data: wday_count.map { |wday, count| [day_names[wday], count] }}
          end
        end

        # [
        #   {:name=>"Sun", :y=>14.778310502283107},
        #   {:name=>"Mon", :y=>12.273439878234399},
        #   {:name=>"Tue", :y=>10.110578386605784},
        #   {:name=>"Wed", :y=>9.843683409436835},
        #   {:name=>"Thu", :y=>10.547945205479452},
        #   {:name=>"Fri", :y=>10.61773211567732},
        #   {:name=>"Sat", :y=>12.115753424657534}
        # ]
        def twitter_addiction_series(times, day_names:)
          max_duration = 5.minutes
          wday_count =
            EVERY_DAY.each_with_object(WDAY_NIL_COUNT.dup) do |wday, memo|
              target_times = times.select { |t| t.wday == wday }
              memo[wday] =
                if target_times.empty?
                  nil
                else
                  target_times.each_cons(2).map { |newer, older| (newer - older) < max_duration ? newer - older : max_duration }.sum
                end
            end
          days = times.map { |t| t.to_date.to_s(:long) }.uniq.size
          weeks = [days / 7.0, 1.0].max
          wday_count.map do |wday, seconds|
            {name: day_names[wday], y: (seconds.nil? ? nil : seconds / weeks / 60)}
          end
        end

        def usage_stats(tweet_times, day_names: %w(Sun Mon Tue Wed Thu Fri Sat))
          [
            usage_stats_wday_series_data(tweet_times, day_names: day_names),
            usage_stats_wday_drilldown_series(tweet_times, day_names: day_names),
            usage_stats_hour_series_data(tweet_times),
            usage_stats_hour_drilldown_series(tweet_times, day_names: day_names),
            twitter_addiction_series(tweet_times, day_names: day_names)
          ]
        end
      end
    end
  end
end
