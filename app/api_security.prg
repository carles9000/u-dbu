function Api_Security( oDom )
	
	if oDom:GetProc() != 'login'
	
		//	Acceso a API Security
			if ! USessionReady()
				URedirect( 'login' )
				retu nil
			endif	
	
	endif

	do case	
		
		case oDom:GetProc() == 'login'			; Upd_Login( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function Upd_Login( oDom )

	local cUser 	:= oDom:Get( 'user' )
	local cPsw 		:= oDom:Get( 'psw' )
	local hData		:= {=>}
	local lAccess	:= .f.
	local oUser, hRow
	local cError 	:= 'User/Psw is wrong !'
	
	//	Check dbf users. if don't exist we'll create
	
		
	
	//	Validate parameters
	
		if len( cUser ) > 10 
			oDom:SetMsg( 'User too long. Max. 10 characters' )
			oDom:Focus( 'user' )
			retu nil
		endif
		
		if empty( cUser ) 
			oDom:SetMsg( 'User is empty' )
			oDom:Focus( 'user' )
			retu nil
		endif		
		
		if empty( cPsw ) 
			oDom:SetMsg( 'Psw is empty' )
			oDom:Focus( 'psw' )
			retu nil
		endif

	//	Process 
	
		oUser 	:= TDbf():New( 'users.dbf', 'users.cdx', 'user' )
		
	
		//if cUser = 'demo' .and. cPsw = '1234'
		
		cPsw := alltrim(cPsw)
		
		if oUser:Seek( cUser )	
		
			hRow := oUser:Row()

			if alltrim( hRow[ 'PASSWORD' ] ) == hb_md5( cPsw )
		
				if hRow[ 'ACTIVE' ]
			
					lAccess := .t.
		
					hData[ 'user' ] := cUser
					hData[ 'name' ] := hRow[ 'NAME' ]
					hData[ 'profile' ] := hRow[ 'PROFILE' ]					
				
					USessionStart()
					Usession( 'credentials', hData )
					URedirect( '/' )
					
				else
					cError := 'User no active'
				endif

			endif
		
		endif
		
		if !lAccess
			oDom:SetError( cError )			
			retu nil					
		endif
		
retu nil

// -------------------------------------------------- //
//	FUNCTIONS - NO API
//	------------------------------------------------- //

function Upd_Info()
	
	local cHtml 			:= ''
	local hCredentials, oSession

	if ! USessionReady()
		URedirect( 'upd_login' )
		retu nil
	endif
	
	hCredentials := USession( 'credentials' )
	
	oSession := UGetSession()		
	
	cHtml := ULoadHtml( 'functional\upd_info.html', hCredentials, oSession )
	
	UWrite( cHtml )									

retu nil

// -------------------------------------------------- //

function Logout()

	USessionEnd()
	
	URedirect( 'splash' )

retu nil 

// -------------------------------------------------- //