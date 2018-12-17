require "shellwords"
require "open3"

module HyperSH
  class CommandBuilder
    class << self
      def history
        @@commands ||= []
      end
    end

    def initialize
      @cmd = "hyper"
      @args = []
    end

    def sparam(flag_or_value, value = nil)
      arg = "-"
      arg += escape(flag_or_value)
      arg += " " + escape(value) if value
      @args << arg
      self
    end

    def lparam(flag_or_value, value = nil)
      arg = "--"
      arg += escape(flag_or_value)
      arg += "=" + escape(value) if value
      @args << arg
      self
    end

    def arg(words)
      @args << Shellwords.escape(words)
      self
    end

    def cmdline
      cmdline = @cmd
      cmdline += " " + @args.join(" ") if @args.any?
    end

    private

    def escape(str)
      Shellwords.escape(str)
    end
  end
end
