TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"
Schemify = require "./schemify"

class ObjectSchema extends AbstractSchema

    @DefaultProperties =
        required: true

    constructor: (obj, properties, additional) ->
        super properties, additional

        @definition = {}
        for key, value of obj
            @definition[key] = Schemify.automaticFromValue value

    of: (obj) ->
        new ObjectSchema obj, @properties

    with: (obj) ->
        definition = {}
        for key, value of @definition
            definition[key] = value
        for key, value of obj
            definition[key] = value

        new ObjectSchema definition, @properties

    isValidType: (obj) -> "object" is typeof obj

    validate: (value, exactMatch, fieldName) ->
        res = super value, exactMatch, fieldName
        if not res.valid
            return res

        separator = if fieldName? then "#{fieldName}." else ""

        count = 0
        exact = true
        for name, schema of @definition
            res = schema.validate value[name], exactMatch, "#{separator}#{name}"
            if not res.valid
                return res

            count++
            exact = exact and value.hasOwnProperty name


        if exactMatch 
            if exact
                exact = count is Object.getOwnPropertyNames(value).length

            if not exact
                return @invalidResult "object structure does not exactly match the model"

        return res

    createNew: (value = {}) ->
        n = {}
        for name, schema of @definition
            n[name] = schema.createNew value[name]
        return n


module.exports = ObjectSchema
