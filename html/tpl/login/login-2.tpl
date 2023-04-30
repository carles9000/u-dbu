<?prg 
/*
	Template: login-1.tpl
	Description: Simple login system
	Author: Carles Aubia	
	Parameters:
		1 -> Reference object oForm from TWeb
		2 -> Values for template:
			'id_user' 			: id get user 
			'id_psw' 			: id get psw
			'placeholder_user'	: placeholder_user
			'placeholder_psw'	: placeholder_psw
			'action' 	: action api 
			'image' 	: background image
			
	https://css-tricks.com/perfect-full-page-background-image/		
*/

#include "lib/tweb/tweb.ch" 

	local o 	:= pvalue(1)
	local hData := pvalue(2)
	
	
	HTML o PARAMS hData
	
		<style>					
			
			body { 
				background-color: transparent;
			}
		
			html {
				height:100%;
				margin: 0;								
				
				background: url("<$ HB_HGetDef( hData, 'image', 'files/images/photo.jpg' ) $>") no-repeat center center fixed; 
				-webkit-background-size: cover;
				-moz-background-size: cover;
				-o-background-size: cover;
				background-size: cover;							
			}

			.mycontainer {
				margin: auto;
				margin-top: 100px;
				margin-left: 0;
				width:300px;
				border: 2px solid gray;
				border-radius: 10px;
				box-shadow: 5px 5px 5px gray;
				background-color:white;
			}
			
			@media only screen
			and (min-width: 320px)
			and (max-width: 736px)
			{			
				.mycontainer {
					margin-left: auto;			
				}
			}
			
			.myblock {
				width: 250px;
				margin: auto;
			}

		</style>
	ENDTEXT 	

	ROW o CLASS 'mycontainer'
	
		COL o GRID 0 CLASS 'myblock'
			
			ROWGROUP o	
				SAY LABEL '<br><h3><i class="fa fa-user-circle" aria-hidden="true"></i>&nbsp;System Access</h3><hr>' ALIGN 'center' GRID 12 OF o						
			ENDROW o						
		
			ROWGROUP o	HALIGN 'center'															
				GET ID HB_HGetDef( hData, 'id_user', 'user' )  VALUE '' GRID 12 ;
					PLACEHOLDER HB_HGetDef( hData, 'placeholder_user', '' ) ;
					LABEL '<i class="fa fa-user" aria-hidden="true"></i>&nbsp;User'  ;
					OF o						
			ENDROW o	

			ROWGROUP o																
				GET ID HB_HGetDef( hData, 'id_psw', 'psw' )  TYPE 'password' VALUE '' GRID 12 ;
					PLACEHOLDER HB_HGetDef( hData, 'placeholder_psw', '' ) ;
					LABEL '<i class="fa fa-unlock-alt" aria-hidden="true"></i>&nbsp;Psw.' ;
					OF o						
			ENDROW o	
			
			ROWGROUP o HALIGN 'center'																
				BUTTON LABEL 'Login' ACTION HB_HGetDef( hData, 'action', 'login' ) ;
					ICON '<i class="fa fa-paper-plane" aria-hidden="true"></i>&nbsp;&nbsp;';
					CLASS 'btn btn-outline-dark' ALIGN 'center' WIDTH '150px' GRID 12 OF o						
			ENDROW o						
		
		ENDCOL o								
		
	ENDROW o
	
	HTML o 
		<script>
			$( document ).ready( function() {
				
			})	
		</script>
	
	ENDTEXT 

	
?>



