#include 'lib\uhttpd2\uhttpd2.ch'
#include 'dbinfo.ch' 

function Api_Indexes( oDom )

	do case	
		
		case oDom:GetProc() == 'add'			; AddTag( oDom )								
		case oDom:GetProc() == 'edit'			; EditTag( oDom )								
		case oDom:GetProc() == 'del'			; DelTag( oDom )								
		case oDom:GetProc() == 'create_cdx'	; Create_Cdx( oDom )								
								
		case oDom:GetProc() == 'type'			; TypeField( oDom )								
		
		case oDom:GetProc() == 'new_dbf'		; New_Dbf( oDom )								
		case oDom:GetProc() == 'info'			; Info( oDom )								
		
		case oDom:GetProc() == 'dlg_select_dbf'; Dlg_Select_Dbf( oDom )								
		case oDom:GetProc() == 'dlg_create_dbf'; Dlg_Create_Dbf( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function AddTag( oDom )

	local hBrowse		:= oDom:Get( 'brwindexes' )
	local cRepo			:= oDom:Get( 'repo' )
	local cFile			:= oDom:Get( 'file' )
	local cTag 			:= oDom:Get( 'tag' )
	local cKey 			:= oDom:Get( 'key' )
	local cPath 		:= AppRepo2Path( cRepo )
	local hTags, cSearch, nPos 
	local hRow 			:= {}
	local cFileDbf, cAlias, oError, uValue
	local bKey, cError

	//	Initialiting variables
	
		if empty( cTag )
			oDom:SetMsg( 'Empty key')
			retu nil
		endif	
	
		if empty( cKey )
			oDom:SetMsg( 'Empty key')
			retu nil
		endif					
	
	
	//	Initialiting variables
	
		cFileDbf 	:= cPath + '\' + cFile
		
		cAlias 	:= NewAlias()
			
		USE (cFileDbf) shared ALIAS (cAlias) VIA 'DBFCDX'		
		
		try
		
			bKey 	:= &( '{||' + cKey + '}' )
			uValue := eval( bKey )
			
			
		catch oError
			_d( oError )
			cError := 'Error: ' + oError:description + ', Operation: ' + HB_CStr( oError:operation) 
			oDom:SetMsg( cError )
			retu nil
		end 

		(cAlias)->( DbCloseArea() )

		hTags		:= hBrowse[ 'data' ]	
		cSearch 	:= upper( alltrim( cTag ) )		
		
		HB_HCaseMatch( hTags, .f. )
		nPos := HB_HScan( hTags, {|key,value,pos| upper( value['name'] ) == cSearch } )

		
		hRow := { 'name' => alltrim( cTag ) , 'key' => cKey, 'status' => 'u' } 	//	[u]pdate

		
		if nPos > 0			
		
			oDom:TableUpdateRow( 'brwindexes', alltrim( cTag ), hRow )			
			
		else 
		
		
			oDom:TableAddData( 'brwindexes', hRow )						
			
		endif	

retu nil

// -------------------------------------------------- //

static function DelTag( oDom )

	local hStr	:= oDom:Get( 'brwindexes' )
	local hRow	:= hStr[ 'selected' ]
		
	if len( hRow) == 1	
		oDom:SetTable( 'brwindexes', 'deleteRow', { 'ids' => hRow[1][ 'name' ] }, 'Delete row?' )						
	endif		
	
retu nil 

// -------------------------------------------------- //

static function EditTag( oDom )

	local hStr	:= oDom:Get( 'brwindexes' )
	local hRow	:= hStr[ 'selected' ]
	local cType 
		
	if len( hRow ) == 1				
	
		oDom:Set( 'tag'	, hRow[1][ 'name'] )		
		oDom:Set( 'key'	, hRow[1][ 'key'] )						
		
		oDom:Focus( 'tag' )
		
	endif
	
retu nil 

// -------------------------------------------------- //

static function TypeField( oDom, cType )

	if cType == NIL 		
		cType := oDom:Get( 'type' ) 	
	endif
	
	do case
	
		case cType == 'C'			
			oDom:Set( 'dec', '0' )			
			oDom:Disable( 'dec' )
			
		case cType == 'L'
			oDom:Set( 'len', '1' )
			oDom:Set( 'dec', '0' )
			oDom:Disable( 'len' )
			oDom:Disable( 'dec' )
			
		case cType == 'D'
			oDom:Set( 'len', '8' )
			oDom:Set( 'dec', '0' )
			oDom:Disable( 'len' )
			oDom:Disable( 'dec' )
			
		case cType == 'M'
			oDom:Set( 'len', '10' )
			oDom:Set( 'dec', '0' )
			oDom:Disable( 'len' )
			oDom:Disable( 'dec' )
			
		otherwise
			oDom:Enable( 'len' )
			oDom:Enable( 'dec' )
	endcase

retu nil 

// -------------------------------------------------- //

static function New_Dbf( oDom )
	
	oDom:Set( 'field', '' )
	oDom:Set( 'type', 'C' )
	oDom:Set( 'len', '10' )
	oDom:Set( 'dec', '0' )

	TypeField( oDom, 'C')	
	
	oDom:TableSetData( 'brwstr', {})

	oDom:SetScope( 'struct' )
		oDom:Set( 'repo', ''  )
		oDom:Set( 'file', ''  )	

retu nil 

// -------------------------------------------------- //

static function Dlg_Select_Dbf( oDom )

	local hParam 	:= { 'action' => 'go_indexes', 'codepage' => .f. }
	local cHtml 	:= ULoadHtml( 'dbu\sc_seldbf.html', hParam )	
	
	oDom:SetDialog( 'dlg_seldbf', cHtml, 'Select Table...' )


retu nil 

//	------------------------------------------------------------------- //

static function Info( oDom )		
	
	local cRepo    := oDom:Get( 'repo' )
	local cPath 	:= AppRepo2Path( cRepo ) 
	local cFile    := oDom:Get( 'file' )
	local hCfg 		:= { 'size' => '300px' }
	local aInfo 	:= {}		
	local cFileDbf	:= cPath + '\' + cFile 
	local cError 	:= ''
	local cHtml, cInfoTable
	
	aInfo 		:= TableInfo( cFileDbf, @cError )	
	
	if !empty( cError )
		oDom:SetMsg( cError )
	else	
		cInfoTable 	:= cRepo + ' - ' + cFile 	
		cHtml 		:= ULoadHtml( 'dbu\sc_info.html', cInfoTable, aInfo )	
		oDom:SetDialog( 'dlg_info', cHtml, '<i class="fa fa-info-circle" aria-hidden="true"></i>&nbsp;Table information')
	endif

retu nil 

// -------------------------------------------------- //

static function Dlg_Create_Dbf( oDom )

	local aRepo    := { '', 'LOCAL', 'BUSSINESS' }
	local cRepo    := oDom:Get( 'repo' )
	local cFile    := oDom:Get( 'file' )
	local hBrowse	:= oDom:Get( 'brwstr' )
	local cHtml 	:= ULoadHtml( 'dbu\sc_create.html', aRepo, cRepo, cFile )	
	local hCfg 		:= { 'size' => '300px' }

	oDom:SetDialog( 'dlg_createdbf', cHtml, 'Create Table', hCfg )

retu nil 

// -------------------------------------------------- //

static function Create_Cdx( oDom )

	local hBrowse		:= oDom:Get( 'brwindexes' )
	local hBag			:= hBrowse[ 'data' ]
	local cRepo			:= oDom:Get( 'repo' )
	local cFile			:= oDom:Get( 'file' )		
	local cPath 		:= AppRepo2Path( cRepo )		
	local aRows 		:= {}
	local cFileDbf, cFileIndex, cFileBkpIndex, cFileNewIndex, cAlias,  uValue, lIndex
	local oError, cError
	local lOk, lError, nTags, n, j, h
	
		if len( hBag ) == 0
			retu nil 
		endif
	
	//	Initialiting variables
	
		cFileDbf 		:= cPath + '\' + cFile
		cFileIndex 		:= hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.cdx'
		cFileBkpIndex 	:= hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.cdx.bkp'
		cFileNewIndex 	:= hb_FNameDir( cFileDbf ) + 'DBU' + hb_FNameName( cFileDbf ) + '.cdx'
		
		cAlias 			:= NewAlias()			
		
		try								
			
			USE (cFileDbf) NEW ALIAS (cAlias) VIA 'DBFCDX'		
			
			if ! used() 
				cError := 'Error open table'
				
			else 			
			
				lIndex := file( cFileIndex )
				
				if lIndex			
					if fRename( cFileIndex, cFileBkpIndex ) != 0
						cError := 'Error rename original index: ' + UValtoChar( FERROR() )
				
					endif
				endif						
			
			endif						
			
		catch oError		
			
			cError := 'Error: ' + oError:description + ', Operation: ' + HB_CStr( oError:operation) 
		end 
		
		if !empty( cError )		
			oDom:SetMsg( cError )
			retu nil
		endif						
		
		lError  := .f.
		lOk 	:= .f. 
		nTags 	:= len( hBag )
		n 		:= 1
				
		while !lOk .and. n < nTags
				
			h := HB_HValueAt( hBag, n )

			try 
			
				(cAlias)->( OrdCreate( cFileNewIndex, h['name'], h['key'] ) )
				lOk := .t.
				Aadd( aRows, { 'name' => h['name'], 'key' => h['key'], 'status' => 'r' })
				
			catch oError			
				cError := oError:description + ', Operation: ' + HB_CStr( oError:operation)			

				Aadd( aRows, { 'name' => h['name'], 'key' => h['key'], 'status' => 'e', 'error' => cError  } )
				lError := .t.
			end																						
	
			n++
		end 				
	
		for j := n to nTags		

			h := HB_HValueAt( hBag, j )			
		
			try 
				
				INDEX ON &(h['key']) TAG  &(h['name']) TO &(cFileNewIndex)
				Aadd( aRows, { 'name' => h['name'], 'key' => h['key'], 'status' => 'r' } )
			catch oError 
			
				cError := oError:description + ', Operation: ' + HB_CStr( oError:operation)
				Aadd( aRows, { 'name' => h['name'], 'key' => h['key'], 'status' => 'e', 'error' => cError } )							
				
				lError := .t.
			end 
			
		next 					
		
	//	-------------------------------	
		(cAlias)->( DbCloseArea() )
		
		if !lError 
		
			if lIndex 
				fErase( cFileBkpIndex )
			endif						
			
		else 
			if lIndex 

				fRename( cFileBkpIndex, cFileIndex )
			endif		
		endif
		
	//	Creem index 

	oDom:TableSetData( 'brwindexes', aRows )	
	
	oDom:SetJs( 'MsgLoading(false)' )
	
retu nil 

// -------------------------------------------------- //

static function OpenDbf( cFileDbf, hOptions )	// cFileDbf, cCodepage )

	static n := 1
	
	local lOpened 		:= .f.
	local cAlias 		:= ''
	local hBag 			:= {=>}
	local i 			:= 1
	local cFileIndex , lIndex, cBagName, cKey 
	
	if !file( cFileDbf )
		retu lOpened
	endif
	
	cFileIndex := hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.cdx'
	cAlias 		:= NewAlias( hb_FNameName( cFileDbf ) )
		
	use ( cFileDbf ) shared new alias (cAlias) VIA 'DBFCDX' 

	lOpened := Used()
	
	if lOpened 
	
		cFileIndex 	:= hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.cdx'
			
		//	Check index
			
			lIndex := file( cFileIndex ) 
			
			if lIndex 
			
				cBagName := hb_FNameName( cFileIndex )
			
				SET INDEX TO ( cFileIndex )
				
				while !empty( ( cKey := (cAlias)->( OrdKey(i) ) ) )						
					hBag[ (cAlias)->( OrdName(i) ) ] := cKey
					i++
				end 			

			
			endif
	
	endif 
	
	
retu lOpened