module LastResort
  class Scheduler

    def initialize config = Config.new
      @config = config
    end

    def get_matching_schedule
      matched_schedule = @config.schedules.find do |schedule|
        match?(schedule)
      end

      if matched_schedule.nil?
        puts "No matched schedule"
        nil
      else
        puts "Schedule found -- calling #{matched_schedule[:contacts]}"
        matched_schedule
      end
    end

    def match?(schedule)
      match_hours?(schedule[:hours]) and match_days?(schedule[:days])
    end

    def match_hours?(hours, time_to_match = Time.now)
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

    def match_days?(days, time_to_match = Time.now)
      day_of_week = time_to_match.strftime("%A").downcase.to_sym

      expanded_days = []
      days.each do |day|
        expanded_days += expand_if_possible(day)
      end

      expanded_days.any? do |day|
        day == day_of_week
      end
    end

    def expand_if_possible(symbol)
      case symbol
      when :all_hours
        [0..23]
      when :off_hours
        [0..8, 17..23]
      when :weekdays
        [:monday, :tuesday, :wednesday, :thursday, :friday]
      when :weekends
        [:saturday, :sunday]
      else
        [symbol]
      end
    end
  end
end