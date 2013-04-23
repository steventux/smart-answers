require "uri"
require "net/http"

def check_links(links_to_check, broken, file)
  links_to_check.uniq.each { |link|
    begin
      uri = URI.parse(link)
      http = Net::HTTP.new(uri.host, uri.port)

      if link.include?("https")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.get(uri.request_uri)

      puts "Checking link: #{link}"
      unless response.class == Net::HTTPOK
        new_hash = { :link => link, :resp => response.code, :file => file }
        if response.code[0] == "3"
          new_hash[:redirect] = response.header['location']
        end
        broken.push(new_hash)
      end
    rescue Exception => e
      # this is here as sometimes we find wrong links through the Regexes
    end
  }
  broken
end

namespace :links do
  desc 'Checks all URLs within Smart Answers for errors.'
  task :check do
    pwd = Dir.pwd
    base_path = File.expand_path("#{pwd}/lib")
    broken = []
    checked = []

    Dir.glob("#{base_path}/flows/locales/**/*.yml") { |file|
      puts "Checking #{file}"
      contents = IO.read(file)
      links_to_check = []
      contents.gsub(/\[(.+)\]\((.+) "(.+)"\)/) { |match|
        text = $1
        link = $2
        unless link.include?("http")
          link = "https://www.gov.uk#{link}"
        end

        links_to_check << link
        checked << link
      }

      broken = check_links(links_to_check, broken, file)
    }

    Dir.glob("#{base_path}/data/*.yml") { |file|
      puts "Checking #{file}"
      contents = IO.read(file)
      links_to_check = []
      contents.gsub(/: (\/.+)$/) {
        link = $1
        unless link.include?("http")
          link = "https://www.gov.uk#{link}"
        end
        checked << link
      }

      broken = check_links(links_to_check, broken, file)
      puts "Finished checking #{file}"
    }

    File.open("log/broken_links.log", "w") { |file|
      file.puts broken
    }

    four_oh_fours = broken.select { |item| item[:resp] == "404" }

    File.open("log/404_links.log", "w") { |file|
      file.puts four_oh_fours
    }

    if four_oh_fours.length > 0
      puts "Warning: Found 404s. Look in log/404_links.log"
    end

  end
end
