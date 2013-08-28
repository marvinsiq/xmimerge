require File.join(File.dirname(__FILE__), 'merge.rb')

class MergeParameters < Merge

	def initialize(name, from_tag, to_tag)
		super()
		@name = name
		@from_tag = from_tag
		@to_tag = to_tag
	end

	def verify

		@from_tag.parameters.each do |from_parameter|
			check_changes(from_parameter)
		end

		check_removed

	end

	def check_changes(from_parameter)

		@log.debug("Checking #{@name}Parameter #{from_parameter.full_name}...")

		to_parameter = @to_tag.parameter_by_name(from_parameter.name)

		if to_parameter.nil?
			new_obj from_parameter
		else
			check_existing(from_parameter, to_parameter)
		end	
	end

	def new_obj(from_parameter)

		@log.debug("New Parameter #{from_parameter.name}...")

		command = "+ #{@name}Parameter #{@from_tag.full_name} {'#{from_parameter.name}'}"
		@commands.add_command_to_buffer(command)
		unless @only_check 
			if @commands.has_command?(command)
				@log.info "[OK] #{command}"
			else
				#@log.info "[NOT] #{command}"
			end
		end	
	end

	def check_existing(from_parameter, to_parameter)

		# TODO

		# kind

		# UML:Parameter.type

		# Stereotypes		
		merge = MergeStereotypes.new("#{@name}Parameter", from_parameter, to_parameter)
		@only_check ? merge.check : merge.merge		

		# TaggedValues
		merge = MergeTaggedValues.new("#{@name}Parameter", from_parameter, to_parameter)
		@only_check ? merge.check : merge.merge		
	end

	def check_removed
		to_parameters = @to_tag.parameters.each do |to_parameter|
			ok = false
			@from_tag.parameters.each do |from_parameter|
				if to_parameter.name == from_parameter.name
					ok = true
					break
				end
			end
			if !ok		
				command = "- #{@name}Parameter #{@from_tag.full_name} {'#{to_parameter.name}'}"
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
end