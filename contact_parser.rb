#!/usr/bin/env ruby

require 'rubygems'
require 'phone_number'

class String
  def titleize
    self.gsub(/\b('?[a-z])/) { $1.capitalize }
  end
end

class Contact
  attr_accessor :name, :email, :phone, :company, :postal_code, :street, :city, :country, :state

end

class Pattern

  @@all = Array.new

  attr_accessor :name
  attr_accessor :matchers
  attr_accessor :values
  attr_accessor :matched
  attr_accessor :formatters

  def self.all
    @@all
  end

  def initialize(name, &block)
    @name = name
    @matchers = Array.new
    @values = Hash.new
    @formatters = Hash.new
    @matched = false
    yield(self) if block_given?
    @@all.push(self)
  end

  def format(field, method)
    @formatters[field.to_sym] = method.to_sym
  end
  
  def add_matcher(pattern, values = [])
    @matchers.push([pattern, values])
  end
  
  def check_text(text)
    @matchers.reverse.each do |m|
      finder = m.first
      if finder.kind_of?(Regexp)
        found = finder.match(text)
        if !(found[0].nil? rescue true)
          m[1].each_with_index { |v,i| @values[v.to_sym] = found[i + 1] }
          @matched = true
          break
        end
      elsif Object.const_defined?(finder.to_s.to_sym)
        method = m[1].kind_of?(Array) ? :new : m[1].to_sym
        @matched = finder.send(method, text.strip)
        if !(@matched.nil? rescue true)
          @values[@name.to_sym] = @matched
          break
        end
      end
    end
    @values.each_key do |field|
      @values[field.to_sym] = @values[field.to_sym].to_s.strip
      next unless @formatters[field.to_sym] && @values[field.to_sym]
      @values[field.to_sym] = @values[field.to_sym].to_s.send(@formatters[field.to_sym].to_sym)
    end
    return @matched ? @values : nil
  end
end


class ContactParser
  @@matches = Hash.new

  def self.parse(text)
    Pattern.all.each do |pattern|
      text.each_line do |line|
        if match = pattern.check_text(line)
          match.each_pair do |k,v|
            @@matches[k] = v
          end
          break
        end
      end
    end
    return @@matches
  end

end


Pattern.new(:name) do |p|
  p.add_matcher(/([a-z]+)\s+([a-z]+)/i, [:first, :last])
  p.add_matcher(/([a-z]+)\s+([a-z\.]+)\s+([a-z]+)/i, [:first, :middle, :last])
  p.format(:first, :capitalize)
  p.format(:middle, :capitalize)
  p.format(:last, :capitalize)
end


Pattern.new(:address) do |p|
  p.add_matcher(/([0-9]+)\s+([\w\s]+)/i, [:number, :street])
  p.format(:street, :titleize)
end

Pattern.new(:locale) do |p|
  p.add_matcher(/([\w\s]+)\,\s?([\w\s]+?)\s+([\w]+)/i, [:city, :state, :zip])
  p.format(:state, :upcase)
  p.format(:city, :titleize)
end

Pattern.new(:phone) do |p|
  p.add_matcher(PhoneNumber, :parse_and_create)
end

Pattern.new(:email) do |p|
  p.add_matcher(%r{^((?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4}))$}i, [:email])
  p.format(:email, :downcase)
end

Pattern.new(:company) do |p|
  p.add_matcher(/([\w\s\,\-]+?(inc|llc|ltd|esq|incorporated|group|firm)\.?)/i, [:company])
  p.format(:company, :titleize)
end

