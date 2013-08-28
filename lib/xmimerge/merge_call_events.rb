
class MergeCallEvents < Merge

def initialize(from_use_case, to_use_case)
		super()
		@from_use_case = from_use_case
		@to_use_case = to_use_case
	end	

	def verify
		@from_use_case.call_events.each do |from_call_event|		
			check_changes(from_call_event)
		end

		check_removed			
	end

	def check_changes(from_call_event)
		@log.debug("Checking Call Event #{from_call_event.name}")

		# Encontra a operação no modelo de origem pelo id
		from_xmi_content = @from_use_case.document.at_xpath("./XMI/XMI.content")
		from_operation = XmiHelper.operation_by_id(from_xmi_content, from_call_event.operation)

		# Encontra a operação no modelo destino pelo nome
		to_operation = XmiHelper.operation_by_id(to_xmi_content, from_call_event.operation)

		to_call_event = @to_use_case.call_event_by_operation_id(from_call_event.name)

		if to_call_event.nil?
			new_obj from_call_event
		else
			check_existing(from_call_event, to_call_event)
		end		
	end

	def check_removed
	end
end