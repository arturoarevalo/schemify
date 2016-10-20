import 'mocha';
import 'should';

import TypeChecker from '../lib/type-checker';

describe('TypeChecker', () => {

    describe('#isEmpty', () => {
        it('should return true for null or undefined values', () => {
            TypeChecker.isEmpty(null).should.equal(true);
            TypeChecker.isEmpty(undefined).should.equal(true);
        });

        it('should return false for any other values', () => {
            TypeChecker.isEmpty(0).should.equal(false);
            TypeChecker.isEmpty(10).should.equal(false);
            TypeChecker.isEmpty(10.10).should.equal(false);
            TypeChecker.isEmpty('').should.equal(false);
            TypeChecker.isEmpty('1234').should.equal(false);
            TypeChecker.isEmpty({}).should.equal(false);
            TypeChecker.isEmpty({ value: 10 }).should.equal(false);
            TypeChecker.isEmpty(true).should.equal(false);
            TypeChecker.isEmpty(false).should.equal(false);
            TypeChecker.isEmpty([]).should.equal(false);
            TypeChecker.isEmpty([1, 2, 3, 4]).should.equal(false);
        });
    });

    describe('#isNumeric', () => {
        it('should return true for numeric values', () => {
            TypeChecker.isNumeric(0).should.equal(true);
            TypeChecker.isNumeric(-10).should.equal(true);
            TypeChecker.isNumeric(10.10).should.equal(true);
            TypeChecker.isNumeric(-10.10).should.equal(true);
        });

        it('should return false for any other values', () => {
            TypeChecker.isNumeric(null).should.equal(false);
            TypeChecker.isNumeric(undefined).should.equal(false);
            TypeChecker.isNumeric('').should.equal(false);
            TypeChecker.isNumeric('10').should.equal(false);
            TypeChecker.isNumeric(true).should.equal(false);
            TypeChecker.isNumeric(false).should.equal(false);
            TypeChecker.isNumeric([]).should.equal(false);
            TypeChecker.isNumeric({}).should.equal(false);
        });
    });
});
