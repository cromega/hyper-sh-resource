require "open3"

module HyperSH
  class CommandRunner
    def run(cmd)
      @output, _ = Open3.capture2e(cmd.cmdline)
    end

    def output
      @output
    end
  end
end
