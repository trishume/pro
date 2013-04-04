require "pro/version"
require "find"
require "fuzzy_match"

SHELL_FUNCTION = <<END
# pro cd function
{{name}}() {
  projDir=$(pro search $1)
  cd ${projDir}
}
END

CD_INFO = <<END
This installs a command to allow you to cd to a git repo
arbitrarily deep in your PRO_BASE based on fuzzy matching.

Example:

  ~/randomFolder/ $ pd pro
  pro/ $ pwd 
  /Users/tristan/Box/Dev/Projects/pro

========
END


module Pro
  # Finds the base directory where repos are kept
  # Checks the environment variable PRO_BASE and the
  # file .proBase
  def self.base_dir()
    # check environment first
    base = ENV['PRO_BASE']
    return base if base
    # next check proBase file
    path = ENV['HOME'] + "/.proBase"
    base = ENV['HOME'] # default to home
    if File.exists?(path)
      base = IO.read(path).chomp
      base = File.expand_path(base)
    end
    base
  end

  # Searches for all the git repositories in the base directory.
  # returns an array of [repo_name, path] pairs.
  def self.repo_list
    repos = []
    Find.find(Pro.base_dir) do |path|
      if FileTest.directory?(path)
        # is this folder a git repo
        if File.exists?(path+"/.git")
          base_name = File.basename(path)
          repos << [base_name,path]
          Find.prune
        end
      end
    end
    repos
  end

  # Fuzzy search for a git repository by name
  # Returns the full path to the repository.
  def self.find_repo(name)
    repos = Pro.repo_list
    match = FuzzyMatch.new(repos, :read => :first).find(name)
    match[1] unless match.nil?
  end

  # Adds a shell function to the shell config files that
  # allows easy directory changing.
  def self.install_cd
    puts CD_INFO
    print "Continue with installation (yN)? "
    return unless gets.chomp == "y"
    # get name
    print "Name of pro cd command (default 'pd'): "
    name = gets.strip
    name = 'pd' if name.empty?
    # sub into function
    func = SHELL_FUNCTION.sub("{{name}}",name)
    ['~/.bashrc','~/.zshrc'].each do |rel_path|
      # check if file exists
      path = File.expand_path(rel_path)
      next unless File.exists?(path)
      # ask the user if they want to add it
      print "Install #{name} function to #{rel_path} (yN): "
      next unless gets.chomp == "y"
      # add it on to the end of the file
      File.open(path,'a') do |file|
        file.puts func
      end
    end
    puts "Done! #{name} will be available in new shells."
  end
end
