require "spec_helper"

module OKComputer
  describe Checks do
    context ".registered_checks" do
      let(:no_checks) { nil }
      let(:some_checks) { {foo: "bar"} }

      it "returns an empty list if not set" do
        Checks.send(:registered_checks=, no_checks)
        Checks.registered_checks.should == []
      end

      it "remembers the checks given to it" do
        Checks.send(:registered_checks=, some_checks)
        Checks.registered_checks.should == some_checks.values
      end
    end

    context ".registered_check(check_name)" do
      let(:check_name) { :foo }
      let(:foo_check) { stub(:checker) }

      it "returns the check registered with the given name" do
        Checks.register(check_name, foo_check)
        Checks.registered_check(check_name).should == foo_check
      end

      it "raises an exceiption if given a check that's not registered" do
        Checks.deregister(check_name)
        expect { Checks.registered_check(check_name) }.to raise_error(Checks::CheckNotFound)
      end
    end

    context ".register(check_name, check_object)" do
      let(:check_name) { :foo }
      let(:check_object) { stub(:checker) }
      let(:second_check_object) { stub(:checker) }

      it "adds the checker to the list of checkers" do
        Checks.deregister(check_name)
        Checks.registered_checks.should_not include check_object
        Checks.register(check_name, check_object)
        Checks.registered_checks.should include check_object
      end

      it "overwrites the current check with the given name" do
        # put the first one in and make sure it's there
        Checks.register(check_name, check_object)
        Checks.registered_checks.should include check_object

        # put the second one in there, and first one gets replaced
        Checks.register(check_name, second_check_object)
        Checks.registered_checks.should_not include check_object
        Checks.registered_checks.should include second_check_object
      end
    end

    context ".deregister(check_name)" do
      let(:check_name) { :foo }
      let(:check_object) { stub(:checker) }

      it "removes the checker from the list of checkers" do
        Checks.register(check_name, check_object)
        Checks.registered_checks.should include check_object

        Checks.deregister(check_name)
        Checks.registered_checks.should_not include check_object
      end

      it "does not error if the name isn't registered" do
        Checks.deregister(check_name)
        Checks.deregister(check_name)
      end
    end
  end
end

