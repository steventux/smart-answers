status :published
satisfies_need "855"

date_question :baby_due_date? do 
	calculate :due_date do
    Date.parse(responses.last)
  end

  calculate :calculator do
    # Calculators::PlanMaternityLeave.new(due_date: due_date)
    Calculators::BirthCalculator.new(due_date)
  end

	next_node :leave_start?
end

date_question :leave_start? do
	precalculate :earliest_start do
    calculator.earliest_start
  end

  calculate :start_date do
    start_date = Date.parse(start_date)
    raise SmartAnswer::InvalidResponse if (start_date > due_date) or (start_date < 11.weeks.ago(due_date)) 
    calculator.enter_start_date(responses.last)
    start_date
  end

  calculate :due_date_formatted do
    calculator.formatted_day_date due_date
  end
  calculate :start_date_formatted do
  	calculator.formatted_start_date
  end
  calculate :qualifying_week do
    calculator.qualifying_week.last
  end
  calculate :period_of_ordinary_leave do
    calculator.format_date_range calculator.period_of_ordinary_leave
  end
  calculate :period_of_additional_leave do
    calculator.format_date_range calculator.period_of_additional_leave
  end

  next_node :maternity_leave_details
end

outcome :maternity_leave_details