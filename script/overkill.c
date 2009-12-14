#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <utmp.h>

#define	INPUT_MAX	1024
#define	INPUT_AREA_SIZE	( INPUT_MAX + 1 )
#define	DEFAULT_SIGNAL	6	
#define DEFAULT_VIEWCHECKPG 0
#define VIEW_FLG 1
#define PS_CMD		"ps aux"
#define	GREP_CMD	" | grep "

#define	PS_FIELDNO_ALL	0
#define	PS_FIELDNO_USR	1
#define	PS_FIELDNO_PID	2
#define	PS_FIELDNO_RSS	6
#define	PS_FIELDNO_CMD	11

#define STR_USAGE \
"使用法: overkill  -u ユーザー名 -c 実行コマンド -m メモリ閾値 [-s 送信シグナル]\n\
指定されたプロセスを検索し、メモリ使用量が閾値を超えていた場合に強制的に終了（kill）します。\n\
\n\
オプション:\n\
\t-u,\t実行権限を持つユーザー名で対象プロセスを絞り込む（必須）\n\
\t-c,\t実行時のコマンドで対象プロセスを絞り込む（必須）\n\
\t\tスペースを含む場合、\"\"で括って下さい。\n\
\t-m,\t許容する最大メモリ使用量（RSS）をMB単位で指定（必須）\n\
\t-s,\tkill実行時に送信するシグナルを指定。デフォルト：6（SIGABRT）\n\
\t-v,\tチェック用のコマンドの内容を表示する\n\
\n\
使用例:\n\
\t以下のように指定した場合\n\
\t\t./overkill -u root -c \"vim hoge.txt\" -m 1\n\
\t以下のようなプロセスがkill対象となります。\n\
\t\troot      6876  0.1  0.0  10496  2748 pts/2    S+   13:29   0:00 vim hoge.txt\n\
\n"


typedef struct
{
	char *	pcTargetUser;
	char *	pcTargetCommand;
	unsigned long ulMaxRSS;
	int			iSendSignal;
        int  viewCheckPg;

} CMDLINE;

int	argv_analyze( CMDLINE *, int, char ** );
void edit_excpscmd( char *, CMDLINE * );
void show_usage( void );


int main( int argc, char * argv[] )
{
	CMDLINE	tCmdLine;
	FILE *	fpCmd	= NULL;
	char		cExcPSCmd[INPUT_AREA_SIZE*2] = {};
	char		cExcKillCmd[INPUT_AREA_SIZE]	= {};
	char		cInput[INPUT_AREA_SIZE]	= {};
	int			iPid	= 0;

	/*--------------------------*/
	/* 引数の指定内容を解析			*/
	/*--------------------------*/
	memset(( void * )&tCmdLine, 0x00, sizeof( tCmdLine ));
	if( 0 != argv_analyze( &tCmdLine, argc, argv ))
	{
		/* 引数の指定が足りないようなので使用方法を表示		*/
		show_usage();
		return( -1 );
	}

	/*--------------------------*/
	/* プロセス検索コマンド編集	*/
	/*--------------------------*/
	memset( cExcPSCmd, 0x00, sizeof( cExcPSCmd ));
	edit_excpscmd( cExcPSCmd, &tCmdLine );

	/*--------------------------*/
	/* プロセス検索実施					*/
	/*--------------------------*/
	fpCmd	= popen( cExcPSCmd, "r" );

	if( NULL == fpCmd )
	{
		printf( "popen error\n" );
		return( -1 );
	}

	/*------------------------------------------*/
	/* PID のリストになっているのでkillしていく	*/
	/*------------------------------------------*/
	while( NULL != fgets( cInput, INPUT_MAX, fpCmd ))
	{
		printf( "PID: %s を kill します。\n", cInput );
		iPid	= atoi( cInput );
		if( 0 != kill( iPid, tCmdLine.iSendSignal ))
		{
			switch( errno )
			{
			case EINVAL:
				printf( "無効なシグナルです。処理を中断します。\n" );
				pclose( fpCmd );
				return( -1 );
				break;
			case EPERM:
				printf( "このプロセスにシグナルを送信する権限がありません。\n" );
				break;
			case ESRCH:
				printf( "このプロセスは既に存在しません。\n" );
				break;
			default:
				printf( "予期せぬエラー（errno:%d）発生。処理を中断します。\n", errno );
				pclose( fpCmd );
				return( -1 );
				break;
			}	
		}
		memset( cInput, 0x00, INPUT_AREA_SIZE );
	}

	pclose( fpCmd );
	return( 0 );
}
int argv_analyze( CMDLINE * ptOut, int iNum, char * argv[] )
{
	int		iCount = 0;

	if( 1 >= iNum )
	{
		return( -1 );
	}

	ptOut->iSendSignal = DEFAULT_SIGNAL;
	ptOut->viewCheckPg = DEFAULT_VIEWCHECKPG;

	for( iCount = 1 ; iCount + 1 < iNum ; iCount += 2 )
	{
		switch( argv[iCount][0] )
		{
		case '-':
			switch( argv[iCount][1] )
			{
			case 'u':
			case 'U':
				ptOut->pcTargetUser	= argv[iCount + 1];
				break;

			case 'c':
			case 'C':
				ptOut->pcTargetCommand	= argv[iCount + 1];
				break;

			case 'm':
			case 'M':
				ptOut->ulMaxRSS = atoi( argv[iCount + 1] );
				break;

			case 's':
			case 'S':
				ptOut->iSendSignal	= atoi( argv[iCount + 1] );
				break;

			case 'v':
			case 'V':
				ptOut->viewCheckPg	= VIEW_FLG;
				break;

			default:
				printf( "argv error:%s\n", argv[iCount] );
				return( -1 );
				break;
			}
			break;
		default:
			printf( "argv error:%s\n", argv[iCount] );
			return( -1 );
			break;
		}
	}

	if(( NULL == ptOut->pcTargetUser )
	|| ( 0 == ptOut->ulMaxRSS )
	|| ( NULL == ptOut->pcTargetCommand ))
	{
		printf( "argv error:missing -u/-c/-m option\n" );
		return( -1 );
	}
	return( 0 );
}
void edit_excpscmd( char * pcOut, CMDLINE * ptCmdLine )
{
	int	iWorkLen	= 0;
	int	iAwkCmpNo	= 0;
	char	cCommandWork[INPUT_AREA_SIZE]	= {};
	char	cUserWork[UT_NAMESIZE+1] = {};
	char *	pcCommandWork = NULL;
	char *	pcNext	= NULL;

	memcpy( pcOut, PS_CMD, strlen( PS_CMD ));
	iWorkLen	= strlen( pcOut );

	if( NULL != ptCmdLine->pcTargetUser )
	{
		//strcat( pcOut, GREP_CMD );
		//strcat( pcOut, ptCmdLine->pcTargetUser );
		//iWorkLen	= strlen( pcOut );

		memset( cUserWork, 0x00, sizeof( cUserWork ));
		strncpy( cUserWork, ptCmdLine->pcTargetUser, UT_NAMESIZE );
		sprintf( &pcOut[iWorkLen],
						" | awk '$%d == \"%s\" { print $%d }'",
						PS_FIELDNO_USR, cUserWork, PS_FIELDNO_ALL );

		iWorkLen	= strlen( pcOut );
	}


	if( NULL != ptCmdLine->pcTargetCommand )
	{
		//strcat( pcOut, GREP_CMD );
		//strcat( pcOut, ptCmdLine->pcTargetCommand );
		//iWorkLen	= strlen( pcOut );
		
		// 引数付のコマンドの場合、、awk が$11 $12 .. に分解してしまうため、バラバラに指定
		// $0 と後方一致の正規表現で・・と行きたいところですが、"/"などのエスケープも面倒。
		iAwkCmpNo	= PS_FIELDNO_CMD;
		memset( cCommandWork, 0x00, sizeof( cCommandWork ));
		strncpy( cCommandWork, ptCmdLine->pcTargetCommand, INPUT_MAX );
		pcCommandWork	= cCommandWork;
		do
		{
			/* スペースが存在したらで分割して次の位置を記憶	*/
			if( NULL != ( pcNext = strchr( pcCommandWork, ' ' )))
			{
				*pcNext	= 0x00;
				pcNext++;
			}
			sprintf( &pcOut[iWorkLen],
							" | awk '$%d == \"%s\" { print $%d }'",
							iAwkCmpNo, pcCommandWork, PS_FIELDNO_ALL );

			iWorkLen	= strlen( pcOut );
			iAwkCmpNo++;

		}	while( NULL != ( pcCommandWork = pcNext ));

	}

	sprintf( &pcOut[iWorkLen],
					" | awk '$%d > %d { print $%d }'",
					PS_FIELDNO_RSS,  ptCmdLine->ulMaxRSS * 1024, PS_FIELDNO_PID );

	iWorkLen	= strlen( pcOut );
        if(VIEW_FLG == ptCmdLine->viewCheckPg)
	{
		printf( "pscmd:\t%s\n", pcOut ); 
        }
	return;
}
void show_usage( void )
{
	/* 想像以上にすることがなく、関数化したことを後悔	*/
	printf( "%s", STR_USAGE );
	return;
}

