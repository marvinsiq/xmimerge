
class CommandsFile

	COMMAND_FILE_NAME = "commands.merge"

	attr_reader :commands

	def initialize
		@buffer = Array.new
		@log = App.logger
	end

	def load_commands
		@log.info "Loading command file '#{COMMAND_FILE_NAME}'..."
		@commands = File.readlines(COMMAND_FILE_NAME, :encoding => "UTF-8")
		@log.info "Command file loaded."
		#@log.info "#{@commands.size} command(s)."
	end	

	def add_command_to_buffer(command)
		@log.debug "Command added to the buffer: \"#{command}\"."
		@buffer << command
	end

	def has_command?(command)			
		has = @commands.select {|c| c.include? command} 
		!has.empty?
	end

	def remove_if_is_last_command(command)
		@buffer.delete_at(@buffer.size-1) if @buffer.last == command
	end

	def buffer_size
		@buffer.size
	end

	def save_buffer
		@log.debug "Buffer saved."
		f = File.new(COMMAND_FILE_NAME, "w")
		f.write(@buffer.join("\n"))
		@buffer = Array.new
		f.close unless f.closed?
	end		

end