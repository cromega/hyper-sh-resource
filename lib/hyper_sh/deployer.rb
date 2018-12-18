require "fileutils"
require "json"

require "hyper_sh/command_builder"
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
      if container_exists?(params.fetch("name"))
        delete_container(params.fetch("name"))
      end

      pull_image(params.fetch("image"))
      create_container(params)

      params["public_ip"]&.tap do |ip|
        attach_floating_ip(params.fetch("name"), ip)
      end

      start_container(params.fetch("name"))
    end

    def container_exists?(name)
      command = CommandBuilder.new.
        arg("inspect").
        arg(name)

      _, status = CommandRunner.run(command)
      status
    end

    def pull_image(image)
      command = CommandBuilder.new.
        arg("pull").
        arg(image)

      CommandRunner.run(command, fail_on_error: true)
    end

    def create_container(params)
      command = CommandBuilder.new.
        arg("run").
        sparam("d").
        lparam("restart", "always").
        lparam("size", params.fetch("size")).
        lparam("name", params.fetch("name"))

      params.fetch("ports", []).each do |port|
        command.sparam("p", port)
      end

      params.fetch("env", {}).each do |key, value|
        command.sparam("e", [key, value].join("="))
      end

      command.arg(params["image"])

      CommandRunner.run(command, fail_on_error: true)
    end

    def delete_container(name)
      command = CommandBuilder.new.
        arg("rm").
        sparam("f").
        arg(name)

      CommandRunner.run(command, fail_on_error: true)
    end

    def start_container(name)
      command = CommandBuilder.new.
        arg("start").
        arg(name)

      CommandRunner.run(command, fail_on_error: true)
    end

    def attach_floating_ip(name, ip)
      command = CommandBuilder.new.
        arg("fip").
        arg("attach").
        sparam("f").
        arg(ip).
        arg(name)

      CommandRunner.run(command, fail_on_error: true)
    end
  end
end
