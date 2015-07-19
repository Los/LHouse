/*
native CreateLog(const File[]);
native WriteLog(const File[], string[]);
native RemoveLog(const File[]);
native LogExists(const File[]);
*/

stock CreateLog ( const File [ ] )
{
    if ( LogExists ( File ) )
    {
        print ( "--------------------------------------------------------------------" );
        printf ( "Losgs: Você está tentando criar um log já existente (%s)", File );
        print ( "Losgs: Consulte o tópico oficial para mais informações." );
        print ( "Losgs: http://forum.sa-mp.com/showthread.php?t=293534" );
        print ( "--------------------------------------------------------------------" );
        return 0;
    }

    new
        File: logfile = fopen ( File, io_write );

    fclose ( logfile );

    return 1;
}

stock WriteLog ( const File [ ], string [ ], maxlength = sizeof ( string ) )
{
    if ( !LogExists ( File ) )
        CreateLog ( File );

    new
        year,
        month,
        day,
        hour,
        minute,
        second,
        str_log [ 600 ];

    getdate ( year, month, day );
    gettime ( hour,minute,second );

    format ( str_log, maxlength + 27, "(%02d/%02d/%d)[%02d:%02d:%02d] %s\r\n", day, month, year, hour, minute, second, string );

    new
        File: logfile = fopen ( File, io_append );

    fwrite ( logfile, str_log );
    fclose ( logfile );

    return 1;
}

stock RemoveLog ( const File [ ] )
{
    if ( !LogExists ( File ) )
    {
        print ( "--------------------------------------------------------------------" );
        printf ( "Losgs: Você está tentando deletar um log que não existe (%s)", File );
        print ( "Losgs: Consulte o tópico oficial para mais informações." );
        print ( "Losgs: http://forum.sa-mp.com/showthread.php?t=293534" );
        print ( "--------------------------------------------------------------------" );
        return 0;
    }

    fremove ( File );

    return 1;
}

stock LogExists ( const File [ ] )
{
    if ( !fexist ( File ) )
        return false;

    else
        return true;
}