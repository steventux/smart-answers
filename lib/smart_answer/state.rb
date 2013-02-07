require 'ostruct'

module SmartAnswer
  class State < OpenStruct
    #def initialize(start_node)
      #super(current_node: start_node, path: [], responses: [])
    #end

    def initialize(flow)
      start_node = flow.start_node
      super(current_node: start_node, responses: [])
      start_node.run_precalculations(self)
    end

    def evaluate_responses(responses)
      responses.each do |response|
        self.responses << current_node.parse_response(self, response)
        self.current_node.run_calculations(self)
        next_node = self.current_node.evaluate_next_node(self)
        next_node.run_precalculations(self)
        self.path << current_node
        self.current_node = next_node
      end
    rescue ArgumentError, InvalidResponse => e
      self.error = e.message
    end

    def transition_to(new_node, input, &blk)
      dup.tap { |new_state|
        new_state.path << self.current_node
        new_state.current_node = new_node
        new_state.responses << input
        yield new_state if block_given?
        new_state.freeze
      }
    end

    def to_hash
      @table
    end

    def save_input_as(name)
      __send__ "#{name}=", responses.last
    end

    private

    def initialize_copy(orig)
      super
      self.responses = orig.responses.dup
      self.path = orig.path.dup
    end
  end
end
