MZR        ��          >    �0jr                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              �Ȏظ 	� �!� L�!���̃t�@�C���� EXE file manager �Ŏg�p���܂��B���s�ł��܂���B
$ ��SHOW.DS PLATE.MAG OH18.MLO OH19.MLO OH02.MLO OH20.MLO OH17.MLO OH16.MLO OH15.MLO OH14.MLO OH13.MLO OH12.MLO OH10.MLO OH09.MLO OH08.MLO OH05.MLO OH03.MLO OH01.MLO GT014.MLO L2ARR.MLO DRIP02.MLO DRIP03.MLO DRIP01.MLO    ��  ��      dd  <<  ��  JJ  ��  MM  \\  ��  88  

  ��    SS  ��    ��  22  ��  ��
	;
	;	MLF MUSIC SHOW script
	;

	screen 1,0,1

	;
	;	MUSIC SHOW MAIN
	;
	cls 3:contrast 0
	console 3,24,6,20
	;
	mag "plate"
	lget 0,0,64,64
	%0=0
*31
	%1=0
*32
	lput %1,%0,64,64,0
	;
	%1=%1+64:if %1<640 :goto *32
	%0=%0+64:if %0<384 :goto *31
	;
	lget 0,0,640,16
	lput 0,384,640,16
	;
	color 15,1,0,1
	gprt 48,16,"�l�t�r�h�b�@�r�g�n�v / ���������Ȃ�I��ł�"
	;
	color 15,3,0,1
	mess "������������ ��������",1,5
	mess "�b���������X�X",2,5
	mess "�`.�c.�s.",3,5
	mess "������ ������������",4,5
	mess "��������������",5,5
	mess "���������� ��������������",6,5
	mess "�c������ ���� �q������",7,5
	mess "�r�������� �b������",8,5
	mess "�s������ �s����",9,5
	mess "������ ��������",10,5
	mess "�������� ��������",11,5
	mess "�c������ ������'�� ����",12,5
	mess "���ӂ�镗�C��",13,5
	mess "�F�D�I�ȉF���l",14,5
	mess "�ǂ���Ճ^�C��",15,5
	mess "�ق�킩�u��",16,5
	mess "���̐��̉ʂ�",17,5
	;
	color 9,1,2,1+32 : locate 6,3
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^���ɂ��܁@�ҋȁ^���ɂ��܁@�@�@�@�@�@"
	mess "��ȁ^�_���܁@�@�ҋȁ^���ɂ��� �@ �@�@�@�@"
	mess "��ȁ^�_���܁@�@�ҋȁ^�_���܁@ �@ �@�@�@�@"
	mess "��ȁ^�ǂ�ҁ[�@�ҋȁ^�ǂ�ҁ[�@�@    �@�@"
	mess "��ȁ^�ǂ�ҁ[�@�ҋȁ^�ǂ�ҁ[�@�@    �@�@"
	mess "��ȁ^�ǂ�ҁ[�@�ҋȁ^�ǂ�ҁ[�@�@    �@�@"
	;
	gosub *11
	contrast 16,1
	;
	msset 230,75
*40
	mswait %1,%2,%3
	if %1=0 : goto *41
	mstop
	;
	if %1=1 : gosub *1
	if %1=2 : gosub *2
	if %1=3 : gosub *3
	if %1=4 : gosub *4
	if %1=5 : gosub *5
	if %1=6 : gosub *6
	if %1=7 : gosub *7
	if %1=8 : gosub *8
	if %1=9 : gosub *9
	if %1=10 : gosub *10
	if %1=11 : gosub *11
	if %1=12 : gosub *12
	if %1=13 : gosub *13
	if %1=14 : gosub *14
	if %1=15 : gosub *15
	if %1=16 : gosub *16
	if %1=17 : gosub *17
	;
	goto *40
	;
*41
	mstop
	contrast 0,1:palwait
	end

*1
	music "OH01" : mplay
	return
*2
	music "OH02" : mplay
	return
*3
	music "OH03" : mplay
	return
*4
	music "OH05" : mplay
	return
*5
	music "OH08" : mplay
	return
*6
	music "OH09" : mplay
	return
*7
	music "OH10" : mplay
	return
*8
	music "OH12" : mplay
	return
*9
	music "OH13" : mplay
	return
*10
	music "OH14" : mplay
	return
*11
	music "OH15" : mplay
	return
*12
	music "OH16" : mplay
	return
*13
	music "L2ARR" : mplay
	return
*14
	music "GT014" : mplay
	return
*15
	music "DRIP01" : mplay
	return
*16
	music "DRIP02" : mplay
	return
*17
	music "DRIP03" : mplay
	return
MAKI02  Magd onitama            MagdSave version 1.05        ? ? P   �   �   "  R       �UU�fU��w� �3   ���������UUUfffwww���������	4% DBF	PA@@((!�����Hd$ �� Hϟ��  ((<0NN@�� 00@P

����

"@ @00
"
"�@�@�@�		#/	�	��
�
P�P�NN	�	��		�i;	P�5�				pp����p��p P�/P��� ���˾��l��������������������ۻ���˽���޾�����������������˜��������ݼ����ܺ������۽���ۻ�����������������κ������ݼ������������������m������ޭ�����ܼ̽�ͻ���̻̺�ܻ���������������ڶ�����˜�˽��������������������������ʼ������ƻ�����������ݽ����������ۼ�ܼݦf��l�ݻ��٫��������̽�����������f�ݜ������������������ɻ��������������������������ۦ��������������������������۶������˝���ͼ�˽��ͻ��������������ܽ���͝�ݻ��������������������ݼ����ͻ��������ݺ�������������f����������������ܻ������������̫�������������̹������������ͽ����ݾ���ܻ��������������������������������̪���������������۽��������������������������������̽�������ͼ�����������޻����޺������콻�̫����ݼ��ܼ�ݺ���������콼��������콽�̫��̻���ܫ�������������˭�������������ʽι�����������������̼��������ܛ�̼������������������̝����������캻��������������������������������������������������������������������������̪m��������ݽ��������ެ���ͻk�ݼ�����ݼ��ܼ���ͭ������������������ھ�����������������������ܼ�̻��������������������˼����˛��������������ξ�����������������������ͽ���������ƾ���������۽�����������빾���ͽ��Ɯ������ݛ�����������m�����ֻ��۬�������������fl�ݩ�������ݻ�μ���������ʩ������������֜����������������������������������ݽ��Ͷ��������ܽ����������������������μ��ͻͼ���켽���������������������������������̺�ܩ���������������������������������˜�����ܶܽ������������f��������ݽ������������޻ܾ����ݻ������j����ݾ�������������ۼ��ͼ����ʻ���������������̻��ۼ�����������������������������˻��������ު����ܼ������������������˼�������̻�����޻�������ڽ�ۻ��˹�������������������ܽ��������Ƭ���̽������������ܖ��ͼ�������ݻj���ݻ����˾����������������;�f�������ܼ���������������������������ݽ�˼������i�����������������웮�����������������ˬݻ�������������������ν����˻����̫����������`�������fk���쩼����۽�̛������ˮ����ʦk����ͻ��������������� � �  ������ ����� �����
  �1 ������
 ��������l���B��l�� � ��� �� ��
� ������ ��� ��    � �  ``ja!( � (GW:7778=P@`  ____
�
< 9( �
    ����;OJp       �?/<  ����
�  c_0 ������ ����z+K+�+������$�3 �����
  s�{��S�[��C�K[{[+{������$�p ������
 ��������l���B��l�� ��JJJ��##��J�J������J��� ��B$��""
��, ��� ��������z+K+�+��z��z��r$�0 ��� ������������z+K+�+��z��z��r$�, ��� �s�{��S�[��C�K[{[+{������$�    � �  ``ja!( � (GW:x4x4!      77<P@`  ____
�
< 9( �
    ����;OJp       �?/<OJp       �?/<  ����
�  �������� ���������� ��������� ���;{���� ���[;��������	 �;{�L �����;�	 �������;�	 � ���z;;;;+�[[[[;{{{�{�� ���������� ���ȪȪ��ȪȪ�� �) ������� ���Ȫ����Ȫ���� �) ��{�{[[k{�� �;��������
  ������$�t\��d�t��\4� � � �0�t$T$4��H<\|�? \�T0�4$T$�$�$���|\|<,<�ȫ$tHT4T�HѤ$T4$H40�\�<�\T$�H�$���sH$�sSSHc�s�s��s$4$T4Tt$�$$55U$��������� �ȬȬ��ȬȬ�|�|�||�ȬȬ��������� -�-�---�-�-�}�}�}}}�}�}���$�T�tH4$$$�H�4�� ������
 ������	�	�@�	� ��@�	� ��
H�H�H�H�H�H����		��@�	� ��@�	� 	�JJ�	�JJ���		��@�	� ��@�	� �BB**�##���		��@�	��@�	� �@���HH�	�
 �HHH�� ת ����� �`��`�����Z�s� ��$s$H�H�$�$HH�H�$�
��~^>.�}]=-�� ���z�zzzȪȪ�����;�;;;�� �����;�;�;;;�;�;�� ��+�+�+++�+�+�� �) �H֣ ח ����� �`��`;�3+�#;�3�� ��s$$tHSHS$S$sHsHSHS$�
�>.�}]=-�|\�� ���:�:::�Z�ZZZ�z�zzzȪȪ���� �����{�{�{{{�{�{�� � �H֐ �)��������z�z��s{�$3��Ȳ��Ȫr� :� � :�20�$�$rZ2R�H:Zz�? �0Ȣ$$#$�$���{[{;+;�Ȫ�
����$s$H�H�$�$HH�H�$��  ��#Hs$S#H�#�#�S#s$�$�$$T$t$�t�$��������� ���ȫȫ��ȫȫ�� �������� ��,�,�,,,�,�,�� �
�����$�T�tH4$$�  �H�"�    � �  ``ja!( � (GW: 
  �� AaQC   U%E&8  F      ��<         ����<OJp       �?/<P@`  ____
�
<  ����
� ���� 
�  � �  ������ �;;[0� �����
  *
*
:�r0�1 ������
 ��������l���B��l�� � ��� ��{�{��0� ��
� ����ț{�{��0� ��� �++;�s0�    � �    2 
    U55 x4x4!      77<P@`  ____
�
< 9( �
    ����;OJp       �?/<  ����
�  ��� �������� �����#S+S#+K�
 KsK{� +Cs�" ����++[[++[[+,+K[{{[� ���`� ����,,\\,,\\,-,L\||\� --]]--]]-.-M]}}]..^^..^^./.N^~~^����/.^~/.�/.^~.� ����.-]}.-�.-]}-� ��"`�"`�� �[ ����� ������ȓȓ���{�
 ȳȻ� �s��" ����#S+S+�KCs� ��R`�R`�T ז ��������
 ����`� �(������B� �������l���B���l�����l���D��
��l�= �������B� ����`ђ`֏ � ��� �� ��
� ������ ��� ��    � �      DD 
 
               
  t4u5            p0}=(        
  $4$$ P@`  ____
�
<OJp       �?/< 9( �
    ����;  ����
�  �~� ������ ������;[;�������;{��[;SZ�zz�;{[;[sz����Z��;�; ��[[�[[;[;[[[�[[;�;[� �����Ȫ� ��;;3��;� ��[[S��;[� �0 ֚ ׺ �����������\<� ��
 \���\<� ��
 \�! ����
  H�;[sH�[;s$;[$��0��z��H�;[sH�[;s$���$�{s0;[�;[{����
  ��0��s���{�{� s[s0�{[s�$�" s[sS`�$ֳ �J ������
 ���������l� ��J��l� ��BB��d���6 �B ��� ������0303030S0030S0� ���`r`� ��S`�`s`S`� �5 �G ��
� ����������0303030S0030S0� ���`r`� ��S`�`s`S`� �5 �B ��� �����300s0�030S0s0�0� ��``� ��`3`3``� �5 �    � �    2 
    U55 ((+_\
  

x4x4!      77<|  __1Q#<P@`  ____
�
< 9( �
    ����;OJp       �?/<  ����
�  40k ������ ��������
 �+� ����� ��z{� ��Z[� ��� ��� ���. +,��� �Z פ �����
  �����`� ��[+K��[+K� s`�s�� s[KH�+r0s$C[s�r�0S$sK[+K+�r0s$C[#������ ���{[K��[K��z�S0�[+�H��0Ⱥ�CH�֐ �7 ������
 ����������l���B��l�� �# �K ��� ������S$C$�#$C$�� �����{[K� ��[Kz� � �`�`�`D`�> �P ��
� ����������S$C$�#$C$�� �����{[K� ��[Kz� � �`�`�`D`�> �K ��� ������$$Ȳ$$Z�� �����K+z� ��+�J� � S`s```�> �    � �       �_��0 'V(q   
  P@`  ____
�
< 9( �
    ����;OJp       �?/<  ����
�  ��, ������ ��������Ț�Ⱥ���� � �� ����������ccc�CCS� �����k��kk��
 �k��k��KKKK[[� �����k��Kk����� ��K��KK��K��KK[[�$ ����
  tфHф��ѴHѴ��H��u�Hх����`� �0��0DTc0$$�0���� �W ������
 ���������l���B���l�����l���D��
��l�; �C �b ��� ��������� ������T� �H���CH�C�S�cH�c�H���U �g ��
� �����	�������� ������T� �H���CH�C�S�cH�c�H���U �b ��� ��������� ������U� �H���DH�D�T�dH�d�H���U �    � �  a01 Y��Y			�vvv;#t#t   77,AfRF  $%6&" Fp    ��� 

   P@`  ____
�
< 9( �
    ����;OJp       �?/<  ����
�  � ����� ��������+,� ����� ��� � ��+,� ��� �3 ��+,� ������� ��kl� ��+,� � ����� �* ��+,� �{ ו ��������
  ��"*�r$b"B�rb$� b"����& b"�"$���H*b0"0H*J�	 �H"� "H��  ���"`"``�	 b0b0� b`���`�`�`b`� ֎ כ ����	�����
  �����"*�r$b"B�rb$� b"����& b"�"$���H*b0"0H*J�	 �H"� "H���  ���b`a`B`�	 "00� "`��"`"``"`� ֔ א ��� �������+k�k� ���+k+� ��K�K� � ���+k+� ���k� �= ��+k�k� ����+{�{� ��+k�k� ��{�{� ��+k�k� �/ փ ו ��
� ��	���������+k�k� ���+k+� ��K�K� � ���+k+� ���k� �= ��+k�k� ����+{�{� ��+k�k� ��{�{� ��+k�k� �/ փ �& ������������ ���
� �� �    I 6    -   5U5�;4t4t   dd,  ����
�  zv ������ ��0#0�����������+K�� �����+K�� �����+K�� �� ���{ٛ��� {�B ����zٚ�� �� H���
  ���``�`� "`� �0"0���
  ����L,�� ,��D$$�,���,L� �D$��$��/ ���
  ����L,L�sC�+{,L$� � l,�c#���K�k+��- k+�$�}M-�|L,�
�� ����ߺ��Ⱥ��K�KK{{k{�����
  ��B`r`B`� �`� ���ѱ0����  ���0��KK�KK�Ȼ��0��KK�K�$�KK�K�K+�ț��0��k������KK�KK�ȻKK�KK�� ����++�++�� �) ���
  ��������L,L�sC�+{,L$� � l,�c#���K�k+��- k+�$�}M-�|�� �� ������
 �������K� ���KK��� �K�	����������������K������ ��K��K��KK�0��������K�� �
�
n���K��
�$ ��KKKK�3 �������	����	� � ֒ ׄ ��`���� ���tHl,��tHDl,���0|d�	 d0�0� sd�Ѵ0���`� DHtdH�tH��0$d���  ��C`C`C`#`� ��D`D`D`� $`� C0C0�{ ׉ ��`���� �������tHl,��tHDl,���0|d�	 d0�0� sd�Ѵ0���`� DHtdH�tH��0$d���  ��r`�`r`b`� ��s`�`s`� c`� s0c0ր ׄ ��`���� ���sHk+��sHCk+���0{c�	 c0�0� rc�ѳ0���`� CHscH�sH��0#c���  ���``�`�`� ���``�`� �`� �0�0�{ �    7 0ppp  $%6&*AfRF  $%6&" Fp    ��� 

   #t#t   77,c111        38 % 
     �� :``ja!( � (GW:P@`  ____
�
<OJp       �?/<w7r2@@GGhbbb1S% ���
 	Y�>  ����
� ���� 
�  ��Z ������� ���������� ��KKLK� ��++,+� ����zz{z�, �����`B`�`�0q0� �O ״ �������� ��B��B��� �`� ��"��"��� B`����
  �`C`#`�0r0�����
  ��C��C`CsC� D$�`C0� D$D�0s0������`DH$$0��0� $0� s0֭ ך ��������
  �  �`�`�`r0�0���Ȓ`C`#`�0r0�����
  ��C��C`CsC� D$�`C0� D$D�0s0������`DH$$0��0� $0� s$֓ �[ ������`� �� �  ���`s`#`s0s0� �� ������K{��	 +K����z�+C�	 ��zJ�% �T �e ������`� �� �  ��`�`�`#0�0� �� �����	�����K{��	 +K����z�+C�	 ��� zJ�( ��^ �2 ��
�����
����� ���
� ����
� �� �    � �       �_��0 'V(2q2B    <#t#t   77,t1t2  TK
   DD<""77      <  ���� 
�  51����� �������������� ��ZZ[ZZ[ZZ� ��zz{zz{zz� ����������� ��++++++� ,+� ++�*�����{ћ����*zz��##�z� ++++++,+++,+��+,����� ���
 �z��+++�z+� +++[{+������z��� ��������� � ����KKKKKKLK{ћ+,��& ��C�CC�0��� �� �����
  ���0�#sC�H�#0#sS��ђ�"r���
  ����%$��0�tD$������|L,���|L,�	 ,�� ��L���-Ȕ$|�D0�tDt������|L,���|L,�	 ,�� ��L������ќ���������� ���
  �0r$C�$�*J�0SCCC
*J*
*
*�y�� ב ������
 �����������K�� ��
n���K��
�$ ��KK��5 ������K���
n�� ��K��
�$ �������KKKK�} �} ��� ����H�H��H��H���#K�Kȓ$+K#0ȳs�$0�0T0� t0�! t0����CS� ���0sS� C0�s0� ��0��p �} ��� ���CH$DHs$H$DHs��S{�{�S$��0�sCS�0T0$0� $0�! D0��D$D$s�� ��C0#� 0�C0� C�CC�0��p ׫ ��
�����
������� �-�
---��.� �
---� ����� �-�
---� ��.� �
---� ����� -��-��-��-��-��-��-��-�J �����
����� �-�
---��.� �
---� ֗ �    � �  ``ja!( � (GW:#t#t    77,1!s 9G9q   
  P@`  ____
�
<OJp       �?/<hbbb1S% ���
 	Y�>  ����
� ���� 
�      ��K ������ �����``d``� ����!�<;<;l;� � ����1``� �@ �� ���� ���d`�`�`T`� ������<;<;l;� ������ы;��;S�c3��:� �����;;;;:;;;;;� �H3�3`��<<;<;<<;� `�0��;;<;� ������ы;��;S�c3��:� �� �< ���� ����4`T`4`� �`� �`�����
 ���Z��� �5 �/ ��� �����������Ȍ�����ȍ����  �4 ��� ���	������������Ȍ�����ȍ����  � ��
�����
��� ���� �    � �  AaQC   U%E&8a01 Y��Y			�vvv;2r8x 


  

�$�$r - 
 0RRR ``ja!( � (GW:q   
    
  B2Bb    __
�W�g>  ���� 
�  ��U �������� �������J����JJ���J��J�J���J���J� ��������+Kz����[K�� �J �E ����  ��0����ȚC0�� +�� ���+K���LK�KK,K� �3 ׮�����������ȳѳѳ$`�$�$�0�������ѳ�`ѻѳ�����������C`�C0�C�C�C�����s����`ѓѓ�0����$�$�$�����D0�L�D�D�D�D�`����E�E�E�%�%�%�E0�E�E�0�����0ѳѳѳ�C0�K�C�`����s0�{��������ѓѓ���C`�C�C�C�0���$0�,�$�$�����D0�D�����Ss�s��`ѻѳѳѳѳ������ѓѓ�s0�s�s�s�C0�K�C�C�����������0������`�0��D0�D�D�D������,�$�$��D`�D�D��������`ѳѳ�0���������ѳѳѳ�������$0�,�$�$D0�D�D�D�D�`ѻѳ�`C�C�C�C���s0�{�s�sȳѳѳ$0�,�$�$�$�$��������ѳѳ0�������0ѻѳ�0ѓ�����0��ѳ������ѳ���������ѳѳ�������ѳ����0�������0ѓѓ�s�s�s�s�0ѓѓ�������CS�S�Ss�0ѓћ��ѓs�s�sS�S�S�Ss�s�s0�{�D0�L�D$�$�$D$�$`�$�$�$�$�$�$�$��ѳѳѳ�ѓ$$�$�,�$�$�$s�s��ѓѓ�������ѳѳѳѳ�����0��#�#C�CS0�S�S���S�S�SC�C#�#�SC�C0�K���#0�#�#�#�#C�SC�CS�S�SC�C�S�SC�CS�SC�CS�SCS�SCS�S�CS�SCS�CS�S�CS�SC�CSC�C�C֣�i �� �� 
 ���������ѳ�� ����������������� ����ٻ��ڻ�ٻ���� ��ٻ��� {{�> �W �i �� �� 
 ������ѓ�s��s�� ������ٛ��ڛ�ٛ��ڛ�ٛ��� ��{��{{��{��{{��� {��{��� KK�> �W �n �	� ������ 
 ���������ѳ�� ����������������� ����ٻ��ڻ�ٻ���� ��ٻ��� {{�> �W �    { h  2q2B    <     �_��0 'V(t2t2    
    &&<3~At#)[_�    ����4  ���� 
�  ~z. ������ �������{ћ������{ћ��JJ� � ׷ ����������L�L�LL��L�L�LL��L�� L�LL��L��L��L��& �H������
  ���4�D0�D	��EH����E� ��DH�$�0ќ|LtH$D|Lt,�Hѓ$�7 ��D`�D`�`CHs#H� �`ђ`ђ`#� �`ђ`ђ`�ְ ׍ ������
 ����������
l��B���
l��
n��
����C��
��
l�����
l��B���
l��
N�����C��
��I�q �y ס ����� ������ȺȺȺ����� ���+��+��+��& �H�������ȺȺȺ����� ���+��+��+��& �H�����������zJ�� *�***J��� � *�**�ZB��) *���H֚ ס ����� ����ȚȚ���z�z�zz�Ț�� �Ț��Ⱥ�Ⱥ�Ⱥ��& �H�����ȚȚ���z�z�zz�Ț�� �Ț��Ⱥ�Ⱥ�Ⱥ��& �H�������KKK�+��� �Ț���CK� � �Ț�����) ����H֚ �� ����������������ȺȺȺ����� ���+��+��+��& �H�  ����ѓ0ѓ	,L�H��L,�� L,�H$$D0�LLDH����{CH�C$�7 � ������������zJ�� *�***J��� � *�**�ZB��) *���0��  ֻ �    � �  ``ja!( � (GW:DE<  �_�_
%%%%<AaQC   U%E&8P@`  ____
�
< 9( �
    ����;OJp       �?/<hbbb1S% ���
 	Y�>  ���� 
�     ���� 
�  hd� ������ ������kkkklkkkkklkkKK� ����kkkKdkkkkdk� k�k� k���KKKDKKKKDKKk� �7 ����kklk� ��KKLK� ��� ��++,+� ��KKLK� �: ��kkkKdkkkkdk� k�k� k�ֱ �� ������������� ������L�" ����c0�c��H�ȋ�$C$�c$�$�����H�ћH���ȃH��K�0�����������H��0��Dd$��Ȍl���H��H��H�D�L�Ѵ���� L�8 l��Hу�ћH�ȋћH�k��k����Kk���jJ�Hу��`�0$�$c$C�� �9 ������
 ������			��@�	�	����@�		� �' �k ����� ���`�``b�C� ��```C0�	 � �������`D0�0�$$��0�0� ���`�`�`�`� �d �f ����� ����`�`c`Cc� ���`�`C`�0�	 ��� �k�KK����`�0�0C`c0�0� ��c`C`c`C`� �_ י ����� ��������`�`c`Cc� ���`�`C`�0�	 ��� ��������  ��d0�d��0��$���Ȍl����H��H��H�DdL�Ѵ���L�8 ��````� ֒ �    � �  ``ja!( � (GW:c111        38 
  ��   F      ��<         ����<  ���� 
�  ��� ���� ������J�LJJJJJZ�\ZZZZZ��z�|zzzzz� �" ���J�LJJJJJZ�\ZZZZZ��z�|zzzzz� �" �����**+*� +����zz{z� ss{{{��**+*� +����zz{z� zzzz�B ֞ �P �������������� �����++�*�+� ���� �I ׂ ���������� ����B2B���K�+�B2B���K�#� �* ��#  +K# �+#  +K+s �{#  +K# �+#  +��zjJ*�0 �{ � �� �� ��    � �  p10. __

 �F&&8?y? 	
%�_�<OOp 
     �))<P0p ��_��*�*XR!         )   }yk �������
  �� �K��{K+�K��C � s s {{{{�@C s �� � s ȓ@C s �� � s �s@# S {����s ȓ@C s ���� ���` �l � ��� �
  �� ����K��{K+�K��C � s s {{{{�@C s �� � s ȓ@C s �� � s �s@# S {����s ȓ@C s ���� ���c ׈ � �� � �����������������yyyyyyyy��������� �����{�[�K�+�Ѫњ�z� ����������� ����zz{{� ������� ���ց �b � �� � ���L�,�{�ȻLȳ � $ $ ,,,,D@� $ LT D $ �D@� $ LT D $ �$@�  ,L\L\$ �D@� $ L\|\D ����[ �R � �� �������
��������������������� ��� ��K �b � ��� � ��
�L�,�{�ȻLȳ � $ $ ,,,,D@� $ LT D $ �D@� $ LT D $ �$@�  ,L\L\$ �D@� $ L\|\D ���Y �    o O  r4x4  

      ,o`d`) ߟߟ
%� B2Bb    __
�W�g>  ���� 
� ����
�  ��t ���� �
�����||LLLt�|\L$0\\,,�,T|\L\t0||LLLt�|\L$0\\,,�,�|\L,0�����||D\L,\t0\\,,|\L,|\L,0� �c ם ���
��� ��MM��MMu��}]M-%%��--��ȼ���--U�}]M]u0}}MM�MMu��}]M-%%��--���-�}]M-�M�����N}}---Muu��]]--}]M---���) ֋ ״ �������{{KK�KKs��{{[[KK#0�[[++���++S{{[[KK[[{�{{�����{{KK�KKs��{{[[KK#0�[[++���++S{�[�K�+�Ț�KK���țț�{{{{++++++KKKK�����[[++{[K+{[K+0�3 ֧ ׂ ����������||LL�LL�|�|\L,�,\\\,,|L|\L\|��||LLLt�|\L,��\\,,|L|\L,�L��\�|L,,,D0\\,,|\L,|\L,0� �r ׇ �������� ����||LL�LL�|�|\L,�,\\\,,|L|\L\|��||LLLt�|\L,��\\,,|L|\L,�L��\�|L�[,,,D0\\,,L,�|\L,0� �r � ��    U O  i5&1A _�۞ 

����$ecQa YYYY
����<k71! �_��	 ��   ��L ����� ��
  ���##{{��0���0ѫ{���0ћ��,�����s`����������4 �K �� ��
  �� ��##KKk{�0ћ�s0�{{��c0�k����{�{k{kC`����������4 �T ������$$l|������,,|||||�,,lllll���-�������tt\L�	 |\,L\|�L|���G �Z �����
���
  ��##{{��{{��[�[�{���������,�������{[K� {[+K[{�K{���A �_ �����
���� �
  ��##KK[{L|�[���,\��{���|\L����{�{[{[��K+� {[+K[{�K{���A � ��    < 6  t1t2  TK
   DD<ecQa YYYY
����<   ��a ������ �����Ȕ��||�t}}-M]�N~�v0���,\L,� ���-�|� ���L�|\� ���\L,� �����P �` ��� �� ����Ȕ��LL�D||,L\ȝ��F0�,�\�\L,Ȕ��|TL�|�|��Ȥ�tt�|T�|\D\L,$H��P �s ����� ��,,,[K+��L,||\|��L|�t]M-��,,\,,,�� ��,��|L� �~^N.�}]M-��|\��\L,� [K+YI)	�c �g ������������ȓ{S{{�s[C+K[{��,D\L,+�[�[{���SK�{�{���$$�s�{S�{[C[K+#H�U �i �������
������ȓ{SKK�C++K[{��,D\L,+�[�[{�ȓ��{SK�{�{��ȣ�ss[K#��SK+[K+#H�U ׃ ������������������ ������������������ ������� ������� �o �    < 6    `0( 	    Z�Z
9:000$- __

 &&&&8  