TypeChecker = require "./type-checker"

class AbstractSchema

    constructor: (parent = {}, properties = {}) ->
        @properties = {}

        for key, value of parent
            @properties[key] = value

        for key, value of properties
            @properties[key] = value

    default: (value) -> @extend defaultValue: @parse value

    in: (list) ->
        @extend
            validValues: list

    parse: (value) -> value
    
    isEmpty: (value) -> TypeChecker.isEmpty value

    isValidType: (value) -> true

    isInvalid: (value) -> not @isValidType(value) #or not @validate(value)

    validResult: 
        valid: true

    invalidResult: (text) ->
        valid: false
        error: text

    validate: (value, exactMatch, fieldName) ->
        if @isEmpty value
            if @properties.required
                return @invalidResult "field '#{fieldName}' is required"

            return @validResult

        if not @isValidType value
            return @invalidResult "#{typeof value} '#{value}' is not a valid value for field '#{fieldName}'"

        if @properties.validValues
            value = @parse value

            if value not in @properties.validValues
                return @invalidResult "'#{value}' is not a valid value for field '#{fieldName}', should be one of '#{@properties.validValues}'"

        return @validResult

    check: (value, exactMatch) ->
        res = @validate value, exactMatch
        return res.valid

    createNew: (value = null) -> switch
        when (@isEmpty value) or (not @check value) then TypeChecker.clone @properties.defaultValue
        else TypeChecker.clone @parse value


module.exports = AbstractSchema
