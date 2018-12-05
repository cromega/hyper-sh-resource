require "hyper_sh/command_builder"

module HyperSH
  describe CommandBuilder do
    describe "#cmdline" do
      it "returns a command with short valueless flags" do
        subject.
          command("test").
          sparam("n")

        expect(subject.cmdline).to eq "test -n"
      end

      it "returns a command with short flags with values" do
        subject.
          command("test").
          sparam("f", "bar baz")

        expect(subject.cmdline).to eq "test -f bar\\ baz"
      end

      it "returns a command with multi word arguments escaped correctly" do
        subject.
          command("test").
          arg("foo bar")

        expect(subject.cmdline).to eq "test foo\\ bar"
      end

      it "returns a command with long flags without values" do
        subject.
          command("test").
          lparam("test")

        expect(subject.cmdline).to eq "test --test"
      end

      it "returns a command with long flags with values converted to kv pairs" do
        subject.
          command("test").
          lparam("param", "value").
          lparam("other", "value2")

        expect(subject.cmdline).to eq "test --param=value --other=value2"
      end
    end
  end
end
