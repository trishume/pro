require "pro/index"
require "find"
require "fuzzy_match"
require "colored"

SHELL_FUNCTION = <<END

# pro cd function
{{name}}() {
  local projDir=$(pro search $1)
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
  class Commands
    DIRTY_MESSAGE = 'uncommitted'.red
    UNPUSHED_MESSAGE = 'unpushed'.blue
    JOIN_STRING = ' + '

    def initialize(index)
      @index = index
    end

    # Fuzzy search for a git repository by name
    # Returns the full path to the repository.
    # 
    # If name is nil return the pro base.
    def find_repo(name)
      return @index.base_dirs.first unless name
      match = FuzzyMatch.new(@index.to_a, :read => :name).find(name)
      match[1] unless match.nil?
    end

    def run_command(command, confirm = true)
      if confirm
        print "Do you really want to run '#{command.bold}' on all repos [Y/n]? "
        ans = STDIN.gets
        return if ans.chomp != "Y"
      end
      @index.each do |r|
        Dir.chdir(r.path)
        result = `#{command}`
        puts "#{r.name}:".bold.red
        puts result
      end
    end

    # Prints out the paths to all repositories in all bases
    def list_repos()
      @index.each do |r|
        puts r.path
      end
    end

    # prints a status list showing repos with
    # unpushed commits or uncommitted changes
    def status()
      max_name = @index.map {|repo| repo.name.length}.max + 1
      @index.each do |r|
        status = repo_status(r.path)
        next if status.empty?
        name = format("%-#{max_name}s",r.name).bold
        puts "#{name} > #{status}"
      end
    end

    # returns a short status message for the repo
    def repo_status(path)
      messages = []
      messages << DIRTY_MESSAGE unless repo_clean?(path)
      messages << UNPUSHED_MESSAGE if repo_unpushed?(path)
      messages.join(JOIN_STRING)
    end

    # Checks if there are any uncommitted changes
    def repo_clean?(path)
      status = ""
      Dir.chdir(path) do
        status = `git status 2>/dev/null`
      end
      return status.end_with?("(working directory clean)\n") || status.end_with?("working directory clean\n")
    end

    # Finds if there are any commits which have not been pushed to origin
    def repo_unpushed?(path)
      unpushed = ""
      Dir.chdir(path) do
        branch_ref = `/usr/bin/git symbolic-ref HEAD 2>/dev/null`
        branch = branch_ref.chomp.split('/').last
        unpushed = `git cherry -v origin/#{branch} 2>/dev/null`
      end
      return !(unpushed.empty?)
    end

    # Adds a shell function to the shell config files that
    # allows easy directory changing.
    def install_cd
      puts CD_INFO
      print "Continue with installation (yN)? "
      return unless gets.chomp == "y"
      # get name
      print "Name of pro cd command (default 'pd'): "
      name = gets.strip
      name = 'pd' if name.empty?
      # sub into function
      func = SHELL_FUNCTION.sub("{{name}}",name)
      ['~/.profile', '~/.bashrc','~/.zshrc'].each do |rel_path|
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
end