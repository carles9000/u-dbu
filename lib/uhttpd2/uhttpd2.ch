#ifndef UHTTPD2_CH_
#define UHTTPD2_CH_

#define CRLF Chr(13)+chr(10)

#xcommand static [<explist,...>]  => THREAD STATIC [<explist>]
#xcommand THREAD STATIC function <FuncName>([<params,...>]) => STAT FUNCTION <FuncName>( [<params>] )
#xcommand THREAD STATIC procedure <ProcName>([<params,...>]) => STAT PROCEDURE <ProcName>( [<params>] )

#xcommand CConsole [<explist,...>] => QQout( [<explist>] )
#xcommand Console [<explist,...>] => Qout( [<explist>] )

#xcommand ? [<explist,...>] => UWrite( '<br>' [,<explist>] )
#xcommand ?? [<explist,...>] => UWrite( [<explist>] )
#xcommand TEXT <into:TO,INTO> <v> => #pragma __cstream|<v>+=%s

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] => ;
                                IF <v1> == NIL ; <v1> := <x1> ; END ;
                                [; IF <vn> == NIL ; <vn> := <xn> ; END ]
#xcommand DEFAULT <v1> := <x1> [, <vn> := <xn> ] => ;
                                IF <v1> == NIL ; <v1> := <x1> ; END ;
                                [; IF <vn> == NIL ; <vn> := <xn> ; END ]								
								
#xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY => ALWAYS

#endif /* UHTTPD2_CH_ */