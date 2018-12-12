require "open3"

module HyperSH
  class CommandRunner
    def run(cmd)
      @output, @status = Open3.capture2e(cmd.cmdline)
      self
    end

    def output
      @output
    end

    def success?
      @status.success?
    end
  end
end
