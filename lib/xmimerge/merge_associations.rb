# encoding: utf-8

require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'util.rb')
require File.join(File.dirname(__FILE__), 'merge_associations_end.rb')
require File.join(File.dirname(__FILE__), 'merge_stereotypes.rb')
require File.join(File.dirname(__FILE__), 'merge_tagged_values.rb')
require File.join(File.dirname(__FILE__), 'merge_multiplicity.rb')

class MergeAssociations < Merge

	def initialize(from_class, to_class)
		super()
		@from_class = from_class
		@to_class = to_class
	end	

	def verify

		@from_class.associations.each do |from_association|		
			check_changes(from_association)
		end

		#check_removed
	end

	# @param [Association, #read] from_association.
	def check_changes(from_association)

		@log.debug("Checking association: #{from_association.full_name}")

		# Localiza a associação no modelo destino
		to_association = @to_class.xml_root.association_by_id(from_association.id)

		if to_association.nil?
			# Se não encontrou é poque é uma nova associação
			new_association from_association
		else
			# Associação já existe, verifica se houve alterações
			check_existing_association(from_association, to_association)
		end
	end

	def check_removed
		@to_class.xml_root.associations.each do |to_association|
			
			ok = false
			@from_class.xml_root.associations.each do |from_association|

				if from_association == to_association
					ok = true
					break
				end
			end
			if !ok
				command = "\t- Association #{to_association.full_name}"
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

	# @param [Association, #read] from_association.
	def new_association(from_association)
		@log.debug("New Association")		

		puts "teste " + from_association.class.name

		command = "\t+ Association #{from_association.full_name}"
		@commands.add_command_to_buffer(command)

		unless @only_check 
			if @commands.has_command?(command)
				@log.info "[OK] #{command}"
			else
				@log.info "[NOT] #{command}"
			end
		end
	end	

	def check_existing_association(from_association, to_association)

		# Visibility
		check_change_propertie("name", from_association, to_association, "AssociationName")

		# Stereotypes		
		merge = MergeStereotypes.new("Association", from_association, to_association)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		t = MergeTaggedValues.new("Association", from_association, to_association)
		@only_check ? t.check : t.merge


		if from_association.end_a != to_association.end_a
			command = "\t* AssociationEndA #{from_association.end_a.name} {'#{from_association.end_a.participant.full_name}' --> '#{to_association.end_a.participant.full_name}'}"
			@commands.add_command_to_buffer(command)			
		end

		if from_association.end_b != to_association.end_b
			command = "\t* AssociationEndB #{from_association.end_b.name} {'#{from_association.end_b.participant.full_name}' --> '#{to_association.end_b.participant.full_name}'}"
			@commands.add_command_to_buffer(command)				
		end

		# AssociationEnd
		end_a = MergeAssociationEnd.new("AssociationEndA", from_association.end_a, to_association.end_a)
		@only_check ? end_a.check : end_a.merge
		
		end_b = MergeAssociationEnd.new("AssociationEndB", from_association.end_b, to_association.end_b)
		@only_check ? end_b.check : end_b.merge	
	end

end