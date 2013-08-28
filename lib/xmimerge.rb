gem 'xmimodel', '>=0.1.1'
require 'xmimodel'
require 'logger'

require File.join(File.dirname(__FILE__), 'xmimerge/app.rb')
require File.join(File.dirname(__FILE__), 'xmimerge/merge_packages.rb')

class XmiMerge

	def initialize(file_name_from, file_name_to)

		@log = App.logger
		
		start = Time.now
		App.logger.info "Loading source model..."
		@from = XmiModel.new file_name_from
		App.logger.info "Source model loaded (#{Util.diff_time(start)})."

		start = Time.now
		App.logger.info "Loading target model..."
		@to = XmiModel.new file_name_to
		App.logger.info "Target model loaded (#{Util.diff_time(start)})."

		@commands = App.instance.commands_file

		App.instance.from = @from
		App.instance.to = @to
		
	end

	def check
		@only_check = true
		verify
		@log.info("#{@commands.buffer_size} change(s).");
		@commands.save_buffer
	end

	def merge
		@only_check = false
		@commands.load_commands
		verify
	end	

	def verify
		merge = MergePackages.new
		@only_check ? merge.check : merge.merge
	end

	def save(path=@to.model_file_name)
		@to.save(path)
		App.logger.info "#{path} saved."
	end

end