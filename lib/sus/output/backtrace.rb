# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module Sus
	module Output
		# Print out a backtrace relevant to the given test identity if provided.
		class Backtrace
			def self.first(identity = nil)
				# This implementation could be a little more efficient.
				self.new(caller_locations(1), identity&.path, 1)
			end
			
			def self.for(exception, identity = nil, verbose: false)
				self.new(exception.backtrace_locations, verbose ? nil : identity&.path)
			end
			
			def initialize(stack, root = nil, limit = nil)
				@stack = stack
				@root = root
				@limit = limit
			end
			
			def filter(root = @root)
				if @root
					stack = @stack.select do |frame|
						frame.path.start_with?(@root)
					end
				else
					stack = @stack
				end
				
				if @limit
					stack = stack.take(@limit)
				end
				
				return stack
			end
			
			def print(output)
				if @limit == 1
					filter.each do |frame|
						output.write " ", :path, frame.path, :line, ":", frame.lineno
					end
				else
					output.indented do
						filter.each do |frame|
							output.puts :indent, :path, frame.path, :line, ":", frame.lineno, :reset, " ", frame.label
						end
					end
				end
			end
		end
	end
end
