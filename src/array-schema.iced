TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"
Schemify = require "./schemify"

class ArraySchema extends AbstractSchema

    @DefaultProperties =
        required: false
        defaultValue: []

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new ArraySchema @properties, properties
        n.required = new ArraySchema n.properties, required: true
        return n

    of: (obj) ->
        if obj.constructor.name in Schemify.VALIDATORS
            @extend elementSchema: obj
        else
            @extend elementSchema: Schemify.of obj

    isEmpty: (value) -> (super value) or value.length is 0

    isValidType: (value) -> TypeChecker.isArray value

    validate: (value, exactMatch, fieldName) ->
        res = super value, exactMatch, fieldName
        if not res.valid
            return res

        if not @isEmpty value
            validator = @properties.elementSchema or Schemify.any

            for element, i in value
                res = validator.validate element, exactMatch, "#{fieldName}[#{i}]"
                if not res.valid
                    return res

        return res


    createNew: (value = null) ->
        if @isEmpty(value) or @isInvalid(value)
            return TypeChecker.clone @properties.defaultValue

        validator = @properties.elementSchema or Schemify.any

        return (validator.createNew item for item in value when validator.check item)


module.exports = ArraySchema
