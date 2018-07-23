import { AnyType, RequiredRuntype, ErrorThrower } from "./runtype";
import { Helpers } from "./helpers";

export class TupleRuntype<TS extends AnyType[], T extends Array<any>> extends RequiredRuntype<T> {
    constructor(protected innerTypes: TS) {
        super("object", `tuple of [${innerTypes.map(type => type.metadata.runtimeType).join(", ")}]`);

        this.constraint((array) => Array.isArray(array) || `should be a ${this.metadata.runtimeType}, not an object`);
        this.constraint((array) => (array.length === innerTypes.length) || `has ${array.length} elements but it should have exactly ${this.innerTypes.length}`);
    }

    decode(value: any, thrower: ErrorThrower = Error, attributeName?: string): T {
        const array: T = super.decode(value, thrower, attributeName);
        if (array) {
            const results = new Array<any>(this.innerTypes.length);
            for (let i = 0; i < array.length; i++) {
                try {
                    results[i] = this.innerTypes[i].decode(array[i], Error, "");
                } catch (err) {
                    throw new thrower(Helpers.formatErrorMessage(attributeName, `is a tuple, but its element at position ${i} is invalid because ${err.message}`));
                }
            }

            return results as any;
        } else {
            return array;
        }
    }

}
