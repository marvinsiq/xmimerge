require File.join(File.dirname(__FILE__), 'merge.rb')

class MergeStereotypes < Merge

	def initialize(name, from_tag, to_tag)
		super()
		@name = name
		@from_tag = from_tag
		@to_tag = to_tag
	end

	def verify

		@from_tag.stereotypes.each do |from_stereotype|
			check_changes(from_stereotype)
		end

		check_removed

	end

	def check_changes(from_stereotype)

		@log.debug("Checking Stereotype (#{from_stereotype.name}) of #{@name}...")

		to_stereotype = @to_tag.stereotype_by_name(from_stereotype.name)

		if to_stereotype.nil?
			new_stereotype from_stereotype
		end	
	end

	def new_stereotype(from_stereotype)

		@log.debug("New Stereotype (#{from_stereotype.name}) of #{@name}...")

		command = "\t+ #{@name}Stereotype #{@from_tag.full_name} {'#{from_stereotype.name}'}"
		@commands.add_command_to_buffer(command)
		unless @only_check 
			if @commands.has_command?(command)
				@to_tag.add_xml_stereotype(from_stereotype.xml)
				@log.info "[OK] #{command}"
			else
				@log.debug "[NOT] #{command}"
			end
		end	
	end

	def check_removed
		@to_tag.stereotypes.each do |to_stereotype|

			#puts "Xml stereotype: #{to_stereotype.xml}"
			#puts "Xml stereotype parent: #{to_stereotype.xml.parent}\n\n"	

			ok = false
			@from_tag.stereotypes.each do |from_stereotype|
				if to_stereotype.name == from_stereotype.name
					ok = true
					break
				end
			end
			if !ok		
				command = "\t- #{@name}Stereotype #{@from_tag.full_name} {'#{to_stereotype.name}'}"
				@commands.add_command_to_buffer(command)
				unless @only_check 
					if @commands.has_command?(command)
											
						to_stereotype.xml.inner_html = "asdasd"
						@to_tag.stereotypes.delete(to_stereotype)

						#puts "testando: #{to_stereotype.xml}"
						#puts "testando: #{@to_tag.xml}"
						@log.info "[OK] #{command}"
					else
						@log.debug "[NOT] #{command}"
					end
				end
			end
		end		
	end

end