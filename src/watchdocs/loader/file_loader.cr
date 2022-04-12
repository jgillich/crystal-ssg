require "./loader"
require "../text_file"

module Watchdocs
  class Loader
    class FileLoader < Loader
      def initialize(@base_path : Path)
      end

      def files : Array(TextFile)
        Dir.glob(["**/*.md", "**/*.html"].map { |p| Path[@base_path, p] }, follow_symlinks: true).map do |p|
          content = File.open(p) do |file|
            file.gets_to_end
          end
          TextFile.new(Path[p].relative_to(@base_path), content)
        end
      end
    end
  end
end
