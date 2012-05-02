require 'spec_helper'

describe LastResort::Scheduler do

  before :each do
    @config = LastResort::Config.new true
    @config.local_utc_offset_in_seconds = 5 * 60 * 60
    @scheduler = LastResort::Scheduler.new @config
  end

  describe "when expanding schedule times" do
    DAY_NAMES = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

    it "should not expand ranges or fixnums" do
      range = 1..10
      @scheduler.expand_if_possible(range).should == [range]

      hour = 1
      @scheduler.expand_if_possible(hour).should == [hour]
    end

    it "should expand weekend/weekdays to day names" do
      @scheduler.expand_if_possible(:weekends).all? { |day|
        DAY_NAMES.include? day
      }.should == true

      @scheduler.expand_if_possible(:weekdays).all? { |day|
        DAY_NAMES.include? day
      }.should == true
    end

    it "should expand hour keywords to fixnum ranges" do
      @scheduler.expand_if_possible(:all_hours).all? { |time|
        time.is_a? Range
      }.should == true

      @scheduler.expand_if_possible(:off_hours).all? { |time|
        time.is_a? Range
      }.should == true
    end

    it "should raise an error on an unrecognized symbol" do
      ->{ @scheduler.expand_if_possible :no_way! }.should raise_error
    end
  end

  describe "when matching schedules" do
    before :each do
      @schedule = {
        :hours => [0..23],
        :days => [:everyday]
      }
    end

    it "zone adjusted time should be in UTC" do
      @scheduler.zone_adjusted_time.utc?.should == true
    end

    it "should match without a time argument" do
      @scheduler.match?(@schedule).should == true
    end

    it "should match when the schedule contains a time that falls into the described times/days" do
      @scheduler.match?(@schedule, Time.now).should == true
    end

    it "should not match when the time matches and the day doesn't" do
      @schedule[:days] = [:monday]
      @scheduler.match?(@schedule, Time.new(1983, 4, 21)).should == false
    end

    it "should not match when the day matches and the time doesn't" do
      @schedule[:hours] = [23]
      @scheduler.match?(@schedule, Time.new(1983, 4, 21)).should == false
    end
  end
end