function CheckIni()

	LOCAL cFileIni	:= HB_DIRBASE() + 'app.ini'
	LOCAL hIni 		:= hb_iniRead( HB_DIRBASE() + 'app.ini', .F. )
	LOCAl hConfig 	:= {=>}
	
	if file( cFileIni )	
	
		hIni := hb_iniRead( cFileIni, .F. )
	
		hConfig[ 'port' ] := Val( IniLoad( hIni, 'main', 'port' ) )
	else
		hConfig[ 'port' ] := 81
	endif

retu hConfig 

// -------------------------------------------------- //

function CheckDbfs()

	if !file( AppPathData() + 'users.dbf' )
		InitDbfUsers()
	endif
	
	if !file( AppPathData() + 'repository.dbf' )
		InitDbfRepository()
	endif	
	
retu nil 

// -------------------------------------------------- //

static function IniLoad( hIni, cGroup, cLabel )

	local uValue := ''

	hb_default( @cGroup, '' )
	hb_default( @cLabel, '' )

	if !empty( cGroup ) .and. !empty( cLabel )	

		HB_HCaseMatch( hIni, .F. )
		
		if HB_HHasKey( hIni, cGroup ) 
		
			HB_HCaseMatch( hIni[ cGroup ], .F. )
			
			if HB_HHasKey( hIni[ cGroup ], cLabel )	
				uValue := hIni[ cGroup ][ cLabel ] 
			endif
			
		endif
		
	endif				
	
retu uValue 

// -------------------------------------------------- //

static function InitDbfUsers()

	LOCAL aStruct := { ;
			   { "USER"		, "C", 10, 0 }, ;
			   { "NAME"		, "C", 20, 0 }, ;
			   { "PROFILE"	, "C",  1, 0 }, ;
			   { "ACTIVE"	, "L",  1, 0 }, ;
			   { "PASSWORD" , "C", 36, 0 } ;
			}
	LOCAL cAlias
			   
	dbCreate( AppPathData() + 'users.dbf', aStruct, "DBFCDX" )
	
	USE ( AppPathData() + 'users.dbf' ) NEW VIA 'DBFCDX'
	cAlias := Alias()
	
	(cAlias)->( OrdCreate(  AppPathData() + 'users.cdx' , 'user', 'user' ) )
	
	SET INDEX TO ( AppPathData() + 'users.cdx' )	
	
	(cAlias)->( DbAppend() )
	(cAlias)->user			:= 'admin'
	(cAlias)->name			:= 'Administrator U-Dbu' 
	(cAlias)->profile 		:= 'A'
	(cAlias)->active 		:= .t.
	(cAlias)->password		:= hb_md5( '1234' )
	
	(cAlias)->( DbAppend() )
	(cAlias)->user			:= 'user'
	(cAlias)->name			:= 'Mr. User for U-Dbu' 
	(cAlias)->profile 		:= 'U'
	(cAlias)->active 		:= .t.
	(cAlias)->password		:= hb_md5( '1234' )			

	(cAlias)->( DbCloseArea() )
		
retu nil 

// -------------------------------------------------- //

static function InitDbfRepository()

	LOCAL aStruct := { ;
			   { "NAME"		, "C", 20, 0 }, ;
			   { "PATH"		, "C", 80, 0 }, ;			   
			   { "ACTIVE"	, "L",  1, 0 }  ;			   
			}
	LOCAL cAlias
			   
	dbCreate( AppPathData() + 'repository.dbf', aStruct, "DBFCDX" )
	
	USE ( AppPathData() + 'repository.dbf' ) NEW VIA 'DBFCDX'
	cAlias := Alias()
	
	(cAlias)->( OrdCreate(  AppPathData() + 'repository.cdx' , 'name', 'name' ) )
	
	SET INDEX TO ( AppPathData() + 'repository.cdx' )	
	
	(cAlias)->( DbAppend() )
	(cAlias)->name			:= 'LOCAL'
	(cAlias)->path			:= HB_DIRBASE() + 'data.example'	
	(cAlias)->active 		:= .t.
	
	(cAlias)->( DbAppend() )
	(cAlias)->name			:= '<name>'
	(cAlias)->path			:= '<data path>'
	(cAlias)->active 		:= .f.	

	(cAlias)->( DbCloseArea() )
		
retu nil 

// -------------------------------------------------- //

function NewAlias( cPre )

	STATIC n := 0
	
	hb_default( @cPre, 'ALIAS')	
retu cPre + ltrim(str(++n))

// -------------------------------------------------- //