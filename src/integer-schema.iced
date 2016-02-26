TypeChecker = require "./type-checker"
NumericSchema = require "./numeric-schema"

class IntegerSchema extends NumericSchema

    @DefaultProperties =
        defaultValue: null
        validator: TypeChecker.isInteger

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new IntegerSchema @properties, properties
        return n

    @getter "strict", -> @extend { validator: TypeChecker.isStrictInteger }

    parse: (value) -> parseInt value

    isValidType: (value) -> @properties.validator value


module.exports = IntegerSchema
