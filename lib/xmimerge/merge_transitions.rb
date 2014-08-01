require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_trigger.rb')

class MergeTransitions < Merge

def initialize(from_activity_graph, to_activity_graph)
		super()
		@from_activity_graph = from_activity_graph
		@to_activity_graph = to_activity_graph
	end

	def verify

		@log.info("Checking Transitions: " + @from_activity_graph.transitions.size.to_s) 

		@from_activity_graph.transitions.each do |transition|
			check_changes transition
		end		

		check_removed
	end

	def check_changes(from_transition)

		from_source_obj = from_transition.source
		from_target_obj = from_transition.target

		@log.debug("Checking Transition between '#{from_source_obj.name}' and '#{from_target_obj.name}'")

		to_transition = @to_activity_graph.transition_by_source_target_ids(from_source_obj.id, from_target_obj.id)

		if to_transition.nil?
			new_obj(from_transition, from_source_obj, from_target_obj)
		else
			check_existing(from_transition, to_transition)
		end		
	end

	def new_obj(from_transition, from_source_obj, from_target_obj)
		
		if from_source_obj.name == "Decision Point"
			source = "#{from_source_obj.name} [#{from_transition.guard_condition}]"
		else
			source =  "#{from_source_obj.name}"
		end

		target = "#{from_target_obj.name}"

		command = "+ Transition #{from_source_obj.activity_graph.full_name} {#{source}} --> {#{target}}"
		@commands.add_command_to_buffer(command)
	end

	def check_existing(from_transition, to_transition)

		# guard_condition
		check_change_propertie("guard_condition", from_transition, to_transition, "GuardCondition")

		# Stereotypes		
		merge = MergeStereotypes.new("Transition", from_transition, to_transition)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		merge = MergeTaggedValues.new("Transition", from_transition, to_transition)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		merge = MergeTrigger.new(from_transition, to_transition)
		@only_check ? merge.check : merge.merge			
	end

	def check_removed

		@log.debug("Checking Removed Transitions ...")

		@to_activity_graph.transitions.each do |to_transition|

			to_source_obj = to_transition.source
			to_target_obj = to_transition.target			
			
			ok = false
			@from_activity_graph.transitions.each do |from_transition|

				from_source_obj = from_transition.source
				from_target_obj = from_transition.target

				if from_source_obj.name == to_source_obj.name && from_target_obj.name == from_target_obj.name
					ok = true
					break
				end
			end
			if !ok
				@log.debug("Transition Removed: #{to_source_obj.activity_graph.full_name} {#{to_source_obj.name}} --> {#{to_target_obj.name}}")
				command = "- Transition #{to_source_obj.activity_graph.full_name} {#{to_source_obj.name}} --> {#{to_target_obj.name}}"
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