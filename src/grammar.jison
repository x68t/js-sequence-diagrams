/** js sequence diagrams
 *  https://bramp.github.io/js-sequence-diagrams/
 *  (c) 2012-2017 Andrew Brampton (bramp.net)
 *  Simplified BSD license.
 */
%lex

%options case-insensitive

%{
	// Pre-lexer code can go here
%}

%%

[\r\n]+           return 'NL';
\s+               /* skip whitespace */
\#[^\r\n]*        /* skip comments */
"participant"     return 'participant';
"left of"         return 'left_of';
"right of"        return 'right_of';
"over"            return 'over';
"note"            return 'note';
"title"           return 'title';
","               return ',';
[^\-<>:,\r\n"]+   return 'ACTOR';
\"[^"]+\"         return 'ACTOR';
"--"              return 'DOTLINE';
"-"               return 'LINE';
">o"              return 'RIGHT_OVALARROW';
">#"              return 'RIGHT_DIAMONDARROW';
">>"              return 'RIGHT_OPENARROW';
">"               return 'RIGHT_ARROW';
"<o"              return 'LEFT_OVALARROW';
"<#"              return 'LEFT_DIAMONDARROW';
"<<"              return 'LEFT_OPENARROW';
"<"               return 'LEFT_ARROW';
:[^\r\n]+         return 'MESSAGE';
<<EOF>>           return 'EOF';
.                 return 'INVALID';

/lex

%start start

%% /* language grammar */

start
	: document 'EOF' { return yy.parser.yy; } /* returning parser.yy is a quirk of jison >0.4.10 */
	;

document
	: /* empty */
	| document line
	;

line
	: statement { }
	| 'NL'
	;

statement
	: 'participant' actor_alias { $2; }
	| signal               { yy.parser.yy.addSignal($1); }
	| note_statement       { yy.parser.yy.addSignal($1); }
	| 'title' message      { yy.parser.yy.setTitle($2);  }
	;

note_statement
	: 'note' placement actor message   { $$ = new Diagram.Note($3, $2, $4); }
	| 'note' 'over' actor_pair message { $$ = new Diagram.Note($3, Diagram.PLACEMENT.OVER, $4); }
	;

actor_pair
	: actor             { $$ = $1; }
	| actor ',' actor   { $$ = [$1, $3]; }
	;

placement
	: 'left_of'   { $$ = Diagram.PLACEMENT.LEFTOF; }
	| 'right_of'  { $$ = Diagram.PLACEMENT.RIGHTOF; }
	;

signal
	: actor signaltype actor message
	{ $$ = new Diagram.Signal($1, $2, $3, $4); }
	;

actor
	: ACTOR { $$ = yy.parser.yy.getActor(Diagram.unescape($1)); }
	;

actor_alias
	: ACTOR { $$ = yy.parser.yy.getActorWithAlias(Diagram.unescape($1)); }
	;

signaltype
	: left_arrowtype linetype right_arrowtype { $$ = ($1 << 8) | $2 | ($3 << 4); }
	;

linetype
	: LINE      { $$ = Diagram.LINETYPE.SOLID; }
	| DOTLINE   { $$ = Diagram.LINETYPE.DOTTED; }
	;

right_arrowtype
    :                    { $$ = Diagram.ARROWTYPE.NONE; }
	| RIGHT_ARROW        { $$ = Diagram.ARROWTYPE.FILLED; }
	| RIGHT_OPENARROW    { $$ = Diagram.ARROWTYPE.OPEN; }
	| RIGHT_OVALARROW    { $$ = Diagram.ARROWTYPE.OVAL; }
	| RIGHT_DIAMONDARROW { $$ = Diagram.ARROWTYPE.DIAMOND; }
	;

left_arrowtype
    :                { $$ = Diagram.ARROWTYPE.NONE; }
	| LEFT_ARROW     { $$ = Diagram.ARROWTYPE.FILLED; }
	| LEFT_OPENARROW { $$ = Diagram.ARROWTYPE.OPEN; }
	| LEFT_OVALARROW { $$ = Diagram.ARROWTYPE.OVAL; }
	| LEFT_DIAMONDARROW { $$ = Diagram.ARROWTYPE.DIAMOND; }
	;

message
	: MESSAGE { $$ = Diagram.unescape($1.substring(1)); }
	;


%%
