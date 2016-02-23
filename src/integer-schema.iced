TypeChecker = require "./type-checker"
NumericSchema = require "./numeric-schema"

class IntegerSchema extends NumericSchema

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
