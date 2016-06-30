require_relative 'domain_crawler'

if ARGV[0]
  root_domain = ARGV[0]
  if root_domain.start_with?("http")
    DomainCrawler.new(root_domain).inspect
  else
    puts "Please enter a valid domain to crawl, starting with 'http://'."
  end
else
  puts "Please enter a domain to crawl."
end