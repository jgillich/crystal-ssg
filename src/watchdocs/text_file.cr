module Watchdocs
  class TextFile
    getter path : Path
    getter content : String

    def initialize(@path, @content)
    end
  end
end
