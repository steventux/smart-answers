class SmartAnswerController < ApplicationController
  before_filter :load_flow

  def landing
  end

  def in_flow
    @state = @flow.evaluate_responses params[:responses]
  end

  private

  def load_flow
    @flow = SmartAnswer::FlowRegistry.instance.find(params[:slug])
  end
end
