# based off of https://github.com/shinetech/backbone-identity-map
###
Identity Map for Backbone models.

Usage:
Base = require('rendr/shared/base/model')
IdentityMap = require('identity-map')
IdentityMap class MyModel extends Base
  ...

A model that is wrapped in IdentityMap will cache models by their
ID. Any time you call new NewModel(), and you pass in an id
attribute, IdentityMap will check the cache to see if that object
has already been created. If so, that existing object will be
returned. Otherwise, a new model will be instantiated.

Any models that are created without an ID will instantiate a new
object. If that model is subsequently assigned an ID, it will add
itself to the cache with this ID. If by that point another object
has already been assigned to the cache with the same ID, then
that object will be overridden.
###
# Stores cached models:
# key: (unique identifier per class) + ':' + (model id)
# value: model object
_ = require('underscore')
cache = {}
###
realConstructor: a backbone model constructor function
returns a constructor function that acts like realConstructor,
but returns cached objects if possible.
###

constructCashKey = (classCacheKey, objectId)->
  "#{classCacheKey}:#{objectId}"

IdentityMap = (realConstructor) ->
  classCacheKey = realConstructor.id
  # creates a new object (used if the object isn't found in the cache)
  makeOriginalObject = (attributes, options)->
    new realConstructor(attributes, options)

  makeNewObjectWithoutId = (attributes, options)->
    obj = makeOriginalObject(attributes, options)
    # when an object's id is set, add it to the cache
    obj.on "change:" + realConstructor::idAttribute, ((model, objectId) ->
      # TODO figure out existing listeners on the potentially cached model
      cache[constructCashKey(classCacheKey, objectId)] = obj
      obj.off null, null, this
      return
    ), this
    obj

  findOrCreateObject = (objectId, attributes, options)->
    cacheKey = constructCashKey(classCacheKey, objectId)
    if object = cache[cacheKey]
      # add new attributes to the object
      object.set attributes
      object
    else
      # the object has an ID, but isn't found in the cache
      cache[cacheKey] = makeOriginalObject(attributes, options)

  identityMapConstructor = (attributes, options) ->
    objectId = attributes and attributes[realConstructor::idAttribute]
    if objectId
      findOrCreateObject(objectId, attributes, options)
    else
      makeNewObjectWithoutId(attributes, options)

  modelConstructor = _.extend(identityMapConstructor, realConstructor)
  modelConstructor:: = realConstructor::
  modelConstructor


###
Clears the cache. (useful for unit testing)
###
IdentityMap.resetCache = ->
  cache = {}
  return

module.exports = IdentityMap
