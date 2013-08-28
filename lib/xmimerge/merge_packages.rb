require File.join(File.dirname(__FILE__), 'merge.rb')
require File.join(File.dirname(__FILE__), 'merge_classes.rb')
require File.join(File.dirname(__FILE__), 'merge_use_cases.rb')

class MergePackages < Merge

	def initialize()
		super()
	end

	def verify

		@log.debug("Checking Packages...") if @only_check

		@from.packages.each do |package|
			check_changes package
		end		

		check_removed

	end

	def check_changes(from_package)

		@log.info("Checking Package #{from_package.full_name}") if @only_check

		to_package = @to.package_by_full_name(from_package.full_name)

		if to_package.nil?
			new_obj from_package
		else
			check_existing_package(from_package, to_package)
		end	
	end

	def new_obj(from_package)
		command = "+ Package #{from_package.full_name}"
		@commands.add_command_to_buffer(command)
	end

	def check_existing_package(from_package, to_package)

		@log.debug("Checking existing package '#{from_package.name}'...") if @only_check

		merge = MergeClasses.new(from_package, to_package)
		@only_check ? merge.check : merge.merge

		merge = MergeUseCases.new(from_package, to_package)
		@only_check ? merge.check : merge.merge		
	end

	def check_removed

		@log.debug("Checking Removed Packages...") if @only_check

		@to.packages.each do |to_package|
			
			ok = false
			@from.packages.each do |from_package|

				if from_package.full_name == to_package.full_name
					ok = true
					break
				end
			end
			if !ok
				@log.info("Package removed: #{to_package.full_name}") if @only_check			
				command = "- Package #{to_package.full_name}"
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

end