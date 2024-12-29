# Embedded HTML Galley plugin for OJS

This OJS Embedded HTML Galley plugin version specifically modified for WJDS is based on a fork from [Embedded HTML Galley](https://github.com/ohilbig01/embeddedHtmlGalley) wich is a fork of the [Inline HTML Galley plugin](https://github.com/ulsdevteam/inlineHtmlGalley).

This plugin presents the HTML Article inside the normal article page within the website's theme specifically modified for WJDS. It is not meant to be used in other contexts.

## Added features for WJDS:

### Version 1.1.0.0 (29.12.204):
- integration with OJS Usage Stats added

### Prior modifications for WJDS: 
- templates/button.tpl, the button text is now "Read in browser"
- templates/displayInline.tpl the text of the object "item backlink" was changed to "Back to summary"
- In order to only show the PDF galley of an article in the sidebar of an article, {if $galley->isPdfGalley()} was inserted in the foreach … $primaryGalleys statement
- "Updated on..." and version count removed

## Added features for the Inline HTML Galley plugin:

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

## Installation

* install as a "generic" plugin
* disable (not delete) the PKP htmlArticleGalley plugin
* enable this plugin


