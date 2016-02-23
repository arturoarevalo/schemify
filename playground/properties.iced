"use strict"

Function::trigger = (prop, getter, setter) ->
    Object.defineProperty @::, prop, { get: getter, set: setter }

class Class
    property: ''

    @trigger 'getable',
        () -> @member
        (value) -> @member = value

    member: 0

Obj =
    a: 10
    @trigger 'getable',
        () -> @member
        (value) -> @member = value
    



c = new Class
c2 = new Class

c.getable = 100
console.log c
console.log c.getable

console.log c2.getable