_ = require "lodash"

# code extraction out of fenced blocks
module.exports = {
  register: (md, langs, testFlavors, runner, gen_dom) ->
    origFence = md.renderer.rules.fence
    md.renderer.rules.fence = (tokens, idx) =>
      fenceToken = tokens[idx]
      fencedContent = origFence.apply this, arguments

      if (langs.indexOf fenceToken.info) > -1
        domStuff = gen_dom()
        callbacks = domStuff
        fencedContent = domStuff.dom

        testCode = fenceToken.content
        tests = []

        prepareFlavors = _.select testFlavors, 'prepare'
        flavoredCode = _.reduce prepareFlavors, ((code, flavor) ->
          flavor.prepare code, runner, domStuff), testCode

        apiFlavors = _.select testFlavors, 'api'
        customApis = _.map apiFlavors, (flavor) ->
          flavor.api flavoredCode, runner

        failedCallbacks = _(customApis).chain()
          .select "failed"
          .pluck "failed"
          .compact()
          .value()
        finishedCallbacks = _(customApis).chain()
          .select "finished"
          .pluck "finished"
          .compact()
          .value()

        customApi = _.reduce customApis, ((acc_api, api) ->
          _.merge acc_api, api), runner.createApi()

        customApi.failed = (e) ->
          _.each failedCallbacks, (c) -> c(e)
        customApi.finished = () ->
          _.each finishedCallbacks, (c) -> c()

        runner.run flavoredCode, customApi

      fencedContent
}
