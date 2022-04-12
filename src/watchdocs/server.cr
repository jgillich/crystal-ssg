require "inotify"
require "kemal"
require "./site"

public_folder "./site"

SITE    = Watchdocs::Site.new
SOCKETS = [] of HTTP::WebSocket

TARGET_DIR = Path[Dir.current, "site"]

FileUtils.rm_r TARGET_DIR if Dir.exists? TARGET_DIR
FileUtils.mkdir_p TARGET_DIR

SITE.render TARGET_DIR

def watch(dir : Dir)
  Inotify.watch dir.path do |event|
    FileUtils.rm_r TARGET_DIR
    FileUtils.mkdir_p TARGET_DIR
    SITE.render TARGET_DIR
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

watch_recursive Dir.new(Path[Dir.current, "content"])
watch_recursive Dir.new(Path[Dir.current, "template"])

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
