package com.riis.decompiler;

// import java.io.IOException;
import java.io.*;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.TokenStream;


public class DexToXML {

	public static void main(String[] args) throws RecognitionException, IOException {	
		DexToXMLLexer lexer = new DexToXMLLexer(new ANTLRFileStream("c:\\temp\\input.log"));
		TokenStream tokenStream = new CommonTokenStream(lexer);
		DexToXMLParser parser = new DexToXMLParser(tokenStream);
	
		parser.rule();
		System.out.println("done!");
		
	}

}