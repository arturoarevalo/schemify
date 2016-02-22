Schemify = {}

module.exports = Schemify

TypeChecker = require "./type-checker"
IntegerSchema = require "./integer-schema"
FloatSchema = require "./float-schema"
StringSchema = require "./string-schema"
BooleanSchema = require "./boolean-schema"
ArraySchema = require "./array-schema"
ObjectSchema = require "./object-schema"
AnySchema = require "./any-schema"


Schemify.VALIDATORS = ["IntegerSchema", "FloatSchema", "BooleanSchema", "StringSchema", 
                       "ArraySchema", "ObjectSchema", "AnySchema"]

# base schema types
Schemify.integer = (new IntegerSchema).extend IntegerSchema.DefaultProperties
Schemify.float = (new FloatSchema).extend FloatSchema.DefaultProperties
Schemify.boolean = (new BooleanSchema).extend BooleanSchema.DefaultProperties    
Schemify.string = (new StringSchema).extend StringSchema.DefaultProperties
Schemify.array = (new ArraySchema).extend ArraySchema.DefaultProperties
Schemify.any = (new AnySchema).extend AnySchema.DefaultProperties
Schemify.of = (p) -> new ObjectSchema p, ObjectSchema.DefaultProperties

# 
Schemify.int8 = Schemify.integer.between -128, 127
Schemify.uint8 = Schemify.integer.between 0, 255
Schemify.int16 = Schemify.integer.between -32768, 32767
Schemify.uint16 = Schemify.integer.between 0, 65535
Schemify.int32 = Schemify.integer.between -2147483648, 2147483647
Schemify.uint32 = Schemify.integer.between 0, 4294967295
 
# aliases
Schemify.int = Schemify.integer
Schemify.real = Schemify.float
Schemify.bool = Schemify.boolean
Schemify.byte = Schemify.uint8
Schemify.short = Schemify.int16
Schemify.ushort = Schemify.uint16
Schemify.long = Schemify.int32
Schemify.ulong = Schemify.uint32


Schemify.automaticFromValue = (value) ->
    if ("object" is typeof value) and (value?.constructor?.name in Schemify.VALIDATORS)
        return value

    return switch
        when null is value then Schemify.any
        when TypeChecker.isString value then Schemify.string.required.default value
        when TypeChecker.isBoolean value then Schemify.boolean.required.default value
        when TypeChecker.isInteger value then Schemify.integer.required.default value
        when TypeChecker.isFloat value then Schemify.float.required.default value
        when TypeChecker.isArray value then Schemify.array.required.of Schemify.any
        else Schemify.of value
