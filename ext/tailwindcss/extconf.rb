# Downloads the correct tailwindcss binary for the current platform at install time.
# This ensures the binary is available when installing from a git source.
require "open-uri"
require "fileutils"
require_relative "../../lib/tailwindcss/ruby/upstream"

platform = [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
filename = Tailwindcss::Ruby::Upstream::NATIVE_PLATFORMS[platform]

unless filename
  abort "tailwindcss-ruby does not support the #{platform} platform"
end

exe_dir = File.expand_path("../../exe/#{platform}", __dir__)
exe_path = File.join(exe_dir, "tailwindcss")

unless File.exist?(exe_path)
  url = "https://github.com/tailwindlabs/tailwindcss/releases/download/#{Tailwindcss::Ruby::Upstream::VERSION}/#{filename}"
  warn "Downloading tailwindcss for #{platform} from #{url} ..."
  FileUtils.mkdir_p(exe_dir)
  URI.parse(url).open do |remote|
    File.binwrite(exe_path, remote.read)
  end
  FileUtils.chmod(0o755, exe_path)
end

# Create a dummy Makefile so rubygems is happy
File.write("Makefile", "all:\n\techo done\ninstall:\n\techo done\n")
