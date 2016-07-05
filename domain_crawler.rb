require "nokogiri"
require "rest-client"

class DomainCrawler
  attr_accessor :root_domain, :current_path
  attr_reader :traversed_paths, :traversible_paths, :sitemap_elements

  def initialize(root_domain)
    @root_domain = root_domain
    @traversed_paths, @traversible_paths, @sitemap_elements = [], [], []
    @traversible_paths << root_domain
    # Ensure that root_domain is a proper http address?
  end

  def inspect
    while !traversible_paths.empty?
      # Catch errors/exceptions from malformed URLs being sent into RestClient
      begin 
        self.current_path = traversible_paths.first
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

    if sitemap_elements.empty?
      puts "Please enter a valid domain to crawl. This one returned no elements to traverse or record."
    else
      output_sitemap(sitemap_elements.uniq.sort)
    end
  end

  private

  def node_traversible?(node)
    (node.start_with?(root_domain) || node.start_with?(root_domain.gsub("www.", ""))) &&
    !traversed_paths.include?(node) &&
    !traversible_paths.include?(node) &&
    !node.end_with?(".php", ".js", ".xml")
  end

  def match_node_for_http(node)
    node.to_s.match(/(https?:\/\/.+?)\"/)
  end

  def examine_node(node)
    node = node[0].gsub("\"", "").strip
    sitemap_elements << [current_path, node]
    if node_traversible?(node)
      puts "Current Path: #{current_path}\tNode: #{node}"
      traversible_paths << node
    end
  end

  def output_sitemap(sorted_elements)
    output_file = File.open("sitemap.txt", "w")
    sorted_elements.each { |element| output_file.write("Parent: #{element[0]}\tElement: #{element[1]}\n") }
    output_file.close
  end
end
