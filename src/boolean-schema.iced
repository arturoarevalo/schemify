TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class BooleanSchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new BooleanSchema @properties, properties
        return n

    isValidType: (value) -> TypeChecker.isBoolean value


module.exports = BooleanSchema
