#include 'lib/uhttpd2/uhttpd2.ch'

request DBFCDX
request TWEB
request ORDKEYNO
request DBSKIP

//	Default codepage ------
REQUEST HB_CODEPAGE_ES850  	
REQUEST HB_LANG_ES
REQUEST HB_CODEPAGE_ESWIN 
//	-----------------------
REQUEST HB_CODEPAGE_ESMWIN
REQUEST HB_CODEPAGE_ES850C
REQUEST HB_CODEPAGE_FR850
REQUEST HB_CODEPAGE_FR850M
REQUEST HB_CODEPAGE_FRISO
REQUEST HB_CODEPAGE_PL852
REQUEST HB_CODEPAGE_PLISO
REQUEST HB_CODEPAGE_PLMAZ
REQUEST HB_CODEPAGE_PLWIN
REQUEST HB_CODEPAGE_PT850
REQUEST HB_CODEPAGE_PT860
REQUEST HB_CODEPAGE_PTISO
//	-----------------------
REQUEST hb_cdpList 

#define VK_ESCAPE	27
#define APP_VERSION 'U-Dbu v1.0'



// -------------------------------------------------- //

function main()

	hb_threadStart( @WebServer() )	
	
	while inkey(0) != VK_ESCAPE
	end

retu nil 

// -------------------------------------------------- //

function WebServer( hConfig )

	local oServer 	:= Httpd2()
	local hCfg 		:= Config()

	HB_HCaseMatch( hCfg, .F. )
	
	oServer:SetPort( HB_HGetDef( hCfg, 'port', 81 ) )
	
	oServer:bInit := {|| ServerInfo() }
	
	//	Routing...			

		oServer:Route( '/'			 , 'main.html' )  												
		oServer:Route( 'splash'	 , 'splash.html' )  												
		
		oServer:Route( 'login'		 , 'security/login.html' )  												
		oServer:Route( 'logout'	 , 'logout' )  					
		
		oServer:Route( 'dashboard'  , 'dashboard' )  				//	Ull! direct to dashboard function :-)
		oServer:Route( 'browse'  	 , 'dbu/browse.html' )  												
		oServer:Route( 'structure'  , 'dbu/structure.html' )  												
		oServer:Route( 'indexes'    , 'dbu/indexes.html' )  												
		oServer:Route( 'server_info', 'dbu/server_info.html' )  												
		oServer:Route( 'users'		 , 'dbu/tables/users.html' )  												
		oServer:Route( 'repository' , 'dbu/tables/repository.html' )  												
		oServer:Route( 'about'		 , 'dbu/about.html' )  												
		
	//	-----------------------------------------------------------------------//	

	IF ! oServer:Run()
	
		? "=> Server error:", oServer:cError

		RETU 1
	ENDIF
	
RETURN 0

// -------------------------------------------------- //

function ServerInfo() 	
	
	local hCfg := UGetServerInfo()	

	hCfg[ 'path' ] 			:= HB_DIRBASE()		
	hCfg[ 'os' ] 			:= os()
	hCfg[ 'harbour' ] 		:= version()
	hCfg[ 'builddate' ] 	:= HB_BUILDDATE()
	hCfg[ 'compiler' ] 		:= HB_compiler()
	hCfg[ 'codepage' ] 		:= hb_SetCodePage() + '/' + hb_cdpUniID( hb_SetCodePage() )
	hCfg[ 'version_tweb' ] 	:= TWebVersion()

	CConsole '---------------------------------'	
	Console  'Server Harbour9000 was started...'
	Console  '---------------------------------'

	Console  'Path.............: ' + hCfg[ 'path' ] 		
	Console  'Version httpd2...: ' + hCfg[ 'version' ] 	
	Console  'Start............: ' + hCfg[ 'start' ] 		
	Console  'Port.............: ' + ltrim(str(hCfg[ 'port' ])) 		
	Console  'OS...............: ' + hCfg[ 'os' ] 		
	Console  'Harbour..........: ' + hCfg[ 'harbour' ] 	
	Console  'Build date.......: ' + hCfg[ 'builddate' ] 	
	Console  'Compiler.........: ' + hCfg[ 'compiler' ] 	
	Console  'SSL..............: ' + if( hCfg[ 'ssl' ], 'Yes', 'No' )
	Console  'Trace............: ' + if( hCfg[ 'debug' ], 'Yes', 'No' )		
	Console  'Codepage.........: ' + hCfg[ 'codepage' ] 	
	Console  'UTF8 (actived)...: ' + if( hCfg[ 'utf8' ], 'Yes', 'No' )
	Console  '---------------------------------'
	Console  'Escape for exit...' 		

retu nil 

// -------------------------------------------------- //

function Config()	

	local hCfg
	
	RddSetDefault( 'DBFCDX' )
	
	HB_LANGSELECT('ES')        
    HB_SetCodePage ( "ESWIN" )		
	
	SET( _SET_DBCODEPAGE, 'ESWIN' )		
	SET( _SET_DELETED, 'ON' )			
	
	SET AUTOPEN OFF 
	SET DATE FORMAT TO 'DD/MM/YYYY' 
	
	CheckDbfs()
	
	hCfg := CheckIni()	
	
retu hCfg 

// -------------------------------------------------- //

function AppVersion() 		; retu APP_VERSION
function AppPathData()		; retu HB_DIRBASE() + 'data.sys\'

// -------------------------------------------------- //

function AppGetRepo() 

	local oRepo := TDbf():New( 'repository.dbf', 'repository.cdx', 'name' )
	local aRows := {}
	
	Aadd( aRows, '' )
	
	while (oRepo:cAlias)->( !eof() )
	
		if (oRepo:cAlias)->active
			Aadd( aRows, alltrim((oRepo:cAlias)->name ))
		endif
		
		(oRepo:cAlias)->(dbskip())
	end	

	(oRepo:cAlias)->( DbCloseArea() )

retu aRows

// -------------------------------------------------- //

function AppRepo2Path( cRepo ) 

	local cPath := ''
	local oRepo := TDbf():New( 'repository.dbf', 'repository.cdx', 'name' )

	if oRepo:Seek( cRepo )
		cPath := oRepo:Row()[ 'PATH' ]
	endif

retu cPath 