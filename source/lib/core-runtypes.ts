import { RequiredRuntype } from "./runtype";

export abstract class ValuedRuntype<T> extends RequiredRuntype<T> {
    in(values: T[]): this {
        this.constraint((value) => values.includes(value) || `its value <${value}> is not one of the accepted values <${values.join(", ")}>`);
        return this;
    }

    equal(targetValue: T): this {
        this.constraint(value => (value === targetValue) || `its value is <${value}> and should be <${targetValue}>`);
        return this;
    }

    notEqual(targetValue: T): this {
        this.constraint(value => (value !== targetValue) || `its value should be other than <${targetValue}>`);
        return this;
    }
}

export class BooleanRuntype extends ValuedRuntype<boolean> {
    constructor() {
        super("boolean", "boolean");
    }
}

export abstract class NumericRuntype<T> extends ValuedRuntype<T> {
    constructor(runtimeType?: string) {
        super("number", runtimeType);
    }

    greaterThan(value: T): this {
        this.constraint((value) => (value > value) || `should be greater than ${value}`);
        return this;
    }

    lessThan(value: T): this {
        this.constraint((value) => (value < value) || `should be less than ${value}`);
        return this;
    }

    greaterOrEqualTo(value: T): this {
        this.constraint((value) => (value >= value) || `should be greater or equal to ${value}`);
        return this;
    }

    lessOrEqualTo(value: T): this {
        this.constraint((value) => (value <= value) || `should be less or equal to ${value}`);
        return this;
    }

    between(minimum: T, maximum: T): this {
        this.constraint((value) => (value >= minimum && value <= maximum) || `should be between ${minimum} and ${maximum}`);
        return this;
    }
}

export class StringRuntype extends ValuedRuntype<string> {
    constructor() {
        super("string", "string");
    }

    allowEmpty(): this {
        this.metadata.emptiable = true;
        return this;
    }

    trim(): this {
        this.preprocess((value) => {
            if (typeof value === "string") {
                return value.trim();
            } else {
                return value;
            }
        });

        return this;
    }

    trimLeft(): this {
        this.preprocess((value) => {
            if (typeof value === "string") {
                return value.trimLeft();
            } else {
                return value;
            }
        });

        return this;
    }

    trimRight(): this {
        this.preprocess((value) => {
            if (typeof value === "string") {
                return value.trimRight();
            } else {
                return value;
            }
        });

        return this;
    }

    minLength(length: number): this {
        this.constraint((value) => (value.length >= length) || `should have at least ${length} characters`);
        return this;
    }

    maxLength(length: number): this {
        this.constraint((value) => (value.length <= length) || `should have no more than ${length} characters`);
        return this;
    }

    protected isEmpty(value: string): boolean {
        return value === "";
    }
}

export class NumberRuntype extends NumericRuntype<number> {
    constructor() {
        super("number");
    }
}

export class IntegerRuntype extends NumericRuntype<number> {
    constructor() {
        super("integer");
        this.constraint((value) => Number.isInteger(value) || "should be a valid integer");
    }
}

export class FloatRuntype extends NumericRuntype<number> {
    constructor() {
        super("float");
    }
}
