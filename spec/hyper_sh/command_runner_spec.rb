require "hyper_sh/command_runner"

module HyperSH
  describe HyperSH::CommandRunner do
    describe "#run" do
      let(:cmd) { CommandRunner.history.last }

      it "runs a command" do
        subject.
          command("test").
          run

        expect(cmd).to eq "test"
      end

      it "runs a command with short valueless flags" do
        subject.
          command("test").
          sparam("n").
          run

        expect(cmd).to eq "test -n"
      end

      it "runs a command with short flags with values" do
        subject.
          command("test").
          sparam("f", "bar baz").
          run

        expect(cmd).to eq "test -f bar\\ baz"
      end

      it "runs a command with multi word arguments escaped correctly" do
        subject.
          command("test").
          arg("foo bar").
          run

        expect(cmd).to eq "test foo\\ bar"
      end

      it "runs a command with long flags without values" do
        subject.
          command("test").
          lparam("test").
          run

        expect(cmd).to eq "test --test"
      end

      it "runs a command with long flags with values converted to kv pairs" do
        subject.
          command("test").
          lparam("param", "value").
          lparam("other", "value2").
          run

        expect(cmd).to eq "test --param=value --other=value2"
      end
    end
  end
end
