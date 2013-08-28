
class Util

	def self.attribute_changes(attribute, from, to)		
		from_attribute_name = from.attribute(attribute).to_s
		to_attribute_name = to.attribute(attribute).to_s		
		
		if !(from_attribute_name.eql? to_attribute_name)
			App.instance.logger.debug("Property '#{attribute}' changed: old = #{to_attribute_name}, new = #{from_attribute_name}")
			return [to_attribute_name, from_attribute_name]
		end
		nil
	end	

	def self.check_change_by_method(method, from, to)
		
		from_value = from.send(method)
		to_value = to.send(method)

		if !(from_value.eql? to_value)
			App.logger.debug("'#{method}' changed: old = '#{to_value}', new = '#{from_value}'")
			return [to_value,from_value]
		end
		nil
	end	

	def self.diff_time(start_time, end_time = Time.now)
		diff = (end_time - start_time)
		s = (diff % 60).to_i
		m = (diff / 60).to_i
		h = (m / 60).to_i

		if s > 0 || m >0 || h >0
			if h == 0
				if m == 0
					"#{(s < 10) ? '0' + s.to_s : s} second(s)"
				else
					"#{(m < 10) ? '0' + m.to_s : m} minute(s) and #{(s < 10) ? '0' + s.to_s : s} second(s)"
				end
			else
		  		"#{(h < 10) ? '0' + h.to_s : h}:#{(m < 10) ? '0' + m.to_s : m}:#{(s < 10) ? '0' + s.to_s : s}"
		  	end
		else
		  format("%.5f", diff) + " miliseconds"
		end
	end		

end