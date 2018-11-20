require "fileutils"
require "json"

require "hyper_sh/command_runner"

module HyperSH
  class Deployer
    def prepare(source)
      FileUtils.mkdir_p("/home/#{ENV['USER']}/.hyper")
      config = {
        auths: {},
        clouds: {
          "tcp://*.hyper.sh:443" => {
            accesskey: source["accesskey"],
            secretkey: source["secretkey"],
            region: source["region"],
          }
        }
      }

      File.write("/home/#{ENV['USER']}/.hyper/config.json", config.to_json)
      self
    end

    def deploy(params)
      runner = CommandRunner.new.
        command("hyper").
        arg("run").
        sparam("d").
        lparam("restart", "always").
        lparam("size", params["size"]).
        lparam("name", params["name"])

      params.fetch("ports", []).each do |port|
        runner.sparam("p", port)
      end

      params.fetch("env", {}).each do |key, value|
        runner.sparam("e", [key, value].join("="))
      end

      runner.arg(params["image"]).
        run
    end
  end
end
