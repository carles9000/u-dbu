#include 'lib\uhttpd2\uhttpd2.ch'
#include 'dbinfo.ch' 

function Api_Structure( oDom )

	do case	
		
		case oDom:GetProc() == 'add'			; AddField( oDom )								
		case oDom:GetProc() == 'del'			; DelField( oDom )								
		case oDom:GetProc() == 'edit'			; EditField( oDom )								
		case oDom:GetProc() == 'type'			; TypeField( oDom )								
		
		case oDom:GetProc() == 'new_dbf'		; New_Dbf( oDom )								
		case oDom:GetProc() == 'info'			; Info( oDom )								
		
		case oDom:GetProc() == 'dlg_select_dbf'; Dlg_Select_Dbf( oDom )								
		case oDom:GetProc() == 'dlg_create_dbf'; Dlg_Create_Dbf( oDom )								
		case oDom:GetProc() == 'create_dbf'	; Create_Dbf( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function AddField( oDom )

	local hInfo 	:= {=>}
	local aRows 	:= {}
	local cType    := ''
	local hStr, hData, nPos, cSearch, hRow
	

	//	Recover data info 
	
		hInfo[ 'field' ] 	:= oDom:Get( 'field' ) 
		hInfo[ 'type' ] 	:= oDom:Get( 'type' ) 
		hInfo[ 'len' ] 		:= Val( oDom:Get( 'len' ) )
		hInfo[ 'dec' ] 		:= Val( oDom:Get( 'dec' ) )

		//	TGrid Data
	
		hStr 				:= oDom:Get( 'brwstr' )
		hData 				:= hStr[ 'data' ]
		
	//	Validating info 
	
		if empty( hInfo[ 'field' ] )
			oDom:SetAlert( 'Field: Empty field' )
			oDom:Focus( 'field' )
			retu nil
		endif
		
		if hInfo[ 'len' ] <= 0
			oDom:SetAlert( 'Len: Value must be > 0' )
			oDom:Focus( 'len' )
			retu nil
		endif	
		
		if hInfo[ 'dec' ] < 0 .or.  hInfo[ 'dec' ] > 4
			oDom:SetAlert( 'Dec: Len must between [0..4]' )
			oDom:Focus( 'dec' )
			retu nil
		endif			

		//	Grid...
		
		cSearch := upper( hInfo[ 'field' ] )

		
		HB_HCaseMatch( hData, .f. )
		nPos := HB_HScan( hData, {|key,value,pos| upper( value['field'] ) == cSearch } )

	
	//	Finally we can send comands to dom...		
		
		Aadd( aRows, { ;
						'field' => hInfo[ 'field' ] ,;
						'type' => TypeKey2Text( hInfo[ 'type' ] ) ,;
						'len' => hInfo[ 'len' ] ,;
						'dec' => hInfo[ 'dec' ] ;
					})
		
	
		if nPos > 0

			hRow := HB_HValueAt( hData, nPos )
			
			if hRow[ 'field' ] != aRows[1][ 'field' ] .or. ;
			   hRow[ 'type' ] != aRows[1][ 'type' ] .or. ;
			   hRow[ 'len' ] != aRows[1][ 'len' ] .or. ;
			   hRow[ 'dec' ] != aRows[1][ 'dec' ] 
			
				oDom:TableUpdateRow( 'brwstr', hInfo[ 'field' ], aRows[1] )			
				oDom:SetJS( "MsgNotify( 'Field updated!')" )
				
			endif 
			
		else
			oDom:TableAddData( 'brwstr', aRows )	
			oDom:SetJS( "MsgNotify( 'New field was added')" )
		endif

retu nil

// -------------------------------------------------- //

static function DelField( oDom )

	local hStr	:= oDom:Get( 'brwstr' )
	local hRow	:= hStr[ 'selected' ]
		
	if len( hRow) == 1	
		oDom:SetTable( 'brwstr', 'deleteRow', { 'ids' => hRow[1][ 'field' ] }, 'Delete row?' )						
	endif		
	
retu nil 

// -------------------------------------------------- //

static function EditField( oDom )

	local hStr	:= oDom:Get( 'brwstr' )
	local hRow	:= hStr[ 'selected' ]
	local cType 
		
	if len( hRow ) == 1	
	
		cType := TypeText2Key( hRow[1][ 'type' ] )
	
		oDom:Set( 'field'	, hRow[1][ 'field'] )
		oDom:Set( 'type'	, cType )
		oDom:Set( 'len'		, hRow[1][ 'len'  ] )
		oDom:Set( 'dec'		, hRow[1][ 'dec'  ] )
		
		TypeField( oDom, cType )
		
	endif
	
retu nil 

// -------------------------------------------------- //

function TypeText2Key( cText )

	local cKey := ''

	cText := lower( cText )

	do case
		case cText == 'character' ; cKey := 'C'
		case cText == 'numeric'   ; cKey := 'N'
		case cText == 'logic'     ; cKey := 'L'
		case cText == 'date'      ; cKey := 'D'
		case cText == 'memo'      ; cKey := 'M'
	endcase
	
retu cKey	

// -------------------------------------------------- //

function TypeKey2Text( cKey )

	local cText := ''

	cKey := upper( cKey )

	do case
		case cKey == 'C' ; cText := 'Character' 
		case cKey == 'N' ; cText := 'Numeric'   
		case cKey == 'L' ; cText := 'Logic'     
		case cKey == 'D' ; cText := 'Date'      
		case cKey == 'M' ; cText := 'Memo'      
	endcase
	
retu cText	

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
	//oDom:Hide( 'grp_file' )

retu nil 

// -------------------------------------------------- //

static function Dlg_Select_Dbf( oDom )

	local hParam 	:= { 'action' => 'go_struct', 'codepage' => .f. }
	local cHtml 	:= ULoadHtml( 'dbu\sc_seldbf.html', hParam )
	
	oDom:SetDialog( 'dlg_seldbf', cHtml, 'Select Table...' )

retu nil 

// -------------------------------------------------- //

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

function TableInfo( cFileDbf, cError )		

	local cAlias 	:= NewAlias()
	local aInfo 	:= {}
	local lOpened 	:= .f.
	local oError, cHtml
	local cFileIndex, cInfoTable, cFileMemo, uValue, nTotal, nTotal_Ok, nDel
	
	
	cError := ''

	if empty( cFileDbf )
		cError := 'Not file'
		retu nil 
	endif 
	
	if ! File( cFileDbf )
		cError := 'File not exist'
		retu nil	
	endif
	
		try 
	
			USE (cFileDbf) NEW READONLY ALIAS (cALias) VIA 'DBFCDX' CODEPAGE 'CP850'
			
			lOpened := used() 
			
		catch oError 
		
			cError := 'Error: ' + oError:description + ', Operation: ' + HB_CStr( oError:operation) 						
			
			retu nil 
	end 		
	
	if !lOpened 
		cError := 'Error apertura' 
		retu nil 
	endif		
	
	uValue := directory( cFileDbf )[1][2]
	uValue := Transform( uValue , '99,999,999,999') + ' Kb.'
	
	Aadd( aInfo, { 'tag' => 'Table', 'value' => lower(hb_FNameNameExt( cFileDbf )), 'cargo' => uValue } )
	
	cFileIndex := hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.cdx'

	if file( cFileIndex )		
		uValue := directory( cFileIndex )[1][2]
		uValue := Transform( uValue , '99,999,999,999') + ' Kb.'
		Aadd( aInfo, { 'tag' => 'Index', 'value' => lower(hb_FNameNameExt(cFileIndex)), 'cargo' => uValue } )
	endif
	
	cFileMemo := hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.fpt'
			
	if file( cFileMemo )		
	
		uValue := directory( cFileMemo )[1][2]
		uValue := Transform( uValue , '99,999,999,999') + ' Kb.'	
	
		Aadd( aInfo, { 'tag' => 'Memo', 'value' => lower(hb_FNameNameExt(cFileMemo)), 'cargo' => uvalue } )
	endif	

	Set DELETED ON 
	
	nTotal := (cAlias)->( RecCount() )
	
	(cAlias)->( DbGoTop() )
	
	Aadd( aInfo, { 'tag' => 'Total Registers', 'value' => Transform( nTotal , '99,999,999,999'), 'cargo' => '' } )
	
	COUNT To nTotal_Ok
	
	nDel := nTotal - nTotal_Ok
	
	Aadd( aInfo, { 'tag' => 'Registers', 'value' => Transform( nTotal_Ok , '99,999,999,999'), 'cargo' => '' } )
	Aadd( aInfo, { 'tag' => 'Deleted', 'value' => Transform( nDel , '99,999,999,999'), 'cargo' => '' } )
	
	uValue := Transform( (cAlias)->( FCount() ) , '999')
	
	Aadd( aInfo, { 'tag' => 'Fields', 'value' => uValue, 'cargo' => '' } )
	
	//	--------------------------------------------------	//		

retu aInfo 

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

static function Create_Dbf( oDom )		
	
	local cRepo    := oDom:Get( 'repo' )
	local cPath 	:= AppRepo2Path( cRepo ) 
	local cFile    := oDom:Get( 'file' )
	local hBrowse	:= oDom:Get( 'brwstr' )
	local hFields 	:= hBrowse[ 'data' ]
	local aFields  := {}
	local i 		:= 1
	local cKey 		:= ''
	local nTags 	:= 0
	local nRows 	:= 0
	local hBag 		:= {=>}
	local lOk 		:= .f.
	local oError
	local cFileDbf, cNewFileDbf, cNewFileIndex, cFileIndex, cFileMemo, cNewFileMemo
	local cAlias, cAliasTmp, lIndex, lMemo, cBagName
	local n, j, h, nTypeMemo, cExtMemo 
	
	//	Validating parameters
	
		if empty( cRepo )
			oDom:SetMsg( "Don't exist reporitory")
			oDom:SetJS( "MsgLoading(false)" )
			retu nil
		endif
		
		if empty( cFile )
			oDom:SetMsg( "Don't exist file")
			oDom:SetJS( "MsgLoading(false)" )
			retu nil
		endif

		if len( hFields ) == 0
			oDom:SetMsg( "Don't exist fields")
			oDom:SetJS( "MsgLoading(false)" )
			retu nil
		endif		
		
		for n :=  1 to len( hFields )
			h := HB_HValueAt( hFields, n )
			Aadd( aFields, { h[ 'field' ], h[ 'type' ], h[ 'len' ], h['dec' ] } )
		next
		
	//	Initialiting variables
	
		cFileDbf 	:= cPath + '\' + cFile
	
	
	//	Validate Structure 
	
	
	//	Init Process...
	
	//	a) If new table, only create structure
	
		if ! file( cFileDbf )
		
			try
				dbCreate( cFileDbf, aFields, 'DBFCDX' ) 
			catch oError 
				
				oDom:SetJS( "MsgLoading(false)" )
				oDom:SetError( oError:description )
				
				retu nil
			end		
			
			oDom:SetMsg( 'Done!')
		
		else 							

			// Abrimos en exclusiva original 
			
				cAlias 	:= NewAlias()
			
				USE (cFileDbf) shared ALIAS (cAlias) VIA 'DBFCDX'
			
		
			//	Init vars
			
				cNewFileDbf 	:= hb_FNameDir( cFileDbf ) + 'UDBU' + hb_FNameNameExt( cFileDbf )			
				cFileIndex 	:= hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + '.cdx'
			
			
			//	Check index
			
				lIndex := file( cFileIndex ) 
			
				if lIndex 
				
					cBagName := hb_FNameName( cFileDbf )
				
					SET INDEX TO ( cFileIndex )
					
					while !empty( ( cKey := (cAlias)->( OrdKey(i) ) ) )						
						hBag[ (cAlias)->( OrdName(i) ) ] := cKey
						i++
					end 								
				
				endif 						
			
				cNewFileIndex := hb_FNameDir( cFileDbf ) + 'UDBU' + hb_FNameName( cFileDbf ) + '.cdx'												
			
			//	Delete temporal old index files  (if existed)
							
				fErase( cNewFileIndex )				
				
			//	Create new table 						
			
				try
					dbCreate( cNewFileDbf, aFields, 'DBFCDX' ) 
				catch oError 					
					oDom:SetError( oError:description )
					oDom:SetJS( "MsgLoading(false)" )
					retu nil
				end
			
			// Open new table
			
				cAliasTmp 	:= NewAlias()
				
				USE (cNewFileDbf) NEW ALIAS (cAliasTmp)
				
				
			//	Append records from original file
			
				try			
					nRows := (cAlias)->( RecCount() )
					(cAliasTmp)->( DbGoTop() )
					
					APPEND FROM (cFileDbf)	
				catch oError 
					oDom:SetJS( "MsgLoading(false)" )
					oDom:SetError( oError:description )
					retu nil
				end		

			//	If exist, we'll create index
			
			if lIndex

				lOk 	:= .f. 
				nTags 	:= len( hBag )
				n 		:= 1
				
				while !lOk .and. n < nTags
				
					h := HB_HPairAt( hBag, n )
					
					try 
					
						(cAliasTmp)->( OrdCreate( cNewFileIndex, h[1], h[2] ) )
						lOk := .t.
					
					
					catch oError					
						_d( 'Error creant index: ' + oError:description )
					end																						
			
					n++
				end 				
			
				for j := n to nTags
				
					h := HB_HPairAt( hBag, j )					
				
					try 
						
						INDEX ON &(h[2]) TAG  &(h[1]) TO &(cNewFileIndex)
					
						
					catch oError 					
						_d( oError )
					end 
					
				next 										
			
			endif 
			
			//	Check memo in new structure
			
				nTypeMemo := (cAlias)->( DbInfo( DBI_MEMOTYPE ) )
				
				do case
					case nTypeMemo ==  DB_MEMO_DBT ; cExtMemo := '.dbt'
					case nTypeMemo ==  DB_MEMO_FPT ; cExtMemo := '.fpt'
					case nTypeMemo ==  DB_MEMO_SMT ; cExtMemo := '.smt'
					otherwise
						cExtMemo := ''
				endcase
				
				cNewFileMemo 	:= hb_FNameDir( cFileDbf ) + 'UDBU' + hb_FNameName( cFileDbf ) + cExtMemo
				cFileMemo 		:= hb_FNameDir( cFileDbf ) + hb_FNameName( cFileDbf ) + cExtMemo				
				lMemo 			:= file( cNewFileMemo )																								
				
			
			//	Close original table and rename new table to original...
			
				(cAlias)->( DbCloseArea() )
				(cAliasTmp)->( DbCloseArea() )
				
			//	Rename new table to original table 
			
				lOk := .f.
			
				if fErase( cFileDbf ) == 0 
				
				
					
				
					fRename( cNewFileDbf, cFileDbf )
			
					//	If index, rename new index to original index
					
						if lIndex 
							fErase( cFileIndex )					
							fRename( cNewFileIndex, cFileIndex ) 
						endif
					
					
					//	if memo, rename new memo to original memo 
					
						if lMemo 
							fErase( cFileMemo )							
							fRename( cNewFileMemo, cFileMemo ) 
						else
						
							//	Si NO existe en la nueva estructura pero existia en la anterior, borramos
						
							if file( cFilememo )
								fErase( cFileMemo )							
							endif
						
						endif 
						
					//	Proc OK !
					
						lOk := .t.
						
				endif																				
		
		endif


	oDom:SetJS( "MsgLoading(false)" )
	
	if lOk 
		oDom:SetMsg( 'Done !')
	else
		oDom:SetMsg( 'Error creating new structure !')
	endif

retu nil 

