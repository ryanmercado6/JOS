
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 cb 00 00 00       	call   8000fc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 b9 00 00 00       	call   8000f8 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 d4 ee ff ff    	lea    -0x112c(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 1f 02 00 00       	call   800270 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	83 bc 83 40 00 00 00 	cmpl   $0x0,0x40(%ebx,%eax,4)
  800060:	00 
  800061:	75 69                	jne    8000cc <umain+0x99>
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	83 c0 01             	add    $0x1,%eax
  800066:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006b:	75 ec                	jne    800059 <umain+0x26>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006d:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800072:	89 84 83 40 00 00 00 	mov    %eax,0x40(%ebx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	83 c0 01             	add    $0x1,%eax
  80007c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800081:	75 ef                	jne    800072 <umain+0x3f>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  800088:	39 84 83 40 00 00 00 	cmp    %eax,0x40(%ebx,%eax,4)
  80008f:	75 51                	jne    8000e2 <umain+0xaf>
	for (i = 0; i < ARRAYSIZE; i++)
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800099:	75 ed                	jne    800088 <umain+0x55>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	8d 83 1c ef ff ff    	lea    -0x10e4(%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 c6 01 00 00       	call   800270 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000aa:	c7 83 40 10 40 00 00 	movl   $0x0,0x401040(%ebx)
  8000b1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000b4:	83 c4 0c             	add    $0xc,%esp
  8000b7:	8d 83 7b ef ff ff    	lea    -0x1085(%ebx),%eax
  8000bd:	50                   	push   %eax
  8000be:	6a 1a                	push   $0x1a
  8000c0:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 98 00 00 00       	call   800164 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000cc:	50                   	push   %eax
  8000cd:	8d 83 4f ef ff ff    	lea    -0x10b1(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	6a 11                	push   $0x11
  8000d6:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  8000dc:	50                   	push   %eax
  8000dd:	e8 82 00 00 00       	call   800164 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000e2:	50                   	push   %eax
  8000e3:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	6a 16                	push   $0x16
  8000ec:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  8000f2:	50                   	push   %eax
  8000f3:	e8 6c 00 00 00       	call   800164 <_panic>

008000f8 <__x86.get_pc_thunk.bx>:
  8000f8:	8b 1c 24             	mov    (%esp),%ebx
  8000fb:	c3                   	ret    

008000fc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	53                   	push   %ebx
  800100:	83 ec 04             	sub    $0x4,%esp
  800103:	e8 f0 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800108:	81 c3 f8 1e 00 00    	add    $0x1ef8,%ebx
  80010e:	8b 45 08             	mov    0x8(%ebp),%eax
  800111:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  800114:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  80011a:	89 8b 40 00 40 00    	mov    %ecx,0x400040(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 08                	jle    80012c <libmain+0x30>
		binaryname = argv[0];
  800124:	8b 0a                	mov    (%edx),%ecx
  800126:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	52                   	push   %edx
  800130:	50                   	push   %eax
  800131:	e8 fd fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800136:	e8 08 00 00 00       	call   800143 <exit>
}
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	83 ec 10             	sub    $0x10,%esp
  80014a:	e8 a9 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80014f:	81 c3 b1 1e 00 00    	add    $0x1eb1,%ebx
	sys_env_destroy(0);
  800155:	6a 00                	push   $0x0
  800157:	e8 c5 0a 00 00       	call   800c21 <sys_env_destroy>
}
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	e8 86 ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  800172:	81 c3 8e 1e 00 00    	add    $0x1e8e,%ebx
	va_list ap;

	va_start(ap, fmt);
  800178:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017b:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800181:	8b 38                	mov    (%eax),%edi
  800183:	e8 ee 0a 00 00       	call   800c76 <sys_getenvid>
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 0c             	push   0xc(%ebp)
  80018e:	ff 75 08             	push   0x8(%ebp)
  800191:	57                   	push   %edi
  800192:	50                   	push   %eax
  800193:	8d 83 9c ef ff ff    	lea    -0x1064(%ebx),%eax
  800199:	50                   	push   %eax
  80019a:	e8 d1 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019f:	83 c4 18             	add    $0x18,%esp
  8001a2:	56                   	push   %esi
  8001a3:	ff 75 10             	push   0x10(%ebp)
  8001a6:	e8 63 00 00 00       	call   80020e <vcprintf>
	cprintf("\n");
  8001ab:	8d 83 6a ef ff ff    	lea    -0x1096(%ebx),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 b7 00 00 00       	call   800270 <cprintf>
  8001b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bc:	cc                   	int3   
  8001bd:	eb fd                	jmp    8001bc <_panic+0x58>

008001bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	56                   	push   %esi
  8001c3:	53                   	push   %ebx
  8001c4:	e8 2f ff ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  8001c9:	81 c3 37 1e 00 00    	add    $0x1e37,%ebx
  8001cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001d2:	8b 16                	mov    (%esi),%edx
  8001d4:	8d 42 01             	lea    0x1(%edx),%eax
  8001d7:	89 06                	mov    %eax,(%esi)
  8001d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001dc:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e5:	74 0b                	je     8001f2 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e7:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	68 ff 00 00 00       	push   $0xff
  8001fa:	8d 46 08             	lea    0x8(%esi),%eax
  8001fd:	50                   	push   %eax
  8001fe:	e8 e1 09 00 00       	call   800be4 <sys_cputs>
		b->idx = 0;
  800203:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb d9                	jmp    8001e7 <putch+0x28>

0080020e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	53                   	push   %ebx
  800212:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800218:	e8 db fe ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  80021d:	81 c3 e3 1d 00 00    	add    $0x1de3,%ebx
	struct printbuf b;

	b.idx = 0;
  800223:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022a:	00 00 00 
	b.cnt = 0;
  80022d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800234:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800237:	ff 75 0c             	push   0xc(%ebp)
  80023a:	ff 75 08             	push   0x8(%ebp)
  80023d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800243:	50                   	push   %eax
  800244:	8d 83 bf e1 ff ff    	lea    -0x1e41(%ebx),%eax
  80024a:	50                   	push   %eax
  80024b:	e8 2c 01 00 00       	call   80037c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 7f 09 00 00       	call   800be4 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800276:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800279:	50                   	push   %eax
  80027a:	ff 75 08             	push   0x8(%ebp)
  80027d:	e8 8c ff ff ff       	call   80020e <vcprintf>
	va_end(ap);

	return cnt;
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 2c             	sub    $0x2c,%esp
  80028d:	e8 d3 05 00 00       	call   800865 <__x86.get_pc_thunk.cx>
  800292:	81 c1 6e 1d 00 00    	add    $0x1d6e,%ecx
  800298:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80029b:	89 c7                	mov    %eax,%edi
  80029d:	89 d6                	mov    %edx,%esi
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a5:	89 d1                	mov    %edx,%ecx
  8002a7:	89 c2                	mov    %eax,%edx
  8002a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ac:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002af:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002bf:	39 c2                	cmp    %eax,%edx
  8002c1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002c4:	72 41                	jb     800307 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c6:	83 ec 0c             	sub    $0xc,%esp
  8002c9:	ff 75 18             	push   0x18(%ebp)
  8002cc:	83 eb 01             	sub    $0x1,%ebx
  8002cf:	53                   	push   %ebx
  8002d0:	50                   	push   %eax
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	ff 75 e4             	push   -0x1c(%ebp)
  8002d7:	ff 75 e0             	push   -0x20(%ebp)
  8002da:	ff 75 d4             	push   -0x2c(%ebp)
  8002dd:	ff 75 d0             	push   -0x30(%ebp)
  8002e0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e3:	e8 b8 09 00 00       	call   800ca0 <__udivdi3>
  8002e8:	83 c4 18             	add    $0x18,%esp
  8002eb:	52                   	push   %edx
  8002ec:	50                   	push   %eax
  8002ed:	89 f2                	mov    %esi,%edx
  8002ef:	89 f8                	mov    %edi,%eax
  8002f1:	e8 8e ff ff ff       	call   800284 <printnum>
  8002f6:	83 c4 20             	add    $0x20,%esp
  8002f9:	eb 13                	jmp    80030e <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	ff 75 18             	push   0x18(%ebp)
  800302:	ff d7                	call   *%edi
  800304:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800307:	83 eb 01             	sub    $0x1,%ebx
  80030a:	85 db                	test   %ebx,%ebx
  80030c:	7f ed                	jg     8002fb <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	ff 75 e4             	push   -0x1c(%ebp)
  800318:	ff 75 e0             	push   -0x20(%ebp)
  80031b:	ff 75 d4             	push   -0x2c(%ebp)
  80031e:	ff 75 d0             	push   -0x30(%ebp)
  800321:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800324:	e8 97 0a 00 00       	call   800dc0 <__umoddi3>
  800329:	83 c4 14             	add    $0x14,%esp
  80032c:	0f be 84 03 bf ef ff 	movsbl -0x1041(%ebx,%eax,1),%eax
  800333:	ff 
  800334:	50                   	push   %eax
  800335:	ff d7                	call   *%edi
}
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800348:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	3b 50 04             	cmp    0x4(%eax),%edx
  800351:	73 0a                	jae    80035d <sprintputch+0x1b>
		*b->buf++ = ch;
  800353:	8d 4a 01             	lea    0x1(%edx),%ecx
  800356:	89 08                	mov    %ecx,(%eax)
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	88 02                	mov    %al,(%edx)
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <printfmt>:
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800365:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800368:	50                   	push   %eax
  800369:	ff 75 10             	push   0x10(%ebp)
  80036c:	ff 75 0c             	push   0xc(%ebp)
  80036f:	ff 75 08             	push   0x8(%ebp)
  800372:	e8 05 00 00 00       	call   80037c <vprintfmt>
}
  800377:	83 c4 10             	add    $0x10,%esp
  80037a:	c9                   	leave  
  80037b:	c3                   	ret    

0080037c <vprintfmt>:
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
  800382:	83 ec 3c             	sub    $0x3c,%esp
  800385:	e8 d7 04 00 00       	call   800861 <__x86.get_pc_thunk.ax>
  80038a:	05 76 1c 00 00       	add    $0x1c76,%eax
  80038f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800398:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039b:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003a1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003a4:	eb 0a                	jmp    8003b0 <vprintfmt+0x34>
			putch(ch, putdat);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	57                   	push   %edi
  8003aa:	50                   	push   %eax
  8003ab:	ff d6                	call   *%esi
  8003ad:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b0:	83 c3 01             	add    $0x1,%ebx
  8003b3:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003b7:	83 f8 25             	cmp    $0x25,%eax
  8003ba:	74 0c                	je     8003c8 <vprintfmt+0x4c>
			if (ch == '\0')
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	75 e6                	jne    8003a6 <vprintfmt+0x2a>
}
  8003c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c3:	5b                   	pop    %ebx
  8003c4:	5e                   	pop    %esi
  8003c5:	5f                   	pop    %edi
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    
		padc = ' ';
  8003c8:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003cc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003d3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e9:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8d 43 01             	lea    0x1(%ebx),%eax
  8003ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f2:	0f b6 13             	movzbl (%ebx),%edx
  8003f5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f8:	3c 55                	cmp    $0x55,%al
  8003fa:	0f 87 c5 03 00 00    	ja     8007c5 <.L20>
  800400:	0f b6 c0             	movzbl %al,%eax
  800403:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800406:	89 ce                	mov    %ecx,%esi
  800408:	03 b4 81 4c f0 ff ff 	add    -0xfb4(%ecx,%eax,4),%esi
  80040f:	ff e6                	jmp    *%esi

00800411 <.L66>:
  800411:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800414:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800418:	eb d2                	jmp    8003ec <vprintfmt+0x70>

0080041a <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80041d:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800421:	eb c9                	jmp    8003ec <vprintfmt+0x70>

00800423 <.L31>:
  800423:	0f b6 d2             	movzbl %dl,%edx
  800426:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80043b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80043e:	83 f9 09             	cmp    $0x9,%ecx
  800441:	77 58                	ja     80049b <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800443:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800446:	eb e9                	jmp    800431 <.L31+0xe>

00800448 <.L34>:
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 40 04             	lea    0x4(%eax),%eax
  800456:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80045c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800460:	79 8a                	jns    8003ec <vprintfmt+0x70>
				width = precision, precision = -1;
  800462:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800465:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800468:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80046f:	e9 78 ff ff ff       	jmp    8003ec <vprintfmt+0x70>

00800474 <.L33>:
  800474:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800477:	85 d2                	test   %edx,%edx
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	0f 49 c2             	cmovns %edx,%eax
  800481:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800487:	e9 60 ff ff ff       	jmp    8003ec <vprintfmt+0x70>

0080048c <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80048f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800496:	e9 51 ff ff ff       	jmp    8003ec <vprintfmt+0x70>
  80049b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80049e:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a1:	eb b9                	jmp    80045c <.L34+0x14>

008004a3 <.L27>:
			lflag++;
  8004a3:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004aa:	e9 3d ff ff ff       	jmp    8003ec <vprintfmt+0x70>

008004af <.L30>:
			putch(va_arg(ap, int), putdat);
  8004af:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 58 04             	lea    0x4(%eax),%ebx
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	57                   	push   %edi
  8004bc:	ff 30                	push   (%eax)
  8004be:	ff d6                	call   *%esi
			break;
  8004c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004c3:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004c6:	e9 90 02 00 00       	jmp    80075b <.L25+0x45>

008004cb <.L28>:
			err = va_arg(ap, int);
  8004cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 58 04             	lea    0x4(%eax),%ebx
  8004d4:	8b 10                	mov    (%eax),%edx
  8004d6:	89 d0                	mov    %edx,%eax
  8004d8:	f7 d8                	neg    %eax
  8004da:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004dd:	83 f8 06             	cmp    $0x6,%eax
  8004e0:	7f 27                	jg     800509 <.L28+0x3e>
  8004e2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e5:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004e8:	85 d2                	test   %edx,%edx
  8004ea:	74 1d                	je     800509 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004ec:	52                   	push   %edx
  8004ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f0:	8d 80 e0 ef ff ff    	lea    -0x1020(%eax),%eax
  8004f6:	50                   	push   %eax
  8004f7:	57                   	push   %edi
  8004f8:	56                   	push   %esi
  8004f9:	e8 61 fe ff ff       	call   80035f <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800501:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800504:	e9 52 02 00 00       	jmp    80075b <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050d:	8d 80 d7 ef ff ff    	lea    -0x1029(%eax),%eax
  800513:	50                   	push   %eax
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	e8 44 fe ff ff       	call   80035f <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051e:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800521:	e9 35 02 00 00       	jmp    80075b <.L25+0x45>

00800526 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	83 c0 04             	add    $0x4,%eax
  80052f:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800537:	85 d2                	test   %edx,%edx
  800539:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053c:	8d 80 d0 ef ff ff    	lea    -0x1030(%eax),%eax
  800542:	0f 45 c2             	cmovne %edx,%eax
  800545:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800548:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80054c:	7e 06                	jle    800554 <.L24+0x2e>
  80054e:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800552:	75 0d                	jne    800561 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800554:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800557:	89 c3                	mov    %eax,%ebx
  800559:	03 45 d0             	add    -0x30(%ebp),%eax
  80055c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80055f:	eb 58                	jmp    8005b9 <.L24+0x93>
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 d8             	push   -0x28(%ebp)
  800567:	ff 75 c8             	push   -0x38(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	e8 0f 03 00 00       	call   800881 <strnlen>
  800572:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800575:	29 c2                	sub    %eax,%edx
  800577:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80057f:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800583:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	eb 0f                	jmp    800597 <.L24+0x71>
					putch(padc, putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	57                   	push   %edi
  80058c:	ff 75 d0             	push   -0x30(%ebp)
  80058f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 eb 01             	sub    $0x1,%ebx
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	85 db                	test   %ebx,%ebx
  800599:	7f ed                	jg     800588 <.L24+0x62>
  80059b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	0f 49 c2             	cmovns %edx,%eax
  8005a8:	29 c2                	sub    %eax,%edx
  8005aa:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005ad:	eb a5                	jmp    800554 <.L24+0x2e>
					putch(ch, putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	57                   	push   %edi
  8005b3:	52                   	push   %edx
  8005b4:	ff d6                	call   *%esi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005bc:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	83 c3 01             	add    $0x1,%ebx
  8005c1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005c5:	0f be d0             	movsbl %al,%edx
  8005c8:	85 d2                	test   %edx,%edx
  8005ca:	74 4b                	je     800617 <.L24+0xf1>
  8005cc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005d0:	78 06                	js     8005d8 <.L24+0xb2>
  8005d2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d6:	78 1e                	js     8005f6 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005dc:	74 d1                	je     8005af <.L24+0x89>
  8005de:	0f be c0             	movsbl %al,%eax
  8005e1:	83 e8 20             	sub    $0x20,%eax
  8005e4:	83 f8 5e             	cmp    $0x5e,%eax
  8005e7:	76 c6                	jbe    8005af <.L24+0x89>
					putch('?', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	57                   	push   %edi
  8005ed:	6a 3f                	push   $0x3f
  8005ef:	ff d6                	call   *%esi
  8005f1:	83 c4 10             	add    $0x10,%esp
  8005f4:	eb c3                	jmp    8005b9 <.L24+0x93>
  8005f6:	89 cb                	mov    %ecx,%ebx
  8005f8:	eb 0e                	jmp    800608 <.L24+0xe2>
				putch(' ', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	57                   	push   %edi
  8005fe:	6a 20                	push   $0x20
  800600:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800602:	83 eb 01             	sub    $0x1,%ebx
  800605:	83 c4 10             	add    $0x10,%esp
  800608:	85 db                	test   %ebx,%ebx
  80060a:	7f ee                	jg     8005fa <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80060c:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
  800612:	e9 44 01 00 00       	jmp    80075b <.L25+0x45>
  800617:	89 cb                	mov    %ecx,%ebx
  800619:	eb ed                	jmp    800608 <.L24+0xe2>

0080061b <.L29>:
	if (lflag >= 2)
  80061b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80061e:	8b 75 08             	mov    0x8(%ebp),%esi
  800621:	83 f9 01             	cmp    $0x1,%ecx
  800624:	7f 1b                	jg     800641 <.L29+0x26>
	else if (lflag)
  800626:	85 c9                	test   %ecx,%ecx
  800628:	74 63                	je     80068d <.L29+0x72>
		return va_arg(*ap, long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	99                   	cltd   
  800633:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
  80063f:	eb 17                	jmp    800658 <.L29+0x3d>
		return va_arg(*ap, long long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 50 04             	mov    0x4(%eax),%edx
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 40 08             	lea    0x8(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800658:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80065b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80065e:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800663:	85 db                	test   %ebx,%ebx
  800665:	0f 89 d6 00 00 00    	jns    800741 <.L25+0x2b>
				putch('-', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	57                   	push   %edi
  80066f:	6a 2d                	push   $0x2d
  800671:	ff d6                	call   *%esi
				num = -(long long) num;
  800673:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800676:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800679:	f7 d9                	neg    %ecx
  80067b:	83 d3 00             	adc    $0x0,%ebx
  80067e:	f7 db                	neg    %ebx
  800680:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800683:	ba 0a 00 00 00       	mov    $0xa,%edx
  800688:	e9 b4 00 00 00       	jmp    800741 <.L25+0x2b>
		return va_arg(*ap, int);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 00                	mov    (%eax),%eax
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	99                   	cltd   
  800696:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a2:	eb b4                	jmp    800658 <.L29+0x3d>

008006a4 <.L23>:
	if (lflag >= 2)
  8006a4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006aa:	83 f9 01             	cmp    $0x1,%ecx
  8006ad:	7f 1b                	jg     8006ca <.L23+0x26>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	74 2c                	je     8006df <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 08                	mov    (%eax),%ecx
  8006b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c3:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006c8:	eb 77                	jmp    800741 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 08                	mov    (%eax),%ecx
  8006cf:	8b 58 04             	mov    0x4(%eax),%ebx
  8006d2:	8d 40 08             	lea    0x8(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d8:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006dd:	eb 62                	jmp    800741 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 08                	mov    (%eax),%ecx
  8006e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ef:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006f4:	eb 4b                	jmp    800741 <.L25+0x2b>

008006f6 <.L26>:
			putch('X', putdat);
  8006f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	57                   	push   %edi
  8006fd:	6a 58                	push   $0x58
  8006ff:	ff d6                	call   *%esi
			putch('X', putdat);
  800701:	83 c4 08             	add    $0x8,%esp
  800704:	57                   	push   %edi
  800705:	6a 58                	push   $0x58
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	83 c4 08             	add    $0x8,%esp
  80070c:	57                   	push   %edi
  80070d:	6a 58                	push   $0x58
  80070f:	ff d6                	call   *%esi
			break;
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb 45                	jmp    80075b <.L25+0x45>

00800716 <.L25>:
			putch('0', putdat);
  800716:	8b 75 08             	mov    0x8(%ebp),%esi
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	57                   	push   %edi
  80071d:	6a 30                	push   $0x30
  80071f:	ff d6                	call   *%esi
			putch('x', putdat);
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	57                   	push   %edi
  800725:	6a 78                	push   $0x78
  800727:	ff d6                	call   *%esi
			num = (unsigned long long)
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8b 08                	mov    (%eax),%ecx
  80072e:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800733:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073c:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800741:	83 ec 0c             	sub    $0xc,%esp
  800744:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	ff 75 d0             	push   -0x30(%ebp)
  80074c:	52                   	push   %edx
  80074d:	53                   	push   %ebx
  80074e:	51                   	push   %ecx
  80074f:	89 fa                	mov    %edi,%edx
  800751:	89 f0                	mov    %esi,%eax
  800753:	e8 2c fb ff ff       	call   800284 <printnum>
			break;
  800758:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80075b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80075e:	e9 4d fc ff ff       	jmp    8003b0 <vprintfmt+0x34>

00800763 <.L21>:
	if (lflag >= 2)
  800763:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	83 f9 01             	cmp    $0x1,%ecx
  80076c:	7f 1b                	jg     800789 <.L21+0x26>
	else if (lflag)
  80076e:	85 c9                	test   %ecx,%ecx
  800770:	74 2c                	je     80079e <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 08                	mov    (%eax),%ecx
  800777:	bb 00 00 00 00       	mov    $0x0,%ebx
  80077c:	8d 40 04             	lea    0x4(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800782:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800787:	eb b8                	jmp    800741 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 08                	mov    (%eax),%ecx
  80078e:	8b 58 04             	mov    0x4(%eax),%ebx
  800791:	8d 40 08             	lea    0x8(%eax),%eax
  800794:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800797:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  80079c:	eb a3                	jmp    800741 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 08                	mov    (%eax),%ecx
  8007a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a8:	8d 40 04             	lea    0x4(%eax),%eax
  8007ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ae:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007b3:	eb 8c                	jmp    800741 <.L25+0x2b>

008007b5 <.L35>:
			putch(ch, putdat);
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	57                   	push   %edi
  8007bc:	6a 25                	push   $0x25
  8007be:	ff d6                	call   *%esi
			break;
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	eb 96                	jmp    80075b <.L25+0x45>

008007c5 <.L20>:
			putch('%', putdat);
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	57                   	push   %edi
  8007cc:	6a 25                	push   $0x25
  8007ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d9:	74 05                	je     8007e0 <.L20+0x1b>
  8007db:	83 e8 01             	sub    $0x1,%eax
  8007de:	eb f5                	jmp    8007d5 <.L20+0x10>
  8007e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e3:	e9 73 ff ff ff       	jmp    80075b <.L25+0x45>

008007e8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	83 ec 14             	sub    $0x14,%esp
  8007ef:	e8 04 f9 ff ff       	call   8000f8 <__x86.get_pc_thunk.bx>
  8007f4:	81 c3 0c 18 00 00    	add    $0x180c,%ebx
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800800:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800803:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800807:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800811:	85 c0                	test   %eax,%eax
  800813:	74 2b                	je     800840 <vsnprintf+0x58>
  800815:	85 d2                	test   %edx,%edx
  800817:	7e 27                	jle    800840 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800819:	ff 75 14             	push   0x14(%ebp)
  80081c:	ff 75 10             	push   0x10(%ebp)
  80081f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800822:	50                   	push   %eax
  800823:	8d 83 42 e3 ff ff    	lea    -0x1cbe(%ebx),%eax
  800829:	50                   	push   %eax
  80082a:	e8 4d fb ff ff       	call   80037c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800832:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800838:	83 c4 10             	add    $0x10,%esp
}
  80083b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083e:	c9                   	leave  
  80083f:	c3                   	ret    
		return -E_INVAL;
  800840:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800845:	eb f4                	jmp    80083b <vsnprintf+0x53>

00800847 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800850:	50                   	push   %eax
  800851:	ff 75 10             	push   0x10(%ebp)
  800854:	ff 75 0c             	push   0xc(%ebp)
  800857:	ff 75 08             	push   0x8(%ebp)
  80085a:	e8 89 ff ff ff       	call   8007e8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <__x86.get_pc_thunk.ax>:
  800861:	8b 04 24             	mov    (%esp),%eax
  800864:	c3                   	ret    

00800865 <__x86.get_pc_thunk.cx>:
  800865:	8b 0c 24             	mov    (%esp),%ecx
  800868:	c3                   	ret    

00800869 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb 03                	jmp    800879 <strlen+0x10>
		n++;
  800876:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800879:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087d:	75 f7                	jne    800876 <strlen+0xd>
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
  80088f:	eb 03                	jmp    800894 <strnlen+0x13>
		n++;
  800891:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	39 d0                	cmp    %edx,%eax
  800896:	74 08                	je     8008a0 <strnlen+0x1f>
  800898:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80089c:	75 f3                	jne    800891 <strnlen+0x10>
  80089e:	89 c2                	mov    %eax,%edx
	return n;
}
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	53                   	push   %ebx
  8008a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008b7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	84 d2                	test   %dl,%dl
  8008bf:	75 f2                	jne    8008b3 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c1:	89 c8                	mov    %ecx,%eax
  8008c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	83 ec 10             	sub    $0x10,%esp
  8008cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d2:	53                   	push   %ebx
  8008d3:	e8 91 ff ff ff       	call   800869 <strlen>
  8008d8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008db:	ff 75 0c             	push   0xc(%ebp)
  8008de:	01 d8                	add    %ebx,%eax
  8008e0:	50                   	push   %eax
  8008e1:	e8 be ff ff ff       	call   8008a4 <strcpy>
	return dst;
}
  8008e6:	89 d8                	mov    %ebx,%eax
  8008e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	89 f3                	mov    %esi,%ebx
  8008fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	eb 0f                	jmp    800910 <strncpy+0x23>
		*dst++ = *src;
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	0f b6 0a             	movzbl (%edx),%ecx
  800907:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090a:	80 f9 01             	cmp    $0x1,%cl
  80090d:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800910:	39 d8                	cmp    %ebx,%eax
  800912:	75 ed                	jne    800901 <strncpy+0x14>
	}
	return ret;
}
  800914:	89 f0                	mov    %esi,%eax
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 75 08             	mov    0x8(%ebp),%esi
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800925:	8b 55 10             	mov    0x10(%ebp),%edx
  800928:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092a:	85 d2                	test   %edx,%edx
  80092c:	74 21                	je     80094f <strlcpy+0x35>
  80092e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800932:	89 f2                	mov    %esi,%edx
  800934:	eb 09                	jmp    80093f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800936:	83 c1 01             	add    $0x1,%ecx
  800939:	83 c2 01             	add    $0x1,%edx
  80093c:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80093f:	39 c2                	cmp    %eax,%edx
  800941:	74 09                	je     80094c <strlcpy+0x32>
  800943:	0f b6 19             	movzbl (%ecx),%ebx
  800946:	84 db                	test   %bl,%bl
  800948:	75 ec                	jne    800936 <strlcpy+0x1c>
  80094a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80094c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094f:	29 f0                	sub    %esi,%eax
}
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095e:	eb 06                	jmp    800966 <strcmp+0x11>
		p++, q++;
  800960:	83 c1 01             	add    $0x1,%ecx
  800963:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800966:	0f b6 01             	movzbl (%ecx),%eax
  800969:	84 c0                	test   %al,%al
  80096b:	74 04                	je     800971 <strcmp+0x1c>
  80096d:	3a 02                	cmp    (%edx),%al
  80096f:	74 ef                	je     800960 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800971:	0f b6 c0             	movzbl %al,%eax
  800974:	0f b6 12             	movzbl (%edx),%edx
  800977:	29 d0                	sub    %edx,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
  800985:	89 c3                	mov    %eax,%ebx
  800987:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098a:	eb 06                	jmp    800992 <strncmp+0x17>
		n--, p++, q++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800992:	39 d8                	cmp    %ebx,%eax
  800994:	74 18                	je     8009ae <strncmp+0x33>
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	84 c9                	test   %cl,%cl
  80099b:	74 04                	je     8009a1 <strncmp+0x26>
  80099d:	3a 0a                	cmp    (%edx),%cl
  80099f:	74 eb                	je     80098c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 00             	movzbl (%eax),%eax
  8009a4:	0f b6 12             	movzbl (%edx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
}
  8009a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    
		return 0;
  8009ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b3:	eb f4                	jmp    8009a9 <strncmp+0x2e>

008009b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bf:	eb 03                	jmp    8009c4 <strchr+0xf>
  8009c1:	83 c0 01             	add    $0x1,%eax
  8009c4:	0f b6 10             	movzbl (%eax),%edx
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	74 06                	je     8009d1 <strchr+0x1c>
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	75 f2                	jne    8009c1 <strchr+0xc>
  8009cf:	eb 05                	jmp    8009d6 <strchr+0x21>
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009e5:	38 ca                	cmp    %cl,%dl
  8009e7:	74 09                	je     8009f2 <strfind+0x1a>
  8009e9:	84 d2                	test   %dl,%dl
  8009eb:	74 05                	je     8009f2 <strfind+0x1a>
	for (; *s; s++)
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	eb f0                	jmp    8009e2 <strfind+0xa>
			break;
	return (char *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 2f                	je     800a33 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	89 f8                	mov    %edi,%eax
  800a06:	09 c8                	or     %ecx,%eax
  800a08:	a8 03                	test   $0x3,%al
  800a0a:	75 21                	jne    800a2d <memset+0x39>
		c &= 0xFF;
  800a0c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	c1 e0 08             	shl    $0x8,%eax
  800a15:	89 d3                	mov    %edx,%ebx
  800a17:	c1 e3 18             	shl    $0x18,%ebx
  800a1a:	89 d6                	mov    %edx,%esi
  800a1c:	c1 e6 10             	shl    $0x10,%esi
  800a1f:	09 f3                	or     %esi,%ebx
  800a21:	09 da                	or     %ebx,%edx
  800a23:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a25:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a28:	fc                   	cld    
  800a29:	f3 ab                	rep stos %eax,%es:(%edi)
  800a2b:	eb 06                	jmp    800a33 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a30:	fc                   	cld    
  800a31:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a33:	89 f8                	mov    %edi,%eax
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a48:	39 c6                	cmp    %eax,%esi
  800a4a:	73 32                	jae    800a7e <memmove+0x44>
  800a4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	76 2b                	jbe    800a7e <memmove+0x44>
		s += n;
		d += n;
  800a53:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	89 d6                	mov    %edx,%esi
  800a58:	09 fe                	or     %edi,%esi
  800a5a:	09 ce                	or     %ecx,%esi
  800a5c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a62:	75 0e                	jne    800a72 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a64:	83 ef 04             	sub    $0x4,%edi
  800a67:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a6d:	fd                   	std    
  800a6e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a70:	eb 09                	jmp    800a7b <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a72:	83 ef 01             	sub    $0x1,%edi
  800a75:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a78:	fd                   	std    
  800a79:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7b:	fc                   	cld    
  800a7c:	eb 1a                	jmp    800a98 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7e:	89 f2                	mov    %esi,%edx
  800a80:	09 c2                	or     %eax,%edx
  800a82:	09 ca                	or     %ecx,%edx
  800a84:	f6 c2 03             	test   $0x3,%dl
  800a87:	75 0a                	jne    800a93 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	ff 75 10             	push   0x10(%ebp)
  800aa5:	ff 75 0c             	push   0xc(%ebp)
  800aa8:	ff 75 08             	push   0x8(%ebp)
  800aab:	e8 8a ff ff ff       	call   800a3a <memmove>
}
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abd:	89 c6                	mov    %eax,%esi
  800abf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac2:	eb 06                	jmp    800aca <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800aca:	39 f0                	cmp    %esi,%eax
  800acc:	74 14                	je     800ae2 <memcmp+0x30>
		if (*s1 != *s2)
  800ace:	0f b6 08             	movzbl (%eax),%ecx
  800ad1:	0f b6 1a             	movzbl (%edx),%ebx
  800ad4:	38 d9                	cmp    %bl,%cl
  800ad6:	74 ec                	je     800ac4 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ad8:	0f b6 c1             	movzbl %cl,%eax
  800adb:	0f b6 db             	movzbl %bl,%ebx
  800ade:	29 d8                	sub    %ebx,%eax
  800ae0:	eb 05                	jmp    800ae7 <memcmp+0x35>
	}

	return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af4:	89 c2                	mov    %eax,%edx
  800af6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af9:	eb 03                	jmp    800afe <memfind+0x13>
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	39 d0                	cmp    %edx,%eax
  800b00:	73 04                	jae    800b06 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b02:	38 08                	cmp    %cl,(%eax)
  800b04:	75 f5                	jne    800afb <memfind+0x10>
			break;
	return (void *) s;
}
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b14:	eb 03                	jmp    800b19 <strtol+0x11>
		s++;
  800b16:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b19:	0f b6 02             	movzbl (%edx),%eax
  800b1c:	3c 20                	cmp    $0x20,%al
  800b1e:	74 f6                	je     800b16 <strtol+0xe>
  800b20:	3c 09                	cmp    $0x9,%al
  800b22:	74 f2                	je     800b16 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b24:	3c 2b                	cmp    $0x2b,%al
  800b26:	74 2a                	je     800b52 <strtol+0x4a>
	int neg = 0;
  800b28:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b2d:	3c 2d                	cmp    $0x2d,%al
  800b2f:	74 2b                	je     800b5c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b37:	75 0f                	jne    800b48 <strtol+0x40>
  800b39:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3c:	74 28                	je     800b66 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b3e:	85 db                	test   %ebx,%ebx
  800b40:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b45:	0f 44 d8             	cmove  %eax,%ebx
  800b48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b50:	eb 46                	jmp    800b98 <strtol+0x90>
		s++;
  800b52:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5a:	eb d5                	jmp    800b31 <strtol+0x29>
		s++, neg = 1;
  800b5c:	83 c2 01             	add    $0x1,%edx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b64:	eb cb                	jmp    800b31 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6a:	74 0e                	je     800b7a <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b6c:	85 db                	test   %ebx,%ebx
  800b6e:	75 d8                	jne    800b48 <strtol+0x40>
		s++, base = 8;
  800b70:	83 c2 01             	add    $0x1,%edx
  800b73:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b78:	eb ce                	jmp    800b48 <strtol+0x40>
		s += 2, base = 16;
  800b7a:	83 c2 02             	add    $0x2,%edx
  800b7d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b82:	eb c4                	jmp    800b48 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b84:	0f be c0             	movsbl %al,%eax
  800b87:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b8a:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b8d:	7d 3a                	jge    800bc9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b8f:	83 c2 01             	add    $0x1,%edx
  800b92:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b96:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 02             	movzbl (%edx),%eax
  800b9b:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b9e:	89 f3                	mov    %esi,%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	76 df                	jbe    800b84 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ba5:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 08                	ja     800bb7 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800baf:	0f be c0             	movsbl %al,%eax
  800bb2:	83 e8 57             	sub    $0x57,%eax
  800bb5:	eb d3                	jmp    800b8a <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bb7:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bba:	89 f3                	mov    %esi,%ebx
  800bbc:	80 fb 19             	cmp    $0x19,%bl
  800bbf:	77 08                	ja     800bc9 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bc1:	0f be c0             	movsbl %al,%eax
  800bc4:	83 e8 37             	sub    $0x37,%eax
  800bc7:	eb c1                	jmp    800b8a <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcd:	74 05                	je     800bd4 <strtol+0xcc>
		*endptr = (char *) s;
  800bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd2:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bd4:	89 c8                	mov    %ecx,%eax
  800bd6:	f7 d8                	neg    %eax
  800bd8:	85 ff                	test   %edi,%edi
  800bda:	0f 45 c8             	cmovne %eax,%ecx
}
  800bdd:	89 c8                	mov    %ecx,%eax
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	89 c3                	mov    %eax,%ebx
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	89 c6                	mov    %eax,%esi
  800bfb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c08:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c12:	89 d1                	mov    %edx,%ecx
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	89 d7                	mov    %edx,%edi
  800c18:	89 d6                	mov    %edx,%esi
  800c1a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 1c             	sub    $0x1c,%esp
  800c2a:	e8 32 fc ff ff       	call   800861 <__x86.get_pc_thunk.ax>
  800c2f:	05 d1 13 00 00       	add    $0x13d1,%eax
  800c34:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c44:	89 cb                	mov    %ecx,%ebx
  800c46:	89 cf                	mov    %ecx,%edi
  800c48:	89 ce                	mov    %ecx,%esi
  800c4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7f 08                	jg     800c58 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 03                	push   $0x3
  800c5e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c61:	8d 83 a4 f1 ff ff    	lea    -0xe5c(%ebx),%eax
  800c67:	50                   	push   %eax
  800c68:	6a 23                	push   $0x23
  800c6a:	8d 83 c1 f1 ff ff    	lea    -0xe3f(%ebx),%eax
  800c70:	50                   	push   %eax
  800c71:	e8 ee f4 ff ff       	call   800164 <_panic>

00800c76 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c81:	b8 02 00 00 00       	mov    $0x2,%eax
  800c86:	89 d1                	mov    %edx,%ecx
  800c88:	89 d3                	mov    %edx,%ebx
  800c8a:	89 d7                	mov    %edx,%edi
  800c8c:	89 d6                	mov    %edx,%esi
  800c8e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
  800c95:	66 90                	xchg   %ax,%ax
  800c97:	66 90                	xchg   %ax,%ax
  800c99:	66 90                	xchg   %ax,%ax
  800c9b:	66 90                	xchg   %ax,%ax
  800c9d:	66 90                	xchg   %ax,%ax
  800c9f:	90                   	nop

00800ca0 <__udivdi3>:
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 1c             	sub    $0x1c,%esp
  800cab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	75 19                	jne    800cd8 <__udivdi3+0x38>
  800cbf:	39 f3                	cmp    %esi,%ebx
  800cc1:	76 4d                	jbe    800d10 <__udivdi3+0x70>
  800cc3:	31 ff                	xor    %edi,%edi
  800cc5:	89 e8                	mov    %ebp,%eax
  800cc7:	89 f2                	mov    %esi,%edx
  800cc9:	f7 f3                	div    %ebx
  800ccb:	89 fa                	mov    %edi,%edx
  800ccd:	83 c4 1c             	add    $0x1c,%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
  800cd5:	8d 76 00             	lea    0x0(%esi),%esi
  800cd8:	39 f0                	cmp    %esi,%eax
  800cda:	76 14                	jbe    800cf0 <__udivdi3+0x50>
  800cdc:	31 ff                	xor    %edi,%edi
  800cde:	31 c0                	xor    %eax,%eax
  800ce0:	89 fa                	mov    %edi,%edx
  800ce2:	83 c4 1c             	add    $0x1c,%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    
  800cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cf0:	0f bd f8             	bsr    %eax,%edi
  800cf3:	83 f7 1f             	xor    $0x1f,%edi
  800cf6:	75 48                	jne    800d40 <__udivdi3+0xa0>
  800cf8:	39 f0                	cmp    %esi,%eax
  800cfa:	72 06                	jb     800d02 <__udivdi3+0x62>
  800cfc:	31 c0                	xor    %eax,%eax
  800cfe:	39 eb                	cmp    %ebp,%ebx
  800d00:	77 de                	ja     800ce0 <__udivdi3+0x40>
  800d02:	b8 01 00 00 00       	mov    $0x1,%eax
  800d07:	eb d7                	jmp    800ce0 <__udivdi3+0x40>
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	89 d9                	mov    %ebx,%ecx
  800d12:	85 db                	test   %ebx,%ebx
  800d14:	75 0b                	jne    800d21 <__udivdi3+0x81>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f3                	div    %ebx
  800d1f:	89 c1                	mov    %eax,%ecx
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	89 f0                	mov    %esi,%eax
  800d25:	f7 f1                	div    %ecx
  800d27:	89 c6                	mov    %eax,%esi
  800d29:	89 e8                	mov    %ebp,%eax
  800d2b:	89 f7                	mov    %esi,%edi
  800d2d:	f7 f1                	div    %ecx
  800d2f:	89 fa                	mov    %edi,%edx
  800d31:	83 c4 1c             	add    $0x1c,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 f9                	mov    %edi,%ecx
  800d42:	ba 20 00 00 00       	mov    $0x20,%edx
  800d47:	29 fa                	sub    %edi,%edx
  800d49:	d3 e0                	shl    %cl,%eax
  800d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4f:	89 d1                	mov    %edx,%ecx
  800d51:	89 d8                	mov    %ebx,%eax
  800d53:	d3 e8                	shr    %cl,%eax
  800d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d59:	09 c1                	or     %eax,%ecx
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	d3 e3                	shl    %cl,%ebx
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	89 f9                	mov    %edi,%ecx
  800d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d6f:	89 eb                	mov    %ebp,%ebx
  800d71:	d3 e6                	shl    %cl,%esi
  800d73:	89 d1                	mov    %edx,%ecx
  800d75:	d3 eb                	shr    %cl,%ebx
  800d77:	09 f3                	or     %esi,%ebx
  800d79:	89 c6                	mov    %eax,%esi
  800d7b:	89 f2                	mov    %esi,%edx
  800d7d:	89 d8                	mov    %ebx,%eax
  800d7f:	f7 74 24 08          	divl   0x8(%esp)
  800d83:	89 d6                	mov    %edx,%esi
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	f7 64 24 0c          	mull   0xc(%esp)
  800d8b:	39 d6                	cmp    %edx,%esi
  800d8d:	72 19                	jb     800da8 <__udivdi3+0x108>
  800d8f:	89 f9                	mov    %edi,%ecx
  800d91:	d3 e5                	shl    %cl,%ebp
  800d93:	39 c5                	cmp    %eax,%ebp
  800d95:	73 04                	jae    800d9b <__udivdi3+0xfb>
  800d97:	39 d6                	cmp    %edx,%esi
  800d99:	74 0d                	je     800da8 <__udivdi3+0x108>
  800d9b:	89 d8                	mov    %ebx,%eax
  800d9d:	31 ff                	xor    %edi,%edi
  800d9f:	e9 3c ff ff ff       	jmp    800ce0 <__udivdi3+0x40>
  800da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dab:	31 ff                	xor    %edi,%edi
  800dad:	e9 2e ff ff ff       	jmp    800ce0 <__udivdi3+0x40>
  800db2:	66 90                	xchg   %ax,%ax
  800db4:	66 90                	xchg   %ax,%ax
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__umoddi3>:
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 1c             	sub    $0x1c,%esp
  800dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dd3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800dd7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	89 da                	mov    %ebx,%edx
  800ddf:	85 ff                	test   %edi,%edi
  800de1:	75 15                	jne    800df8 <__umoddi3+0x38>
  800de3:	39 dd                	cmp    %ebx,%ebp
  800de5:	76 39                	jbe    800e20 <__umoddi3+0x60>
  800de7:	f7 f5                	div    %ebp
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 df                	cmp    %ebx,%edi
  800dfa:	77 f1                	ja     800ded <__umoddi3+0x2d>
  800dfc:	0f bd cf             	bsr    %edi,%ecx
  800dff:	83 f1 1f             	xor    $0x1f,%ecx
  800e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e06:	75 40                	jne    800e48 <__umoddi3+0x88>
  800e08:	39 df                	cmp    %ebx,%edi
  800e0a:	72 04                	jb     800e10 <__umoddi3+0x50>
  800e0c:	39 f5                	cmp    %esi,%ebp
  800e0e:	77 dd                	ja     800ded <__umoddi3+0x2d>
  800e10:	89 da                	mov    %ebx,%edx
  800e12:	89 f0                	mov    %esi,%eax
  800e14:	29 e8                	sub    %ebp,%eax
  800e16:	19 fa                	sbb    %edi,%edx
  800e18:	eb d3                	jmp    800ded <__umoddi3+0x2d>
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	89 e9                	mov    %ebp,%ecx
  800e22:	85 ed                	test   %ebp,%ebp
  800e24:	75 0b                	jne    800e31 <__umoddi3+0x71>
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f5                	div    %ebp
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	89 d8                	mov    %ebx,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f1                	div    %ecx
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	f7 f1                	div    %ecx
  800e3b:	89 d0                	mov    %edx,%eax
  800e3d:	31 d2                	xor    %edx,%edx
  800e3f:	eb ac                	jmp    800ded <__umoddi3+0x2d>
  800e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800e51:	29 c2                	sub    %eax,%edx
  800e53:	89 c1                	mov    %eax,%ecx
  800e55:	89 e8                	mov    %ebp,%eax
  800e57:	d3 e7                	shl    %cl,%edi
  800e59:	89 d1                	mov    %edx,%ecx
  800e5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e5f:	d3 e8                	shr    %cl,%eax
  800e61:	89 c1                	mov    %eax,%ecx
  800e63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e67:	09 f9                	or     %edi,%ecx
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	d3 e5                	shl    %cl,%ebp
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	d3 ef                	shr    %cl,%edi
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	d3 e3                	shl    %cl,%ebx
  800e7d:	89 d1                	mov    %edx,%ecx
  800e7f:	89 fa                	mov    %edi,%edx
  800e81:	d3 e8                	shr    %cl,%eax
  800e83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e88:	09 d8                	or     %ebx,%eax
  800e8a:	f7 74 24 08          	divl   0x8(%esp)
  800e8e:	89 d3                	mov    %edx,%ebx
  800e90:	d3 e6                	shl    %cl,%esi
  800e92:	f7 e5                	mul    %ebp
  800e94:	89 c7                	mov    %eax,%edi
  800e96:	89 d1                	mov    %edx,%ecx
  800e98:	39 d3                	cmp    %edx,%ebx
  800e9a:	72 06                	jb     800ea2 <__umoddi3+0xe2>
  800e9c:	75 0e                	jne    800eac <__umoddi3+0xec>
  800e9e:	39 c6                	cmp    %eax,%esi
  800ea0:	73 0a                	jae    800eac <__umoddi3+0xec>
  800ea2:	29 e8                	sub    %ebp,%eax
  800ea4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ea8:	89 d1                	mov    %edx,%ecx
  800eaa:	89 c7                	mov    %eax,%edi
  800eac:	89 f5                	mov    %esi,%ebp
  800eae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb2:	29 fd                	sub    %edi,%ebp
  800eb4:	19 cb                	sbb    %ecx,%ebx
  800eb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ebb:	89 d8                	mov    %ebx,%eax
  800ebd:	d3 e0                	shl    %cl,%eax
  800ebf:	89 f1                	mov    %esi,%ecx
  800ec1:	d3 ed                	shr    %cl,%ebp
  800ec3:	d3 eb                	shr    %cl,%ebx
  800ec5:	09 e8                	or     %ebp,%eax
  800ec7:	89 da                	mov    %ebx,%edx
  800ec9:	83 c4 1c             	add    $0x1c,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    
