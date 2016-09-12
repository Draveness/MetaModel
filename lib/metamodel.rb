require 'active_support/core_ext/string/strip'

module MetaModel

  class PlainInformative < StandardError; end

  # Indicates an user error. This is defined in cocoapods-core.
  #
  class Informative < PlainInformative
    def message
      "[!] #{super}".red
    end
  end

  require 'pathname'
  require 'active_support/inflector'

  require 'metamodel/version'
  require 'metamodel/config'
  require 'metamodel/erbal_template'

  # Loaded immediately after dependencies to ensure proper override of their
  # UI methods.
  #
  require 'metamodel/user_interface'

  autoload :Command,   'metamodel/command'
  autoload :Parser,    'metamodel/parser'
end
