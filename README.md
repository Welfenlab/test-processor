# more-markdown / test-processor

A plugin for `more-markdown` that runs tests on the markdown contents.

# Installation

You first need a [more-markdown](https://github.com/Welfenlab/more-markdown) setup.
Then you can install it via:

```
npm install @more-markdown/test-processor
```

# Usage

```
var moreMarkdown = require('more-markdown');
var testProcessor = require('@more-markdown/test-processor');

// create a processor that writes the final html
// to the element with the id 'output'
var proc = moreMarkdown.create('output', processors: [testProcessor(...)]);

proc.render("```test" +
"it('should do X', function(){...})" +
"```");
```

Or have a look at the [markdown-editor-example](https://github.com/Welfenlab/markdown-editor-example)
