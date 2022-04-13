require "crinja"
require "./page"
require "./site_config"
require "./plugin/*"

@[Crinja::Attributes(expose: [base_path, config, pages])]
class Watchdocs::Site
  include Crinja::Object::Auto

  getter env : Crinja = Crinja.new

  getter base_path : Path

  getter config : Config

  @plugins : Array(Plugin) = [Plugin::PostCSS.new] of Plugin

  def initialize(@base_path = Path[Dir.current])
    env.loader = Crinja::Loader::FileSystemLoader.new([Path[@base_path, "templates"].to_s])
    @config = Config.from_yaml File.read(@base_path.join("site.yaml"))
  end

  def pages
    root = Path[@base_path, "pages"]
    Dir.glob(["**/*.md", "**/*.markdown", "**/*.html"].map { |p| Path[root, p] }, follow_symlinks: true).map do |p|
      File.open(p, "r") do |f|
        Page.new Path[p].relative_to(root), f, self
      end
    end
  end

  def build(out_path : Path)
    channel = Channel(Tuple(Path | Page, Path)).new
    System.cpu_count.times do
      spawn do
        while f = channel.receive?
          FileUtils.mkdir_p f[1].parent
          build(f[0], f[1])
        end
      end
    end

    pages.map do |page|
      channel.send({page, out_path.join(page.path)})
    end

    Dir.glob(Path[@base_path, "static", "**/*"]).each do |p|
      if File.file?(p)
        channel.send({Path[p], out_path.join(Path[p].relative_to(Path[@base_path, "static"]))})
      end
    end
  ensure
    channel.close unless channel.nil?
  end

  def build(page : Page, out_path : Path)
    io = IO::Memory.new
    page.render io
    File.write(out_path, io.to_slice)
  end

  def build(in_path : Path, out_path : Path)
    File.open(in_path, "r") do |file|
      io = IO::Memory.new
      IO.copy(file, io)
      @plugins.each &.static(in_path, io)
      File.write(out_path, io.to_slice)
    end
  end
end
