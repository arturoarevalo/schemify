import { AnyType, AnyProperties, TypeOf } from "./runtype";
import { StringRuntype, NumberRuntype, IntegerRuntype, FloatRuntype, BooleanRuntype } from "./core-runtypes";
import { ArrayRuntype } from "./array-runtype";
import { InterfaceRuntype } from "./interface-runtype";
import { TupleRuntype } from "./tuple-runtype";

export class Schema {
    static get string(): StringRuntype {
        return new StringRuntype();
    }

    static get boolean(): BooleanRuntype {
        return new BooleanRuntype();
    }

    static get number(): NumberRuntype {
        return new NumberRuntype();
    }

    static get integer(): IntegerRuntype {
        return new IntegerRuntype();
    }

    static get float(): FloatRuntype {
        return new FloatRuntype();
    }

    static array<T extends AnyType>(innerType: T): ArrayRuntype<T> {
        return new ArrayRuntype(innerType);
    }

    static tuple<T1 extends AnyType, T2 extends AnyType, T3 extends AnyType, T4 extends AnyType, T5 extends AnyType>(t1: T1, t2: T2, t3: T3, t4: T4, t5: T5):
        TupleRuntype<[T1, T2, T3, T4], [TypeOf<T1>, TypeOf<T2>, TypeOf<T3>, TypeOf<T4>, TypeOf<T5>]>;
    static tuple<T1 extends AnyType, T2 extends AnyType, T3 extends AnyType, T4 extends AnyType>(t1: T1, t2: T2, t3: T3, t4: T4):
        TupleRuntype<[T1, T2, T3, T4], [TypeOf<T1>, TypeOf<T2>, TypeOf<T3>, TypeOf<T4>]>;
    static tuple<T1 extends AnyType, T2 extends AnyType, T3 extends AnyType>(t1: T1, t2: T2, t3: T3):
        TupleRuntype<[T1, T2, T3], [TypeOf<T1>, TypeOf<T2>, TypeOf<T3>]>;
    static tuple<T1 extends AnyType, T2 extends AnyType>(t1: T1, t2: T2):
        TupleRuntype<[T1, T2], [TypeOf<T1>, TypeOf<T2>]>;
    static tuple<T1 extends AnyType>(t1: T1):
        TupleRuntype<[T1], [TypeOf<T1>]>;
    static tuple(...innerTypes: AnyType[]): TupleRuntype<AnyType[], any[]> {
        return new TupleRuntype(innerTypes);
    }

    static interface<T extends AnyProperties>(obj: T): InterfaceRuntype<T> {
        return new InterfaceRuntype(obj);
    }
}
