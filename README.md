# Embedded HTML Galley plugin for OJS

This is an unofficial OJS plugin forked from the [Inline HTML Galley plugin](https://github.com/ulsdevteam/inlineHtmlGalley).

This plugin presents the HTML Article inside the normal article page within the website's theme. 

Some things were added:

* 'Read full version' button on the article page
* display of the full theme and the article details
* the html view page has a link back to the article page
* the plugin extracts the style from the `head` of the galley (if present) and uses it to display the page.
* there is also a file '/style/htmlGalley.css' which can be used to style tables etc. 
* on the article details page, the title and subtitle of the ojs metadata are displayed, and not those of the galley file



## Requirements

* OJS 3.x
  * The PKP plugin htmlArticleGalley (which ships by default with OJS)
* PHP modules
  * [libxml](https://www.php.net/manual/en/book.libxml.php)
  * [dom](https://www.php.net/manual/en/book.dom.php)

## Configuration

Please install as a "generic" plugin.  


