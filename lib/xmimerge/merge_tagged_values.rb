require File.join(File.dirname(__FILE__), 'merge.rb')

class MergeTaggedValues < Merge

	def initialize(name, from_tag, to_tag)
		super()
		@name = name
		@from_tag = from_tag
		@to_tag = to_tag
	end

	def verify
		@from_tag.tagged_values.each do |from_tagged_value|
			check_new(from_tagged_value)
		end
		check_removed
	end

	def check_new(from_tagged_value)

		@log.debug("Checking TaggedValue '#{@from_tag.full_name}'...") if @only_check

		to_tagged_value = @to_tag.tagged_value_by_name(from_tagged_value.name)
		if to_tagged_value.nil?			

			@log.debug("New Tagged Value #{from_tagged_value.name}...") if @only_check
			command = "\t+ #{@name}TaggedValue #{@from_tag.full_name} {'#{from_tagged_value.name}' = '#{from_tagged_value.value}'}"
			@commands.add_command_to_buffer(command)
			unless @only_check 
				if @commands.has_command?(command)
					@to_tag.add_xml_tagged_value(from_tagged_value.xml.to_xml)	
					@log.info "[OK] #{command}"
				else
					#@log.info "[NOT] #{command}"
				end
			end
		else
			if from_tagged_value.value != to_tagged_value.value
				@log.debug("Change Tagged Value #{from_tagged_value.name}...") if @only_check
				command = "\t* #{@name}TaggedValue #{@from_tag.full_name} {'#{from_tagged_value.name}'} '#{to_tagged_value.value}' --> '#{from_tagged_value.value}'"
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

	def check_removed
		to_tagged_values = @to_tag.tagged_values.each do |to_tagged_value|
			ok = false
			@from_tag.tagged_values.each do |from_tagged_value|
				if to_tagged_value.name == from_tagged_value.name
					ok = true
					break
				end
			end
			if !ok
				command = "\t- #{@name}TaggedValue #{@from_tag.full_name} {'#{to_tagged_value.name}'}"
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