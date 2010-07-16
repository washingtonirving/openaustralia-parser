#!/usr/bin/env ruby

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'rubygems'
require 'mechanize'
require 'configuration'
require 'people'

conf = Configuration.new

agent = WWW::Mechanize.new

puts "Reading Australia post office data..."
data = CSV.readlines("data/pc-full_20100629.csv")
# Ignore header
data.shift

valid_postcodes = data.map {|row| row.first}.uniq.sort

def extract_divisions_from_page(page)
  page.search('div/table/tr/td[4]').map {|t| t.inner_text}
end

def other_pages?(page)
  page.at('table table')
end

file = File.open("data/postcodes.csv", "w")

file.puts("Postcode,Electoral division name")
file.puts(",")

valid_postcodes.each do |postcode|
  page = agent.get("http://apps.aec.gov.au/esearch/LocalitySearchResults.aspx?filter=#{postcode}&filterby=Postcode")
  puts "Postcode #{postcode}..."
  page_number = 1
  puts "  Page #{page_number}..."
  divisions = extract_divisions_from_page(page)

  if other_pages?(page)
    begin
      page_number += 1
      puts "  Page #{page_number}..."
      form = page.form_with(:name => "aspnetForm")
      form["__EVENTTARGET"] = 'ctl00$ContentPlaceHolderBody$gridViewLocalities'
      form["__EVENTARGUMENT"] = "Page$#{page_number}"
      page = form.submit
      new_divisions = extract_divisions_from_page(page)
      divisions += new_divisions
    end until new_divisions.empty?
  end
  divisions = divisions.uniq.sort
  
  if divisions.empty?
    puts "  * No divisions *"
  else
    puts "  " + divisions.join(", ")
    divisions.each do |division|
      file.puts "#{postcode},#{division}"
    end
  end
end

