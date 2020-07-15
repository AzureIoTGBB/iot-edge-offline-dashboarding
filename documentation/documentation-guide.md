# Documentation guidelines

This document outlines the documentation guidelines and standards. It provides an introduction to technical aspects of documentation writing and generation, to highlight common pitfalls, and to describe the recommended writing style.

The page itself is supposed to serve as an example, therefore it uses the intended style and the most common markup features of the documentation.

* [Source](#source-documentation)
* [How-to](#how-to-documentation)

---

## Functionality and markup

This section describes frequently needed features. To see how they work, look at the source code of the page.

1. Numbered lists
   1. Nested numbered lists with at least 3 leading blank spaces
   1. The actual number in code is irrelevant; parsing will take care of setting the correct item number
   1. This way removing or adding a line in between lists will not require updating each number

* Bullet point lists
  * Nested bullet point lists
* Text in **bold** with \*\*double asterisk\*\*
* _italic_ *text* with \_underscore\_ or \*single asterisk\*
* Text `highlighted as code` within a sentence \`using backquotes\`
* Links to docs pages [documentation guidelines](documentation-guide.md)
* Links to [anchors within a page](#style); anchors are formed by replacing spaces with dashes, and converting to lowercase

For code samples we use the blocks with three backticks \`\`\` and specify the language for syntax highlighting:

```javascript
function sampleFunction (i) {
	return i + 2;
}
```

When mentioning code within a sentence `use a single backtick`.

### TODOs

Avoid using TODOs in docs or in code, as over time these TODOs  tend to accumulate and information about how they should be updated and why gets lost.

If it is absolutely necessary to add a TODO, follow these steps:

1. File a new issue on Github describing the context behind the TODO, and provide enough background that another contributor would be able to understand and then address the TODO.
1. Reference the issue URL in the todo in the docs.

> TODO (https://github.com/AzureIoTGBB/iot-edge-offline-dashboarding/issues/ISSUE_NUMBER_HERE): A brief blurb on the issue

### Highlighted sections

To highlight specific points to the reader, use *> [!NOTE]* , *> [!WARNING]* , and *> [!IMPORTANT]* to produce the following styles. It is recommended to use notes for general points and warning/important points only for special relevant cases.

> [!NOTE]
> Example of a note

> [!WARNING]
> Example of a warning

> [!IMPORTANT]
> Example of an important comment

## Page layout

### Headline

There should be only one first-level headline per page, acting as the main title.

If required, add a short introduction what the page  is about. Do not make this too long, instead add sub headlines. These allow to link to sections and can be saved as bookmarks.

### Main body

Use two-level and three-level headlines to structure the rest.

**Mini Sections**

Use a bold line of text for blocks that should stand out. We might replace this by four-level headlines at some point.

### 'See also' section

Some pages might end with a chapter called *See also*. This chapter is simply a bullet pointed list of links to pages related to this topic. These links may also appear within the page text where appropriate, but this is not required. Similarly, the page text may contain links to pages that are not related to the main topic, these should not be included in the *See also* list. See [this page's ''See also'' chapter](#see-also) as an example for the choice of links.

## Style

### Writing style

General rule of thumb: Try to **sound professional**. That usually means to avoid a 'conversational tone'. Also try to avoid hyperbole and sensationalism.

1. Don't try to be (overly) funny.
2. Never write 'I'
3. Avoid 'we'. This can usually be rephrased easily, using 'This sample' instead. Example: "we support this feature" -> "This sample supports this feature" or "the following features are supported ...".
4. Similarly, try to avoid 'you'. Example: "With this simple change the dashboard becomes configurable!" -> "Dashboards can be made configurable with little effort."
5. Do not use 'sloppy phrases'.
6. Avoid sounding overly excited, we do not need to sell anything.
7. Similarly, avoid being overly dramatic. Exclamation marks are rarely needed.

### Capitalization

* Use **Sentence case for headlines**. Ie. capitalize the first letter and names, but nothing else.
* Use regular English for everything else. That means **do not capitalize arbitrary words**, even if they hold a special meaning in that context. Prefer *italic text* for highlighting certain words, [see below](#emphasis-and-highlighting).
* When a link is embedded in a sentence (which is the preferred method), the standard chapter name always uses capital letters, thus breaking the rule of no arbitrary capitalization inside text. Therefore use a custom link name to fix the capitalization. As an example, here is a link to the [deployment manual](deployment-manual.md) documentation.
* Do capitalize names, such as *Azure*.

### Emphasis and highlighting

There are two ways to emphasize or highlight words, making them bold or making them italic. The effect of bold text is that **bold text sticks out** and therefore can easily be noticed while skimming a piece of text or even just scrolling over a page. Bold is great to highlight phrases that people should remember. However, **use bold text rarely**, because it is generally distracting.

Often one wants to either 'group' something that belongs logically together or highlight a specific term, because it has a special meaning. Such things do not need to stand out of the overall text. Use italic text as a *lightweight method* to highlight something.

Similarly, when a filename, a path or a menu-entry is mentioned in text, prefer to make it italic to logically group it, without being distracting.

In general, try to **avoid unnecessary text highlighting**. Special terms can be highlighted once to make the reader aware, do not repeat such highlighting throughout the text, when it serves no purpose anymore and only distracts.

### Links

Insert as many useful links to other pages as possible, but each link only once. Assume a reader clicks on every link in the page, and think about how annoying it would be, if the same page opens 20 times.

Prefer links embedded in a sentence:

* BAD: Guidelines are useful. See [this chapter](documentation-guide.md) for details.
* GOOD: [Guidelines](documentation-guide.md) are useful.

When adding a link, consider whether it should also be listed in the [See also](#see-also) section. Similarly, check whether a link to the new page should be added to the linked-to page.

## Page completion checklist

1. Ensure that this document's guidelines were followed.
1. Browse the document structure and see if the new document could be mentioned under the [See also](#see-also) section of other pages.
1. If available, have someone with knowledge of the topic proof-read the page for technical correctness.
1. Have someone proof-read the page for style and formatting. This can be someone unfamiliar with the topic, which is also a good idea to get feedback about how understandable the documentation is.

## Tools for editing MarkDown

[Visual Studio Code](https://code.visualstudio.com/) is a great tool for editing markdown files.

When writing documentation, installing the following two extensions is also highly recommended:

- Docs Markdown Extension for Visual Studio Code - Use Alt+M to bring up a menu of docs authoring options.

- Code Spell Checker - misspelled words will be underlined; right-click on a misspelled word to change it or save it to the dictionary.

Both of these come packaged in the Microsoft published Docs Authoring Pack.

## See also

- [Microsoft Docs contributor guide overview](https://docs.microsoft.com/en-us/contribute/)
