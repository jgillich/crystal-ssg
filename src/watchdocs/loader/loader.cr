require "../text_file"

module Watchdocs
  abstract class Loader
    abstract def files : Array(TextFile)
  end
end
