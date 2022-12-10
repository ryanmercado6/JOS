
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned*)0 = 0;
  800033:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	53                   	push   %ebx
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	e8 3b 00 00 00       	call   800085 <__x86.get_pc_thunk.bx>
  80004a:	81 c3 b6 1f 00 00    	add    $0x1fb6,%ebx
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  800056:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  80005c:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 c0                	test   %eax,%eax
  800064:	7e 08                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800066:	8b 0a                	mov    (%edx),%ecx
  800068:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	52                   	push   %edx
  800072:	50                   	push   %eax
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0c 00 00 00       	call   800089 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800083:	c9                   	leave  
  800084:	c3                   	ret    

00800085 <__x86.get_pc_thunk.bx>:
  800085:	8b 1c 24             	mov    (%esp),%ebx
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	e8 f0 ff ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800095:	81 c3 6b 1f 00 00    	add    $0x1f6b,%ebx
	sys_env_destroy(0);
  80009b:	6a 00                	push   $0x0
  80009d:	e8 45 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 1c             	sub    $0x1c,%esp
  8000f0:	e8 66 00 00 00       	call   80015b <__x86.get_pc_thunk.ax>
  8000f5:	05 0b 1f 00 00       	add    $0x1f0b,%eax
  8000fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800127:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	6a 23                	push   $0x23
  800130:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  800136:	50                   	push   %eax
  800137:	e8 23 00 00 00       	call   80015f <_panic>

0080013c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 02 00 00 00       	mov    $0x2,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <__x86.get_pc_thunk.ax>:
  80015b:	8b 04 24             	mov    (%esp),%eax
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	e8 18 ff ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  80016d:	81 c3 93 1e 00 00    	add    $0x1e93,%ebx
	va_list ap;

	va_start(ap, fmt);
  800173:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800176:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017c:	8b 38                	mov    (%eax),%edi
  80017e:	e8 b9 ff ff ff       	call   80013c <sys_getenvid>
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 0c             	push   0xc(%ebp)
  800189:	ff 75 08             	push   0x8(%ebp)
  80018c:	57                   	push   %edi
  80018d:	50                   	push   %eax
  80018e:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  800194:	50                   	push   %eax
  800195:	e8 d1 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019a:	83 c4 18             	add    $0x18,%esp
  80019d:	56                   	push   %esi
  80019e:	ff 75 10             	push   0x10(%ebp)
  8001a1:	e8 63 00 00 00       	call   800209 <vcprintf>
	cprintf("\n");
  8001a6:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 b7 00 00 00       	call   80026b <cprintf>
  8001b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x58>

008001ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	e8 c1 fe ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  8001c4:	81 c3 3c 1e 00 00    	add    $0x1e3c,%ebx
  8001ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001cd:	8b 16                	mov    (%esi),%edx
  8001cf:	8d 42 01             	lea    0x1(%edx),%eax
  8001d2:	89 06                	mov    %eax,(%esi)
  8001d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d7:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e0:	74 0b                	je     8001ed <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e2:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	68 ff 00 00 00       	push   $0xff
  8001f5:	8d 46 08             	lea    0x8(%esi),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 ac fe ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8001fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	eb d9                	jmp    8001e2 <putch+0x28>

00800209 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	53                   	push   %ebx
  80020d:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800213:	e8 6d fe ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800218:	81 c3 e8 1d 00 00    	add    $0x1de8,%ebx
	struct printbuf b;

	b.idx = 0;
  80021e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800225:	00 00 00 
	b.cnt = 0;
  800228:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800232:	ff 75 0c             	push   0xc(%ebp)
  800235:	ff 75 08             	push   0x8(%ebp)
  800238:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023e:	50                   	push   %eax
  80023f:	8d 83 ba e1 ff ff    	lea    -0x1e46(%ebx),%eax
  800245:	50                   	push   %eax
  800246:	e8 2c 01 00 00       	call   800377 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	83 c4 08             	add    $0x8,%esp
  80024e:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800254:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025a:	50                   	push   %eax
  80025b:	e8 4a fe ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 08             	push   0x8(%ebp)
  800278:	e8 8c ff ff ff       	call   800209 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
  800288:	e8 cf 05 00 00       	call   80085c <__x86.get_pc_thunk.cx>
  80028d:	81 c1 73 1d 00 00    	add    $0x1d73,%ecx
  800293:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800296:	89 c7                	mov    %eax,%edi
  800298:	89 d6                	mov    %edx,%esi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a0:	89 d1                	mov    %edx,%ecx
  8002a2:	89 c2                	mov    %eax,%edx
  8002a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ba:	39 c2                	cmp    %eax,%edx
  8002bc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002bf:	72 41                	jb     800302 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c1:	83 ec 0c             	sub    $0xc,%esp
  8002c4:	ff 75 18             	push   0x18(%ebp)
  8002c7:	83 eb 01             	sub    $0x1,%ebx
  8002ca:	53                   	push   %ebx
  8002cb:	50                   	push   %eax
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	ff 75 e4             	push   -0x1c(%ebp)
  8002d2:	ff 75 e0             	push   -0x20(%ebp)
  8002d5:	ff 75 d4             	push   -0x2c(%ebp)
  8002d8:	ff 75 d0             	push   -0x30(%ebp)
  8002db:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002de:	e8 fd 08 00 00       	call   800be0 <__udivdi3>
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	52                   	push   %edx
  8002e7:	50                   	push   %eax
  8002e8:	89 f2                	mov    %esi,%edx
  8002ea:	89 f8                	mov    %edi,%eax
  8002ec:	e8 8e ff ff ff       	call   80027f <printnum>
  8002f1:	83 c4 20             	add    $0x20,%esp
  8002f4:	eb 13                	jmp    800309 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	56                   	push   %esi
  8002fa:	ff 75 18             	push   0x18(%ebp)
  8002fd:	ff d7                	call   *%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800302:	83 eb 01             	sub    $0x1,%ebx
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f ed                	jg     8002f6 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	ff 75 e4             	push   -0x1c(%ebp)
  800313:	ff 75 e0             	push   -0x20(%ebp)
  800316:	ff 75 d4             	push   -0x2c(%ebp)
  800319:	ff 75 d0             	push   -0x30(%ebp)
  80031c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80031f:	e8 dc 09 00 00       	call   800d00 <__umoddi3>
  800324:	83 c4 14             	add    $0x14,%esp
  800327:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  80032e:	ff 
  80032f:	50                   	push   %eax
  800330:	ff d7                	call   *%edi
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800343:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800347:	8b 10                	mov    (%eax),%edx
  800349:	3b 50 04             	cmp    0x4(%eax),%edx
  80034c:	73 0a                	jae    800358 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	88 02                	mov    %al,(%edx)
}
  800358:	5d                   	pop    %ebp
  800359:	c3                   	ret    

0080035a <printfmt>:
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800360:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800363:	50                   	push   %eax
  800364:	ff 75 10             	push   0x10(%ebp)
  800367:	ff 75 0c             	push   0xc(%ebp)
  80036a:	ff 75 08             	push   0x8(%ebp)
  80036d:	e8 05 00 00 00       	call   800377 <vprintfmt>
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	c9                   	leave  
  800376:	c3                   	ret    

00800377 <vprintfmt>:
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	83 ec 3c             	sub    $0x3c,%esp
  800380:	e8 d6 fd ff ff       	call   80015b <__x86.get_pc_thunk.ax>
  800385:	05 7b 1c 00 00       	add    $0x1c7b,%eax
  80038a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038d:	8b 75 08             	mov    0x8(%ebp),%esi
  800390:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800393:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800396:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  80039c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80039f:	eb 0a                	jmp    8003ab <vprintfmt+0x34>
			putch(ch, putdat);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	57                   	push   %edi
  8003a5:	50                   	push   %eax
  8003a6:	ff d6                	call   *%esi
  8003a8:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ab:	83 c3 01             	add    $0x1,%ebx
  8003ae:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003b2:	83 f8 25             	cmp    $0x25,%eax
  8003b5:	74 0c                	je     8003c3 <vprintfmt+0x4c>
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	75 e6                	jne    8003a1 <vprintfmt+0x2a>
}
  8003bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003be:	5b                   	pop    %ebx
  8003bf:	5e                   	pop    %esi
  8003c0:	5f                   	pop    %edi
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    
		padc = ' ';
  8003c3:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e1:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e4:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8d 43 01             	lea    0x1(%ebx),%eax
  8003ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ed:	0f b6 13             	movzbl (%ebx),%edx
  8003f0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f3:	3c 55                	cmp    $0x55,%al
  8003f5:	0f 87 c5 03 00 00    	ja     8007c0 <.L20>
  8003fb:	0f b6 c0             	movzbl %al,%eax
  8003fe:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800401:	89 ce                	mov    %ecx,%esi
  800403:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  80040a:	ff e6                	jmp    *%esi

0080040c <.L66>:
  80040c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80040f:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800413:	eb d2                	jmp    8003e7 <vprintfmt+0x70>

00800415 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800418:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80041c:	eb c9                	jmp    8003e7 <vprintfmt+0x70>

0080041e <.L31>:
  80041e:	0f b6 d2             	movzbl %dl,%edx
  800421:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800424:	b8 00 00 00 00       	mov    $0x0,%eax
  800429:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80042c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800433:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800436:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800439:	83 f9 09             	cmp    $0x9,%ecx
  80043c:	77 58                	ja     800496 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80043e:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800441:	eb e9                	jmp    80042c <.L31+0xe>

00800443 <.L34>:
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8b 00                	mov    (%eax),%eax
  800448:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 40 04             	lea    0x4(%eax),%eax
  800451:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800457:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80045b:	79 8a                	jns    8003e7 <vprintfmt+0x70>
				width = precision, precision = -1;
  80045d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800460:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800463:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80046a:	e9 78 ff ff ff       	jmp    8003e7 <vprintfmt+0x70>

0080046f <.L33>:
  80046f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800472:	85 d2                	test   %edx,%edx
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	0f 49 c2             	cmovns %edx,%eax
  80047c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800482:	e9 60 ff ff ff       	jmp    8003e7 <vprintfmt+0x70>

00800487 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80048a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800491:	e9 51 ff ff ff       	jmp    8003e7 <vprintfmt+0x70>
  800496:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800499:	89 75 08             	mov    %esi,0x8(%ebp)
  80049c:	eb b9                	jmp    800457 <.L34+0x14>

0080049e <.L27>:
			lflag++;
  80049e:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a5:	e9 3d ff ff ff       	jmp    8003e7 <vprintfmt+0x70>

008004aa <.L30>:
			putch(va_arg(ap, int), putdat);
  8004aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 58 04             	lea    0x4(%eax),%ebx
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	57                   	push   %edi
  8004b7:	ff 30                	push   (%eax)
  8004b9:	ff d6                	call   *%esi
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004be:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004c1:	e9 90 02 00 00       	jmp    800756 <.L25+0x45>

008004c6 <.L28>:
			err = va_arg(ap, int);
  8004c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cf:	8b 10                	mov    (%eax),%edx
  8004d1:	89 d0                	mov    %edx,%eax
  8004d3:	f7 d8                	neg    %eax
  8004d5:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d8:	83 f8 06             	cmp    $0x6,%eax
  8004db:	7f 27                	jg     800504 <.L28+0x3e>
  8004dd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e0:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	74 1d                	je     800504 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004e7:	52                   	push   %edx
  8004e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004eb:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004f1:	50                   	push   %eax
  8004f2:	57                   	push   %edi
  8004f3:	56                   	push   %esi
  8004f4:	e8 61 fe ff ff       	call   80035a <printfmt>
  8004f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fc:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004ff:	e9 52 02 00 00       	jmp    800756 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800504:	50                   	push   %eax
  800505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800508:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  80050e:	50                   	push   %eax
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	e8 44 fe ff ff       	call   80035a <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800519:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 35 02 00 00       	jmp    800756 <.L25+0x45>

00800521 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800521:	8b 75 08             	mov    0x8(%ebp),%esi
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	83 c0 04             	add    $0x4,%eax
  80052a:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800532:	85 d2                	test   %edx,%edx
  800534:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800537:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  80053d:	0f 45 c2             	cmovne %edx,%eax
  800540:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800543:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800547:	7e 06                	jle    80054f <.L24+0x2e>
  800549:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80054d:	75 0d                	jne    80055c <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800552:	89 c3                	mov    %eax,%ebx
  800554:	03 45 d0             	add    -0x30(%ebp),%eax
  800557:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80055a:	eb 58                	jmp    8005b4 <.L24+0x93>
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	ff 75 d8             	push   -0x28(%ebp)
  800562:	ff 75 c8             	push   -0x38(%ebp)
  800565:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800568:	e8 0b 03 00 00       	call   800878 <strnlen>
  80056d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800570:	29 c2                	sub    %eax,%edx
  800572:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80057a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80057e:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <.L24+0x71>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	57                   	push   %edi
  800587:	ff 75 d0             	push   -0x30(%ebp)
  80058a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 eb 01             	sub    $0x1,%ebx
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 db                	test   %ebx,%ebx
  800594:	7f ed                	jg     800583 <.L24+0x62>
  800596:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800599:	85 d2                	test   %edx,%edx
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	0f 49 c2             	cmovns %edx,%eax
  8005a3:	29 c2                	sub    %eax,%edx
  8005a5:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a8:	eb a5                	jmp    80054f <.L24+0x2e>
					putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	57                   	push   %edi
  8005ae:	52                   	push   %edx
  8005af:	ff d6                	call   *%esi
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b7:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	83 c3 01             	add    $0x1,%ebx
  8005bc:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005c0:	0f be d0             	movsbl %al,%edx
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	74 4b                	je     800612 <.L24+0xf1>
  8005c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005cb:	78 06                	js     8005d3 <.L24+0xb2>
  8005cd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005d1:	78 1e                	js     8005f1 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d7:	74 d1                	je     8005aa <.L24+0x89>
  8005d9:	0f be c0             	movsbl %al,%eax
  8005dc:	83 e8 20             	sub    $0x20,%eax
  8005df:	83 f8 5e             	cmp    $0x5e,%eax
  8005e2:	76 c6                	jbe    8005aa <.L24+0x89>
					putch('?', putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	57                   	push   %edi
  8005e8:	6a 3f                	push   $0x3f
  8005ea:	ff d6                	call   *%esi
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	eb c3                	jmp    8005b4 <.L24+0x93>
  8005f1:	89 cb                	mov    %ecx,%ebx
  8005f3:	eb 0e                	jmp    800603 <.L24+0xe2>
				putch(' ', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	57                   	push   %edi
  8005f9:	6a 20                	push   $0x20
  8005fb:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005fd:	83 eb 01             	sub    $0x1,%ebx
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	85 db                	test   %ebx,%ebx
  800605:	7f ee                	jg     8005f5 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800607:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
  80060d:	e9 44 01 00 00       	jmp    800756 <.L25+0x45>
  800612:	89 cb                	mov    %ecx,%ebx
  800614:	eb ed                	jmp    800603 <.L24+0xe2>

00800616 <.L29>:
	if (lflag >= 2)
  800616:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800619:	8b 75 08             	mov    0x8(%ebp),%esi
  80061c:	83 f9 01             	cmp    $0x1,%ecx
  80061f:	7f 1b                	jg     80063c <.L29+0x26>
	else if (lflag)
  800621:	85 c9                	test   %ecx,%ecx
  800623:	74 63                	je     800688 <.L29+0x72>
		return va_arg(*ap, long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062d:	99                   	cltd   
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
  80063a:	eb 17                	jmp    800653 <.L29+0x3d>
		return va_arg(*ap, long long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 50 04             	mov    0x4(%eax),%edx
  800642:	8b 00                	mov    (%eax),%eax
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8d 40 08             	lea    0x8(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800653:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800656:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800659:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80065e:	85 db                	test   %ebx,%ebx
  800660:	0f 89 d6 00 00 00    	jns    80073c <.L25+0x2b>
				putch('-', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	57                   	push   %edi
  80066a:	6a 2d                	push   $0x2d
  80066c:	ff d6                	call   *%esi
				num = -(long long) num;
  80066e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800671:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800674:	f7 d9                	neg    %ecx
  800676:	83 d3 00             	adc    $0x0,%ebx
  800679:	f7 db                	neg    %ebx
  80067b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80067e:	ba 0a 00 00 00       	mov    $0xa,%edx
  800683:	e9 b4 00 00 00       	jmp    80073c <.L25+0x2b>
		return va_arg(*ap, int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	99                   	cltd   
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
  80069d:	eb b4                	jmp    800653 <.L29+0x3d>

0080069f <.L23>:
	if (lflag >= 2)
  80069f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a5:	83 f9 01             	cmp    $0x1,%ecx
  8006a8:	7f 1b                	jg     8006c5 <.L23+0x26>
	else if (lflag)
  8006aa:	85 c9                	test   %ecx,%ecx
  8006ac:	74 2c                	je     8006da <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 08                	mov    (%eax),%ecx
  8006b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006be:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006c3:	eb 77                	jmp    80073c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 08                	mov    (%eax),%ecx
  8006ca:	8b 58 04             	mov    0x4(%eax),%ebx
  8006cd:	8d 40 08             	lea    0x8(%eax),%eax
  8006d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d3:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d8:	eb 62                	jmp    80073c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 08                	mov    (%eax),%ecx
  8006df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ea:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006ef:	eb 4b                	jmp    80073c <.L25+0x2b>

008006f1 <.L26>:
			putch('X', putdat);
  8006f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	57                   	push   %edi
  8006f8:	6a 58                	push   $0x58
  8006fa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006fc:	83 c4 08             	add    $0x8,%esp
  8006ff:	57                   	push   %edi
  800700:	6a 58                	push   $0x58
  800702:	ff d6                	call   *%esi
			putch('X', putdat);
  800704:	83 c4 08             	add    $0x8,%esp
  800707:	57                   	push   %edi
  800708:	6a 58                	push   $0x58
  80070a:	ff d6                	call   *%esi
			break;
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb 45                	jmp    800756 <.L25+0x45>

00800711 <.L25>:
			putch('0', putdat);
  800711:	8b 75 08             	mov    0x8(%ebp),%esi
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	57                   	push   %edi
  800718:	6a 30                	push   $0x30
  80071a:	ff d6                	call   *%esi
			putch('x', putdat);
  80071c:	83 c4 08             	add    $0x8,%esp
  80071f:	57                   	push   %edi
  800720:	6a 78                	push   $0x78
  800722:	ff d6                	call   *%esi
			num = (unsigned long long)
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 08                	mov    (%eax),%ecx
  800729:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80072e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800731:	8d 40 04             	lea    0x4(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800737:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80073c:	83 ec 0c             	sub    $0xc,%esp
  80073f:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	ff 75 d0             	push   -0x30(%ebp)
  800747:	52                   	push   %edx
  800748:	53                   	push   %ebx
  800749:	51                   	push   %ecx
  80074a:	89 fa                	mov    %edi,%edx
  80074c:	89 f0                	mov    %esi,%eax
  80074e:	e8 2c fb ff ff       	call   80027f <printnum>
			break;
  800753:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800756:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800759:	e9 4d fc ff ff       	jmp    8003ab <vprintfmt+0x34>

0080075e <.L21>:
	if (lflag >= 2)
  80075e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	83 f9 01             	cmp    $0x1,%ecx
  800767:	7f 1b                	jg     800784 <.L21+0x26>
	else if (lflag)
  800769:	85 c9                	test   %ecx,%ecx
  80076b:	74 2c                	je     800799 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 08                	mov    (%eax),%ecx
  800772:	bb 00 00 00 00       	mov    $0x0,%ebx
  800777:	8d 40 04             	lea    0x4(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077d:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  800782:	eb b8                	jmp    80073c <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 08                	mov    (%eax),%ecx
  800789:	8b 58 04             	mov    0x4(%eax),%ebx
  80078c:	8d 40 08             	lea    0x8(%eax),%eax
  80078f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800792:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  800797:	eb a3                	jmp    80073c <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 08                	mov    (%eax),%ecx
  80079e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a3:	8d 40 04             	lea    0x4(%eax),%eax
  8007a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a9:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007ae:	eb 8c                	jmp    80073c <.L25+0x2b>

008007b0 <.L35>:
			putch(ch, putdat);
  8007b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	57                   	push   %edi
  8007b7:	6a 25                	push   $0x25
  8007b9:	ff d6                	call   *%esi
			break;
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 96                	jmp    800756 <.L25+0x45>

008007c0 <.L20>:
			putch('%', putdat);
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	57                   	push   %edi
  8007c7:	6a 25                	push   $0x25
  8007c9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	89 d8                	mov    %ebx,%eax
  8007d0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d4:	74 05                	je     8007db <.L20+0x1b>
  8007d6:	83 e8 01             	sub    $0x1,%eax
  8007d9:	eb f5                	jmp    8007d0 <.L20+0x10>
  8007db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007de:	e9 73 ff ff ff       	jmp    800756 <.L25+0x45>

008007e3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	83 ec 14             	sub    $0x14,%esp
  8007ea:	e8 96 f8 ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  8007ef:	81 c3 11 18 00 00    	add    $0x1811,%ebx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 2b                	je     80083b <vsnprintf+0x58>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 27                	jle    80083b <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	push   0x14(%ebp)
  800817:	ff 75 10             	push   0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	8d 83 3d e3 ff ff    	lea    -0x1cc3(%ebx),%eax
  800824:	50                   	push   %eax
  800825:	e8 4d fb ff ff       	call   800377 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800830:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800833:	83 c4 10             	add    $0x10,%esp
}
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    
		return -E_INVAL;
  80083b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800840:	eb f4                	jmp    800836 <vsnprintf+0x53>

00800842 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084b:	50                   	push   %eax
  80084c:	ff 75 10             	push   0x10(%ebp)
  80084f:	ff 75 0c             	push   0xc(%ebp)
  800852:	ff 75 08             	push   0x8(%ebp)
  800855:	e8 89 ff ff ff       	call   8007e3 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <__x86.get_pc_thunk.cx>:
  80085c:	8b 0c 24             	mov    (%esp),%ecx
  80085f:	c3                   	ret    

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 03                	jmp    800870 <strlen+0x10>
		n++;
  80086d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800870:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800874:	75 f7                	jne    80086d <strlen+0xd>
	return n;
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strnlen+0x13>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088b:	39 d0                	cmp    %edx,%eax
  80088d:	74 08                	je     800897 <strnlen+0x1f>
  80088f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800893:	75 f3                	jne    800888 <strnlen+0x10>
  800895:	89 c2                	mov    %eax,%edx
	return n;
}
  800897:	89 d0                	mov    %edx,%eax
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008aa:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008ae:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b8:	89 c8                	mov    %ecx,%eax
  8008ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	83 ec 10             	sub    $0x10,%esp
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c9:	53                   	push   %ebx
  8008ca:	e8 91 ff ff ff       	call   800860 <strlen>
  8008cf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008d2:	ff 75 0c             	push   0xc(%ebp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 be ff ff ff       	call   80089b <strcpy>
	return dst;
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	eb 0f                	jmp    800907 <strncpy+0x23>
		*dst++ = *src;
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	0f b6 0a             	movzbl (%edx),%ecx
  8008fe:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 f9 01             	cmp    $0x1,%cl
  800904:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800907:	39 d8                	cmp    %ebx,%eax
  800909:	75 ed                	jne    8008f8 <strncpy+0x14>
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091c:	8b 55 10             	mov    0x10(%ebp),%edx
  80091f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	85 d2                	test   %edx,%edx
  800923:	74 21                	je     800946 <strlcpy+0x35>
  800925:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800929:	89 f2                	mov    %esi,%edx
  80092b:	eb 09                	jmp    800936 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	83 c1 01             	add    $0x1,%ecx
  800930:	83 c2 01             	add    $0x1,%edx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 09                	je     800943 <strlcpy+0x32>
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	84 db                	test   %bl,%bl
  80093f:	75 ec                	jne    80092d <strlcpy+0x1c>
  800941:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800943:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 18                	je     8009a5 <strncmp+0x33>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
}
  8009a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    
		return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	eb f4                	jmp    8009a0 <strncmp+0x2e>

008009ac <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b6:	eb 03                	jmp    8009bb <strchr+0xf>
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	0f b6 10             	movzbl (%eax),%edx
  8009be:	84 d2                	test   %dl,%dl
  8009c0:	74 06                	je     8009c8 <strchr+0x1c>
		if (*s == c)
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	75 f2                	jne    8009b8 <strchr+0xc>
  8009c6:	eb 05                	jmp    8009cd <strchr+0x21>
			return (char *) s;
	return 0;
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	74 09                	je     8009e9 <strfind+0x1a>
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	74 05                	je     8009e9 <strfind+0x1a>
	for (; *s; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	eb f0                	jmp    8009d9 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f7:	85 c9                	test   %ecx,%ecx
  8009f9:	74 2f                	je     800a2a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009fb:	89 f8                	mov    %edi,%eax
  8009fd:	09 c8                	or     %ecx,%eax
  8009ff:	a8 03                	test   $0x3,%al
  800a01:	75 21                	jne    800a24 <memset+0x39>
		c &= 0xFF;
  800a03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a07:	89 d0                	mov    %edx,%eax
  800a09:	c1 e0 08             	shl    $0x8,%eax
  800a0c:	89 d3                	mov    %edx,%ebx
  800a0e:	c1 e3 18             	shl    $0x18,%ebx
  800a11:	89 d6                	mov    %edx,%esi
  800a13:	c1 e6 10             	shl    $0x10,%esi
  800a16:	09 f3                	or     %esi,%ebx
  800a18:	09 da                	or     %ebx,%edx
  800a1a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a1f:	fc                   	cld    
  800a20:	f3 ab                	rep stos %eax,%es:(%edi)
  800a22:	eb 06                	jmp    800a2a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a27:	fc                   	cld    
  800a28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2a:	89 f8                	mov    %edi,%eax
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3f:	39 c6                	cmp    %eax,%esi
  800a41:	73 32                	jae    800a75 <memmove+0x44>
  800a43:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a46:	39 c2                	cmp    %eax,%edx
  800a48:	76 2b                	jbe    800a75 <memmove+0x44>
		s += n;
		d += n;
  800a4a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4d:	89 d6                	mov    %edx,%esi
  800a4f:	09 fe                	or     %edi,%esi
  800a51:	09 ce                	or     %ecx,%esi
  800a53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a59:	75 0e                	jne    800a69 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a5b:	83 ef 04             	sub    $0x4,%edi
  800a5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a64:	fd                   	std    
  800a65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a67:	eb 09                	jmp    800a72 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6f:	fd                   	std    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a72:	fc                   	cld    
  800a73:	eb 1a                	jmp    800a8f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	89 f2                	mov    %esi,%edx
  800a77:	09 c2                	or     %eax,%edx
  800a79:	09 ca                	or     %ecx,%edx
  800a7b:	f6 c2 03             	test   $0x3,%dl
  800a7e:	75 0a                	jne    800a8a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a83:	89 c7                	mov    %eax,%edi
  800a85:	fc                   	cld    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a88:	eb 05                	jmp    800a8f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a8a:	89 c7                	mov    %eax,%edi
  800a8c:	fc                   	cld    
  800a8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a99:	ff 75 10             	push   0x10(%ebp)
  800a9c:	ff 75 0c             	push   0xc(%ebp)
  800a9f:	ff 75 08             	push   0x8(%ebp)
  800aa2:	e8 8a ff ff ff       	call   800a31 <memmove>
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab4:	89 c6                	mov    %eax,%esi
  800ab6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab9:	eb 06                	jmp    800ac1 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ac1:	39 f0                	cmp    %esi,%eax
  800ac3:	74 14                	je     800ad9 <memcmp+0x30>
		if (*s1 != *s2)
  800ac5:	0f b6 08             	movzbl (%eax),%ecx
  800ac8:	0f b6 1a             	movzbl (%edx),%ebx
  800acb:	38 d9                	cmp    %bl,%cl
  800acd:	74 ec                	je     800abb <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800acf:	0f b6 c1             	movzbl %cl,%eax
  800ad2:	0f b6 db             	movzbl %bl,%ebx
  800ad5:	29 d8                	sub    %ebx,%eax
  800ad7:	eb 05                	jmp    800ade <memcmp+0x35>
	}

	return 0;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af0:	eb 03                	jmp    800af5 <memfind+0x13>
  800af2:	83 c0 01             	add    $0x1,%eax
  800af5:	39 d0                	cmp    %edx,%eax
  800af7:	73 04                	jae    800afd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af9:	38 08                	cmp    %cl,(%eax)
  800afb:	75 f5                	jne    800af2 <memfind+0x10>
			break;
	return (void *) s;
}
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 55 08             	mov    0x8(%ebp),%edx
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0b:	eb 03                	jmp    800b10 <strtol+0x11>
		s++;
  800b0d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b10:	0f b6 02             	movzbl (%edx),%eax
  800b13:	3c 20                	cmp    $0x20,%al
  800b15:	74 f6                	je     800b0d <strtol+0xe>
  800b17:	3c 09                	cmp    $0x9,%al
  800b19:	74 f2                	je     800b0d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b1b:	3c 2b                	cmp    $0x2b,%al
  800b1d:	74 2a                	je     800b49 <strtol+0x4a>
	int neg = 0;
  800b1f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b24:	3c 2d                	cmp    $0x2d,%al
  800b26:	74 2b                	je     800b53 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b28:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2e:	75 0f                	jne    800b3f <strtol+0x40>
  800b30:	80 3a 30             	cmpb   $0x30,(%edx)
  800b33:	74 28                	je     800b5d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b35:	85 db                	test   %ebx,%ebx
  800b37:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3c:	0f 44 d8             	cmove  %eax,%ebx
  800b3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b44:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b47:	eb 46                	jmp    800b8f <strtol+0x90>
		s++;
  800b49:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b51:	eb d5                	jmp    800b28 <strtol+0x29>
		s++, neg = 1;
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	bf 01 00 00 00       	mov    $0x1,%edi
  800b5b:	eb cb                	jmp    800b28 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b61:	74 0e                	je     800b71 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 d8                	jne    800b3f <strtol+0x40>
		s++, base = 8;
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b6f:	eb ce                	jmp    800b3f <strtol+0x40>
		s += 2, base = 16;
  800b71:	83 c2 02             	add    $0x2,%edx
  800b74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b79:	eb c4                	jmp    800b3f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b7b:	0f be c0             	movsbl %al,%eax
  800b7e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b81:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b84:	7d 3a                	jge    800bc0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b86:	83 c2 01             	add    $0x1,%edx
  800b89:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b8d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b8f:	0f b6 02             	movzbl (%edx),%eax
  800b92:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 09             	cmp    $0x9,%bl
  800b9a:	76 df                	jbe    800b7b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b9c:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b9f:	89 f3                	mov    %esi,%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 08                	ja     800bae <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ba6:	0f be c0             	movsbl %al,%eax
  800ba9:	83 e8 57             	sub    $0x57,%eax
  800bac:	eb d3                	jmp    800b81 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bae:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bb1:	89 f3                	mov    %esi,%ebx
  800bb3:	80 fb 19             	cmp    $0x19,%bl
  800bb6:	77 08                	ja     800bc0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb8:	0f be c0             	movsbl %al,%eax
  800bbb:	83 e8 37             	sub    $0x37,%eax
  800bbe:	eb c1                	jmp    800b81 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc4:	74 05                	je     800bcb <strtol+0xcc>
		*endptr = (char *) s;
  800bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bcb:	89 c8                	mov    %ecx,%eax
  800bcd:	f7 d8                	neg    %eax
  800bcf:	85 ff                	test   %edi,%edi
  800bd1:	0f 45 c8             	cmovne %eax,%ecx
}
  800bd4:	89 c8                	mov    %ecx,%eax
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    
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
