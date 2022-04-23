
include					head.inc

ExitProcess proto, dwExitCode: dword

.data
fileHandle				dword				0
fileSize				dword				0
newFile					byte				"c:\\newFile.exe",0
newFileHandle			dword				0
msg1					byte				"the file size is: ",0
msgErr2					byte				"get file size error.",0
msgErr3					byte				"move file pointer error.",0
msgErr4					byte				"read file error.",0
msgFinish				byte				"it is finished.",0
lpFileSize				dword				0
fileData				byte				101	dup(0)
lpReadBytes				dword				0				
specWriteByte			dword				0
tempPointer				dword				0
lpError					dword				0

.code
asmMain proc c,
			fileName:ptr byte,										
			operation:byte											;Ҫִ�еĲ��������ܻ����
	
			;��Դ�ļ�
			invoke		CreateFileA, fileName, GENERIC_READ, 0, NULL,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
			cmp			eax,INVALID_HANDLE_VALUE		
			jne			fileOpen									;�ļ��򿪳ɹ�
			call		GetLastError								;��ȡ������
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR lpError,NULL, NULL
			mov			edx,lpError									;���ϵͳ������Ϣ
			call		WriteString
			jmp			quit
fileOpen:
			mov			fileHandle,eax


			;��Ŀ���ļ�
			invoke		CreateFileA, addr newFile, GENERIC_WRITE, 0, NULL,CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
			cmp			eax,INVALID_HANDLE_VALUE		
			jne			fileOpen2									;�ļ��򿪳ɹ�
			call		GetLastError								;��ȡ������
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR lpError,NULL, NULL
			mov			edx,lpError									;���ϵͳ������Ϣ
			call		WriteString
			jmp			quit
fileOpen2:
			mov			newFileHandle,eax

			;��ȡ�ļ���С
			invoke		GetFileSize, fileHandle,lpFileSize
			cmp			lpFileSize,0
			jz			getFileSizeok								;�ɹ�����ļ���С
			mov			edx,offset msgErr2							;��ȡ�ļ���Сʧ��
			call		WriteString
			jmp			quit

getFileSizeok:							
			mov			fileSize,eax								;�����ļ���С
			mov			edx,offset msg1								;����ļ���С��Ϣ
			call		WriteString
			mov			eax,fileSize
			call		WriteDec
			call		Crlf
			call		Crlf

			;�����ļ���С��������ΰ�����д�����ļ�
			mov			edx,0										; edx:eax / 100
			mov			eax,fileSize
			mov			ecx,100
			div			ecx
			mov			specWriteByte,edx							;������Ҫ���⴦��
			mov			ecx,eax										;����д�������ÿ��100���ֽ�

			;�����û������ת���ܻ���ܴ����
			cmp			operation,"d"								
			je			decode										; ��ת���ܴ����

			;��ȡ���ݲ����ܣ�Ȼ��д�����ļ�
write100Byte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,100		;���ļ���ȡ����
			invoke		myROR,addr fileData,100						;�����ݽ��м���
			invoke		myWirteFile,newFileHandle,addr fileData,100 ;�Ѽ�������д���ļ�
			pop			ecx
			loop		write100Byte

			;�����ļ�ĩβ����ȡ���ݲ����ܣ�Ȼ��д�����ļ�
			mov			ecx,specWriteByte							;����д�������ÿ��1���ֽ�
writeByte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,1		;���ļ���ȡ����
			invoke		myROR,addr fileData,1						;�����ݽ��м���
			invoke		myWirteFile,newFileHandle,addr fileData,1   ;�Ѽ�������д���ļ�
			pop			ecx
			loop		writeByte
			jmp			finish										;�������

			;��ȡ���ݲ����ܣ�Ȼ��д�����ļ�
decode:
_100Byte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,100		;���ļ���ȡ����
			invoke		myROL,addr fileData,100						;�����ݽ��м���
			invoke		myWirteFile,newFileHandle,addr fileData,100 ;�Ѽ�������д���ļ�
			pop			ecx
			loop		_100Byte

			;�����ļ�ĩβ����ȡ���ݲ����ܣ�Ȼ��д�����ļ�
			mov			ecx,specWriteByte							;����д�������ÿ��1���ֽ�
_1Byte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,1		;���ļ���ȡ����
			invoke		myROL,addr fileData,1						;�����ݽ��м���
			invoke		myWirteFile,newFileHandle,addr fileData,1   ;�Ѽ�������д���ļ�
			pop			ecx
			loop		_1Byte

finish:
			;���������ɵ���Ϣ
			mov			edx,offset msgFinish
			call		WriteChar

quit:
			invoke	ExitProcess,0
asmMain endp

; ��win32 api readfile�ķ�װ
myReadFile proc uses edx eax,
			fileHandleR:DWORD,								;�ļ����
			bufR:ptr byte,									;������ָ��
			bytesR:dword									;�ֽ���
	local	ReadBytes:dword

			;����win32 api
			invoke		ReadFile,fileHandleR,bufR,bytesR,addr ReadBytes,NULL
			cmp			eax,0
			jnz			read_ok								;�ɹ���ȡ
			call		GetLastError						;��ȡʧ��
			push		eax									;��������
			call		WriteDec							;��������
			call		Crlf
			pop			eax
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR tempPointer,NULL, NULL
			mov			edx,tempPointer
			call		WriteString
			ret
	read_ok:
			ret
myReadFile endp

; ��win32 api writefile�ķ�װ
myWirteFile proc uses edx eax,
			fileHandleW:DWORD,								;�ļ����
			bufW:ptr byte,									;������ָ��
			bytesW:dword									;�ֽ���

			;����win32 api
			invoke		WriteFile,fileHandleW,bufW,bytesW,addr tempPointer	,NULL
			cmp			eax,0
			jnz			write_ok							;�ɹ�д��
			call		GetLastError						;д��ʧ��
			push		eax									;����������
			call		WriteDec							;����������
			call		Crlf
			pop			eax
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR tempPointer,NULL, NULL
			mov			edx,tempPointer
			call		WriteString
			ret
	write_ok:
			ret
myWirteFile endp

; �Ը�����ַ�����ݽ���ror����
myROR	proc uses esi ecx,
			bufROR:ptr byte,								;Ҫ���ܵ����ݵ�ַ
			bufSize:dword									;�ֽ���

			mov			esi,bufROR
			mov			ecx,bufSize
	beginR:
			ror			byte ptr [esi],1					;�����ƶ�1λ
			inc			esi
			loop		beginR

			ret
myROR	endp

; �Ը�����ַ�����ݽ���rol����
myROL	proc uses esi ecx,
			bufROL:ptr byte,								;Ҫ���ܵ����ݵ�ַ
			BufSize:dword									;�ֽ���

			mov			esi,bufROL
			mov			ecx,BufSize
	beginL:
			rol			byte ptr [esi],1					;�����ƶ�1λ
			inc			esi
			loop		beginL

			ret
myROL	endp

end

