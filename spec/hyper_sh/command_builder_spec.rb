require "hyper_sh/command_builder"

module HyperSH
  describe CommandBuilder do
    describe "#cmdline" do
      it "returns a command with short valueless flags" do
        subject.
          sparam("n")

        expect(subject.cmdline).to eq "hyper -n"
      end

      it "returns a command with short flags with values" do
        subject.
          sparam("f", "bar baz")

        expect(subject.cmdline).to eq "hyper -f bar\\ baz"
      end

      it "returns a command with multi word arguments escaped correctly" do
        subject.
          arg("foo bar")

        expect(subject.cmdline).to eq "hyper foo\\ bar"
      end

      it "returns a command with long flags without values" do
        subject.
          lparam("test")

        expect(subject.cmdline).to eq "hyper --test"
      end

      it "returns a command with long flags with values converted to kv pairs" do
        subject.
          lparam("param", "value").
          lparam("other", "value2")

        expect(subject.cmdline).to eq "hyper --param=value --other=value2"
      end
    end
  end
end
