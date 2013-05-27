module Pro
  Repo = Struct.new(:name,:path)
  class Index
    include Enumerable
    attr_reader :bases,:base_dirs
    def initialize
      @base_dirs = find_base_dirs
      @bases = scan_bases
    end
    # yields all repo objects in all bases
    def each
      bases.each do |key,val|
        val.each {|r| yield r}
      end
    end
    private
    # add all git repos in all bases to the index
    def scan_bases
      bases = {}
      base_dirs.each do |base|
        bases[base] = index_repos(base)
      end
      bases
    end
    # find all repos in a certain base directory
    # returns an array of Repo objects
    def index_repos(base)
      repos = []
      Find.find(base) do |path|
        # dir must exist and be a git repo
        if FileTest.directory?(path) && File.exists?(path+"/.git")
          base_name = File.basename(path)
          repos << Repo.new(base_name,path)
          Find.prune
        end
      end
      repos
    end
    # Finds the base directory where repos are kept
    # Checks the environment variable PRO_BASE and the
    # file .proBase
    def find_base_dirs()
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
      # I know about select! but it doesn't exist in 1.8
      bases = bases.select {|b| File.exists?(b)}
      # if no bases then return home
      bases << ENV['HOME'] if bases.empty?
      bases
    end
  end
end