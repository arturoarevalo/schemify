schema = require "../src/schemify"
assert = require "assert"

describe "array schema", () ->

    describe "without default value", () ->

        describe "validates as expected", () ->

            check = (param) ->
                schema.array.check param

            it "empty (NULL) values", (done) ->
                assert.strictEqual true, check null
                done()

            it "empty (undefined) values", (done) ->
                assert.strictEqual true, check undefined
                done()

            it "integers", (done) ->
                assert.strictEqual false, check 1234
                done()

            it "floats", (done) ->
                assert.strictEqual false, check 1234.1234
                done()

            it "strings", (done) ->
                assert.strictEqual false, check "1234.1234"
                done()

            it "booleans", (done) ->
                assert.strictEqual false, check true
                done()

            it "arrays", (done) ->
                assert.strictEqual true, check []
                done()

            it "objects", (done) ->
                assert.strictEqual false, check {a:1}
                done()



        describe "creates as expected", () ->

            check = (param) ->
                schema.array.createNew param

            it "empty (NULL) values", (done) ->
                assert.strictEqual null, check null
                done()

            it "empty (undefined) values", (done) ->
                assert.strictEqual null, check undefined
                done()

            it "integers", (done) ->
                assert.strictEqual null, check 1234
                done()

            it "floats", (done) ->
                assert.strictEqual null, check 1234.1234
                done()

            it "strings", (done) ->
                assert.strictEqual null, check "1234.1234"
                done()

            it "booleans", (done) ->
                assert.strictEqual null, check true
                done()

            it "arrays", (done) ->
                assert.deepEqual ["a"], check ["a"]
                done()

            it "objects", (done) ->
                assert.strictEqual null, check {a:1}
                done()



    describe "with a default value", () ->

        describe "validates as expected", () ->

            defaultValue = [1, 2, "a", "b"]
            check = (param) ->
                schema.array.default(defaultValue).check param

            it "empty (NULL) values", (done) ->
                assert.strictEqual true, check null
                done()

            it "empty (undefined) values", (done) ->
                assert.strictEqual true, check undefined
                done()

            it "integers", (done) ->
                assert.strictEqual false, check 1234
                done()

            it "floats", (done) ->
                assert.strictEqual false, check 1234.1234
                done()

            it "strings", (done) ->
                assert.strictEqual false, check "1234.1234"
                done()

            it "booleans", (done) ->
                assert.strictEqual false, check true
                done()

            it "arrays", (done) ->
                assert.strictEqual true, check []
                done()

            it "objects", (done) ->
                assert.strictEqual false, check {a:1}
                done()



        describe "creates as expected", () ->

            defaultValue = [1, 2, "a", "b"]
            check = (param) ->
                schema.array.default(defaultValue).createNew param

            it "empty (NULL) values", (done) ->
                assert.deepEqual defaultValue, check null
                done()

            it "empty (undefined) values", (done) ->
                assert.deepEqual defaultValue, check undefined
                done()

            it "integers", (done) ->
                assert.deepEqual defaultValue, check 1234
                done()

            it "floats", (done) ->
                assert.deepEqual defaultValue, check 1234.1234
                done()

            it "strings", (done) ->
                assert.deepEqual defaultValue, check "test string"
                done()

            it "booleans", (done) ->
                assert.deepEqual defaultValue, check true
                done()

            it "arrays", (done) ->
                assert.deepEqual ["1", "2", 1, 2, "a"], check ["1", "2", 1, 2, "a"]
                done()

            it "objects", (done) ->
                assert.deepEqual defaultValue, check {a:1}
                done()



    describe "marked as required", () ->

        describe "validates correctly", () ->

            check = (param) ->
                schema.array.required.check param

            it "null and undefined values", (done) ->
                assert.strictEqual false, check null
                assert.strictEqual false, check undefined
                done()

            it "empty arrays", (done) ->
                assert.strictEqual true, check []
                done()

            it "nonempty arrays", (done) ->
                assert.strictEqual true, check [1,2,3,4]
                done()


    describe "marked as nonempty", () ->

        describe "validates correctly", () ->

            check = (param) ->
                schema.array.nonempty.check param

            it "null and undefined values", (done) ->
                assert.strictEqual false, check null
                assert.strictEqual false, check undefined
                done()

            it "empty arrays", (done) ->
                assert.strictEqual false, check []
                done()

            it "nonempty arrays", (done) ->
                assert.strictEqual true, check [1,2,3,4]
                done()


    describe "with primitive element validator", () ->

        describe "validates correctly", () ->

            check = (param) ->
                schema.array.of(schema.integer).check param

            it "arrays of valid elements", (done) ->
                assert.strictEqual true, check [1,2,3,4,5]
                done()

            it "arrays with invalid elements", (done) ->
                assert.strictEqual false, check [1,2,"3",4,5]
                done()


        describe "creates correctly", () ->

            check = (param) ->
                schema.array.of(schema.integer).createNew param

            it "null and undefined values", (done) ->
                assert.deepEqual null, check null
                assert.deepEqual null, check undefined
                done()

            it "arrays of valid elements", (done) ->
                assert.deepEqual [1,2,3,4,5], check [1,2,3,4,5]
                done()

            it "arrays with invalid elements", (done) ->
                console.log check [1,2,"3",4,5]
                assert.deepEqual [1,2,4,5], check [1,2,"3",4,5]
                done()
                
