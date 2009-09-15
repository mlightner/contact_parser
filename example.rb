#!/usr/bin/env ruby

require 'contact_parser'

parsed = ContactParser.parse("Joe Schmoe
123 fake street
Fake City, AZ, 12345
Some company, inc.
480-555-0012
joe@google.com")

hi = Highrise::Base.site = 'http://api-token:login@yoursite.highrisehq.com/'

pid = Highrise::Person.new(:first_name => parsed[:first], :last_name => parsed[:last], :company_name => parsed[:company], :contact_data => {
  :email_addresses => { :email_address => { :location => "Work", :address => parsed[:email]}},
  :phone_numbers => { :phone_number => { :location => "Work", :address => parsed[:phone]}}} )
pid.save

puts pid.inspect
