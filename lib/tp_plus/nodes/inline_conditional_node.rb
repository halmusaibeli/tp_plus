module TPPlus
  module Nodes
    class InlineConditionalNode
      def initialize(type, condition, block)
        @type = type
        @condition = condition
        @block = block
      end

      def simple?
        @block.is_a? JumpNode
      end

      def condition(context,options={})
        options[:opposite] ||= @type == "unless"

        @c ||= @condition.eval(context, options)
      end

      def eval(context)
        if simple?
          "IF #{condition(context)},#{@block.eval(context)}"
        else
          "IF #{condition(context,force_parens: true)},#{@block.eval(context,mixed_logic:true)}"
        end
      end
    end
  end
end
