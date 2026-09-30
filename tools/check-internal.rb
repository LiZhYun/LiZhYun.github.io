#!/usr/bin/env ruby
# frozen_string_literal: true

# Gate 2a (local): internal links and #fragments resolve, every <img> has alt, and
# every page links a favicon. html-proofer runs the same checks in CI; it cannot be
# installed here (no Ruby dev headers), so this uses the system Nokogiri.
require "nokogiri"
require "uri"

SITE = File.expand_path("../_site", __dir__)
abort "Build the site first: tools/build.sh" unless File.exist?(File.join(SITE, "index.html"))
errors = []
docs = {}
read_doc = ->(file) { docs[file] ||= Nokogiri::HTML(File.read(file)) }

def resolve(site, from_file, path)
  target = path.start_with?("/") ? File.join(site, path) : File.join(File.dirname(from_file), path)
  target = File.expand_path(target)
  File.directory?(target) ? File.join(target, "index.html") : target
end

pages = Dir.glob(File.join(SITE, "**", "*.html"))
pages.each do |file|
  rel = file.delete_prefix("#{SITE}/")
  doc = read_doc.call(file)
  errors << "#{rel}: no <link rel=\"icon\">" unless doc.at('link[rel~="icon"]')
  doc.css("img").each { |img| errors << "#{rel}: <img src=\"#{img['src']}\"> has no alt attribute" unless img.key?("alt") }
  refs = doc.css("a[href]").map { |n| n["href"] } + doc.css("link[href]").map { |n| n["href"] } +
         doc.css("script[src]").map { |n| n["src"] } + doc.css("img[src]").map { |n| n["src"] }
  refs.each do |href|
    next if href.nil? || href.empty?

    begin
      uri = URI.parse(href)
    rescue URI::InvalidURIError
      errors << "#{rel}: unparsable URL #{href}"
      next
    end
    next if uri.scheme || href.start_with?("//") # external: tools/check-links.sh

    target = uri.path.to_s.empty? ? file : resolve(SITE, file, uri.path)
    unless File.exist?(target)
      errors << "#{rel}: broken link #{href}"
      next
    end
    next if uri.fragment.to_s.empty?

    errors << "#{rel}: #{href} points to a missing id" unless read_doc.call(target).at_css("[id=\"#{uri.fragment}\"]")
  end
end

if errors.empty?
  puts "INTERNAL OK (#{pages.size} pages)"
else
  errors.uniq.each { |e| puts "FAIL #{e}" }
  exit 1
end
