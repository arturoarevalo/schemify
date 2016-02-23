TypeChecker = require "./type-checker"
NumericSchema = require "./numeric-schema"

class IntegerSchema extends NumericSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new IntegerSchema @properties, properties
        return n

    parse: (value) -> parseInt value

    isValidType: (value) -> TypeChecker.isInteger value


module.exports = IntegerSchema
