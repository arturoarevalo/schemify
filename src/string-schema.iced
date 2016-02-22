TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class StringSchema extends AbstractSchema

    @DefaultProperties =
        required: false
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional

    extend: (properties) ->
        n = new StringSchema @properties, properties
        n.required = new StringSchema n.properties, required: true
        return n

    isValidType: (value) -> TypeChecker.isString value


module.exports = StringSchema
