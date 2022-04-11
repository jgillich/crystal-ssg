require "yaml"
require "markd"
require "front_matter"
require "./text_file"
require "./front_matter"
require "./site"

module Watchdocs
  @[Crinja::Attributes(expose: [content, html, title])]
  class Page
    include Crinja::Object::Auto

    getter file : TextFile

    getter title : String?

    getter content : String

    getter frontmatter : FrontMatter

    def initialize(@file : TextFile)
      @frontmatter = FrontMatter.new
      @content = @file.content

      if @content.lstrip.starts_with? "---"
        ::FrontMatter.parse(@content) do |fm, c|
          @frontmatter = FrontMatter.from_yaml(fm)
          @content = c
        end
      end
    end

    def html
      Markd.to_html(@content)
    end

    def title
      @title = @frontmatter.title
    end

    def render(site : Site, io : IO)
      template = site.env.get_template("_default.html")

      io << template.render({"page" => self, "site" => site})
    end
  end
end
