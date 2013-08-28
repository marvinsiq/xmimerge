require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_states.rb')

class MergeActionStates < MergeStates

	def initialize(from_activity_graph, to_activity_graph)
		super("ActionState", "action_states", from_activity_graph, to_activity_graph)
	end

end