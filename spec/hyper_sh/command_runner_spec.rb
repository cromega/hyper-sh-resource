require "hyper_sh/command_runner"

  describe HyperSH::CommandRunner do
    let(:command) { double(:command, cmdline: "echo 123") }

    before do
      subject.run(command)
    end

    describe "#output" do
      it "returns the stdout of the process" do
        expect(subject.output).to eq "123\n"
      end
    end
  end
