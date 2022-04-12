require "inotify"
require "kemal"
require "./site"

SITE    = Watchdocs::Site.new
SOCKETS = [] of HTTP::WebSocket

TARGET_DIR = Path[Dir.current, "build"]

public_folder TARGET_DIR.to_s

FileUtils.rm_r TARGET_DIR if Dir.exists? TARGET_DIR
FileUtils.mkdir_p TARGET_DIR

SITE.build TARGET_DIR

def watch(dir : Dir)
  Inotify.watch dir.path do |event|
    FileUtils.rm_r TARGET_DIR
    FileUtils.mkdir_p TARGET_DIR
    SITE.build TARGET_DIR
    SOCKETS.each do |socket|
      socket.send "reload"
    end
  rescue e
    pp e
  end
end

def watch_recursive(dir : Dir)
  watch dir
  dir.each_child do |name|
    path = Path[dir.path, name]
    if File.directory?(path)
      watch_recursive Dir.new(path)
    end
  end
end

watch_recursive Dir.new(Path[Dir.current, "pages"])
watch_recursive Dir.new(Path[Dir.current, "templates"])

get "/" do |env|
  env.redirect "/index.html"
end

ws "/livereload" do |socket|
  SOCKETS << socket
  socket.on_close do
    SOCKETS.delete socket
  end
end

Signal::TERM.trap do
  Kemal.stop
  exit
end

Kemal.run
