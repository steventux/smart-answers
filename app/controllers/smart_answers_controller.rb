class SmartAnswersController < ApplicationController
  before_filter :reject_invalid_utf8
  before_filter :find_smart_answer
  before_filter :redirect_response_to_canonical_url, only: %w{show}

  rescue_from SmartAnswer::FlowRegistry::NotFound, with: :error_404
  rescue_from SmartAnswer::InvalidNode, with: :error_404

  def show
    set_slimmer_artefact(@presenter.artefact)
    respond_to do |format|
      format.html { render }
      format.json {
        html_fragment = with_format('html') {
          render_to_string(partial: "content")
        }
        render :json => {
          url: smart_answer_path(params[:id], 'y', @presenter.current_state.responses),
          html_fragment: html_fragment,
          title: @presenter.current_node.title
        }
      }
      format.ics {
        if @presenter.current_node.respond_to?(:calendar) and @presenter.current_node.has_calendar?
          response.headers['Content-Disposition'] = "attachment; filename=\"#{@name.to_s}.ics\""
          render :text => @presenter.current_node.calendar.to_ics, :layout => false
        else
          error_404
        end
      }
    end

    set_expiry
  end

private
  def json_request?
    request.format == Mime::JSON
  end

  def with_format(format, &block)
    old_formats = self.formats
    self.formats = [format]
    result = yield
    self.formats = old_formats
    result
  end

  def find_smart_answer
    @name = params[:id].to_sym
    smart_answer = flow_registry.find(@name.to_s)
    @presenter = SmartAnswerPresenter.new(request, smart_answer)
  end

  def flow_registry
    @flow_registry = SmartAnswer::FlowRegistry.instance
  end

  def redirect_response_to_canonical_url
    if params[:next] && ! @presenter.current_state.error
      set_expiry
      redirect_to action: :show,
        id: @name,
        started: 'y',
        skip_slimmer: 1,
        responses: @presenter.current_state.responses,
        protocol: (request.ssl? || Rails.env.production?) ? 'https' : 'http'
    end
  end

  def reject_invalid_utf8
    error_404 unless params[:responses].nil? or params[:responses].valid_encoding?
  end
end
