module Watchdocs
  class Plugin
    class PostCSS < Plugin
      def initialize
      end

      def static(path : Path, io : IO::Memory)
        if path.extension == ".css"
          Process.run("npx", args: ["-y", "postcss-cli"]) do |proc|
            IO.copy io, proc.input
            proc.input.close
            io.clear
            IO.copy proc.output, io
          end
        end
      end
    end
  end
end
