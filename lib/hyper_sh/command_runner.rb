require "shellwords"
require "open3"

module HyperSH
  class CommandRunner
    class << self
      def history
        @@commands
      end
    end

    def initialize
      @args = []
    end

    def command(cmd)
      @cmd = cmd
      self
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

    def run
      cmdline = @cmd
      cmdline += " " + @args.join(" ") if @args.any?

      puts "running command: #{cmdline.inspect}" if debug?
      output, _ = Open3.capture2e(cmdline)
      (@@commands ||= []) << cmdline
      output
    end

    private

    def escape(str)
      Shellwords.escape(str)
    end

    def debug?
      ENV.has_key? "DEBUG"
    end
  end
end
