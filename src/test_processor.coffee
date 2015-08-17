
markdownItTest = require './md_test'
cbo = require '@more-markdown/callback-objects'
uuid = require 'node-uuid'

testProcessor = (langs, config) ->
  register: (mdInstance, postProcessors) ->
    callbacks =
      testsChanged: cbo()
      testsCodeChanged: cbo()

    markdownItTest.register mdInstance, (testCode) ->
      id = "tp-"+uuid.v4()
      mdInstance.domReady.registerCallback ->
        tests = []

        runner = config.runner
        testFlavors = config.tests
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

      return {
        dom: config.templates.tests id: id
      }


    return callbacks

module.exports = testProcessor
