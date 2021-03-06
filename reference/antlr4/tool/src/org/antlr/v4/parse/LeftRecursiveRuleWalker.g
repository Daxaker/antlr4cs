/*
 * Copyright (c) 2012 The ANTLR Project. All rights reserved.
 * Use of this file is governed by the BSD-3-Clause license that
 * can be found in the LICENSE.txt file in the project root.
 */

/** Find left-recursive rules */
tree grammar LeftRecursiveRuleWalker;

options {
	tokenVocab=ANTLRParser;
    ASTLabelType=GrammarAST;
}

@header {
package org.antlr.v4.parse;

import org.antlr.v4.misc.*;
import org.antlr.v4.tool.*;
import org.antlr.v4.tool.ast.*;
}

@members {
private String ruleName;
private int currentOuterAltNumber; // which outer alt of rule?
public int numAlts;  // how many alts for this rule total?

public void setAltAssoc(AltAST altTree, int alt) {}
public void binaryAlt(AltAST altTree, int alt) {}
public void prefixAlt(AltAST altTree, int alt) {}
public void suffixAlt(AltAST altTree, int alt) {}
public void otherAlt(AltAST altTree, int alt) {}
public void setReturnValues(GrammarAST t) {}
}

@rulecatch { }

// TODO: can get parser errors for not matching pattern; make them go away
public
rec_rule returns [boolean isLeftRec]
@init
{
	currentOuterAltNumber = 1;
}
	:	^(	r=RULE id=RULE_REF {ruleName=$id.getText();}
			ruleModifier?
//			(ARG_ACTION)? shouldn't allow args, right?
			(^(RETURNS a=ARG_ACTION {setReturnValues($a);}))?
//      		( ^(THROWS .+) )? don't allow
      		( ^(LOCALS ARG_ACTION) )? // TODO: copy these to gen'd code
      		(	^(OPTIONS .*)
		    |   ^(AT ID ACTION) // TODO: copy
		    )*
			ruleBlock {$isLeftRec = $ruleBlock.isLeftRec;}
			exceptionGroup
		)
	;

exceptionGroup
    :	exceptionHandler* finallyClause?
    ;

exceptionHandler
	: ^(CATCH ARG_ACTION ACTION)
	;

finallyClause
	: ^(FINALLY ACTION)
	;

ruleModifier
    : PUBLIC
    | PRIVATE
    | PROTECTED
    ;

ruleBlock returns [boolean isLeftRec]
@init{boolean lr=false; this.numAlts = $start.getChildCount();}
	:	^(	BLOCK
			(
				o=outerAlternative
				{if ($o.isLeftRec) $isLeftRec = true;}
				{currentOuterAltNumber++;}
			)+
		)
	;

/** An alt is either prefix, suffix, binary, or ternary operation or "other" */
outerAlternative returns [boolean isLeftRec]
    :   (binary)=>           binary
                             {binaryAlt((AltAST)$start, currentOuterAltNumber); $isLeftRec=true;}
    |   (prefix)=>           prefix
                             {prefixAlt((AltAST)$start, currentOuterAltNumber);}
    |   (suffix)=>           suffix
                             {suffixAlt((AltAST)$start, currentOuterAltNumber); $isLeftRec=true;}
    |   nonLeftRecur         {otherAlt((AltAST)$start,  currentOuterAltNumber);}
    ;

binary
	:	^( ALT elementOptions? recurse element* recurse epsilonElement* )
        {setAltAssoc((AltAST)$ALT,currentOuterAltNumber);}
	;

prefix
	:	^(	ALT elementOptions?
			element+
			recurse epsilonElement*
		 )
         {setAltAssoc((AltAST)$ALT,currentOuterAltNumber);}
	;

suffix
    :   ^( ALT elementOptions? recurse element+ )
         {setAltAssoc((AltAST)$ALT,currentOuterAltNumber);}
    ;

nonLeftRecur
    :   ^(ALT elementOptions? element+)
    ;

recurse
	:	^(ASSIGN ID recurseNoLabel)
	|	^(PLUS_ASSIGN ID recurseNoLabel)
	|	recurseNoLabel
	;

recurseNoLabel : {((CommonTree)input.LT(1)).getText().equals(ruleName)}? RULE_REF;

token returns [GrammarAST t=null]
	:	^(ASSIGN ID s=token {$t = $s.t;})
	|	^(PLUS_ASSIGN ID s=token {$t = $s.t;})
	|	b=STRING_LITERAL    					{$t = $b;}
    |	^(b=STRING_LITERAL elementOptions)		{$t = $b;}
    |	^(c=TOKEN_REF elementOptions)			{$t = $c;}
	|	c=TOKEN_REF        						{$t = $c;}
	;

elementOptions
    :	^(ELEMENT_OPTIONS elementOption*)
    ;

elementOption
    :	ID
    |   ^(ASSIGN ID ID)
    |   ^(ASSIGN ID STRING_LITERAL)
    |   ^(ASSIGN ID ACTION)
    |   ^(ASSIGN ID INT)
    ;

element
	:	atom
	|	^(NOT element)
	|	^(RANGE atom atom)
	|	^(ASSIGN ID element)
	|	^(PLUS_ASSIGN ID element)
    |	^(SET setElement+)
    |   RULE_REF
	|	ebnf
	|	epsilonElement
	;

epsilonElement
	:	ACTION
	|	SEMPRED
	|	EPSILON
	|	^(ACTION elementOptions)
	|	^(SEMPRED elementOptions)
	;

setElement
	:	^(STRING_LITERAL elementOptions)
	|	^(TOKEN_REF elementOptions)
	|	STRING_LITERAL
	|	TOKEN_REF
	;

ebnf:   block
    |   ^( OPTIONAL block )
    |   ^( CLOSURE block )
    |   ^( POSITIVE_CLOSURE block )
    ;

block
    :	^(BLOCK ACTION? alternative+)
    ;

alternative
	:	^(ALT elementOptions? element+)
    ;

atom
	:	^(RULE_REF ARG_ACTION? elementOptions?)
    |  ^(STRING_LITERAL elementOptions)
	|	STRING_LITERAL
    |	^(TOKEN_REF elementOptions)
	|	TOKEN_REF
    |	^(WILDCARD elementOptions)
	|	WILDCARD
	|	^(DOT ID element)
	;
