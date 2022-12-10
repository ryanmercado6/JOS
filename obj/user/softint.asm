
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	53                   	push   %ebx
  80003a:	83 ec 04             	sub    $0x4,%esp
  80003d:	e8 3b 00 00 00       	call   80007d <__x86.get_pc_thunk.bx>
  800042:	81 c3 be 1f 00 00    	add    $0x1fbe,%ebx
  800048:	8b 45 08             	mov    0x8(%ebp),%eax
  80004b:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  80004e:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  800054:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	7e 08                	jle    800066 <libmain+0x30>
		binaryname = argv[0];
  80005e:	8b 0a                	mov    (%edx),%ecx
  800060:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	52                   	push   %edx
  80006a:	50                   	push   %eax
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0c 00 00 00       	call   800081 <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <__x86.get_pc_thunk.bx>:
  80007d:	8b 1c 24             	mov    (%esp),%ebx
  800080:	c3                   	ret    

00800081 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	53                   	push   %ebx
  800085:	83 ec 10             	sub    $0x10,%esp
  800088:	e8 f0 ff ff ff       	call   80007d <__x86.get_pc_thunk.bx>
  80008d:	81 c3 73 1f 00 00    	add    $0x1f73,%ebx
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 45 00 00 00       	call   8000df <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 1c             	sub    $0x1c,%esp
  8000e8:	e8 66 00 00 00       	call   800153 <__x86.get_pc_thunk.ax>
  8000ed:	05 13 1f 00 00       	add    $0x1f13,%eax
  8000f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	b8 03 00 00 00       	mov    $0x3,%eax
  800102:	89 cb                	mov    %ecx,%ebx
  800104:	89 cf                	mov    %ecx,%edi
  800106:	89 ce                	mov    %ecx,%esi
  800108:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010a:	85 c0                	test   %eax,%eax
  80010c:	7f 08                	jg     800116 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	50                   	push   %eax
  80011a:	6a 03                	push   $0x3
  80011c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80011f:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  800125:	50                   	push   %eax
  800126:	6a 23                	push   $0x23
  800128:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 23 00 00 00       	call   800157 <_panic>

00800134 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 02 00 00 00       	mov    $0x2,%eax
  800144:	89 d1                	mov    %edx,%ecx
  800146:	89 d3                	mov    %edx,%ebx
  800148:	89 d7                	mov    %edx,%edi
  80014a:	89 d6                	mov    %edx,%esi
  80014c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <__x86.get_pc_thunk.ax>:
  800153:	8b 04 24             	mov    (%esp),%eax
  800156:	c3                   	ret    

00800157 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 0c             	sub    $0xc,%esp
  800160:	e8 18 ff ff ff       	call   80007d <__x86.get_pc_thunk.bx>
  800165:	81 c3 9b 1e 00 00    	add    $0x1e9b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800174:	8b 38                	mov    (%eax),%edi
  800176:	e8 b9 ff ff ff       	call   800134 <sys_getenvid>
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	ff 75 0c             	push   0xc(%ebp)
  800181:	ff 75 08             	push   0x8(%ebp)
  800184:	57                   	push   %edi
  800185:	50                   	push   %eax
  800186:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  80018c:	50                   	push   %eax
  80018d:	e8 d1 00 00 00       	call   800263 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800192:	83 c4 18             	add    $0x18,%esp
  800195:	56                   	push   %esi
  800196:	ff 75 10             	push   0x10(%ebp)
  800199:	e8 63 00 00 00       	call   800201 <vcprintf>
	cprintf("\n");
  80019e:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001a4:	89 04 24             	mov    %eax,(%esp)
  8001a7:	e8 b7 00 00 00       	call   800263 <cprintf>
  8001ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x58>

008001b2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 c1 fe ff ff       	call   80007d <__x86.get_pc_thunk.bx>
  8001bc:	81 c3 44 1e 00 00    	add    $0x1e44,%ebx
  8001c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c5:	8b 16                	mov    (%esi),%edx
  8001c7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ca:	89 06                	mov    %eax,(%esi)
  8001cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cf:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d8:	74 0b                	je     8001e5 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001da:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	68 ff 00 00 00       	push   $0xff
  8001ed:	8d 46 08             	lea    0x8(%esi),%eax
  8001f0:	50                   	push   %eax
  8001f1:	e8 ac fe ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8001f6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001fc:	83 c4 10             	add    $0x10,%esp
  8001ff:	eb d9                	jmp    8001da <putch+0x28>

00800201 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	53                   	push   %ebx
  800205:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020b:	e8 6d fe ff ff       	call   80007d <__x86.get_pc_thunk.bx>
  800210:	81 c3 f0 1d 00 00    	add    $0x1df0,%ebx
	struct printbuf b;

	b.idx = 0;
  800216:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021d:	00 00 00 
	b.cnt = 0;
  800220:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800227:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022a:	ff 75 0c             	push   0xc(%ebp)
  80022d:	ff 75 08             	push   0x8(%ebp)
  800230:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800236:	50                   	push   %eax
  800237:	8d 83 b2 e1 ff ff    	lea    -0x1e4e(%ebx),%eax
  80023d:	50                   	push   %eax
  80023e:	e8 2c 01 00 00       	call   80036f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800243:	83 c4 08             	add    $0x8,%esp
  800246:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80024c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800252:	50                   	push   %eax
  800253:	e8 4a fe ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800258:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800261:	c9                   	leave  
  800262:	c3                   	ret    

00800263 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800269:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 08             	push   0x8(%ebp)
  800270:	e8 8c ff ff ff       	call   800201 <vcprintf>
	va_end(ap);

	return cnt;
}
  800275:	c9                   	leave  
  800276:	c3                   	ret    

00800277 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 2c             	sub    $0x2c,%esp
  800280:	e8 cf 05 00 00       	call   800854 <__x86.get_pc_thunk.cx>
  800285:	81 c1 7b 1d 00 00    	add    $0x1d7b,%ecx
  80028b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028e:	89 c7                	mov    %eax,%edi
  800290:	89 d6                	mov    %edx,%esi
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	8b 55 0c             	mov    0xc(%ebp),%edx
  800298:	89 d1                	mov    %edx,%ecx
  80029a:	89 c2                	mov    %eax,%edx
  80029c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b2:	39 c2                	cmp    %eax,%edx
  8002b4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b7:	72 41                	jb     8002fa <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b9:	83 ec 0c             	sub    $0xc,%esp
  8002bc:	ff 75 18             	push   0x18(%ebp)
  8002bf:	83 eb 01             	sub    $0x1,%ebx
  8002c2:	53                   	push   %ebx
  8002c3:	50                   	push   %eax
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	ff 75 e4             	push   -0x1c(%ebp)
  8002ca:	ff 75 e0             	push   -0x20(%ebp)
  8002cd:	ff 75 d4             	push   -0x2c(%ebp)
  8002d0:	ff 75 d0             	push   -0x30(%ebp)
  8002d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d6:	e8 05 09 00 00       	call   800be0 <__udivdi3>
  8002db:	83 c4 18             	add    $0x18,%esp
  8002de:	52                   	push   %edx
  8002df:	50                   	push   %eax
  8002e0:	89 f2                	mov    %esi,%edx
  8002e2:	89 f8                	mov    %edi,%eax
  8002e4:	e8 8e ff ff ff       	call   800277 <printnum>
  8002e9:	83 c4 20             	add    $0x20,%esp
  8002ec:	eb 13                	jmp    800301 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ee:	83 ec 08             	sub    $0x8,%esp
  8002f1:	56                   	push   %esi
  8002f2:	ff 75 18             	push   0x18(%ebp)
  8002f5:	ff d7                	call   *%edi
  8002f7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002fa:	83 eb 01             	sub    $0x1,%ebx
  8002fd:	85 db                	test   %ebx,%ebx
  8002ff:	7f ed                	jg     8002ee <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800301:	83 ec 08             	sub    $0x8,%esp
  800304:	56                   	push   %esi
  800305:	83 ec 04             	sub    $0x4,%esp
  800308:	ff 75 e4             	push   -0x1c(%ebp)
  80030b:	ff 75 e0             	push   -0x20(%ebp)
  80030e:	ff 75 d4             	push   -0x2c(%ebp)
  800311:	ff 75 d0             	push   -0x30(%ebp)
  800314:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800317:	e8 e4 09 00 00       	call   800d00 <__umoddi3>
  80031c:	83 c4 14             	add    $0x14,%esp
  80031f:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  800326:	ff 
  800327:	50                   	push   %eax
  800328:	ff d7                	call   *%edi
}
  80032a:	83 c4 10             	add    $0x10,%esp
  80032d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 0a                	jae    800350 <sprintputch+0x1b>
		*b->buf++ = ch;
  800346:	8d 4a 01             	lea    0x1(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	88 02                	mov    %al,(%edx)
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <printfmt>:
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800358:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035b:	50                   	push   %eax
  80035c:	ff 75 10             	push   0x10(%ebp)
  80035f:	ff 75 0c             	push   0xc(%ebp)
  800362:	ff 75 08             	push   0x8(%ebp)
  800365:	e8 05 00 00 00       	call   80036f <vprintfmt>
}
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <vprintfmt>:
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	57                   	push   %edi
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
  800375:	83 ec 3c             	sub    $0x3c,%esp
  800378:	e8 d6 fd ff ff       	call   800153 <__x86.get_pc_thunk.ax>
  80037d:	05 83 1c 00 00       	add    $0x1c83,%eax
  800382:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800385:	8b 75 08             	mov    0x8(%ebp),%esi
  800388:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038b:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038e:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800394:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800397:	eb 0a                	jmp    8003a3 <vprintfmt+0x34>
			putch(ch, putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	57                   	push   %edi
  80039d:	50                   	push   %eax
  80039e:	ff d6                	call   *%esi
  8003a0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a3:	83 c3 01             	add    $0x1,%ebx
  8003a6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003aa:	83 f8 25             	cmp    $0x25,%eax
  8003ad:	74 0c                	je     8003bb <vprintfmt+0x4c>
			if (ch == '\0')
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	75 e6                	jne    800399 <vprintfmt+0x2a>
}
  8003b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    
		padc = ' ';
  8003bb:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003dc:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e5:	0f b6 13             	movzbl (%ebx),%edx
  8003e8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003eb:	3c 55                	cmp    $0x55,%al
  8003ed:	0f 87 c5 03 00 00    	ja     8007b8 <.L20>
  8003f3:	0f b6 c0             	movzbl %al,%eax
  8003f6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f9:	89 ce                	mov    %ecx,%esi
  8003fb:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  800402:	ff e6                	jmp    *%esi

00800404 <.L66>:
  800404:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800407:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80040b:	eb d2                	jmp    8003df <vprintfmt+0x70>

0080040d <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800410:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800414:	eb c9                	jmp    8003df <vprintfmt+0x70>

00800416 <.L31>:
  800416:	0f b6 d2             	movzbl %dl,%edx
  800419:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80041c:	b8 00 00 00 00       	mov    $0x0,%eax
  800421:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800424:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800427:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042b:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80042e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800431:	83 f9 09             	cmp    $0x9,%ecx
  800434:	77 58                	ja     80048e <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800436:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800439:	eb e9                	jmp    800424 <.L31+0xe>

0080043b <.L34>:
			precision = va_arg(ap, int);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 40 04             	lea    0x4(%eax),%eax
  800449:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80044f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800453:	79 8a                	jns    8003df <vprintfmt+0x70>
				width = precision, precision = -1;
  800455:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800458:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800462:	e9 78 ff ff ff       	jmp    8003df <vprintfmt+0x70>

00800467 <.L33>:
  800467:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80046a:	85 d2                	test   %edx,%edx
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	0f 49 c2             	cmovns %edx,%eax
  800474:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80047a:	e9 60 ff ff ff       	jmp    8003df <vprintfmt+0x70>

0080047f <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800482:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800489:	e9 51 ff ff ff       	jmp    8003df <vprintfmt+0x70>
  80048e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800491:	89 75 08             	mov    %esi,0x8(%ebp)
  800494:	eb b9                	jmp    80044f <.L34+0x14>

00800496 <.L27>:
			lflag++;
  800496:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049d:	e9 3d ff ff ff       	jmp    8003df <vprintfmt+0x70>

008004a2 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	57                   	push   %edi
  8004af:	ff 30                	push   (%eax)
  8004b1:	ff d6                	call   *%esi
			break;
  8004b3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b6:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004b9:	e9 90 02 00 00       	jmp    80074e <.L25+0x45>

008004be <.L28>:
			err = va_arg(ap, int);
  8004be:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	89 d0                	mov    %edx,%eax
  8004cb:	f7 d8                	neg    %eax
  8004cd:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 f8 06             	cmp    $0x6,%eax
  8004d3:	7f 27                	jg     8004fc <.L28+0x3e>
  8004d5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d8:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	74 1d                	je     8004fc <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004df:	52                   	push   %edx
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004e9:	50                   	push   %eax
  8004ea:	57                   	push   %edi
  8004eb:	56                   	push   %esi
  8004ec:	e8 61 fe ff ff       	call   800352 <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f4:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f7:	e9 52 02 00 00       	jmp    80074e <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fc:	50                   	push   %eax
  8004fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800500:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  800506:	50                   	push   %eax
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	e8 44 fe ff ff       	call   800352 <printfmt>
  80050e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800511:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800514:	e9 35 02 00 00       	jmp    80074e <.L25+0x45>

00800519 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 75 08             	mov    0x8(%ebp),%esi
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	83 c0 04             	add    $0x4,%eax
  800522:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80052a:	85 d2                	test   %edx,%edx
  80052c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052f:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  800535:	0f 45 c2             	cmovne %edx,%eax
  800538:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80053b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80053f:	7e 06                	jle    800547 <.L24+0x2e>
  800541:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800545:	75 0d                	jne    800554 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800547:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	03 45 d0             	add    -0x30(%ebp),%eax
  80054f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800552:	eb 58                	jmp    8005ac <.L24+0x93>
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	ff 75 d8             	push   -0x28(%ebp)
  80055a:	ff 75 c8             	push   -0x38(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	e8 0b 03 00 00       	call   800870 <strnlen>
  800565:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800568:	29 c2                	sub    %eax,%edx
  80056a:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800572:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800576:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800579:	eb 0f                	jmp    80058a <.L24+0x71>
					putch(padc, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	57                   	push   %edi
  80057f:	ff 75 d0             	push   -0x30(%ebp)
  800582:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	85 db                	test   %ebx,%ebx
  80058c:	7f ed                	jg     80057b <.L24+0x62>
  80058e:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800591:	85 d2                	test   %edx,%edx
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	0f 49 c2             	cmovns %edx,%eax
  80059b:	29 c2                	sub    %eax,%edx
  80059d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a0:	eb a5                	jmp    800547 <.L24+0x2e>
					putch(ch, putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	57                   	push   %edi
  8005a6:	52                   	push   %edx
  8005a7:	ff d6                	call   *%esi
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005af:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b1:	83 c3 01             	add    $0x1,%ebx
  8005b4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005b8:	0f be d0             	movsbl %al,%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 4b                	je     80060a <.L24+0xf1>
  8005bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c3:	78 06                	js     8005cb <.L24+0xb2>
  8005c5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005c9:	78 1e                	js     8005e9 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005cf:	74 d1                	je     8005a2 <.L24+0x89>
  8005d1:	0f be c0             	movsbl %al,%eax
  8005d4:	83 e8 20             	sub    $0x20,%eax
  8005d7:	83 f8 5e             	cmp    $0x5e,%eax
  8005da:	76 c6                	jbe    8005a2 <.L24+0x89>
					putch('?', putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	57                   	push   %edi
  8005e0:	6a 3f                	push   $0x3f
  8005e2:	ff d6                	call   *%esi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb c3                	jmp    8005ac <.L24+0x93>
  8005e9:	89 cb                	mov    %ecx,%ebx
  8005eb:	eb 0e                	jmp    8005fb <.L24+0xe2>
				putch(' ', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	57                   	push   %edi
  8005f1:	6a 20                	push   $0x20
  8005f3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f5:	83 eb 01             	sub    $0x1,%ebx
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	85 db                	test   %ebx,%ebx
  8005fd:	7f ee                	jg     8005ed <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ff:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
  800605:	e9 44 01 00 00       	jmp    80074e <.L25+0x45>
  80060a:	89 cb                	mov    %ecx,%ebx
  80060c:	eb ed                	jmp    8005fb <.L24+0xe2>

0080060e <.L29>:
	if (lflag >= 2)
  80060e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800611:	8b 75 08             	mov    0x8(%ebp),%esi
  800614:	83 f9 01             	cmp    $0x1,%ecx
  800617:	7f 1b                	jg     800634 <.L29+0x26>
	else if (lflag)
  800619:	85 c9                	test   %ecx,%ecx
  80061b:	74 63                	je     800680 <.L29+0x72>
		return va_arg(*ap, long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 00                	mov    (%eax),%eax
  800622:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800625:	99                   	cltd   
  800626:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 40 04             	lea    0x4(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)
  800632:	eb 17                	jmp    80064b <.L29+0x3d>
		return va_arg(*ap, long long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 50 04             	mov    0x4(%eax),%edx
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 08             	lea    0x8(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80064e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800651:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800656:	85 db                	test   %ebx,%ebx
  800658:	0f 89 d6 00 00 00    	jns    800734 <.L25+0x2b>
				putch('-', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	57                   	push   %edi
  800662:	6a 2d                	push   $0x2d
  800664:	ff d6                	call   *%esi
				num = -(long long) num;
  800666:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800669:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066c:	f7 d9                	neg    %ecx
  80066e:	83 d3 00             	adc    $0x0,%ebx
  800671:	f7 db                	neg    %ebx
  800673:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800676:	ba 0a 00 00 00       	mov    $0xa,%edx
  80067b:	e9 b4 00 00 00       	jmp    800734 <.L25+0x2b>
		return va_arg(*ap, int);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 00                	mov    (%eax),%eax
  800685:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800688:	99                   	cltd   
  800689:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
  800695:	eb b4                	jmp    80064b <.L29+0x3d>

00800697 <.L23>:
	if (lflag >= 2)
  800697:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	83 f9 01             	cmp    $0x1,%ecx
  8006a0:	7f 1b                	jg     8006bd <.L23+0x26>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 2c                	je     8006d2 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 08                	mov    (%eax),%ecx
  8006ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b0:	8d 40 04             	lea    0x4(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006bb:	eb 77                	jmp    800734 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 08                	mov    (%eax),%ecx
  8006c2:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c5:	8d 40 08             	lea    0x8(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d0:	eb 62                	jmp    800734 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 08                	mov    (%eax),%ecx
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006e7:	eb 4b                	jmp    800734 <.L25+0x2b>

008006e9 <.L26>:
			putch('X', putdat);
  8006e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	57                   	push   %edi
  8006f0:	6a 58                	push   $0x58
  8006f2:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f4:	83 c4 08             	add    $0x8,%esp
  8006f7:	57                   	push   %edi
  8006f8:	6a 58                	push   $0x58
  8006fa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fc:	83 c4 08             	add    $0x8,%esp
  8006ff:	57                   	push   %edi
  800700:	6a 58                	push   $0x58
  800702:	ff d6                	call   *%esi
			break;
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 45                	jmp    80074e <.L25+0x45>

00800709 <.L25>:
			putch('0', putdat);
  800709:	8b 75 08             	mov    0x8(%ebp),%esi
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	57                   	push   %edi
  800710:	6a 30                	push   $0x30
  800712:	ff d6                	call   *%esi
			putch('x', putdat);
  800714:	83 c4 08             	add    $0x8,%esp
  800717:	57                   	push   %edi
  800718:	6a 78                	push   $0x78
  80071a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 08                	mov    (%eax),%ecx
  800721:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800726:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072f:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800734:	83 ec 0c             	sub    $0xc,%esp
  800737:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80073b:	50                   	push   %eax
  80073c:	ff 75 d0             	push   -0x30(%ebp)
  80073f:	52                   	push   %edx
  800740:	53                   	push   %ebx
  800741:	51                   	push   %ecx
  800742:	89 fa                	mov    %edi,%edx
  800744:	89 f0                	mov    %esi,%eax
  800746:	e8 2c fb ff ff       	call   800277 <printnum>
			break;
  80074b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80074e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800751:	e9 4d fc ff ff       	jmp    8003a3 <vprintfmt+0x34>

00800756 <.L21>:
	if (lflag >= 2)
  800756:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800759:	8b 75 08             	mov    0x8(%ebp),%esi
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7f 1b                	jg     80077c <.L21+0x26>
	else if (lflag)
  800761:	85 c9                	test   %ecx,%ecx
  800763:	74 2c                	je     800791 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 08                	mov    (%eax),%ecx
  80076a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800775:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80077a:	eb b8                	jmp    800734 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8b 08                	mov    (%eax),%ecx
  800781:	8b 58 04             	mov    0x4(%eax),%ebx
  800784:	8d 40 08             	lea    0x8(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078a:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  80078f:	eb a3                	jmp    800734 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 08                	mov    (%eax),%ecx
  800796:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007a6:	eb 8c                	jmp    800734 <.L25+0x2b>

008007a8 <.L35>:
			putch(ch, putdat);
  8007a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	57                   	push   %edi
  8007af:	6a 25                	push   $0x25
  8007b1:	ff d6                	call   *%esi
			break;
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	eb 96                	jmp    80074e <.L25+0x45>

008007b8 <.L20>:
			putch('%', putdat);
  8007b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	57                   	push   %edi
  8007bf:	6a 25                	push   $0x25
  8007c1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	89 d8                	mov    %ebx,%eax
  8007c8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007cc:	74 05                	je     8007d3 <.L20+0x1b>
  8007ce:	83 e8 01             	sub    $0x1,%eax
  8007d1:	eb f5                	jmp    8007c8 <.L20+0x10>
  8007d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d6:	e9 73 ff ff ff       	jmp    80074e <.L25+0x45>

008007db <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	83 ec 14             	sub    $0x14,%esp
  8007e2:	e8 96 f8 ff ff       	call   80007d <__x86.get_pc_thunk.bx>
  8007e7:	81 c3 19 18 00 00    	add    $0x1819,%ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800804:	85 c0                	test   %eax,%eax
  800806:	74 2b                	je     800833 <vsnprintf+0x58>
  800808:	85 d2                	test   %edx,%edx
  80080a:	7e 27                	jle    800833 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080c:	ff 75 14             	push   0x14(%ebp)
  80080f:	ff 75 10             	push   0x10(%ebp)
  800812:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800815:	50                   	push   %eax
  800816:	8d 83 35 e3 ff ff    	lea    -0x1ccb(%ebx),%eax
  80081c:	50                   	push   %eax
  80081d:	e8 4d fb ff ff       	call   80036f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800822:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800825:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082b:	83 c4 10             	add    $0x10,%esp
}
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    
		return -E_INVAL;
  800833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800838:	eb f4                	jmp    80082e <vsnprintf+0x53>

0080083a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800840:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800843:	50                   	push   %eax
  800844:	ff 75 10             	push   0x10(%ebp)
  800847:	ff 75 0c             	push   0xc(%ebp)
  80084a:	ff 75 08             	push   0x8(%ebp)
  80084d:	e8 89 ff ff ff       	call   8007db <vsnprintf>
	va_end(ap);

	return rc;
}
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <__x86.get_pc_thunk.cx>:
  800854:	8b 0c 24             	mov    (%esp),%ecx
  800857:	c3                   	ret    

00800858 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
  800863:	eb 03                	jmp    800868 <strlen+0x10>
		n++;
  800865:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800868:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086c:	75 f7                	jne    800865 <strlen+0xd>
	return n;
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	eb 03                	jmp    800883 <strnlen+0x13>
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800883:	39 d0                	cmp    %edx,%eax
  800885:	74 08                	je     80088f <strnlen+0x1f>
  800887:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088b:	75 f3                	jne    800880 <strnlen+0x10>
  80088d:	89 c2                	mov    %eax,%edx
	return n;
}
  80088f:	89 d0                	mov    %edx,%eax
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	84 d2                	test   %dl,%dl
  8008ae:	75 f2                	jne    8008a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b0:	89 c8                	mov    %ecx,%eax
  8008b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	83 ec 10             	sub    $0x10,%esp
  8008be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c1:	53                   	push   %ebx
  8008c2:	e8 91 ff ff ff       	call   800858 <strlen>
  8008c7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ca:	ff 75 0c             	push   0xc(%ebp)
  8008cd:	01 d8                	add    %ebx,%eax
  8008cf:	50                   	push   %eax
  8008d0:	e8 be ff ff ff       	call   800893 <strcpy>
	return dst;
}
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e7:	89 f3                	mov    %esi,%ebx
  8008e9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ec:	89 f0                	mov    %esi,%eax
  8008ee:	eb 0f                	jmp    8008ff <strncpy+0x23>
		*dst++ = *src;
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 0a             	movzbl (%edx),%ecx
  8008f6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f9:	80 f9 01             	cmp    $0x1,%cl
  8008fc:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008ff:	39 d8                	cmp    %ebx,%eax
  800901:	75 ed                	jne    8008f0 <strncpy+0x14>
	}
	return ret;
}
  800903:	89 f0                	mov    %esi,%eax
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	56                   	push   %esi
  80090d:	53                   	push   %ebx
  80090e:	8b 75 08             	mov    0x8(%ebp),%esi
  800911:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800914:	8b 55 10             	mov    0x10(%ebp),%edx
  800917:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800919:	85 d2                	test   %edx,%edx
  80091b:	74 21                	je     80093e <strlcpy+0x35>
  80091d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800921:	89 f2                	mov    %esi,%edx
  800923:	eb 09                	jmp    80092e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800925:	83 c1 01             	add    $0x1,%ecx
  800928:	83 c2 01             	add    $0x1,%edx
  80092b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80092e:	39 c2                	cmp    %eax,%edx
  800930:	74 09                	je     80093b <strlcpy+0x32>
  800932:	0f b6 19             	movzbl (%ecx),%ebx
  800935:	84 db                	test   %bl,%bl
  800937:	75 ec                	jne    800925 <strlcpy+0x1c>
  800939:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80093b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093e:	29 f0                	sub    %esi,%eax
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80094d:	eb 06                	jmp    800955 <strcmp+0x11>
		p++, q++;
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800955:	0f b6 01             	movzbl (%ecx),%eax
  800958:	84 c0                	test   %al,%al
  80095a:	74 04                	je     800960 <strcmp+0x1c>
  80095c:	3a 02                	cmp    (%edx),%al
  80095e:	74 ef                	je     80094f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800960:	0f b6 c0             	movzbl %al,%eax
  800963:	0f b6 12             	movzbl (%edx),%edx
  800966:	29 d0                	sub    %edx,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
  800974:	89 c3                	mov    %eax,%ebx
  800976:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800979:	eb 06                	jmp    800981 <strncmp+0x17>
		n--, p++, q++;
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800981:	39 d8                	cmp    %ebx,%eax
  800983:	74 18                	je     80099d <strncmp+0x33>
  800985:	0f b6 08             	movzbl (%eax),%ecx
  800988:	84 c9                	test   %cl,%cl
  80098a:	74 04                	je     800990 <strncmp+0x26>
  80098c:	3a 0a                	cmp    (%edx),%cl
  80098e:	74 eb                	je     80097b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800990:	0f b6 00             	movzbl (%eax),%eax
  800993:	0f b6 12             	movzbl (%edx),%edx
  800996:	29 d0                	sub    %edx,%eax
}
  800998:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    
		return 0;
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a2:	eb f4                	jmp    800998 <strncmp+0x2e>

008009a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ae:	eb 03                	jmp    8009b3 <strchr+0xf>
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	0f b6 10             	movzbl (%eax),%edx
  8009b6:	84 d2                	test   %dl,%dl
  8009b8:	74 06                	je     8009c0 <strchr+0x1c>
		if (*s == c)
  8009ba:	38 ca                	cmp    %cl,%dl
  8009bc:	75 f2                	jne    8009b0 <strchr+0xc>
  8009be:	eb 05                	jmp    8009c5 <strchr+0x21>
			return (char *) s;
	return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 09                	je     8009e1 <strfind+0x1a>
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 05                	je     8009e1 <strfind+0x1a>
	for (; *s; s++)
  8009dc:	83 c0 01             	add    $0x1,%eax
  8009df:	eb f0                	jmp    8009d1 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ef:	85 c9                	test   %ecx,%ecx
  8009f1:	74 2f                	je     800a22 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f3:	89 f8                	mov    %edi,%eax
  8009f5:	09 c8                	or     %ecx,%eax
  8009f7:	a8 03                	test   $0x3,%al
  8009f9:	75 21                	jne    800a1c <memset+0x39>
		c &= 0xFF;
  8009fb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d0                	mov    %edx,%eax
  800a01:	c1 e0 08             	shl    $0x8,%eax
  800a04:	89 d3                	mov    %edx,%ebx
  800a06:	c1 e3 18             	shl    $0x18,%ebx
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	c1 e6 10             	shl    $0x10,%esi
  800a0e:	09 f3                	or     %esi,%ebx
  800a10:	09 da                	or     %ebx,%edx
  800a12:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a14:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a17:	fc                   	cld    
  800a18:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1a:	eb 06                	jmp    800a22 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	fc                   	cld    
  800a20:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a22:	89 f8                	mov    %edi,%eax
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a37:	39 c6                	cmp    %eax,%esi
  800a39:	73 32                	jae    800a6d <memmove+0x44>
  800a3b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3e:	39 c2                	cmp    %eax,%edx
  800a40:	76 2b                	jbe    800a6d <memmove+0x44>
		s += n;
		d += n;
  800a42:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a45:	89 d6                	mov    %edx,%esi
  800a47:	09 fe                	or     %edi,%esi
  800a49:	09 ce                	or     %ecx,%esi
  800a4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a51:	75 0e                	jne    800a61 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1a                	jmp    800a87 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	09 ca                	or     %ecx,%edx
  800a73:	f6 c2 03             	test   $0x3,%dl
  800a76:	75 0a                	jne    800a82 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	fc                   	cld    
  800a7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a80:	eb 05                	jmp    800a87 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a82:	89 c7                	mov    %eax,%edi
  800a84:	fc                   	cld    
  800a85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	push   0x10(%ebp)
  800a94:	ff 75 0c             	push   0xc(%ebp)
  800a97:	ff 75 08             	push   0x8(%ebp)
  800a9a:	e8 8a ff ff ff       	call   800a29 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 06                	jmp    800ab9 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ab9:	39 f0                	cmp    %esi,%eax
  800abb:	74 14                	je     800ad1 <memcmp+0x30>
		if (*s1 != *s2)
  800abd:	0f b6 08             	movzbl (%eax),%ecx
  800ac0:	0f b6 1a             	movzbl (%edx),%ebx
  800ac3:	38 d9                	cmp    %bl,%cl
  800ac5:	74 ec                	je     800ab3 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800ac7:	0f b6 c1             	movzbl %cl,%eax
  800aca:	0f b6 db             	movzbl %bl,%ebx
  800acd:	29 d8                	sub    %ebx,%eax
  800acf:	eb 05                	jmp    800ad6 <memcmp+0x35>
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae3:	89 c2                	mov    %eax,%edx
  800ae5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae8:	eb 03                	jmp    800aed <memfind+0x13>
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	73 04                	jae    800af5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af1:	38 08                	cmp    %cl,(%eax)
  800af3:	75 f5                	jne    800aea <memfind+0x10>
			break;
	return (void *) s;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b03:	eb 03                	jmp    800b08 <strtol+0x11>
		s++;
  800b05:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b08:	0f b6 02             	movzbl (%edx),%eax
  800b0b:	3c 20                	cmp    $0x20,%al
  800b0d:	74 f6                	je     800b05 <strtol+0xe>
  800b0f:	3c 09                	cmp    $0x9,%al
  800b11:	74 f2                	je     800b05 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b13:	3c 2b                	cmp    $0x2b,%al
  800b15:	74 2a                	je     800b41 <strtol+0x4a>
	int neg = 0;
  800b17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1c:	3c 2d                	cmp    $0x2d,%al
  800b1e:	74 2b                	je     800b4b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b26:	75 0f                	jne    800b37 <strtol+0x40>
  800b28:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2b:	74 28                	je     800b55 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b34:	0f 44 d8             	cmove  %eax,%ebx
  800b37:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b3f:	eb 46                	jmp    800b87 <strtol+0x90>
		s++;
  800b41:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b44:	bf 00 00 00 00       	mov    $0x0,%edi
  800b49:	eb d5                	jmp    800b20 <strtol+0x29>
		s++, neg = 1;
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800b53:	eb cb                	jmp    800b20 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b55:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b59:	74 0e                	je     800b69 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b5b:	85 db                	test   %ebx,%ebx
  800b5d:	75 d8                	jne    800b37 <strtol+0x40>
		s++, base = 8;
  800b5f:	83 c2 01             	add    $0x1,%edx
  800b62:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b67:	eb ce                	jmp    800b37 <strtol+0x40>
		s += 2, base = 16;
  800b69:	83 c2 02             	add    $0x2,%edx
  800b6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b71:	eb c4                	jmp    800b37 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b73:	0f be c0             	movsbl %al,%eax
  800b76:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b79:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b7c:	7d 3a                	jge    800bb8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b85:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b87:	0f b6 02             	movzbl (%edx),%eax
  800b8a:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	80 fb 09             	cmp    $0x9,%bl
  800b92:	76 df                	jbe    800b73 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b94:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b97:	89 f3                	mov    %esi,%ebx
  800b99:	80 fb 19             	cmp    $0x19,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b9e:	0f be c0             	movsbl %al,%eax
  800ba1:	83 e8 57             	sub    $0x57,%eax
  800ba4:	eb d3                	jmp    800b79 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ba6:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ba9:	89 f3                	mov    %esi,%ebx
  800bab:	80 fb 19             	cmp    $0x19,%bl
  800bae:	77 08                	ja     800bb8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb0:	0f be c0             	movsbl %al,%eax
  800bb3:	83 e8 37             	sub    $0x37,%eax
  800bb6:	eb c1                	jmp    800b79 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bb8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbc:	74 05                	je     800bc3 <strtol+0xcc>
		*endptr = (char *) s;
  800bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc1:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc3:	89 c8                	mov    %ecx,%eax
  800bc5:	f7 d8                	neg    %eax
  800bc7:	85 ff                	test   %edi,%edi
  800bc9:	0f 45 c8             	cmovne %eax,%ecx
}
  800bcc:	89 c8                	mov    %ecx,%eax
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    
  800bd3:	66 90                	xchg   %ax,%ax
  800bd5:	66 90                	xchg   %ax,%ax
  800bd7:	66 90                	xchg   %ax,%ax
  800bd9:	66 90                	xchg   %ax,%ax
  800bdb:	66 90                	xchg   %ax,%ax
  800bdd:	66 90                	xchg   %ax,%ax
  800bdf:	90                   	nop

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
