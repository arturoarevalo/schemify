schema = require "./lib/schemify.js"



Person = schema.of
    name: schema.string
    age: schema.integer.between 0, 100
    gender: schema.string.required.in ["M", "F"]


Employee = Person.with
    salary: schema.float.required.between 0, 50000
    age: schema.integer.between 18, 67

Boss = Employee.with
    salary: schema.float.between 50000, 1000000
    employees: schema.array.required.of Employee



person = 
    name: "John Doe"
    age: 75
    gender: "M"

employee = 
    name: "John Employeed"
    age: 35
    gender: "M"
    salary: 35000

boss = 
    name: "John Boss"
    age: 55
    gender: "M"
    salary: 250000


console.log Person.validate person
console.log Employee.validate person
console.log Boss.validate person

console.log Person.validate employee
console.log Employee.validate employee
console.log Boss.validate employee

console.log "Boss is person", Person.validate boss, true
console.log Employee.validate boss
console.log Boss.validate boss, true

