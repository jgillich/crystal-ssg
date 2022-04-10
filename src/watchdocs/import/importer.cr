require "../text_file"

module Watchdocs::Import
  abstract class Importer
    abstract def read(*paths : Path) : Array(TextFile)
  end
end
