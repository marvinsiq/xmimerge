require File.join(File.dirname(__FILE__), 'commands_file.rb')
require 'rake'

class App

	attr_accessor :from
	attr_accessor :to

	@@instance = App.new
	def self.instance		
		return @@instance	
	end
	
	def commands_file
		@commands_file = CommandsFile.new if @commands_file.nil?
		@commands_file
	end
	
	@@log = nil
	def self.logger		
		return @@log unless @@log.nil?
		@@log = Logger.new($stdout)
		@@log.level = Logger::INFO
		@@log.formatter = proc do |severity, datetime, progname, msg|
		  "[#{severity}] - #{msg}\n"
		end
		@@log
	end	

	@@spec = nil
	def self.specification
		return @@spec unless @@spec.nil?
		@@spec = Gem::Specification.new do |s|
		  s.name        = 'xmimerge'
		  s.version     = '0.0.1'
		  s.date        = '2013-01-29'
		  s.summary     = "Xmi Merge"
		  s.description = "A helper gem for merge XMI files"
		  s.authors     = ["Marcus Siqueira"]
		  s.email       = 'marvinsiq@gmail.com'
		  s.files       = FileList['lib/*.rb', 'lib/**/*.rb'].to_a
		  s.homepage    = 'https://github.com/marvinsiq/xmimerge'
		  s.executables << 'xmimerge'
		end
	end

end