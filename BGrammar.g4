grammar BGrammar;

// Using ';' is completely up to you
// but you can either use it only
// ONCE or NOT at all
start
    :
    (
            COMMENT
        |   (define_class ';'?)
        |   (import_libs ';'?)
        |   (define_function ';'?)
        |   (define_variable ';'?)
        |   (assign_variable ';'?)
        |   (iota ';'?)
    )*  (main_part) EOF
    ;

// Main function
main_part
    :
    'main'
    '{'
        function_code*
    '}'
    ;

// This includes main part of this grammar
// which consists of every block of code we need
// such as: defining variables, functions,
// classes and ... . It also includes flowing
// control commands such as for/while loops,
// if clause and so on.
function_code
    :
        COMMENT
        |   (define_variable ';'?)
        |   (assign_variable ';'?)
        |   (while_loop ';'?)
        |   (for_loop ';'?)
        |   (if_clause ';'?)
        |   (switch_case ';'?)
        |   (iota ';'?)
        |   (return_statement ';'?)
    ;
class_name: IDENTIFIER ;
parent_class_name: IDENTIFIER ;
interface_name: IDENTIFIER ;
library_name:   IDENTIFIER ;
function_name:  IDENTIFIER ;
name:   IDENTIFIER ;
iterator_name: IDENTIFIER ;
decimal_num:    INT;
floating_num:   FLOAT ;
scientific_num: SCIENTIFIC_NOTATION ;
step:   '-'? decimal_num ; // Step can be either positive or negative
return_statement:   'return' (value | name) ;
import_libs
    :
        name  '='  'require'  library_name
    |   name  '='  'from'  library_name  'require' function_name
    ;
data_type
    :
        'int'
    |   'float'
    ;
define_function
    :
        function_name  '=' '(' func_args  ')'
        '=>' '{'
        function_code*
        '}'
    ;
func_args:  (data_type name  ',' )* data_type  name ;
define_class
    :
        'class' class_name ('extends' parent_class_name)?
        ('implements' (interface_name ',')* interface_name)?
        '{'
        (function_code | define_function)*
        '}'
    ;

// Values can either be positive or negative
value
    :
        '-'? decimal_num
    |   '-'? floating_num
    |   '-'? scientific_num
    ;
variable_range: '[' decimal_num ':' decimal_num ']' ;
expr
    :
        expr '**' expr
    |   '~' expr
    |   expr ('*'|'/'|'//'|'%') expr
    |   expr ('+'|'-') expr
    |   '###' expr
    |   expr ('<<'|'>>') expr
    |   expr ('&'|'^'|'|') expr
    |   decimal_num
    |   floating_num
    |   name
    |   '(' expr ')'
    ;
condition_notation
    :
        expr ('=='|'!='|'<>') expr
    |   expr ('<'|'>'|'<='|'>=') expr
    ;
switch_case
    :
        'switch' '(' name ')'
        '{'
            (case_)+
            (default_)?
        '}'
    ;
case_
    :
        'case' (name| INT | FLOAT) ':'
        function_code*
        ('break' ';'?)?
    ;
default_
    :
        'default' ':'
        function_code*
        ('break' ';'?)?
    ;
while_loop
    :
        'while'
        '('  (condition) ( or_and (condition))* ')'
        '{'
            function_code*
        '}'
    ;
for_loop
    :
        'for'
    (
        '(' name 'in' variable_range 'step' step')'
    |   '(' 'auto' name 'in' iterator_name ')'
    )
        '{'
            function_code*
        '}'
    ;
if_clause
    :
        if_structure
        else_if_structure*
        else_structure?
    ;
if_structure
    :
        'if'
        '(' (condition) (or_and condition)* ')'
        '{'
            (function_code* | 'break' ';'?)
        '}'
    ;
else_if_structure
    :
        'else if'
        '(' (condition) (or_and condition)* ')'
        '{'
            (function_code* | 'break' ';'?)
        '}'
    ;
else_structure
    :
        'else'
        '{'
            (function_code* | 'break' ';'?)
        '}'
    ;
condition:  'not'? (condition_notation | BOOL_CONST) ;
or_and
    :
        'and'
    |   'or'
    ;
define_variable
    :
        ('let' | 'const')
        (
            (data_type name ('=' (value | '-'? name | expr))? (',' name ('=' (value | '-'? name | expr))?)*)
        |   (data_type name '=' (name '=')* (value | '-'? name | expr))
        |   (data_type '[' ']' name ('=' (name | name variable_range))? (',' name ('=' (name | name variable_range))?)*)
        |   (data_type '[' ']' name '=' (name '=')* (name | name variable_range))
        )
    ;
assign_variable
    :
        name assign_sign
        (
            value
            |   '-'?name
            |   name variable_range
            |   expr
        )
    ;
assign_sign
    :
        (
            '='
        |   '**='
        |   '/='
        |   '//='
        |   '*='
        |   '%='
        |   '-='
        |   '+='
        )
    ;
iota
    :
        'iota' name
        '('
            name '=' 'iota' ';'?
            (name)*
        ')'
    ;
BOOL_CONST
    :
        'TRUE'
    |   'FALSE'
    ;
IDENTIFIER:   [a-zA-Z]([a-zA-Z0-9] | '_')+; // Written like this to have at least 2 characters
WS: [ \t\r\n]+ -> skip ; // Handle white spaces
INT
    :
        [0]
    |   [1-9][0-9]* ;
FLOAT:  INT '.' INT;
SCIENTIFIC_NOTATION:    ([1-9]'.'INT) ('e-'|'e+') INT ;

// Multi-line comment:  ## ... ##
// Single-line comment: \\ ...
COMMENT
    :
    (
        '##' ~['##']* '##'
    |   '\\' ~[\r\n]* '\n'
    ) -> skip
    ;
