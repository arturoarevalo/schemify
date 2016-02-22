TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class FloatSchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new FloatSchema @properties, properties
        n.required = new FloatSchema n.properties, required: true
        return n

    parse: (value) -> parseFloat value

    isValidType: (value) -> TypeChecker.isFloat value


module.exports = FloatSchema
