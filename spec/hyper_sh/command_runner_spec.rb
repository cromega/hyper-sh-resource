require "hyper_sh/command_runner"

  describe HyperSH::CommandRunner do
    describe ".run" do
      before do
        allow(STDERR).to receive(:puts)
      end

      context "when the command succeeds" do
        let(:command) { double(:command, cmdline: "echo 123") }
        it "returns the stdout of the process" do
          output, _ = described_class.run(command)
          expect(output).to eq "123\n"
        end

        it "returns the exit success of the process" do
          _, success = described_class.run(command)
          expect(success).to eq true
        end

        it "sends output to stderr" do
          described_class.run(command)
          expect(STDERR).to have_received(:puts).with("123\n")
        end
      end

      context "when the command fails" do
        context "when fail on error is true" do
          let(:command) { double(:command, cmdline: "false") }

          it "raises an error" do
            expect { described_class.run(command, fail_on_error: true) }.to raise_error HyperSH::CommandError
          end
        end
        let(:command) { double(:command, cmdline: "false") }

        context "when fail on error is not set" do
          it "returns false" do
            _, success = described_class.run(command)
            expect(success).to eq false
          end
        end
      end
    end
  end
