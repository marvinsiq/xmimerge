require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_stereotypes.rb')
require File.join(File.dirname(__FILE__), 'merge_tagged_values.rb')

class MergeStates < Merge

	def initialize(name_state, method_name, from_activity_graph, to_activity_graph)
		super()
		@name_state = name_state
		@from_activity_graph = from_activity_graph
		@to_activity_graph = to_activity_graph
		@method_name = method_name
	end

	def verify

		@from_activity_graph.send(@method_name).each do |state|
			check_changes state
		end		

		check_removed
	end

	def check_changes(from_state)

		@log.debug("Checking #{@name_state} '#{from_state.full_name}'")

		to_state = @to_activity_graph.state_by_id(from_state.id)		
		to_state = @to_activity_graph.state_by_name(from_state.name, @name_state) if to_state.nil?

		if to_state.nil?
			new_obj from_state
		else
			check_existing(from_state, to_state)
		end		
	end

	def new_obj(from_action_state)
		command = "+ #{@name_state} #{from_action_state.full_name}"
		@commands.add_command_to_buffer(command)
	end

	def check_existing(from_action_state, to_action_state)

		# Stereotypes		
		merge = MergeStereotypes.new(@name_state, from_action_state, to_action_state)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		merge = MergeTaggedValues.new(@name_state, from_action_state, to_action_state)
		@only_check ? merge.check : merge.merge		
	end

	def check_removed

		@log.debug("Checking Removed #{@name_state}...")

		@to_activity_graph.send(@method_name).each do |to_action_state|
			
			ok = false
			@from_activity_graph.send(@method_name).each do |from_action_state|

				if from_action_state.name == to_action_state.name
					ok = true
					break
				end
			end
			if !ok
				@log.debug("#{@name_state} Removed: #{to_action_state.full_name}")				
				command = "- #{@name_state} #{to_action_state.full_name}"
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