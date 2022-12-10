
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	53                   	push   %ebx
  800039:	83 ec 04             	sub    $0x4,%esp
  80003c:	e8 3b 00 00 00       	call   80007c <__x86.get_pc_thunk.bx>
  800041:	81 c3 bf 1f 00 00    	add    $0x1fbf,%ebx
  800047:	8b 45 08             	mov    0x8(%ebp),%eax
  80004a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  80004d:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  800053:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800059:	85 c0                	test   %eax,%eax
  80005b:	7e 08                	jle    800065 <libmain+0x30>
		binaryname = argv[0];
  80005d:	8b 0a                	mov    (%edx),%ecx
  80005f:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800065:	83 ec 08             	sub    $0x8,%esp
  800068:	52                   	push   %edx
  800069:	50                   	push   %eax
  80006a:	e8 c4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006f:	e8 0c 00 00 00       	call   800080 <exit>
}
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007a:	c9                   	leave  
  80007b:	c3                   	ret    

0080007c <__x86.get_pc_thunk.bx>:
  80007c:	8b 1c 24             	mov    (%esp),%ebx
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	53                   	push   %ebx
  800084:	83 ec 10             	sub    $0x10,%esp
  800087:	e8 f0 ff ff ff       	call   80007c <__x86.get_pc_thunk.bx>
  80008c:	81 c3 74 1f 00 00    	add    $0x1f74,%ebx
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 45 00 00 00       	call   8000de <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	89 c3                	mov    %eax,%ebx
  8000b4:	89 c7                	mov    %eax,%edi
  8000b6:	89 c6                	mov    %eax,%esi
  8000b8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cf:	89 d1                	mov    %edx,%ecx
  8000d1:	89 d3                	mov    %edx,%ebx
  8000d3:	89 d7                	mov    %edx,%edi
  8000d5:	89 d6                	mov    %edx,%esi
  8000d7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 1c             	sub    $0x1c,%esp
  8000e7:	e8 66 00 00 00       	call   800152 <__x86.get_pc_thunk.ax>
  8000ec:	05 14 1f 00 00       	add    $0x1f14,%eax
  8000f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7f 08                	jg     800115 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80011e:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	6a 23                	push   $0x23
  800127:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 23 00 00 00       	call   800156 <_panic>

00800133 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 02 00 00 00       	mov    $0x2,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <__x86.get_pc_thunk.ax>:
  800152:	8b 04 24             	mov    (%esp),%eax
  800155:	c3                   	ret    

00800156 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	e8 18 ff ff ff       	call   80007c <__x86.get_pc_thunk.bx>
  800164:	81 c3 9c 1e 00 00    	add    $0x1e9c,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016a:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016d:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800173:	8b 38                	mov    (%eax),%edi
  800175:	e8 b9 ff ff ff       	call   800133 <sys_getenvid>
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	ff 75 0c             	push   0xc(%ebp)
  800180:	ff 75 08             	push   0x8(%ebp)
  800183:	57                   	push   %edi
  800184:	50                   	push   %eax
  800185:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  80018b:	50                   	push   %eax
  80018c:	e8 d1 00 00 00       	call   800262 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800191:	83 c4 18             	add    $0x18,%esp
  800194:	56                   	push   %esi
  800195:	ff 75 10             	push   0x10(%ebp)
  800198:	e8 63 00 00 00       	call   800200 <vcprintf>
	cprintf("\n");
  80019d:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 b7 00 00 00       	call   800262 <cprintf>
  8001ab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ae:	cc                   	int3   
  8001af:	eb fd                	jmp    8001ae <_panic+0x58>

008001b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	e8 c1 fe ff ff       	call   80007c <__x86.get_pc_thunk.bx>
  8001bb:	81 c3 45 1e 00 00    	add    $0x1e45,%ebx
  8001c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c4:	8b 16                	mov    (%esi),%edx
  8001c6:	8d 42 01             	lea    0x1(%edx),%eax
  8001c9:	89 06                	mov    %eax,(%esi)
  8001cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ce:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d7:	74 0b                	je     8001e4 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d9:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	68 ff 00 00 00       	push   $0xff
  8001ec:	8d 46 08             	lea    0x8(%esi),%eax
  8001ef:	50                   	push   %eax
  8001f0:	e8 ac fe ff ff       	call   8000a1 <sys_cputs>
		b->idx = 0;
  8001f5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	eb d9                	jmp    8001d9 <putch+0x28>

00800200 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	53                   	push   %ebx
  800204:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020a:	e8 6d fe ff ff       	call   80007c <__x86.get_pc_thunk.bx>
  80020f:	81 c3 f1 1d 00 00    	add    $0x1df1,%ebx
	struct printbuf b;

	b.idx = 0;
  800215:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021c:	00 00 00 
	b.cnt = 0;
  80021f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800226:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800229:	ff 75 0c             	push   0xc(%ebp)
  80022c:	ff 75 08             	push   0x8(%ebp)
  80022f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	8d 83 b1 e1 ff ff    	lea    -0x1e4f(%ebx),%eax
  80023c:	50                   	push   %eax
  80023d:	e8 2c 01 00 00       	call   80036e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800242:	83 c4 08             	add    $0x8,%esp
  800245:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80024b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800251:	50                   	push   %eax
  800252:	e8 4a fe ff ff       	call   8000a1 <sys_cputs>

	return b.cnt;
}
  800257:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800268:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026b:	50                   	push   %eax
  80026c:	ff 75 08             	push   0x8(%ebp)
  80026f:	e8 8c ff ff ff       	call   800200 <vcprintf>
	va_end(ap);

	return cnt;
}
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	57                   	push   %edi
  80027a:	56                   	push   %esi
  80027b:	53                   	push   %ebx
  80027c:	83 ec 2c             	sub    $0x2c,%esp
  80027f:	e8 cf 05 00 00       	call   800853 <__x86.get_pc_thunk.cx>
  800284:	81 c1 7c 1d 00 00    	add    $0x1d7c,%ecx
  80028a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028d:	89 c7                	mov    %eax,%edi
  80028f:	89 d6                	mov    %edx,%esi
  800291:	8b 45 08             	mov    0x8(%ebp),%eax
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 d1                	mov    %edx,%ecx
  800299:	89 c2                	mov    %eax,%edx
  80029b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002aa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b1:	39 c2                	cmp    %eax,%edx
  8002b3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b6:	72 41                	jb     8002f9 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	ff 75 18             	push   0x18(%ebp)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	53                   	push   %ebx
  8002c2:	50                   	push   %eax
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	ff 75 e4             	push   -0x1c(%ebp)
  8002c9:	ff 75 e0             	push   -0x20(%ebp)
  8002cc:	ff 75 d4             	push   -0x2c(%ebp)
  8002cf:	ff 75 d0             	push   -0x30(%ebp)
  8002d2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d5:	e8 06 09 00 00       	call   800be0 <__udivdi3>
  8002da:	83 c4 18             	add    $0x18,%esp
  8002dd:	52                   	push   %edx
  8002de:	50                   	push   %eax
  8002df:	89 f2                	mov    %esi,%edx
  8002e1:	89 f8                	mov    %edi,%eax
  8002e3:	e8 8e ff ff ff       	call   800276 <printnum>
  8002e8:	83 c4 20             	add    $0x20,%esp
  8002eb:	eb 13                	jmp    800300 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	56                   	push   %esi
  8002f1:	ff 75 18             	push   0x18(%ebp)
  8002f4:	ff d7                	call   *%edi
  8002f6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f ed                	jg     8002ed <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	push   -0x1c(%ebp)
  80030a:	ff 75 e0             	push   -0x20(%ebp)
  80030d:	ff 75 d4             	push   -0x2c(%ebp)
  800310:	ff 75 d0             	push   -0x30(%ebp)
  800313:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800316:	e8 e5 09 00 00       	call   800d00 <__umoddi3>
  80031b:	83 c4 14             	add    $0x14,%esp
  80031e:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  800325:	ff 
  800326:	50                   	push   %eax
  800327:	ff d7                	call   *%edi
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033e:	8b 10                	mov    (%eax),%edx
  800340:	3b 50 04             	cmp    0x4(%eax),%edx
  800343:	73 0a                	jae    80034f <sprintputch+0x1b>
		*b->buf++ = ch;
  800345:	8d 4a 01             	lea    0x1(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	88 02                	mov    %al,(%edx)
}
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <printfmt>:
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800357:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035a:	50                   	push   %eax
  80035b:	ff 75 10             	push   0x10(%ebp)
  80035e:	ff 75 0c             	push   0xc(%ebp)
  800361:	ff 75 08             	push   0x8(%ebp)
  800364:	e8 05 00 00 00       	call   80036e <vprintfmt>
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <vprintfmt>:
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
  800374:	83 ec 3c             	sub    $0x3c,%esp
  800377:	e8 d6 fd ff ff       	call   800152 <__x86.get_pc_thunk.ax>
  80037c:	05 84 1c 00 00       	add    $0x1c84,%eax
  800381:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800384:	8b 75 08             	mov    0x8(%ebp),%esi
  800387:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038a:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038d:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800393:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800396:	eb 0a                	jmp    8003a2 <vprintfmt+0x34>
			putch(ch, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	57                   	push   %edi
  80039c:	50                   	push   %eax
  80039d:	ff d6                	call   *%esi
  80039f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a2:	83 c3 01             	add    $0x1,%ebx
  8003a5:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003a9:	83 f8 25             	cmp    $0x25,%eax
  8003ac:	74 0c                	je     8003ba <vprintfmt+0x4c>
			if (ch == '\0')
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	75 e6                	jne    800398 <vprintfmt+0x2a>
}
  8003b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b5:	5b                   	pop    %ebx
  8003b6:	5e                   	pop    %esi
  8003b7:	5f                   	pop    %edi
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    
		padc = ' ';
  8003ba:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003db:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e4:	0f b6 13             	movzbl (%ebx),%edx
  8003e7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ea:	3c 55                	cmp    $0x55,%al
  8003ec:	0f 87 c5 03 00 00    	ja     8007b7 <.L20>
  8003f2:	0f b6 c0             	movzbl %al,%eax
  8003f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f8:	89 ce                	mov    %ecx,%esi
  8003fa:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  800401:	ff e6                	jmp    *%esi

00800403 <.L66>:
  800403:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800406:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80040a:	eb d2                	jmp    8003de <vprintfmt+0x70>

0080040c <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040f:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800413:	eb c9                	jmp    8003de <vprintfmt+0x70>

00800415 <.L31>:
  800415:	0f b6 d2             	movzbl %dl,%edx
  800418:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80041b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800423:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800426:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042a:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80042d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800430:	83 f9 09             	cmp    $0x9,%ecx
  800433:	77 58                	ja     80048d <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800435:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800438:	eb e9                	jmp    800423 <.L31+0xe>

0080043a <.L34>:
			precision = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 40 04             	lea    0x4(%eax),%eax
  800448:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80044e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800452:	79 8a                	jns    8003de <vprintfmt+0x70>
				width = precision, precision = -1;
  800454:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800457:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800461:	e9 78 ff ff ff       	jmp    8003de <vprintfmt+0x70>

00800466 <.L33>:
  800466:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800469:	85 d2                	test   %edx,%edx
  80046b:	b8 00 00 00 00       	mov    $0x0,%eax
  800470:	0f 49 c2             	cmovns %edx,%eax
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800479:	e9 60 ff ff ff       	jmp    8003de <vprintfmt+0x70>

0080047e <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800481:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800488:	e9 51 ff ff ff       	jmp    8003de <vprintfmt+0x70>
  80048d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800490:	89 75 08             	mov    %esi,0x8(%ebp)
  800493:	eb b9                	jmp    80044e <.L34+0x14>

00800495 <.L27>:
			lflag++;
  800495:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800499:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049c:	e9 3d ff ff ff       	jmp    8003de <vprintfmt+0x70>

008004a1 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 58 04             	lea    0x4(%eax),%ebx
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	57                   	push   %edi
  8004ae:	ff 30                	push   (%eax)
  8004b0:	ff d6                	call   *%esi
			break;
  8004b2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b5:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004b8:	e9 90 02 00 00       	jmp    80074d <.L25+0x45>

008004bd <.L28>:
			err = va_arg(ap, int);
  8004bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c6:	8b 10                	mov    (%eax),%edx
  8004c8:	89 d0                	mov    %edx,%eax
  8004ca:	f7 d8                	neg    %eax
  8004cc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cf:	83 f8 06             	cmp    $0x6,%eax
  8004d2:	7f 27                	jg     8004fb <.L28+0x3e>
  8004d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d7:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	74 1d                	je     8004fb <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004de:	52                   	push   %edx
  8004df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e2:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004e8:	50                   	push   %eax
  8004e9:	57                   	push   %edi
  8004ea:	56                   	push   %esi
  8004eb:	e8 61 fe ff ff       	call   800351 <printfmt>
  8004f0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f3:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f6:	e9 52 02 00 00       	jmp    80074d <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fb:	50                   	push   %eax
  8004fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ff:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  800505:	50                   	push   %eax
  800506:	57                   	push   %edi
  800507:	56                   	push   %esi
  800508:	e8 44 fe ff ff       	call   800351 <printfmt>
  80050d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800510:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800513:	e9 35 02 00 00       	jmp    80074d <.L25+0x45>

00800518 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 75 08             	mov    0x8(%ebp),%esi
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	83 c0 04             	add    $0x4,%eax
  800521:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800529:	85 d2                	test   %edx,%edx
  80052b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052e:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  800534:	0f 45 c2             	cmovne %edx,%eax
  800537:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80053a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80053e:	7e 06                	jle    800546 <.L24+0x2e>
  800540:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800544:	75 0d                	jne    800553 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800546:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800549:	89 c3                	mov    %eax,%ebx
  80054b:	03 45 d0             	add    -0x30(%ebp),%eax
  80054e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800551:	eb 58                	jmp    8005ab <.L24+0x93>
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	ff 75 d8             	push   -0x28(%ebp)
  800559:	ff 75 c8             	push   -0x38(%ebp)
  80055c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055f:	e8 0b 03 00 00       	call   80086f <strnlen>
  800564:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800567:	29 c2                	sub    %eax,%edx
  800569:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800571:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800575:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	eb 0f                	jmp    800589 <.L24+0x71>
					putch(padc, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	57                   	push   %edi
  80057e:	ff 75 d0             	push   -0x30(%ebp)
  800581:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 eb 01             	sub    $0x1,%ebx
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	85 db                	test   %ebx,%ebx
  80058b:	7f ed                	jg     80057a <.L24+0x62>
  80058d:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800590:	85 d2                	test   %edx,%edx
  800592:	b8 00 00 00 00       	mov    $0x0,%eax
  800597:	0f 49 c2             	cmovns %edx,%eax
  80059a:	29 c2                	sub    %eax,%edx
  80059c:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80059f:	eb a5                	jmp    800546 <.L24+0x2e>
					putch(ch, putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	57                   	push   %edi
  8005a5:	52                   	push   %edx
  8005a6:	ff d6                	call   *%esi
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005ae:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b0:	83 c3 01             	add    $0x1,%ebx
  8005b3:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005b7:	0f be d0             	movsbl %al,%edx
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	74 4b                	je     800609 <.L24+0xf1>
  8005be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c2:	78 06                	js     8005ca <.L24+0xb2>
  8005c4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005c8:	78 1e                	js     8005e8 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ce:	74 d1                	je     8005a1 <.L24+0x89>
  8005d0:	0f be c0             	movsbl %al,%eax
  8005d3:	83 e8 20             	sub    $0x20,%eax
  8005d6:	83 f8 5e             	cmp    $0x5e,%eax
  8005d9:	76 c6                	jbe    8005a1 <.L24+0x89>
					putch('?', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	57                   	push   %edi
  8005df:	6a 3f                	push   $0x3f
  8005e1:	ff d6                	call   *%esi
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	eb c3                	jmp    8005ab <.L24+0x93>
  8005e8:	89 cb                	mov    %ecx,%ebx
  8005ea:	eb 0e                	jmp    8005fa <.L24+0xe2>
				putch(' ', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	57                   	push   %edi
  8005f0:	6a 20                	push   $0x20
  8005f2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f4:	83 eb 01             	sub    $0x1,%ebx
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	85 db                	test   %ebx,%ebx
  8005fc:	7f ee                	jg     8005ec <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fe:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
  800604:	e9 44 01 00 00       	jmp    80074d <.L25+0x45>
  800609:	89 cb                	mov    %ecx,%ebx
  80060b:	eb ed                	jmp    8005fa <.L24+0xe2>

0080060d <.L29>:
	if (lflag >= 2)
  80060d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800610:	8b 75 08             	mov    0x8(%ebp),%esi
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7f 1b                	jg     800633 <.L29+0x26>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 63                	je     80067f <.L29+0x72>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 00                	mov    (%eax),%eax
  800621:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800624:	99                   	cltd   
  800625:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
  800631:	eb 17                	jmp    80064a <.L29+0x3d>
		return va_arg(*ap, long long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 40 08             	lea    0x8(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80064d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800650:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800655:	85 db                	test   %ebx,%ebx
  800657:	0f 89 d6 00 00 00    	jns    800733 <.L25+0x2b>
				putch('-', putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	57                   	push   %edi
  800661:	6a 2d                	push   $0x2d
  800663:	ff d6                	call   *%esi
				num = -(long long) num;
  800665:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800668:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066b:	f7 d9                	neg    %ecx
  80066d:	83 d3 00             	adc    $0x0,%ebx
  800670:	f7 db                	neg    %ebx
  800672:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800675:	ba 0a 00 00 00       	mov    $0xa,%edx
  80067a:	e9 b4 00 00 00       	jmp    800733 <.L25+0x2b>
		return va_arg(*ap, int);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 00                	mov    (%eax),%eax
  800684:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800687:	99                   	cltd   
  800688:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
  800694:	eb b4                	jmp    80064a <.L29+0x3d>

00800696 <.L23>:
	if (lflag >= 2)
  800696:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800699:	8b 75 08             	mov    0x8(%ebp),%esi
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7f 1b                	jg     8006bc <.L23+0x26>
	else if (lflag)
  8006a1:	85 c9                	test   %ecx,%ecx
  8006a3:	74 2c                	je     8006d1 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 08                	mov    (%eax),%ecx
  8006aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b5:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006ba:	eb 77                	jmp    800733 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 08                	mov    (%eax),%ecx
  8006c1:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c4:	8d 40 08             	lea    0x8(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ca:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006cf:	eb 62                	jmp    800733 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 08                	mov    (%eax),%ecx
  8006d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e1:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006e6:	eb 4b                	jmp    800733 <.L25+0x2b>

008006e8 <.L26>:
			putch('X', putdat);
  8006e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	57                   	push   %edi
  8006ef:	6a 58                	push   $0x58
  8006f1:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f3:	83 c4 08             	add    $0x8,%esp
  8006f6:	57                   	push   %edi
  8006f7:	6a 58                	push   $0x58
  8006f9:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fb:	83 c4 08             	add    $0x8,%esp
  8006fe:	57                   	push   %edi
  8006ff:	6a 58                	push   $0x58
  800701:	ff d6                	call   *%esi
			break;
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	eb 45                	jmp    80074d <.L25+0x45>

00800708 <.L25>:
			putch('0', putdat);
  800708:	8b 75 08             	mov    0x8(%ebp),%esi
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	57                   	push   %edi
  80070f:	6a 30                	push   $0x30
  800711:	ff d6                	call   *%esi
			putch('x', putdat);
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	57                   	push   %edi
  800717:	6a 78                	push   $0x78
  800719:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8b 08                	mov    (%eax),%ecx
  800720:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800725:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800728:	8d 40 04             	lea    0x4(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072e:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800733:	83 ec 0c             	sub    $0xc,%esp
  800736:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80073a:	50                   	push   %eax
  80073b:	ff 75 d0             	push   -0x30(%ebp)
  80073e:	52                   	push   %edx
  80073f:	53                   	push   %ebx
  800740:	51                   	push   %ecx
  800741:	89 fa                	mov    %edi,%edx
  800743:	89 f0                	mov    %esi,%eax
  800745:	e8 2c fb ff ff       	call   800276 <printnum>
			break;
  80074a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80074d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800750:	e9 4d fc ff ff       	jmp    8003a2 <vprintfmt+0x34>

00800755 <.L21>:
	if (lflag >= 2)
  800755:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	83 f9 01             	cmp    $0x1,%ecx
  80075e:	7f 1b                	jg     80077b <.L21+0x26>
	else if (lflag)
  800760:	85 c9                	test   %ecx,%ecx
  800762:	74 2c                	je     800790 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 08                	mov    (%eax),%ecx
  800769:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076e:	8d 40 04             	lea    0x4(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800774:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800779:	eb b8                	jmp    800733 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8b 08                	mov    (%eax),%ecx
  800780:	8b 58 04             	mov    0x4(%eax),%ebx
  800783:	8d 40 08             	lea    0x8(%eax),%eax
  800786:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800789:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  80078e:	eb a3                	jmp    800733 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800790:	8b 45 14             	mov    0x14(%ebp),%eax
  800793:	8b 08                	mov    (%eax),%ecx
  800795:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079a:	8d 40 04             	lea    0x4(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007a5:	eb 8c                	jmp    800733 <.L25+0x2b>

008007a7 <.L35>:
			putch(ch, putdat);
  8007a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	57                   	push   %edi
  8007ae:	6a 25                	push   $0x25
  8007b0:	ff d6                	call   *%esi
			break;
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 96                	jmp    80074d <.L25+0x45>

008007b7 <.L20>:
			putch('%', putdat);
  8007b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	57                   	push   %edi
  8007be:	6a 25                	push   $0x25
  8007c0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	89 d8                	mov    %ebx,%eax
  8007c7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007cb:	74 05                	je     8007d2 <.L20+0x1b>
  8007cd:	83 e8 01             	sub    $0x1,%eax
  8007d0:	eb f5                	jmp    8007c7 <.L20+0x10>
  8007d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d5:	e9 73 ff ff ff       	jmp    80074d <.L25+0x45>

008007da <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	83 ec 14             	sub    $0x14,%esp
  8007e1:	e8 96 f8 ff ff       	call   80007c <__x86.get_pc_thunk.bx>
  8007e6:	81 c3 1a 18 00 00    	add    $0x181a,%ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800803:	85 c0                	test   %eax,%eax
  800805:	74 2b                	je     800832 <vsnprintf+0x58>
  800807:	85 d2                	test   %edx,%edx
  800809:	7e 27                	jle    800832 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080b:	ff 75 14             	push   0x14(%ebp)
  80080e:	ff 75 10             	push   0x10(%ebp)
  800811:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	8d 83 34 e3 ff ff    	lea    -0x1ccc(%ebx),%eax
  80081b:	50                   	push   %eax
  80081c:	e8 4d fb ff ff       	call   80036e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800821:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800824:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800827:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082a:	83 c4 10             	add    $0x10,%esp
}
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    
		return -E_INVAL;
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800837:	eb f4                	jmp    80082d <vsnprintf+0x53>

00800839 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800842:	50                   	push   %eax
  800843:	ff 75 10             	push   0x10(%ebp)
  800846:	ff 75 0c             	push   0xc(%ebp)
  800849:	ff 75 08             	push   0x8(%ebp)
  80084c:	e8 89 ff ff ff       	call   8007da <vsnprintf>
	va_end(ap);

	return rc;
}
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <__x86.get_pc_thunk.cx>:
  800853:	8b 0c 24             	mov    (%esp),%ecx
  800856:	c3                   	ret    

00800857 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 03                	jmp    800867 <strlen+0x10>
		n++;
  800864:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	75 f7                	jne    800864 <strlen+0xd>
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
  80087d:	eb 03                	jmp    800882 <strnlen+0x13>
		n++;
  80087f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	39 d0                	cmp    %edx,%eax
  800884:	74 08                	je     80088e <strnlen+0x1f>
  800886:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088a:	75 f3                	jne    80087f <strnlen+0x10>
  80088c:	89 c2                	mov    %eax,%edx
	return n;
}
  80088e:	89 d0                	mov    %edx,%eax
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	84 d2                	test   %dl,%dl
  8008ad:	75 f2                	jne    8008a1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008af:	89 c8                	mov    %ecx,%eax
  8008b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    

008008b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	83 ec 10             	sub    $0x10,%esp
  8008bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c0:	53                   	push   %ebx
  8008c1:	e8 91 ff ff ff       	call   800857 <strlen>
  8008c6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008c9:	ff 75 0c             	push   0xc(%ebp)
  8008cc:	01 d8                	add    %ebx,%eax
  8008ce:	50                   	push   %eax
  8008cf:	e8 be ff ff ff       	call   800892 <strcpy>
	return dst;
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	89 f3                	mov    %esi,%ebx
  8008e8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008eb:	89 f0                	mov    %esi,%eax
  8008ed:	eb 0f                	jmp    8008fe <strncpy+0x23>
		*dst++ = *src;
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 0a             	movzbl (%edx),%ecx
  8008f5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f8:	80 f9 01             	cmp    $0x1,%cl
  8008fb:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008fe:	39 d8                	cmp    %ebx,%eax
  800900:	75 ed                	jne    8008ef <strncpy+0x14>
	}
	return ret;
}
  800902:	89 f0                	mov    %esi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	8b 55 10             	mov    0x10(%ebp),%edx
  800916:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800918:	85 d2                	test   %edx,%edx
  80091a:	74 21                	je     80093d <strlcpy+0x35>
  80091c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 09                	jmp    80092d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800924:	83 c1 01             	add    $0x1,%ecx
  800927:	83 c2 01             	add    $0x1,%edx
  80092a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80092d:	39 c2                	cmp    %eax,%edx
  80092f:	74 09                	je     80093a <strlcpy+0x32>
  800931:	0f b6 19             	movzbl (%ecx),%ebx
  800934:	84 db                	test   %bl,%bl
  800936:	75 ec                	jne    800924 <strlcpy+0x1c>
  800938:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80093a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093d:	29 f0                	sub    %esi,%eax
}
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800949:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094c:	eb 06                	jmp    800954 <strcmp+0x11>
		p++, q++;
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800954:	0f b6 01             	movzbl (%ecx),%eax
  800957:	84 c0                	test   %al,%al
  800959:	74 04                	je     80095f <strcmp+0x1c>
  80095b:	3a 02                	cmp    (%edx),%al
  80095d:	74 ef                	je     80094e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095f:	0f b6 c0             	movzbl %al,%eax
  800962:	0f b6 12             	movzbl (%edx),%edx
  800965:	29 d0                	sub    %edx,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c3                	mov    %eax,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800978:	eb 06                	jmp    800980 <strncmp+0x17>
		n--, p++, q++;
  80097a:	83 c0 01             	add    $0x1,%eax
  80097d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800980:	39 d8                	cmp    %ebx,%eax
  800982:	74 18                	je     80099c <strncmp+0x33>
  800984:	0f b6 08             	movzbl (%eax),%ecx
  800987:	84 c9                	test   %cl,%cl
  800989:	74 04                	je     80098f <strncmp+0x26>
  80098b:	3a 0a                	cmp    (%edx),%cl
  80098d:	74 eb                	je     80097a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098f:	0f b6 00             	movzbl (%eax),%eax
  800992:	0f b6 12             	movzbl (%edx),%edx
  800995:	29 d0                	sub    %edx,%eax
}
  800997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    
		return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb f4                	jmp    800997 <strncmp+0x2e>

008009a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ad:	eb 03                	jmp    8009b2 <strchr+0xf>
  8009af:	83 c0 01             	add    $0x1,%eax
  8009b2:	0f b6 10             	movzbl (%eax),%edx
  8009b5:	84 d2                	test   %dl,%dl
  8009b7:	74 06                	je     8009bf <strchr+0x1c>
		if (*s == c)
  8009b9:	38 ca                	cmp    %cl,%dl
  8009bb:	75 f2                	jne    8009af <strchr+0xc>
  8009bd:	eb 05                	jmp    8009c4 <strchr+0x21>
			return (char *) s;
	return 0;
  8009bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d3:	38 ca                	cmp    %cl,%dl
  8009d5:	74 09                	je     8009e0 <strfind+0x1a>
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	74 05                	je     8009e0 <strfind+0x1a>
	for (; *s; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	eb f0                	jmp    8009d0 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ee:	85 c9                	test   %ecx,%ecx
  8009f0:	74 2f                	je     800a21 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f2:	89 f8                	mov    %edi,%eax
  8009f4:	09 c8                	or     %ecx,%eax
  8009f6:	a8 03                	test   $0x3,%al
  8009f8:	75 21                	jne    800a1b <memset+0x39>
		c &= 0xFF;
  8009fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fe:	89 d0                	mov    %edx,%eax
  800a00:	c1 e0 08             	shl    $0x8,%eax
  800a03:	89 d3                	mov    %edx,%ebx
  800a05:	c1 e3 18             	shl    $0x18,%ebx
  800a08:	89 d6                	mov    %edx,%esi
  800a0a:	c1 e6 10             	shl    $0x10,%esi
  800a0d:	09 f3                	or     %esi,%ebx
  800a0f:	09 da                	or     %ebx,%edx
  800a11:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a13:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a16:	fc                   	cld    
  800a17:	f3 ab                	rep stos %eax,%es:(%edi)
  800a19:	eb 06                	jmp    800a21 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	fc                   	cld    
  800a1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a21:	89 f8                	mov    %edi,%eax
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a36:	39 c6                	cmp    %eax,%esi
  800a38:	73 32                	jae    800a6c <memmove+0x44>
  800a3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3d:	39 c2                	cmp    %eax,%edx
  800a3f:	76 2b                	jbe    800a6c <memmove+0x44>
		s += n;
		d += n;
  800a41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	09 fe                	or     %edi,%esi
  800a48:	09 ce                	or     %ecx,%esi
  800a4a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a50:	75 0e                	jne    800a60 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a52:	83 ef 04             	sub    $0x4,%edi
  800a55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a58:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5b:	fd                   	std    
  800a5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5e:	eb 09                	jmp    800a69 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a60:	83 ef 01             	sub    $0x1,%edi
  800a63:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a66:	fd                   	std    
  800a67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a69:	fc                   	cld    
  800a6a:	eb 1a                	jmp    800a86 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6c:	89 f2                	mov    %esi,%edx
  800a6e:	09 c2                	or     %eax,%edx
  800a70:	09 ca                	or     %ecx,%edx
  800a72:	f6 c2 03             	test   $0x3,%dl
  800a75:	75 0a                	jne    800a81 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a77:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	fc                   	cld    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 05                	jmp    800a86 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a90:	ff 75 10             	push   0x10(%ebp)
  800a93:	ff 75 0c             	push   0xc(%ebp)
  800a96:	ff 75 08             	push   0x8(%ebp)
  800a99:	e8 8a ff ff ff       	call   800a28 <memmove>
}
  800a9e:	c9                   	leave  
  800a9f:	c3                   	ret    

00800aa0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aab:	89 c6                	mov    %eax,%esi
  800aad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab0:	eb 06                	jmp    800ab8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab2:	83 c0 01             	add    $0x1,%eax
  800ab5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ab8:	39 f0                	cmp    %esi,%eax
  800aba:	74 14                	je     800ad0 <memcmp+0x30>
		if (*s1 != *s2)
  800abc:	0f b6 08             	movzbl (%eax),%ecx
  800abf:	0f b6 1a             	movzbl (%edx),%ebx
  800ac2:	38 d9                	cmp    %bl,%cl
  800ac4:	74 ec                	je     800ab2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ac6:	0f b6 c1             	movzbl %cl,%eax
  800ac9:	0f b6 db             	movzbl %bl,%ebx
  800acc:	29 d8                	sub    %ebx,%eax
  800ace:	eb 05                	jmp    800ad5 <memcmp+0x35>
	}

	return 0;
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae7:	eb 03                	jmp    800aec <memfind+0x13>
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	39 d0                	cmp    %edx,%eax
  800aee:	73 04                	jae    800af4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af0:	38 08                	cmp    %cl,(%eax)
  800af2:	75 f5                	jne    800ae9 <memfind+0x10>
			break;
	return (void *) s;
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 55 08             	mov    0x8(%ebp),%edx
  800aff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b02:	eb 03                	jmp    800b07 <strtol+0x11>
		s++;
  800b04:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b07:	0f b6 02             	movzbl (%edx),%eax
  800b0a:	3c 20                	cmp    $0x20,%al
  800b0c:	74 f6                	je     800b04 <strtol+0xe>
  800b0e:	3c 09                	cmp    $0x9,%al
  800b10:	74 f2                	je     800b04 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b12:	3c 2b                	cmp    $0x2b,%al
  800b14:	74 2a                	je     800b40 <strtol+0x4a>
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1b:	3c 2d                	cmp    $0x2d,%al
  800b1d:	74 2b                	je     800b4a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b25:	75 0f                	jne    800b36 <strtol+0x40>
  800b27:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2a:	74 28                	je     800b54 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2c:	85 db                	test   %ebx,%ebx
  800b2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b33:	0f 44 d8             	cmove  %eax,%ebx
  800b36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b3e:	eb 46                	jmp    800b86 <strtol+0x90>
		s++;
  800b40:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b43:	bf 00 00 00 00       	mov    $0x0,%edi
  800b48:	eb d5                	jmp    800b1f <strtol+0x29>
		s++, neg = 1;
  800b4a:	83 c2 01             	add    $0x1,%edx
  800b4d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b52:	eb cb                	jmp    800b1f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b54:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b58:	74 0e                	je     800b68 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 d8                	jne    800b36 <strtol+0x40>
		s++, base = 8;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b66:	eb ce                	jmp    800b36 <strtol+0x40>
		s += 2, base = 16;
  800b68:	83 c2 02             	add    $0x2,%edx
  800b6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b70:	eb c4                	jmp    800b36 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b72:	0f be c0             	movsbl %al,%eax
  800b75:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b78:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b7b:	7d 3a                	jge    800bb7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b7d:	83 c2 01             	add    $0x1,%edx
  800b80:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b84:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b86:	0f b6 02             	movzbl (%edx),%eax
  800b89:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 09             	cmp    $0x9,%bl
  800b91:	76 df                	jbe    800b72 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b93:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b96:	89 f3                	mov    %esi,%ebx
  800b98:	80 fb 19             	cmp    $0x19,%bl
  800b9b:	77 08                	ja     800ba5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b9d:	0f be c0             	movsbl %al,%eax
  800ba0:	83 e8 57             	sub    $0x57,%eax
  800ba3:	eb d3                	jmp    800b78 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ba5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 08                	ja     800bb7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800baf:	0f be c0             	movsbl %al,%eax
  800bb2:	83 e8 37             	sub    $0x37,%eax
  800bb5:	eb c1                	jmp    800b78 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbb:	74 05                	je     800bc2 <strtol+0xcc>
		*endptr = (char *) s;
  800bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc2:	89 c8                	mov    %ecx,%eax
  800bc4:	f7 d8                	neg    %eax
  800bc6:	85 ff                	test   %edi,%edi
  800bc8:	0f 45 c8             	cmovne %eax,%ecx
}
  800bcb:	89 c8                	mov    %ecx,%eax
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
  800bd2:	66 90                	xchg   %ax,%ax
  800bd4:	66 90                	xchg   %ax,%ax
  800bd6:	66 90                	xchg   %ax,%ax
  800bd8:	66 90                	xchg   %ax,%ax
  800bda:	66 90                	xchg   %ax,%ax
  800bdc:	66 90                	xchg   %ax,%ax
  800bde:	66 90                	xchg   %ax,%ax

00800be0 <__udivdi3>:
  800be0:	f3 0f 1e fb          	endbr32 
  800be4:	55                   	push   %ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 1c             	sub    $0x1c,%esp
  800beb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800bef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800bf3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800bf7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	75 19                	jne    800c18 <__udivdi3+0x38>
  800bff:	39 f3                	cmp    %esi,%ebx
  800c01:	76 4d                	jbe    800c50 <__udivdi3+0x70>
  800c03:	31 ff                	xor    %edi,%edi
  800c05:	89 e8                	mov    %ebp,%eax
  800c07:	89 f2                	mov    %esi,%edx
  800c09:	f7 f3                	div    %ebx
  800c0b:	89 fa                	mov    %edi,%edx
  800c0d:	83 c4 1c             	add    $0x1c,%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
  800c15:	8d 76 00             	lea    0x0(%esi),%esi
  800c18:	39 f0                	cmp    %esi,%eax
  800c1a:	76 14                	jbe    800c30 <__udivdi3+0x50>
  800c1c:	31 ff                	xor    %edi,%edi
  800c1e:	31 c0                	xor    %eax,%eax
  800c20:	89 fa                	mov    %edi,%edx
  800c22:	83 c4 1c             	add    $0x1c,%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    
  800c2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c30:	0f bd f8             	bsr    %eax,%edi
  800c33:	83 f7 1f             	xor    $0x1f,%edi
  800c36:	75 48                	jne    800c80 <__udivdi3+0xa0>
  800c38:	39 f0                	cmp    %esi,%eax
  800c3a:	72 06                	jb     800c42 <__udivdi3+0x62>
  800c3c:	31 c0                	xor    %eax,%eax
  800c3e:	39 eb                	cmp    %ebp,%ebx
  800c40:	77 de                	ja     800c20 <__udivdi3+0x40>
  800c42:	b8 01 00 00 00       	mov    $0x1,%eax
  800c47:	eb d7                	jmp    800c20 <__udivdi3+0x40>
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	89 d9                	mov    %ebx,%ecx
  800c52:	85 db                	test   %ebx,%ebx
  800c54:	75 0b                	jne    800c61 <__udivdi3+0x81>
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	31 d2                	xor    %edx,%edx
  800c5d:	f7 f3                	div    %ebx
  800c5f:	89 c1                	mov    %eax,%ecx
  800c61:	31 d2                	xor    %edx,%edx
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	f7 f1                	div    %ecx
  800c67:	89 c6                	mov    %eax,%esi
  800c69:	89 e8                	mov    %ebp,%eax
  800c6b:	89 f7                	mov    %esi,%edi
  800c6d:	f7 f1                	div    %ecx
  800c6f:	89 fa                	mov    %edi,%edx
  800c71:	83 c4 1c             	add    $0x1c,%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	ba 20 00 00 00       	mov    $0x20,%edx
  800c87:	29 fa                	sub    %edi,%edx
  800c89:	d3 e0                	shl    %cl,%eax
  800c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	89 d8                	mov    %ebx,%eax
  800c93:	d3 e8                	shr    %cl,%eax
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 c1                	or     %eax,%ecx
  800c9b:	89 f0                	mov    %esi,%eax
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	d3 e8                	shr    %cl,%eax
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	89 eb                	mov    %ebp,%ebx
  800cb1:	d3 e6                	shl    %cl,%esi
  800cb3:	89 d1                	mov    %edx,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 f3                	or     %esi,%ebx
  800cb9:	89 c6                	mov    %eax,%esi
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 d8                	mov    %ebx,%eax
  800cbf:	f7 74 24 08          	divl   0x8(%esp)
  800cc3:	89 d6                	mov    %edx,%esi
  800cc5:	89 c3                	mov    %eax,%ebx
  800cc7:	f7 64 24 0c          	mull   0xc(%esp)
  800ccb:	39 d6                	cmp    %edx,%esi
  800ccd:	72 19                	jb     800ce8 <__udivdi3+0x108>
  800ccf:	89 f9                	mov    %edi,%ecx
  800cd1:	d3 e5                	shl    %cl,%ebp
  800cd3:	39 c5                	cmp    %eax,%ebp
  800cd5:	73 04                	jae    800cdb <__udivdi3+0xfb>
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	74 0d                	je     800ce8 <__udivdi3+0x108>
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	31 ff                	xor    %edi,%edi
  800cdf:	e9 3c ff ff ff       	jmp    800c20 <__udivdi3+0x40>
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ceb:	31 ff                	xor    %edi,%edi
  800ced:	e9 2e ff ff ff       	jmp    800c20 <__udivdi3+0x40>
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__umoddi3>:
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 1c             	sub    $0x1c,%esp
  800d0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d13:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d17:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d1b:	89 f0                	mov    %esi,%eax
  800d1d:	89 da                	mov    %ebx,%edx
  800d1f:	85 ff                	test   %edi,%edi
  800d21:	75 15                	jne    800d38 <__umoddi3+0x38>
  800d23:	39 dd                	cmp    %ebx,%ebp
  800d25:	76 39                	jbe    800d60 <__umoddi3+0x60>
  800d27:	f7 f5                	div    %ebp
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	31 d2                	xor    %edx,%edx
  800d2d:	83 c4 1c             	add    $0x1c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
  800d35:	8d 76 00             	lea    0x0(%esi),%esi
  800d38:	39 df                	cmp    %ebx,%edi
  800d3a:	77 f1                	ja     800d2d <__umoddi3+0x2d>
  800d3c:	0f bd cf             	bsr    %edi,%ecx
  800d3f:	83 f1 1f             	xor    $0x1f,%ecx
  800d42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d46:	75 40                	jne    800d88 <__umoddi3+0x88>
  800d48:	39 df                	cmp    %ebx,%edi
  800d4a:	72 04                	jb     800d50 <__umoddi3+0x50>
  800d4c:	39 f5                	cmp    %esi,%ebp
  800d4e:	77 dd                	ja     800d2d <__umoddi3+0x2d>
  800d50:	89 da                	mov    %ebx,%edx
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	29 e8                	sub    %ebp,%eax
  800d56:	19 fa                	sbb    %edi,%edx
  800d58:	eb d3                	jmp    800d2d <__umoddi3+0x2d>
  800d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d60:	89 e9                	mov    %ebp,%ecx
  800d62:	85 ed                	test   %ebp,%ebp
  800d64:	75 0b                	jne    800d71 <__umoddi3+0x71>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f5                	div    %ebp
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	89 d8                	mov    %ebx,%eax
  800d73:	31 d2                	xor    %edx,%edx
  800d75:	f7 f1                	div    %ecx
  800d77:	89 f0                	mov    %esi,%eax
  800d79:	f7 f1                	div    %ecx
  800d7b:	89 d0                	mov    %edx,%eax
  800d7d:	31 d2                	xor    %edx,%edx
  800d7f:	eb ac                	jmp    800d2d <__umoddi3+0x2d>
  800d81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d88:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d8c:	ba 20 00 00 00       	mov    $0x20,%edx
  800d91:	29 c2                	sub    %eax,%edx
  800d93:	89 c1                	mov    %eax,%ecx
  800d95:	89 e8                	mov    %ebp,%eax
  800d97:	d3 e7                	shl    %cl,%edi
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d9f:	d3 e8                	shr    %cl,%eax
  800da1:	89 c1                	mov    %eax,%ecx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	09 f9                	or     %edi,%ecx
  800da9:	89 df                	mov    %ebx,%edi
  800dab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	d3 e5                	shl    %cl,%ebp
  800db3:	89 d1                	mov    %edx,%ecx
  800db5:	d3 ef                	shr    %cl,%edi
  800db7:	89 c1                	mov    %eax,%ecx
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	d3 e3                	shl    %cl,%ebx
  800dbd:	89 d1                	mov    %edx,%ecx
  800dbf:	89 fa                	mov    %edi,%edx
  800dc1:	d3 e8                	shr    %cl,%eax
  800dc3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dc8:	09 d8                	or     %ebx,%eax
  800dca:	f7 74 24 08          	divl   0x8(%esp)
  800dce:	89 d3                	mov    %edx,%ebx
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	f7 e5                	mul    %ebp
  800dd4:	89 c7                	mov    %eax,%edi
  800dd6:	89 d1                	mov    %edx,%ecx
  800dd8:	39 d3                	cmp    %edx,%ebx
  800dda:	72 06                	jb     800de2 <__umoddi3+0xe2>
  800ddc:	75 0e                	jne    800dec <__umoddi3+0xec>
  800dde:	39 c6                	cmp    %eax,%esi
  800de0:	73 0a                	jae    800dec <__umoddi3+0xec>
  800de2:	29 e8                	sub    %ebp,%eax
  800de4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800de8:	89 d1                	mov    %edx,%ecx
  800dea:	89 c7                	mov    %eax,%edi
  800dec:	89 f5                	mov    %esi,%ebp
  800dee:	8b 74 24 04          	mov    0x4(%esp),%esi
  800df2:	29 fd                	sub    %edi,%ebp
  800df4:	19 cb                	sbb    %ecx,%ebx
  800df6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	d3 e0                	shl    %cl,%eax
  800dff:	89 f1                	mov    %esi,%ecx
  800e01:	d3 ed                	shr    %cl,%ebp
  800e03:	d3 eb                	shr    %cl,%ebx
  800e05:	09 e8                	or     %ebp,%eax
  800e07:	89 da                	mov    %ebx,%edx
  800e09:	83 c4 1c             	add    $0x1c,%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    
