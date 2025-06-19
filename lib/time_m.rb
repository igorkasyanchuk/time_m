# frozen_string_literal: true

require_relative "time_m/version"
require_relative "time_m/timer"
require "colorize"

module TimeM
  NAME = "| time_m |"
  SKIP_FLAG = -1

  def self.method_missing(method, *args, &block) # rubocop:disable Style/MissingRespondToMissing
    name = method.to_s
    label = args.first.to_s
    label = (label == "") ? nil : label

    m(name, label, &block)
  end

  def self.m(name = nil, label = nil, &block)
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    if block_given?
      yield.tap do |res|
        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - now
        output(name, label, duration, res)
      end
    else
      timer = tracker.timers[name]
      if timer.nil?
        tracker.init(name)
        output(name, label, SKIP_FLAG)
      else
        diff = now - timer[:last_time] if timer[:last_time]
        output(name, label, now - timer[:time], diff)
        tracker.touch(name, now)
      end
    end
  end

  private_class_method

  # colors: https://github.com/fazibear/colorize/blob/master/lib/colorize/class_methods.rb

  def self.info(str = "", new_line: false)
    log(str.magenta.italic, new_line: new_line)
  end

  def self.success(str = "", new_line: false)
    log(str.light_green.bold, new_line: new_line)
  end

  def self.warning(str = "", new_line: false)
    log(str.light_yellow.bold, new_line: new_line)
  end

  def self.log(str = "", new_line: false)
    new_line ? puts(str) : print(str)
  end

  def self.output(name, label, time, last_time = nil)
    display_name = label || name || caller[1..2].detect { |line| !line.include?("/lib/time_m") }
    display_name = display_name.gsub(Rails.root.to_s + "/", "") if defined?(Rails)

    if time == SKIP_FLAG
      info "#{NAME}".on_light_yellow
      info " #{display_name} ⏲", new_line: true
      return
    end

    time = time.round(3)
    last_time = last_time.round(3) if last_time
    if display_name
      info "#{NAME}".on_light_yellow
      info " #{display_name} ∑"
      warning sprintf("%0.3f", time)
      info " seconds"

      if last_time
        info ", "
        success "+#{sprintf("%0.3f", last_time)}"
        info " seconds", new_line: true
      else
        info new_line: true
      end
    else
      info "#{NAME}".on_light_yellow
      info " Elapsed time: #{sprintf("%0.3f", time)} seconds", new_line: true
    end
  end

  def self.tracker
    Thread.current[:time_m_timer] ||= Timer.new
  end
end

TM = TimeM

Time.define_singleton_method(:m) do |name = nil, label = nil, &block|
  TimeM.m(name, label, &block)
end

Time.define_singleton_method(:measure) do |name = nil, label = nil, &block|
  TimeM.m(name, label, &block)
end
