export class Helpers {

    static formatType(typeName: string): string {
        return "aeiouAEIOU".includes(typeName[0]) ? `an ${typeName}` : `a ${typeName}`;
    }

    static pluralize(sentence: string): string {
        const words = sentence.split(" ");
        return words.map((word, index) => (index === 0) ? word + "s" : word).join(" ");
    }

    static formatErrorMessage(attributeName: string | undefined, error: string): string {
        if (attributeName === undefined) {
            return `payload ${error}`;
        } else if (attributeName === "") {
            return error;
        } else {
            return `attribute <${attributeName}> ${error}`;
        }
    }

}
