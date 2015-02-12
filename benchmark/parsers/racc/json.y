class LL::BenchmarkParser::JSONRacc

token T_LCURLY T_RCURLY T_STRING T_COLON T_COMMA T_INT

options no_result_var

rule
  object
    : T_LCURLY pairs T_RCURLY { val[1] }
    ;

  pairs
    : pair
      {
        val[0]
      }
    | pair T_COMMA pairs
      {
        new_hash = val[0]

        val[2].each do |key, value|
          new_hash[key] = value
        end

        new_hash
      }
    ;

  pair
    : string T_COLON value { {val[0] => val[2]} }
    ;

  value
    : string  { val[0] }
    | integer { val[0] }
    | object  { val[0] }
    ;

  string
    : T_STRING { val[0] }
    ;

  integer
    : T_INT { val[0].to_i }
    ;
end

---- inner

  def yield_next_token
    yield [:T_LCURLY, '{']
    yield [:T_STRING, 'name']
    yield [:T_COLON, ':']
    yield [:T_STRING, 'Alice']
    yield [:T_COMMA, ',']
    yield [:T_STRING, 'age']
    yield [:T_COLON, ':']
    yield [:T_INT, 28]
    yield [:T_RCURLY, '}']
    yield [false, false]
  end

  def parse
    return yyparse(self, :yield_next_token)
  end

# vim: set ft=racc:
