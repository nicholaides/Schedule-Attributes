require 'ice_cube'
require 'active_support'
require 'active_support/time_with_zone'
require 'ostruct'

module ScheduleAtts
  # Your code goes here...
  DAY_NAMES = Date::DAYNAMES.map(&:downcase).map(&:to_sym)
  def schedule
    @schedule ||= begin
      if schedule_yaml.blank?
        IceCube::Schedule.new(Date.today.to_time).tap{|sched| sched.add_recurrence_rule(IceCube::Rule.daily) }
      else
        IceCube::Schedule.from_yaml(schedule_yaml)
      end
    end
  end

  def schedule_attributes=(options)
    options = options.dup
    options[:interval] = options[:interval].to_i
    options[:start_date] &&= ScheduleAttributes.parse_in_timezone(options[:start_date])
    options[:date]       &&= ScheduleAttributes.parse_in_timezone(options[:date])
    options[:until_date] &&= ScheduleAttributes.parse_in_timezone(options[:until_date])

    if options[:repeat].to_i == 0
      @schedule = IceCube::Schedule.new(options[:date])
      @schedule.add_recurrence_date(options[:date])
    else
      @schedule = IceCube::Schedule.new(options[:start_date])

      rule = case options[:interval_unit]
        when 'day'
          IceCube::Rule.daily options[:interval]
        when 'week'
          IceCube::Rule.weekly(options[:interval]).day( *IceCube::DAYS.keys.select{|day| options[day].to_i == 1 } )
      end

      rule.until(options[:until_date]) if options[:ends] == 'eventually'

      @schedule.add_recurrence_rule(rule)
    end

    self.schedule_yaml = @schedule.to_yaml
  end

  def schedule_attributes
    atts = {}

    if rule = schedule.rrules.first
      atts[:repeat]     = 1
      atts[:start_date] = schedule.start_date.to_date
      atts[:date]       = Date.today # for populating the other part of the form

      rule_hash = rule.to_hash
      atts[:interval] = rule_hash[:interval]

      case rule
      when IceCube::DailyRule
        atts[:interval_unit] = 'day'
      when IceCube::WeeklyRule
        atts[:interval_unit] = 'week'
        rule_hash[:validations][:day].each do |day_idx|
          atts[ DAY_NAMES[day_idx] ] = 1
        end
      end

      if rule.until_date
        atts[:until_date] = rule.until_date.to_date
        atts[:ends] = 'eventually'
      else
        atts[:ends] = 'never'
      end
    else
      atts[:repeat]     = 0
      atts[:date]       = schedule.start_date.to_date
      atts[:start_date] = Date.today # for populating the other part of the form
    end

    OpenStruct.new(atts)
  end

  # TODO: test this
  def self.parse_in_timezone(str)
    if Time.respond_to? :zone
      Time.zone.parse(str)
    else
      Time.parse(str)
    end
  end
end

# TODO: we shouldn't need this
ScheduleAttributes = ScheduleAtts

#TODO: this should be merged into ice_cube, or at least, make a pull request or something.
class IceCube::Rule
  def ==(other)
    to_hash == other.to_hash
  end
end

class IceCube::Schedule
  def ==(other)
    to_hash == other.to_hash
  end
end

