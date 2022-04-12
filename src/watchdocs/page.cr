require "yaml"
require "markd"
require "front_matter"
require "./text_file"
require "./front_matter"
require "./site"
require "./page_type"

module Watchdocs
  @[Crinja::Attributes(expose: [content, html, title, frontmatter, url, children])]
  class Page
    include Crinja::Object::Auto

    @file : TextFile

    getter content : String

    getter frontmatter : FrontMatter

    @site : Site

    def initialize(@file : TextFile, @site)
      @frontmatter = FrontMatter.new
      @content = @file.content

      if @content.lstrip.starts_with? "---"
        ::FrontMatter.parse(@content) do |fm, c|
          @frontmatter = FrontMatter.from_yaml(fm)
          @content = c
        end
      end
    end

    def type
      case @file.path.extension
      when ".md", ".markdown"
        PageType::Markdown
      when ".html"
        PageType::Html
      else
        PageType::Text
      end
    end

    def html
      case type
      when PageType::Markdown
        Markd.to_html(@content)
        # when PageType::Html
        #  @content
      else
        raise "cannot convert page type #{type} to html"
      end
    end

    def title
      @frontmatter.title || @file.path.stem.gsub("_", " ")
    end

    def index?
      @file.path.stem == "index"
    end

    def path
      if index?
        Path[@file.path.dirname, "index.html"]
      else
        Path[@file.path.to_s.chomp(@file.path.extension), "index.html"]
      end
    end

    def url
      Path["/", path].to_s
    end

    def children
      @site.pages.select do
        true
      end
      @site.pages.select do |page|
        if index?
          page.path.parent.to_s.starts_with?(path.to_s.chomp("index.html"))
        else
          page.path.parent.parent.to_s.starts_with?(path.parent.to_s)
        end
      end
    end

    def render(io : IO)
      case type
      when PageType::Markdown
        template = begin
          @site.env.get_template("_default.html")
        end
        io << template.render({"page" => self, "site" => @site})
      when PageType::Html
        env = Crinja.new
        h = Hash(String, String).new
        h[@file.path.to_s] = @content
        env.loader = Crinja::Loader::ChoiceLoader.new([
          Crinja::Loader::HashLoader.new(h),
          @site.env.loader,
        ])
        io << env.get_template(@file.path.to_s).render({"page" => self, "site" => @site})
      else
        io << @content
      end
    end
  end
end
