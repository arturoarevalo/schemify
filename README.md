# schemify
A lightweight and simple framework for complex object schema validation, including nested objects, arrays and inheritance, with a nice syntax in coffeescript.

## Installation
```
npm install schemify
```

## Basic usage
### Creating and validating a very simple schema
```coffeescript
schema = require "schemify"

Point = schema.of
    x: schema.float
    y: schema.float

# use <Schema>.check() to quickly see if an object satisfies the schema
p1 = 
    x: 10
    y: 20

# returns true
Point.check p1 

# use <Schema>.validate() to obtain information about what failed during the validation
p2 = 
    x: "10"
    y: 20

# returns an object { valid: false, error: "string '10' is not a valid value for field 'x'"}
Point.validate p2 

# both check/validate accept a second parameter (exactMatch) to force the object being validated to have the exact structure as the schema
p3 = 
    x: 10
    y: 20
    z: 30

# returns { valid: true }
Point.validate p3

# returns { valid: false, error: "object structure does not exactly match the model"}
Point.validate p3, true
```

### Creating new instances of a schema and cleaning existing ones
```coffeescript
# create a new instance of a Point schema
p4 = Point.createNew()
# returns
#   p4.x = null
#   p4.y = null

# create a new instance, based on p5, which conforms to the schema
p5 = 
    x: '10'
    y: 20
    z: 30

p6 = Point.createNew p5
# returns
#   p6.x = null ... because p5.x was a string and it should be an integer
#   p6.y = 20   ... ok, p5.y was a valid value
#   p6.z doesn't exist, as "z" is not defined in the schema
```

### Validators
```coffeescript
# built-in standard validators
schema.integer                      # integers
schema.float                        # floats
schema.string                       # strings
schema.boolean                      # booleans
schema.array                        # arrays
schema.of <obj>                     # objects
schema.any                          # anything

# built-in validators for some standard integer ranges
schema.int8                         # -128, 127
schema.uint8                        # 0, 255
schema.int16                        # -32768, 32767
schema.uint16                       # 0, 65535
schema.int32                        # -2147483648, 2147483647
schema.uint32                       # 0, 4294967295

# and some aliases
schema.int = schema.integer
schema.real = schema.float
schema.bool = schema.boolean
schema.byte = schema.uint8
schema.short = schema.int16
schema.ushort = schema.uint16
schema.long = schema.int32
schema.ulong = schema.uint32
```

### Required attributes
```coffeescript
# by default, validators accept null/undefined values as valid ones
Point = schema.of
    x: schema.integer
    y: schema.integer

# returns true, as null values are allowed
Point.check { x:null, y:20 }

# .required attribute to force them to be mandatory
Point = schema.of
    x: schema.integer.required
    y: schema.integer.required

# both return false, as null or undefined values aren't allowed
Point.check { x: null, y: 20 }
Point.check { x: 10 }
```

### Default values
```coffeescript
# when creating new instances of a schema, or cleaning existing ones, empty or invalid valued will be replaced by the validator default value, which is null
Point = schema.of
    x: schema.integer
    y: schema.integer

# returns { x:null, y:null }
Point.createNew()

# returns { x:null, y:20 }
Point.createNew { x: "not a number", y: 20 }

# all validators have the .default method to set the default value for the field
Point = schema.of
    x: schema.integer.default -999
    y: schema.integer.default 999

# both return { x: -999, y: 999 }
Point.createNew()
Point.createNew { x: "string and floats not allowed", y: 123.456 }

# returns { x: 10, y: 20 }, as all other fields aren't copied to the new instance
Point.createNew { x: 10, y: 20, z: 30, w: 40 }

# both return { x: 10, y: 999 }
Point.createNew { x: 10 }
Point.createNew { x: 10, y: true, z: 20 }
```

### Schema creation by values
```coffeescript
# directly using values is the same as using validators with the required attribute and default values
Product = schema.of
    id: 0
    name: "Name of the product"
    price: 9.99
    extendedData:
        tags: ["tag1", "tag2"]
        language: "en"
        available: true

# is the same as
Product = schema.of
    id: schema.integer.required.default 0
    name: schema.string.required.default "Name of the product"
    price: schema.float.required.default 9.99
    extendedData: schema.of
        tags: schema.array.required.default(["tag1", "tag2"]).of schema.any
        language: schema.string.required.default "en"
        available: schema.boolean.required.default true

# both notations can be freely mixed in schema declaration
Person = schema.of
    name: schema.string
    age: 0
    gender: "F"
```

### Range checking
```coffeescript
# numeric validators (integer, float) allow to set minimum and maximum values
Person = schema.of
    name: schema.string
    age: schema.integer.minimum 0
    fingers: schema.integer.between 0, 10
    eyes: schema.integer.maximum 2

# note that using .between, .minimum or .maximum doesn't make the attribute required ...
Person.check { name: "John" }               # true, all can be null
                                            # use .required instead
Person.check { name: "John", eyes: 3 }      # false, eyes is out of range
```

### Set of values
```coffeescript
# use the .in function in a validator to set a list of its possible values
Person = schema.of
    name: schema.string
    gender: schema.string.in ["MALE", "FEMALE"]

# again, note that using .in doesn't make the attribute required ...
Person.check { name: "John" }                   # true, gender can be null
                                                # use .required instead
Person.check { name: "John", gender: "OTHER" }  # false, gender is out of range
```

## Advanced usage
### Nested objects
```coffeescript
Person = schema.of
    name: schema.string.required.default "John Doe"
    age: schema.integer
    address: schema.of
        street: schema.string.required
        postalCode: schema.string

p1 = 
    name: "John"
    age: 30

# WON'T VALIDATE: person doesn't have an address
Person.validate p1

p2 =
    name: "John"
    age: 30
    address:
        postalCode: "12345"

# WON'T VALIDATE: person has an address, but the "street" attribute is missing and it's required

p3 =
    name: "John"
    age: 30
    address:
        street: "Elm Street, 100"

# OK, IT'S VALID: person has an address ... postal code is missing ... but it's not required
```

### Array validation
```coffeescript
# elements inside an array can be validated against a schema

# "items" can be null, empty [] or contain elements of mixed types [1, "2", {a:1, b:2}, true]
Example = schema.of
    # can be null or empty []
    # can contain elements of mixed types [1, "2", {a:1}]
    items1: schema.array

    # cannot be null, but can be empty []
    # can contain elements of mixed types [1, "2", {a:1}]
    items2: schema.array.required

    # cannot be null nor empty []
    # can contain elements of mixed types [1, "2", {a:1}]
    items3: schema.array.nonempty

    # cannot be null nor empty []
    # can only contain elements of a single type (integers)
    items4: schema.array.nonempty.of schema.integer

    # cannot be null nor empty []
    # can only contain elements of a single type,
    #   objects with the following schema { attr1: integer, attr2: string }
    items5: schema.array.nonempty.of
        attr1: schema.integer
        attr2: schema.string
```

### Array cleaning
```coffeescript
# when cleaning instances, array elements which don't validate are removed
Example1 = schema.of
    numbers: schema.array.of schema.integer

# only numeric (integer) elements are kept
# returns { numbers: [1, 2, 3, 4, 5 ]}
Example1.createNew { numbers: [1, "a", 2, 2.5, 3, true, false, 4, {a:1}, 5]}

# validation of arrays show which element failed
# returns { valid: false, error: "string 'a' is not a valid value for attribute 'numbers[1]'"}
Example1.validate { numbers: [1, "a", 2, 2.5, 3, true, false, 4, {a:1}, 5]}
```

### Composition
```coffeescript
# schemas can be composed ...
Address = schema.of
    street: schema.string
    postalCode: schema.string

Person = schema.of
    name: schema.string
    age: schema.integer
    address: Address

Business = schema.of
    name: schema.string
    address: Address

# ... and used in arrays ...
Example = schema.of
    customers: schema.array.of Business

# this fails to validate ...
b1 = 
    customers: [
        {
            name: "Business 1"
        },
        {
            name: "Business 2"
            address:
                street: "street name"
                postalCode: "12345"
        }
    ]

# ... as customers[0].address is required
Example.validate b1
```

### Inheritance
```coffeescript
# use the .with function of a object schema to create a new schema that inherits its attributes and extends them
Person = schema.of
    name: schema.string
    age: schema.integer

Employee = Person.with
    salary: schema.float.required

person = 
    name: "John Doe Unemployeed"
    age: 30

employeed =
    name: "John Doe Employeed"
    age: 30
    salary: 40000

Person.check person             # true, is valid
Employee.check employeed        # true, is valid
Person.check employeed          # true, all attributes of Person validate
Person.check employeed, true    # false, salary is not an attribute of Person
Employee.check person           # false, salary is missing
```

```coffeescript
# inherited schemas can just change the behaviour of an attribute
Person = schema.of
    name: schema.string
    age: schema.integer.between 0, 100

Employee = Person.with
    age: schema.integer.between 18, 65

young = 
    name: "John Doe Young"
    age: 10

employeed =
    name: "John Doe Employeed"
    age: 30

retired =
    name: "John Doe Retired"
    age: 80

# all are valid Person
Person.check young          # true
Person.check employeed      # true
Person.check retired        # true

# but only one of them is a valid Employee
Employee.check young        # false, age < 18
Employee.check employeed    # true
Employee.check retired      # false, age > 65
```


# TODO
- Write (more) tests
- Better documentation
- Additional validators, i.e. date
- Additional validations, i.e. string.(max|min)length, integer.minimum|maximum
- Custom validations
```coffeescript
# value should be odd/even
Model = schema.of
    value: schema.integer.custom (value) -> (value % 2) is 1
```
- Conditional validations 
```coffeescript
# terms and conditions must be accepted if age is under 18
Customer = schema.of
    age: schema.integer.required
    accepted: schema.boolean
        .when((model) -> model.age < 18).required.in([true])
        .otherwise.in([true, false])
```
