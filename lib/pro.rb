require "pro/version"
require "find"
require "fuzzy_match"

module Pro
  def self.find_repo(name)
    repos = []
    Find.find(ENV['HOME']+"/Box") do |path|
      if FileTest.directory?(path)
        # is this folder a git repo
        if File.exists?(path+"/.git")
          base_name = File.basename(path)
          repos << [base_name,path]
          Find.prune
        end
      end
    end
    match = FuzzyMatch.new(repos, :read => :first).find(name)
    match[1] unless match.nil?
  end
end
