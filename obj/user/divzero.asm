
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 32 00 00 00       	call   800071 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80004c:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  80004f:	b8 01 00 00 00       	mov    $0x1,%eax
  800054:	b9 00 00 00 00       	mov    $0x0,%ecx
  800059:	99                   	cltd   
  80005a:	f7 f9                	idiv   %ecx
  80005c:	50                   	push   %eax
  80005d:	8d 83 44 ee ff ff    	lea    -0x11bc(%ebx),%eax
  800063:	50                   	push   %eax
  800064:	e8 25 01 00 00       	call   80018e <cprintf>
}
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006f:	c9                   	leave  
  800070:	c3                   	ret    

00800071 <__x86.get_pc_thunk.bx>:
  800071:	8b 1c 24             	mov    (%esp),%ebx
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	53                   	push   %ebx
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	e8 f0 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800081:	81 c3 7f 1f 00 00    	add    $0x1f7f,%ebx
  800087:	8b 45 08             	mov    0x8(%ebp),%eax
  80008a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  80008d:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  800093:	89 8b 30 00 00 00    	mov    %ecx,0x30(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 c0                	test   %eax,%eax
  80009b:	7e 08                	jle    8000a5 <libmain+0x30>
		binaryname = argv[0];
  80009d:	8b 0a                	mov    (%edx),%ecx
  80009f:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	52                   	push   %edx
  8000a9:	50                   	push   %eax
  8000aa:	e8 84 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000af:	e8 08 00 00 00       	call   8000bc <exit>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 10             	sub    $0x10,%esp
  8000c3:	e8 a9 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000c8:	81 c3 38 1f 00 00    	add    $0x1f38,%ebx
	sys_env_destroy(0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	e8 6a 0a 00 00       	call   800b3f <sys_env_destroy>
}
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000db:	c9                   	leave  
  8000dc:	c3                   	ret    

008000dd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	e8 8a ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  8000e7:	81 c3 19 1f 00 00    	add    $0x1f19,%ebx
  8000ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f0:	8b 16                	mov    (%esi),%edx
  8000f2:	8d 42 01             	lea    0x1(%edx),%eax
  8000f5:	89 06                	mov    %eax,(%esi)
  8000f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fa:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800103:	74 0b                	je     800110 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800105:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	68 ff 00 00 00       	push   $0xff
  800118:	8d 46 08             	lea    0x8(%esi),%eax
  80011b:	50                   	push   %eax
  80011c:	e8 e1 09 00 00       	call   800b02 <sys_cputs>
		b->idx = 0;
  800121:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	eb d9                	jmp    800105 <putch+0x28>

0080012c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800136:	e8 36 ff ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  80013b:	81 c3 c5 1e 00 00    	add    $0x1ec5,%ebx
	struct printbuf b;

	b.idx = 0;
  800141:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800148:	00 00 00 
	b.cnt = 0;
  80014b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800152:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800155:	ff 75 0c             	push   0xc(%ebp)
  800158:	ff 75 08             	push   0x8(%ebp)
  80015b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800161:	50                   	push   %eax
  800162:	8d 83 dd e0 ff ff    	lea    -0x1f23(%ebx),%eax
  800168:	50                   	push   %eax
  800169:	e8 2c 01 00 00       	call   80029a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016e:	83 c4 08             	add    $0x8,%esp
  800171:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800177:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 7f 09 00 00       	call   800b02 <sys_cputs>

	return b.cnt;
}
  800183:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800194:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800197:	50                   	push   %eax
  800198:	ff 75 08             	push   0x8(%ebp)
  80019b:	e8 8c ff ff ff       	call   80012c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 2c             	sub    $0x2c,%esp
  8001ab:	e8 d3 05 00 00       	call   800783 <__x86.get_pc_thunk.cx>
  8001b0:	81 c1 50 1e 00 00    	add    $0x1e50,%ecx
  8001b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001b9:	89 c7                	mov    %eax,%edi
  8001bb:	89 d6                	mov    %edx,%esi
  8001bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c3:	89 d1                	mov    %edx,%ecx
  8001c5:	89 c2                	mov    %eax,%edx
  8001c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001ca:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8001cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001dd:	39 c2                	cmp    %eax,%edx
  8001df:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e2:	72 41                	jb     800225 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 18             	push   0x18(%ebp)
  8001ea:	83 eb 01             	sub    $0x1,%ebx
  8001ed:	53                   	push   %ebx
  8001ee:	50                   	push   %eax
  8001ef:	83 ec 08             	sub    $0x8,%esp
  8001f2:	ff 75 e4             	push   -0x1c(%ebp)
  8001f5:	ff 75 e0             	push   -0x20(%ebp)
  8001f8:	ff 75 d4             	push   -0x2c(%ebp)
  8001fb:	ff 75 d0             	push   -0x30(%ebp)
  8001fe:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800201:	e8 0a 0a 00 00       	call   800c10 <__udivdi3>
  800206:	83 c4 18             	add    $0x18,%esp
  800209:	52                   	push   %edx
  80020a:	50                   	push   %eax
  80020b:	89 f2                	mov    %esi,%edx
  80020d:	89 f8                	mov    %edi,%eax
  80020f:	e8 8e ff ff ff       	call   8001a2 <printnum>
  800214:	83 c4 20             	add    $0x20,%esp
  800217:	eb 13                	jmp    80022c <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	ff 75 18             	push   0x18(%ebp)
  800220:	ff d7                	call   *%edi
  800222:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800225:	83 eb 01             	sub    $0x1,%ebx
  800228:	85 db                	test   %ebx,%ebx
  80022a:	7f ed                	jg     800219 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	83 ec 04             	sub    $0x4,%esp
  800233:	ff 75 e4             	push   -0x1c(%ebp)
  800236:	ff 75 e0             	push   -0x20(%ebp)
  800239:	ff 75 d4             	push   -0x2c(%ebp)
  80023c:	ff 75 d0             	push   -0x30(%ebp)
  80023f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800242:	e8 e9 0a 00 00       	call   800d30 <__umoddi3>
  800247:	83 c4 14             	add    $0x14,%esp
  80024a:	0f be 84 03 5c ee ff 	movsbl -0x11a4(%ebx,%eax,1),%eax
  800251:	ff 
  800252:	50                   	push   %eax
  800253:	ff d7                	call   *%edi
}
  800255:	83 c4 10             	add    $0x10,%esp
  800258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5f                   	pop    %edi
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800266:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	3b 50 04             	cmp    0x4(%eax),%edx
  80026f:	73 0a                	jae    80027b <sprintputch+0x1b>
		*b->buf++ = ch;
  800271:	8d 4a 01             	lea    0x1(%edx),%ecx
  800274:	89 08                	mov    %ecx,(%eax)
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	88 02                	mov    %al,(%edx)
}
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <printfmt>:
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800283:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800286:	50                   	push   %eax
  800287:	ff 75 10             	push   0x10(%ebp)
  80028a:	ff 75 0c             	push   0xc(%ebp)
  80028d:	ff 75 08             	push   0x8(%ebp)
  800290:	e8 05 00 00 00       	call   80029a <vprintfmt>
}
  800295:	83 c4 10             	add    $0x10,%esp
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <vprintfmt>:
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	57                   	push   %edi
  80029e:	56                   	push   %esi
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 3c             	sub    $0x3c,%esp
  8002a3:	e8 d7 04 00 00       	call   80077f <__x86.get_pc_thunk.ax>
  8002a8:	05 58 1d 00 00       	add    $0x1d58,%eax
  8002ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8002b9:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8002bf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8002c2:	eb 0a                	jmp    8002ce <vprintfmt+0x34>
			putch(ch, putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	57                   	push   %edi
  8002c8:	50                   	push   %eax
  8002c9:	ff d6                	call   *%esi
  8002cb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ce:	83 c3 01             	add    $0x1,%ebx
  8002d1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8002d5:	83 f8 25             	cmp    $0x25,%eax
  8002d8:	74 0c                	je     8002e6 <vprintfmt+0x4c>
			if (ch == '\0')
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	75 e6                	jne    8002c4 <vprintfmt+0x2a>
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		padc = ' ';
  8002e6:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8002ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800304:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800307:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 43 01             	lea    0x1(%ebx),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 13             	movzbl (%ebx),%edx
  800313:	8d 42 dd             	lea    -0x23(%edx),%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 c5 03 00 00    	ja     8006e3 <.L20>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800324:	89 ce                	mov    %ecx,%esi
  800326:	03 b4 81 ec ee ff ff 	add    -0x1114(%ecx,%eax,4),%esi
  80032d:	ff e6                	jmp    *%esi

0080032f <.L66>:
  80032f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800332:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800336:	eb d2                	jmp    80030a <vprintfmt+0x70>

00800338 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80033b:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80033f:	eb c9                	jmp    80030a <vprintfmt+0x70>

00800341 <.L31>:
  800341:	0f b6 d2             	movzbl %dl,%edx
  800344:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800347:	b8 00 00 00 00       	mov    $0x0,%eax
  80034c:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80034f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800352:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800356:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800359:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80035c:	83 f9 09             	cmp    $0x9,%ecx
  80035f:	77 58                	ja     8003b9 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800361:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800364:	eb e9                	jmp    80034f <.L31+0xe>

00800366 <.L34>:
			precision = va_arg(ap, int);
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8b 00                	mov    (%eax),%eax
  80036b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80036e:	8b 45 14             	mov    0x14(%ebp),%eax
  800371:	8d 40 04             	lea    0x4(%eax),%eax
  800374:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80037a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80037e:	79 8a                	jns    80030a <vprintfmt+0x70>
				width = precision, precision = -1;
  800380:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800383:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800386:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80038d:	e9 78 ff ff ff       	jmp    80030a <vprintfmt+0x70>

00800392 <.L33>:
  800392:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800395:	85 d2                	test   %edx,%edx
  800397:	b8 00 00 00 00       	mov    $0x0,%eax
  80039c:	0f 49 c2             	cmovns %edx,%eax
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003a5:	e9 60 ff ff ff       	jmp    80030a <vprintfmt+0x70>

008003aa <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8003ad:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003b4:	e9 51 ff ff ff       	jmp    80030a <vprintfmt+0x70>
  8003b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8003bf:	eb b9                	jmp    80037a <.L34+0x14>

008003c1 <.L27>:
			lflag++;
  8003c1:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8003c8:	e9 3d ff ff ff       	jmp    80030a <vprintfmt+0x70>

008003cd <.L30>:
			putch(va_arg(ap, int), putdat);
  8003cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 58 04             	lea    0x4(%eax),%ebx
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	57                   	push   %edi
  8003da:	ff 30                	push   (%eax)
  8003dc:	ff d6                	call   *%esi
			break;
  8003de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e1:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8003e4:	e9 90 02 00 00       	jmp    800679 <.L25+0x45>

008003e9 <.L28>:
			err = va_arg(ap, int);
  8003e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 58 04             	lea    0x4(%eax),%ebx
  8003f2:	8b 10                	mov    (%eax),%edx
  8003f4:	89 d0                	mov    %edx,%eax
  8003f6:	f7 d8                	neg    %eax
  8003f8:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fb:	83 f8 06             	cmp    $0x6,%eax
  8003fe:	7f 27                	jg     800427 <.L28+0x3e>
  800400:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800403:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800406:	85 d2                	test   %edx,%edx
  800408:	74 1d                	je     800427 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  80040a:	52                   	push   %edx
  80040b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040e:	8d 80 7d ee ff ff    	lea    -0x1183(%eax),%eax
  800414:	50                   	push   %eax
  800415:	57                   	push   %edi
  800416:	56                   	push   %esi
  800417:	e8 61 fe ff ff       	call   80027d <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800422:	e9 52 02 00 00       	jmp    800679 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800427:	50                   	push   %eax
  800428:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042b:	8d 80 74 ee ff ff    	lea    -0x118c(%eax),%eax
  800431:	50                   	push   %eax
  800432:	57                   	push   %edi
  800433:	56                   	push   %esi
  800434:	e8 44 fe ff ff       	call   80027d <printfmt>
  800439:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043f:	e9 35 02 00 00       	jmp    800679 <.L25+0x45>

00800444 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800444:	8b 75 08             	mov    0x8(%ebp),%esi
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	83 c0 04             	add    $0x4,%eax
  80044d:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800455:	85 d2                	test   %edx,%edx
  800457:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045a:	8d 80 6d ee ff ff    	lea    -0x1193(%eax),%eax
  800460:	0f 45 c2             	cmovne %edx,%eax
  800463:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800466:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80046a:	7e 06                	jle    800472 <.L24+0x2e>
  80046c:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800470:	75 0d                	jne    80047f <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800475:	89 c3                	mov    %eax,%ebx
  800477:	03 45 d0             	add    -0x30(%ebp),%eax
  80047a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047d:	eb 58                	jmp    8004d7 <.L24+0x93>
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 d8             	push   -0x28(%ebp)
  800485:	ff 75 c8             	push   -0x38(%ebp)
  800488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048b:	e8 0f 03 00 00       	call   80079f <strnlen>
  800490:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800493:	29 c2                	sub    %eax,%edx
  800495:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80049d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  8004a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	eb 0f                	jmp    8004b5 <.L24+0x71>
					putch(padc, putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	57                   	push   %edi
  8004aa:	ff 75 d0             	push   -0x30(%ebp)
  8004ad:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	83 eb 01             	sub    $0x1,%ebx
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	85 db                	test   %ebx,%ebx
  8004b7:	7f ed                	jg     8004a6 <.L24+0x62>
  8004b9:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	0f 49 c2             	cmovns %edx,%eax
  8004c6:	29 c2                	sub    %eax,%edx
  8004c8:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004cb:	eb a5                	jmp    800472 <.L24+0x2e>
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	57                   	push   %edi
  8004d1:	52                   	push   %edx
  8004d2:	ff d6                	call   *%esi
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004da:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dc:	83 c3 01             	add    $0x1,%ebx
  8004df:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8004e3:	0f be d0             	movsbl %al,%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 4b                	je     800535 <.L24+0xf1>
  8004ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ee:	78 06                	js     8004f6 <.L24+0xb2>
  8004f0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f4:	78 1e                	js     800514 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fa:	74 d1                	je     8004cd <.L24+0x89>
  8004fc:	0f be c0             	movsbl %al,%eax
  8004ff:	83 e8 20             	sub    $0x20,%eax
  800502:	83 f8 5e             	cmp    $0x5e,%eax
  800505:	76 c6                	jbe    8004cd <.L24+0x89>
					putch('?', putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	57                   	push   %edi
  80050b:	6a 3f                	push   $0x3f
  80050d:	ff d6                	call   *%esi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	eb c3                	jmp    8004d7 <.L24+0x93>
  800514:	89 cb                	mov    %ecx,%ebx
  800516:	eb 0e                	jmp    800526 <.L24+0xe2>
				putch(' ', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	57                   	push   %edi
  80051c:	6a 20                	push   $0x20
  80051e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800520:	83 eb 01             	sub    $0x1,%ebx
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	85 db                	test   %ebx,%ebx
  800528:	7f ee                	jg     800518 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80052a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80052d:	89 45 14             	mov    %eax,0x14(%ebp)
  800530:	e9 44 01 00 00       	jmp    800679 <.L25+0x45>
  800535:	89 cb                	mov    %ecx,%ebx
  800537:	eb ed                	jmp    800526 <.L24+0xe2>

00800539 <.L29>:
	if (lflag >= 2)
  800539:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	83 f9 01             	cmp    $0x1,%ecx
  800542:	7f 1b                	jg     80055f <.L29+0x26>
	else if (lflag)
  800544:	85 c9                	test   %ecx,%ecx
  800546:	74 63                	je     8005ab <.L29+0x72>
		return va_arg(*ap, long);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	99                   	cltd   
  800551:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 40 04             	lea    0x4(%eax),%eax
  80055a:	89 45 14             	mov    %eax,0x14(%ebp)
  80055d:	eb 17                	jmp    800576 <.L29+0x3d>
		return va_arg(*ap, long long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 50 04             	mov    0x4(%eax),%edx
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 08             	lea    0x8(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800576:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800579:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80057c:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800581:	85 db                	test   %ebx,%ebx
  800583:	0f 89 d6 00 00 00    	jns    80065f <.L25+0x2b>
				putch('-', putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	57                   	push   %edi
  80058d:	6a 2d                	push   $0x2d
  80058f:	ff d6                	call   *%esi
				num = -(long long) num;
  800591:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800594:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800597:	f7 d9                	neg    %ecx
  800599:	83 d3 00             	adc    $0x0,%ebx
  80059c:	f7 db                	neg    %ebx
  80059e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a1:	ba 0a 00 00 00       	mov    $0xa,%edx
  8005a6:	e9 b4 00 00 00       	jmp    80065f <.L25+0x2b>
		return va_arg(*ap, int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	99                   	cltd   
  8005b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 40 04             	lea    0x4(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c0:	eb b4                	jmp    800576 <.L29+0x3d>

008005c2 <.L23>:
	if (lflag >= 2)
  8005c2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7f 1b                	jg     8005e8 <.L23+0x26>
	else if (lflag)
  8005cd:	85 c9                	test   %ecx,%ecx
  8005cf:	74 2c                	je     8005fd <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8b 08                	mov    (%eax),%ecx
  8005d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8005e6:	eb 77                	jmp    80065f <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 08                	mov    (%eax),%ecx
  8005ed:	8b 58 04             	mov    0x4(%eax),%ebx
  8005f0:	8d 40 08             	lea    0x8(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8005fb:	eb 62                	jmp    80065f <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 08                	mov    (%eax),%ecx
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
  800607:	8d 40 04             	lea    0x4(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060d:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800612:	eb 4b                	jmp    80065f <.L25+0x2b>

00800614 <.L26>:
			putch('X', putdat);
  800614:	8b 75 08             	mov    0x8(%ebp),%esi
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	57                   	push   %edi
  80061b:	6a 58                	push   $0x58
  80061d:	ff d6                	call   *%esi
			putch('X', putdat);
  80061f:	83 c4 08             	add    $0x8,%esp
  800622:	57                   	push   %edi
  800623:	6a 58                	push   $0x58
  800625:	ff d6                	call   *%esi
			putch('X', putdat);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	57                   	push   %edi
  80062b:	6a 58                	push   $0x58
  80062d:	ff d6                	call   *%esi
			break;
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	eb 45                	jmp    800679 <.L25+0x45>

00800634 <.L25>:
			putch('0', putdat);
  800634:	8b 75 08             	mov    0x8(%ebp),%esi
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 30                	push   $0x30
  80063d:	ff d6                	call   *%esi
			putch('x', putdat);
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	57                   	push   %edi
  800643:	6a 78                	push   $0x78
  800645:	ff d6                	call   *%esi
			num = (unsigned long long)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 08                	mov    (%eax),%ecx
  80064c:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800651:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065a:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	ff 75 d0             	push   -0x30(%ebp)
  80066a:	52                   	push   %edx
  80066b:	53                   	push   %ebx
  80066c:	51                   	push   %ecx
  80066d:	89 fa                	mov    %edi,%edx
  80066f:	89 f0                	mov    %esi,%eax
  800671:	e8 2c fb ff ff       	call   8001a2 <printnum>
			break;
  800676:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80067c:	e9 4d fc ff ff       	jmp    8002ce <vprintfmt+0x34>

00800681 <.L21>:
	if (lflag >= 2)
  800681:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800684:	8b 75 08             	mov    0x8(%ebp),%esi
  800687:	83 f9 01             	cmp    $0x1,%ecx
  80068a:	7f 1b                	jg     8006a7 <.L21+0x26>
	else if (lflag)
  80068c:	85 c9                	test   %ecx,%ecx
  80068e:	74 2c                	je     8006bc <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 08                	mov    (%eax),%ecx
  800695:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a0:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8006a5:	eb b8                	jmp    80065f <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 08                	mov    (%eax),%ecx
  8006ac:	8b 58 04             	mov    0x4(%eax),%ebx
  8006af:	8d 40 08             	lea    0x8(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8006ba:	eb a3                	jmp    80065f <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 08                	mov    (%eax),%ecx
  8006c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cc:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8006d1:	eb 8c                	jmp    80065f <.L25+0x2b>

008006d3 <.L35>:
			putch(ch, putdat);
  8006d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	57                   	push   %edi
  8006da:	6a 25                	push   $0x25
  8006dc:	ff d6                	call   *%esi
			break;
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 96                	jmp    800679 <.L25+0x45>

008006e3 <.L20>:
			putch('%', putdat);
  8006e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	57                   	push   %edi
  8006ea:	6a 25                	push   $0x25
  8006ec:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f7:	74 05                	je     8006fe <.L20+0x1b>
  8006f9:	83 e8 01             	sub    $0x1,%eax
  8006fc:	eb f5                	jmp    8006f3 <.L20+0x10>
  8006fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800701:	e9 73 ff ff ff       	jmp    800679 <.L25+0x45>

00800706 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	53                   	push   %ebx
  80070a:	83 ec 14             	sub    $0x14,%esp
  80070d:	e8 5f f9 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800712:	81 c3 ee 18 00 00    	add    $0x18ee,%ebx
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800721:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800725:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 2b                	je     80075e <vsnprintf+0x58>
  800733:	85 d2                	test   %edx,%edx
  800735:	7e 27                	jle    80075e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800737:	ff 75 14             	push   0x14(%ebp)
  80073a:	ff 75 10             	push   0x10(%ebp)
  80073d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800740:	50                   	push   %eax
  800741:	8d 83 60 e2 ff ff    	lea    -0x1da0(%ebx),%eax
  800747:	50                   	push   %eax
  800748:	e8 4d fb ff ff       	call   80029a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
}
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800763:	eb f4                	jmp    800759 <vsnprintf+0x53>

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	push   0x10(%ebp)
  800772:	ff 75 0c             	push   0xc(%ebp)
  800775:	ff 75 08             	push   0x8(%ebp)
  800778:	e8 89 ff ff ff       	call   800706 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <__x86.get_pc_thunk.ax>:
  80077f:	8b 04 24             	mov    (%esp),%eax
  800782:	c3                   	ret    

00800783 <__x86.get_pc_thunk.cx>:
  800783:	8b 0c 24             	mov    (%esp),%ecx
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strlen+0x10>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079b:	75 f7                	jne    800794 <strlen+0xd>
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 03                	jmp    8007b2 <strnlen+0x13>
		n++;
  8007af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	39 d0                	cmp    %edx,%eax
  8007b4:	74 08                	je     8007be <strnlen+0x1f>
  8007b6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ba:	75 f3                	jne    8007af <strnlen+0x10>
  8007bc:	89 c2                	mov    %eax,%edx
	return n;
}
  8007be:	89 d0                	mov    %edx,%eax
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d8:	83 c0 01             	add    $0x1,%eax
  8007db:	84 d2                	test   %dl,%dl
  8007dd:	75 f2                	jne    8007d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007df:	89 c8                	mov    %ecx,%eax
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	83 ec 10             	sub    $0x10,%esp
  8007ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f0:	53                   	push   %ebx
  8007f1:	e8 91 ff ff ff       	call   800787 <strlen>
  8007f6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f9:	ff 75 0c             	push   0xc(%ebp)
  8007fc:	01 d8                	add    %ebx,%eax
  8007fe:	50                   	push   %eax
  8007ff:	e8 be ff ff ff       	call   8007c2 <strcpy>
	return dst;
}
  800804:	89 d8                	mov    %ebx,%eax
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	56                   	push   %esi
  80080f:	53                   	push   %ebx
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
  800816:	89 f3                	mov    %esi,%ebx
  800818:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081b:	89 f0                	mov    %esi,%eax
  80081d:	eb 0f                	jmp    80082e <strncpy+0x23>
		*dst++ = *src;
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	0f b6 0a             	movzbl (%edx),%ecx
  800825:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800828:	80 f9 01             	cmp    $0x1,%cl
  80082b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80082e:	39 d8                	cmp    %ebx,%eax
  800830:	75 ed                	jne    80081f <strncpy+0x14>
	}
	return ret;
}
  800832:	89 f0                	mov    %esi,%eax
  800834:	5b                   	pop    %ebx
  800835:	5e                   	pop    %esi
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	56                   	push   %esi
  80083c:	53                   	push   %ebx
  80083d:	8b 75 08             	mov    0x8(%ebp),%esi
  800840:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800843:	8b 55 10             	mov    0x10(%ebp),%edx
  800846:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800848:	85 d2                	test   %edx,%edx
  80084a:	74 21                	je     80086d <strlcpy+0x35>
  80084c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800850:	89 f2                	mov    %esi,%edx
  800852:	eb 09                	jmp    80085d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	83 c2 01             	add    $0x1,%edx
  80085a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80085d:	39 c2                	cmp    %eax,%edx
  80085f:	74 09                	je     80086a <strlcpy+0x32>
  800861:	0f b6 19             	movzbl (%ecx),%ebx
  800864:	84 db                	test   %bl,%bl
  800866:	75 ec                	jne    800854 <strlcpy+0x1c>
  800868:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80086a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086d:	29 f0                	sub    %esi,%eax
}
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087c:	eb 06                	jmp    800884 <strcmp+0x11>
		p++, q++;
  80087e:	83 c1 01             	add    $0x1,%ecx
  800881:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800884:	0f b6 01             	movzbl (%ecx),%eax
  800887:	84 c0                	test   %al,%al
  800889:	74 04                	je     80088f <strcmp+0x1c>
  80088b:	3a 02                	cmp    (%edx),%al
  80088d:	74 ef                	je     80087e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088f:	0f b6 c0             	movzbl %al,%eax
  800892:	0f b6 12             	movzbl (%edx),%edx
  800895:	29 d0                	sub    %edx,%eax
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a3:	89 c3                	mov    %eax,%ebx
  8008a5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strncmp+0x17>
		n--, p++, q++;
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b0:	39 d8                	cmp    %ebx,%eax
  8008b2:	74 18                	je     8008cc <strncmp+0x33>
  8008b4:	0f b6 08             	movzbl (%eax),%ecx
  8008b7:	84 c9                	test   %cl,%cl
  8008b9:	74 04                	je     8008bf <strncmp+0x26>
  8008bb:	3a 0a                	cmp    (%edx),%cl
  8008bd:	74 eb                	je     8008aa <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bf:	0f b6 00             	movzbl (%eax),%eax
  8008c2:	0f b6 12             	movzbl (%edx),%edx
  8008c5:	29 d0                	sub    %edx,%eax
}
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    
		return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb f4                	jmp    8008c7 <strncmp+0x2e>

008008d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dd:	eb 03                	jmp    8008e2 <strchr+0xf>
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	0f b6 10             	movzbl (%eax),%edx
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	74 06                	je     8008ef <strchr+0x1c>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	75 f2                	jne    8008df <strchr+0xc>
  8008ed:	eb 05                	jmp    8008f4 <strchr+0x21>
			return (char *) s;
	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800900:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 09                	je     800910 <strfind+0x1a>
  800907:	84 d2                	test   %dl,%dl
  800909:	74 05                	je     800910 <strfind+0x1a>
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	eb f0                	jmp    800900 <strfind+0xa>
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 2f                	je     800951 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800922:	89 f8                	mov    %edi,%eax
  800924:	09 c8                	or     %ecx,%eax
  800926:	a8 03                	test   $0x3,%al
  800928:	75 21                	jne    80094b <memset+0x39>
		c &= 0xFF;
  80092a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092e:	89 d0                	mov    %edx,%eax
  800930:	c1 e0 08             	shl    $0x8,%eax
  800933:	89 d3                	mov    %edx,%ebx
  800935:	c1 e3 18             	shl    $0x18,%ebx
  800938:	89 d6                	mov    %edx,%esi
  80093a:	c1 e6 10             	shl    $0x10,%esi
  80093d:	09 f3                	or     %esi,%ebx
  80093f:	09 da                	or     %ebx,%edx
  800941:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800943:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800946:	fc                   	cld    
  800947:	f3 ab                	rep stos %eax,%es:(%edi)
  800949:	eb 06                	jmp    800951 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	fc                   	cld    
  80094f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800951:	89 f8                	mov    %edi,%eax
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 32                	jae    80099c <memmove+0x44>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 c2                	cmp    %eax,%edx
  80096f:	76 2b                	jbe    80099c <memmove+0x44>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 d6                	mov    %edx,%esi
  800976:	09 fe                	or     %edi,%esi
  800978:	09 ce                	or     %ecx,%esi
  80097a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800980:	75 0e                	jne    800990 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 09                	jmp    800999 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800990:	83 ef 01             	sub    $0x1,%edi
  800993:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800996:	fd                   	std    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800999:	fc                   	cld    
  80099a:	eb 1a                	jmp    8009b6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	09 c2                	or     %eax,%edx
  8009a0:	09 ca                	or     %ecx,%edx
  8009a2:	f6 c2 03             	test   $0x3,%dl
  8009a5:	75 0a                	jne    8009b1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 05                	jmp    8009b6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c0:	ff 75 10             	push   0x10(%ebp)
  8009c3:	ff 75 0c             	push   0xc(%ebp)
  8009c6:	ff 75 08             	push   0x8(%ebp)
  8009c9:	e8 8a ff ff ff       	call   800958 <memmove>
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	89 c6                	mov    %eax,%esi
  8009dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e0:	eb 06                	jmp    8009e8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009e8:	39 f0                	cmp    %esi,%eax
  8009ea:	74 14                	je     800a00 <memcmp+0x30>
		if (*s1 != *s2)
  8009ec:	0f b6 08             	movzbl (%eax),%ecx
  8009ef:	0f b6 1a             	movzbl (%edx),%ebx
  8009f2:	38 d9                	cmp    %bl,%cl
  8009f4:	74 ec                	je     8009e2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009f6:	0f b6 c1             	movzbl %cl,%eax
  8009f9:	0f b6 db             	movzbl %bl,%ebx
  8009fc:	29 d8                	sub    %ebx,%eax
  8009fe:	eb 05                	jmp    800a05 <memcmp+0x35>
	}

	return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a17:	eb 03                	jmp    800a1c <memfind+0x13>
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	73 04                	jae    800a24 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a20:	38 08                	cmp    %cl,(%eax)
  800a22:	75 f5                	jne    800a19 <memfind+0x10>
			break;
	return (void *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	eb 03                	jmp    800a37 <strtol+0x11>
		s++;
  800a34:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a37:	0f b6 02             	movzbl (%edx),%eax
  800a3a:	3c 20                	cmp    $0x20,%al
  800a3c:	74 f6                	je     800a34 <strtol+0xe>
  800a3e:	3c 09                	cmp    $0x9,%al
  800a40:	74 f2                	je     800a34 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a42:	3c 2b                	cmp    $0x2b,%al
  800a44:	74 2a                	je     800a70 <strtol+0x4a>
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4b:	3c 2d                	cmp    $0x2d,%al
  800a4d:	74 2b                	je     800a7a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a55:	75 0f                	jne    800a66 <strtol+0x40>
  800a57:	80 3a 30             	cmpb   $0x30,(%edx)
  800a5a:	74 28                	je     800a84 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	85 db                	test   %ebx,%ebx
  800a5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a63:	0f 44 d8             	cmove  %eax,%ebx
  800a66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a6b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a6e:	eb 46                	jmp    800ab6 <strtol+0x90>
		s++;
  800a70:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
  800a78:	eb d5                	jmp    800a4f <strtol+0x29>
		s++, neg = 1;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a82:	eb cb                	jmp    800a4f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a88:	74 0e                	je     800a98 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	75 d8                	jne    800a66 <strtol+0x40>
		s++, base = 8;
  800a8e:	83 c2 01             	add    $0x1,%edx
  800a91:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a96:	eb ce                	jmp    800a66 <strtol+0x40>
		s += 2, base = 16;
  800a98:	83 c2 02             	add    $0x2,%edx
  800a9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa0:	eb c4                	jmp    800a66 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa2:	0f be c0             	movsbl %al,%eax
  800aa5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aab:	7d 3a                	jge    800ae7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aad:	83 c2 01             	add    $0x1,%edx
  800ab0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ab4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ab6:	0f b6 02             	movzbl (%edx),%eax
  800ab9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	76 df                	jbe    800aa2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ac3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800acd:	0f be c0             	movsbl %al,%eax
  800ad0:	83 e8 57             	sub    $0x57,%eax
  800ad3:	eb d3                	jmp    800aa8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ad5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 08                	ja     800ae7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800adf:	0f be c0             	movsbl %al,%eax
  800ae2:	83 e8 37             	sub    $0x37,%eax
  800ae5:	eb c1                	jmp    800aa8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aeb:	74 05                	je     800af2 <strtol+0xcc>
		*endptr = (char *) s;
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800af2:	89 c8                	mov    %ecx,%eax
  800af4:	f7 d8                	neg    %eax
  800af6:	85 ff                	test   %edi,%edi
  800af8:	0f 45 c8             	cmovne %eax,%ecx
}
  800afb:	89 c8                	mov    %ecx,%eax
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	89 c6                	mov    %eax,%esi
  800b19:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b26:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b30:	89 d1                	mov    %edx,%ecx
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	89 d7                	mov    %edx,%edi
  800b36:	89 d6                	mov    %edx,%esi
  800b38:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	83 ec 1c             	sub    $0x1c,%esp
  800b48:	e8 32 fc ff ff       	call   80077f <__x86.get_pc_thunk.ax>
  800b4d:	05 b3 14 00 00       	add    $0x14b3,%eax
  800b52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b62:	89 cb                	mov    %ecx,%ebx
  800b64:	89 cf                	mov    %ecx,%edi
  800b66:	89 ce                	mov    %ecx,%esi
  800b68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	7f 08                	jg     800b76 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	50                   	push   %eax
  800b7a:	6a 03                	push   $0x3
  800b7c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b7f:	8d 83 44 f0 ff ff    	lea    -0xfbc(%ebx),%eax
  800b85:	50                   	push   %eax
  800b86:	6a 23                	push   $0x23
  800b88:	8d 83 61 f0 ff ff    	lea    -0xf9f(%ebx),%eax
  800b8e:	50                   	push   %eax
  800b8f:	e8 1f 00 00 00       	call   800bb3 <_panic>

00800b94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9f:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba4:	89 d1                	mov    %edx,%ecx
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	89 d7                	mov    %edx,%edi
  800baa:	89 d6                	mov    %edx,%esi
  800bac:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 0c             	sub    $0xc,%esp
  800bbc:	e8 b0 f4 ff ff       	call   800071 <__x86.get_pc_thunk.bx>
  800bc1:	81 c3 3f 14 00 00    	add    $0x143f,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bc7:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bca:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bd0:	8b 38                	mov    (%eax),%edi
  800bd2:	e8 bd ff ff ff       	call   800b94 <sys_getenvid>
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	ff 75 0c             	push   0xc(%ebp)
  800bdd:	ff 75 08             	push   0x8(%ebp)
  800be0:	57                   	push   %edi
  800be1:	50                   	push   %eax
  800be2:	8d 83 70 f0 ff ff    	lea    -0xf90(%ebx),%eax
  800be8:	50                   	push   %eax
  800be9:	e8 a0 f5 ff ff       	call   80018e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800bee:	83 c4 18             	add    $0x18,%esp
  800bf1:	56                   	push   %esi
  800bf2:	ff 75 10             	push   0x10(%ebp)
  800bf5:	e8 32 f5 ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  800bfa:	8d 83 50 ee ff ff    	lea    -0x11b0(%ebx),%eax
  800c00:	89 04 24             	mov    %eax,(%esp)
  800c03:	e8 86 f5 ff ff       	call   80018e <cprintf>
  800c08:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c0b:	cc                   	int3   
  800c0c:	eb fd                	jmp    800c0b <_panic+0x58>
  800c0e:	66 90                	xchg   %ax,%ax

00800c10 <__udivdi3>:
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	75 19                	jne    800c48 <__udivdi3+0x38>
  800c2f:	39 f3                	cmp    %esi,%ebx
  800c31:	76 4d                	jbe    800c80 <__udivdi3+0x70>
  800c33:	31 ff                	xor    %edi,%edi
  800c35:	89 e8                	mov    %ebp,%eax
  800c37:	89 f2                	mov    %esi,%edx
  800c39:	f7 f3                	div    %ebx
  800c3b:	89 fa                	mov    %edi,%edx
  800c3d:	83 c4 1c             	add    $0x1c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	39 f0                	cmp    %esi,%eax
  800c4a:	76 14                	jbe    800c60 <__udivdi3+0x50>
  800c4c:	31 ff                	xor    %edi,%edi
  800c4e:	31 c0                	xor    %eax,%eax
  800c50:	89 fa                	mov    %edi,%edx
  800c52:	83 c4 1c             	add    $0x1c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
  800c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c60:	0f bd f8             	bsr    %eax,%edi
  800c63:	83 f7 1f             	xor    $0x1f,%edi
  800c66:	75 48                	jne    800cb0 <__udivdi3+0xa0>
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	72 06                	jb     800c72 <__udivdi3+0x62>
  800c6c:	31 c0                	xor    %eax,%eax
  800c6e:	39 eb                	cmp    %ebp,%ebx
  800c70:	77 de                	ja     800c50 <__udivdi3+0x40>
  800c72:	b8 01 00 00 00       	mov    $0x1,%eax
  800c77:	eb d7                	jmp    800c50 <__udivdi3+0x40>
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 d9                	mov    %ebx,%ecx
  800c82:	85 db                	test   %ebx,%ebx
  800c84:	75 0b                	jne    800c91 <__udivdi3+0x81>
  800c86:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	f7 f3                	div    %ebx
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	31 d2                	xor    %edx,%edx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	f7 f1                	div    %ecx
  800c97:	89 c6                	mov    %eax,%esi
  800c99:	89 e8                	mov    %ebp,%eax
  800c9b:	89 f7                	mov    %esi,%edi
  800c9d:	f7 f1                	div    %ecx
  800c9f:	89 fa                	mov    %edi,%edx
  800ca1:	83 c4 1c             	add    $0x1c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 f9                	mov    %edi,%ecx
  800cb2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cb7:	29 fa                	sub    %edi,%edx
  800cb9:	d3 e0                	shl    %cl,%eax
  800cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	89 d8                	mov    %ebx,%eax
  800cc3:	d3 e8                	shr    %cl,%eax
  800cc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cc9:	09 c1                	or     %eax,%ecx
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	d3 e3                	shl    %cl,%ebx
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cdf:	89 eb                	mov    %ebp,%ebx
  800ce1:	d3 e6                	shl    %cl,%esi
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	d3 eb                	shr    %cl,%ebx
  800ce7:	09 f3                	or     %esi,%ebx
  800ce9:	89 c6                	mov    %eax,%esi
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	89 d8                	mov    %ebx,%eax
  800cef:	f7 74 24 08          	divl   0x8(%esp)
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	f7 64 24 0c          	mull   0xc(%esp)
  800cfb:	39 d6                	cmp    %edx,%esi
  800cfd:	72 19                	jb     800d18 <__udivdi3+0x108>
  800cff:	89 f9                	mov    %edi,%ecx
  800d01:	d3 e5                	shl    %cl,%ebp
  800d03:	39 c5                	cmp    %eax,%ebp
  800d05:	73 04                	jae    800d0b <__udivdi3+0xfb>
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	74 0d                	je     800d18 <__udivdi3+0x108>
  800d0b:	89 d8                	mov    %ebx,%eax
  800d0d:	31 ff                	xor    %edi,%edi
  800d0f:	e9 3c ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d1b:	31 ff                	xor    %edi,%edi
  800d1d:	e9 2e ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d22:	66 90                	xchg   %ax,%ax
  800d24:	66 90                	xchg   %ax,%ax
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 1c             	sub    $0x1c,%esp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d4b:	89 f0                	mov    %esi,%eax
  800d4d:	89 da                	mov    %ebx,%edx
  800d4f:	85 ff                	test   %edi,%edi
  800d51:	75 15                	jne    800d68 <__umoddi3+0x38>
  800d53:	39 dd                	cmp    %ebx,%ebp
  800d55:	76 39                	jbe    800d90 <__umoddi3+0x60>
  800d57:	f7 f5                	div    %ebp
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 df                	cmp    %ebx,%edi
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cf             	bsr    %edi,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	75 40                	jne    800db8 <__umoddi3+0x88>
  800d78:	39 df                	cmp    %ebx,%edi
  800d7a:	72 04                	jb     800d80 <__umoddi3+0x50>
  800d7c:	39 f5                	cmp    %esi,%ebp
  800d7e:	77 dd                	ja     800d5d <__umoddi3+0x2d>
  800d80:	89 da                	mov    %ebx,%edx
  800d82:	89 f0                	mov    %esi,%eax
  800d84:	29 e8                	sub    %ebp,%eax
  800d86:	19 fa                	sbb    %edi,%edx
  800d88:	eb d3                	jmp    800d5d <__umoddi3+0x2d>
  800d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d90:	89 e9                	mov    %ebp,%ecx
  800d92:	85 ed                	test   %ebp,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x71>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f5                	div    %ebp
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f1                	div    %ecx
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	f7 f1                	div    %ecx
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	eb ac                	jmp    800d5d <__umoddi3+0x2d>
  800db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbc:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc1:	29 c2                	sub    %eax,%edx
  800dc3:	89 c1                	mov    %eax,%ecx
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	d3 e7                	shl    %cl,%edi
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dcf:	d3 e8                	shr    %cl,%eax
  800dd1:	89 c1                	mov    %eax,%ecx
  800dd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd7:	09 f9                	or     %edi,%ecx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 ef                	shr    %cl,%edi
  800de7:	89 c1                	mov    %eax,%ecx
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	d3 e3                	shl    %cl,%ebx
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 fa                	mov    %edi,%edx
  800df1:	d3 e8                	shr    %cl,%eax
  800df3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800df8:	09 d8                	or     %ebx,%eax
  800dfa:	f7 74 24 08          	divl   0x8(%esp)
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	f7 e5                	mul    %ebp
  800e04:	89 c7                	mov    %eax,%edi
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	39 d3                	cmp    %edx,%ebx
  800e0a:	72 06                	jb     800e12 <__umoddi3+0xe2>
  800e0c:	75 0e                	jne    800e1c <__umoddi3+0xec>
  800e0e:	39 c6                	cmp    %eax,%esi
  800e10:	73 0a                	jae    800e1c <__umoddi3+0xec>
  800e12:	29 e8                	sub    %ebp,%eax
  800e14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 c7                	mov    %eax,%edi
  800e1c:	89 f5                	mov    %esi,%ebp
  800e1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e22:	29 fd                	sub    %edi,%ebp
  800e24:	19 cb                	sbb    %ecx,%ebx
  800e26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	d3 e0                	shl    %cl,%eax
  800e2f:	89 f1                	mov    %esi,%ecx
  800e31:	d3 ed                	shr    %cl,%ebp
  800e33:	d3 eb                	shr    %cl,%ebx
  800e35:	09 e8                	or     %ebp,%eax
  800e37:	89 da                	mov    %ebx,%edx
  800e39:	83 c4 1c             	add    $0x1c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
