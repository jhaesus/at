module At
 class Settings
   cattr_accessor :instance

   class << self
     delegate :inspect, to: :instance, allow_nil: true

     def method_missing name, *args, &block
       instance.respond_to?(name) ? instance.send(name, *args, &block) : super
     end
   end

   CAST = lambda do |value|
     (Hash === value ? Settings.new(value) : value).freeze
   end

   def initialize data
     @data = Hash[data].freeze

     @data.each do |k,v|
       define_singleton_method k do
         self[k.to_s]
       end
     end
   end

   def [] name
     CAST[@data[name.to_s]]
   end

   def inspect
     @data.inspect
   end

   def to_h
     @data.with_indifferent_access
   end
 end
end
