# encoding: utf-8

require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_stereotypes.rb')
require File.join(File.dirname(__FILE__), 'merge_tagged_values.rb')
require File.join(File.dirname(__FILE__), 'merge_multiplicity.rb')

class MergeAssociationEnd < Merge

	def initialize(name, from_association_end, to_association_end)
		super()
		@name = name
		@from_association_end = from_association_end
		@to_association_end = to_association_end
	end	

	def verify

		# Visibility
		check_change_propertie("visibility", @from_association_end, @to_association_end, "AssociationVisibility")

		# IsNavegable
		check_change_propertie("is_navigable", @from_association_end, @to_association_end, "AssociationIsNavegable")

		# Initial Value
		check_change_propertie("is_specification", @from_association_end, @to_association_end, "AssociationIsSpecification")

		# Ordering
		check_change_propertie("ordering", @from_association_end, @to_association_end, "AssociationOrdering")

		# Aggregation
		check_change_propertie("aggregation", @from_association_end, @to_association_end, "AssociationAggregation")

		# Initial Value
		check_change_propertie("target_scope", @from_association_end, @to_association_end, "AssociationTargetScope")

		# Changeability
		check_change_propertie("changeability", @from_association_end, @to_association_end, "AssociationChangeability")		

		# Multiplicity
		merge = MergeMultiplicity.new("Attribute", @from_association_end, @to_association_end)
		@only_check ? merge.check : merge.merge

		# Stereotypes		
		merge = MergeStereotypes.new("Association", @from_association_end, @to_association_end)
		@only_check ? merge.check : merge.merge

		# TaggedValues
		t = MergeTaggedValues.new("Association", @from_association_end, @to_association_end)
		@only_check ? t.check : t.merge			

		# TODO

		# Type Modifier
		# Scope
		# Documentation
	end

end