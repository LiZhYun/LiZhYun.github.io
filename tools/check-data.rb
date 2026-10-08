#!/usr/bin/env ruby
# frozen_string_literal: true

# Gate 3: validates _data/*.yml against the design spec (§4, §5).
# Usage: ruby tools/check-data.rb [--root DIR] [--expect-total N] [--expect-selected N]
require "yaml"
require "date"
require "optparse"
require "shellwords"

opts = { root: File.expand_path("..", __dir__) }
OptionParser.new do |o|
  o.on("--root DIR") { |v| opts[:root] = File.expand_path(v) }
  o.on("--expect-total N", Integer) { |v| opts[:total] = v }
  o.on("--expect-selected N", Integer) { |v| opts[:selected] = v }
end.parse!

ROOT = opts[:root]
VENUE_KEYS = %w[neurips icml aaai arxiv nn tnsm eaai apin aamas tpami bmvc ijcnn].freeze
TYPES = ["Conference", "Journal", "Preprint", "Workshop", "Under review"].freeze
LINK_KEYS = %w[paper arxiv oa code project].freeze
MAX_W = 800
MAX_BYTES = 80 * 1024
# Common abbreviations that end in a period but don't end a sentence; blanked out before
# counting sentence terminators in a tldr (case-sensitive, as written).
TLDR_ABBREVIATIONS = ["e.g.", "i.e.", "vs.", "et al.", "Fig.", "Eq.", "approx."].freeze
ERRORS = []

def err(msg)
  ERRORS << msg
end

def load_data(name)
  path = File.join(ROOT, "_data", "#{name}.yml")
  unless File.exist?(path)
    err("#{name}.yml: missing")
    return nil
  end
  YAML.safe_load(File.read(path), permitted_classes: [Date])
rescue Psych::SyntaxError => e
  err("#{name}.yml: YAML error: #{e.message}")
  nil
end

def image_width(path)
  `identify -format %w #{Shellwords.escape("#{path}[0]")} 2>/dev/null`.to_i
end

def nonempty_string?(v)
  v.is_a?(String) && !v.strip.empty?
end

# ---------- publications ----------
pubs = load_data("publications")
if pubs
  unless pubs.is_a?(Array) && !pubs.empty?
    err("publications.yml: must be a non-empty list")
    pubs = []
  end
  prev_year = nil
  new_flags = 0
  pubs.each_with_index do |p, i|
    unless p.is_a?(Hash)
      err("publications[#{i}]: not a mapping")
      next
    end
    tag = "publications[#{i}] (#{p['title'].to_s[0, 40]})"
    %w[title venue tldr].each { |k| err("#{tag}: '#{k}' must be a non-empty string") unless nonempty_string?(p[k]) }
    authors = p["authors"]
    if authors.is_a?(Array) && !authors.empty? && authors.all? { |a| nonempty_string?(a) }
      err("#{tag}: authors must include 'Zhiyuan Li'") unless authors.include?("Zhiyuan Li")
    else
      err("#{tag}: 'authors' must be a non-empty list of names")
    end
    err("#{tag}: venue_key '#{p['venue_key']}' not in #{VENUE_KEYS.join(', ')}") unless VENUE_KEYS.include?(p["venue_key"])
    err("#{tag}: type '#{p['type']}' not in #{TYPES.join(' / ')}") unless TYPES.include?(p["type"])
    err("#{tag}: 'selected' must be true or false") unless [true, false].include?(p["selected"])
    if p["year"].is_a?(Integer)
      err("#{tag}: year #{p['year']} is newer than the entry above (#{prev_year})") if prev_year && p["year"] > prev_year
      prev_year = p["year"]
    else
      err("#{tag}: 'year' must be an integer")
    end
    if nonempty_string?(p["tldr"])
      sentence_check = TLDR_ABBREVIATIONS.reduce(p["tldr"]) { |s, abbr| s.gsub(abbr, "") }
      if sentence_check.scan(/[.!?](?=\s|\z)/).size != 1
        err("#{tag}: tldr must be exactly one sentence ending in . ! or ?")
      end
    end
    links = p["links"]
    if links.is_a?(Hash) && !links.empty?
      links.each do |k, v|
        err("#{tag}: unknown link key '#{k}' (allowed: #{LINK_KEYS.join(', ')})") unless LINK_KEYS.include?(k)
        err("#{tag}: link '#{k}' must start with https://") unless v.is_a?(String) && v.start_with?("https://")
      end
    else
      err("#{tag}: 'links' must be a non-empty mapping")
    end
    err("#{tag}: 'award' must be a non-empty string when present") if p.key?("award") && !nonempty_string?(p["award"])
    if p["new"]
      new_flags += 1
      err("#{tag}: the 'new' entry must have a thumb") unless p["thumb"]
    end
    next unless p["thumb"]

    path = File.join(ROOT, "assets", "img", "pubs", p["thumb"].to_s)
    if File.exist?(path)
      w = image_width(path)
      err("#{tag}: thumb is #{w}px wide (max #{MAX_W})") if w.zero? || w > MAX_W
      err("#{tag}: thumb is #{File.size(path)} bytes (max #{MAX_BYTES})") if File.size(path) > MAX_BYTES
    else
      err("#{tag}: thumb #{p['thumb']} not found in assets/img/pubs/")
    end
  end
  err("publications.yml: #{new_flags} entries have new: true (max 1)") if new_flags > 1
  err("publications.yml: #{pubs.size} entries, expected #{opts[:total]}") if opts[:total] && pubs.size != opts[:total]
  selected = pubs.count { |p| p.is_a?(Hash) && p["selected"] == true }
  err("publications.yml: #{selected} selected, expected #{opts[:selected]}") if opts[:selected] && selected != opts[:selected]
end

# ---------- news ----------
news = load_data("news")
if news
  if news.is_a?(Array) && !news.empty?
    new_count = 0
    news.each_with_index do |n, i|
      unless n.is_a?(Hash)
        err("news[#{i}]: not a mapping")
        next
      end
      d = n["date"]
      unless d.is_a?(String) && d.match?(/\A\d{4}(-(0[1-9]|1[0-2]))?\z/)
        err("news[#{i}]: date must be a quoted string \"YYYY\" or \"YYYY-MM\" (got #{d.inspect})")
      end
      err("news[#{i}]: 'emoji' missing") unless nonempty_string?(n["emoji"])
      err("news[#{i}]: 'html' missing") unless nonempty_string?(n["html"])
      err("news[#{i}]: 'older' must be true or false") if n.key?("older") && ![true, false].include?(n["older"])
      new_count += 1 if n["new"]
    end
    err("news.yml: #{new_count} items have new: true (max 1)") if new_count > 1
    years = news.map { |n| n.is_a?(Hash) ? n["date"].to_s[0, 4] : "" }
    err("news.yml: items must be ordered newest year first") unless years.each_cons(2).all? { |a, b| a >= b }
  else
    err("news.yml: must be a non-empty list")
  end
end

# ---------- profile ----------
prof = load_data("profile")
if prof.is_a?(Hash)
  %w[name name_zh role org location email scholar_url].each { |k| err("profile.yml: '#{k}' missing") unless nonempty_string?(prof[k]) }
  unless prof["pinyin"].is_a?(Array) && prof["pinyin"].size == prof["name_zh"].to_s.chars.size
    err("profile.yml: pinyin must have one syllable per character of name_zh")
  end
  err("profile.yml: bio must be a non-empty list of HTML strings") unless prof["bio"].is_a?(Array) && !prof["bio"].empty?
  chips = prof["chips"].is_a?(Array) ? prof["chips"] : []
  err("profile.yml: chips missing") if chips.empty?
  chips.each_with_index do |c, i|
    unless c.is_a?(Hash) && nonempty_string?(c["label"]) && nonempty_string?(c["href"])
      err("profile.yml chips[#{i}]: needs label and href")
      next
    end
    err("profile.yml chips[#{i}]: #{c['href']} not found") if c["href"].start_with?("/") && !File.exist?(File.join(ROOT, c["href"]))
  end
  interests = prof["interests"].is_a?(Array) ? prof["interests"] : []
  err("profile.yml: interests missing") if interests.empty? || !interests.all? { |c| c.is_a?(Hash) && nonempty_string?(c["label"]) }
  sc = prof["scholar"]
  unless sc.is_a?(Hash) && sc["citations"].is_a?(Integer) && sc["h_index"].is_a?(Integer) && sc["updated"].is_a?(Date)
    err("profile.yml: scholar needs integer citations, integer h_index and an unquoted date 'updated'")
  end
  (chips + interests).each do |c|
    next unless c.is_a?(Hash) && c["icon"]

    err("profile.yml: icon '#{c['icon']}' has no _includes/icons/#{c['icon']}.svg") unless File.exist?(File.join(ROOT, "_includes", "icons", "#{c['icon']}.svg"))
  end
elsif prof
  err("profile.yml: must be a mapping")
end

# ---------- simple lists ----------
{
  "education" => %w[institution logo degree dates],
  "experience" => %w[institution logo role dates], "awards" => %w[emoji title year],
  "service" => %w[label text], "teaching" => %w[html]
}.each do |name, keys|
  list = load_data(name)
  next unless list

  unless list.is_a?(Array) && !list.empty?
    err("#{name}.yml: must be a non-empty list")
    next
  end
  list.each_with_index do |item, i|
    keys.each { |k| err("#{name}[#{i}]: '#{k}' missing") unless item.is_a?(Hash) && nonempty_string?(item[k]) }
    next unless item.is_a?(Hash) && item["logo"]

    err("#{name}[#{i}]: logo #{item['logo']} not in assets/img/logos/") unless File.exist?(File.join(ROOT, "assets", "img", "logos", item["logo"]))
  end
end

if ERRORS.empty?
  puts "DATA OK"
else
  ERRORS.each { |e| puts "ERROR #{e}" }
  puts "#{ERRORS.size} problem(s)"
  exit 1
end
