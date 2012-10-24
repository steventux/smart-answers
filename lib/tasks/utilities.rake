namespace :utility do
  desc "List questions for flow. Expects the flow file location."
  task :flow_questions, [:flow_file] => :environment do |t, args|
  	qs = open(args[:flow_file]) { |f| f.grep(/\A\w+_\w+ :/)}
  	qs.each do |q|
  		title = q[/:.*\?/]
  		qtype = $1 if q[/\A(.*) :/]
  		puts "#{title} [#{qtype}]"
  	end
  end
end