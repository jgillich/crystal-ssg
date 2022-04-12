require "crinja"
require "./loader/*"
require "./page"
require "./site_config"

@[Crinja::Attributes(expose: [base_path, config, pages])]
class Watchdocs::Site
  include Crinja::Object::Auto

  getter env : Crinja = Crinja.new

  getter base_path : Path = Path[Dir.current]

  getter config : Config

  @loader : Loader

  def initialize(
    @loader = Loader::FileLoader.new(Path[Dir.current, "content"]),
    template_loader = Crinja::Loader::FileSystemLoader.new([Path[Dir.current, "template"].to_s, "./theme/template"])
  )
    env.loader = template_loader

    @config = Config.from_yaml File.read(@base_path.join("site.yaml"))
  end

  def pages
    @loader.files.map do |f|
      Page.new f, self
    end
  end

  def render(out_path : Path)
    pages.map do |page|
      p = out_path.join page.path
      FileUtils.mkdir_p p.dirname
      File.open(p, mode: "w") do |file|
        page.render(file)
      end
    end
  end
end
