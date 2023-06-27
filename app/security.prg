//	Authorization()				--> Only check autenticate
//	Authorization( 'A')			--> + profile == 'A'
//	Authorization( 'A;C')			--> + profile == 'A' or 'C'

function Authorization( cProfiles )

	local lAuth 		:= .f.	
	local aProfiles, hCredentials, cProfile 
	
	hb_default( @cProfiles, '' )

	if ! USessionReady()
		URedirect( 'login' )
		retu .f.
	endif

	if empty( cProfiles )		
		retu .t.					
	endif 
	

	hCredentials 	:= USession( 'credentials' )
	aProfiles		:= hb_Atokens( cProfiles, ';' )
	cProfile 		:= upper( hCredentials[ 'profile' ] )

	if Ascan( aProfiles, {|u| upper(u) == cProfile } ) == 0
		URedirect( 'login' )
		retu .f.					
	endif 	
	
retu .t.