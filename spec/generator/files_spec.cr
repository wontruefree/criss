require "spec"
require "../../src/generator"

private def generate_files
  site = Criss::Site.new("spec/fixtures/simple-site")
  generator = Criss::Generator::Files.new(site)
  generator.generate

  site.files
end

describe Criss::Generator::Files do
  it "reads files" do
    generate_files.map(&.slug).should eq ["css/site.css", "folder/file.html", "index.md", "no-frontmatter.markdown", "simple.scss"]
  end

  it "reads files with includes" do
    site = Criss::Site.new("spec/fixtures/simple-site")
    site.config.include = ["_include.html"]
    generator = Criss::Generator::Files.new(site)
    generator.generate

    site.files.map(&.slug).should eq ["css/site.css", "folder/file.html", "index.md", "no-frontmatter.markdown", "simple.scss", "_include.html"]
  end

  it "creates resource" do
    files = generate_files
    file = files[2]
    file.slug.should eq "index.md"
    file.content.should eq "Index\n"
    file.title.should eq "Homepage"
    file.has_frontmatter?.should be_true

    file = files[4]
    file.slug.should eq "simple.scss"
    file.has_frontmatter?.should be_true
  end

  it "recognizes no frontmatter" do
    generate_files.find(&.slug.==("no-frontmatter.markdown")).not_nil!.has_frontmatter?.should be_false
  end

  it "applies defaults" do
    config = Criss::Config.new
    config.site_dir = "spec/fixtures/simple-site"
    config.defaults = [Criss::Config::Defaults.new(Criss::Config::Scope.new(type: "pages"), Criss::Frontmatter{"defaults_applied" => true})]

    site = Criss::Site.new(config)
    generator = Criss::Generator::Files.new(site)
    generator.generate

    site.files[0]["defaults_applied"].should be_true
  end
end
