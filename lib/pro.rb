require "pro/version"
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
  DIRTY_MESSAGE = 'uncommitted'.red
  UNPUSHED_MESSAGE = 'unpushed'.blue
  JOIN_STRING = ' + '
  # Finds the base directory where repos are kept
  # Checks the environment variable PRO_BASE and the
  # file .proBase
  def self.base_dirs()
    bases = []
    # check environment first
    base = ENV['PRO_BASE']
    bases << base if base
    # next check proBase file
    path = ENV['HOME'] + "/.proBase"
    if File.exists?(path)
      # read lines of the pro base file
      bases += IO.read(path).split("\n").map {|p| File.expand_path(p.strip)}
    end
    # strip bases that do not exist
    bases.select! {|b| File.exists?(b)}
    # if no bases then return home
    bases << ENV['HOME'] if bases.empty?
    bases
  end

  # Searches for all the git repositories in the base directory.
  # returns an array of [repo_name, path] pairs.
  def self.repo_list
    repos = []
    Pro.base_dirs.each do |base|
      Find.find(base) do |path|
        if FileTest.directory?(path)
          # is this folder a git repo
          if File.exists?(path+"/.git")
            base_name = File.basename(path)
            repos << [base_name,path]
            Find.prune
          end
        end
      end
    end
    repos
  end

  # Fuzzy search for a git repository by name
  # Returns the full path to the repository.
  # 
  # If name is nil return the pro base.
  def self.find_repo(name)
    return Pro.base_dirs.first unless name
    repos = Pro.repo_list
    match = FuzzyMatch.new(repos, :read => :first).find(name)
    match[1] unless match.nil?
  end

  def self.run_command(command, confirm = true)
    if confirm
      print "Do you really want to run '#{command.bold}' on all repos [Y/n]? "
      ans = STDIN.gets
      return if ans.chomp != "Y"
    end
    repos = Pro.repo_list
    repos.each do |r|
      Dir.chdir(r[1])
      result = `#{command}`
      puts "#{r.first}:".bold.red
      puts result
    end
  end

  # prints a status list showing repos with
  # unpushed commits or uncommitted changes
  def self.status
    repos = Pro.repo_list
    max_name = repos.map {|pair| pair.first.length}.max + 1
    repos.each do |pair|
      path = pair.last
      status = Pro.repo_status(path)
      next if status.empty?
      name = format("%-#{max_name}s",pair.first).bold
      puts "#{name} > #{status}"
    end
  end

  # returns a short status message for the repo
  def self.repo_status(path)
    messages = []
    messages << DIRTY_MESSAGE unless Pro.repo_clean?(path)
    messages << UNPUSHED_MESSAGE if Pro.repo_unpushed?(path)
    messages.join(JOIN_STRING)
  end

  # Checks if there are any uncommitted changes
  def self.repo_clean?(path)
    status = ""
    Dir.chdir(path) do
      status = `git status 2>/dev/null`
    end
    return status.end_with?("(working directory clean)\n") || status.end_with?("working directory clean\n")
  end

  # Finds if there are any commits which have not been pushed to origin
  def self.repo_unpushed?(path)
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
