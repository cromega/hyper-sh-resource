require "open3"

module HyperSH
  class CommandError < StandardError; end

  class CommandRunner
    OUTPUT = STDERR

    class << self
      def run(cmd, fail_on_error: false)
        output = []
        Open3.popen2e(cmd.cmdline) do |_, stdout, thread|
          while ! stdout.eof?
            stdout.readline.tap do |line|
              output << line
              OUTPUT.puts line
            end
          end

          if fail_on_error && !thread.value.success?
            raise CommandError, "#{cmd.cmdline} failed"
          end
          return output.join("\n"), thread.value.success?
        end
      rescue
        raise CommandError, "#{cmd.cmdline} failed"
      end
    end
  end
end
