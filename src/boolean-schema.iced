TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class BooleanSchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new BooleanSchema @properties, properties
        n.required = new BooleanSchema n.properties, required: true
        return n

    isValidType: (value) -> TypeChecker.isBoolean value


module.exports = BooleanSchema
