# frozen_string_literal: true
require "spec_helper"

describe "bundle install" do
  context "git sources" do
    it "displays the revision hash of the gem repository" do
      build_git "foo", "1.0", :path => lib_path("foo")

      install_gemfile <<-G
        gem "foo", :git => "#{lib_path("foo")}"
      G

      bundle :install
      expect(out).to include("Using foo 1.0 from #{lib_path("foo")} (at master@#{revision_for(lib_path("foo"))[0..6]})")
      should_be_installed "foo 1.0"
    end

    it "does not checkout repository with --local option" do
      build_git "foo", "1.0", :path => lib_path("foo")

      install_gemfile <<-G, :local => true
        gem "foo", :git => "#{lib_path("foo")}"
      G

      expect(out).to include("The git source #{lib_path("foo")} is not yet checked out.")
      should_not_be_installed "foo 1.0"
    end

    it "does not attempt to checkout repository when a local version of the repository exists" do
      build_git "foo", "1.0", :path => lib_path("foo")

      install_gemfile <<-G
        gem "foo", :git => "#{lib_path("foo")}"
      G

      expect(out).to include("Fetching #{lib_path("foo")}")
      should_be_installed "foo 1.0"

      install_gemfile <<-G, :local => true
        gem "foo", :git => "#{lib_path("foo")}"
      G

      expect(out).to_not include("Fetching #{lib_path("foo")}")
      expect(out).to include("Using foo 1.0 from #{lib_path("foo")}")
      should_be_installed "foo 1.0"
    end
  end
end
