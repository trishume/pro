module Pro
  Repo = Struct.new(:name,:path)
  class Index
    include Enumerable
    attr_reader :bases,:base_dirs,:created_version
    def initialize(bases,base_dirs)
      @bases, @base_dirs = bases, base_dirs
      @created_version = Pro::VERSION
    end
    # yields all repo objects in all bases
    def each
      bases.each do |key,val|
        val.each {|r| yield r}
      end
    end
  end
end