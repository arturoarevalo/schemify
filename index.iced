

TypeChecker =

    isEmpty: (value) -> (null is value) or (undefined is value)

    isInteger: (value) -> switch
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
            newInstance[key] = clone obj[key]

        return newInstance


class AbstractSchema

    constructor: (parent = {}, properties = {}) ->
        @properties = {}

        for key, value of parent
            @properties[key] = value

        for key, value of properties
            @properties[key] = value

    default: (value) -> @extend defaultValue: @parse value

    between: (minimum, maximum) ->
        @extend 
            limits: true
            minimum: @parse minimum
            maximum: @parse maximum

    parse: (value) -> value
    
    isEmpty: (value) -> TypeChecker.isEmpty value

    isValid: (value) -> true

    isInvalid: (value) -> not @isValid(value) #or not @validate(value)

    validate: (value, exactMatch, fieldName) ->
        if @isEmpty value

            return not @properties.required

        if not @isValid value
            return false

        if @properties.limits 
            value = @parse value

            if @properties.limits and (value < @properties.minimum or value > @properties.maximum)
                return false

        return true

    createNew: (value = null) -> switch
        when @isEmpty value then @properties.defaultValue
        when @isInvalid value then @properties.defaultValue
        else @parse value


class IntegerSchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new IntegerSchema @properties, properties
        n.required = new IntegerSchema n.properties, required: true
        return n

    parse: (value) -> parseInt value

    isValid: (value) -> TypeChecker.isInteger value



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

    isValid: (value) -> TypeChecker.isFloat value



class BooleanSchema extends AbstractSchema

    @DefaultProperties =
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional
    
    extend: (properties) ->
        n = new BooleanSchema @properties, properties
        n.required = new BooleanSchema n.properties, required: true
        return n

    isValid: (value) -> TypeChecker.isBoolean value


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
            @extend elementSchema: schema.of obj

    isEmpty: (value) -> (super value) or value.length is 0

    isValid: (value) -> TypeChecker.isArray value

    validate: (value) ->
        if not super value
            return false

        if not @isEmpty value
            validator = @properties.elementSchema or schema.any

            for element in value
                if not validator.validate element
                    return false

        return true


    createNew: (value = null) ->
        if @isEmpty(value) or @isInvalid(value)
            return TypeChecker.clone @properties.defaultValue

        validator = @properties.elementSchema or schema.any

        return (validator.createNew item for item in value when validator.validate item)


class StringSchema extends AbstractSchema

    @DefaultProperties =
        required: false
        defaultValue: null

    constructor: (properties, additional) ->
        super properties, additional

    extend: (properties) ->
        n = new StringSchema @properties, properties
        n.required = new StringSchema n.properties, required: true
        return n

    isValid: (value) -> TypeChecker.isString value



class ObjectSchema extends AbstractSchema

    @DefaultProperties = {}

    constructor: (properties, additional) ->
        super properties, additional

    of: (obj) ->
        new ObjectSchema obj

    isValid: (obj) -> "object" is typeof obj

    validate: (value, raiseExceptions = false) ->
        if not super value
            return false

        for name, schema of @properties
            if not schema.validate value[name], raiseExceptions
                return false

        return true

    createNew: (value = {}) ->
        n = {}
        for name, schema of @properties
            n[name] = schema.createNew value[name]
        return n


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



class Schemify

    VALIDATORS = ["IntegerSchema", "FloatSchema", "BooleanSchema", "StringSchema", 
                  "ArraySchema", "ObjectSchema", "AnySchema"]

    constructor: ->
        # base types
        @integer = (new IntegerSchema).extend IntegerSchema.DefaultProperties
        @float = (new FloatSchema).extend FloatSchema.DefaultProperties
        @boolean = (new BooleanSchema).extend BooleanSchema.DefaultProperties    
        @string = (new StringSchema).extend StringSchema.DefaultProperties
        @array = (new ArraySchema).extend ArraySchema.DefaultProperties
        @any = (new AnySchema).extend AnySchema.DefaultProperties

        # 
        @int8 = @integer.between -128, 127
        @uint8 = @integer.between 0, 255
        @int16 = @integer.between -32768, 32767
        @uint16 = @integer.between 0, 65535
        @int32 = @integer.between -2147483648, 2147483647
        @uint32 = @integer.between 0, 4294967295
     
        # aliases
        @int = @integer
        @real = @float
        @bool = @boolean
        @byte = @uint8
        @short = @int16
        @ushort = @uint16
        @long = @int32
        @ulong = @uint32

        @of = (p) -> new ObjectSchema p




schema = new Schemify


A = schema.of
    a: schema.int
    b: schema.integer.default 10
    c: schema.string.required.default "Hello World"


a =
    a: 1
    b: 2

console.log A.validate a
console.log A.createNew a
