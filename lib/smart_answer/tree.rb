class SmartAnswer::Tree
  # be rails r 'pp SmartAnswer::Tree.new().analyse("report-a-lost-or-stolen-passport")'
  def analyse(question_name)
    reg =  SmartAnswer::FlowRegistry.instance
    q = reg.find(question_name)
    {
      id: question_name,
      nodes: q.nodes.map do |node|
        {
          name: node.name,
          class: node.class.name.demodulize,
          question: node.question?,
          targets: node.question? ? node.targets : nil
        }
      end
    }

    # q.nodes[0].next_node(:yes)
  end
end
