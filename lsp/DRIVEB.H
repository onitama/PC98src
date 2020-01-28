
//	MPU-PC98 initalize ( result: 0=board not found,1=OK )
extern int mpu_board( void );
extern int mpu_init( void );

//	READ DATA from MIDI
extern void mpu_proc( void );
//	READ DATA from MIDI �i�o�b�t�@����`�F�b�N�j
extern void mpu_proc2( void );
//	SEND DATA to MIDI
extern void mpu_out( char data );

//	MIDI�f�[�^��MSTOP,START
extern void mpu_start( void );			// also uses for buffer RESET
extern void mpu_stop( void );

//	��M�f�[�^�o�b�t�@�𓾂邽�߂̊֐�
extern char *mpu_buffer( void );
extern char *mpu_endptr( void );

//	PITCH BEND STATUS�𓾂邽�߂̊֐�
extern int mpu_pbend( void );

