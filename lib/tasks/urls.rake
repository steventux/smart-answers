namespace :urls do
	desc "List external links in YAML files. Goes through the YAML files in lib/flows/locales/en/ 
		and retrieves an array of internal and external links and text. These are then outputted to two files
		in lib/data: internal_links.csv and external_links.csv"
	task :ext_link_check_yaml do
		pwd = './lib/flows/locales/en/'
		internal_links = [
			%w[file url page_text tip_text].join(',')
		]
		external_links = [
			%w[file url page_text tip_text].join(',')
		]
		Dir.foreach(pwd) do |f|
			next unless f.match(/.*\.yml$/)
			IO.readlines(pwd + f).each do |l| 
				if l =~ /\[(.*)\]\((.*)\)/
					link_text = ''
					url = $2
					if url =~ / "/
						link_text = $1 if url.match(/"(.*)"/)
						url = $1 if url.match(/^(.*) "/)
					end
					
					line = "#{f},#{url},#{$1},#{link_text}"
					if (url =~ /^http/)
						external_links << line
					else
						internal_links << line
					end
				end
			end
		end
		File.open("./lib/data/internal_links.csv", "w") { |f| f.write(internal_links.join("\n")) }
		File.open("./lib/data/external_links.csv", "w") { |f| f.write(external_links.join("\n")) }
		puts "external links: #{external_links.count}"
		puts "internal links: #{internal_links.count}"
	end

	desc "Updates internal links in YAML files. Expects a CSV file to be provided with a list of URL pairs: old/new.
		Goes through the YAML files in lib/flows/locales/en/ and compares URLs, replacing old (if found) with
		new. Creates .bak files of the YAML files that it updates - so you'll want to remove these before committing."
	task :update_links, [:link_csv] => :environment do |t, args|
		# get links
		url_list = {}
		IO.readlines(args[:link_csv]).each do |urlstr| 
			urlized = "/" + urlstr.split(',')[0]
			url_list[urlized] = urlstr.split(',')[1].chomp
		end

		# get YAML
		pwd = './lib/flows/locales/en/'
		internal_links = []
		external_links = []
		Dir.foreach(pwd) do |f|
			next unless f.match(/.*\.yml$/)
			fn = pwd + f
			fn_new = fn + ".new"
			chg = 0
			f_input = File.open(fn, "r")	
			f_output = File.open(fn_new, "w")
			f_input.each do |line| 
				if line =~ /\[(.*)\]\((.*)\)/ 
					url = $2.split(" ")[0]
					unless url.match(/\Ahttp/)
						if url_list.has_key?(url) 
							lz = url_list[url]
							line.gsub!(/#{url}/, "/"+ lz)
							puts "found [#{url}] in #{f} and replaced with [#{lz}]" 
							chg += 1
						end
					end
				end
				f_output.print line
			end
			f_output.close
			f_input.close
			if chg < 1
				File.delete(fn_new) 
			else
				# back up original YAML file 
				File.rename(fn, fn+".bak")
				# write new YAML file to operational name
				File.rename(fn_new, fn)
			end
		end
	end

	desc "Get test urls from spec files"
	task :gen_test_urls, [:spec_file] => :environment do |t, args|
		# process add response
		test_responses = []
		lowest_tab = 100
		last_tab = 0

		urls = []
		ar = open(args[:spec_file]) {|f| f.grep(/add_response/)} 
		ar.each do |a|	
			# puts a

			response_str = $1 if a[/add_response ([\S]*)/]
			response_str.gsub!(/["']?/,'')


			tab_size = a[/\A */].size
			
			# determine lowest tab num
			if lowest_tab > tab_size
				lowest_tab = tab_size
				curr_url = "/" + response_str
			elsif last_tab > tab_size
				curr_url = "/" + response_str
			else
				curr_url = urls.last + "/" + response_str
			end
			last_tab = tab_size

			urls << curr_url
			puts curr_url

			# put in array of arrays
			# test_responses << [response_str, tab_size]
		end
		# puts lowest_tab
		# puts test_responses.inspect

		# append to last lower
	end
end