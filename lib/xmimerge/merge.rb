
class Merge

	def initialize	
		@app = 	App.instance
		@from = @app.from
		@to = @app.to		
		@log = App.logger
		@commands = @app.commands_file
	end	

	def check
		#@log.debug "Check"
		@only_check = true
		verify
	end

	def merge
		#@log.debug "Merge"
		@only_check = false
		verify
	end

	def check_change_propertie(method, from, to, name)

		changes = Util.check_change_by_method(method, from, to)

		if !changes.nil?
			command = "\t* #{name} #{from.full_name} {'#{changes[0]}' --> '#{changes[1]}'}"
			@commands.add_command_to_buffer(command)
			unless @only_check 
				if @commands.has_command?(command)
					@log.info "[OK] #{command}"
				else
					#@log.info "[NOT] #{command}"
				end
			end
		end			
	end	
end