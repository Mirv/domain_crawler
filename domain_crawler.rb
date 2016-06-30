require "nokogiri"
require "rest-client"
require "pry"

class DomainCrawler
  attr_accessor :root_domain
  attr_reader :traversed_paths, :elements

  def initialize(root_domain)
    @root_domain = root_domain
    @traversed_paths = []
    @elements = []
    # Ensure that root_domain is a proper http address
  end

  def inspect(current_path = nil, depth = 0)
    current_path ||= root_domain
    traversed_paths << current_path

    begin
      html = RestClient.get(current_path)

      Nokogiri::HTML(html).traverse do |node|
        node = node.to_s.match(/(https?:\/\/.+?)\"/)
        if node  
          node = node_to_string(node, depth)
          elements << node unless elements.last == node  # Gives better result then just doing .uniq, as you want children to be able to display copies of the same link
          # binding.pry if node.include?(root_domain)
          puts "Node: #{node} with depth #{depth}" if node_traversible?(node.strip)
          inspect(node.strip, depth + 1) if node_traversible?(node.strip)
        end
      end
    rescue
      # Not a traversible URL
    end

    unless depth != 0
      output_file = File.open("sitemap.txt", "w")
      elements.each { |element| output_file.write(element) }
      output_file.close
    end
  end

  private

  def node_to_string(node, depth)
    output_element = node[0].gsub("\"", "") # Regex is still catching the trailing "
    # depth.times { output_element = "\t\t" + output_element }
    output_element + "\n"
  end

  def node_traversible?(node)
    node.include?(root_domain) && !traversed_paths.include?(node) && !node.end_with?(".php", ".js", ".xml")
  end

end

DomainCrawler.new("https://figmentums.wordpress.com").inspect
# DomainCrawler.new("http://wiprodigital.com/").inspect

        # file.write("First method: #{node.to_s.match(/(http.+\.[a-zA-Z0-9]{1,4})/)[1]}\n")
        # file.write("Second method: #{node.to_s.match(/(http.+\w{1,4})/)[1]}\n\n")
        # file.write("#{node.to_s.match(/(http.+?)\"/)[1]}\n\n")

      # Element -> node.attributes["href"].value
      # Comment -> node.to_s.match(/(http.+\.[a-zA-Z0-9]{1,4})/)[1]  # Not the best regex, admittedly
      # Comment -> node.to_s.match(/(http.+\w{1,4})/)[1]  # Not the best regex, admittedly