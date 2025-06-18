module TimeM
  class Timer
    attr_reader :timers

    def initialize
      @timers = {}
    end

    def init(name = nil)
      @timers[name] ||= {}
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @timers[name][:time] = now
      touch(name, now)
    end

    def touch(name, time)
      @timers[name] ||= {}
      @timers[name][:last_time] = time
    end

    def reset_all
      @timers = {}
    end
  end
end
