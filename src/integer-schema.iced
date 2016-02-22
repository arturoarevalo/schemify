TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class IntegerSchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new IntegerSchema @properties, properties
        n.required = new IntegerSchema n.properties, required: true
        return n

    parse: (value) -> parseInt value

    isValidType: (value) -> TypeChecker.isInteger value


module.exports = IntegerSchema
