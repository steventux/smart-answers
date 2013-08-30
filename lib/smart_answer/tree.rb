class SmartAnswer::Tree
  def analyse(question_name)
    reg =  SmartAnswer::FlowRegistry.instance
    q = reg.find(question_name)
    q.nodes[0].next_node(:yes)
  end
end
