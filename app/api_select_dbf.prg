#include 'lib\uhttpd2\uhttpd2.ch'
#include 'dbinfo.ch' 
#include "FileIO.ch"

function Api_Select_Dbf( oDom )

	do case	
		
		case oDom:GetProc() == 'load_repo'		; Load_Repo( oDom )														
		
		case oDom:GetProc() == 'go_struct'		; Sel_and_GoStruct( oDom )														
		case oDom:GetProc() == 'go_browse'		; Sel_and_GoBrowse( oDom )														
		case oDom:GetProc() == 'go_indexes'	; Sel_and_GoIndexes( oDom )														

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function Load_repo( oDom )

	local cRepo := oDom:Get( 'repository' )
	local cPath := AppRepo2Path( cRepo )
	local aDbfs := {}
	local aFiles, n, uValue
	
	if empty( cPath )
		oDom:TableSetData( 'brwdbf', {} )
		retu nil 
	endif 
	
	aFiles := DIrectory( cPath + '\*.dbf') 
	
	for n := 1 to len( aFiles )
		uValue := Transform( aFiles[n][2] , '99,999,999,999') + ' Kb.'
		Aadd( aDbfs , {'file' => aFiles[n][1], 'size' => uValue } )
	next 	
	
	oDom:TableSetData( 'brwdbf', aDbfs )		

retu nil

// -------------------------------------------------- //

static function Sel_and_GoStruct( oDom )	 

	local cRepo 		:= oDom:Get( 'repository' )
	local hBrowse 		:= oDom:Get( 'brwdbf' )
	local aSelected	:= hBrowse[ 'selected' ]
	local aDbfs 		:= {}
	local aFields 		:= {}
	local hInfo 		:= {=>}
	local lOpened		:= .f.
	local cPath, cFile, aFiles, cAlias, aStr, n
	local oError , cError

	if len( aSelected ) <> 1
		retu nil 
	endif 
	
	cPath 	:= AppRepo2Path( cRepo ) 
	cFile 	:= cPath + '\' + aSelected[1][ 'file' ]	
	cAlias 	:= NewAlias()
	
	try 
	
		USE (cFile) NEW READONLY ALIAS (cALias) VIA 'DBFCDX' CODEPAGE 'CP850'
		
		lOpened := used() 
		
		
	catch oError 
		
		cError := 'Error: ' + oError:description + ', Operation: ' + HB_CStr( oError:operation) 		
		
		oDom:SetMsg( cError )
		
	end 
	
	if lOpened 
	
		aStr := (cAlias)->( DbStruct() )		
		
		for n := 1 to len( aStr )
			Aadd( aFields, { 'field' => aStr[n][1],;
							  'type' => TypeKey2Text( aStr[n][2] ),;
							  'len'  => aStr[n][3],;
							  'dec'  => aStr[n][4] ;
							})
		next 
	
		oDom:SetScope( 'struct' )	//	<<--- Change Scope
					
			oDom:Set( 'repo', cRepo  )
			oDom:Set( 'file', aSelected[1][ 'file' ]  )
						
			oDom:Set( 'field', '' )
			oDom:Set( 'type', 'C' )
			oDom:Set( 'len', '10' )
			oDom:Set( 'dec', '0' )	
			
			oDom:TableSetData( 'brwstr', aFields )		
			
	endif
	
	oDom:DialogClose( 'dlg_seldbf' )	

retu nil 

// -------------------------------------------------- //

static function Sel_and_GoBrowse( oDom )	 

	local cRepo 		:= oDom:Get( 'repository' )
	local cCodepage	:= oDom:Get( 'codepage' )
	local hBrowse 		:= oDom:Get( 'brwdbf' )
	local aSelected	:= hBrowse[ 'selected' ]
	local cPath, cFile, cCollate, h 

	
	if len( aSelected ) <> 1
		retu nil 
	endif 
	
	cPath 	:= AppRepo2Path( cRepo ) 
	cFile 	:= cPath + '\' + aSelected[1][ 'file' ]

	oDom:DialogClose( 'dlg_seldbf' )	
	
	h := { 'file' => cFile, 'codepage' => cCodepage, 'repo' => cRepo }
	
	oDom:MsgApi( 'api_browse', 'init', h )			

retu nil 

// -------------------------------------------------- //

static function Sel_and_GoIndexes( oDom )	 

	local cRepo 		:= oDom:Get( 'repository' )
	local hBrowse 		:= oDom:Get( 'brwdbf' )
	local aSelected	:= hBrowse[ 'selected' ]
	local lOpened 		:= .f.
	local aBag 			:= {}
	local i 			:= 1
	local cPath, cFile, cCollate, h, cAlias, oError, cError
	local cFileIndex, lIndex, cBagName, cKey

	
	if len( aSelected ) <> 1
		retu nil 
	endif 
	
	cPath 	:= AppRepo2Path( cRepo ) 
	cFile 	:= cPath + '\' + aSelected[1][ 'file' ]
	
	//	Open Dbf
	
		try 
			cAlias := NewAlias()
			USE (cFile) NEW READONLY ALIAS (cALias) VIA 'DBFCDX' 
	
			lOpened := used() 
	
			
		catch oError 
			
			cError := 'Error: ' + oError:description + ', Operation: ' + HB_CStr( oError:operation) 	
	
			oDom:SetMsg( cError )
			retu nil
			
		end 	
		
		if !lOpened 
			oDom:SetMsg( 'Error open table' )
			retu nil 
		endif 
	

	oDom:DialogClose( 'dlg_seldbf' )					
	
	cFileIndex 	:= hb_FNameDir( cFile ) + hb_FNameName( cFile ) + '.cdx'	
	
	//	Check index
	
		lIndex := file( cFileIndex ) 
	
		if lIndex 
		
			cBagName := hb_FNameName( cFile )
		
			SET INDEX TO ( cFileIndex )
			
			while !empty( ( cKey := (cAlias)->( OrdKey(i) ) ) )						
				
				Aadd( aBag, { 'name' => (cAlias)->( OrdName(i) ), 'key' => cKey })
						
				i++
			end 							
		
		endif 	

		oDom:SetScope( 'index' )	//	<<--- Change Scope		
			
			oDom:Set( 'repo', cRepo  )
			oDom:Set( 'file', aSelected[1][ 'file' ]  )		
	
			oDom:TableSetData( 'brwindexes', aBag )			

retu nil

// -------------------------------------------------- //
