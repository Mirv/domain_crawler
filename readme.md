# Crawling a Website, Or: How Hard Could it Be?

## To Run:

Clone the repo down. The program can be run by typing `ruby crawl` followed by the domain to crawl, surrounded by double quotes.

---

The email describing this exercise came through while I was on the subway heading home. I spent the rest of the ride thinking it through, taking notes on my phone, and by the time I arrived, felt like I had a pretty good grasp on how to proceed.

Alas, the answer to the question in the title is evident by the length of this readme. I've a new-found respect for designers who create robust, flexible and efficient web crawling software. Even on a simple-seeming WordPress site, the sheer depth of linkage astounded me.

My first instinct was to use recursion. After all, at first naive blush, one might think that the process could be as follows:
 * Turn the entire DOM into a string
 * Parse this string element by element, looking for 'http' to be present in each element's stringified description
 * If 'http' is present but the url doesn't contain the root domain, add this element to the list of static content in the sitemap
 * If it contains the root domain _and_ is a traversible URL, call the inspect method recursively, sending in the current element as the new element to inspect
 * Make really, absolutely, **totally** friggin' sure that you're keeping track of which URLs you've already visited. Infinite loops really aren't fun, and in this particular context are extremely tricky to debug.

Thus, my first approach. I will acknowledge that I was a bit concerned about the possibility of stack overflow if the recursion got too deep. But, I thought, it would be an interesting experiment, and if it turned out to be the case, I could always switch to an iterative method. It couldn't take that long to implement, right?

...right.

Debugging this turned out to be extremely challenging. You'd find yourself in infinite loops where, in order to get into the debugger at the right point to inspect the current structures, you'd need to describe exceedingly narrow conditions. As a result, you'd often end up missing them and just looping. And iterating manually through to the point where your logic failed would sometimes require stepping hundreds of times.

I'd originally planned to format the output in a nested fashion, making it clear which elements were present as children of other elements. Something like:


    http://www.fakesite.com
    http://www.fakesite.com/logo.jpg
    http://www.fakesite.com/posts
        http://www.fakesite.com/logo.jpg
        http://www.fakesite.com/posts/1
        http://www.fakesite.com/posts/2
        http://www.fakesite.com/posts/3
            http://www.fakesite.com/logo.jpg
            http://www.fakesite.com/adorable_cat_picture.jpg
            http://www.fakesite.com/posts/3/comments
        http://www.fakesite.com/posts/4
            http://www.fakesite.com/posts/4/comments
            http://www.fakesite.com/bizarre_monkey_picture.gif
        http://www.fakesite.com/posts/5
    http://www.fakesite.com/messages
    http://www.fakesite.com/contact-us


And so on. However, as the magnitude of the nesting which I was coming across became clear to me (I was hitting nests 350 deep before achieving stack overflow), I realized this would be almost impossible to display visually, and so I adjusted my code for a simpler output.

Finally, my code was functional to the point where I was able to start getting the dreaded stack overflow errors. I considered whether using tail-end recursion would both speed things up and prevent overflow, but I couldn't easily think of a way to adjust the recursive method signature in a way that would support this. So, to iteration I retreated, tail between my legs.

The logic was essentially the same, I just needed to keep track of nodes left to inspect and nodes I'd already inspect. But I was still running into some of the same sorts of errors, where the DOM-traversal would take forever and you simply weren't sure whether you'd fallen into a hole in your logic or not.

Finally, I was able to get my run-throughs to complete. Looking at the output, it appeared to be consistent with what I'd been expecting.

## Tradeoffs/potential inefficiencies I'm aware of:
 * I don't remove duplicate elements from the array until right before writing them to file. However, I doubt it ever approaches anywhere near the size where it would be considered a memory leak.
 * I'm not currently testing URLs for validity before passing them into RestClient, leaving that instead to my begin/rescue block. Definitely not best practice.
 * It's possible that the large amount of regex matching I do slows the process down, and that there are other ways to narrow down the selection without matching against the `to_s` of every element.
 * My regular expression matching isn't perfect, and in a very small number of edge cases, bad strings slip into the output (e.g. html tags are still present.)
 * It's very possible that Nokogirl::HTML.traverse is inefficient, and that simply parsing a DOM string element by element manually would be faster. I settled on that method before realizing how challenging this project would be, and the thought of attempting to adjust my code to try other methods at this point makes my eyelid twitch.

---

Despite all of this, I found this highly enjoyable and challenging. My class had, within the first week, begun building web scrapers using RestClient and Nokogiri, so this was hardly alien territory for me. However, the difficulties which cropped up during the process were very satisfying to overcome.

Thanks folks!
