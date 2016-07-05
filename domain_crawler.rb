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
          node = match_node_for_http(node)
          examine_node(node) if node
        end
      rescue
        # Not a traversible URL, invalid for RestClient
      end
      traversible_paths.shift
    end

    if elements.empty?
      puts "Please enter a valid domain to crawl. This one returned no elements to traverse or record."
    else
      output_sitemap(elements.uniq.sort)
    end
  end

  private

  def node_traversible?(node)
    node.start_with?(root_domain) &&
    !traversed_paths.include?(node) &&
    !traversible_paths.include?(node) &&
    !node.end_with?(".php", ".js", ".xml")
  end

  def match_node_for_http(node)
    node.to_s.match(/(https?:\/\/.+?)\"/)
  end

  def examine_node(node)
    node = node[0].gsub("\"", "").strip
    elements << node
    puts "Node: #{node}" if node_traversible?(node)
    # I left this in as a bit of a sanity check for the user, as the crawl can take quite a long time.
    # The intermittent console feedback lets them know something is still happening.
    traversible_paths << node if node_traversible?(node)
  end

  def output_sitemap(sorted_elements)
    output_file = File.open("sitemap.txt", "w")
    sorted_elements.each { |element| output_file.write(element + "\n") }
    output_file.close
  end
end

# DomainCrawler.new("https://figmentums.wordpress.com").inspect
