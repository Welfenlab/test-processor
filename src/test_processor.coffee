
markdownItTest = require './md_test'
cbo = require '@more-markdown/callback-objects'
uuid = require 'node-uuid'

testProcessor = (langs, config) ->
  register: (mdInstance, postProcessors) ->
    callbacks =
      testsChanged: cbo()
      testsCodeChanged: cbo()

    markdownItTest.register mdInstance, langs, config.tests, config.runner, () ->
      id = "tp-"+uuid.v4()
      mdInstance.domReady.registerCallback -> config.callbacks?.ready?()

      return {
        dom: config.templates.tests id: id
      }


    return callbacks

module.exports = testProcessor
