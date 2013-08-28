require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'util.rb')
require File.join(File.dirname(__FILE__), 'merge_stereotypes.rb')
require File.join(File.dirname(__FILE__), 'merge_tagged_values.rb')
require File.join(File.dirname(__FILE__), 'merge_multiplicity.rb')

class MergeAttribute < Merge

	def initialize(from_class, to_class)
		super()
		@from_class = from_class
		@to_class = to_class
	end	

	def verify

		initial_buffer_size = @commands.buffer_size

		@from_class.attributes.each do |from_attribute|		
			check_changes(from_attribute)
		end

		check_removed

		@commands.buffer_size != initial_buffer_size
	end

	def check_changes(from_attribute)

		@log.debug("Checking attribute: #{@from_class.full_name}::#{from_attribute.name}") if @only_check

		# Localiza o atributo no modelo destino pelo nome
		to_attribute = @to_class.attribute_by_name(from_attribute.name)
		if to_attribute.nil?
			# Se não encontrou é poque é um novo atributo
			new_attribute from_attribute
		else
			# Atributo já existe, verifica se houve alterações
			check_existing_attribute(from_attribute, to_attribute)
		end
	end

	def check_removed
		@to_class.attributes.each do |to_attribute|
			
			ok = false
			@from_class.attributes.each do |from_attribute|

				if from_attribute.name == to_attribute.name
					ok = true
					break
				end
			end
			if !ok
				command = "\t- Attribute #{@from_class.full_name}::#{to_attribute.name}"
				@commands.add_command_to_buffer(command)
				unless @only_check 
					if @commands.has_command?(command)
						@log.info "[OK] #{command}"
					else
						#@log.warn "[NOT] #{command}"
					end
				end
			end
		end		
	end

	def new_attribute(from_attribute)
		@log.debug("New Attribute")	if @only_check

		command = "\t+ Attribute #{@from_class.full_name}::#{from_attribute.name}"		
		@commands.add_command_to_buffer(command)

		unless @only_check 
			if @commands.has_command?(command)
				@to_class.add_xml_attribute(from_attribute.xml.to_xml)					
				@log.info "[OK] #{command}"
			else
				#@log.warn "[NOT] #{command}"
			end
		end
	end	

	def check_existing_attribute(from_attribute, to_attribute)

		from_full_attribute_name = "#{@from_class.full_name}::#{from_attribute.name}"

		# Name
		#changes = Util.check_change_by_method("name", from_attribute, to_attribute)
		#check_change_propertie(changes, "AttributeName", from_attribute.full_name)		

		# Visibility
		check_change_propertie("visibility", from_attribute, to_attribute, "AttributeVisibility")

		# Type
		check_change_propertie("type", from_attribute, to_attribute, "AttributeType")

		# Initial Value
		check_change_propertie("initial_value", from_attribute, to_attribute, "AttributeInitialValue")


		# Multiplicity
		merge = MergeMultiplicity.new("Attribute", from_attribute, to_attribute)
		@only_check ? merge.check : merge.merge

		# Stereotypes		
		merge = MergeStereotypes.new("Attribute", from_attribute, to_attribute)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		t = MergeTaggedValues.new("Attribute", from_attribute, to_attribute)
		@only_check ? t.check : t.merge			

		# TODO

		# Type Modifier
		# Changeability
		# Ordering
		# Scope
		# Documentation
		

	end

end