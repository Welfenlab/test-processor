
# code extraction out of fenced blocks
module.exports = {
  register: (md, langs, gen_dom) ->
    origFence = md.renderer.rules.fence
    md.renderer.rules.fence = (tokens, idx) =>
      fenceToken = tokens[idx]
      fencedContent = origFence.apply this, arguments

      if (langs.indexOf fenceToken.info) > -1
        testCode = fenceToken.content

        # this one starts the test stuff
        domStuff = gen_dom testCode, tokens
        fencedContent = domStuff.dom

      fencedContent
}
