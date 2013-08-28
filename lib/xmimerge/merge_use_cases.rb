require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_activity_graphs.rb')
require File.join(File.dirname(__FILE__), 'merge_classes.rb')
require File.join(File.dirname(__FILE__), 'merge_signal_events.rb')

class MergeUseCases < Merge

	def initialize(from_package, to_package)
		super()
		@from_package = from_package
		@to_package = to_package
	end

	def verify

		@log.debug("Checking Use Cases...")

		@from_package.use_cases.each do |use_case|
			check_changes use_case
		end		

		check_removed
	end

	def check_changes(from_use_case)

		@log.info("Checking UseCase #{from_use_case.full_name}")

		to_use_case = @to_package.use_case_by_name(from_use_case.name)

		if to_use_case.nil?
			new_use_case to_use_case
		else
			check_existing_use_case(from_use_case, to_use_case)
		end	
	end

	def new_use_case(from_use_case)
		command = "+ UseCase #{from_use_case.full_name}"
		@commands.add_command_to_buffer(command)
	end

	def check_existing_use_case(from_use_case, to_use_case)

		# Stereotypes		
		merge = MergeStereotypes.new("UseCase", from_use_case, to_use_case)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		merge = MergeTaggedValues.new("UseCase", from_use_case, to_use_case)
		@only_check ? merge.check : merge.merge

		# SignalEvent
		merge = MergeSignalEvents.new(from_use_case, to_use_case)
		@only_check ? merge.check : merge.merge

		# SignalEvent
		merge = MergeActivityGraphs.new(from_use_case, to_use_case)
		@only_check ? merge.check : merge.merge	
	end

	def check_removed
		@log.debug("Checking Removed UseCases on package #{@to_package.full_name}...")

		@to_package.use_cases.each do |to_use_case|
			
			ok = false
			@from_package.use_cases.each do |from_use_case|

				if from_use_case.name == to_use_case.name
					ok = true
					break
				end
			end
			if !ok
				command = "- UseCase #{from_use_case.full_name}"
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

end