#!/bin/sh

. test/test.sh

PATH=.:$PATH

test "print"
out=$(printf '{\n"age":10\n}' | jawk '{print}')
[ "$out" = '{"age":10}' ]

test "extract field"
out=$(echo '{"age":10}' | jawk '{print _["age"]}')
[ "$out" = "10" ]

test "extract nested field"
out=$(echo '{"person":{"name":"Jason"}}' | jawk '{print _["person","name"]}')
[ "$out" = "Jason" ]

test "array"
out=$(echo '[4,2,0]' | jawk '{while (++i <= _["length"]) print _[i]}')
[ "$out" = "$(printf '%s\n' 4 2 0)" ]

test "array of objects"
out=$(echo '[{"x":6},{"x":7}]' | jawk '{
	while (++i <= _["length"]) print _[i,"x"]
}')
[ "$out" = "$(printf '%s\n' 6 7)" ]

test "newline-delimited objects"
out=$(printf '{"x":6}\n{"x":7}\n' | jawk '{print _["x"]}')
[ "$out" = "$(printf '%s\n' 6 7)" ]

test "keys(a) object"
out=$(echo '{"name":{"first":"Jason"},"age":25,"":"x"}' | jawk '{
	print keys(o); for (k in o) print k, _[o[k],JSON] | "sort"
}')
[ "$out" = "$(printf '%s\n' 3 ' "x"' 'age 25' 'name {"first":"Jason"}')" ]

test "keys(a,o) object"
out=$(echo '{"name":{"first":"Jason"},"age":25}' | jawk '{
	print keys(o,"name"); for (k in o) print k, _[o[k],JSON] | "sort"
}')
[ "$out" = "$(printf '%s\n' 1 'first "Jason"')" ]

test "keys(a,\"\") object"
out=$(echo '{"":{"name":"Jason"},"age":25}' | jawk '{
	print keys(o,""); for (k in o) print k, _[o[k],JSON] | "sort"
}')
[ "$out" = "$(printf '%s\n' 1 'name "Jason"')" ]

test "keys(a) array"
out=$(echo '["first","second"]' | jawk '{
	print keys(a); for (i in a) print i, _[a[i],JSON] | "sort"
}')
[ "$out" = "$(printf '%s\n' 2 '1 "first"' '2 "second"')" ]

test "keys(a,o) array"
out=$(echo '["first",["second","third"]]' | jawk '{
	print keys(a,2); for (i in a) print i, _[a[i],JSON] | "sort"
}')
[ "$out" = "$(printf '%s\n' 2 '1 "second"' '2 "third"')" ]

test "keys(a,\"\") array"
out=$(echo '{"":["first","second"]}' | jawk '{
	print keys(a,""); for (i in a) print i, _[a[i],JSON] | "sort"
}')
[ "$out" = "$(printf '%s\n' 2 '1 "first"' '2 "second"')" ]

test "_[p,JSON]"
out=$(echo '{"name":"Jason"}' | jawk '{print _["name",JSON]}')
[ "$out" = '"Jason"' ]

test "_[JSON]"
out=$(echo '{"":"Jason"}' | jawk '{print _[JSON]}')
[ "$out" = '{"":"Jason"}' ]

test "_[\"\",JSON]"
out=$(echo '{"":"Jason"}' | jawk '{print _["",JSON]}')
[ "$out" = '"Jason"' ]

test "_[TYPE]"
out=$(echo '{"":"Jason"}' | jawk '{print _[TYPE]}')
[ "$out" = 'object' ]

test "_[\"\",TYPE]"
out=$(echo '{"":"Jason"}' | jawk '{print _["",TYPE]}')
[ "$out" = 'string' ]

test "_[p,TYPE] == \"number\""
out=$(echo '{"x":1}' | jawk '{print _["x",TYPE]}')
[ "$out" = "number" ]

test "_[p,TYPE] == \"boolean\""
out=$(echo '{"x":true}' | jawk '{print _["x",TYPE]}')
[ "$out" = "boolean" ]

test "_[p,TYPE] == \"string\""
out=$(echo '{"x":"hello"}' | jawk '{print _["x",TYPE]}')
[ "$out" = "string" ]

test "_[p,TYPE] == \"array\""
out=$(echo '{"x":[]}' | jawk '{print _["x",TYPE]}')
[ "$out" = "array" ]

test "_[p,TYPE] == \"object\""
out=$(echo '{"x":{}}' | jawk '{print _["x",TYPE]}')
[ "$out" = "object" ]

test "_[p,TYPE] == \"null\""
out=$(echo '{"x":null}' | jawk '{print _["x",TYPE]}')
[ "$out" = "null" ]

test "_[\"\"]"
out=$(echo '{"":"Jason"}' | jawk '{print _[""]}')
[ "$out" = 'Jason' ]

test "_[0]"
out=$(printf '20\n{"0":5}' | jawk '{print _[0]}')
[ "$out" = "$(printf '%s\n' 20 5)" ]

test "single quote in string"
out=$(echo '{"x":"hello'\''friend"}' | jawk '{printf("%s",_["x"])}')
[ "$out" = "hello'friend" ]

test "double quote in string"
out=$(printf "%s" '{"x":"hello\"friend"}' | jawk '{printf("%s",_["x"])}')
[ "$out" = "hello\"friend" ]

test "backslash double quote in string"
out=$(printf "%s" '{"x":"hello\\\"friend"}' | jawk '{printf("%s",_["x"])}')
[ "$out" = "hello\\\"friend" ]

test "backtick in string"
out=$(echo '{"x":"hello`friend"}' | jawk '{printf("%s",_["x"])}')
[ "$out" = 'hello`friend' ]

test "dollar sign in string"
out=$(echo '{"x":"hello$friend"}' | jawk '{printf("%s",_["x"])}')
[ "$out" = 'hello$friend' ]

test "escapes in string"
out=$(printf "%s" '{"x":"\b\f\n\r\t\"\/\\"}' | jawk '{printf("%s",_["x"])}')
[ "$out" = "$(printf '\b\f\n\r\t"/\\')" ]

test "unicode in string"
out=$(printf "%s" '"\u0041\u0636\uFe10\uD801\uDC37"' | jawk '{print _[0]}')
[ "$out" = "$(echo 'Aض︐𐐷')" ]

test "trailing newline in string"
out=$(printf '%s' '{"x":"\t\n"}' | jawk '{printf("%s",_["x"])}' && echo .)
expect=$(printf '\t\n' && echo .)
[ "${out%.}" = "${expect%.}" ]

test "no trailing newline in string"
out=$(printf '%s' '{"x":"\t"}' | jawk '{printf("%s",_["x"])}' && echo .)
[ "${out%.}" = "$(printf '\t')" ]

test "no trailing newline in string (escaped)"
out=$(printf '%s' '{"x":"\\n"}' | jawk '{printf("%s",_["x"])}' && echo .)
[ "${out%.}" = "$(printf '\\n')" ]

test "blank line in JSON"
out=$(printf '{"a":1,\n\n"b":2}' | jawk '{print _["b"]}')
[ "$out" = '2' ]

test "trailing space in JSON"
out=$(printf '{"a":1, \n"b":2}' | jawk '{print _["b"]}')
[ "$out" = '2' ]

test "NR"
out=$(printf '{\n"age":10\n}\n{\n"age":12\n}' | jawk '{print NR}')
[ "$out" = "$(printf '1\n2')" ]

test "files"
printf '{"age":10}\n{"age":20}' >test/test.json
printf '{"age":30}\n{"age":40}' >test/test2.json
out=$(jawk \
	'BEGIN{print ARGC,ARGV[0],ARGV[1],ARGV[2]}
	{print ARGC,FILENAME,NR,FNR,_["age"]}' \
		test/test.json test/test2.json
	rm test/test*.json
)
[ "$out" = "$(printf '%s\n' \
'3 jawk test/test.json test/test2.json' \
'3 test/test.json 1 1 10' \
'3 test/test.json 2 2 20' \
'3 test/test2.json 3 1 30' \
'3 test/test2.json 4 2 40')" ]

test "trailing comma in array"
out=$(echo '[1,]' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = 'jawk: unexpected token ]' ]

test "trailing comma in object"
out=$(echo '{"x":1,}' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = 'jawk: unexpected token }' ]

test "unexpected token"
out=$(echo '"' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = 'jawk: unexpected token "' ]

test "unexpected token in array separator"
out=$(echo [1s | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = "jawk: unexpected token s" ]

test "unexpected token in object key"
out=$(echo '{"' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = 'jawk: unexpected token "' ]

test "unexpected token in object key (number)"
out=$(echo '{12:34}' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = 'jawk: unexpected token 12' ]

test "unexpected token in object colon"
out=$(echo '{"x"c' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = "jawk: unexpected token c" ]

test "unexpected token in object separator"
out=$(echo '{"x":1s' | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = "jawk: unexpected token s" ]

test "unexpected EOF"
out=$(echo [ | jawk '{print}' 2>test/err; echo $?)
err=$(cat test/err; rm test/err)
[ "$out" = 1 ]
[ "$err" = "jawk: unexpected EOF" ]
