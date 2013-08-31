class SmartAnswer::Tree
  def analyse(question_name)
    reg =  SmartAnswer::FlowRegistry.instance
    q = reg.find(question_name)
    yeah = {
      id: question_name,
      raw: q.inspect,
      nodes: q.nodes
    }

    # q.nodes[0].next_node(:yes)
  end
end
