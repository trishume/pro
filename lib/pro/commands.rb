require "pro/index"
require "find"
require "fuzzy_match"
require "colored"
require "open3"

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
    EMPTY_MESSAGE = 'empty'.green
    UNCOMMITTED_MESSAGE = 'uncommitted'.red
    UNTRACKED_MESSAGE = 'untracked'.magenta
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
        print "Do you really want to run '#{command.bold}' on all repos [Yn]? "
        ans = STDIN.gets.chomp.downcase
        return unless ans == 'y' || ans.empty?
      end
      @index.each do |r|
        Dir.chdir(r.path)
        stdin, result, wait_thr = Open3.popen2e(command)
        puts "#{r.name}:".bold.red
        puts result.read
        [stdin, result].map &:close
      end
    end

    # Prints out the paths to all repositories in all bases
    def list_repos()
      @index.each do |r|
        puts r.path
      end
    end

    # prints out all the base directories
    def list_bases
      @index.base_dirs.each do |b|
        puts b
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
      messages << EMPTY_MESSAGE if repo_empty?(path)
      messages << UNCOMMITTED_MESSAGE if commit_pending?(path)
      messages << UNTRACKED_MESSAGE if untracked_files?(path)
      messages << UNPUSHED_MESSAGE if repo_unpushed?(path)
      messages.join(JOIN_STRING)
    end

    # Checks if there are nothing in the repo
    def repo_empty?(path)
      status = ""
      Dir.chdir(path) do
        status = `git status 2>/dev/null`
      end
      return status.include?("Initial commit")
    end

    # Checks if there are pending commits / edited files
    def commit_pending?(path)
      status = ""
      Dir.chdir(path) do
        status = `git status 2>/dev/null`
      end
      return status.include?("Changes to be committed") || status.include?("Changes not staged for commit")
    end

    # Checks if there are untracked files in the repo
    def untracked_files?(path)
      status = ""
      Dir.chdir(path) do
        status = `git status 2>/dev/null`
      end
      return status.include?("Untracked files")
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
      return unless gets.chomp.downcase == "y"
      # get name
      print "Name of pro cd command (default 'pd'): "
      name = gets.strip
      name = 'pd' if name.empty?
      # sub into function
      func = SHELL_FUNCTION.sub("{{name}}",name)
      did_any = false
      ['~/.profile', '~/.bashrc','~/.zshrc','~/.bash_profile'].each do |rel_path|
        # check if file exists
        path = File.expand_path(rel_path)
        next unless File.exists?(path)
        # ask the user if they want to add it
        print "Install #{name} function to #{rel_path} [yN]: "
        next unless gets.chomp.downcase == "y"
        # add it on to the end of the file
        File.open(path,'a') do |file|
          file.puts func
        end
        did_any = true
      end
      if did_any
        puts "Done! #{name} will be available in new shells."
      else
        STDERR.puts "WARNING: Did not install in any shell dotfiles.".red
        STDERR.puts "Maybe you should create the shell config file you want.".red
      end
    end
  end
end
