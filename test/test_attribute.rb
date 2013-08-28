require 'test/unit'
require 'xmimerge'

class AttributeTest < Test::Unit::TestCase
	
	def setup
		@log = App.logger
	end

	def teardown
		## Nothing really
	end

	def test_01_new_attribute
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/01_new_attribute/from.xml", "test/resource/MagicDraw/attribute/01_new_attribute/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "+ Attribute br.com.xmimerge.XmiMerge::description")
	end

	def test_02_change_attribute_name
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/02_change_attribute_name/from.xml", "test/resource/MagicDraw/attribute/02_change_attribute_name/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "+ Attribute br.com.xmimerge.XmiMerge::description")
		has_command(file, "- Attribute br.com.xmimerge.XmiMerge::name")
	end	

	def test_03_change_attribute_visibility
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/03_change_attribute_visibility/from.xml", "test/resource/MagicDraw/attribute/03_change_attribute_visibility/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "* AttributeVisibility br.com.xmimerge.XmiMerge::name {'private' --> 'public'}")
	end

	def test_04_change_attribute_type
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/04_change_attribute_type/from.xml", "test/resource/MagicDraw/attribute/04_change_attribute_type/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "* AttributeType br.com.xmimerge.XmiMerge::name {'UML Standard Profile::char' --> 'UML Standard Profile::byte'}")
	end

	def test_05_change_attribute_datatype
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/05_change_attribute_datatype/from.xml", "test/resource/MagicDraw/attribute/05_change_attribute_datatype/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "* AttributeType br.com.xmimerge.XmiMerge::name {'UML Standard Profile::char' --> 'br.com.xmimerge.Name'}")
	end

	def test_06_change_attribute_initial_value
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/06_change_attribute_initial_value/from.xml", "test/resource/MagicDraw/attribute/06_change_attribute_initial_value/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "* AttributeInitialValue br.com.xmimerge.XmiMerge::name {'' --> 'undefined'}")
	end

	def test_07_change_attribute_multiplicity
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/07_change_attribute_multiplicity/from.xml", "test/resource/MagicDraw/attribute/07_change_attribute_multiplicity/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "- AttributeMultiplicity br.com.xmimerge.XmiMerge::attr1 '[0, 0]'")
		not_has_command(file, "* AttributeMultiplicity br.com.xmimerge.XmiMerge::attr2 '[0, 0]' --> '[0, 0]'")
		has_command(file, "* AttributeMultiplicity br.com.xmimerge.XmiMerge::attr3 '[1, -1]' --> '[0, 1]'")
		has_command(file, "* AttributeMultiplicity br.com.xmimerge.XmiMerge::attr4 '[0, 0]' --> '[0, -1]'")
		has_command(file, "* AttributeMultiplicity br.com.xmimerge.XmiMerge::attr5 '[1, -1]' --> '[1, 1]'")
		has_command(file, "* AttributeMultiplicity br.com.xmimerge.XmiMerge::attr6 '[-1, -1]' --> '[1, -1]'")
		has_command(file, "+ AttributeMultiplicity br.com.xmimerge.XmiMerge::attr7 '[-1, -1]'")
	end

	def test_08_change_attribute_stereotype
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/08_change_attribute_stereotype/from.xml", "test/resource/MagicDraw/attribute/08_change_attribute_stereotype/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "+ AttributeStereotype br.com.xmimerge.XmiMerge::attr1 {'UML Standard Profile::UML2.0::flowFinal'}")
		has_command(file, "- AttributeStereotype br.com.xmimerge.XmiMerge::attr1 {'MagicDraw Profile::parameteredElement'}")
	end

	def test_09_change_attribute_tagged_value
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/09_change_attribute_tagged_value/from.xml", "test/resource/MagicDraw/attribute/09_change_attribute_tagged_value/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands

		has_command(file, "* AttributeTaggedValue br.com.xmimerge.XmiMerge::attr1 {'TODO'} 'test' --> 'new value'")
		has_command(file, "+ AttributeTaggedValue br.com.xmimerge.XmiMerge::attr1 {'derived' = 'true'}")
		has_command(file, "- AttributeTaggedValue br.com.xmimerge.XmiMerge::attr1 {'hyperlinkText'}")
		not_has_command(file, "* AttributeTaggedValue br.com.xmimerge.XmiMerge::attr1 {'persistence' 'true' --> 'true'}")
	end

	def test_10_remove_attribute
		@merge = XmiMerge.new("test/resource/MagicDraw/attribute/10_remove_attribute/from.xml", "test/resource/MagicDraw/attribute/10_remove_attribute/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		has_command(file, "- Attribute br.com.xmimerge.XmiMerge::description")		
	end

	def has_command(file, command)
		assert(file.has_command?(command), "The file does not have the command '#{command}'.\n#{file.commands}")		
	end	

	def not_has_command(file, command)
		assert(!file.has_command?(command), "The file has the command '#{command}'")
	end	

end