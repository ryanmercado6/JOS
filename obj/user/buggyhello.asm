
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 74 00 00 00       	call   8000c2 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	53                   	push   %ebx
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	e8 f0 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800066:	81 c3 9a 1f 00 00    	add    $0x1f9a,%ebx
  80006c:	8b 45 08             	mov    0x8(%ebp),%eax
  80006f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  800072:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  800078:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80008a:	83 ec 08             	sub    $0x8,%esp
  80008d:	52                   	push   %edx
  80008e:	50                   	push   %eax
  80008f:	e8 9f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800094:	e8 08 00 00 00       	call   8000a1 <exit>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	e8 a9 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000ad:	81 c3 53 1f 00 00    	add    $0x1f53,%ebx
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 45 00 00 00       	call   8000ff <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	89 c3                	mov    %eax,%ebx
  8000d5:	89 c7                	mov    %eax,%edi
  8000d7:	89 c6                	mov    %eax,%esi
  8000d9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 1c             	sub    $0x1c,%esp
  800108:	e8 66 00 00 00       	call   800173 <__x86.get_pc_thunk.ax>
  80010d:	05 f3 1e 00 00       	add    $0x1ef3,%eax
  800112:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	b8 03 00 00 00       	mov    $0x3,%eax
  800122:	89 cb                	mov    %ecx,%ebx
  800124:	89 cf                	mov    %ecx,%edi
  800126:	89 ce                	mov    %ecx,%esi
  800128:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f 08                	jg     800136 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	6a 03                	push   $0x3
  80013c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013f:	8d 83 3e ee ff ff    	lea    -0x11c2(%ebx),%eax
  800145:	50                   	push   %eax
  800146:	6a 23                	push   $0x23
  800148:	8d 83 5b ee ff ff    	lea    -0x11a5(%ebx),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 23 00 00 00       	call   800177 <_panic>

00800154 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 02 00 00 00       	mov    $0x2,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <__x86.get_pc_thunk.ax>:
  800173:	8b 04 24             	mov    (%esp),%eax
  800176:	c3                   	ret    

00800177 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	e8 d1 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800185:	81 c3 7b 1e 00 00    	add    $0x1e7b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800194:	8b 38                	mov    (%eax),%edi
  800196:	e8 b9 ff ff ff       	call   800154 <sys_getenvid>
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 0c             	push   0xc(%ebp)
  8001a1:	ff 75 08             	push   0x8(%ebp)
  8001a4:	57                   	push   %edi
  8001a5:	50                   	push   %eax
  8001a6:	8d 83 6c ee ff ff    	lea    -0x1194(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 d1 00 00 00       	call   800283 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b2:	83 c4 18             	add    $0x18,%esp
  8001b5:	56                   	push   %esi
  8001b6:	ff 75 10             	push   0x10(%ebp)
  8001b9:	e8 63 00 00 00       	call   800221 <vcprintf>
	cprintf("\n");
  8001be:	8d 83 8f ee ff ff    	lea    -0x1171(%ebx),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 b7 00 00 00       	call   800283 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cf:	cc                   	int3   
  8001d0:	eb fd                	jmp    8001cf <_panic+0x58>

008001d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	e8 7a fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001dc:	81 c3 24 1e 00 00    	add    $0x1e24,%ebx
  8001e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e5:	8b 16                	mov    (%esi),%edx
  8001e7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ea:	89 06                	mov    %eax,(%esi)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	74 0b                	je     800205 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fa:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 46 08             	lea    0x8(%esi),%eax
  800210:	50                   	push   %eax
  800211:	e8 ac fe ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  800216:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	eb d9                	jmp    8001fa <putch+0x28>

00800221 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	53                   	push   %ebx
  800225:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022b:	e8 26 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800230:	81 c3 d0 1d 00 00    	add    $0x1dd0,%ebx
	struct printbuf b;

	b.idx = 0;
  800236:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023d:	00 00 00 
	b.cnt = 0;
  800240:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800247:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024a:	ff 75 0c             	push   0xc(%ebp)
  80024d:	ff 75 08             	push   0x8(%ebp)
  800250:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	8d 83 d2 e1 ff ff    	lea    -0x1e2e(%ebx),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 2c 01 00 00       	call   80038f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	83 c4 08             	add    $0x8,%esp
  800266:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80026c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	e8 4a fe ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800289:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028c:	50                   	push   %eax
  80028d:	ff 75 08             	push   0x8(%ebp)
  800290:	e8 8c ff ff ff       	call   800221 <vcprintf>
	va_end(ap);

	return cnt;
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	e8 cf 05 00 00       	call   800874 <__x86.get_pc_thunk.cx>
  8002a5:	81 c1 5b 1d 00 00    	add    $0x1d5b,%ecx
  8002ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ae:	89 c7                	mov    %eax,%edi
  8002b0:	89 d6                	mov    %edx,%esi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	89 d1                	mov    %edx,%ecx
  8002ba:	89 c2                	mov    %eax,%edx
  8002bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002cb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d2:	39 c2                	cmp    %eax,%edx
  8002d4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d7:	72 41                	jb     80031a <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	ff 75 18             	push   0x18(%ebp)
  8002df:	83 eb 01             	sub    $0x1,%ebx
  8002e2:	53                   	push   %ebx
  8002e3:	50                   	push   %eax
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 e4             	push   -0x1c(%ebp)
  8002ea:	ff 75 e0             	push   -0x20(%ebp)
  8002ed:	ff 75 d4             	push   -0x2c(%ebp)
  8002f0:	ff 75 d0             	push   -0x30(%ebp)
  8002f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f6:	e8 05 09 00 00       	call   800c00 <__udivdi3>
  8002fb:	83 c4 18             	add    $0x18,%esp
  8002fe:	52                   	push   %edx
  8002ff:	50                   	push   %eax
  800300:	89 f2                	mov    %esi,%edx
  800302:	89 f8                	mov    %edi,%eax
  800304:	e8 8e ff ff ff       	call   800297 <printnum>
  800309:	83 c4 20             	add    $0x20,%esp
  80030c:	eb 13                	jmp    800321 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	ff 75 18             	push   0x18(%ebp)
  800315:	ff d7                	call   *%edi
  800317:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	85 db                	test   %ebx,%ebx
  80031f:	7f ed                	jg     80030e <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	56                   	push   %esi
  800325:	83 ec 04             	sub    $0x4,%esp
  800328:	ff 75 e4             	push   -0x1c(%ebp)
  80032b:	ff 75 e0             	push   -0x20(%ebp)
  80032e:	ff 75 d4             	push   -0x2c(%ebp)
  800331:	ff 75 d0             	push   -0x30(%ebp)
  800334:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800337:	e8 e4 09 00 00       	call   800d20 <__umoddi3>
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	0f be 84 03 91 ee ff 	movsbl -0x116f(%ebx,%eax,1),%eax
  800346:	ff 
  800347:	50                   	push   %eax
  800348:	ff d7                	call   *%edi
}
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035f:	8b 10                	mov    (%eax),%edx
  800361:	3b 50 04             	cmp    0x4(%eax),%edx
  800364:	73 0a                	jae    800370 <sprintputch+0x1b>
		*b->buf++ = ch;
  800366:	8d 4a 01             	lea    0x1(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	88 02                	mov    %al,(%edx)
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <printfmt>:
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800378:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037b:	50                   	push   %eax
  80037c:	ff 75 10             	push   0x10(%ebp)
  80037f:	ff 75 0c             	push   0xc(%ebp)
  800382:	ff 75 08             	push   0x8(%ebp)
  800385:	e8 05 00 00 00       	call   80038f <vprintfmt>
}
  80038a:	83 c4 10             	add    $0x10,%esp
  80038d:	c9                   	leave  
  80038e:	c3                   	ret    

0080038f <vprintfmt>:
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 3c             	sub    $0x3c,%esp
  800398:	e8 d6 fd ff ff       	call   800173 <__x86.get_pc_thunk.ax>
  80039d:	05 63 1c 00 00       	add    $0x1c63,%eax
  8003a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ae:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003b4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003b7:	eb 0a                	jmp    8003c3 <vprintfmt+0x34>
			putch(ch, putdat);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	57                   	push   %edi
  8003bd:	50                   	push   %eax
  8003be:	ff d6                	call   *%esi
  8003c0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c3:	83 c3 01             	add    $0x1,%ebx
  8003c6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003ca:	83 f8 25             	cmp    $0x25,%eax
  8003cd:	74 0c                	je     8003db <vprintfmt+0x4c>
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	75 e6                	jne    8003b9 <vprintfmt+0x2a>
}
  8003d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d6:	5b                   	pop    %ebx
  8003d7:	5e                   	pop    %esi
  8003d8:	5f                   	pop    %edi
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    
		padc = ' ';
  8003db:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003df:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003fc:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8d 43 01             	lea    0x1(%ebx),%eax
  800402:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800405:	0f b6 13             	movzbl (%ebx),%edx
  800408:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 c5 03 00 00    	ja     8007d8 <.L20>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800419:	89 ce                	mov    %ecx,%esi
  80041b:	03 b4 81 20 ef ff ff 	add    -0x10e0(%ecx,%eax,4),%esi
  800422:	ff e6                	jmp    *%esi

00800424 <.L66>:
  800424:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800427:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80042b:	eb d2                	jmp    8003ff <vprintfmt+0x70>

0080042d <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800430:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800434:	eb c9                	jmp    8003ff <vprintfmt+0x70>

00800436 <.L31>:
  800436:	0f b6 d2             	movzbl %dl,%edx
  800439:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800444:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800447:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044b:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80044e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800451:	83 f9 09             	cmp    $0x9,%ecx
  800454:	77 58                	ja     8004ae <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800456:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800459:	eb e9                	jmp    800444 <.L31+0xe>

0080045b <.L34>:
			precision = va_arg(ap, int);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 40 04             	lea    0x4(%eax),%eax
  800469:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80046f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800473:	79 8a                	jns    8003ff <vprintfmt+0x70>
				width = precision, precision = -1;
  800475:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800482:	e9 78 ff ff ff       	jmp    8003ff <vprintfmt+0x70>

00800487 <.L33>:
  800487:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c2             	cmovns %edx,%eax
  800494:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049a:	e9 60 ff ff ff       	jmp    8003ff <vprintfmt+0x70>

0080049f <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004a9:	e9 51 ff ff ff       	jmp    8003ff <vprintfmt+0x70>
  8004ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b4:	eb b9                	jmp    80046f <.L34+0x14>

008004b6 <.L27>:
			lflag++;
  8004b6:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004bd:	e9 3d ff ff ff       	jmp    8003ff <vprintfmt+0x70>

008004c2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	57                   	push   %edi
  8004cf:	ff 30                	push   (%eax)
  8004d1:	ff d6                	call   *%esi
			break;
  8004d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d6:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004d9:	e9 90 02 00 00       	jmp    80076e <.L25+0x45>

008004de <.L28>:
			err = va_arg(ap, int);
  8004de:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e7:	8b 10                	mov    (%eax),%edx
  8004e9:	89 d0                	mov    %edx,%eax
  8004eb:	f7 d8                	neg    %eax
  8004ed:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f0:	83 f8 06             	cmp    $0x6,%eax
  8004f3:	7f 27                	jg     80051c <.L28+0x3e>
  8004f5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f8:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004fb:	85 d2                	test   %edx,%edx
  8004fd:	74 1d                	je     80051c <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004ff:	52                   	push   %edx
  800500:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800503:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  800509:	50                   	push   %eax
  80050a:	57                   	push   %edi
  80050b:	56                   	push   %esi
  80050c:	e8 61 fe ff ff       	call   800372 <printfmt>
  800511:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800514:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800517:	e9 52 02 00 00       	jmp    80076e <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80051c:	50                   	push   %eax
  80051d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800520:	8d 80 a9 ee ff ff    	lea    -0x1157(%eax),%eax
  800526:	50                   	push   %eax
  800527:	57                   	push   %edi
  800528:	56                   	push   %esi
  800529:	e8 44 fe ff ff       	call   800372 <printfmt>
  80052e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800531:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800534:	e9 35 02 00 00       	jmp    80076e <.L25+0x45>

00800539 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 75 08             	mov    0x8(%ebp),%esi
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	83 c0 04             	add    $0x4,%eax
  800542:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80054a:	85 d2                	test   %edx,%edx
  80054c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054f:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  800555:	0f 45 c2             	cmovne %edx,%eax
  800558:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80055b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80055f:	7e 06                	jle    800567 <.L24+0x2e>
  800561:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800565:	75 0d                	jne    800574 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056a:	89 c3                	mov    %eax,%ebx
  80056c:	03 45 d0             	add    -0x30(%ebp),%eax
  80056f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800572:	eb 58                	jmp    8005cc <.L24+0x93>
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	ff 75 d8             	push   -0x28(%ebp)
  80057a:	ff 75 c8             	push   -0x38(%ebp)
  80057d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800580:	e8 0b 03 00 00       	call   800890 <strnlen>
  800585:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800588:	29 c2                	sub    %eax,%edx
  80058a:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800592:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800596:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800599:	eb 0f                	jmp    8005aa <.L24+0x71>
					putch(padc, putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	57                   	push   %edi
  80059f:	ff 75 d0             	push   -0x30(%ebp)
  8005a2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a4:	83 eb 01             	sub    $0x1,%ebx
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	85 db                	test   %ebx,%ebx
  8005ac:	7f ed                	jg     80059b <.L24+0x62>
  8005ae:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b8:	0f 49 c2             	cmovns %edx,%eax
  8005bb:	29 c2                	sub    %eax,%edx
  8005bd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c0:	eb a5                	jmp    800567 <.L24+0x2e>
					putch(ch, putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	57                   	push   %edi
  8005c6:	52                   	push   %edx
  8005c7:	ff d6                	call   *%esi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005cf:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d1:	83 c3 01             	add    $0x1,%ebx
  8005d4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005d8:	0f be d0             	movsbl %al,%edx
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 4b                	je     80062a <.L24+0xf1>
  8005df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e3:	78 06                	js     8005eb <.L24+0xb2>
  8005e5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e9:	78 1e                	js     800609 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ef:	74 d1                	je     8005c2 <.L24+0x89>
  8005f1:	0f be c0             	movsbl %al,%eax
  8005f4:	83 e8 20             	sub    $0x20,%eax
  8005f7:	83 f8 5e             	cmp    $0x5e,%eax
  8005fa:	76 c6                	jbe    8005c2 <.L24+0x89>
					putch('?', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	57                   	push   %edi
  800600:	6a 3f                	push   $0x3f
  800602:	ff d6                	call   *%esi
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	eb c3                	jmp    8005cc <.L24+0x93>
  800609:	89 cb                	mov    %ecx,%ebx
  80060b:	eb 0e                	jmp    80061b <.L24+0xe2>
				putch(' ', putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	57                   	push   %edi
  800611:	6a 20                	push   $0x20
  800613:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800615:	83 eb 01             	sub    $0x1,%ebx
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	85 db                	test   %ebx,%ebx
  80061d:	7f ee                	jg     80060d <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80061f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
  800625:	e9 44 01 00 00       	jmp    80076e <.L25+0x45>
  80062a:	89 cb                	mov    %ecx,%ebx
  80062c:	eb ed                	jmp    80061b <.L24+0xe2>

0080062e <.L29>:
	if (lflag >= 2)
  80062e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800631:	8b 75 08             	mov    0x8(%ebp),%esi
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7f 1b                	jg     800654 <.L29+0x26>
	else if (lflag)
  800639:	85 c9                	test   %ecx,%ecx
  80063b:	74 63                	je     8006a0 <.L29+0x72>
		return va_arg(*ap, long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	99                   	cltd   
  800646:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 40 04             	lea    0x4(%eax),%eax
  80064f:	89 45 14             	mov    %eax,0x14(%ebp)
  800652:	eb 17                	jmp    80066b <.L29+0x3d>
		return va_arg(*ap, long long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 50 04             	mov    0x4(%eax),%edx
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 08             	lea    0x8(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80066b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800671:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800676:	85 db                	test   %ebx,%ebx
  800678:	0f 89 d6 00 00 00    	jns    800754 <.L25+0x2b>
				putch('-', putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	57                   	push   %edi
  800682:	6a 2d                	push   $0x2d
  800684:	ff d6                	call   *%esi
				num = -(long long) num;
  800686:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800689:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068c:	f7 d9                	neg    %ecx
  80068e:	83 d3 00             	adc    $0x0,%ebx
  800691:	f7 db                	neg    %ebx
  800693:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800696:	ba 0a 00 00 00       	mov    $0xa,%edx
  80069b:	e9 b4 00 00 00       	jmp    800754 <.L25+0x2b>
		return va_arg(*ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a8:	99                   	cltd   
  8006a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b5:	eb b4                	jmp    80066b <.L29+0x3d>

008006b7 <.L23>:
	if (lflag >= 2)
  8006b7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bd:	83 f9 01             	cmp    $0x1,%ecx
  8006c0:	7f 1b                	jg     8006dd <.L23+0x26>
	else if (lflag)
  8006c2:	85 c9                	test   %ecx,%ecx
  8006c4:	74 2c                	je     8006f2 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 08                	mov    (%eax),%ecx
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006db:	eb 77                	jmp    800754 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 08                	mov    (%eax),%ecx
  8006e2:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e5:	8d 40 08             	lea    0x8(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006eb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f0:	eb 62                	jmp    800754 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 08                	mov    (%eax),%ecx
  8006f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800702:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  800707:	eb 4b                	jmp    800754 <.L25+0x2b>

00800709 <.L26>:
			putch('X', putdat);
  800709:	8b 75 08             	mov    0x8(%ebp),%esi
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	57                   	push   %edi
  800710:	6a 58                	push   $0x58
  800712:	ff d6                	call   *%esi
			putch('X', putdat);
  800714:	83 c4 08             	add    $0x8,%esp
  800717:	57                   	push   %edi
  800718:	6a 58                	push   $0x58
  80071a:	ff d6                	call   *%esi
			putch('X', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	57                   	push   %edi
  800720:	6a 58                	push   $0x58
  800722:	ff d6                	call   *%esi
			break;
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 45                	jmp    80076e <.L25+0x45>

00800729 <.L25>:
			putch('0', putdat);
  800729:	8b 75 08             	mov    0x8(%ebp),%esi
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	57                   	push   %edi
  800730:	6a 30                	push   $0x30
  800732:	ff d6                	call   *%esi
			putch('x', putdat);
  800734:	83 c4 08             	add    $0x8,%esp
  800737:	57                   	push   %edi
  800738:	6a 78                	push   $0x78
  80073a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 08                	mov    (%eax),%ecx
  800741:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800746:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800749:	8d 40 04             	lea    0x4(%eax),%eax
  80074c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074f:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800754:	83 ec 0c             	sub    $0xc,%esp
  800757:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80075b:	50                   	push   %eax
  80075c:	ff 75 d0             	push   -0x30(%ebp)
  80075f:	52                   	push   %edx
  800760:	53                   	push   %ebx
  800761:	51                   	push   %ecx
  800762:	89 fa                	mov    %edi,%edx
  800764:	89 f0                	mov    %esi,%eax
  800766:	e8 2c fb ff ff       	call   800297 <printnum>
			break;
  80076b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80076e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800771:	e9 4d fc ff ff       	jmp    8003c3 <vprintfmt+0x34>

00800776 <.L21>:
	if (lflag >= 2)
  800776:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	83 f9 01             	cmp    $0x1,%ecx
  80077f:	7f 1b                	jg     80079c <.L21+0x26>
	else if (lflag)
  800781:	85 c9                	test   %ecx,%ecx
  800783:	74 2c                	je     8007b1 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 08                	mov    (%eax),%ecx
  80078a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078f:	8d 40 04             	lea    0x4(%eax),%eax
  800792:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800795:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80079a:	eb b8                	jmp    800754 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8b 08                	mov    (%eax),%ecx
  8007a1:	8b 58 04             	mov    0x4(%eax),%ebx
  8007a4:	8d 40 08             	lea    0x8(%eax),%eax
  8007a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007aa:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007af:	eb a3                	jmp    800754 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 08                	mov    (%eax),%ecx
  8007b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007bb:	8d 40 04             	lea    0x4(%eax),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007c6:	eb 8c                	jmp    800754 <.L25+0x2b>

008007c8 <.L35>:
			putch(ch, putdat);
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	57                   	push   %edi
  8007cf:	6a 25                	push   $0x25
  8007d1:	ff d6                	call   *%esi
			break;
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	eb 96                	jmp    80076e <.L25+0x45>

008007d8 <.L20>:
			putch('%', putdat);
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	57                   	push   %edi
  8007df:	6a 25                	push   $0x25
  8007e1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	89 d8                	mov    %ebx,%eax
  8007e8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ec:	74 05                	je     8007f3 <.L20+0x1b>
  8007ee:	83 e8 01             	sub    $0x1,%eax
  8007f1:	eb f5                	jmp    8007e8 <.L20+0x10>
  8007f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f6:	e9 73 ff ff ff       	jmp    80076e <.L25+0x45>

008007fb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 14             	sub    $0x14,%esp
  800802:	e8 4f f8 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800807:	81 c3 f9 17 00 00    	add    $0x17f9,%ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800813:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800816:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80081d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800824:	85 c0                	test   %eax,%eax
  800826:	74 2b                	je     800853 <vsnprintf+0x58>
  800828:	85 d2                	test   %edx,%edx
  80082a:	7e 27                	jle    800853 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082c:	ff 75 14             	push   0x14(%ebp)
  80082f:	ff 75 10             	push   0x10(%ebp)
  800832:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8d 83 55 e3 ff ff    	lea    -0x1cab(%ebx),%eax
  80083c:	50                   	push   %eax
  80083d:	e8 4d fb ff ff       	call   80038f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800842:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800845:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084b:	83 c4 10             	add    $0x10,%esp
}
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    
		return -E_INVAL;
  800853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800858:	eb f4                	jmp    80084e <vsnprintf+0x53>

0080085a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800860:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800863:	50                   	push   %eax
  800864:	ff 75 10             	push   0x10(%ebp)
  800867:	ff 75 0c             	push   0xc(%ebp)
  80086a:	ff 75 08             	push   0x8(%ebp)
  80086d:	e8 89 ff ff ff       	call   8007fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <__x86.get_pc_thunk.cx>:
  800874:	8b 0c 24             	mov    (%esp),%ecx
  800877:	c3                   	ret    

00800878 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
  800883:	eb 03                	jmp    800888 <strlen+0x10>
		n++;
  800885:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800888:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088c:	75 f7                	jne    800885 <strlen+0xd>
	return n;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800896:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	eb 03                	jmp    8008a3 <strnlen+0x13>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a3:	39 d0                	cmp    %edx,%eax
  8008a5:	74 08                	je     8008af <strnlen+0x1f>
  8008a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ab:	75 f3                	jne    8008a0 <strnlen+0x10>
  8008ad:	89 c2                	mov    %eax,%edx
	return n;
}
  8008af:	89 d0                	mov    %edx,%eax
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	75 f2                	jne    8008c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d0:	89 c8                	mov    %ecx,%eax
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	83 ec 10             	sub    $0x10,%esp
  8008de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e1:	53                   	push   %ebx
  8008e2:	e8 91 ff ff ff       	call   800878 <strlen>
  8008e7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ea:	ff 75 0c             	push   0xc(%ebp)
  8008ed:	01 d8                	add    %ebx,%eax
  8008ef:	50                   	push   %eax
  8008f0:	e8 be ff ff ff       	call   8008b3 <strcpy>
	return dst;
}
  8008f5:	89 d8                	mov    %ebx,%eax
  8008f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	56                   	push   %esi
  800900:	53                   	push   %ebx
  800901:	8b 75 08             	mov    0x8(%ebp),%esi
  800904:	8b 55 0c             	mov    0xc(%ebp),%edx
  800907:	89 f3                	mov    %esi,%ebx
  800909:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090c:	89 f0                	mov    %esi,%eax
  80090e:	eb 0f                	jmp    80091f <strncpy+0x23>
		*dst++ = *src;
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	0f b6 0a             	movzbl (%edx),%ecx
  800916:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800919:	80 f9 01             	cmp    $0x1,%cl
  80091c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80091f:	39 d8                	cmp    %ebx,%eax
  800921:	75 ed                	jne    800910 <strncpy+0x14>
	}
	return ret;
}
  800923:	89 f0                	mov    %esi,%eax
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 75 08             	mov    0x8(%ebp),%esi
  800931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800934:	8b 55 10             	mov    0x10(%ebp),%edx
  800937:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800939:	85 d2                	test   %edx,%edx
  80093b:	74 21                	je     80095e <strlcpy+0x35>
  80093d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800941:	89 f2                	mov    %esi,%edx
  800943:	eb 09                	jmp    80094e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	83 c2 01             	add    $0x1,%edx
  80094b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80094e:	39 c2                	cmp    %eax,%edx
  800950:	74 09                	je     80095b <strlcpy+0x32>
  800952:	0f b6 19             	movzbl (%ecx),%ebx
  800955:	84 db                	test   %bl,%bl
  800957:	75 ec                	jne    800945 <strlcpy+0x1c>
  800959:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80095b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80095e:	29 f0                	sub    %esi,%eax
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096d:	eb 06                	jmp    800975 <strcmp+0x11>
		p++, q++;
  80096f:	83 c1 01             	add    $0x1,%ecx
  800972:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800975:	0f b6 01             	movzbl (%ecx),%eax
  800978:	84 c0                	test   %al,%al
  80097a:	74 04                	je     800980 <strcmp+0x1c>
  80097c:	3a 02                	cmp    (%edx),%al
  80097e:	74 ef                	je     80096f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800980:	0f b6 c0             	movzbl %al,%eax
  800983:	0f b6 12             	movzbl (%edx),%edx
  800986:	29 d0                	sub    %edx,%eax
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
  800994:	89 c3                	mov    %eax,%ebx
  800996:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800999:	eb 06                	jmp    8009a1 <strncmp+0x17>
		n--, p++, q++;
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a1:	39 d8                	cmp    %ebx,%eax
  8009a3:	74 18                	je     8009bd <strncmp+0x33>
  8009a5:	0f b6 08             	movzbl (%eax),%ecx
  8009a8:	84 c9                	test   %cl,%cl
  8009aa:	74 04                	je     8009b0 <strncmp+0x26>
  8009ac:	3a 0a                	cmp    (%edx),%cl
  8009ae:	74 eb                	je     80099b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b0:	0f b6 00             	movzbl (%eax),%eax
  8009b3:	0f b6 12             	movzbl (%edx),%edx
  8009b6:	29 d0                	sub    %edx,%eax
}
  8009b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    
		return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c2:	eb f4                	jmp    8009b8 <strncmp+0x2e>

008009c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ce:	eb 03                	jmp    8009d3 <strchr+0xf>
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	0f b6 10             	movzbl (%eax),%edx
  8009d6:	84 d2                	test   %dl,%dl
  8009d8:	74 06                	je     8009e0 <strchr+0x1c>
		if (*s == c)
  8009da:	38 ca                	cmp    %cl,%dl
  8009dc:	75 f2                	jne    8009d0 <strchr+0xc>
  8009de:	eb 05                	jmp    8009e5 <strchr+0x21>
			return (char *) s;
	return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	74 09                	je     800a01 <strfind+0x1a>
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	74 05                	je     800a01 <strfind+0x1a>
	for (; *s; s++)
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	eb f0                	jmp    8009f1 <strfind+0xa>
			break;
	return (char *) s;
}
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	57                   	push   %edi
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0f:	85 c9                	test   %ecx,%ecx
  800a11:	74 2f                	je     800a42 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a13:	89 f8                	mov    %edi,%eax
  800a15:	09 c8                	or     %ecx,%eax
  800a17:	a8 03                	test   $0x3,%al
  800a19:	75 21                	jne    800a3c <memset+0x39>
		c &= 0xFF;
  800a1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1f:	89 d0                	mov    %edx,%eax
  800a21:	c1 e0 08             	shl    $0x8,%eax
  800a24:	89 d3                	mov    %edx,%ebx
  800a26:	c1 e3 18             	shl    $0x18,%ebx
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 10             	shl    $0x10,%esi
  800a2e:	09 f3                	or     %esi,%ebx
  800a30:	09 da                	or     %ebx,%edx
  800a32:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a34:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a37:	fc                   	cld    
  800a38:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3a:	eb 06                	jmp    800a42 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	fc                   	cld    
  800a40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a42:	89 f8                	mov    %edi,%eax
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a57:	39 c6                	cmp    %eax,%esi
  800a59:	73 32                	jae    800a8d <memmove+0x44>
  800a5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5e:	39 c2                	cmp    %eax,%edx
  800a60:	76 2b                	jbe    800a8d <memmove+0x44>
		s += n;
		d += n;
  800a62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a65:	89 d6                	mov    %edx,%esi
  800a67:	09 fe                	or     %edi,%esi
  800a69:	09 ce                	or     %ecx,%esi
  800a6b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a71:	75 0e                	jne    800a81 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a73:	83 ef 04             	sub    $0x4,%edi
  800a76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a79:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7c:	fd                   	std    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 09                	jmp    800a8a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a81:	83 ef 01             	sub    $0x1,%edi
  800a84:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a87:	fd                   	std    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8a:	fc                   	cld    
  800a8b:	eb 1a                	jmp    800aa7 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8d:	89 f2                	mov    %esi,%edx
  800a8f:	09 c2                	or     %eax,%edx
  800a91:	09 ca                	or     %ecx,%edx
  800a93:	f6 c2 03             	test   $0x3,%dl
  800a96:	75 0a                	jne    800aa2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a98:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9b:	89 c7                	mov    %eax,%edi
  800a9d:	fc                   	cld    
  800a9e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa0:	eb 05                	jmp    800aa7 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab1:	ff 75 10             	push   0x10(%ebp)
  800ab4:	ff 75 0c             	push   0xc(%ebp)
  800ab7:	ff 75 08             	push   0x8(%ebp)
  800aba:	e8 8a ff ff ff       	call   800a49 <memmove>
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acc:	89 c6                	mov    %eax,%esi
  800ace:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	eb 06                	jmp    800ad9 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ad9:	39 f0                	cmp    %esi,%eax
  800adb:	74 14                	je     800af1 <memcmp+0x30>
		if (*s1 != *s2)
  800add:	0f b6 08             	movzbl (%eax),%ecx
  800ae0:	0f b6 1a             	movzbl (%edx),%ebx
  800ae3:	38 d9                	cmp    %bl,%cl
  800ae5:	74 ec                	je     800ad3 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ae7:	0f b6 c1             	movzbl %cl,%eax
  800aea:	0f b6 db             	movzbl %bl,%ebx
  800aed:	29 d8                	sub    %ebx,%eax
  800aef:	eb 05                	jmp    800af6 <memcmp+0x35>
	}

	return 0;
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b03:	89 c2                	mov    %eax,%edx
  800b05:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b08:	eb 03                	jmp    800b0d <memfind+0x13>
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	39 d0                	cmp    %edx,%eax
  800b0f:	73 04                	jae    800b15 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b11:	38 08                	cmp    %cl,(%eax)
  800b13:	75 f5                	jne    800b0a <memfind+0x10>
			break;
	return (void *) s;
}
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b23:	eb 03                	jmp    800b28 <strtol+0x11>
		s++;
  800b25:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b28:	0f b6 02             	movzbl (%edx),%eax
  800b2b:	3c 20                	cmp    $0x20,%al
  800b2d:	74 f6                	je     800b25 <strtol+0xe>
  800b2f:	3c 09                	cmp    $0x9,%al
  800b31:	74 f2                	je     800b25 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b33:	3c 2b                	cmp    $0x2b,%al
  800b35:	74 2a                	je     800b61 <strtol+0x4a>
	int neg = 0;
  800b37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b3c:	3c 2d                	cmp    $0x2d,%al
  800b3e:	74 2b                	je     800b6b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b46:	75 0f                	jne    800b57 <strtol+0x40>
  800b48:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4b:	74 28                	je     800b75 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4d:	85 db                	test   %ebx,%ebx
  800b4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b54:	0f 44 d8             	cmove  %eax,%ebx
  800b57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5f:	eb 46                	jmp    800ba7 <strtol+0x90>
		s++;
  800b61:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b64:	bf 00 00 00 00       	mov    $0x0,%edi
  800b69:	eb d5                	jmp    800b40 <strtol+0x29>
		s++, neg = 1;
  800b6b:	83 c2 01             	add    $0x1,%edx
  800b6e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b73:	eb cb                	jmp    800b40 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b75:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b79:	74 0e                	je     800b89 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b7b:	85 db                	test   %ebx,%ebx
  800b7d:	75 d8                	jne    800b57 <strtol+0x40>
		s++, base = 8;
  800b7f:	83 c2 01             	add    $0x1,%edx
  800b82:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b87:	eb ce                	jmp    800b57 <strtol+0x40>
		s += 2, base = 16;
  800b89:	83 c2 02             	add    $0x2,%edx
  800b8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b91:	eb c4                	jmp    800b57 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b93:	0f be c0             	movsbl %al,%eax
  800b96:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b99:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b9c:	7d 3a                	jge    800bd8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ba5:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ba7:	0f b6 02             	movzbl (%edx),%eax
  800baa:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bad:	89 f3                	mov    %esi,%ebx
  800baf:	80 fb 09             	cmp    $0x9,%bl
  800bb2:	76 df                	jbe    800b93 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bb4:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bb7:	89 f3                	mov    %esi,%ebx
  800bb9:	80 fb 19             	cmp    $0x19,%bl
  800bbc:	77 08                	ja     800bc6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bbe:	0f be c0             	movsbl %al,%eax
  800bc1:	83 e8 57             	sub    $0x57,%eax
  800bc4:	eb d3                	jmp    800b99 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bc6:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 08                	ja     800bd8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bd0:	0f be c0             	movsbl %al,%eax
  800bd3:	83 e8 37             	sub    $0x37,%eax
  800bd6:	eb c1                	jmp    800b99 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdc:	74 05                	je     800be3 <strtol+0xcc>
		*endptr = (char *) s;
  800bde:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800be3:	89 c8                	mov    %ecx,%eax
  800be5:	f7 d8                	neg    %eax
  800be7:	85 ff                	test   %edi,%edi
  800be9:	0f 45 c8             	cmovne %eax,%ecx
}
  800bec:	89 c8                	mov    %ecx,%eax
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    
  800bf3:	66 90                	xchg   %ax,%ax
  800bf5:	66 90                	xchg   %ax,%ax
  800bf7:	66 90                	xchg   %ax,%ax
  800bf9:	66 90                	xchg   %ax,%ax
  800bfb:	66 90                	xchg   %ax,%ax
  800bfd:	66 90                	xchg   %ax,%ax
  800bff:	90                   	nop

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
