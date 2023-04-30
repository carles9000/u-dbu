#include 'lib\uhttpd2\uhttpd2.ch'
#include "lib\tweb\tweb.ch" 
#include 'dbinfo.ch' 

function Api_Browse( oDom )

	//	Acceso a API Security
		if ! USessionReady()
			URedirect( 'login' )
			retu nil
		endif	

	do case	
		
		case oDom:GetProc() == 'dlg_select_dbf'	; Dlg_Select_Dbf( oDom )								
		case oDom:GetProc() == 'dlg_filter'		; Dlg_Filter( oDom )	
		
		case oDom:GetProc() == 'init'				; Dbu_Init( oDom )								
		case oDom:GetProc() == 'update'			; Dbu_Update( oDom )
		case oDom:GetProc() == 'top'				; Dbu_Top( oDom )
		case oDom:GetProc() == 'prev'				; Dbu_Prev( oDom )
		case oDom:GetProc() == 'next'				; Dbu_Next( oDom )
		case oDom:GetProc() == 'end'				; Dbu_End( oDom )
		case oDom:GetProc() == 'close'				; Dbu_Close( oDom )								
		case oDom:GetProc() == 'new_ordername'		; Dbu_NewOrderName( oDom )								
		case oDom:GetProc() == 'refresh'			; Dbu_Refresh( oDom )								
		case oDom:GetProc() == 'info'				; Dbu_Info( oDom )			
		case oDom:GetProc() == 'del'				; Dbu_Del( oDom )	
		case oDom:GetProc() == 'new'				; Dbu_Append( oDom )	
		case oDom:GetProc() == 'print'				; Dbu_Print( oDom )	
		case oDom:GetProc() == 'to_xls'			; Dbu_To_Xls( oDom )	
		case oDom:GetProc() == 'goto'				; Dbu_Goto( oDom )	
		
		case oDom:GetProc() == 'exe_filter'		; Dbu_ExeFilter( oDom )	
		case oDom:GetProc() == 'filter'			; Dbu_Filter( oDom )	
		
		case oDom:GetProc() == 'setdeleted'		; Dbu_SetDeleted( oDom )	
		case oDom:GetProc() == 'clean'				; oDom:TableClean( 'brwdata' )				
		
		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function Dlg_Select_Dbf( oDom )

	local hParam 	:= { 'action' => 'go_browse' , 'codepage' => .t. }
	local cHtml 	:= ULoadHtml( 'dbu\sc_seldbf.html', hParam )	
	
	oDom:SetDialog( 'dlg_seldbf', cHtml, 'Select Table...' )

retu nil 

// -------------------------------------------------- //

static function Dlg_Filter( oDom )
	
	local cHtml 		:= ''
	local cTableToken	:= oDom:Get( 'tabletoken' )
	local cFilter, hFile
	
	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------f

	hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
	
	cFilter := hFile[ 'filter' ]
	
	cHtml 	:= ULoadHtml( 'dbu\sc_filter.html', cFilter  )	
	
	oDom:SetDialog( 'dlg_filter', cHtml, 'Filter...' )

retu nil 

// -------------------------------------------------- //

static function Dbu_Init( oDom )

	local cRepo 	:= oDom:Get( 'repo')		//'c:\uhttpd2.dbu\data\test.dbf' //
	local cFile 	:= oDom:Get( 'file')		//'c:\uhttpd2.dbu\data\test.dbf' //
	local cCodepage := oDom:Get( 'codepage')	
	local lDeleted := oDom:Get( 'deleted')	
	local nRows 	:= 20	// Val( oDom:Get( 'pages' )
	local i 		:= 1
	local hFile	:= {=>}
	local aBag 		:= {}
	local cAlias, aStr, aColumns, hFiles, arows, cToken, hConfig, aEvents, cInfo, cHtml, cBag, cTitle
		
	if empty( cFile )
		retu nil 
	endif 
	
	//	Init Session vars...
	
		USessionStart()
		
		hFiles := USession( 'files' )
		
		if valtype( hFiles ) <> 'H'
			USession( 'files', {=>} )
		endif

	
	//	Open Dbf
	
		hFile[ 'page'] := 1
		hFile[ 'page_size'] := nRows 
		hFile[ 'repo'] := cRepo
		hFile[ 'file'] := cFile 
		hFile[ 'codepage'] := cCodepage		//	Default
		hFile[ 'ordername'] := ''
		hFile[ 'deleted'] := lDeleted
		hFile[ 'filter'] := ''
	
		cAlias := OpenDbf( hFile )
		
		if empty( cAlias )
			retu nil 
		endif
		
		cToken := TokenFile()
		
	
	//	Recover Info 
	
		hFile[ 'reccount' ] 	:= (cAlias)->( RecCount())
		hFile[ 'page_total' ] 	:= Int( hFile[ 'reccount' ] / hFile[ 'page_size' ] ) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )
		
	
		aStr := (cAlias)->( DbStruct() )	
		
		hFile[ 'str' ] := aStr 
		
		Aadd( aBag, '' ) 	//'Natural Order' )
		
		while !empty( ( cBag := (cAlias)->( OrdName(i)  ) ) )						
			Aadd( aBag, cBag )
			i++
		end 			
		
		hFile[ 'bag'] := aBag 			

		USession( 'files' )[ cToken ] := hFile			
		
	//	Build Header Browse
	
		aColumns := Str2Header( cAlias, aStr )		

	//	Load row data...
	
		aRows 	:= GetRows( cAlias, 1, nRows, aStr )	
		

	//	Setup browse 

		hConfig := { ;
				'index' => '_recno',;								
				'height' => '400px',	;				
				'columns' => aColumns, ;								
				'data' => aRows,;
				'printAsHtml' => .t.,; 		//enable html table printing
				'printStyled' => .t.,; 		//copy Tabulator styling to HTML table
				'printRowRange' => "all",;
				'movableColumns' => .T.,;
				'selectableRollingSelection' => .T.,;
				'selectable' => .t.,;
				'selectableRangeMode' => "click";					
		}
			
		aEvents := { { 'name' => 'cellEdited' , 'proc' => 'update'} }		

		oDom:TableInit( 'brwdata', hConfig, aEvents )	

		oDom:Set( 'bag', aBag)

		cTitle := '<h4><i class="fa fa-database" aria-hidden="true"></i>&nbsp;' + hb_FNameNameExt( cFile ) 
		cTitle += '<span style="float: right;font-size: small;margin-top: 10px;">Codepage: ' + cCodepage + '</span>'
		cTitle += '</h4>'

		Dbu_RefreshInfo( oDom, hFile )
		
		oDom:Set( 'header_file', cTitle  )
		oDom:Show( 'header' )
		oDom:Show( 'brwdata' )
		oDom:Show( 'brwbar' )				
		
	oDom:Set( 'tabletoken', cToken )			
	
retu nil 

// -------------------------------------------------- //

static function Dbu_Close( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local hFiles 

	oDom:Hide( 'header' )	
	oDom:Hide( 'brwbar' )	
	oDom:TableDestroy( 'brwdata' )	

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------

		
	hFiles := USession( "files" )
		
	if HB_HHasKey( hFiles, cTableToken )
		HB_HDel( hFiles, cTableToken )
	endif
	
	USession( "files" , hFiles )
	
	oDom:Set( 'tabletoken', '' )

	
retu nil 

// -------------------------------------------------- //

/*	Cuando usamos el metodo 'cellEdit' (ver Dbu_Init()), cada vez que editemos una celda 
	el sistema creara una petición a nuestra api, en este caso 'update'
	
	aEvents := { { 'name' => 'cellEdited' , 'proc' => 'update'} }	
	
	En este caso recibiremos un parametro cell, con diversa información de la celda editada.
	La mejor manera de conocerla es debugar este parametro para ver su contenido
	
	--------------------------------------------------------------------------------------
	
	When we use the 'cellEdit' method (see Dbu_Init()), every time we edit a cell
	the system will create a request to our api, in this case 'update'

	aEvents := { { 'name' => 'cellEdited' , 'proc' => 'update'} }

	In this case we will receive a cell parameter, with various information about the edited cell.
	The best way to know it is to debug this parameter to see its content.		
*/

static function Dbu_Update( oDom )
	
	local lOK  			:= .F.
	local cMsg 			:= ''	
	local cTableToken	:= oDom:Get( 'tabletoken' )
	local oCell 		:= oDom:Get( 'cell' )
	local cField 		:= oCell[ 'field' ]
	local uValue 		:= oCell[ 'value' ]
	local nRecno 		:= oCell[ 'row' ][ '_recno' ]
	local cAlias, cFile, nPos, aStr, nField 	
	local nIndex, hFile, oError			
		
	//	You need to know parameteres received from client. The best solution is 
	//  checking to debug it, in special 'cell' parameter.	
	
		_d( oCell )		

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------

		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile )					//	Open Dbf
		aStr 	:= hFile[ 'str' ]					 		// Recover structure, the same aStr := (cAlias)->( DbStruct() )
		
	//	Valid edited field
	
		nField  := Ascan( aStr, {|a| lower(a[ 1 ]) == lower(cField) } )
		
		if nField == 0 
			oDom:SetAlert( 'Field not exist: ' + cField )
			retu nil	
		endif

		if valtype( uValue ) != aStr[nField][2]
		
			do case
				case aStr[nField][2] == 'D' ; uValue := CToD( uValue )
				case aStr[nField][2] == 'M' ; uValue := Alltrim( uValue )
				otherwise
					oDom:SetMsg( 'Type field error: ' + cField + ' => ' + valtype( uValue ) )
					retu nil	
			endcase
		endif


	//	Save data field
	
		nPos := (cAlias)->( FieldPos( cField ) )

		(cAlias)->( DbGoTo( nRecno ) )

		if (cAlias)->( DbRLock() )
		
			try
		
				(cAlias)->( FieldPut( nPos, uValue ) ) 
				(cAlias)->( DbUnlock() )		
			
				lOk := .t.			
				
			catch oError
			
				cMsg := oError:description 												
				
			end 
			
		else		
			cMsg := 'Lock error...'			
		endif

	//	Control browse dom 
	
		oDom:SetData( { 'updated' => lOk , 'msg' => cMsg } )
		oDom:TableClearEdited( 'brwdata' )
		
		Dbu_RefreshInfo( oDom, hFile )		
		
retu nil

// -------------------------------------------------- //

static function Dbu_Goto( oDom )
	
	local cTableToken	:= oDom:Get( 'tabletoken' )
	local nRecno 		:= Val( oDom:Get( 'recno' ) )
	local hFile, cAlias, nTotal

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------

		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile )					//	Open Dbf
		
		nTotal := (cAlias)->( RecCount() )
		
		if nRecno <= 0 .or. nRecno > nTotal
			oDom:SetMsg( 'Out of range')
			retu nil 
		endif 
		 
		(cAlias)->( DbCloseArea() )	
		
		Dbu_Refresh( oDom, nRecno )
		
		oDom:Set( 'recno', '' )
		
retu nil 

// -------------------------------------------------- //

static function Dbu_ExeFilter( oDom )	

	local cFilter 		:= oDom:Get( 'filter' ) 
	local nMax_Reg 	:= Val( oDom:Get( 'max_reg') )

	oDom:SetJS( "MsgLoading( 'Filtering, please wait...')" )			
	oDom:DialogClose( 'dlg_filter' )
	oDom:MsgApi( 'api_browse', 'filter', { 'filter' => cFilter, 'max_reg' => nMax_Reg }, 'browse' )
		
retu nil 

// -------------------------------------------------- //

static function Dbu_Filter( oDom )	

	local cFilter 		:= oDom:Get( 'filter' ) 
	local cTableToken	:= oDom:Get( 'tabletoken' )
	local hFile, cAlias, bFilter, n, u, nFields, aStr
	local oError
	local aRows := {}
	local nLapsus , nTotal
	local nMax_Reg 	:= oDom:Get( 'max_reg') 
	
	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------

		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		hFile[ 'filter' ] := cFilter
		cAlias 	:= OpenDbf( hFile )					//	Open Dbf
		
		( cAlias )->( DbGoTop() )					
		
		try 
	
			bFilter := (cAlias)->( &( '{|| ' + cFilter + '}' ) )
			
			u := (cAlias)->( eval( bFilter ) )
		
		catch oError 
		
			oDom:SetMsg( oError:description  )
			oDom:SetJS( 'MsgLoading(false)' )
			retu nil 
		
		end
		
		if valtype( u ) != 'L'
			oDom:SetMsg( 'Expresión no logic' )
			oDom:SetJS( 'MsgLoading(false)' )
			retu nil 
		endif
		
		nFields	:= (cAlias)->( FCount() )
		aStr 	:= (cAlias)->(DbStruct())
		
		nLapsus := Seconds()
		nTotal  := (cAlias)->( RecCount() )
		
		try 
		
			n := 0
			
			(cAlias)->( DbGotop())
			
			while n < nMax_Reg .and. (cAlias)->( !eof() )
		
				if (cAlias)->( eval( bFilter )) 
					Aadd( aRows, LoadRow( cAlias, nFields, aStr ) )
					n++
				endif
				
				(cAlias)->( DbSkip() )
		
			end 
			
		catch oError 
		
			oDom:SetMsg( oError:description  )
		
		end 
		
		nLapsus := Seconds() - nLapsus 
		
	oDom:Set( 'info', 'Rows: ' + ltrim(str(len(aRows))) + ' of ' + Transform( nTotal , '99,999,999,999') + ' / Lapsed: ' + ltrim(str(nLapsus)) + ' sec.' )
	oDom:Hide( 'btn_top' )
	oDom:Hide( 'btn_prev' )
	oDom:Hide( 'page' )
	oDom:Hide( 'btn_next' )
	oDom:Hide( 'btn_end' )
	
	oDom:TableSetData( 'brwdata', aRows )
	oDom:SetJS( 'MsgLoading(false)' )	

retu nil 

// -------------------------------------------------- //

static function Dbu_Del( oDom )
	
	local cAlias, cFile, nPos, aStr, nField 	
	local lOK  	:= .F.
	local cMsg 	:= ''	
	local cTableToken	:= oDom:Get( 'tabletoken' )
	local hStr 			:= oDom:Get( 'brwdata' )
	local aSelected	:= hStr[ 'selected' ]
	local hFile, n 

	if Len( aSelected ) == 0
		retu nil
	endif

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------

		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile )					//	Open Dbf
		
	//	Delete register
	
		for n := 1 to len( aSelected )

			(cAlias)->( DbGoto(  aSelected[n][ '_recno' ] ) )
			
			if (cAlias)->( Rlock() )
				if (cAlias)->( Deleted() )
					(cAlias)->( DbRecall() )
				else
					(cAlias)->( DbDelete() )
				endif
				
				(cAlias)->( DbUnlock() )
			endif
		
		next 

	Dbu_Refresh( oDom )

	oDom:SetData( { 'sel' => aSelected } )							
		
retu nil

// -------------------------------------------------- //

static function Dbu_Append( oDom )
	
	local cTableToken	:= oDom:Get( 'tabletoken' )
	local cAlias	

	local hFile, n, nrecno, nLogical

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------

		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile )					//	Open Dbf
		
		(cAlias)->( DbAppend() )
		
		if empty( (cAlias)->( OrdSetFocus()) )
			nRecno := (cAlias)->( Recno() ) 
		else
			nRecno := (cAlias)->( OrdKeyNo() ) 
		endif
	
		Dbu_Refresh( oDom, nRecno )
	
retu nil

// -------------------------------------------------- //

static function Dbu_Print( oDom )	

	local cTableToken	:= oDom:Get( 'tabletoken' )			

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
	
	oDom:TablePrint( 'brwdata', 'aaa', 'bbb')
	
retu nil

// -------------------------------------------------- //

static function Dbu_To_Xls( oDom )	

	local cTableToken	:= oDom:Get( 'tabletoken' )			

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
	
	oDom:TableDownload( 'brwdata', 'xlsx', 'dbu.xlsx')
	
retu nil

// -------------------------------------------------- //

static function Dbu_Top( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local aRows 		:= {}
	local cAlias, hFile, aStr
	local nPage	


	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
		
		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile  )					//	Open Dbf
		aStr 	:= hFile[ 'str' ]					 
	
		nPage 	:= 1
		
		hFile[ 'reccount' ] 	:= (cAlias)->( RecCount() ) 
		hFile[ 'page_total' ] := Int( hFile[ 'reccount' ] / hFile[ 'page_size' ] ) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )
		
		aRows  	:= GetRows( cAlias, ((nPage-1)*hFile[ 'page_size' ])+1, hFile[ 'page_size' ], aStr ) 											
		
	hFile[ 'page' ] := nPage

	oDom:TableSetData( 'brwdata', aRows )				
	
	Dbu_RefreshInfo( oDom, hFile )
	
	USession( "files" )[ cTableToken ] := hFile 	
		
retu nil 

// -------------------------------------------------- //

static function Dbu_End( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local aRows 		:= {}	
	local cAlias, hFile, aStr, nPage	

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
		
		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile  )					//	Open Dbf
		aStr 	:= hFile[ 'str' ]				
	
		hFile[ 'reccount' ] 	:= (cAlias)->( RecCount() ) 
		hFile[ 'page_total' ] 	:= Int( hFile[ 'reccount' ] / hFile[ 'page_size' ] ) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )
		nPage 		 := hFile[ 'page_total' ]
		
		aRows  	:= GetRows( cAlias, ((nPage-1)*hFile[ 'page_size' ])+1, hFile[ 'page_size' ], aStr ) 											
		
	hFile[ 'page' ] := nPage

	Dbu_RefreshInfo( oDom, hFile )	
	
	oDom:TableSetData( 'brwdata', aRows )	

	USession( "files" )[ cTableToken ] := hFile 	
		
retu nil 

// -------------------------------------------------- //

static function Dbu_Next( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local aRows 		:= {}
	local cAlias, hFile, aStr, nPage


	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------if
		
		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile  )					//	Open Dbf
		aStr 	:= hFile[ 'str' ]				

	
		nPage 	:= hFile[ 'page' ] + 1
		
		hFile[ 'reccount' ] 	:= (cAlias)->( RecCount() ) 
		hFile[ 'page_total' ] := Int( hFile[ 'reccount' ] / hFile[ 'page_size' ] ) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )
		
		if nPage > hFile[ 'page_total' ]
			nPage := hFile[ 'page_total' ]
		endif
		
		aRows  	:= GetRows( cAlias, ((nPage-1)*hFile[ 'page_size' ])+1, hFile[ 'page_size' ], aStr ) 	
				
	hFile[ 'page' ] := nPage					
	
	Dbu_RefreshInfo( oDom, hFile )	
	
	oDom:TableSetData( 'brwdata', aRows )	

	USession( "files" )[ cTableToken ] := hFile 	
		
retu nil 

// -------------------------------------------------- //

static function Dbu_RefreshInfo( oDom, hFile )

	local cInfo 		:= 'Pag. '
	
	oDom:Set( 'page', hFile[ 'page' ] )		
	
	cInfo := 'Reg. ' + Transform( hFile[ 'reccount'] , '99,999,999,999') + '/ Pag. ' + ltrim(str(hFile[ 'page_total' ]))	
	
	oDom:Show( 'btn_top' )
	oDom:Show( 'btn_prev' )
	oDom:Show( 'page' )
	oDom:Show( 'btn_next' )
	oDom:Show( 'btn_end' )	
	
	oDom:Set( 'info', cInfo )

retu nil 

// -------------------------------------------------- //

static function Dbu_Prev( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local aRows 		:= {}			
	local cAlias, hFile, aStr
	local nPage

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
		
		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile  )					//	Open Dbf
		aStr 	:= hFile[ 'str' ]			
	
		nPage 	:= hFile[ 'page' ] - 1
		nPage   := Max( 1, nPage )
		
		hFile[ 'reccount' ] 	:= (cAlias)->( RecCount() ) 
		hFile[ 'page_total' ] := Int( hFile[ 'reccount' ] / hFile[ 'page_size' ] ) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )

		aRows  	:= GetRows( cAlias, ((nPage-1)*hFile[ 'page_size' ])+1, hFile[ 'page_size' ], aStr ) 	

	hFile[ 'page' ] := nPage	
	
	Dbu_RefreshInfo( oDom, hFile )

	oDom:TableSetData( 'brwdata', aRows )				

	USession( "files" )[ cTableToken ] := hFile 	
		
retu nil 

// -------------------------------------------------- //

static function Dbu_Refresh( oDom, nRecno )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local aRows 		:= {}
	local cAlias, hFile, nPage, aStr

	hb_default( @nRecno, 0 )

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
		
		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
		cAlias 	:= OpenDbf( hFile  )				//	Open Dbf
		aStr 	:= hFile[ 'str' ]	

		hFile[ 'reccount' ] 	:= (cAlias)->( RecCount() ) 
		hFile[ 'page_total' ] := Int( hFile[ 'reccount' ] / hFile[ 'page_size' ] ) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )

		if nRecno > 0

			nPage 	:= Int( nRecno / hFile[ 'page_size' ]) + if( hFile[ 'reccount' ] % hFile[ 'page_size' ] == 0, 0, 1 )
			aRows  	:= GetRows( cAlias, nRecno, hFile[ 'page_size' ], aStr, .T. ) 
			
		else
		
			nPage 	:= hFile[ 'page' ]					
			
			if nPage > hFile[ 'page_total' ] 
				nPage := hFile[ 'page_total' ]
			endif
			
			aRows  	:= GetRows( cAlias, ((nPage-1)*hFile[ 'page_size' ])+1, hFile[ 'page_size' ], aStr ) 	
		endif
	
		
	hFile[ 'page' ] := nPage	
	USession( "files" )[ cTableToken ] := hFile 		
		
	Dbu_RefreshInfo( oDom, hFile )
	
	oDom:TableSetData( 'brwdata', aRows )	
	
retu nil

//	------------------------------------------------------------------- //

static function Dbu_Info( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local cRepo    		:= oDom:Get( 'repo' )
	local cPath 		:= AppRepo2Path( cRepo ) 
	local cFile    		:= oDom:Get( 'file' )
	local hCfg 			:= { 'size' => '300px' }
	local aInfo 		:= {}		
	local cError 		:= ''
	local cHtml, cInfoTable, hFile	

	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
		
	hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						
	aInfo 	:= TableInfo( hFile[ 'file' ], @cError )	
	
	if !empty( cError )
		oDom:SetMsg( cError )
	else	
		
		cInfoTable 	:= hFile[ 'repo' ] + ' - ' + hb_FNameNameExt(hFile[ 'file' ])
		cHtml 		:= ULoadHtml( 'dbu\sc_info.html', cInfoTable, aInfo )	
		oDom:SetDialog( 'dlg_info', cHtml, '<i class="fa fa-info-circle" aria-hidden="true"></i>&nbsp;Table information')
	endif		

retu nil

// -------------------------------------------------- //

static function Str2Header( cAlias, aStr )

	local aCols 	:= {}
	local nLen 		:= len( aStr )
	local hDel 		:= {=>}
	local n, cType, cEditor, cFormatter, cAlign, aValidator, hEditorParams
	
	
	hDel := { 'height' => '16', 'width' => '16', 'yes' => 'files/images/trash.png' }


	Aadd( aCols, { 'formatter' => "rowSelection", "titleFormatter" => "rowSelection", "hozAlign" => "center", "headerHozAlign" => "center", "headerSort" => .f., "width" => 20, 'print' => .F., 'download' => .f. } )
	Aadd( aCols, { 'title' => 'Recno',	'field' => '_recno'	, 'hozAlign' => 'center', 'print' => .F., 'download' => .f.})		
	Aadd( aCols, { 'title' => 'Del',	'field' => '_del'	, 'hozAlign' => 'center', 'formatter' => "UFormatLogic", 'formatterParams' => hDel, 'print' => .F., 'download' => .f. })	
		
		//http://tabulator.info/docs/5.3/validate#func-custom 
		
	for n := 1 to nLen 
	
		cType 		:= aStr[n][2]						
		cFormatter 	:= nil
		cEditor 	:= nil
		cAlign 		:= nil
		aValidator 	:= nil
		hEditorParams := nil 
		
		//aValidator[1] := { 'type' => 'noDivide', 'parameters' => { 'dummy' => 1 } } 				
		
		do case
			case cType == 'C' ;	cEditor := 'input'
			
			case cType == 'N' 
				cEditor 	:= 'number'
				cAlign 		:= "center"
				
			case cType == 'D' 
				cEditor 		:= 'input'
				heditorParams 	:= { 'mask' => "99/99/9999",;
									 'inputFormat' => "DD/MM/YYYY";
									}				
				
				cAlign 			:= "center"		
				aValidator 	:= { 'type' => 'UValidDate', 'parameters' => { 'inputFormat' => 'DD/MM/YYYY' } }

			case cType == 'L' 
				cEditor 	:= .T. 
				cFormatter 	:= "tickCross"
				cAlign 		:= "center"
				
			case cType == 'M' ;	cEditor := 'textarea'
		endcase
	
		Aadd( aCols, { 'title' => upper( aStr[n][1] ),;
						'field' => aStr[n][1] ,;
						'editor' => cEditor ,;
						'formatter' => cFormatter ,;
						'hozAlign' => cAlign ,;
						'validator' => aValidator,;
						'editorParams' => hEditorParams;
					})	
	next 
	
retu aCols

// -------------------------------------------------- //

static function Dbu_NewOrderName( oDom )

	local cTableToken	:= oDom:Get( 'tabletoken' )
	local cOrderName 	:= oDom:Get( 'bag' )
	local hFile
	
	//	Xec tabletoken 
	
		hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 	
	
	//	Xec ordbag 
	
	//	Save new order 
	
		hFile[ 'ordername' ] := cOrderName 
		
		USession( "files" )[ cTableToken ] := hFile 
		
	//	Refresh
	
		Dbu_Refresh( oDom )				
		
retu nil 

// -------------------------------------------------- //

static function GetRows( cAlias, nRecno, nTotal, aStr, lGo_Recno_Natural  )

	local aRows 	:= {}
	local n 		:= 0
	local nFields, uValue, j, hRow	

	hb_default( @lGo_Recno_Natural, .F. )

	if empty( (cAlias)->( ordSetFocus() ) ) .or. lGo_Recno_Natural
		(cAlias)->( DbGoto( nRecno ) )	
	else
		(cAlias)->( OrdKeyGoto( nRecno ) )		
	endif
	
	nFields	:= len( aStr )		
	
	while n < nTotal .and. (cAlias)->( !eof() ) 
	
		hRow := LoadRow( cAlias, nFields, aStr )

		Aadd( aRows, hRow ) 
	
		(cAlias)->( DbSkip() )
		n++
	end 			
	
retu aRows 

// -------------------------------------------------- //

static function LoadRow( cAlias, nFields, aStr ) 

	local hRow := {=>}			
	local j, uValue
	
	hb_default( @nFields, (cAlias)->( FCount() ) )
		
	HB_HSet( hRow, '_recno' 	, (cAlias)->( Recno() ) )
	HB_HSet( hRow, '_del' 		, (cAlias)->( Deleted() ) )
	
	for j := 1 to nFields

		do case
			case aStr[j][2] == 'C'	
				uValue := hb_strtoUtf8(  Alltrim( (cAlias)->( FieldGet( j ))) )
				HB_HSet( hRow, (cAlias)->( FieldName( j ) ), uValue ) 
			case aStr[j][2] == 'D'							
				HB_HSet( hRow, (cAlias)->( FieldName( j ) ), DTOC( (cAlias)->( FieldGet( j ) ) ) ) 
			otherwise				
				HB_HSet( hRow, (cAlias)->( FieldName( j ) ), (cAlias)->( FieldGet( j ) ) ) 
		endcase
	
	next

retu hRow

// -------------------------------------------------- //

static function Dbu_SetDeleted( oDom )

	local lSetDeleted 	:= oDom:Get( 'deleted')
	local cTableToken	:= oDom:Get( 'tabletoken' )	
	local hFile 
	
	//	Validate Token...	

		if !ValidateToken( cTableToken )
			retu nil
		endif
		
	//	---------------------------------
		
	hFile 	:= USession( "files" )[ cTableToken ] 	//	Recover info from session 						

	hFile[ 'deleted' ] := lSetDeleted
	USession( "files" )[ cTableToken ] := hFile 	

	Dbu_Refresh( oDom )

retu nil 

// -------------------------------------------------- //

static function OpenDbf( hFile )	// cFile, cCodepage )

	static n := 1
	
	local cAlias 		:= ''
	local cFileIndex 
	
	if !file( hFile[ 'file' ] )
		retu cAlias 
	endif
	
	cFileIndex := hb_FNameDir( hFile[ 'file' ] ) + hb_FNameName( hFile[ 'file' ] ) + '.cdx'
	cAlias 		:= NewAlias( hb_FNameName( hFile[ 'file' ] ) )
		
	Set( _SET_DELETED, hFile[ 'deleted' ] )
	
	use ( hFile[ 'file' ] ) shared new alias (cAlias) VIA 'DBFCDX' CODEPAGE hFile[ 'codepage' ]
	
	if file( cFileIndex )
	
		set index to (cFileIndex)
		
		if empty( hFile[ 'ordername' ] )		
			(cAlias)->( ordSetFocus(0) ) 
		else
			(cAlias)->( ordSetFocus(hFile[ 'ordername' ]) ) 
		endif
		
	endif		
	
retu if( used(), cAlias, '' )

// -------------------------------------------------- //

function TokenFile()

	static n := 1
	
retu 'TOK-' + ltrim(str(++n)) 

// -------------------------------------------------- //

function ValidateToken( cToken )

	local hSession := USessionAll()
	
	if ! HB_HHasKey( hSession, 'files' ) .or. ;
	   ! HB_HHasKey( hSession[ 'files' ], cToken )
		 
		//oDom:SetMsg( 'Error tabletoken' )
		retu .f.
	endif

retu .t. 