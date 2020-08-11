# jawk

awk for JSON.

## Install

Run `make install` as root to install `jawk` to `/usr/local/bin`.

or

Copy the `jawk` file to somewhere in your `PATH`.

## Examples

```shell
$ echo '{"age":10}' | jawk '{print _["age"]}'
10

$ echo '{"person":{"name":"Jason"}}' | jawk '{print _["person","name"]}'
Jason

$ echo '[4,2,0]' | jawk '{while (++i <= _["length"]) print _[i]}'
4
2
0

$ echo '[{"x":6},{"x":7}]' | jawk '{while (++i <= _["length"]) print _[i,"x"]}'
6
7

$ printf '{"x":6}\n{"x":7}\n' | jawk '{print _["x"]}'
6
7

$ echo '{"name":{"first":"Jason"},"age":25}' | jawk '{
	keys(o); for (k in o) print k, _[o[k],JSON]
}'
name {"first":"Jason"}
age 25

$ echo '{"name":"Jason"}' | jawk '{print _["name",JSON]}'
"Jason"

# Try it with real data!
curl -Ls https://api.github.com/repos/onetrueawk/awk |
jawk '{print "id:", _["id"], "owner.id:", _["owner","id"]}'

curl -Ls https://api.github.com/repos/onetrueawk/awk/commits |
jawk '{
	while (++i <= _["length"]) {
		sha = _[i,"sha"]
		message = _[i,"commit","message"]
		l = index(message, "\n")
		print sha, substr(message, 1, l ? l - 1 : 50)
	}
}'

curl -Ls https://api.github.com/repos/onetrueawk/awk/commits |
jawk '{while (++i <= _["length"]) printf("{\"sha\":%s}\n",_[i,"sha",JSON])}'
```

## Details

jawk uses [JSON.awk](https://github.com/step-/JSON.awk) to parse the JSON file.
It then makes available each JSON object using the `_` variable. `jawk`
programs are `awk` programs, and all `awk` features and functions are
available. Nested fields can be accessed using standard awk indexing (eg.
`_["foo","bar"]`). Some conversions are done: the value `true` is converted to
1, `false` is converted to 0 and `null` is converted to `""`. Arrays are
1-indexed.

## Properties

### _[p]

Return the value of the object at path `p` if it's a primitive, or `p` if it's
an object or array. If the root object is a primitive, `_[0]` returns its
value.

### _[[p,]"length"]

Return the length of the array at path `p`, or the root array if `p` is
omitted.

### _[[p,]JSON]

Return the JSON form of the object at path `p`, or the root object if `p` is
omitted.

### _[[p,]TYPE]

Return the type of the object at path `p`, or the root object if `p` is
omitted. The result will be one of `boolean`, `null`, `array`, `object`,
`string` or `number`.

## Functions

### keys(a[, o])

Populate the array `a` with the keys of the object at path `o` such that `a[k]
= p` where `k` is the key and `p` is its full path. The path can then be passed
to `_` to retrieve its value. If `o` isn't provided, `a` is populated with the
keys and paths of the root object. Returns the number of keys.

## Development

Make changes to `src/jawk.sh` and run `make` to produce `jawk`. Run `make -B
test` to test changes.
