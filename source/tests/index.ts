import "reflect-metadata";

type Prototype = any;

interface ValidationContext {
    attributeName: string;
    attributeValue: any;
    className: string;
}

abstract class Validation {
    abstract execute(context: ValidationContext): string | undefined;
}

export class TypeValidation extends Validation {
    constructor(private readonly type: Prototype) { super(); }

    execute(context: ValidationContext): string | undefined {
        if (context.attributeValue !== undefined && context.attributeValue.constructor !== this.type) {
            return "type error " + context.attributeValue.constructor + " " + this.type;
        } else {
            return undefined;
        }
    }
}

export class RequiredValidation extends Validation {
    execute(context: ValidationContext): string | undefined {
        if (context.attributeValue === undefined) {
            return "required value error " + context.attributeName;
        } else {
            return undefined;
        }
    }
}

class SchemaProperty {
    defaultValue: any;
    validations: Validation[] = [];

    constructor(type: any) {
        this.addValidation(new TypeValidation(type));
    }

    addValidation(validation: Validation): void {
        this.validations.push(validation);
    }

    verify(context: ValidationContext): string[] {
        const results: string[] = [];

        for (const validation of this.validations) {
            const validationResult = validation.execute(context);
            if (validationResult !== undefined) {
                results.push(validationResult);
            }
        }

        return results;
    }
}

class Schema {
    properties = new Map<string, SchemaProperty>();

    constructor(private readonly proto: Prototype) { }

    findProperty(key: string, type: Prototype): SchemaProperty {
        let property = this.properties.get(key);
        if (property === undefined) {
            property = new SchemaProperty(type);
            this.properties.set(key, property);
        }

        return property;
    }

    verify(value: any, options?: VerificationOptions): string[] {
        const results: string[] = [];

        for (const [key, property] of this.properties) {
            const context: ValidationContext = {
                attributeName: key,
                attributeValue: value[key],
                className: this.proto
            };

            results.push(...property.verify(context));
        }

        return results;
    }
}

const schemas = new Map<Prototype, Schema>();

function findSchema(target: Prototype): Schema {
    let schema = schemas.get(target);
    if (schema === undefined) {
        schema = new Schema(target);
        schemas.set(target, schema);
    }

    return schema;
}

function findProperty(target: Prototype, key: string): SchemaProperty {
    const type = Reflect.getMetadata("design:type", target, key);
    const schema = findSchema(target);

    console.log(target, key, type);

    return schema.findProperty(key, type);
}

function Required(target: Prototype, key: string): void {
    const property = findProperty(target, key);
    property.addValidation(new RequiredValidation());
}

export function Optional(target: Prototype, key: string): void {
    findProperty(target, key);
}

export function DefaultValue(value: any): PropertyDecorator {
    return (target: Prototype, key: string) => {
        const property = findProperty(target, key);
        property.defaultValue = value;
    };
}

interface Constructable<T> { new(): T; }

export interface VerificationOptions {
    exact?: boolean;
}

export class Schemify {
    static options: VerificationOptions = {
        exact: false
    };

    private static mixOptions(options?: VerificationOptions): VerificationOptions {
        return {
            exact: (options && options.exact !== undefined) ? options.exact : this.options.exact
        };
    }

    static verify<T>(value: any, type: Constructable<T>, options?: VerificationOptions): string[] {
        options = this.mixOptions(options);

        const schema = findSchema(type.prototype);
        return schema.verify(value, options);
    }
}

class Address {
    @Required
    public name2: string;
}

class Person {
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

    @Required
    public numbers: Number[];
}

const a = Schemify.verify({ name: "asas" }, Person);
console.log(a);
