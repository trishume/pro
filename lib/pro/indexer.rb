require "pro/index"
require "colored"
module Pro
  # creates an index object from cache
  # or by searching the file system
  class Indexer
    CACHE_PATH = File.expand_path("~/.proCache")
    def initialize
      @base_dirs = find_base_dirs
      @low_cpu = false
    end

    def index
      # most of the time the cache should exist
      if res = read_cache
        # index in the background for next time.
        run_index_process
      else
        STDERR.puts "Indexing... This should only happen after updating.".red
        res = build_index
      end
      res
    end
    # unserializes the cache file and returns
    # the index object
    def read_cache
      return nil unless File.readable_real?(CACHE_PATH)
      index = YAML::load_file(CACHE_PATH)
      return nil unless index.created_version == Pro::VERSION
      return nil unless index.base_dirs == @base_dirs
      index
    end

    # spins off a background process to update the cache file
    def run_index_process
      fork {
        @low_cpu = true
        build_index 
      }
    end

    # scan the base directories for git repos
    # and build an index then cache it
    # returns an index
    def build_index
      index = scan_into_index
      cache_index(index)
      index
    end

    # serialize the index to a cache file
    def cache_index(index)
      # TODO: atomic rename. Right now we just hope.
      File.open(CACHE_PATH, 'w' ) do |out|
        YAML::dump( index, out )
      end
    end

    # compile base directories and scan them
    # use this info to create an index object
    # and return it
    def scan_into_index
      repos = scan_bases
      Index.new(repos,@base_dirs)
    end

    # add all git repos in all bases to the index
    def scan_bases
      bases = {}
      @base_dirs.each do |base|
        bases[base] = index_repos(base)
      end
      bases
    end


    # find all repos in a certain base directory
    # returns an array of Repo objects
    def index_repos(base)
      if system("which find > /dev/null")
        index_repos_fast(base)
      else
        index_repos_slow(base)
      end
    end

    def index_repos_fast(base)
      res = `find #{base} -name .git`
      # turn the output into a list of repos
      repos = []
      res.each_line do |line|
        next if line.empty?
        git_path = File.expand_path(line.chomp)
        path = File.dirname(git_path)
        repo_name = File.basename(path)
        repos << Repo.new(repo_name,path)
      end
      repos
    end

    # recursive walk in ruby
    def index_repos_slow(base)
      STDERR.puts "WARNING: pro is indexing slowly, please install the 'find' command."
      repos = []
      Find.find(base) do |path|
        # dir must exist and be a git repo
        if FileTest.directory?(path) && File.exists?(path+"/.git")
          base_name = File.basename(path)
          repos << Repo.new(base_name,path)
          Find.prune
        end
        # slow down
        sleep(1.0/10000.0) if @low_cpu
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