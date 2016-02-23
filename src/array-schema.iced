TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"
Schemify = require "./schemify"

class ArraySchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null
        required: false
        nonempty: false

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new ArraySchema @properties, properties
        n.required = new ArraySchema n.properties, required: true
        n.nonempty = new ArraySchema n.properties, { required: true, nonempty: true }
        return n

    of: (obj) ->
        if obj.constructor.name in Schemify.VALIDATORS
            @extend elementSchema: obj
        else
            @extend elementSchema: Schemify.of obj

    isEmpty: (value) -> (super value) or (@properties.nonempty and value.length is 0)

    isValidType: (value) -> TypeChecker.isArray value

    validate: (value, exactMatch, fieldName) ->
        res = super value, exactMatch, fieldName
        return res if not res.valid

        if not @isEmpty value
            validator = @properties.elementSchema or Schemify.any

            for element, i in value
                res = validator.validate element, exactMatch, "#{fieldName}[#{i}]"
                return res if not res.valid

        return res


    createNew: (value = null) ->
        if @isEmpty(value) or @isInvalid(value)
            return TypeChecker.clone @properties.defaultValue

        validator = @properties.elementSchema
        if validator
            n = []
            for item in value
                newItem = validator.createNew item
                n.push newItem if (newItem isnt null) and (validator.check newItem)
            return n
        else
            return TypeChecker.clone value


module.exports = ArraySchema
