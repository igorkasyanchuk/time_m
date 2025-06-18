# frozen_string_literal: true

require_relative "time_m/version"
require_relative "time_m/timer"
require "colorize"

module TimeM
  SUCCESS_COLOR = :light_green
  WARNING_COLOR = :light_yellow
  INFO_COLOR = :light_magenta

  PLUS_SIGN = "+"
  SKIP_FLAG = -1
  DEFAULT_PRINT_PROC = ->(name, label, time, last_time = nil) do
    # to handle case when caller is Time.measure and not TM.m
    display_name = label || name || caller[1..2].detect { |line| !line.include?("lib/time_m") }

    if time == SKIP_FLAG
      info("TM | #{display_name} ⏲", new_line: true)
      return
    end

    time = time.round(3)
    last_time = last_time.round(3) if last_time
    if display_name
      info "TM | #{display_name} ∑"
      warning sprintf("%0.3f", time)
      info " seconds"

      if last_time
        info ", "
        success "#{PLUS_SIGN}#{sprintf("%0.3f", last_time)}"
        info " seconds", new_line: true
      else
        info new_line: true
      end
    else
      info "TM | Elapsed time: #{sprintf("%0.3f", time)} seconds", new_line: true
    end
  end

  def self.info(str = "", new_line: false)
    log(str.send(INFO_COLOR), new_line: new_line)
  end

  def self.success(str = "", new_line: false)
    log(str.send(SUCCESS_COLOR).bold, new_line: new_line)
  end

  def self.warning(str = "", new_line: false)
    log(str.send(WARNING_COLOR).bold, new_line: new_line)
  end

  def self.log(str = "", new_line: false)
    new_line ? puts(str) : print(str)
  end

  def self.configure
    yield self
  end

  def self.method_missing(method, *args, &block) # rubocop:disable Style/MissingRespondToMissing
    name = method.to_s
    label = args.first.to_s
    label = (label == "") ? nil : label

    m(name, label, &block)
  end

  def self.m(name = nil, label = nil, &block)
    if block_given?
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      res = yield
      duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - now
      print_proc.call(name, label, duration)
      res
    else
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      timer = tracker.timers[name]
      if timer.nil?
        tracker.init(name)
        print_proc.call(name, label, SKIP_FLAG)
      else
        diff = timer[:last_time] ? now - timer[:last_time] : nil
        print_proc.call(name, label, now - timer[:time], diff)
        tracker.touch(name, now)
      end
    end
  end

  private_class_method

  def self.print_proc
    @print_proc ||= DEFAULT_PRINT_PROC
  end

  def self.print_proc=(proc)
    @print_proc = proc
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
