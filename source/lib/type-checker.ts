
class TypeChecker {
    static isEmpty(value: any): boolean {
        return (value === null) || (value === undefined);
    }

    static isNumeric(value: any): boolean {
        return typeof value === 'number';
    }

    static isInteger(value: any): boolean {
        return (value.toString() as string).match(/^[0-9]*$/) && TypeChecker.isStrictInteger(value);
    }

    static isStrictInteger(value: any): boolean {
        return Number.isInteger(value);
    }

    static isFloat(value: any): boolean {
        return TypeChecker.isNumeric(value) && parseFloat(value).toString() === value.toString();
    }

    static isString(value: any): boolean {
        return typeof value === 'string';
    }

    static isBoolean(value: any): boolean {
        return typeof value === 'boolean';
    }

    static isArray(value: any): boolean {
        return Array.isArray(value);
    }
}

export default TypeChecker;
