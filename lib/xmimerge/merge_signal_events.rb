require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_parameters.rb')

class MergeSignalEvents < Merge

	def initialize(from_use_case, to_use_case)
		super()
		@from_use_case = from_use_case
		@to_use_case = to_use_case
	end	

	def verify
		#@from_use_case.signal_events.each do |from_signal_event|		
		#	check_changes(from_signal_event)
		#end

		#check_removed			
	end

	def check_changes(from_signal_event)
		@log.debug("Checking Signal Event #{from_signal_event.name}...")

		to_signal_event = @to_use_case.signal_event_by_name(from_signal_event.name)

		if to_signal_event.nil?
			new_obj from_signal_event
		else
			check_existing(from_signal_event, to_signal_event)
		end			
	end

	def check_removed

		to_signal_events = @to_use_case.signal_events.each do |to_signal_event|
			
			ok = false
			@from_use_case.signal_events.each do |from_signal_event|

				if from_signal_event.name == to_signal_event.name
					ok = true
					break
				end
			end
			if !ok
				command = "- SignalEvent #{@from_use_case.full_name}::#{to_signal_event.name}"
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

	def new_obj(from_signal_event)
		command = "+ SignalEvent #{@from_use_case.full_name}::#{from_signal_event.name}"		
		@commands.add_command_to_buffer(command)		
	end

	def check_existing(from_signal_event, to_signal_event)

		@log.debug("Checking existing Signal Event: #{@from_use_case.full_name}::#{from_signal_event.name}")

		# Parameters
		merge = MergeParameters.new("SignalEvent", from_signal_event, to_signal_event)
		@only_check ? merge.check : merge.merge		
	end
end