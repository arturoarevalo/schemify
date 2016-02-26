
TypeChecker =
    isEmpty: (value) -> (null is value) or (undefined is value)

    isNumeric: (value) -> "number" is typeof value

    isInteger: (value) ->
        (value.toString().match /^[0-9]*$/) and TypeChecker.isStrictInteger parseInt value

    isStrictInteger: (value) -> switch
        when Number.isInteger then Number.isInteger value
        else ("number" is typeof value) and (isFinite value) and (value > -9007199254740992) and (value < 9007199254740992) and (value is Math.floor value)

    isFloat: (value) -> ("number" is typeof value) and (parseFloat(value).toString() is value.toString())

    isString: (value) -> "string" is typeof value

    isBoolean: (value) -> "boolean" is typeof value

    isArray: (value) -> switch
        when Array.isArray then Array.isArray value
        else ("object" is typeof value) and (value?.hasOwnProperty "length")

    clone: (obj) ->
        if not obj? or typeof obj isnt "object"
            return obj

        if obj instanceof Date
            return new Date obj.getTime()

        if obj instanceof RegExp
            flags = ""
            flags += 'g' if obj.global?
            flags += 'i' if obj.ignoreCase?
            flags += 'm' if obj.multiline?
            flags += 'y' if obj.sticky?
            return new RegExp obj.source, flags

        newInstance = new obj.constructor

        for key of obj
            newInstance[key] = @clone obj[key]

        return newInstance


module.exports = TypeChecker
