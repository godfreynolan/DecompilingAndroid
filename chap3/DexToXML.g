grammar DexToXML;

options {
  language = Java;
}

@header {
  package com.riis.decompiler;
}

@lexer::header {
  package com.riis.decompiler;
}

rule 
	@init {System.out.println("<root>");}	
	@after {System.out.println("</root>");}	
	: header
	  string_ids
	  type_ids
	  proto_ids
	  field_ids
	  method_ids
	  class_defs
	  data
	;

header
	@init {System.out.println("<header>");}	
	@after {System.out.println("</header>");}	
	: magic
	  header_entry
	  signature
	  header_entry+
	;

magic: address eight_hex eight_hex IDENT ':' id=MAGIC_NUM
	{System.out.println("<magic>" + id.getText() + "</magic>");}
	;

header_entry
	: address id1=eight_hex id2=IDENT
		{System.out.println("<" + $id2.text + ">" + $id1.text + "</" + $id2.text + ">");}
	| address eight_hex id3=xml_id ':' id4=hex_address
		{System.out.println("<" + $id3.result + ">" + $id4.text + "</" + $id3.result + ">");}
	| address eight_hex eight_hex id5=xml_id ':' id6=hex_address
		{System.out.println("<" + $id5.result + ">" + $id6.text + "</" + $id5.result + ">");}
	;

xml_id returns [String result]
	: id1=IDENT id2=IDENT
		{$result = id1.getText() + "_" + id2.getText();}
	| id1=IDENT id2=IDENT id3=IDENT
		{$result = id1.getText() + "_" + id2.getText() + "_" + id3.getText();}
	;
	
signature: address id=signature_hex 'signature'
	{System.out.println("<signature>" + $id.text + "</signature>");}
	;

signature_hex: eight_hex eight_hex eight_hex eight_hex eight_hex
	;

string_ids
	@init {System.out.println("<string_ids>");}	
	@after {System.out.println("</string_ids>");}	
	: string_address+
	;
	
string_address	
	: address eight_hex IDENT id1=array_digit  ':' 'at' id2=hex_address
		{System.out.println("<string>\n<id>" + $id1.result + "</id>\n<address>" + $id2.text + "</address>\n</string>");}
	;

type_ids
	@init {System.out.println("<type_ids>");}	
	@after {System.out.println("</type_ids>");}	
	: type_address+
	;
	
type_address	
	: address eight_hex IDENT id1=array_digit  'index:' id2=eight_hex '(' id3=proto_type_string ')'
		{int addr = Integer.parseInt($id2.text,16);	
		 System.out.println("<type>\n<id>" + $id1.result + "</id>\n<string_id>" 
					+ addr + "</string_id>\n<string>" + $id3.text + "<string>\n</type>");}
	;

proto_ids
	@init {System.out.println("<proto_ids>");}	
	@after {System.out.println("</proto_ids>");}	
	: proto_address+
	;
	
proto_address	
	: address eight_hex eight_hex eight_hex IDENT id1=array_digit ':' 
			'short signature:' id2=proto_type_string ';' 
			'return type:' id3=proto_type_string ';'
			'parameter block offset:' eight_hex
		 {System.out.println("<proto>\n<id>" + $id1.result + "</id>\n<string>" 
					+ $id3.text + "</string>\n<signature>" + $id2.text + "<signature>\n</proto>");}
	;
	
field_ids
	@init {System.out.println("<field_ids>");}	
	@after {System.out.println("</field_ids>");}	
	: field_address+
	;
	
field_address	
	: address eight_hex eight_hex IDENT id1=array_digit ':' id2=proto_type_string id3=proto_type_string
		 {System.out.println("<field>\n<id>" + $id1.result + "</id>\n<name>" 
					+ $id2.text + "</name>\n<type>" + $id3.text + "<type>\n</field>");}
	
	;

method_ids
	@init {System.out.println("<method_ids>");}	
	@after {System.out.println("</method_ids>");}	
	: method_address+
	;
	
method_address	
	: address eight_hex eight_hex IDENT id1=array_digit ':' id2=proto_type_string '(' id3=proto_type_string ')' 
		 {System.out.println("<method>\n<id>" + $id1.result + "</id>\n<name>" 
					+ $id2.text + "</name>\n<proto>" + $id3.text + "<proto>\n</method>");}
	;

	
class_defs
	@init {System.out.println("<classes>");}	
	@after {System.out.println("</classes>");}	
	: class_address+
	;

class_address
	: address id1=eight_hex id2=eight_hex id3=eight_hex id4=eight_hex id5=eight_hex id6=eight_hex id7=eight_hex id8=eight_hex id9=IDENT id10=IDENT
		 {System.out.println("<class>\n" 
		 		 		+"<class_id>" + $id9.text + " " + $id10.text + "</class_id>\n"
		 		 		+"<type_id>" + $id1.text + "</type_id>\n" 		 
		 				+"<access_flags>" + $id2.text + "</access_flags>\n"
		 				+"<superclass_id>" + $id3.text + "<superclass>\n"
		 				+"<interfaces_offset>" + $id4.text + "<interfaces_offset>\n"
		 				+"<source_file_id>" + $id5.text + "<source_file_id>\n"
		 				+"<annotations_offset>" + $id6.text + "<annotations_offset>\n"
		 				+"<class_data_offset>" + $id7.text + "<class_data_offset>\n"
		 				+"<static_values_offset>" + $id8.text + "<static_values_offset>\n"
		 				+"</class>");}	
	;

data 
	@init {System.out.println("<data>");}	
	@after {System.out.println("</data>");}	
	: class_+
	;

class_
	@init {System.out.println("<class>");}	
	@after {System.out.println("</class>");}	
	: class_data_items code_items
	;

class_data_items
	@init {System.out.println("<class_data_items>");}	
	@after {System.out.println("</class_data_items>");}
	: class_data_item
	;

class_data_item
	@init {System.out.println("<class_data_item>");}	
	@after {System.out.println("</class_data_item>");}
	: class_data_item_header static_fields //instance_methods 
		direct_methods	// virtual_methods
		encoded_arrays
	;
	
class_data_item_header
	:	address HEX_DOUBLE 'static fields size:' id1=DIGIT
		address HEX_DOUBLE 'instance fields size:' id2=DIGIT
		address HEX_DOUBLE 'direct methods size:' id3=DIGIT
		address HEX_DOUBLE 'virtual methods size:' id4=DIGIT
		 {System.out.println("<static_field_size>" + $id1.getText() + "</static_field_size>\n"
		 		 		+"<instance_field_size>" + $id2.getText() + "</instance_field_size>\n" 		 
		 				+"<direct_methods_size>" + $id3.getText() + "</direct_methods_size>\n"
		 				+"<virtual_methods_size>" + $id4.getText() + "</virtual_methods_size>");}	
	;

static_fields
	@init {System.out.println("<static_fields>");}	
	@after {System.out.println("</static_fields>");}
	: static_field+
	;

static_field
	@init {System.out.println("<static_field>");}	
	@after {System.out.println("</static_field>");}
	: address id1=HEX_DOUBLE id2=HEX_DOUBLE
		 {System.out.println("<field_id>" + $id1.getText() + "</field_id>\n"
		 		 		+"<access_flags>" + $id2.getText() + "</access_flags>");}	
	;

direct_methods
	@init {System.out.println("<direct_methods>");}	
	@after {System.out.println("</direct_methods>");}
	: direct_method+
	;

direct_method
	@init {System.out.println("<direct_method>");}	
	@after {System.out.println("</direct_method>");}
	: address id1=HEX_DOUBLE id2=HEX_DOUBLE id3=HEX_DOUBLE id4=HEX_DOUBLE id5=HEX_DOUBLE id6=HEX_DOUBLE
		 {System.out.println("<method_id>" + $id1.getText() + "</method_id>\n"
		 				+"<access_flags>" + $id2.getText()  + $id3.getText()  + $id4.getText() + "</access_flags>\n"
		 		 		+"<address>0x" + $id5.getText() + $id6.getText() + "</address>");}	
	| address id1=HEX_DOUBLE id2=HEX_DOUBLE id3=HEX_DOUBLE id4=HEX_DOUBLE 
		 {System.out.println("<method_id>" + $id1.getText() + "</method_id>\n"
		 				+"<access_flags>" + $id2.getText() + "</access_flags>\n"
		 		 		+"<address>0x" + $id3.getText() + $id4.getText() + "</address>");}	
	;

encoded_arrays
	: address HEX_DOUBLE 'array item count:' DIGIT encoded_array+
	;

encoded_array
	: address HEX_DOUBLE HEX_DOUBLE IDENT IDENT array_digit ':' '"' IDENT '"'
	;

code_items
	@init {System.out.println("<code_items>");}	
	@after {System.out.println("</code_items>");}	
	: code_item+
	;
	
code_item
	@init {System.out.println("<code_item>");}	
	@after {System.out.println("</code_item>");}
	: code_item_header code_item_debug_info insns
	;
	
code_item_header
	: 'Class:' IDENT  'Method:' IDENT+ proto_type_string 
		address HEX_DOUBLE HEX_DOUBLE 'registers size:' id1=DIGIT
		address HEX_DOUBLE HEX_DOUBLE 'input arguments:' id2=DIGIT
		address HEX_DOUBLE HEX_DOUBLE 'output arguments:' id3=DIGIT
		address HEX_DOUBLE HEX_DOUBLE 'try block size:' id4=DIGIT
		address id5=eight_hex  
		address id6=eight_hex  
		 {System.out.println("<registers_size>" + $id1.getText() + "</registers_size>\n"
		 		 		+"<input_arguments>" + $id2.getText() + "</input_arguments>\n" 		 
		 				+"<output_arguments>" + $id3.getText() + "</output_arguments>\n"
		 				+"<try_block_size>" + $id4.getText() + "</try_block_size>\n"
		 				+"<debug_info_offset>" + $id5.text + "</debug_info_offset>\n"
		 				+"<instuction_block_offset>" + $id6.text + "</instuction_block_offset>");}		
	;

code_item_debug_info
	: address HEX_DOUBLE 'Starting line:' DIGIT
	  address HEX_DOUBLE 'Parameter number:' DIGIT
	  address HEX_DOUBLE 'DBG_SET_PROLOGUE_END'	
	  line_register
	  address HEX_DOUBLE 'DBG_END_SEQUENCE'	  	
	| address HEX_DOUBLE 'Starting line:' DIGIT
	  address HEX_DOUBLE 'Parameter number:' DIGIT
	  address HEX_DOUBLE 'reg' '#-' DIGIT ':' IDENT DIGIT
	  address HEX_DOUBLE 'DBG_SET_PROLOGUE_END'
	  line_register+
	  address HEX_DOUBLE HEX_DOUBLE DBGADVANCEPC	
	  line_register+
	  address HEX_DOUBLE 'DBG_END_SEQUENCE'
	;

line_register 
	: 	  address HEX_DOUBLE 'Line register:' DIGIT ';' 'address register:' '0x' DIGIT
	| 	  address HEX_DOUBLE 'Line register:' DIGIT ';' 'address register:' '0x' HEX_DOUBLE
	| 	  address HEX_DOUBLE 'Line register:' HEX_DOUBLE ';' 'address register:' '0x' HEX_DOUBLE
	;

insns  
	@init {System.out.println("<insns>");} 	
	@after {System.out.println("</insns>");}
	: insn+
	; 


insn
	: id1=bytecode
	 	{System.out.println("<insn>" + $id1.text + "</insn>");}
	;
	
bytecode
	: INVOKEDIRECT
	| CONST
	| IFGE
	| SGETOBJECT
	| NEWINSTANCE
	| INVOKEVIRTUAL
	| MOVERESULTOBJECT
	| ADDINT
	| INTTOCHAR
	| GOTO	
	| RETURNVOID
	;
	
	
proto_type_string 
	: IDENT
	| IDENT ';' 
	| IDENT '.' IDENT
	| IDENT '/' IDENT
	| IDENT '/' '<' IDENT '>'	
	| '<' IDENT '>' '()' IDENT 
	| IDENT '/' IDENT '/' IDENT ';' 
	| '[' IDENT '/' IDENT '/' IDENT ';' 
	| IDENT '()' IDENT '/' IDENT '/' IDENT ';' 				// toString()Ljava/lang/String;	
	| IDENT '/' IDENT '/' IDENT '.' IDENT     
	| IDENT '/' IDENT '/' IDENT '/' IDENT     				// java/io/PrintStream/println
	| IDENT '/' IDENT '/' IDENT '/' '<' IDENT '>'			// java/lang/Object/<init>
	| IDENT '(' IDENT '/' IDENT '/' IDENT ';' ')' IDENT  	// println(Ljava/lang/String;)V	
	| IDENT '(' '[' IDENT '/' IDENT '/' IDENT ';' ')' IDENT // main([Ljava/lang/String;)V
	| IDENT '(' IDENT ')' IDENT '/' IDENT '/' IDENT ';' 	// append(C)Ljava/lang/StringBuilder;	
	| IDENT '(' IDENT '/' IDENT '/' IDENT ';' ')' IDENT '/' IDENT '/' IDENT ';' 	// append(Ljava/lang/String;)Ljava/lang/StringBuilder;	
	;
	
	
hex_address: '0x' eight_hex
	;
	
address
	: eight_hex ':' 
	;
	
eight_hex
	: HEX_DOUBLE HEX_DOUBLE HEX_DOUBLE HEX_DOUBLE 
	;

array_digit returns [String result]
	: id=ELEMENT
		{String str = id.getText(); $result = str.substring(1, str.length()-1);}
	;
	


HEX_DOUBLE: ('0'..'9')('0'..'9')|('0'..'9')('A'..'F')|('A'..'F')('0'..'9')|('A'..'F')('A'..'F')|('0'..'9')('a'..'f')|('a'..'f')('0'..'9')|('a'..'f')('a'..'f');
MAGIC_NUM: 'dex\\n035\\0';
IDENT: ('a'..'z'|'A'..'Z')+;	
DIGIT: ('0'..'9');
ELEMENT: ('[')('0'..'9')+(']');
COMMENT:  '//' ~( '\r' | '\n' )* {$channel = HIDDEN;};
DBGOFFSET:  'debug info offset:' ~( '\r' | '\n' )* {$channel = HIDDEN;};
BLOCKSIZE:  'instruction block size:' ~( '\r' | '\n' )* {$channel = HIDDEN;};
METHODBLOCK: '\r' '\n' 'method block:' ~( '\r' | '\n' )* {$channel = HIDDEN;}; // using start of line 
NEXTBLOCK: 'next block starts at:' ~( '\r' | '\n' )* {$channel = HIDDEN;};
INVOKEDIRECT: 'invoke-direct' ~( '\r' | '\n' )*;
CONST: 'const' ~( '\r' | '\n' )*;
IFGE: 'if-ge' ~( '\r' | '\n' )*;
SGETOBJECT: 'sget-object' ~( '\r' | '\n' )*;
NEWINSTANCE: 'new-instance' ~( '\r' | '\n' )*;
INVOKEVIRTUAL: 'invoke-virtual' ~( '\r' | '\n' )*;
MOVERESULTOBJECT: 'move-result-object' ~( '\r' | '\n' )*;
ADDINT: 'add-int' ~( '\r' | '\n' )*;
INTTOCHAR: 'int-to-char' ~( '\r' | '\n' )*;
GOTO: 'goto' ~( '\r' | '\n' )*;
RETURNVOID: 'return-void'; 
DBGADVANCEPC: 'DBG_ADVANCE_PC' ~( '\r' | '\n' )*;
WS: (' ' | '\t' | '\n' | '\r' | '\f' | ',' | '-' | '*')+ {$channel = HIDDEN;};  