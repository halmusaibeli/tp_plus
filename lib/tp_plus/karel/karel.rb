require "erb"
require_relative "../utility_functions.rb"

module TPPlus
  module Karel

    CONVERT_TYPE = {"R" => "DATA_REG", 
      "PR" => "DATA_POSREG",
      "SR" => "DATA_STRING", 
      "F" => "io_flag",
      "DO" => "io_dout",
      "DI" => "io_din",
      "AO" => "io_anout",
      "AI" => "io_anin",
      "UO" => "io_uopout",
      "UI" => "io_uopin"
    }

    T_Register = Struct.new(:name, :type, :id)

    class Environment
      include ERB::Util
      attr_reader :variables

      TEMPLATE_FILE = File.join(File.dirname(__FILE__),"templates/karelenv.erb")

      def initialize(filename = 'tppenv', hashprog = 'env', hashtable = 'tbl')
        @variables = []
        @nodes = []
        @filename = filename
        @hashprog = filename
        @hashtable = hashtable
        @clear_registers = false
      end

      def set_clear_registers(clear)
        @clear_registers = clear
      end

      def gather_variables(interpreter)
        @nodes = []
        TPPlus::Util.gather_variables(interpreter, @nodes)
        nil
      end

      def build_list
        @nodes.each do |val|
          type = val.class
          case
            when val.is_a?(TPPlus::Nodes::IONode)
              @variables << T_Register.new(val.comment, CONVERT_TYPE[val.type], val.id)
            when val.is_a?(TPPlus::Nodes::NumregNode)
              @variables << T_Register.new(val.comment, CONVERT_TYPE["R"], val.id)
            when val.is_a?(TPPlus::Nodes::PosregNode)
              @variables << T_Register.new(val.comment, CONVERT_TYPE["PR"], val.id)
            when val.is_a?(TPPlus::Nodes::StringRegisterNode)
              @variables << T_Register.new(val.comment, CONVERT_TYPE["SR"], val.id)
            else
              next
          end
        end

        def makefile
          erb = ERB.new(File.read(TEMPLATE_FILE), trim_mode: '-')
          File.open(@filename + '.kl', 'w') do |f|
            f.write erb.result(binding)
          end
        end
      end
    end

  end
end