require 'open-uri'
require 'nokogiri'
require 'pry'

# To run the code, run this ruby file and input the url you would like to scrape

=begin
The WebScraper Class is the main part of the program, it will be initialized with a link and from that point will then crawl through the rest of the website
One of the main tradeoffs of this page is that its thoroughness leads is rather slow, it evaluates every possible link on every page and then compares to one array. 
There are probably faster ways of determining whether a link needs to be examined
There are also tradeoffs to doing things recursively, recursion may be easier to read but it is generally slower then itteration. The fact that ruby is also single threaded and always adds to the stack in recursison exacerbates these problems.
There are several reasons I am considering for why the app is not working, one would be an infinite loop in the recursion. Another would be that I am trying to scrape pages that can not be scraped. I encountered this problem when the links were PDF's but I might have accounted for it
I think many of these problems could be addressed with implementing rescue and further debugging, but I have hit the time limit.
=end

class WebScraper
	attr_reader :host, :websites_processed_urls,:websites_pages
	def initialize(url)
		@host = URI(url).host
		# @websites_processed_urls will hold all URL strings that have been stored, and will be used in determining whether something has been added
		@websites_processed_urls = []
		# @websites_pages holds invidual link objects, which contain that pages internal links, external links, and image linkss
		@websites_pages = []
		doc = Nokogiri::HTML(open(url))
		# recursive crawl scrapes the website, and once that has been completed, output formats the sitemap
		recursivecrawl(doc)
		output
	end


	def recursivecrawl(doc)
		# find all the links
		alllinks = doc.css('a').map { |link| link['href'] }.compact
		alllinks.each do |link|
			# do nothing if the link is external or if the link has already been processed, or the link cannot be processed due to being an incorrect file type
			if @websites_processed_urls.include?(link) || !link.start_with?('http://' + host) ||  link.split("/").last.include?('.')
			# otherwise, create a new link object, submit it into websites_pages, and recursively scrape that new page
			else
				clean_url = URI.parse(link) 
				doc = Nokogiri::HTML(open(clean_url))
				@websites_pages << Link.new(link,doc,@host)
				@websites_processed_urls << link
				puts "#{link} has been added"
				recursivecrawl(doc) 
			end
		end
	end


	def output
		puts "Websites Scraped:  #{self.websites_pages.count}"
		puts "The following pages were visited" 
		puts self.websites_processed_urls
		self.websites_pages.each_with_index do |page,index|
			puts "#{index}. #{page.url}"
			puts "	External Links:"
			page.external_links.each_with_index do |link,index|
				puts "	#{index}. #{link}"
			end
			puts "	Internal Links:"
			page.internal_links.each_with_index do |link,index|
				puts "	#{index}. #{link}"
			end
			puts "	Images:"
			page.images.each_with_index do |link,index|
				puts "	#{index}. #{link}"
			end
		end

end
end

# Links will be stored as objects, this will ultimately assist in having a more manageable output, as each pages links can be accessed as attributes
# One of the tradeoffs with creating link objects is that the overall scraping process is more cumbersome, creating objects as opposed to storing strings will be slower and occupy more space
class Link 
	attr_reader :images,:external_links,:internal_links,:host,:url
	
	def initialize(url,doc,domain)
		@domain = domain
		@url = url
		@external_links = []
		@internal_links = []
		 @images = doc.css('img').map{ |image| image['src'] }
		categorize_links(doc)
	end

	def categorize_links(doc)
		alllinks = doc.css('a').map { |link| link['href'] }.compact
		alllinks.each do |link|
			 # assess whether link is internal
			if link.include?(@domain)
			  @internal_links << link
			# otherwise link is external
			else
			  @external_links << link
			end
		end
	end
end

puts "What website would you like to crawl, including the protocol(HTTP or HTTPS)?"
url = gets.chomp
WebScraper.new(url)




















# These are earlier notes, my pseudocode for what needed to be done and my early thought process. 
# class page
#  has many links, has many external links, has many images
# end


# class webscraper(starting_page)
# 	def initialize
# 		@first_link = starting_page
# 		@domain = starting_page.split('/')[0]
# 		@final_links = []
# 		@links_queue = []
# 		@links_queue  << @first_link
# 		scrapethispage(@first_link)
# 	end


# def scrapethispage(link)
# 	if final_links include link
# 		break
# 	end
# 	if links_queue = []
# 		return sitemap (self)
# 	end
# 	go to page
# 	scrape all the links from that page, add to links queue
# 	 links queue each do look at the links and evaluate whether they are from the same domain
# 	 if they arent ignore
# 	 if they are add to final links if not already included and scrapethispage(self)
# end


# def sitemap
# 	make a pretty sitemap
# 	self.final_links each do
# 		prints pretty
# 	end
# end

	# end

# 	def getalllinks(url)
# doc = Nokogiri::HTML(open(url))
# doc.css('a').map { |link| link['href'] }
# end


# def gethost(url)
# 	URI(url).host
# end

# def getallimages(url)
# doc = Nokogiri::HTML(open(url))
# doc.css('img').map{ |image| image['src'] }
# end

