
obj/user/faultread:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800045:	ff 35 00 00 00 00    	push   0x0
  80004b:	8d 83 34 ee ff ff    	lea    -0x11cc(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 25 01 00 00       	call   80017c <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
  80006a:	e8 f0 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 45 08             	mov    0x8(%ebp),%eax
  800078:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  80007b:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  800081:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 c0                	test   %eax,%eax
  800089:	7e 08                	jle    800093 <libmain+0x30>
		binaryname = argv[0];
  80008b:	8b 0a                	mov    (%edx),%ecx
  80008d:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	52                   	push   %edx
  800097:	50                   	push   %eax
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 08 00 00 00       	call   8000aa <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 10             	sub    $0x10,%esp
  8000b1:	e8 a9 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000b6:	81 c3 4a 1f 00 00    	add    $0x1f4a,%ebx
	sys_env_destroy(0);
  8000bc:	6a 00                	push   $0x0
  8000be:	e8 6a 0a 00 00       	call   800b2d <sys_env_destroy>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	e8 8a ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000d5:	81 c3 2b 1f 00 00    	add    $0x1f2b,%ebx
  8000db:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000de:	8b 16                	mov    (%esi),%edx
  8000e0:	8d 42 01             	lea    0x1(%edx),%eax
  8000e3:	89 06                	mov    %eax,(%esi)
  8000e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	74 0b                	je     8000fe <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f3:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	68 ff 00 00 00       	push   $0xff
  800106:	8d 46 08             	lea    0x8(%esi),%eax
  800109:	50                   	push   %eax
  80010a:	e8 e1 09 00 00       	call   800af0 <sys_cputs>
		b->idx = 0;
  80010f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	eb d9                	jmp    8000f3 <putch+0x28>

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	53                   	push   %ebx
  80011e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800124:	e8 36 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800129:	81 c3 d7 1e 00 00    	add    $0x1ed7,%ebx
	struct printbuf b;

	b.idx = 0;
  80012f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800136:	00 00 00 
	b.cnt = 0;
  800139:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800140:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800143:	ff 75 0c             	push   0xc(%ebp)
  800146:	ff 75 08             	push   0x8(%ebp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	8d 83 cb e0 ff ff    	lea    -0x1f35(%ebx),%eax
  800156:	50                   	push   %eax
  800157:	e8 2c 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015c:	83 c4 08             	add    $0x8,%esp
  80015f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800165:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 7f 09 00 00       	call   800af0 <sys_cputs>

	return b.cnt;
}
  800171:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	push   0x8(%ebp)
  800189:	e8 8c ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 2c             	sub    $0x2c,%esp
  800199:	e8 d3 05 00 00       	call   800771 <__x86.get_pc_thunk.cx>
  80019e:	81 c1 62 1e 00 00    	add    $0x1e62,%ecx
  8001a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001a7:	89 c7                	mov    %eax,%edi
  8001a9:	89 d6                	mov    %edx,%esi
  8001ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	89 d1                	mov    %edx,%ecx
  8001b3:	89 c2                	mov    %eax,%edx
  8001b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8001be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001cb:	39 c2                	cmp    %eax,%edx
  8001cd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d0:	72 41                	jb     800213 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	ff 75 18             	push   0x18(%ebp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	53                   	push   %ebx
  8001dc:	50                   	push   %eax
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	ff 75 e4             	push   -0x1c(%ebp)
  8001e3:	ff 75 e0             	push   -0x20(%ebp)
  8001e6:	ff 75 d4             	push   -0x2c(%ebp)
  8001e9:	ff 75 d0             	push   -0x30(%ebp)
  8001ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001ef:	e8 0c 0a 00 00       	call   800c00 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 8e ff ff ff       	call   800190 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 13                	jmp    80021a <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	push   0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800213:	83 eb 01             	sub    $0x1,%ebx
  800216:	85 db                	test   %ebx,%ebx
  800218:	7f ed                	jg     800207 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	56                   	push   %esi
  80021e:	83 ec 04             	sub    $0x4,%esp
  800221:	ff 75 e4             	push   -0x1c(%ebp)
  800224:	ff 75 e0             	push   -0x20(%ebp)
  800227:	ff 75 d4             	push   -0x2c(%ebp)
  80022a:	ff 75 d0             	push   -0x30(%ebp)
  80022d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800230:	e8 eb 0a 00 00       	call   800d20 <__umoddi3>
  800235:	83 c4 14             	add    $0x14,%esp
  800238:	0f be 84 03 5c ee ff 	movsbl -0x11a4(%ebx,%eax,1),%eax
  80023f:	ff 
  800240:	50                   	push   %eax
  800241:	ff d7                	call   *%edi
}
  800243:	83 c4 10             	add    $0x10,%esp
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	push   0x10(%ebp)
  800278:	ff 75 0c             	push   0xc(%ebp)
  80027b:	ff 75 08             	push   0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 3c             	sub    $0x3c,%esp
  800291:	e8 d7 04 00 00       	call   80076d <__x86.get_pc_thunk.ax>
  800296:	05 6a 1d 00 00       	add    $0x1d6a,%eax
  80029b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80029e:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002a7:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002b0:	eb 0a                	jmp    8002bc <vprintfmt+0x34>
			putch(ch, putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	57                   	push   %edi
  8002b6:	50                   	push   %eax
  8002b7:	ff d6                	call   *%esi
  8002b9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002bc:	83 c3 01             	add    $0x1,%ebx
  8002bf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002c3:	83 f8 25             	cmp    $0x25,%eax
  8002c6:	74 0c                	je     8002d4 <vprintfmt+0x4c>
			if (ch == '\0')
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	75 e6                	jne    8002b2 <vprintfmt+0x2a>
}
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    
		padc = ' ';
  8002d4:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002d8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8002ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8002f5:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f8:	8d 43 01             	lea    0x1(%ebx),%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fe:	0f b6 13             	movzbl (%ebx),%edx
  800301:	8d 42 dd             	lea    -0x23(%edx),%eax
  800304:	3c 55                	cmp    $0x55,%al
  800306:	0f 87 c5 03 00 00    	ja     8006d1 <.L20>
  80030c:	0f b6 c0             	movzbl %al,%eax
  80030f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800312:	89 ce                	mov    %ecx,%esi
  800314:	03 b4 81 ec ee ff ff 	add    -0x1114(%ecx,%eax,4),%esi
  80031b:	ff e6                	jmp    *%esi

0080031d <.L66>:
  80031d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800320:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800324:	eb d2                	jmp    8002f8 <vprintfmt+0x70>

00800326 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800329:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80032d:	eb c9                	jmp    8002f8 <vprintfmt+0x70>

0080032f <.L31>:
  80032f:	0f b6 d2             	movzbl %dl,%edx
  800332:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800335:	b8 00 00 00 00       	mov    $0x0,%eax
  80033a:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80033d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800340:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800344:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800347:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034a:	83 f9 09             	cmp    $0x9,%ecx
  80034d:	77 58                	ja     8003a7 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80034f:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800352:	eb e9                	jmp    80033d <.L31+0xe>

00800354 <.L34>:
			precision = va_arg(ap, int);
  800354:	8b 45 14             	mov    0x14(%ebp),%eax
  800357:	8b 00                	mov    (%eax),%eax
  800359:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 40 04             	lea    0x4(%eax),%eax
  800362:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800368:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80036c:	79 8a                	jns    8002f8 <vprintfmt+0x70>
				width = precision, precision = -1;
  80036e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800371:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800374:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037b:	e9 78 ff ff ff       	jmp    8002f8 <vprintfmt+0x70>

00800380 <.L33>:
  800380:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800383:	85 d2                	test   %edx,%edx
  800385:	b8 00 00 00 00       	mov    $0x0,%eax
  80038a:	0f 49 c2             	cmovns %edx,%eax
  80038d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800393:	e9 60 ff ff ff       	jmp    8002f8 <vprintfmt+0x70>

00800398 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80039b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a2:	e9 51 ff ff ff       	jmp    8002f8 <vprintfmt+0x70>
  8003a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8003ad:	eb b9                	jmp    800368 <.L34+0x14>

008003af <.L27>:
			lflag++;
  8003af:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003b6:	e9 3d ff ff ff       	jmp    8002f8 <vprintfmt+0x70>

008003bb <.L30>:
			putch(va_arg(ap, int), putdat);
  8003bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8003be:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c1:	8d 58 04             	lea    0x4(%eax),%ebx
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	57                   	push   %edi
  8003c8:	ff 30                	push   (%eax)
  8003ca:	ff d6                	call   *%esi
			break;
  8003cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003d2:	e9 90 02 00 00       	jmp    800667 <.L25+0x45>

008003d7 <.L28>:
			err = va_arg(ap, int);
  8003d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8d 58 04             	lea    0x4(%eax),%ebx
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	89 d0                	mov    %edx,%eax
  8003e4:	f7 d8                	neg    %eax
  8003e6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e9:	83 f8 06             	cmp    $0x6,%eax
  8003ec:	7f 27                	jg     800415 <.L28+0x3e>
  8003ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8003f1:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8003f4:	85 d2                	test   %edx,%edx
  8003f6:	74 1d                	je     800415 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8003f8:	52                   	push   %edx
  8003f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fc:	8d 80 7d ee ff ff    	lea    -0x1183(%eax),%eax
  800402:	50                   	push   %eax
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	e8 61 fe ff ff       	call   80026b <printfmt>
  80040a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040d:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800410:	e9 52 02 00 00       	jmp    800667 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800415:	50                   	push   %eax
  800416:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800419:	8d 80 74 ee ff ff    	lea    -0x118c(%eax),%eax
  80041f:	50                   	push   %eax
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	e8 44 fe ff ff       	call   80026b <printfmt>
  800427:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042a:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80042d:	e9 35 02 00 00       	jmp    800667 <.L25+0x45>

00800432 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800432:	8b 75 08             	mov    0x8(%ebp),%esi
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	83 c0 04             	add    $0x4,%eax
  80043b:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800443:	85 d2                	test   %edx,%edx
  800445:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800448:	8d 80 6d ee ff ff    	lea    -0x1193(%eax),%eax
  80044e:	0f 45 c2             	cmovne %edx,%eax
  800451:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800454:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800458:	7e 06                	jle    800460 <.L24+0x2e>
  80045a:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80045e:	75 0d                	jne    80046d <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800463:	89 c3                	mov    %eax,%ebx
  800465:	03 45 d0             	add    -0x30(%ebp),%eax
  800468:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80046b:	eb 58                	jmp    8004c5 <.L24+0x93>
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 d8             	push   -0x28(%ebp)
  800473:	ff 75 c8             	push   -0x38(%ebp)
  800476:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800479:	e8 0f 03 00 00       	call   80078d <strnlen>
  80047e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800481:	29 c2                	sub    %eax,%edx
  800483:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80048b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80048f:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	eb 0f                	jmp    8004a3 <.L24+0x71>
					putch(padc, putdat);
  800494:	83 ec 08             	sub    $0x8,%esp
  800497:	57                   	push   %edi
  800498:	ff 75 d0             	push   -0x30(%ebp)
  80049b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	85 db                	test   %ebx,%ebx
  8004a5:	7f ed                	jg     800494 <.L24+0x62>
  8004a7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004aa:	85 d2                	test   %edx,%edx
  8004ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b1:	0f 49 c2             	cmovns %edx,%eax
  8004b4:	29 c2                	sub    %eax,%edx
  8004b6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004b9:	eb a5                	jmp    800460 <.L24+0x2e>
					putch(ch, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	57                   	push   %edi
  8004bf:	52                   	push   %edx
  8004c0:	ff d6                	call   *%esi
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c8:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 c3 01             	add    $0x1,%ebx
  8004cd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004d1:	0f be d0             	movsbl %al,%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	74 4b                	je     800523 <.L24+0xf1>
  8004d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004dc:	78 06                	js     8004e4 <.L24+0xb2>
  8004de:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e2:	78 1e                	js     800502 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004e8:	74 d1                	je     8004bb <.L24+0x89>
  8004ea:	0f be c0             	movsbl %al,%eax
  8004ed:	83 e8 20             	sub    $0x20,%eax
  8004f0:	83 f8 5e             	cmp    $0x5e,%eax
  8004f3:	76 c6                	jbe    8004bb <.L24+0x89>
					putch('?', putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	57                   	push   %edi
  8004f9:	6a 3f                	push   $0x3f
  8004fb:	ff d6                	call   *%esi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb c3                	jmp    8004c5 <.L24+0x93>
  800502:	89 cb                	mov    %ecx,%ebx
  800504:	eb 0e                	jmp    800514 <.L24+0xe2>
				putch(' ', putdat);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	57                   	push   %edi
  80050a:	6a 20                	push   $0x20
  80050c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80050e:	83 eb 01             	sub    $0x1,%ebx
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 db                	test   %ebx,%ebx
  800516:	7f ee                	jg     800506 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	e9 44 01 00 00       	jmp    800667 <.L25+0x45>
  800523:	89 cb                	mov    %ecx,%ebx
  800525:	eb ed                	jmp    800514 <.L24+0xe2>

00800527 <.L29>:
	if (lflag >= 2)
  800527:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80052a:	8b 75 08             	mov    0x8(%ebp),%esi
  80052d:	83 f9 01             	cmp    $0x1,%ecx
  800530:	7f 1b                	jg     80054d <.L29+0x26>
	else if (lflag)
  800532:	85 c9                	test   %ecx,%ecx
  800534:	74 63                	je     800599 <.L29+0x72>
		return va_arg(*ap, long);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	99                   	cltd   
  80053f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 40 04             	lea    0x4(%eax),%eax
  800548:	89 45 14             	mov    %eax,0x14(%ebp)
  80054b:	eb 17                	jmp    800564 <.L29+0x3d>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8b 50 04             	mov    0x4(%eax),%edx
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800558:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 40 08             	lea    0x8(%eax),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800564:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800567:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80056a:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80056f:	85 db                	test   %ebx,%ebx
  800571:	0f 89 d6 00 00 00    	jns    80064d <.L25+0x2b>
				putch('-', putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	57                   	push   %edi
  80057b:	6a 2d                	push   $0x2d
  80057d:	ff d6                	call   *%esi
				num = -(long long) num;
  80057f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800582:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800585:	f7 d9                	neg    %ecx
  800587:	83 d3 00             	adc    $0x0,%ebx
  80058a:	f7 db                	neg    %ebx
  80058c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058f:	ba 0a 00 00 00       	mov    $0xa,%edx
  800594:	e9 b4 00 00 00       	jmp    80064d <.L25+0x2b>
		return va_arg(*ap, int);
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a1:	99                   	cltd   
  8005a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 40 04             	lea    0x4(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ae:	eb b4                	jmp    800564 <.L29+0x3d>

008005b0 <.L23>:
	if (lflag >= 2)
  8005b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b6:	83 f9 01             	cmp    $0x1,%ecx
  8005b9:	7f 1b                	jg     8005d6 <.L23+0x26>
	else if (lflag)
  8005bb:	85 c9                	test   %ecx,%ecx
  8005bd:	74 2c                	je     8005eb <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 08                	mov    (%eax),%ecx
  8005c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c9:	8d 40 04             	lea    0x4(%eax),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cf:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005d4:	eb 77                	jmp    80064d <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 08                	mov    (%eax),%ecx
  8005db:	8b 58 04             	mov    0x4(%eax),%ebx
  8005de:	8d 40 08             	lea    0x8(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005e9:	eb 62                	jmp    80064d <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 08                	mov    (%eax),%ecx
  8005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800600:	eb 4b                	jmp    80064d <.L25+0x2b>

00800602 <.L26>:
			putch('X', putdat);
  800602:	8b 75 08             	mov    0x8(%ebp),%esi
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	57                   	push   %edi
  800609:	6a 58                	push   $0x58
  80060b:	ff d6                	call   *%esi
			putch('X', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	57                   	push   %edi
  800611:	6a 58                	push   $0x58
  800613:	ff d6                	call   *%esi
			putch('X', putdat);
  800615:	83 c4 08             	add    $0x8,%esp
  800618:	57                   	push   %edi
  800619:	6a 58                	push   $0x58
  80061b:	ff d6                	call   *%esi
			break;
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	eb 45                	jmp    800667 <.L25+0x45>

00800622 <.L25>:
			putch('0', putdat);
  800622:	8b 75 08             	mov    0x8(%ebp),%esi
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	57                   	push   %edi
  800629:	6a 30                	push   $0x30
  80062b:	ff d6                	call   *%esi
			putch('x', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	57                   	push   %edi
  800631:	6a 78                	push   $0x78
  800633:	ff d6                	call   *%esi
			num = (unsigned long long)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 08                	mov    (%eax),%ecx
  80063a:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80063f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800648:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800654:	50                   	push   %eax
  800655:	ff 75 d0             	push   -0x30(%ebp)
  800658:	52                   	push   %edx
  800659:	53                   	push   %ebx
  80065a:	51                   	push   %ecx
  80065b:	89 fa                	mov    %edi,%edx
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	e8 2c fb ff ff       	call   800190 <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800667:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80066a:	e9 4d fc ff ff       	jmp    8002bc <vprintfmt+0x34>

0080066f <.L21>:
	if (lflag >= 2)
  80066f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800672:	8b 75 08             	mov    0x8(%ebp),%esi
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7f 1b                	jg     800695 <.L21+0x26>
	else if (lflag)
  80067a:	85 c9                	test   %ecx,%ecx
  80067c:	74 2c                	je     8006aa <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 08                	mov    (%eax),%ecx
  800683:	bb 00 00 00 00       	mov    $0x0,%ebx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068e:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800693:	eb b8                	jmp    80064d <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 08                	mov    (%eax),%ecx
  80069a:	8b 58 04             	mov    0x4(%eax),%ebx
  80069d:	8d 40 08             	lea    0x8(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006a8:	eb a3                	jmp    80064d <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 08                	mov    (%eax),%ecx
  8006af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ba:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006bf:	eb 8c                	jmp    80064d <.L25+0x2b>

008006c1 <.L35>:
			putch(ch, putdat);
  8006c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	57                   	push   %edi
  8006c8:	6a 25                	push   $0x25
  8006ca:	ff d6                	call   *%esi
			break;
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	eb 96                	jmp    800667 <.L25+0x45>

008006d1 <.L20>:
			putch('%', putdat);
  8006d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	57                   	push   %edi
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e5:	74 05                	je     8006ec <.L20+0x1b>
  8006e7:	83 e8 01             	sub    $0x1,%eax
  8006ea:	eb f5                	jmp    8006e1 <.L20+0x10>
  8006ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ef:	e9 73 ff ff ff       	jmp    800667 <.L25+0x45>

008006f4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 14             	sub    $0x14,%esp
  8006fb:	e8 5f f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800700:	81 c3 00 19 00 00    	add    $0x1900,%ebx
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800713:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 2b                	je     80074c <vsnprintf+0x58>
  800721:	85 d2                	test   %edx,%edx
  800723:	7e 27                	jle    80074c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800725:	ff 75 14             	push   0x14(%ebp)
  800728:	ff 75 10             	push   0x10(%ebp)
  80072b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	8d 83 4e e2 ff ff    	lea    -0x1db2(%ebx),%eax
  800735:	50                   	push   %eax
  800736:	e8 4d fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800744:	83 c4 10             	add    $0x10,%esp
}
  800747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    
		return -E_INVAL;
  80074c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800751:	eb f4                	jmp    800747 <vsnprintf+0x53>

00800753 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075c:	50                   	push   %eax
  80075d:	ff 75 10             	push   0x10(%ebp)
  800760:	ff 75 0c             	push   0xc(%ebp)
  800763:	ff 75 08             	push   0x8(%ebp)
  800766:	e8 89 ff ff ff       	call   8006f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <__x86.get_pc_thunk.ax>:
  80076d:	8b 04 24             	mov    (%esp),%eax
  800770:	c3                   	ret    

00800771 <__x86.get_pc_thunk.cx>:
  800771:	8b 0c 24             	mov    (%esp),%ecx
  800774:	c3                   	ret    

00800775 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077b:	b8 00 00 00 00       	mov    $0x0,%eax
  800780:	eb 03                	jmp    800785 <strlen+0x10>
		n++;
  800782:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800785:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800789:	75 f7                	jne    800782 <strlen+0xd>
	return n;
}
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
  80079b:	eb 03                	jmp    8007a0 <strnlen+0x13>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	39 d0                	cmp    %edx,%eax
  8007a2:	74 08                	je     8007ac <strnlen+0x1f>
  8007a4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a8:	75 f3                	jne    80079d <strnlen+0x10>
  8007aa:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ac:	89 d0                	mov    %edx,%eax
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	53                   	push   %ebx
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bf:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c6:	83 c0 01             	add    $0x1,%eax
  8007c9:	84 d2                	test   %dl,%dl
  8007cb:	75 f2                	jne    8007bf <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cd:	89 c8                	mov    %ecx,%eax
  8007cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 10             	sub    $0x10,%esp
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 91 ff ff ff       	call   800775 <strlen>
  8007e4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	push   0xc(%ebp)
  8007ea:	01 d8                	add    %ebx,%eax
  8007ec:	50                   	push   %eax
  8007ed:	e8 be ff ff ff       	call   8007b0 <strcpy>
	return dst;
}
  8007f2:	89 d8                	mov    %ebx,%eax
  8007f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
  800804:	89 f3                	mov    %esi,%ebx
  800806:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	89 f0                	mov    %esi,%eax
  80080b:	eb 0f                	jmp    80081c <strncpy+0x23>
		*dst++ = *src;
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	0f b6 0a             	movzbl (%edx),%ecx
  800813:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 f9 01             	cmp    $0x1,%cl
  800819:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80081c:	39 d8                	cmp    %ebx,%eax
  80081e:	75 ed                	jne    80080d <strncpy+0x14>
	}
	return ret;
}
  800820:	89 f0                	mov    %esi,%eax
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	8b 55 10             	mov    0x10(%ebp),%edx
  800834:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	85 d2                	test   %edx,%edx
  800838:	74 21                	je     80085b <strlcpy+0x35>
  80083a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083e:	89 f2                	mov    %esi,%edx
  800840:	eb 09                	jmp    80084b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800842:	83 c1 01             	add    $0x1,%ecx
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 09                	je     800858 <strlcpy+0x32>
  80084f:	0f b6 19             	movzbl (%ecx),%ebx
  800852:	84 db                	test   %bl,%bl
  800854:	75 ec                	jne    800842 <strlcpy+0x1c>
  800856:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800858:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085b:	29 f0                	sub    %esi,%eax
}
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086a:	eb 06                	jmp    800872 <strcmp+0x11>
		p++, q++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800872:	0f b6 01             	movzbl (%ecx),%eax
  800875:	84 c0                	test   %al,%al
  800877:	74 04                	je     80087d <strcmp+0x1c>
  800879:	3a 02                	cmp    (%edx),%al
  80087b:	74 ef                	je     80086c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 c0             	movzbl %al,%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	89 c3                	mov    %eax,%ebx
  800893:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800896:	eb 06                	jmp    80089e <strncmp+0x17>
		n--, p++, q++;
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80089e:	39 d8                	cmp    %ebx,%eax
  8008a0:	74 18                	je     8008ba <strncmp+0x33>
  8008a2:	0f b6 08             	movzbl (%eax),%ecx
  8008a5:	84 c9                	test   %cl,%cl
  8008a7:	74 04                	je     8008ad <strncmp+0x26>
  8008a9:	3a 0a                	cmp    (%edx),%cl
  8008ab:	74 eb                	je     800898 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 00             	movzbl (%eax),%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    
		return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bf:	eb f4                	jmp    8008b5 <strncmp+0x2e>

008008c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 03                	jmp    8008d0 <strchr+0xf>
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	74 06                	je     8008dd <strchr+0x1c>
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	75 f2                	jne    8008cd <strchr+0xc>
  8008db:	eb 05                	jmp    8008e2 <strchr+0x21>
			return (char *) s;
	return 0;
  8008dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	74 09                	je     8008fe <strfind+0x1a>
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	74 05                	je     8008fe <strfind+0x1a>
	for (; *s; s++)
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	eb f0                	jmp    8008ee <strfind+0xa>
			break;
	return (char *) s;
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 7d 08             	mov    0x8(%ebp),%edi
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 2f                	je     80093f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800910:	89 f8                	mov    %edi,%eax
  800912:	09 c8                	or     %ecx,%eax
  800914:	a8 03                	test   $0x3,%al
  800916:	75 21                	jne    800939 <memset+0x39>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 08             	shl    $0x8,%eax
  800921:	89 d3                	mov    %edx,%ebx
  800923:	c1 e3 18             	shl    $0x18,%ebx
  800926:	89 d6                	mov    %edx,%esi
  800928:	c1 e6 10             	shl    $0x10,%esi
  80092b:	09 f3                	or     %esi,%ebx
  80092d:	09 da                	or     %ebx,%edx
  80092f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800931:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800934:	fc                   	cld    
  800935:	f3 ab                	rep stos %eax,%es:(%edi)
  800937:	eb 06                	jmp    80093f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093c:	fc                   	cld    
  80093d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093f:	89 f8                	mov    %edi,%eax
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	57                   	push   %edi
  80094a:	56                   	push   %esi
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800954:	39 c6                	cmp    %eax,%esi
  800956:	73 32                	jae    80098a <memmove+0x44>
  800958:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095b:	39 c2                	cmp    %eax,%edx
  80095d:	76 2b                	jbe    80098a <memmove+0x44>
		s += n;
		d += n;
  80095f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	89 d6                	mov    %edx,%esi
  800964:	09 fe                	or     %edi,%esi
  800966:	09 ce                	or     %ecx,%esi
  800968:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096e:	75 0e                	jne    80097e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800970:	83 ef 04             	sub    $0x4,%edi
  800973:	8d 72 fc             	lea    -0x4(%edx),%esi
  800976:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800979:	fd                   	std    
  80097a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097c:	eb 09                	jmp    800987 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097e:	83 ef 01             	sub    $0x1,%edi
  800981:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800984:	fd                   	std    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800987:	fc                   	cld    
  800988:	eb 1a                	jmp    8009a4 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
  80098e:	09 ca                	or     %ecx,%edx
  800990:	f6 c2 03             	test   $0x3,%dl
  800993:	75 0a                	jne    80099f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800995:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800998:	89 c7                	mov    %eax,%edi
  80099a:	fc                   	cld    
  80099b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099d:	eb 05                	jmp    8009a4 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a4:	5e                   	pop    %esi
  8009a5:	5f                   	pop    %edi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ae:	ff 75 10             	push   0x10(%ebp)
  8009b1:	ff 75 0c             	push   0xc(%ebp)
  8009b4:	ff 75 08             	push   0x8(%ebp)
  8009b7:	e8 8a ff ff ff       	call   800946 <memmove>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	eb 06                	jmp    8009d6 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009d6:	39 f0                	cmp    %esi,%eax
  8009d8:	74 14                	je     8009ee <memcmp+0x30>
		if (*s1 != *s2)
  8009da:	0f b6 08             	movzbl (%eax),%ecx
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	38 d9                	cmp    %bl,%cl
  8009e2:	74 ec                	je     8009d0 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009e4:	0f b6 c1             	movzbl %cl,%eax
  8009e7:	0f b6 db             	movzbl %bl,%ebx
  8009ea:	29 d8                	sub    %ebx,%eax
  8009ec:	eb 05                	jmp    8009f3 <memcmp+0x35>
	}

	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a05:	eb 03                	jmp    800a0a <memfind+0x13>
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	73 04                	jae    800a12 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0e:	38 08                	cmp    %cl,(%eax)
  800a10:	75 f5                	jne    800a07 <memfind+0x10>
			break;
	return (void *) s;
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x11>
		s++;
  800a22:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 02             	movzbl (%edx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0xe>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2a                	je     800a5e <strtol+0x4a>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2b                	je     800a68 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 0f                	jne    800a54 <strtol+0x40>
  800a45:	80 3a 30             	cmpb   $0x30,(%edx)
  800a48:	74 28                	je     800a72 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a51:	0f 44 d8             	cmove  %eax,%ebx
  800a54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5c:	eb 46                	jmp    800aa4 <strtol+0x90>
		s++;
  800a5e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb d5                	jmp    800a3d <strtol+0x29>
		s++, neg = 1;
  800a68:	83 c2 01             	add    $0x1,%edx
  800a6b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a70:	eb cb                	jmp    800a3d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a72:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a76:	74 0e                	je     800a86 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 d8                	jne    800a54 <strtol+0x40>
		s++, base = 8;
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a84:	eb ce                	jmp    800a54 <strtol+0x40>
		s += 2, base = 16;
  800a86:	83 c2 02             	add    $0x2,%edx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb c4                	jmp    800a54 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a90:	0f be c0             	movsbl %al,%eax
  800a93:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a96:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a99:	7d 3a                	jge    800ad5 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c2 01             	add    $0x1,%edx
  800a9e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aa2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aa4:	0f b6 02             	movzbl (%edx),%eax
  800aa7:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 09             	cmp    $0x9,%bl
  800aaf:	76 df                	jbe    800a90 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800abb:	0f be c0             	movsbl %al,%eax
  800abe:	83 e8 57             	sub    $0x57,%eax
  800ac1:	eb d3                	jmp    800a96 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800acd:	0f be c0             	movsbl %al,%eax
  800ad0:	83 e8 37             	sub    $0x37,%eax
  800ad3:	eb c1                	jmp    800a96 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad9:	74 05                	je     800ae0 <strtol+0xcc>
		*endptr = (char *) s;
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ae0:	89 c8                	mov    %ecx,%eax
  800ae2:	f7 d8                	neg    %eax
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	0f 45 c8             	cmovne %eax,%ecx
}
  800ae9:	89 c8                	mov    %ecx,%eax
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	89 c7                	mov    %eax,%edi
  800b05:	89 c6                	mov    %eax,%esi
  800b07:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1e:	89 d1                	mov    %edx,%ecx
  800b20:	89 d3                	mov    %edx,%ebx
  800b22:	89 d7                	mov    %edx,%edi
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 1c             	sub    $0x1c,%esp
  800b36:	e8 32 fc ff ff       	call   80076d <__x86.get_pc_thunk.ax>
  800b3b:	05 c5 14 00 00       	add    $0x14c5,%eax
  800b40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b50:	89 cb                	mov    %ecx,%ebx
  800b52:	89 cf                	mov    %ecx,%edi
  800b54:	89 ce                	mov    %ecx,%esi
  800b56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	7f 08                	jg     800b64 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	50                   	push   %eax
  800b68:	6a 03                	push   $0x3
  800b6a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b6d:	8d 83 44 f0 ff ff    	lea    -0xfbc(%ebx),%eax
  800b73:	50                   	push   %eax
  800b74:	6a 23                	push   $0x23
  800b76:	8d 83 61 f0 ff ff    	lea    -0xf9f(%ebx),%eax
  800b7c:	50                   	push   %eax
  800b7d:	e8 1f 00 00 00       	call   800ba1 <_panic>

00800b82 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b92:	89 d1                	mov    %edx,%ecx
  800b94:	89 d3                	mov    %edx,%ebx
  800b96:	89 d7                	mov    %edx,%edi
  800b98:	89 d6                	mov    %edx,%esi
  800b9a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	e8 b0 f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800baf:	81 c3 51 14 00 00    	add    $0x1451,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bb5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bb8:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bbe:	8b 38                	mov    (%eax),%edi
  800bc0:	e8 bd ff ff ff       	call   800b82 <sys_getenvid>
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	ff 75 0c             	push   0xc(%ebp)
  800bcb:	ff 75 08             	push   0x8(%ebp)
  800bce:	57                   	push   %edi
  800bcf:	50                   	push   %eax
  800bd0:	8d 83 70 f0 ff ff    	lea    -0xf90(%ebx),%eax
  800bd6:	50                   	push   %eax
  800bd7:	e8 a0 f5 ff ff       	call   80017c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bdc:	83 c4 18             	add    $0x18,%esp
  800bdf:	56                   	push   %esi
  800be0:	ff 75 10             	push   0x10(%ebp)
  800be3:	e8 32 f5 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800be8:	8d 83 50 ee ff ff    	lea    -0x11b0(%ebx),%eax
  800bee:	89 04 24             	mov    %eax,(%esp)
  800bf1:	e8 86 f5 ff ff       	call   80017c <cprintf>
  800bf6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800bf9:	cc                   	int3   
  800bfa:	eb fd                	jmp    800bf9 <_panic+0x58>
  800bfc:	66 90                	xchg   %ax,%ax
  800bfe:	66 90                	xchg   %ax,%ax

00800c00 <__udivdi3>:
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	75 19                	jne    800c38 <__udivdi3+0x38>
  800c1f:	39 f3                	cmp    %esi,%ebx
  800c21:	76 4d                	jbe    800c70 <__udivdi3+0x70>
  800c23:	31 ff                	xor    %edi,%edi
  800c25:	89 e8                	mov    %ebp,%eax
  800c27:	89 f2                	mov    %esi,%edx
  800c29:	f7 f3                	div    %ebx
  800c2b:	89 fa                	mov    %edi,%edx
  800c2d:	83 c4 1c             	add    $0x1c,%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
  800c35:	8d 76 00             	lea    0x0(%esi),%esi
  800c38:	39 f0                	cmp    %esi,%eax
  800c3a:	76 14                	jbe    800c50 <__udivdi3+0x50>
  800c3c:	31 ff                	xor    %edi,%edi
  800c3e:	31 c0                	xor    %eax,%eax
  800c40:	89 fa                	mov    %edi,%edx
  800c42:	83 c4 1c             	add    $0x1c,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
  800c4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c50:	0f bd f8             	bsr    %eax,%edi
  800c53:	83 f7 1f             	xor    $0x1f,%edi
  800c56:	75 48                	jne    800ca0 <__udivdi3+0xa0>
  800c58:	39 f0                	cmp    %esi,%eax
  800c5a:	72 06                	jb     800c62 <__udivdi3+0x62>
  800c5c:	31 c0                	xor    %eax,%eax
  800c5e:	39 eb                	cmp    %ebp,%ebx
  800c60:	77 de                	ja     800c40 <__udivdi3+0x40>
  800c62:	b8 01 00 00 00       	mov    $0x1,%eax
  800c67:	eb d7                	jmp    800c40 <__udivdi3+0x40>
  800c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c70:	89 d9                	mov    %ebx,%ecx
  800c72:	85 db                	test   %ebx,%ebx
  800c74:	75 0b                	jne    800c81 <__udivdi3+0x81>
  800c76:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7b:	31 d2                	xor    %edx,%edx
  800c7d:	f7 f3                	div    %ebx
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	31 d2                	xor    %edx,%edx
  800c83:	89 f0                	mov    %esi,%eax
  800c85:	f7 f1                	div    %ecx
  800c87:	89 c6                	mov    %eax,%esi
  800c89:	89 e8                	mov    %ebp,%eax
  800c8b:	89 f7                	mov    %esi,%edi
  800c8d:	f7 f1                	div    %ecx
  800c8f:	89 fa                	mov    %edi,%edx
  800c91:	83 c4 1c             	add    $0x1c,%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	ba 20 00 00 00       	mov    $0x20,%edx
  800ca7:	29 fa                	sub    %edi,%edx
  800ca9:	d3 e0                	shl    %cl,%eax
  800cab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800caf:	89 d1                	mov    %edx,%ecx
  800cb1:	89 d8                	mov    %ebx,%eax
  800cb3:	d3 e8                	shr    %cl,%eax
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 c1                	or     %eax,%ecx
  800cbb:	89 f0                	mov    %esi,%eax
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	d3 e8                	shr    %cl,%eax
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	89 eb                	mov    %ebp,%ebx
  800cd1:	d3 e6                	shl    %cl,%esi
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 f3                	or     %esi,%ebx
  800cd9:	89 c6                	mov    %eax,%esi
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	89 d8                	mov    %ebx,%eax
  800cdf:	f7 74 24 08          	divl   0x8(%esp)
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	89 c3                	mov    %eax,%ebx
  800ce7:	f7 64 24 0c          	mull   0xc(%esp)
  800ceb:	39 d6                	cmp    %edx,%esi
  800ced:	72 19                	jb     800d08 <__udivdi3+0x108>
  800cef:	89 f9                	mov    %edi,%ecx
  800cf1:	d3 e5                	shl    %cl,%ebp
  800cf3:	39 c5                	cmp    %eax,%ebp
  800cf5:	73 04                	jae    800cfb <__udivdi3+0xfb>
  800cf7:	39 d6                	cmp    %edx,%esi
  800cf9:	74 0d                	je     800d08 <__udivdi3+0x108>
  800cfb:	89 d8                	mov    %ebx,%eax
  800cfd:	31 ff                	xor    %edi,%edi
  800cff:	e9 3c ff ff ff       	jmp    800c40 <__udivdi3+0x40>
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d0b:	31 ff                	xor    %edi,%edi
  800d0d:	e9 2e ff ff ff       	jmp    800c40 <__udivdi3+0x40>
  800d12:	66 90                	xchg   %ax,%ax
  800d14:	66 90                	xchg   %ax,%ax
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__umoddi3>:
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
  800d2b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d33:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d37:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d3b:	89 f0                	mov    %esi,%eax
  800d3d:	89 da                	mov    %ebx,%edx
  800d3f:	85 ff                	test   %edi,%edi
  800d41:	75 15                	jne    800d58 <__umoddi3+0x38>
  800d43:	39 dd                	cmp    %ebx,%ebp
  800d45:	76 39                	jbe    800d80 <__umoddi3+0x60>
  800d47:	f7 f5                	div    %ebp
  800d49:	89 d0                	mov    %edx,%eax
  800d4b:	31 d2                	xor    %edx,%edx
  800d4d:	83 c4 1c             	add    $0x1c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	39 df                	cmp    %ebx,%edi
  800d5a:	77 f1                	ja     800d4d <__umoddi3+0x2d>
  800d5c:	0f bd cf             	bsr    %edi,%ecx
  800d5f:	83 f1 1f             	xor    $0x1f,%ecx
  800d62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d66:	75 40                	jne    800da8 <__umoddi3+0x88>
  800d68:	39 df                	cmp    %ebx,%edi
  800d6a:	72 04                	jb     800d70 <__umoddi3+0x50>
  800d6c:	39 f5                	cmp    %esi,%ebp
  800d6e:	77 dd                	ja     800d4d <__umoddi3+0x2d>
  800d70:	89 da                	mov    %ebx,%edx
  800d72:	89 f0                	mov    %esi,%eax
  800d74:	29 e8                	sub    %ebp,%eax
  800d76:	19 fa                	sbb    %edi,%edx
  800d78:	eb d3                	jmp    800d4d <__umoddi3+0x2d>
  800d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d80:	89 e9                	mov    %ebp,%ecx
  800d82:	85 ed                	test   %ebp,%ebp
  800d84:	75 0b                	jne    800d91 <__umoddi3+0x71>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f5                	div    %ebp
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	89 d8                	mov    %ebx,%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	f7 f1                	div    %ecx
  800d97:	89 f0                	mov    %esi,%eax
  800d99:	f7 f1                	div    %ecx
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	31 d2                	xor    %edx,%edx
  800d9f:	eb ac                	jmp    800d4d <__umoddi3+0x2d>
  800da1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dac:	ba 20 00 00 00       	mov    $0x20,%edx
  800db1:	29 c2                	sub    %eax,%edx
  800db3:	89 c1                	mov    %eax,%ecx
  800db5:	89 e8                	mov    %ebp,%eax
  800db7:	d3 e7                	shl    %cl,%edi
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dbf:	d3 e8                	shr    %cl,%eax
  800dc1:	89 c1                	mov    %eax,%ecx
  800dc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dc7:	09 f9                	or     %edi,%ecx
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcf:	89 c1                	mov    %eax,%ecx
  800dd1:	d3 e5                	shl    %cl,%ebp
  800dd3:	89 d1                	mov    %edx,%ecx
  800dd5:	d3 ef                	shr    %cl,%edi
  800dd7:	89 c1                	mov    %eax,%ecx
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	d3 e3                	shl    %cl,%ebx
  800ddd:	89 d1                	mov    %edx,%ecx
  800ddf:	89 fa                	mov    %edi,%edx
  800de1:	d3 e8                	shr    %cl,%eax
  800de3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800de8:	09 d8                	or     %ebx,%eax
  800dea:	f7 74 24 08          	divl   0x8(%esp)
  800dee:	89 d3                	mov    %edx,%ebx
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	f7 e5                	mul    %ebp
  800df4:	89 c7                	mov    %eax,%edi
  800df6:	89 d1                	mov    %edx,%ecx
  800df8:	39 d3                	cmp    %edx,%ebx
  800dfa:	72 06                	jb     800e02 <__umoddi3+0xe2>
  800dfc:	75 0e                	jne    800e0c <__umoddi3+0xec>
  800dfe:	39 c6                	cmp    %eax,%esi
  800e00:	73 0a                	jae    800e0c <__umoddi3+0xec>
  800e02:	29 e8                	sub    %ebp,%eax
  800e04:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e08:	89 d1                	mov    %edx,%ecx
  800e0a:	89 c7                	mov    %eax,%edi
  800e0c:	89 f5                	mov    %esi,%ebp
  800e0e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e12:	29 fd                	sub    %edi,%ebp
  800e14:	19 cb                	sbb    %ecx,%ebx
  800e16:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	d3 e0                	shl    %cl,%eax
  800e1f:	89 f1                	mov    %esi,%ecx
  800e21:	d3 ed                	shr    %cl,%ebp
  800e23:	d3 eb                	shr    %cl,%ebx
  800e25:	09 e8                	or     %ebp,%eax
  800e27:	89 da                	mov    %ebx,%edx
  800e29:	83 c4 1c             	add    $0x1c,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    
