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
      around(:each) do |example|
        ShellMock.enable
        example.run
        ShellMock.disable
      end

      subject { described_class.new.prepare(source) }

      context "with basic app params" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1"
          }
        end
        let!(:run_stub) { ShellMock.stub_command("hyper run -d --restart=always --size=s1 --name=app cromega/app") }

        context "when an app with the same name does not exist" do
          before do
            ShellMock.stub_command("hyper inspect app").to_exit(1)
          end

          it "deploys the new app" do
            subject.deploy(params)
            expect(run_stub).to have_run
          end
        end

        context "when an app with the same name exists" do
          before do
            ShellMock.stub_command("hyper inspect app").to_exit(0)
          end

          let!(:delete_stub) { ShellMock.stub_command("hyper rm -f app") }

          it "deletes the old app and deploys the new one" do
            subject.deploy(params)
            expect(delete_stub).to have_run
            expect(run_stub).to have_run
          end
        end
      end

      context "when ports are exposed" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1",
            "ports" => ["22:2222"],
          }
        end
        let!(:run_stub) { ShellMock.stub_command("hyper run -d --restart=always --size=s1 --name=app -p 22:2222 cromega/app") }

        before do
          ShellMock.stub_command("hyper inspect app").to_exit(1)
        end

        it "deploys the app with ports exposed" do
          subject.deploy(params)
          expect(run_stub).to have_run
        end
      end

      context "when env vars are specified" do
        let(:params) do
          {
            "name" => "app",
            "image" => "cromega/app",
            "size" => "s1",
            "env" => { "FOO" => "BAR" }
          }
        end
        let!(:run_stub) { ShellMock.stub_command("hyper run -d --restart=always --size=s1 --name=app -e FOO\\=BAR cromega/app") }

        before do
          ShellMock.stub_command("hyper inspect app").to_exit(1)
        end

        it "deploys the app with ports exposed" do
          subject.deploy(params)
          expect(run_stub).to have_run
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
        let!(:run_stub) { ShellMock.stub_command("hyper run -d --restart=always --size=s1 --name=app cromega/app") }
        let!(:fip_stub) { ShellMock.stub_command("hyper fip attach -f 123.456.789.123 app") }

        before do
          ShellMock.stub_command("hyper inspect app").to_exit(1)
        end

        it "deploys the app and attaches the public ip" do
          subject.deploy(params)
          expect(run_stub).to have_run
          expect(fip_stub).to have_run
        end
      end
    end
  end
end
