import { TypeOf, AnyType, RequiredRuntype, ErrorThrower } from "./runtype";
import { Helpers } from "./helpers";

export class ArrayRuntype<T extends AnyType> extends RequiredRuntype<TypeOf<T>[]> {
    constructor(protected innerType: T) {
        super("object", `array of ${Helpers.pluralize(innerType.metadata.runtimeType)}`);

        this.constraint((array) => Array.isArray(array) || `should be an ${this.metadata.runtimeType}, not an object`);
    }

    decode(value: any, thrower: ErrorThrower = Error, attributeName?: string): TypeOf<T>[] {
        const array: TypeOf<T>[] = super.decode(value, thrower, attributeName);
        if (array) {
            const results = new Array<TypeOf<T>>(array.length);
            for (let i = 0; i < array.length; i++) {
                try {
                    results[i] = this.innerType.decode(array[i], Error, "");
                } catch (err) {
                    throw new thrower(Helpers.formatErrorMessage(attributeName, `is an array, but its element at position ${i} is invalid because ${err.message}`));
                }
            }

            return results;
        } else {
            return array;
        }
    }

}
