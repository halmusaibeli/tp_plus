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
      "UI" => "io_uopin",
      "SO" => "io_sopout",
      "SI" => "io_sopin",
      "GO" => "io_gpout",
      "GI" => "io_gpin",
      "RO" => "io_rdo",
      "RI" => "io_rdi",
    }

    MAX_PROGRAM_SIZE = 300

    T_Register = Struct.new(:name, :type, :id)

    class Environment
      include ERB::Util
      attr_reader :variables

      TEMPLATE_FILE = File.join(File.dirname(__FILE__),"templates/karelenv.erb")
      ROSSUM_FILE = File.join(File.dirname(__FILE__),"templates/rossumenv.erb")

      def initialize(hashfilename = 'tppenv', rossumfilename = 'env', hashtable = 'tbl')
        @variables = []
        @constants = []
        @nodes = []
        @hashbasename = hashfilename
        @rossumfilename = rossumfilename
        @hashprog = hashfilename
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

      def gather_constants(interpreter)
        @constants = []
        TPPlus::Util.gather_constants(interpreter, @constants)
        nil
      end

      def build_list
        @nodes.each do |val|
          type = val.class
          case
            when val.is_a?(TPPlus::Nodes::IONode)
              @variables << T_Register.new(val.comment[0, 16], CONVERT_TYPE[val.type], val.id)
            when val.is_a?(TPPlus::Nodes::NumregNode)
              @variables << T_Register.new(val.comment[0, 16], CONVERT_TYPE["R"], val.id)
            when val.is_a?(TPPlus::Nodes::PosregNode)
              @variables << T_Register.new(val.comment[0, 16], CONVERT_TYPE["PR"], val.id)
            when val.is_a?(TPPlus::Nodes::StringRegisterNode)
              @variables << T_Register.new(val.comment[0, 16], CONVERT_TYPE["SR"], val.id)
            else
              next
          end
        end
      end

      def makefile
        erb = ERB.new(File.read(TEMPLATE_FILE), trim_mode: '-')
        
        @variables.each_slice(MAX_PROGRAM_SIZE).with_index do |subarray, index|
          @sArray = subarray
          @index  = index + 1
          @hashfilename = "#{@hashbasename}#{@index}"
          File.open("#{@hashfilename}.kl", 'w') do |f|
            f.write erb.result(binding)
          end
        end
      end

      def makeconfig
        erb = ERB.new(File.read(ROSSUM_FILE), trim_mode: '-')
        File.open(@rossumfilename + '.klt', 'w') do |f|
          f.write erb.result(binding)
        end
      end
    
    end

  end
end