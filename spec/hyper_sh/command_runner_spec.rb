require "hyper_sh/command_runner"

  describe HyperSH::CommandRunner do
    describe ".run" do
      context "when the command succeeds" do
        let(:command) { double(:command, cmdline: "echo 123") }
        it "returns the stdout of the process" do
          output, _ = described_class.run(command)
          expect(output).to eq "123\n"
        end

        it "returns the exit status of the process" do
          _, status = described_class.run(command)
          expect(status).to eq true
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
          it "returns the exit status of the process" do
            _, status = described_class.run(command)
            expect(status).to eq false
          end
        end
      end
    end
  end
