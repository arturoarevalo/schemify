import "reflect-metadata";

type Prototype = any;

abstract class SchemaProperty {
    defaultValue: any;
    required: boolean;

    constructor() { }

    static create(type: any): SchemaProperty {
        if (type === String) {
            return new StringSchemaProperty();
        } else if (type === Number) {
            return new NumberSchemaProperty();
        } else if (type === Boolean) {
            return new BooleanSchemaProperty();
        } else if (type === Date) {
            return new DateSchemaProperty();
        } else if (type === Object) {
            return new ObjectSchemaProperty();
        } else {
            return new ClassSchemaProperty(type);
        }
    }
}

class StringSchemaProperty extends SchemaProperty {
}

class NumberSchemaProperty extends SchemaProperty {
}

class BooleanSchemaProperty extends SchemaProperty {
}

class DateSchemaProperty extends SchemaProperty {
}

class ObjectSchemaProperty extends SchemaProperty {
}

class ClassSchemaProperty extends SchemaProperty {
    constructor(readonly type: Prototype) {
        super();
    }
}

class Schema {
    properties = new Map<string, SchemaProperty>();

    constructor(private readonly proto: Prototype) { }

    findProperty(key: string, type: Prototype): SchemaProperty {
        let property = this.properties.get(key);
        if (property === undefined) {
            property = SchemaProperty.create(type);
            this.properties.set(key, property);
        }

        return property;
    }
}

const schemas = new Map<Prototype, Schema>();

function findSchema(target: Prototype): Schema {
    let schema = schemas.get(target);
    if (schema === undefined) {
        schema = new Schema(target);
        schemas.set(target, schema);
        console.log("created new schema", target);
    } else {
        console.log("retrieved schame", target);
    }

    return schema;
}

function findProperty(target: Prototype, key: string): SchemaProperty {
    const type = Reflect.getMetadata("design:type", target, key);
    const schema = findSchema(target);

    return schema.findProperty(key, type);
}

function Required(target: Prototype, key: string): void {
    const property = findProperty(target, key);
    property.required = true;
}

export function Optional(target: Prototype, key: string): void {
    const property = findProperty(target, key);
    property.required = false;
}

export function DefaultValue(value: any): PropertyDecorator {
    return (target: Prototype, key: string) => {
        const property = findProperty(target, key);
        property.defaultValue = value;
    };
}

class Address {
    @Required
    public name2: string;
}

class Person {
    constructor() { }

    @Required @DefaultValue("ad")
    public name: string;

    @Required
    public active: boolean;

    @Required
    public age: number;

    @Required
    public birth: Date;

    @Required
    public address: Address;
}

class Employee extends Person {
}

const m = Reflect.getMetadata("design:type", Employee.prototype, "active");
console.log(m === String);
console.log(m === Boolean);
console.log(m === Number);
console.log(m === Date);
console.log(m === Address);

const p = new Person();
console.log(Object.getPrototypeOf(p));
