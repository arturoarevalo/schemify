TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class AnySchema extends AbstractSchema

    @DefaultProperties = 
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional

    extend: (properties) ->
        n = new AnySchema @properties, properties
        n.required = new AnySchema n.properties, required: true
        return n

    createNew: (value) ->
        if @isEmpty(value) or @isInvalid(value)
            return TypeChecker.clone @properties.defaultValue

        return TypeChecker.clone value


module.exports = AnySchema
