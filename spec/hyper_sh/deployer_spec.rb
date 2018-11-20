require "json"

require "hyper_sh/deployer"

module HyperSH
  describe Deployer do
    let(:source) do
      { "accesskey" => "access",
        "secretkey" => "secret",
        "region" => "region" }
    end

    describe "#prepare" do
      let(:config_path) { "/home/#{ENV['USER']}/.hyper/config.json" }

      it "creates the hypercli config file" do
        subject.prepare(source)
        config = JSON.parse(File.read(config_path))
        creds = config["clouds"]["tcp://*.hyper.sh:443"]

        expect(creds).to_not be_nil
        expect(creds["accesskey"]).to eq source["accesskey"]
        expect(creds["secretkey"]).to eq source["secretkey"]
        expect(creds["region"]).to eq source["region"]
      end
    end

    describe "#deploy" do
      subject { described_class.new.prepare(source) }

      let(:cmd) { CommandRunner.history.last }

      context "with basic app params" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1"
          }
        end

        it "deploys a container to hyper.sh with basic options" do
          subject.deploy(params)
          expect(cmd).to eq "hyper run -d --restart=always --size=s1 --name=app cromega/app"
        end
      end

      context "when ports are exposed" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1",
            "ports" => ["25:25"],
          }
        end

        it "deploys the container with ports forwarded" do
          subject.deploy(params)
          expect(cmd).to include "-p 25:25"
        end
      end

      context "when environment variables are specified" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1",
            "env" => {
              "ENV_VAR" => "env var"
            }
          }
        end

        it "deploys the container with ports forwarded" do
          subject.deploy(params)
          expect(cmd).to include "-e ENV_VAR\\=env\\ var"
        end
      end
    end
  end
end
