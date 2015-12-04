
markdownItTest = require './md_test'
cbo = require '@more-markdown/callback-objects'
uuid = require 'node-uuid'
_ = require "lodash"

unifiedCallbacks = (apis, cbName) ->
  _(apis).chain()
    .map (api) -> api.remote
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
          _.merge acc_api, api), {}

        customApi.remote.failed = (e) ->
          _.each failedCallbacks, (c) -> c(e)
          done()
        customApi.remote.finished = (err) ->
          _.each finishedCallbacks, (c) -> c(err)
          done()

        deactivateConsoleAPI = """
          console = {log: function(){}};
        """

        fullCode = deactivateConsoleAPI + "\n" + flavoredCode
        
        sandbox = runner.run fullCode, customApi
        config.testProcessor?.init?(sandox)
        return sandbox

      return {
        dom: config.templates.tests id: id
      }


    return callbacks

module.exports = testProcessor
