#include 'lib\uhttpd2\uhttpd2.ch'

function Api_Users( oDom )

	do case			
		
		case oDom:GetProc() == 'update'		; RowUpdate( oDom )								
		case oDom:GetProc() == 'del'			; RowDel( oDom )								
		case oDom:GetProc() == 'new'			; RowAppend( oDom )								
		case oDom:GetProc() == 'resetkey'		; RowResetKey( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function RowUpdate( oDom )

	local oCell 		:= oDom:Get( 'cell' )
	local oUser 		:= TDbf():New( 'users.dbf', 'users.cdx', 'user' )
	local cError 		:= ''		
		
	//	You need to know parameteres received from client. The best solution is 
	//  checking to debug it, in special 'cell' parameter.	
	
		//	_d( oCell )	
		
	//	 Update
	
		if oUser:Update( oCell['row'][ '_recno' ], {;
							'user' => oCell['row'][ 'USER' ],;
							'name' => oCell['row'][ 'NAME' ],;
							'profile' => oCell['row'][ 'PROFILE' ],;
							'active' => oCell['row'][ 'ACTIVE' ];
						}, @cError )
						
			// oDom:SetJs( "MsgNotify( 'Update ok' )" )
		else 
			oDom:SetMsg( cError, 'Error' )
		endif

retu nil 

// -------------------------------------------------- //

static function RowDel( oDom )

	local hStr 			:= oDom:Get( 'brwusers' )
	local aSelected	:= hStr[ 'selected' ]
	local oUser 		:= TDbf():New( 'users.dbf', 'users.cdx', 'user' ) //, { 'set_deleted' => .t. } )
	local cError 		:= ''

	if Len( aSelected ) == 0
		retu nil
	endif
	
	if oUser:Delete( aSelected[1][ '_recno'], @cError )
		oDom:TableDelete( 'brwusers', aSelected[1][ '_recno'] )
	else 
		oDom:SetMsg( cError, 'Error' )
	endif


retu nil 

// -------------------------------------------------- //

static function RowAppend( oDom )

	local hStr 			:= oDom:Get( 'brwusers' )	
	local oUser 		:= TDbf():New( 'users.dbf', 'users.cdx', 'user' ) //, { 'set_deleted' => .t. } )
	local cError 		:= ''
	local hrow
	
	if oUser:Append( @cError )

		hRow 				:= oUser:Blank()
		
		hRow[ '_recno' ] 	:= ( oUser:cAlias )->( Recno() )
		
		oDom:TableAddData( 'brwusers', { hRow } )

	else 
		oDom:SetMsg( cError, 'Error' )
	endif

retu nil 

// -------------------------------------------------- //

static function RowResetKey( oDom )

	local hStr 			:= oDom:Get( 'brwusers' )
	local cNewKey 		:= oDom:Get( 'newkey' )
	local aSelected	:= hStr[ 'selected' ]
	local oUser 		:= TDbf():New( 'users.dbf', 'users.cdx', 'user' ) 
	local cError 		:= ''	
	local hRow
	
	if Len( aSelected ) == 0
		retu nil
	endif
	
	hRow := aSelected[1]
	
		
	//	Validate params 
	
		if empty( cNewKey ) .or. len( cNewKey ) > 10
			oDom:SetMsg( "Value don't allowed. Password should be between 1 and 10 characters max." )
			retu nil 
		endif
		
	//	 Update
	
		cNewKey := hb_md5(cNewKey)
	
		if oUser:Update( hRow[ '_recno' ], { 'password' => cNewKey }, @cError )
			
			oDom:SetMsg( 'New password changed!' )
		else 
			oDom:SetMsg( cError )
		endif 
retu nil 

// -------------------------------------------------- //
