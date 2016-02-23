TypeChecker = require "./type-checker"
NumericSchema = require "./numeric-schema"

class FloatSchema extends NumericSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new FloatSchema @properties, properties
        return n

    parse: (value) -> parseFloat value

    isValidType: (value) -> TypeChecker.isFloat value


module.exports = FloatSchema
