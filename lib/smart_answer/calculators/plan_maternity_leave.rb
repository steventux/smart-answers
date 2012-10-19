module SmartAnswer::Calculators
	class PlanMaternityLeave < BirthCalculator
		include ActionView::Helpers::DateHelper

		# attr_reader :formatted_start_date #:formatted_due_date, 

		def initialize(options = {})
			@due_date = Date.parse(options[:due_date])
		end

	end
end