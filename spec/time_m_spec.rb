# frozen_string_literal: true

require "colorize"

class UserNotifier
  def initialize(name)
    @name = name
  end

  def call
    Time.measure("send_email") do
      send_email
    end
    Time.measure("send_sms") do
      send_sms
    end
    Time.measure("send_push") do
      send_push
    end

    Time.measure("mark_as_done") do
      mark_as_done
    end
  end

  def call_step_by_step
    Time.measure
    send_email
    Time.measure
    send_sms
    Time.measure
    send_push
    Time.measure
    mark_as_done
    Time.measure
  end

  private

  def send_email
    sleep 0.1
  end

  def send_sms
    sleep 0.2
  end

  def send_push
    sleep 0.3
  end

  def mark_as_done
    sleep 0.1
  end
end

RSpec.describe TimeM do
  before do
    TM.tracker.reset_all
  end

  it "with works with configure" do
    $x = 0 # rubocop:disable Style/GlobalVars

    old_print_proc = TimeM.send(:print_proc)

    TimeM.configure do |config|
      config.print_proc = ->(name, label, time, last_time = nil) { $x += 1 } # rubocop:disable Style/GlobalVars
    end
    TM.m("test") do
      sleep 0.1
    end
    TM.m("test") do
      sleep 0.1
    end
    expect($x).to eq(2) # rubocop:disable Style/GlobalVars

    TimeM.send(:print_proc=, old_print_proc)
  end

  it "just works" do
    now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    TM.m
    sleep 0.1
    TM.m
    sleep 1
    TM.m
    sleep 0.1
    TM.m
    sleep 0.2
    TM.m
    expect(TM.tracker.timers.size).to eq(1)
  end

  it "works with method missing" do
    TM.s
    sleep 0.1
    TM.s
    expect(TM.tracker.timers.size).to eq(1)
  end

  it "works with method missing" do
    TM.b do
      sleep 0.1
    end
  end

  it "works with blocks as {}" do
    TM.calculation { sleep 0.1 }
  end

  it "works with name" do
    TM.m("abc")
    sleep 0.1
    TM.m("abc")
    expect(TM.tracker.timers.size).to eq(1)
  end

  it "works with name and label" do
    TM.m("xxx", "User sign in")
    sleep 0.1
    TM.m("xxx", "User sign in")
    expect(TM.tracker.timers.size).to eq(1)
  end

  it "works with block" do
    TM.m do
      sleep 1
    end
  end

  it "works with block and name" do
    TM.m("test") do
      sleep 0.1
    end
  end

  it "works with Time.m as block" do
    Time.m do
      sleep 0.1
    end
  end

  it "works with Time.measure as block" do
    Time.measure do
      sleep 0.1
    end
  end

  it "works with Time.m without name" do
    Time.measure
    sleep 0.1
    Time.measure
    sleep 0.1
    Time.measure
  end

  it "works with Time.m and custom name" do
    Time.measure("abc")
    sleep 0.1
    Time.measure("abc")
    sleep 0.1
    Time.measure("abc")
  end

  it "works with UserNotifier" do
    UserNotifier.new("John").call
  end

  it "works with UserNotifier step by step" do
    UserNotifier.new("John").call_step_by_step
  end
end
