
//	MPU-PC98 initalize ( result: 0=board not found,1=OK )
extern int mpu_board( void );
extern int mpu_init( void );

//	READ DATA from MIDI
extern void mpu_proc( void );
//	READ DATA from MIDI （バッファ溜りチェック）
extern void mpu_proc2( void );
//	SEND DATA to MIDI
extern void mpu_out( char data );

//	MIDIデータ受信STOP,START
extern void mpu_start( void );			// also uses for buffer RESET
extern void mpu_stop( void );

//	受信データバッファを得るための関数
extern char *mpu_buffer( void );
extern char *mpu_endptr( void );

//	PITCH BEND STATUSを得るための関数
extern int mpu_pbend( void );

