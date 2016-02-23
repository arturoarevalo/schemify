TypeChecker = require "./type-checker"
AbstractSchema = require "./abstract-schema"

class NumericSchema extends AbstractSchema

    constructor: (properties, additional) ->
        super properties, additional

    between: (minimum, maximum) ->
        @extend 
            minimumLimit: true
            maximumLimit: true
            minimum: @parse minimum
            maximum: @parse maximum

    minimum: (minimum) ->
        @extend 
            minimumLimit: true
            minimum: @parse minimum

    maximum: (maximum) ->
        @extend 
            maximumLimit: true
            maximum: @parse maximum

    validate: (value, exactMatch, fieldName) ->
        res = super value, exactMatch, fieldName
        return res if not res.valid

        if @properties.minimumLimit or @properties.maximumLimit
            value = @parse value

            if @properties.minimumLimit and @properties.maximumLimit and (value < @properties.minimum or value > @properties.maximum)
                return @invalidResult "'#{value}' is not a valid value for field '#{fieldName}', should be between '#{@properties.minimum}' and '#{@properties.maximum}'"
            else if @properties.minimumLimit and value < @properties.minimum
                return @invalidResult "'#{value}' is not a valid value for field '#{fieldName}', it should be greater than '#{@properties.minimum}'"
            else if @properties.maximumLimit and value > @properties.maximum
                return @invalidResult "'#{value}' is not a valid value for field '#{fieldName}', it should be lower than '#{@properties.maximum}'"

        return @validResult


module.exports = NumericSchema
