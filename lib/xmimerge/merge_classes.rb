require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_attributes.rb')
require File.join(File.dirname(__FILE__), 'merge_operations.rb')
require File.join(File.dirname(__FILE__), 'merge_stereotypes.rb')
require File.join(File.dirname(__FILE__), 'merge_tagged_values.rb')
require File.join(File.dirname(__FILE__), 'merge_associations.rb')

class MergeClasses < Merge

	def initialize(from_package, to_package)
		super()
		@from_package = from_package
		@to_package = to_package
	end	

	def verify

		@from_package.classes.each do |from_class|		
			check_changes(from_class)
		end

		check_removed

	end

	def check_changes(from_class)

		to_class = @to_package.class_by_name(from_class.name)

		@log.info("Checking Class #{from_class.full_name}") if @only_check

		if to_class.nil?
			new_class from_class
		else
			check_existing_class(from_class, to_class)
		end
	end

	def check_removed

		@log.debug("Checking Removed Classes on package #{@to_package.full_name}...") if @only_check

		@to_package.classes.each do |to_class|
			
			ok = false
			@from_package.classes.each do |from_class|

				if from_class.full_name == to_class.full_name
					ok = true
					break
				end
			end
			if !ok
				@log.info("Class Removed: #{to_class.full_name}") if @only_check		
				command = "- Class #{to_class.full_name}"
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

	def new_class(from_class)
		@log.debug("New class") if @only_check
		command = "+ Class #{from_class.full_name}"
		@commands.add_command_to_buffer(command)

		unless @only_check 
			if @commands.has_command?(command)
				@to_package.add_xml_class(from_class.xml.to_xml)	
				@log.info "[OK] #{command}"				
			else
				@log.debug "[NOT] #{command}"
			end
		end

		from_class.attributes.each do |from_attribute|
			command = "\t+ Attribute #{from_class.full_name}::#{from_attribute.name}"
			@commands.add_command_to_buffer(command)
		end
	end

	def check_existing_class(from_class, to_class)
		
		@log.debug("Checking Existing Class: #{from_class.full_name}") if @only_check

		command = "* Class #{from_class.full_name}"
		@commands.add_command_to_buffer(command)	

		# Attributes
		merge = MergeAttribute.new(from_class, to_class)
		@only_check ? merge.check : merge.merge

		# Stereotypes		
		merge = MergeStereotypes.new("Class", from_class, to_class)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		merge = MergeTaggedValues.new("Class", from_class, to_class)
		@only_check ? merge.check : merge.merge

		# TODO

		# Generalization

		# Associations		
		merge = MergeAssociations.new(from_class, to_class)
		@only_check ? merge.check : merge.merge		

		# Operations
		merge = MergeOperations.new(from_class, to_class)
		@only_check ? merge.check : merge.merge

		@commands.remove_if_is_last_command(command)		
	end

end