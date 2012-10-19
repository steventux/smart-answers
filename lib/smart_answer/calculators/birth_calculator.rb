module SmartAnswer::Calculators
	class BirthCalculator
		include ActionView::Helpers::DateHelper

		attr_reader :due_date, :formatted_start_date

		def initialize(match_or_due_date)
      @due_date = @match_date = match_or_due_date
    end

		def expected_week
			expected_start = @due_date - @due_date.wday
      expected_start .. expected_start + 6.days
		end

		def qualifying_week
			qualifying_start = 15.weeks.ago(expected_week.first)
      qualifying_start .. qualifying_start + 6.days
		end

		def employment_start
			25.weeks.ago(qualifying_week.last)
		end

		### Planner methods
		## Maternity 

		def enter_start_date(entered_start_date)
			@start_date = Date.parse(entered_start_date)
			@formatted_start_date = formatted_date(@start_date)
		end

		def earliest_start
      11.weeks.ago(expected_week.first)
	  end

		def period_of_ordinary_leave
      @start_date .. @start_date + 26 * 7 - 1
	  end

	  def period_of_additional_leave
	    period_of_ordinary_leave.last .. 26.weeks.since(period_of_ordinary_leave.last)
	  end

		### Date methods

		def formatted_date(dt)
			dt.strftime("%d %B %Y")
		end

		def formatted_due_date
			@due_date.strftime("%A, %d %B %Y")
		end

		def format_date_range(range)
	  	first = formatted_date(range.first)
	  	last = formatted_date(range.last)
	  	(first + " to " + last)
	  end 

	end
end