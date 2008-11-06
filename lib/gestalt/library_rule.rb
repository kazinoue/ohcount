module Ohcount
	module Gestalt

		class LibraryRule
			def ==(other)
				return false unless self.class == other.class
				return false unless self.instance_variables == other.instance_variables
				self.instance_variables.each do |v|
					return false unless self.send(v[1..-1]) == other.send(v[1..-1])
				end
				true
			end
		end

		class CHeaderRule < LibraryRule
			attr_reader :headers

			def initialize(*headers)
				@headers = headers
			end

			def trigger?(source_file)
				return false unless ['c','cpp'].include?(source_file.polyglot)
				regexp.match(source_file.language_breakdowns('c').code) ||
					regexp.match(source_file.language_breakdowns('cpp').code)
			end

			def regexp
				@regexp ||= begin
					header_term = "(" + headers.join("|") + ")"
					Regexp.new("include\s+['<\"]#{ header_term }[\">']", Regexp::IGNORECASE)
				end
			end
		end

		class FileRule < LibraryRule
			attr_reader :filenames

			def initialize(filenames)
				@filenames = filenames
			end

			def trigger?(source_file)
				# string_matches
				filenames.include?(source_file.basename)
			end

			def regex
				#@regexp ||= begin
				#	filenames.collect		
				#	Regexp.new("(" + keywords.join("|") + ")")
				#end
			end
		end

		class KeywordLibraryRule
			attr_reader :keywords, :language

			def initialize(language, *keywords)
				@language = language
				@keywords = keywords
			end

			def trigger?(source_file)
				return unless source_file.language_breakdowns(language)
				regexp.match(source_file.language_breakdowns(language).code)
			end

			def regexp
				@regexp ||= begin
					Regexp.new("(" + keywords.join("|") + ")")
				end
			end
		end

		class CKeywordRule < KeywordLibraryRule

			def initialize(*keywords)
				super('c',*keywords)
			end

			def trigger?(source_file)
				return false unless ['c','cpp'].include?(source_file.polyglot)
				regexp.match(source_file.language_breakdowns('c').code) ||
					regexp.match(source_file.language_breakdowns('cpp').code)
			end
		end

	end
end
