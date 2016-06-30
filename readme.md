# Crawling a Website, Or: How Hard Could it Be?

## To Run:

Clone the repo down. The program can be run by typing `ruby crawl` followed by the domain to crawl, surrounded by double quotes.

---

The answer to question in the title is evident by the length of this readme. I've a new-found respect for designers who create robust, flexible and efficient web crawling software. Even on a simple-seeming WordPress site, the sheer depth of linkage astounded me.

My first instinct was to use recursion. After all, at first naive blush, one might think that the process could be as follows:
 * Turn entire DOM into a string
 * Parse string element by element, looking for 'http' to be present
 * If present but doesn't contain the root domain, add element to list of static content
 * If it contains the root domain and is a traversible URL, call the current method recursively, sending in the current element as the new element to inspect
 * Make really, absolutely, totally friggin' sure that you're keeping track of which URLs you've already visited. Infinite loops suck, and in this particular context are extremely tricky to debug.

Thus, my first approach. I will acknowledge that I was a bit concerned about the possibility of stack overflow if the recursion got too deep. But, I thought, it would be an interesting experiment, and if it turned out to be the case, I could always switch to an iterative method. It couldn't take that long to implement, right?

...right.

Debugging this turned out to be extremely difficult. You'd find yourself in infinite loops where the conditions to get into the debugger were extremely tricky to describe precisely, so you'd often end up missing them and just looping. And iterating manually through to the point where your logic failed would sometimes require stepping hundreds of times.

I'd originally planned to format the output in a nested fashion, making it clear which elements were children of which. For example:

http://www.fakesite.com
http://www.fakesite.com/posts
    http://www.fakesite.com/posts/1
    http://www.fakesite.com/posts/2
    http://www.fakesite.com/posts/3
        http://www.fakesite.com/posts/3/comments
    http://www.fakesite.com/posts/4
        http://www.fakesite.com/posts/4/comments
    http://www.fakesite.com/posts/5
http://www.fakesite.com/messages
http://www.fakesite.com/contact-us

And so on. However, as the magnitude of the nesting which I was coming across became clear to me, I realized this would be utterly impossible, and so I adjusted my code for a simpler output.

Finally, my code was functional to the point where I was able to start getting the dreaded stack overflow errors. I considered whether using tail-end recursion would both speed things up and prevent overflow errors, but I couldn't easily think of a way to adjust the recursive method signature in a way that would support this. So, to iterative.

The logic was essentially the same, I just needed to keep track of nodes left to inspect and nodes I'd already inspect. But I was still running into some of the same sorts of errors, where the DOM-traversal would take forever and you simply weren't sure whether you'd fallen into a hole in your logic or not.

At this point, my most recent run-through finally completed. Looking at the output, it appears to be consistent with what I'd been expecting.

Tradeoffs/potential inefficiencies I'm aware of:
 * I don't trim duplicate elements until right before writing them to file. However, as this is just an array operation, I doubt it's very problematic.
 * I'm not currently testing URLs for validity before passing them into RestClient, leaving that instead to my begin/rescue block. Surely not best practice, but I was rather pressed for time.
 * It's entirely possible that the large quantity of regex matching I do slows the process down, and that there are other ways to narrow down the selection without checking every single element.
 * Some of my regular expressions aren't perfect, and occasionally bad strings slip into the output, e.g. html tags are still present.
 * It's very possible that Nokogirl::HTML.traverse is inefficient, and that simply parsing a DOM string piece by piece would be better. I settled on that method before realizing how challenging this project would be, and the thought of attempting to adjust my code to try other methods by this point makes my eye twitch.

--

Despite all of this, I found this highly enjoyable and challenging. My class had, within the first week, begun building web scrapers using RestClient and Nokogiri, so this was hardly alien territory for me. However, the difficulties which cropped up during the process were very satisfying to overcome.
