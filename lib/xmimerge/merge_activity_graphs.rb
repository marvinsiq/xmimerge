require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_action_states.rb')
require File.join(File.dirname(__FILE__), 'merge_final_states.rb')
require File.join(File.dirname(__FILE__), 'merge_pseudo_states.rb')
require File.join(File.dirname(__FILE__), 'merge_transitions.rb')

class MergeActivityGraphs  < Merge

	def initialize(from_use_case, to_use_case)
		super()
		@from_use_case = from_use_case
		@to_use_case = to_use_case
	end

	def verify

		@from_use_case.activity_graphs.each do |activity_graphs|
			check_changes activity_graphs
		end		

		check_removed
	end

	def check_changes(from_activity_graph)

		@log.info("Checking Activity Graph #{from_activity_graph.full_name}")

		to_activity_graph = @to_use_case.activity_graphs_by_name(from_activity_graph.name)

		if to_activity_graph.nil?
			new_obj to_activity_graph
		else
			check_existing(from_activity_graph, to_activity_graph)
		end	
	end

	def new_obj(from_activity_graph)
		command = "+ ActivityGraph #{from_activity_graph.full_name}"
		@commands.add_command_to_buffer(command)
	end

	def check_existing(from_activity_graph, to_activity_graph)

		@log.debug("Checking Existing Activity Graph: #{from_activity_graph.full_name}")

		# ActionState
		merge = MergeActionStates.new(from_activity_graph, to_activity_graph)
		@only_check ? merge.check : merge.merge

		# FinalState
		merge = MergeFinalStates.new(from_activity_graph, to_activity_graph)
		@only_check ? merge.check : merge.merge

		# PseudoState
		merge = MergePseudoStates.new(from_activity_graph, to_activity_graph)
		@only_check ? merge.check : merge.merge

		# Transition
		merge = MergeTransitions.new(from_activity_graph, to_activity_graph)
		@only_check ? merge.check : merge.merge	
	end

	def check_removed

		@log.debug("Checking removed Activity Graph...")

		@to_use_case.activity_graphs.each do |to_activity_graph|
			
			ok = false
			@from_use_case.activity_graphs.each do |from_activity_graph|

				if from_activity_graph.name == to_activity_graph.name
					ok = true
					break
				end
			end
			if !ok
				@log.info("Activity Graph Removed: #{to_activity_graph.full_name}")				
				command = "- ActivityGraph #{to_activity_graph.full_name}"
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