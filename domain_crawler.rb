require "nokogiri"
require "rest-client"

class DomainCrawler
  attr_accessor :root_domain
  attr_reader :traversed_paths, :traversible_paths, :elements

  def initialize(root_domain)
    @root_domain = root_domain
    @traversed_paths, @traversible_paths, @elements = [], [], []
    @traversible_paths << root_domain
    # Ensure that root_domain is a proper http address?
  end

  def inspect
    while !traversible_paths.empty?
      # Catch errors/exceptions from malformed URLs being sent into RestClient
      begin 
        current_path = traversible_paths.first
        traversed_paths << current_path
        site_html = RestClient.get(current_path)
        Nokogiri::HTML(site_html).traverse do |node|
          node = node.to_s.match(/(https?:\/\/.+?)\"/)
          if node  
            node = node[0].gsub("\"", "").strip
            elements << node
            puts "Traversing node: #{node}" if node_traversible?(node)
            # I left this in as a bit of a sanity check for the user, as the crawl can take quite a long time.
            # The intermittent console feedback lets them know something is still happening.
            traversible_paths << node if node_traversible?(node)
          end
        end
      rescue
        # Not a traversible URL
      end
      traversible_paths.shift
    end

    if elements.empty?
      puts "Please enter a valid domain to crawl. This one returned no elements to traverse or record."
    else
      elements.uniq!.sort!
      output_file = File.open("sitemap.txt", "w")
      elements.each { |element| output_file.write(element + "\n") }
      output_file.close
    end
  end

  private

  def node_traversible?(node)
    node.start_with?(root_domain) &&
    !traversed_paths.include?(node) &&
    !traversible_paths.include?(node) &&
    !node.end_with?(".php", ".js", ".xml")
  end

end

# DomainCrawler.new("https://figmentums.wordpress.com").inspect
