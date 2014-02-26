# Identity Map for Backbone Models
All the logic was taken from https://github.com/shinetech/backbone-identity-map.

Subscribes to the module pattern.
Tested with [Rendr](https://github.com/rendrjs/rendr) models.

Usage:
```coffee
Base = require('rendr/shared/base/model')
IdentityMap = require('identity-map')

IdentityMap class MyModel extends Base
  ...
```
