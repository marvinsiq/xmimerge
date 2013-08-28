require File.join(File.dirname(__FILE__), 'merge.rb')

class MergeOperations < Merge

	def initialize(from_class, to_class)
		super()
		@from_class = from_class
		@to_class = to_class
	end	

	def verify
		@from_class.operations.each do |from_operation|		
			check_changes(from_operation)
		end

		check_removed			
	end

	def check_changes(from_operation)

		@log.debug("Checking operation: #{@from_class.full_name}::#{from_operation.name}")		

		to_operation = @to_class.operation_by_name(from_operation.name)
		if to_operation.nil?
			new_operation from_operation
		else
			check_existing(from_operation, to_operation)
		end
	end

	def check_removed
		to_operations = @to_class.operations.each do |to_operation|
			
			ok = false
			@from_class.operations.each do |from_operation|

				if from_operation.name == to_operation.name
					ok = true
					break
				end
			end
			if !ok
				command = "\t- Operation #{@from_class.full_name}::#{to_operation.name}"
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

	def new_operation(from_operation)
		@log.debug("New operation")		

		command = "\t+ Operation #{@from_class.full_name}::#{from_operation.name}"		
		@commands.add_command_to_buffer(command)

		unless @only_check 
			if @commands.has_command?(command)
				@log.info "[OK] #{command}"
			else
				@log.info "[NOT] #{command}"
			end
		end
	end	

	def check_existing(from_operation, to_operation)

		from_full_operation_name = "#{@from_class.full_name}::#{from_operation.name}"

		# Visibility
		check_change_propertie("visibility", from_operation, to_operation, "OperationVisibility")

		# Parameters
		merge = MergeParameters.new("Operation", from_operation, to_operation)
		@only_check ? merge.check : merge.merge			
	end	

end