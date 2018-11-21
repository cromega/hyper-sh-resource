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
      before do
        CommandRunner.history.clear
      end

      subject { described_class.new.prepare(source) }

      let(:last_cmd) { CommandRunner.history.last }

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
          expect(last_cmd).to eq "hyper run -d --restart=always --size=s1 --name=app cromega/app"
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
          expect(last_cmd).to include "-p 25:25"
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
          expect(last_cmd).to include "-e ENV_VAR\\=env\\ var"
        end
      end

      context "when the app has a public IP" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1",
            "public_ip" => "123.456.789.123"
          }
        end

        it "attaches the IP to the app" do
          subject.deploy(params)
          expect(last_cmd).to eq "hyper fip attach 123.456.789.123 app"
        end
      end
    end
  end
end
