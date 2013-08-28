require 'test/unit'
require 'xmimerge'

class ClassTest < Test::Unit::TestCase

	def setup
		@log = App.logger
	end	

	def test_class_01_new
		@merge = XmiMerge.new("test/resource/MagicDraw/class/01_new_class/from.xml", "test/resource/MagicDraw/class/01_new_class/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		assert(file.has_command?("+ Class br.com.xmimerge.XmiMerge"))	
	end

	def test_class_02_stereotype
		@merge = XmiMerge.new("test/resource/MagicDraw/class/02_class_stereotype/from.xml", "test/resource/MagicDraw/class/02_class_stereotype/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		assert(file.has_command?("+ ClassStereotype br.com.xmimerge.XmiMerge {'UML Standard Profile::entity'}"))
		assert(file.has_command?("- ClassStereotype br.com.xmimerge.XmiMerge {'UML Standard Profile::utility'}"))
	end

	def test_class_03_tagged_values
		@merge = XmiMerge.new("test/resource/MagicDraw/class/03_class_tagged_values/from.xml", "test/resource/MagicDraw/class/03_class_tagged_values/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		assert(file.has_command?("* ClassTaggedValue br.com.xmimerge.XmiMerge {'TODO'} 'old_value' --> 'new_value'"))
		assert(file.has_command?("+ ClassTaggedValue br.com.xmimerge.XmiMerge {'persistence' = 'true'}"))
		assert(file.has_command?("- ClassTaggedValue br.com.xmimerge.XmiMerge {'derived'}"))
		assert(!file.has_command?("* ClassTaggedValue br.com.xmimerge.XmiMerge {'semantics'} 'A' --> 'A'"))
	end	

	def test_class_04_removed
		@merge = XmiMerge.new("test/resource/MagicDraw/class/04_class_removed/from.xml", "test/resource/MagicDraw/class/04_class_removed/to.xml")
		@merge.check
		file = CommandsFile.new
		file.load_commands
		assert(file.has_command?("- Class br.com.xmimerge.XmiMerge"))
	end

end