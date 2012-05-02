module LastResort
  class Scheduler

    ALL_DAYS = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
    WEEKENDS = [:saturday, :sunday]
    WEEKDAYS = [:monday, :tuesday, :wednesday, :thursday, :friday]


    def initialize config = Config.new
      @config = config
    end

    def get_matching_schedule
      matched_schedule = @config.schedules.find { |schedule| match?(schedule) }

      if matched_schedule.nil?
        puts "No matched schedule"
        nil
      else
        puts "Schedule found -- calling #{matched_schedule[:contacts]}"
        matched_schedule
      end
    end

    def zone_adjusted_time
      Time.now.utc + @config.local_utc_offset_in_seconds
    end

    def match?(schedule, time_to_match = zone_adjusted_time)
      match_hours?(schedule[:hours], time_to_match) && match_days?(schedule[:days], time_to_match)
    end

    def match_hours?(hours, time_to_match)
      expanded_hours = []
      hours.each do |hour|
        expanded_hours += expand_if_possible(hour)
      end

      expanded_hours.any? do |hour|
        if hour.is_a? Range
          hour.include? time_to_match.hour
        elsif hour.is_a? Fixnum
          hour == time_to_match.hour
        end
      end
    end

    def match_days?(days, time_to_match)
      day_of_week = time_to_match.strftime("%A").downcase.to_sym
      expanded_days = []
      days.each do |day|
        expanded_days += expand_if_possible(day)
      end

      expanded_days.include? day_of_week
    end

    def expand_if_possible(symbol_or_time_unit)
      return [symbol_or_time_unit] if
        symbol_or_time_unit.is_a? Fixnum or symbol_or_time_unit.is_a? Range

      case symbol_or_time_unit
      when :all_hours
        [0..23]
      when :off_hours
        [0..8, 17..23]
      when :everyday
        ALL_DAYS
      when :weekdays
        WEEKDAYS
      when :weekends
        WEEKENDS
      when :monday, :tuesday, :wednesday, :thursday, :friday
        [symbol_or_time_unit]
      else
        raise "#{symbol_or_time_unit} is not a recognized expandable symbol"
      end
    end
  end
end