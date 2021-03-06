module Transproc
  # Transformation functions for Classes
  #
  # @example
  #   require 'transproc/class'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:constructor_inject, Struct)
  #
  #   fn['User', :name, :age]
  #   # => Struct::User
  #
  # @api public
  module ClassTransformations
    extend Functions

    # Inject given arguments into the constructor of the class
    #
    # @example
    #   Transproct(:constructor_inject, Struct)['User', :name, :age]
    #   # => Struct::User
    #
    # @param [*Mixed] A list of arguments to inject
    #
    # @return [Object] An instance of the given klass
    #
    # @api public
    def constructor_inject(*args, klass)
      klass.new(*args)
    end

    # Set instance variables from the hash argument (key/value pairs) on the object
    #
    # @example
    #   Transproc(:set_ivars, Object)[name: 'Jane', age: 25]
    #   # => #<Object:0x007f411d06a210 @name="Jane", @age=25>
    #
    # @param [Object]
    #
    # @return [Object]
    #
    # @api public
    def set_ivars(ivar_hash, klass)
      object = klass.allocate
      ivar_hash.each do |ivar_name, ivar_value|
        object.instance_variable_set("@#{ivar_name}", ivar_value)
      end
      object
    end
  end
end
