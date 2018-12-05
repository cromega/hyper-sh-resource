require "fileutils"
require "json"

require "hyper_sh/command_builder"

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
      commands = []
      command = CommandBuilder.new.
        command("hyper").
        arg("run").
        sparam("d").
        lparam("restart", "always").
        lparam("size", params["size"]).
        lparam("name", params["name"])

      params.fetch("ports", []).each do |port|
        command.sparam("p", port)
      end

      params.fetch("env", {}).each do |key, value|
        command.sparam("e", [key, value].join("="))
      end

      command.arg(params["image"])
      commands << command

      params["public_ip"]&.tap do |ip|
        commands << CommandBuilder.new.
          command("hyper").
          arg("fip").
          arg("attach").
          arg(ip).
          arg(params["name"])
      end

      commands
    end
  end
end
