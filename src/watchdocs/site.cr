require "crinja"
require "./import/*"
require "./page"

class Watchdocs::Site
  getter pages : Array(Page)
  getter env : Crinja = Crinja.new

  def initialize(@importer : Import::Importer = Import::FileImporter.new(Path[Dir.current]))
    @pages = @importer.read(Path["content/**/*.md"]).map do |f|
      Page.new f
    end
    env.loader = Crinja::Loader::FileSystemLoader.new([Path[Dir.current, "templates"].to_s, "./theme/templates"])
  end

  def render(path : Path)
    @pages.map do |page|
      p = path.join(page.file.path.relative_to("content"))
      FileUtils.mkdir_p p.parent
      File.open(p, mode: "wb") do |file|
        page.render(self, file)
      end
    end
  end
end

pp Watchdocs::Site.new.render Path[Dir.current, "site"]
