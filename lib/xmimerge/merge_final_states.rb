require File.join(File.dirname(__FILE__), 'merge_states.rb')

class MergeFinalStates < MergeStates

	def initialize(from_activity_graph, to_activity_graph)
		super("FinalState", "final_states", from_activity_graph, to_activity_graph)
	end

end