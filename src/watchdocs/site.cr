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

  def render(path : Path, pages : Array(Page) = @pages)
    pages.map do |page|
      p = page.file.path.relative_to("content")
      if p.stem == "index"
        p = path.join Path[p.dirname, "#{p.stem}.html"]
      else
        p = path.join Path[p.to_s.chomp(p.extension), "/index.html"]
      end
      FileUtils.mkdir_p p.dirname
      File.open(p, mode: "w") do |file|
        page.render(self, file)
      end
    end
  end
end
