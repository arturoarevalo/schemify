import { Helpers } from "./helpers";

export type ErrorThrower = { new(error: string): any };
export type RuntypeConstraint<T> = (value: T, thrower: ErrorThrower, attributeName?: string) => boolean | string;
export type RuntypePreprocessor<T> = (value: T) => T;

export class RuntypeMetadata<T> {
    internalType: T;
    constraints: RuntypeConstraint<T>[];
    preprocessors: RuntypePreprocessor<T>[];
    required: boolean;
    nullable: boolean;
    emptiable: boolean;
    staticType: string;
    runtimeType: string;
    default: T | undefined;

    constructor(staticType: string, runtimeType?: string) {
        this.constraints = [];
        this.preprocessors = [];
        this.required = true;
        this.nullable = false;
        this.emptiable = false;
        this.default = undefined;
        this.staticType = staticType;
        this.runtimeType = runtimeType || staticType;
    }
}

export type AnyType = Runtype<any>;
export type TypeOf<T extends AnyType> = T["metadata"]["internalType"];
export interface AnyProperties {
    [key: string]: AnyType;
}
export type RequiredKeys<T> = { [P in keyof T]: T[P] extends RequiredRuntype<any> ? P : never }[keyof T];
export type OptionalKeys<T> = { [P in keyof T]: T[P] extends RequiredRuntype<any> ? never : P }[keyof T];
export type TypeOfProperties<T extends AnyProperties> =
    { [K in RequiredKeys<T>]: TypeOf<T[K]> } & { [K in OptionalKeys<T>]?: TypeOf<T[K]> };

export abstract class Runtype<T> {
    readonly metadata: RuntypeMetadata<T>;

    constructor(staticType: string, runtimeType?: string) {
        this.metadata = new RuntypeMetadata<T>(staticType, runtimeType);
    }

    constraint(constraint: RuntypeConstraint<T>): this {
        this.metadata.constraints.push(constraint);
        return this;
    }

    preprocess(preprocessor: RuntypePreprocessor<T>): this {
        this.metadata.preprocessors.push(preprocessor);
        return this;
    }

    nullable(): this {
        this.metadata.nullable = true;
        return this;
    }

    default(value: T): this {
        this.metadata.default = value;
        return this;
    }

    protected isEmpty(value: T): boolean {
        return false;
    }

    decode(value: any, thrower: ErrorThrower = Error, attributeName?: string): T {
        if (this.metadata.preprocessors.length > 0) {
            for (const preprocessor of this.metadata.preprocessors) {
                value = preprocessor(value);
            }
        }

        if (value === undefined) {
            if (this.metadata.required) {
                throw new thrower(Helpers.formatErrorMessage(attributeName, `is required, but is undefined and should be ${Helpers.formatType(this.metadata.runtimeType)}`));
            } else if (this.metadata.default !== undefined) {
                return this.metadata.default;
            }
        } else if (value === null) {
            if (!this.metadata.nullable) {
                throw new thrower(Helpers.formatErrorMessage(attributeName, `cannot be null and should be ${Helpers.formatType(this.metadata.runtimeType)}`));
            }
        } else if (this.metadata.staticType !== undefined && this.metadata.staticType !== typeof value) {
            throw new thrower(Helpers.formatErrorMessage(attributeName, `is ${Helpers.formatType(typeof value)} and should be ${Helpers.formatType(this.metadata.runtimeType)}`));
        } else {
            if (this.isEmpty(value)) {
                if (!this.metadata.emptiable) {
                    throw new thrower(Helpers.formatErrorMessage(attributeName, `is required, but is empty and should be ${Helpers.formatType(this.metadata.runtimeType)}`));
                }
            } else {
                for (const constraint of this.metadata.constraints) {
                    const result = constraint(value, thrower, attributeName);

                    if (typeof result === "boolean") {
                        if (!result) {
                            throw new thrower(Helpers.formatErrorMessage(attributeName, "has an invalid value"));
                        }
                    } else {
                        throw new thrower(Helpers.formatErrorMessage(attributeName, result));
                    }
                }
            }
        }

        return value;
    }

    is(value: any): value is T {
        try {
            this.decode(value);
            return true;
        } catch (error) {
            return false;
        }
    }
}

export abstract class RequiredRuntype<T> extends Runtype<T> {
    optional(): OptionalRuntype<T> {
        this.metadata.required = false;
        return this;
    }
}

export abstract class OptionalRuntype<T> extends Runtype<T | undefined> {
}
