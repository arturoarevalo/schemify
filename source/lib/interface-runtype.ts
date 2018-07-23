import { Runtype, RequiredRuntype, AnyProperties, TypeOfProperties, ErrorThrower } from "./runtype";

export class InterfaceRuntype<T extends AnyProperties> extends RequiredRuntype<TypeOfProperties<T>> {
    protected keys: string[];
    protected requiredKeys: string[];
    protected runtypes: Runtype<any>[];

    constructor(obj: T) {
        const keys: string[] = [];
        const runtypes: Runtype<any>[] = [];

        for (const key of Object.getOwnPropertyNames(obj)) {
            if (obj[key] instanceof Runtype) {
                keys.push(key);
                runtypes.push(obj[key]);
            }
        }

        const requiredKeys = keys.filter((key, i) => runtypes[i].metadata.required);
        const optionalKeys = keys.filter((key, i) => !runtypes[i].metadata.required);

        let runtimeDescription: string;
        if (requiredKeys.length && optionalKeys.length) {
            runtimeDescription = `object with the required attributes <${requiredKeys.join(", ")}> and, optionally <${optionalKeys.join(", ")}>`;
        } else if (requiredKeys.length && !optionalKeys.length) {
            runtimeDescription = `object with the required attributes <${requiredKeys.join(", ")}>`;
        } else if (!requiredKeys.length && optionalKeys.length) {
            runtimeDescription = `object with the optional attributes <${requiredKeys.join(", ")}>`;
        } else {
            runtimeDescription = "object";
        }

        super("object", runtimeDescription);

        this.keys = keys;
        this.requiredKeys = requiredKeys;
        this.runtypes = runtypes;
    }

    decode(value: any, thrower: ErrorThrower = Error, attributeName?: string): TypeOfProperties<T> {
        const obj = super.decode(value, thrower, attributeName);

        if (obj) {
            const prefix = (attributeName !== undefined && attributeName !== "") ? attributeName + "." : "";
            const newObj: any = {};

            /*
            const missingKeys = [];
            for (let i = 0; i < this.requiredKeys.length; i++) {
                const key = this.requiredKeys[i];
                if (value[key] === undefined && ) {
                    missingKeys.push(key);
                }
            }

            if (missingKeys.length > 1) {
                throw new thrower(Helpers.formatErrorMessage(attributeName, `is missing the required attributes <${missingKeys.join(', ')}>`));
            }
            */

            for (let i = 0; i < this.keys.length; i++) {
                const key = this.keys[i];
                const runtype = this.runtypes[i];
                newObj[key] = runtype.decode((obj as any)[key], thrower, prefix + key);
            }

            return newObj;
        } else {
            return obj;
        }
    }

}
