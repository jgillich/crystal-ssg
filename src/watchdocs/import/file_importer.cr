require "./importer"
require "../text_file"

module Watchdocs::Import
  class FileImporter < Importer
    def initialize(@base_path : Path)
    end

    def read(*paths : Path) : Array(TextFile)
      Dir.glob(paths.map { |p| Path[@base_path, p] }, follow_symlinks: true).map do |p|
        content = File.open(p) do |file|
          file.gets_to_end
        end
        TextFile.new(Path[p].relative_to(@base_path), content)
      end
    end
  end
end
