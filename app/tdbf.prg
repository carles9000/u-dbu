#include 'lib\uhttpd2\uhttpd2.ch'	
#include 'hbclass.ch'	

CLASS TDbf

	DATA cAlias 
	DATA nFields 						INIT 0
	DATA hFlags 

	METHOD New( cDbf, cCdx, cFocus )  CONSTRUCTOR 
	
	METHOD LoadAll( aFields ) 
	METHOD Update( nRecno, aFields, cError ) 
	METHOD Delete( nRecno, cError )	
	METHOD Append( cError )
	
	METHOD Seek( u, lSoft )
	
	METHOD Blank()
	METHOD Row() 
	
ENDCLASS 

// -------------------------------------------------- //

METHOD New( cDbf, cCdx, cFocus, hFlags ) CLASS TDbf

	local cFileDbf 	:= AppPathData() + cDbf
	local cAlias, cFileCdx, oError
	
	hb_default( @cCdx, '')
	hb_default( @cFocus, '' )
	hb_default( @hFlags, {=>} )
	
	cFileDbf 	:= AppPathData() + cDbf
	
	if !file( cFileDbf )
		UDo_Error( "No dbf file" )			
		retu nil
	endif
	
	::hFlags := hFlags
	
	TRY
	
		::cAlias := NewAlias()

		use ( cFileDbf ) shared new alias (::cAlias) VIA 'DBFCDX' 		
		
		::nFields := (::cAlias)->( FCount() )
		
		if !empty( cCdx )
		
			cFileCdx 	:= AppPathData() + cCdx
			
			if file( cFileCdx )
		
				SET INDEX TO ( cFileCdx )
			
				if !empty( cFocus )			
					(::cAlias)->( OrdSetFocus( cFocus ) )
					
					if (::cAlias)->( IndexOrd() ) == 0
						UDo_Error( "Tag doesn't exist " + cFocus )
					endif
					
				endif
					
			else 
				UDo_Error( "Cdx doesn't exist " + cCdx )			
			endif 
		endif 
		
	
	CATCH oError 

		Eval( ErrorBlock(), oError )
	
	END			
	
RETU SELF

//	----------------------------------------------- //

METHOD LoadAll( aFields ) CLASS TDbf

	local aRows := {}
	local hRow  := {=>}
	local aStr, n, nFields, uValue, aSt
	local nSet 
	
	hb_default( @aFields, {} ) 

	if empty( aFields )
	
		aSt := ( ::cAlias)->( DbStruct() )
		
		for n := 1 to len( aSt )		
			Aadd( aFields, aSt[n][1] )
		next 		
	
	endif 

	nFields := len( aFields )
	
	for n := 1 to nFields
		aFields[n] := { aFields[n], (::cAlias)->( FieldPos( aFields[n] ) ), valtype( (::cAlias)->( FieldGet( FieldPos( aFields[n] )))) } 
	next 	
	
	(::cAlias)->( DbGoTop() )
	
	while (::cAlias)->( !eof() )
	
		hRow := {=>}
			
		hRow[ '_recno' ] := (::cAlias)->( Recno() )
		
		for n := 1 to nFields 
		
			uValue := (::cAlias)->( FieldGet( aFields[n][2] ) )
			
			do case
				case aFields[n][3] == 'C' ; uValue := hb_strtoUtf8( alltrim( uValue) ) 
				case aFields[n][3] == 'D' ; uValue := DToC( uValue )
			endcase			
			
			hRow[ aFields[n][1] ] := uValue
			
		next 
		
		Aadd( aRows, hRow  )
	
		(::cAlias)->( DbSkip() )
		
	end	

RETU aRows 

//	----------------------------------------------- //

METHOD Update( nRecno, hFields, cError ) CLASS TDbf

	local lUpdate := .f.
	local n, j, h, nPos, oError

	(::cAlias)->( DbGoTo( nRecno ) )
		
	if (::cAlias)->( Rlock() )		
	
		lUpdate := .t.
	
		for n :=  1 to len(hFields)
		
			h := HB_HPairAt( hFields, n )

			nPos := (::cAlias)->( FieldPos( h[1] ) )

			try
				(::cAlias)->( Fieldput( nPos, h[2] ) )		
			catch oError

				cError  := 'Field: ' + UValToChar( h[1] )
				cError  += '<br>Error: ' + oError:description
				
				if valtype( oError:args ) == 'A'
					cError  += '<br>Args: ' 
					for j := 1 to len(oError:args)
						cError  += '<br>&nbsp;&nbsp;[' + ltrim(str(j))+ ']: ' + UValToChar( oError:args[j] )					
					next					
				endif
				
				lUpdate := .f.
			end 
		
		next			
		
		(::cAlias)->( DbCommit() )
		(::cAlias)->( DbUnlock() )		
		
	else 
		cError := 'Lock error'
	endif

RETU lUpdate

//	----------------------------------------------- //

METHOD Delete( nRecno, cError ) CLASS TDbf

	local lDelete := .f.
	
	(::cAlias)->( DbGoto(  nRecno ) )
	
	if (::cAlias)->( Rlock() )			
	
		(::cAlias)->( DbDelete() )	
		
		(::cAlias)->( DbUnlock() )
		
		lDelete := .T. 
		
	else 
		cError := 'Lock error'				
	endif		
	
	
RETU lDelete 

//	----------------------------------------------- //

METHOD Append( nRecno, cError ) CLASS TDbf	
	
	(::cAlias)->( DbAppend() )		
	
RETU .t.

//	----------------------------------------------- //

METHOD Seek( cUser, lSoftSeek  ) CLASS TDbf		
	
	hb_default( @lSoftSeek, .f. )
	
retu (::cAlias)->( DbSeek( cUser, lSoftSeek ) )		

//	----------------------------------------------- //

METHOD Blank() CLASS TDbf	

	local nRecno :=  (::cAlias)->( recno() )	
	local hRow 		:= {=>}
		
	(::cAlias)->( DbGobottom() )
	(::cAlias)->( DbSkip(1) )		
	
	hRow := ::Row()	
		
	(::cAlias)->( DbGoTo( nRecno ) )

RETU hRow

//	----------------------------------------------- //

METHOD Row() CLASS TDbf	

	local nFields := (::cAlias)->( FCount() )
	local hRow 		:= {=>}
	local n, cType, uValue 	
	
	for n := 1 to ::nFields
	
		uValue := (::cAlias)->( FieldGet( n ) )
		
		cType  := valtype( uValue )
		
		do case
			case cType == 'C' .or. cType == 'M'
				uValue := alltrim(uValue)
			case cType == 'D'
				uValue := DToC( '  -  -  ' )
		endcase
		
		hRow[ (::cAlias)->( FieldName( n ) ) ] := uValue
	
	next 					

RETU hRow

//	----------------------------------------------- //
