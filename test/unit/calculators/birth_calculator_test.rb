require_relative "../../test_helper"

module SmartAnswer::Calculators
  class BirthCalculatorTest < ActiveSupport::TestCase
  	context BirthCalculator do 
  		context "basic tests" do
				# Birth 22/12/12
				# QW 02/09/12 - 08/09/12
				# Employ start 17/03/12 
	  		context "birth 2012 Dec 22" do
		  		setup do
			    	@due_date = Date.parse("2012 Dec 22")
			      @calculator = BirthCalculator.new(@due_date)
			    	@calculator.enter_start_date("2012-11-25")
			    end
		  		should "return basic calcs" do
		  			assert_equal @due_date, @calculator.due_date
		  			assert_equal Date.parse("16 Dec 2012")..Date.parse("22 Dec 2012"), @calculator.expected_week
		  		end
			    should "qualifying week" do
			    	assert_equal Date.parse("02 Sep 2012")..Date.parse("08 Sep 2012"), @calculator.qualifying_week
			    end
			    should "employment start" do
			    	assert_equal Date.parse("17 Mar 2012"), @calculator.employment_start
			    end
				  
				  context "Date methods tests" do
				  	should "formatted dates" do
				  		assert_equal "Saturday, 22 December 2012", @calculator.formatted_due_date
				    	assert_equal "25 November 2012", @calculator.formatted_start_date
				    end
				  end

				  context "Planner tests" do
				  	should "qualifying_week give last date of 1 September 2012" do
				      assert_equal Date.parse("08 September 2012"), @calculator.qualifying_week.last
				    end

			    	should "earliest_start" do
				      assert_equal Date.parse("30 September 2012"), @calculator.earliest_start
				    end

			    	should "period_of_ordinary_leave" do
				      assert_equal "25 November 2012 to 25 May 2013", @calculator.format_date_range(@calculator.period_of_ordinary_leave)
				    end

			    	should "period_of_additional_leave" do
				      assert_equal "25 May 2013 to 23 November 2013", @calculator.format_date_range(@calculator.period_of_additional_leave)
				    end
				  end
			  end


	  	end
  	end 
  end
end