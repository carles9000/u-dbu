#include 'lib\uhttpd2\uhttpd2.ch'

function Api_Repository( oDom )

	do case					
		case oDom:GetProc() == 'update'		; RowUpdate( oDom )								
		case oDom:GetProc() == 'del'			; RowDel( oDom )								
		case oDom:GetProc() == 'new'			; RowAppend( oDom )								

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //

static function RowUpdate( oDom )

	local oCell 		:= oDom:Get( 'cell' )
	local oRepo 		:= TDbf():New( 'repository.dbf', 'repository.cdx', 'name' )
	local cError := ''		
		
	//	You need to know parameteres received from client. The best solution is 
	//  checking to debug it, in special 'cell' parameter.	
	
		//	_d( oCell )	
		
	//	 Update
	
		if oRepo:Update( oCell['row'][ '_recno' ], {;
							'name' => oCell['row'][ 'NAME' ],;
							'path' => oCell['row'][ 'PATH' ],;							
							'active' => oCell['row'][ 'ACTIVE' ];
						}, @cError )
						
			// oDom:SetJs( "MsgNotify( 'Update ok' )" )
		else 
			oDom:SetMsg( cError, 'Error' )
		endif

retu nil 

// -------------------------------------------------- //

static function RowDel( oDom )

	local hStr 			:= oDom:Get( 'brwrepo' )
	local aSelected	:= hStr[ 'selected' ]
	local oRepo 		:= TDbf():New( 'repository.dbf', 'repository.cdx', 'name' ) //, { 'set_deleted' => .t. } )
	local cError 		:= ''

	if Len( aSelected ) == 0
		retu nil
	endif
	
	if oRepo:Delete( aSelected[1][ '_recno'], @cError )
		oDom:TableDelete( 'brwrepo', aSelected[1][ '_recno'] )
	else 
		oDom:SetMsg( cError, 'Error' )
	endif


retu nil 

// -------------------------------------------------- //

static function RowAppend( oDom )

	local hStr 			:= oDom:Get( 'brwrepo' )	
	local oRepo 		:= TDbf():New( 'repository.dbf', 'repository.cdx', 'name' ) //, { 'set_deleted' => .t. } )
	local cError 		:= ''
	local hrow
	
	if oRepo:Append( @cError )

		hRow 				:= oRepo:Blank()		
		hRow[ '_recno' ] 	:= ( oRepo:cAlias )->( Recno() )
		
		oDom:TableAddData( 'brwrepo', { hRow } )

	else 
		oDom:SetMsg( cError, 'Error' )
	endif

retu nil 

//	------------------------------------------------------------------- //
