require File.join(File.dirname(__FILE__), 'merge.rb')

class MergeTrigger < Merge

	def initialize(from_transition, to_transition)
		super()
		@from_transition = from_transition
		@to_transition = to_transition
	end

	def verify

		@log.debug("Checking Trigger...")

		check_changes(@from_transition.trigger) unless @from_transition.trigger.nil?
	
		check_removed
	end

	def check_changes(from_trigger)

		@log.info("Checking Trigger '#{from_trigger.full_name}'")

		to_trigger = @to_transition.trigger

		if to_trigger.nil?
			new_trigger to_trigger
		else
			check_existing_trigger(from_trigger, to_trigger)
		end	
	end

	def new_trigger(from_trigger)
		command = "+ Trigger #{from_trigger.full_name}"
		@commands.add_command_to_buffer(command)
	end

	def check_existing_trigger(from_trigger, to_trigger)

		# Type
		check_change_propertie("name", from_trigger, to_trigger, "TriggerName")		

		# Stereotypes		
		#merge = MergeStereotypes.new("Trigger", from_trigger, to_trigger)
		#@only_check ? merge.check : merge.merge

		# TaggedValues
		#merge = MergeTaggedValues.new("Trigger", from_trigger, to_trigger)
		#@only_check ? merge.check : merge.merge

		# SignalEvent
		#merge = MergeSignalEvents.new(from_trigger, to_trigger)
		#@only_check ? merge.check : merge.merge

		# Parameters
		merge = MergeParameters.new("Trigger", from_trigger, to_trigger)
		@only_check ? merge.check : merge.merge	
	end

	def check_removed
		@log.debug("Checking Removed Triggers on transition '#{@to_transition.full_name}'...")

		if !@to_transition.trigger.nil? && @from_transition.trigger.nil?
			command = "- Trigger #{from_trigger.full_name}"
			@commands.add_command_to_buffer(command)
			unless @only_check 
				if @commands.has_command?(command)
					@log.info "[OK] #{command}"
				else
					@log.info "[NOT] #{command}"
				end
			end
		end		
	end

end