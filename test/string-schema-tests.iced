schema = require "../src/schemify"
assert = require "assert"

describe "string schema", () ->

    describe "without default value", () ->

        describe "validates as expected", () ->

            check = (param) ->
                schema.string.check param

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
                assert.strictEqual true, check "1234.1234"
                done()

            it "booleans", (done) ->
                assert.strictEqual false, check true
                done()

            it "arrays", (done) ->
                assert.strictEqual false, check []
                done()

            it "objects", (done) ->
                assert.strictEqual false, check {a:1}
                done()



        describe "creates as expected", () ->

            check = (param) ->
                schema.string.createNew param

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
                assert.strictEqual "1234.1234", check "1234.1234"
                done()

            it "booleans", (done) ->
                assert.strictEqual null, check true
                done()

            it "arrays", (done) ->
                assert.strictEqual null, check []
                done()

            it "objects", (done) ->
                assert.strictEqual null, check {a:1}
                done()



    describe "with a default value", () ->

        describe "validates as expected", () ->

            defaultValue = "test string"
            check = (param) ->
                schema.string.default(defaultValue).check param

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
                assert.strictEqual true, check "1234.1234"
                done()

            it "booleans", (done) ->
                assert.strictEqual false, check true
                done()

            it "arrays", (done) ->
                assert.strictEqual false, check []
                done()

            it "objects", (done) ->
                assert.strictEqual false, check {a:1}
                done()



        describe "creates as expected", () ->

            defaultValue = "test default value"
            check = (param) ->
                schema.string.default(defaultValue).createNew param

            it "empty (NULL) values", (done) ->
                assert.strictEqual defaultValue, check null
                done()

            it "empty (undefined) values", (done) ->
                assert.strictEqual defaultValue, check undefined
                done()

            it "integers", (done) ->
                assert.strictEqual defaultValue, check 1234
                done()

            it "floats", (done) ->
                assert.strictEqual defaultValue, check 1234.1234
                done()

            it "strings", (done) ->
                assert.strictEqual "test string", check "test string"
                done()

            it "booleans", (done) ->
                assert.strictEqual defaultValue, check true
                done()

            it "arrays", (done) ->
                assert.strictEqual defaultValue, check []
                done()

            it "objects", (done) ->
                assert.strictEqual defaultValue, check {a:1}
                done()



