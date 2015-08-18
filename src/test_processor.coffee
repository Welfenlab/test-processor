
markdownItTest = require './md_test'
cbo = require '@more-markdown/callback-objects'
uuid = require 'node-uuid'
_ = require "lodash"

unifiedCallbacks = (apis, cbName) ->
  _(apis).chain()
    .select cbName
    .pluck cbName
    .compact()
    .value()

testProcessor = (langs, config) ->
  register: (mdInstance, postProcessors) ->
    callbacks =
      testsChanged: cbo()
      testsCodeChanged: cbo()

    markdownItTest.register mdInstance, langs, (testCode, token) ->
      id = "tp-"+uuid.v4()
      postProcessors.registerElemenbById id, (elem, done) ->
        tests = []

        runner = config.runner
        testFlavors = config.tests
        prepareFlavors = _.select testFlavors, 'prepare'
        flavoredCode = _.reduce prepareFlavors, ((code, flavor) ->
          flavor.prepare code, runner, elem, token), testCode

        apiFlavors = _.select testFlavors, 'api'
        customApis = _.map apiFlavors, (flavor) ->
          flavor.api flavoredCode, runner, elem, token

        failedCallbacks = unifiedCallbacks customApis, "failed"
        finishedCallbacks = unifiedCallbacks customApis, "finished"
        
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
