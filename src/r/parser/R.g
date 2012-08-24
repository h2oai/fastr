grammar R;

options {
  language = Java ;
  memoize = true;
}

tokens {
  CALL;
  BRAKET;
  KW;
  PARMS;
  SEQUENCE;
  //NULL;
  MISSING_VAL;
  UPLUS;
  UMINUS;
  UTILDE;
 }

@header {
package r.parser;

import r.*;
import r.data.*;
import r.nodes.*;
import r.nodes.Call.*;
import r.nodes.UnaryOperation.*;
import r.nodes.BinaryOperation.*;
//Checkstyle: stop
}
@lexer::header {
package r.parser;
//Checkstyle: stop
}
@rulecatch {
    catch(RecognitionException re){
        throw re; // Stop at first error
    }
}
@lexer::rulecatch {
    catch(RecognitionException re){
        throw re; // Stop at first error ??? Doesn't work at all ??? why ??
    }
}
@members {
    public void display_next_tokens(){
        System.err.print("Allowed tokens: ");
        for(int next: next_tokens())
            System.err.print(tokenNames[next]);
        System.err.println("");
    }
    public int[] next_tokens(){
        return state.following[state._fsp].toArray();
    }
}

@lexer::members{
    public final int MAX_INCOMPLETE_SIZE = 100;
    int incomplete_stack[] = new int[MAX_INCOMPLETE_SIZE]; // TODO probably go for an ArrayList of int :S
    int incomplete_depth;
    
    @Override
    public void reportError(RecognitionException e) {
        throw new RuntimeException(e);
    }
}
@lexer::init{
    incomplete_depth = 0;
    incomplete_stack[incomplete_depth] = 0;
}

/****************************************************
** Known errors : 
** - foo * if(...) ... because of priority
** - No help support '?' & '??'
** - %OP% not very robust, maybe allow everything
** - More than 3x '.' are handled like ...
** - '.' is a valid id
** - Line break are tolerated in strings even without a '\' !!! (ugly)
** - EOF does'nt work with unbalanced structs
** - Improve the stack of balanced structures 
*****************************************************/

script returns [ASTNode v]
    @init{ArrayList<ASTNode> stmts = new ArrayList<ASTNode>();}
	@after{ $v = Sequence.create(stmts);}
	: n_ (s=statement {stmts.add(s);})*
	;
interactive returns [ASTNode v]
	: n_ e=statement {$v = e;}
	;
statement returns [ASTNode v]
	: e=expr_or_assign n {$v = e;}
	| '--EOF--' .* EOF
	;

n_	: (NEWLINE | COMMENT)*;
n	: (NEWLINE | COMMENT)+ | EOF | SEMICOLUMN n_;

expr_or_assign returns [ASTNode v]
	: a=alter_assign { v = a; }
	;
expr returns [ASTNode v]
	: a=assign { v = a; }
	;	
expr_wo_assign returns [ASTNode v]
	: w=while_expr { $v = w; }
	| i=if_expr { $v = i; }
	| f=for_expr { $v = f; }
	| r=repeat_expr { $v = r; }
	| fun=function { $v = fun; }
	| NEXT ((LPAR)=>LPAR n_ RPAR)? 
	| BREAK ((LPAR)=>LPAR n_ RPAR)? 
	;
sequence returns [ASTNode v]
    @init{ArrayList<ASTNode> stmts = new ArrayList<ASTNode>();}
    @after{ $v = Sequence.create(stmts);}
	: LBRACE n_ (e=expr_or_assign { stmts.add(e); } (n e=expr_or_assign { stmts.add(e); })* n?)?  RBRACE  
	;
assign returns [ASTNode v]
	: l=tilde_expr	
		( ARROW n_ r=expr { $v = AssignVariable.create(false, l, r);}
		| SUPER_ARROW n_ r=expr { $v = AssignVariable.create(true, l, r);}
		| a=RIGHT_ARROW n_ r=expr { $v = AssignVariable.create(false, r, l);}
		| a=SUPER_RIGHT_ARROW n_ r=expr { $v = AssignVariable.create(true, r, l);}
		| { $v = l;}
		)
	;
alter_assign returns [ASTNode v]
	: l=tilde_expr	
		( (ARROW)=>ARROW n_ r=expr_or_assign { $v = AssignVariable.create(false, l, r);}
		| (SUPER_ARROW)=>SUPER_ARROW n_ r=expr_or_assign {v = AssignVariable.create(true, l, r);}
		| (RIGHT_ARROW)=>a=RIGHT_ARROW n_ r=expr_or_assign { v = AssignVariable.create(false, r, l);}
		| (SUPER_RIGHT_ARROW)=>a=SUPER_RIGHT_ARROW n_ r=expr_or_assign {v = AssignVariable.create(true, r, l);}
		| (ASSIGN)=>a=ASSIGN n_ r=expr_or_assign {v = AssignVariable.create(false, l, r);}
		| { v = l;}
		)
	;
if_expr returns [ASTNode v]
	:
	IF n_ LPAR n_ cond=expr_or_assign n_ RPAR n_ t=expr_or_assign
	((n_ ELSE)=>(options {greedy=false; backtrack = true;}: n_ ELSE n_ f=expr_or_assign { v = If.create(cond, t, f);})
    | {v = If.create(cond, t);}
	)
	;
while_expr returns [ASTNode v]
	: WHILE n_ LPAR n_ c=expr_or_assign n_ RPAR n_ body=expr_or_assign { $v = Loop.create(c, body); }
	;
for_expr returns [ASTNode v]
	: FOR n_ LPAR n_ ID n_ IN n_ in=expr_or_assign n_ RPAR n_ body=expr_or_assign 
	;
repeat_expr returns [ASTNode v]
	: REPEAT n_ body=expr_or_assign {v = Loop.create(body); }
	;
function returns [ASTNode v]
@init { ArgumentList l = new ArgumentList.Default(); }
	: FUNCTION n_ LPAR  n_ (par_decl[l] (n_ COMMA n_ par_decl[l])* n_)? RPAR n_ body=expr_or_assign { $v = Function.create(l, body); } 
	;
par_decl [ArgumentList l]
	: i=ID { $l.add($i.text, null); } 
	| i=ID n_ ASSIGN n_ e=expr { $l.add($i.text, e); }
	| v=VARIATIC { $l.add($v.text, null); } // FIXME This is not quite good, since `...` is a special token
	                                 // For this reason let's call RSymbol.xxxx(...)
	// This 3 cases were not handled ... and everything was working fine
	// I add them for completeness, however note that the function create
	// with such a signature will always fail if they try to access them !
 	| VARIATIC n_ ASSIGN n_ expr
 	| DD
 	| DD n_ ASSIGN n_ expr
	;
tilde_expr returns [ASTNode v]
	: l=or_expr { $v = $l.v ;}
	( ((TILDE)=>TILDE n_ r=or_expr {$v = BinaryOperation.create(BinaryOperator.ADD, $tilde_expr.v, $r.v);} ))*
	;
or_expr returns [ASTNode v]
	: l=and_expr { $v = $l.v ;}
	(((or_operator)=>op=or_operator n_ r=and_expr {$v = BinaryOperation.create(op, $or_expr.v, $r.v);} ))*
	;
and_expr returns [ASTNode v]
	: l=comp_expr { $v = $l.v ;}
    (((and_operator)=>op=and_operator n_ r=comp_expr {$v = BinaryOperation.create(op, $and_expr.v, $r.v);} ))*
	;
comp_expr returns [ASTNode v]
	: l=add_expr { $v = $l.v ;}
    (((comp_operator)=>op=comp_operator n_ r=add_expr { $v = BinaryOperation.create(op, $comp_expr.v, $r.v);} ))*
    ;
add_expr returns [ASTNode v]
	: l=mult_expr { $v = $l.v ;}
	 (((add_operator)=>op=add_operator n_ r=mult_expr { $v = BinaryOperation.create(op, $add_expr.v, $r.v);} ))*
	;
mult_expr returns [ASTNode v]
	: l=operator_expr { $v = $l.v ;}
	(((mult_operator)=>op=mult_operator n_ r=operator_expr { $v = BinaryOperation.create(op, $mult_expr.v, $r.v);} ))*
	;
operator_expr returns [ASTNode v]
	: l=column_expr { $v = $l.v ;}
	(((OP)=>op=OP n_ r=column_expr { $v = null; } ))*  /* FIXME BinaryOperation.create(op, $operator_expr.v, $r.v); */ 
	;
column_expr returns [ASTNode v] // FIXME
	: l=power_expr { $v = $l.v ;}
	(((COLUMN)=>op=COLUMN n_ r=power_expr { $v = BinaryOperation.create(BinaryOperator.COLUMN, $column_expr.v, $r.v);} ))*
	;
power_expr returns [ASTNode v]
	: l=unary_expression {$v=$l.v;}
    (((power_operator)=>op=power_operator n_ r=power_expr { $v = BinaryOperation.create(op, $l.v, $r.v);} )
    |)
    ;
unary_expression returns [ASTNode v] // Does !~ work ? ..if yes I'm not sure to understand 
	: NOT n_ l=unary_expression {$v = UnaryOperation.create(UnaryOperator.NOT, l);}
	| PLUS n_ l=unary_expression {$v = UnaryOperation.create(UnaryOperator.PLUS, l);}
	| MINUS n_ l=unary_expression {$v = UnaryOperation.create(UnaryOperator.MINUS, l);}
	| TILDE n_ l=unary_expression {$v = UnaryOperation.create(UnaryOperator.MODEL, l);}
	| b=basic_expr { $v=b; }
	;
basic_expr returns [ASTNode v]
	: lhs=simple_expr { $v = lhs; }
	(((FIELD|AT|LBRAKET|LBB|LPAR)=>subset=expr_subset[v] { $v = subset; })+ | (n_)=>)
	;
expr_subset [ASTNode i] returns [ASTNode v]
    : (FIELD n_ name=id) { v = FieldAccess.create(FieldOperator.FIELD, i, name.getText()); } 
    | (AT n_ name=id)  { v = FieldAccess.create(FieldOperator.AT, i, name.getText()); } 
    | (LBRAKET subset=args RBRAKET) { v = Call.create(CallOperator.SUBSET, i, subset); }
    | (LBB subscript=args RBRAKET RBRAKET) { v = Call.create(CallOperator.SUBSCRIPT, i, subscript); }
    // Must use RBRAKET in`stead of RBB beacause of : a[b[1]]
    | (LPAR a=args RPAR)  { v = Call.create(i, a); } 
    //| { v = i; }
    ;
simple_expr returns [ASTNode v]
	: i=id { $v = AccessVariable.create(i.getText()); }
	| b=bool { $v = b; }
	| DD
	| NULL { $v = Constant.getNull(); }
	| num=number { $v = num; }
	| id NS_GET n_ id
	| id NS_GET_INT n_ id
	| LPAR n_ ea = expr_or_assign n_ RPAR { $v = ea; }
	| s = sequence { $v = s;}
	| e = expr_wo_assign { $v = e; }
	;
number returns [ASTNode n]
    : i=INTEGER { $n = Constant.createIntConstant($i.text); }
    | d=DOUBLE { $n = Constant.createDoubleConstant($d.text); }
    | c=COMPLEX { $n = Constant.createComplexConstant($c.text); }
    ;
id	returns [Token t]
    : i=ID { $t = $i; }
    | s=STRING { $t = $s; }
    | v=VARIATIC { $t = $v; }
    ;
bool returns [ASTNode v]
    : TRUE {$v = Constant.createBoolConstant(1); }
    | FALSE {$v = Constant.createBoolConstant(0); }
    | NA {$v = Constant.createBoolConstant(RLogical.NA); }
    ;
or_operator returns [BinaryOperator v]
	: OR          {$v = BinaryOperator.OR; }
 	| BITWISEOR   {$v = BinaryOperator.BITWISEOR; };
and_operator returns [BinaryOperator v]
	: AND          {$v = BinaryOperator.AND; }
	| BITWISEAND   {$v = BinaryOperator.BITWISEAND; };
comp_operator returns [BinaryOperator v]
	: GT {$v = BinaryOperator.GT; }
	| GE {$v = BinaryOperator.GE; }
	| LT {$v = BinaryOperator.LT; }
	| LE {$v = BinaryOperator.LE; }
	| EQ {$v = BinaryOperator.EQ; }
	| NE {$v = BinaryOperator.NE; };
add_operator returns [BinaryOperator v]
	: PLUS {$v = BinaryOperator.ADD; }
	| MINUS {$v = BinaryOperator.SUB; };	
mult_operator returns [BinaryOperator v]
	: MULT {$v = BinaryOperator.MULT; }
	| DIV  {$v = BinaryOperator.DIV; }
	| MOD  {$v = BinaryOperator.MOD; };
power_operator returns [BinaryOperator v]
	: CARRET {$v = BinaryOperator.POW; }
	;
args returns [ArgumentList v]
@init { $v = new ArgumentList.Default(); }
    : (n_ arg_expr[v])? n_ (COMMA ( { $v.add((ASTNode)null); } | n_ arg_expr[v]) n_)* 
	;
arg_expr [ArgumentList l]
	: e=expr { $l.add(e); }
	| name=id n_ ASSIGN n_ val=expr { $l.add(name.getText(), val); }
	| name=id n_ ASSIGN  { $l.add(name.getText(), null); }
	| NULL n_ ASSIGN n_ val=expr { Utils.nyi(); }
	| NULL n_ ASSIGN { Utils.nyi(); }
	;
///////////////////////////////////////////////////////////////////////////////
/// Lexer
///
COMMENT
    :   '#' ~('\n'|'\r'|'\f')* (LINE_BREAK | EOF)	{ if(incomplete_stack[incomplete_depth]>0) $channel=HIDDEN; }
    ;
ARROW
	: '<-' | ':='
	;
SUPER_ARROW 
	:	 '<<-' ;
RIGHT_ARROW 
	: '->'
	;
SUPER_RIGHT_ARROW 
	:	'->>'
	;
VARIATIC 
	: '..' '.'+
	; // FIXME
EQ	: '==';
NE 	: '!=';
GE	: '>=';
LE	: '<=';
GT	: '>';
LT 	: '<';
ASSIGN 
	: '=';


NS_GET_INT
	: ':::';
NS_GET
	: '::';

COLUMN
	: ':';
SEMICOLUMN
	: ';';
COMMA
	: ',';
AND
	: '&&';
BITWISEAND 
	: '&';
OR	: '||';
BITWISEOR
	:'|';
LBRACE 
	: '{'	{incomplete_stack[++incomplete_depth] = 0; }; // TODO grow the stack
RBRACE 
	: '}'	{incomplete_depth -- ;};
LPAR 
	: '('	{ incomplete_stack[incomplete_depth] ++; };
RPAR
	: ')'	{ incomplete_stack[incomplete_depth]--; };
LBB
	: '[['	{ incomplete_stack[incomplete_depth] += 2; }; // Must increase by two beacause of ']'']' used for closing
LBRAKET
	: '['	{ incomplete_stack[incomplete_depth] ++; };
RBRAKET
	: ']'	{ incomplete_stack[incomplete_depth] --;};
CARRET
	: '^' | '**';
TILDE
	: '~' ;
MOD
	: '%%' ;

NOT
	: '!';
PLUS
	: '+';
MULT
	: '*';
DIV	: '/';
MINUS
	: '-';

FIELD
	: '$';
AT	: '@';

FUNCTION
	: 'function';
NULL
	: 'NULL';

NA
    : 'NA';
TRUE
	: 'TRUE';
FALSE
	: 'FALSE';

WHILE 
	: 'while';
FOR	: 'for';
REPEAT
	: 'repeat';
IN	: 'in';
IF	: 'if';
ELSE
	: 'else';
NEXT
	: 'next';
BREAK
	: 'break';
// ?

WS  :   ( ' '
        | '\t'
        ) {$channel=HIDDEN;}
    ;
NEWLINE 
	: LINE_BREAK	{ if(incomplete_stack[incomplete_depth]>0) $channel=HIDDEN; };
INTEGER
    :   ('0'..'9')+ '.' ('0'..'9')* 'L' {setText(getText().substring(0, getText().length()-1));}
    |   '.'? ('0'..'9')+ EXPONENT? 'L' {setText(getText().substring(0, getText().length()-1));}
    |   '0x' HEX_DIGIT+ 'L' {setText(getText().substring(0, getText().length()-1));}
    ;
COMPLEX
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT? 'i'  {setText(getText().substring(0, getText().length()-1));}
    |   '.'? ('0'..'9')+ EXPONENT? 'i' {setText(getText().substring(0, getText().length()-1));}
    |   '0x' HEX_DIGIT 'i' {setText(getText().substring(0, getText().length()-1));}
    ;
DOUBLE
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.'? ('0'..'9')+ EXPONENT?
    |	'0x' HEX_DIGIT
    ;
DD	: '..' ('0'..'9')+
	;  
ID  : '.'* ID_NAME
	| '.'
	| '`' ( ESC_SEQ | ~('\\'|'`') )* '`'  {setText(getText().substring(1, getText().length()-1));} 
	;
OP	: '%' OP_NAME+ '%'
	;
STRING
    :
    ( '"' ( ESC_SEQ | ~('\\'|'"') )* '"' 
    | '\'' ( ESC_SEQ | ~('\\'|'\'') )* '\'' 
    ) {setText(getText().substring(1, getText().length()-1));} 
    ;
fragment
LINE_BREAK
	:
	 (('\f'|'\r')? '\n')
	| ('\n'? ('\r'|'\f')) // This rule fix very old Mac/Dos/Windows encoded files
	;
fragment
EXPONENT
	: ('e'|'E') ('+'|'-')? ('0'..'9')+ 
	;
fragment
OP_NAME
	: ID_NAME
	| ('*'|'/'|'+'|'-'|'>'|'<'|'='|'|'|'&'|':'|'^'|'.'|'~'|',')
	;
fragment
ID_NAME
	: ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_'|'.')*
	;
fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'"'|'\''|'`'|'\\'|' '|'a'|'v')
    |	'\\' LINE_BREAK // FIXME that's an ugly way to fix this
    |   UNICODE_ESC
    |   OCTAL_ESC
    |	HEX_ESC
    ;
fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;
fragment
HEX_ESC
	: '\\x' HEX_DIGIT HEX_DIGIT?
	;
fragment
HEX_DIGIT
	: ('0'..'9'|'a'..'f'|'A'..'F')
	;
fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;