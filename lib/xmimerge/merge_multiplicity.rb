require File.join(File.dirname(__FILE__), 'merge.rb')

class MergeMultiplicity < Merge

	def initialize(name, from_tag, to_tag)
		super()
		@name = name
		@from_tag = from_tag
		@to_tag = to_tag
	end

	def verify

		from_value = @from_tag.multiplicity_range
		to_value = @to_tag.multiplicity_range

		if !from_value.nil? && to_value.nil?

			command = "+ #{@name}Multiplicity #{@from_tag.full_name} '#{from_value}'"
			@commands.add_command_to_buffer(command)	
		
		elsif from_value.nil? && !to_value.nil?

			command = "- #{@name}Multiplicity #{@from_tag.full_name} '#{to_value}'"
			@commands.add_command_to_buffer(command)
		
		elsif (!from_value.nil? && !to_value.nil?) && to_value != from_value
			
			command = "* #{@name}Multiplicity #{@from_tag.full_name} '#{to_value}' --> '#{from_value}'"
			@commands.add_command_to_buffer(command)
		end			

	end
	
end