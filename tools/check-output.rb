#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks the built site's SEO tags, sitemap, robots.txt, redirects and 404 page (spec §7, §8).
# Uses the system Nokogiri; run with plain `ruby` (not `bundle exec`).
require "nokogiri"

SITE = File.expand_path("../_site", __dir__)
abort "Build the site first: tools/build.sh" unless File.exist?(File.join(SITE, "index.html"))
$failures = 0

def check(ok, msg)
  puts "#{ok ? 'PASS' : 'FAIL'} #{msg}"
  $failures += 1 unless ok
end

def page(rel)
  Nokogiri::HTML(File.read(File.join(SITE, rel)))
end

home = page("index.html")
check(home.at("title")&.text == "Zhiyuan Li (李志圆)", "home <title> is exactly 'Zhiyuan Li (李志圆)'")
ld = home.css('script[type="application/ld+json"]').map(&:text).join
check(ld.include?('"@type":"Person"'), "JSON-LD @type is Person")
check(ld.include?("https://orcid.org/0000-0002-1804-3485"), "JSON-LD sameAs lists ORCID")
check(home.at('meta[property="og:image"]')&.[]("content") == "https://lizhyun.github.io/assets/img/avatar.png", "og:image is the avatar")
check(home.at('meta[name="twitter:card"]')&.[]("content") == "summary", "twitter:card is summary (the square avatar isn't cropped to 2:1)")
check(home.at('meta[name="twitter:site"]').nil?, "no twitter:site meta tag (site.twitter is unset, so jekyll-seo-tag must not emit it)")
check(home.at('meta[name="twitter:creator"]').nil?, "no twitter:creator meta tag (site.twitter is unset, so jekyll-seo-tag must not emit it)")
check(home.at('meta[name="description"]')&.[]("content").to_s.start_with?("Postdoctoral researcher at Aalto University"), "meta description is set")
check(home.css('link[rel="canonical"]').size == 1, "home has exactly one canonical link")
check(!File.read(File.join(SITE, "index.html")).include?("†"), "no corresponding-author marks")

sitemap = File.read(File.join(SITE, "sitemap.xml"))
check(sitemap.include?("<loc>https://lizhyun.github.io/</loc>"), "sitemap lists the home page")
check(sitemap.include?("Li_Zhiyuan_CV.pdf"), "sitemap lists the English CV")
%w[Li_Zhiyuan_CV_zh.pdf /publications/ /projects/ /blog/ 404.html].each { |s| check(!sitemap.include?(s), "sitemap omits #{s}") }
robots_path = File.join(SITE, "robots.txt")
check(File.exist?(robots_path) && File.read(robots_path).include?("Sitemap: https://lizhyun.github.io/sitemap.xml"), "robots.txt points to the sitemap")

{
  "publications/index.html" => "/#publications", "projects/index.html" => "/#publications",
  "projects/compass/index.html" => "/#publications", "blog/index.html" => "/"
}.each do |rel, dest|
  unless File.exist?(File.join(SITE, rel))
    check(false, "#{rel} exists")
    next
  end
  d = page(rel)
  check(d.at('meta[http-equiv="refresh"]')&.[]("content") == "0; url=#{dest}", "#{rel} refreshes to #{dest}")
  check(d.at('meta[name="robots"]')&.[]("content") == "noindex", "#{rel} is noindex")
  check(d.css('link[rel="canonical"]').size == 1, "#{rel} has exactly one canonical link")
  check(!d.at("a[href=\"#{dest}\"]").nil?, "#{rel} has a visible fallback link")
  check(!d.at('link[rel~="icon"]').nil?, "#{rel} links the favicon")
end

if File.exist?(File.join(SITE, "404.html"))
  d = page("404.html")
  check(d.at("title")&.text.to_s.start_with?("Page not found"), "404 title starts with 'Page not found'")
  check(d.css('link[rel="stylesheet"]').any? { |l| l["href"].start_with?("/assets/") }, "404 loads CSS by a root-relative URL")
  check(!d.at('a[href="/"]').nil?, "404 links home")
else
  check(false, "404.html exists")
end

texts = Dir.glob(File.join(SITE, "**", "*")).select { |f| File.file?(f) && f.end_with?(".html", ".css", ".js", ".xml") }
check(texts.none? { |f| File.read(f).include?("polyfill.io") }, "no polyfill.io references")
check(!File.read(File.join(SITE, "assets/css/site.css")).match?(/\b1440px\b/), "no fixed 1440px widths in CSS")
check(!File.exist?(File.join(SITE, "feed.xml")), "no feed.xml")

if $failures.zero?
  puts "OUTPUT OK"
else
  puts "#{$failures} check(s) failed"
  exit 1
end
