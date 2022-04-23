
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
			operation:byte											;要执行的操作，加密或解密
	
			;打开源文件
			invoke		CreateFileA, fileName, GENERIC_READ, 0, NULL,OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
			cmp			eax,INVALID_HANDLE_VALUE		
			jne			fileOpen									;文件打开成功
			call		GetLastError								;获取错误编号
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR lpError,NULL, NULL
			mov			edx,lpError									;输出系统错误信息
			call		WriteString
			jmp			quit
fileOpen:
			mov			fileHandle,eax


			;打开目标文件
			invoke		CreateFileA, addr newFile, GENERIC_WRITE, 0, NULL,CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
			cmp			eax,INVALID_HANDLE_VALUE		
			jne			fileOpen2									;文件打开成功
			call		GetLastError								;获取错误编号
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR lpError,NULL, NULL
			mov			edx,lpError									;输出系统错误信息
			call		WriteString
			jmp			quit
fileOpen2:
			mov			newFileHandle,eax

			;获取文件大小
			invoke		GetFileSize, fileHandle,lpFileSize
			cmp			lpFileSize,0
			jz			getFileSizeok								;成功获得文件大小
			mov			edx,offset msgErr2							;获取文件大小失败
			call		WriteString
			jmp			quit

getFileSizeok:							
			mov			fileSize,eax								;保存文件大小
			mov			edx,offset msg1								;输出文件大小信息
			call		WriteString
			mov			eax,fileSize
			call		WriteDec
			call		Crlf
			call		Crlf

			;根据文件大小，决定如何把数据写入新文件
			mov			edx,0										; edx:eax / 100
			mov			eax,fileSize
			mov			ecx,100
			div			ecx
			mov			specWriteByte,edx							;余数需要特殊处理
			mov			ecx,eax										;数据写入次数，每次100个字节

			;根据用户命令，跳转加密或解密代码段
			cmp			operation,"d"								
			je			decode										; 跳转解密代码段

			;读取数据并加密，然后写到新文件
write100Byte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,100		;从文件读取数据
			invoke		myROR,addr fileData,100						;对数据进行加密
			invoke		myWirteFile,newFileHandle,addr fileData,100 ;把加密数据写入文件
			pop			ecx
			loop		write100Byte

			;到了文件末尾，读取数据并加密，然后写到新文件
			mov			ecx,specWriteByte							;数据写入次数，每次1个字节
writeByte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,1		;从文件读取数据
			invoke		myROR,addr fileData,1						;对数据进行加密
			invoke		myWirteFile,newFileHandle,addr fileData,1   ;把加密数据写入文件
			pop			ecx
			loop		writeByte
			jmp			finish										;加密完成

			;读取数据并解密，然后写到新文件
decode:
_100Byte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,100		;从文件读取数据
			invoke		myROL,addr fileData,100						;对数据进行加密
			invoke		myWirteFile,newFileHandle,addr fileData,100 ;把加密数据写入文件
			pop			ecx
			loop		_100Byte

			;到了文件末尾，读取数据并加密，然后写到新文件
			mov			ecx,specWriteByte							;数据写入次数，每次1个字节
_1Byte:
			push		ecx
			invoke		myReadFile,fileHandle,addr fileData,1		;从文件读取数据
			invoke		myROL,addr fileData,1						;对数据进行加密
			invoke		myWirteFile,newFileHandle,addr fileData,1   ;把加密数据写入文件
			pop			ecx
			loop		_1Byte

finish:
			;输出程序完成的信息
			mov			edx,offset msgFinish
			call		WriteChar

quit:
			invoke	ExitProcess,0
asmMain endp

; 对win32 api readfile的封装
myReadFile proc uses edx eax,
			fileHandleR:DWORD,								;文件句柄
			bufR:ptr byte,									;缓冲区指针
			bytesR:dword									;字节数
	local	ReadBytes:dword

			;调用win32 api
			invoke		ReadFile,fileHandleR,bufR,bytesR,addr ReadBytes,NULL
			cmp			eax,0
			jnz			read_ok								;成功读取
			call		GetLastError						;读取失败
			push		eax									;保存错误号
			call		WriteDec							;输出错误号
			call		Crlf
			pop			eax
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR tempPointer,NULL, NULL
			mov			edx,tempPointer
			call		WriteString
			ret
	read_ok:
			ret
myReadFile endp

; 对win32 api writefile的封装
myWirteFile proc uses edx eax,
			fileHandleW:DWORD,								;文件句柄
			bufW:ptr byte,									;缓冲区指针
			bytesW:dword									;字节数

			;调用win32 api
			invoke		WriteFile,fileHandleW,bufW,bytesW,addr tempPointer	,NULL
			cmp			eax,0
			jnz			write_ok							;成功写入
			call		GetLastError						;写入失败
			push		eax									;保存错误代码
			call		WriteDec							;输出错误代码
			call		Crlf
			pop			eax
			invoke		FormatMessageA,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM, NULL, eax,NULL,ADDR tempPointer,NULL, NULL
			mov			edx,tempPointer
			call		WriteString
			ret
	write_ok:
			ret
myWirteFile endp

; 对给定地址的数据进行ror操作
myROR	proc uses esi ecx,
			bufROR:ptr byte,								;要加密的数据地址
			bufSize:dword									;字节数

			mov			esi,bufROR
			mov			ecx,bufSize
	beginR:
			ror			byte ptr [esi],1					;向右移动1位
			inc			esi
			loop		beginR

			ret
myROR	endp

; 对给定地址的数据进行rol操作
myROL	proc uses esi ecx,
			bufROL:ptr byte,								;要加密的数据地址
			BufSize:dword									;字节数

			mov			esi,bufROL
			mov			ecx,BufSize
	beginL:
			rol			byte ptr [esi],1					;向右移动1位
			inc			esi
			loop		beginL

			ret
myROL	endp

end

