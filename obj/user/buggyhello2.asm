
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	push   0xc(%ebx)
  800050:	e8 74 00 00 00       	call   8000c9 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	53                   	push   %ebx
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	e8 f0 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006d:	81 c3 93 1f 00 00    	add    $0x1f93,%ebx
  800073:	8b 45 08             	mov    0x8(%ebp),%eax
  800076:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  800079:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  80007f:	89 8b 30 00 00 00    	mov    %ecx,0x30(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	7e 08                	jle    800091 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 0a                	mov    (%edx),%ecx
  80008b:	89 8b 10 00 00 00    	mov    %ecx,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	52                   	push   %edx
  800095:	50                   	push   %eax
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 10             	sub    $0x10,%esp
  8000af:	e8 a9 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000b4:	81 c3 4c 1f 00 00    	add    $0x1f4c,%ebx
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 45 00 00 00       	call   800106 <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f7:	89 d1                	mov    %edx,%ecx
  8000f9:	89 d3                	mov    %edx,%ebx
  8000fb:	89 d7                	mov    %edx,%edi
  8000fd:	89 d6                	mov    %edx,%esi
  8000ff:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	83 ec 1c             	sub    $0x1c,%esp
  80010f:	e8 66 00 00 00       	call   80017a <__x86.get_pc_thunk.ax>
  800114:	05 ec 1e 00 00       	add    $0x1eec,%eax
  800119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	b8 03 00 00 00       	mov    $0x3,%eax
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7f 08                	jg     80013d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	6a 03                	push   $0x3
  800143:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800146:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  80014c:	50                   	push   %eax
  80014d:	6a 23                	push   $0x23
  80014f:	8d 83 69 ee ff ff    	lea    -0x1197(%ebx),%eax
  800155:	50                   	push   %eax
  800156:	e8 23 00 00 00       	call   80017e <_panic>

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <__x86.get_pc_thunk.ax>:
  80017a:	8b 04 24             	mov    (%esp),%eax
  80017d:	c3                   	ret    

0080017e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	e8 d1 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80018c:	81 c3 74 1e 00 00    	add    $0x1e74,%ebx
	va_list ap;

	va_start(ap, fmt);
  800192:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800195:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  80019b:	8b 38                	mov    (%eax),%edi
  80019d:	e8 b9 ff ff ff       	call   80015b <sys_getenvid>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	ff 75 0c             	push   0xc(%ebp)
  8001a8:	ff 75 08             	push   0x8(%ebp)
  8001ab:	57                   	push   %edi
  8001ac:	50                   	push   %eax
  8001ad:	8d 83 78 ee ff ff    	lea    -0x1188(%ebx),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 d1 00 00 00       	call   80028a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	56                   	push   %esi
  8001bd:	ff 75 10             	push   0x10(%ebp)
  8001c0:	e8 63 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  8001c5:	8d 83 40 ee ff ff    	lea    -0x11c0(%ebx),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 b7 00 00 00       	call   80028a <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x58>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	e8 7a fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001e3:	81 c3 1d 1e 00 00    	add    $0x1e1d,%ebx
  8001e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ec:	8b 16                	mov    (%esi),%edx
  8001ee:	8d 42 01             	lea    0x1(%edx),%eax
  8001f1:	89 06                	mov    %eax,(%esi)
  8001f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f6:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ff:	74 0b                	je     80020c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800201:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800205:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	68 ff 00 00 00       	push   $0xff
  800214:	8d 46 08             	lea    0x8(%esi),%eax
  800217:	50                   	push   %eax
  800218:	e8 ac fe ff ff       	call   8000c9 <sys_cputs>
		b->idx = 0;
  80021d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	eb d9                	jmp    800201 <putch+0x28>

00800228 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	53                   	push   %ebx
  80022c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800232:	e8 26 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800237:	81 c3 c9 1d 00 00    	add    $0x1dc9,%ebx
	struct printbuf b;

	b.idx = 0;
  80023d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800244:	00 00 00 
	b.cnt = 0;
  800247:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800251:	ff 75 0c             	push   0xc(%ebp)
  800254:	ff 75 08             	push   0x8(%ebp)
  800257:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	8d 83 d9 e1 ff ff    	lea    -0x1e27(%ebx),%eax
  800264:	50                   	push   %eax
  800265:	e8 2c 01 00 00       	call   800396 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026a:	83 c4 08             	add    $0x8,%esp
  80026d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800273:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800279:	50                   	push   %eax
  80027a:	e8 4a fe ff ff       	call   8000c9 <sys_cputs>

	return b.cnt;
}
  80027f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800290:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 08             	push   0x8(%ebp)
  800297:	e8 8c ff ff ff       	call   800228 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 2c             	sub    $0x2c,%esp
  8002a7:	e8 cf 05 00 00       	call   80087b <__x86.get_pc_thunk.cx>
  8002ac:	81 c1 54 1d 00 00    	add    $0x1d54,%ecx
  8002b2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002b5:	89 c7                	mov    %eax,%edi
  8002b7:	89 d6                	mov    %edx,%esi
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bf:	89 d1                	mov    %edx,%ecx
  8002c1:	89 c2                	mov    %eax,%edx
  8002c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d9:	39 c2                	cmp    %eax,%edx
  8002db:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002de:	72 41                	jb     800321 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	ff 75 18             	push   0x18(%ebp)
  8002e6:	83 eb 01             	sub    $0x1,%ebx
  8002e9:	53                   	push   %ebx
  8002ea:	50                   	push   %eax
  8002eb:	83 ec 08             	sub    $0x8,%esp
  8002ee:	ff 75 e4             	push   -0x1c(%ebp)
  8002f1:	ff 75 e0             	push   -0x20(%ebp)
  8002f4:	ff 75 d4             	push   -0x2c(%ebp)
  8002f7:	ff 75 d0             	push   -0x30(%ebp)
  8002fa:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002fd:	e8 fe 08 00 00       	call   800c00 <__udivdi3>
  800302:	83 c4 18             	add    $0x18,%esp
  800305:	52                   	push   %edx
  800306:	50                   	push   %eax
  800307:	89 f2                	mov    %esi,%edx
  800309:	89 f8                	mov    %edi,%eax
  80030b:	e8 8e ff ff ff       	call   80029e <printnum>
  800310:	83 c4 20             	add    $0x20,%esp
  800313:	eb 13                	jmp    800328 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	56                   	push   %esi
  800319:	ff 75 18             	push   0x18(%ebp)
  80031c:	ff d7                	call   *%edi
  80031e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800321:	83 eb 01             	sub    $0x1,%ebx
  800324:	85 db                	test   %ebx,%ebx
  800326:	7f ed                	jg     800315 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800328:	83 ec 08             	sub    $0x8,%esp
  80032b:	56                   	push   %esi
  80032c:	83 ec 04             	sub    $0x4,%esp
  80032f:	ff 75 e4             	push   -0x1c(%ebp)
  800332:	ff 75 e0             	push   -0x20(%ebp)
  800335:	ff 75 d4             	push   -0x2c(%ebp)
  800338:	ff 75 d0             	push   -0x30(%ebp)
  80033b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80033e:	e8 dd 09 00 00       	call   800d20 <__umoddi3>
  800343:	83 c4 14             	add    $0x14,%esp
  800346:	0f be 84 03 9b ee ff 	movsbl -0x1165(%ebx,%eax,1),%eax
  80034d:	ff 
  80034e:	50                   	push   %eax
  80034f:	ff d7                	call   *%edi
}
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800362:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800366:	8b 10                	mov    (%eax),%edx
  800368:	3b 50 04             	cmp    0x4(%eax),%edx
  80036b:	73 0a                	jae    800377 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	88 02                	mov    %al,(%edx)
}
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <printfmt>:
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800382:	50                   	push   %eax
  800383:	ff 75 10             	push   0x10(%ebp)
  800386:	ff 75 0c             	push   0xc(%ebp)
  800389:	ff 75 08             	push   0x8(%ebp)
  80038c:	e8 05 00 00 00       	call   800396 <vprintfmt>
}
  800391:	83 c4 10             	add    $0x10,%esp
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <vprintfmt>:
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
  80039c:	83 ec 3c             	sub    $0x3c,%esp
  80039f:	e8 d6 fd ff ff       	call   80017a <__x86.get_pc_thunk.ax>
  8003a4:	05 5c 1c 00 00       	add    $0x1c5c,%eax
  8003a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b5:	8d 80 14 00 00 00    	lea    0x14(%eax),%eax
  8003bb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003be:	eb 0a                	jmp    8003ca <vprintfmt+0x34>
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	57                   	push   %edi
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c3 01             	add    $0x1,%ebx
  8003cd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	74 0c                	je     8003e2 <vprintfmt+0x4c>
			if (ch == '\0')
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	75 e6                	jne    8003c0 <vprintfmt+0x2a>
}
  8003da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003dd:	5b                   	pop    %ebx
  8003de:	5e                   	pop    %esi
  8003df:	5f                   	pop    %edi
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    
		padc = ' ';
  8003e2:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ed:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800400:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800403:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8d 43 01             	lea    0x1(%ebx),%eax
  800409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040c:	0f b6 13             	movzbl (%ebx),%edx
  80040f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800412:	3c 55                	cmp    $0x55,%al
  800414:	0f 87 c5 03 00 00    	ja     8007df <.L20>
  80041a:	0f b6 c0             	movzbl %al,%eax
  80041d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800420:	89 ce                	mov    %ecx,%esi
  800422:	03 b4 81 28 ef ff ff 	add    -0x10d8(%ecx,%eax,4),%esi
  800429:	ff e6                	jmp    *%esi

0080042b <.L66>:
  80042b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80042e:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800432:	eb d2                	jmp    800406 <vprintfmt+0x70>

00800434 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800437:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80043b:	eb c9                	jmp    800406 <vprintfmt+0x70>

0080043d <.L31>:
  80043d:	0f b6 d2             	movzbl %dl,%edx
  800440:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80044b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800452:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800455:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800458:	83 f9 09             	cmp    $0x9,%ecx
  80045b:	77 58                	ja     8004b5 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80045d:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800460:	eb e9                	jmp    80044b <.L31+0xe>

00800462 <.L34>:
			precision = va_arg(ap, int);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8b 00                	mov    (%eax),%eax
  800467:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 40 04             	lea    0x4(%eax),%eax
  800470:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800476:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80047a:	79 8a                	jns    800406 <vprintfmt+0x70>
				width = precision, precision = -1;
  80047c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80047f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800482:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800489:	e9 78 ff ff ff       	jmp    800406 <vprintfmt+0x70>

0080048e <.L33>:
  80048e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	0f 49 c2             	cmovns %edx,%eax
  80049b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a1:	e9 60 ff ff ff       	jmp    800406 <vprintfmt+0x70>

008004a6 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004b0:	e9 51 ff ff ff       	jmp    800406 <vprintfmt+0x70>
  8004b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bb:	eb b9                	jmp    800476 <.L34+0x14>

008004bd <.L27>:
			lflag++;
  8004bd:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004c4:	e9 3d ff ff ff       	jmp    800406 <vprintfmt+0x70>

008004c9 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8d 58 04             	lea    0x4(%eax),%ebx
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	57                   	push   %edi
  8004d6:	ff 30                	push   (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004dd:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004e0:	e9 90 02 00 00       	jmp    800775 <.L25+0x45>

008004e5 <.L28>:
			err = va_arg(ap, int);
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ee:	8b 10                	mov    (%eax),%edx
  8004f0:	89 d0                	mov    %edx,%eax
  8004f2:	f7 d8                	neg    %eax
  8004f4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f7:	83 f8 06             	cmp    $0x6,%eax
  8004fa:	7f 27                	jg     800523 <.L28+0x3e>
  8004fc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ff:	8b 14 82             	mov    (%edx,%eax,4),%edx
  800502:	85 d2                	test   %edx,%edx
  800504:	74 1d                	je     800523 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800506:	52                   	push   %edx
  800507:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050a:	8d 80 bc ee ff ff    	lea    -0x1144(%eax),%eax
  800510:	50                   	push   %eax
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	e8 61 fe ff ff       	call   800379 <printfmt>
  800518:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80051b:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80051e:	e9 52 02 00 00       	jmp    800775 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800523:	50                   	push   %eax
  800524:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800527:	8d 80 b3 ee ff ff    	lea    -0x114d(%eax),%eax
  80052d:	50                   	push   %eax
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	e8 44 fe ff ff       	call   800379 <printfmt>
  800535:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800538:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80053b:	e9 35 02 00 00       	jmp    800775 <.L25+0x45>

00800540 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	83 c0 04             	add    $0x4,%eax
  800549:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800551:	85 d2                	test   %edx,%edx
  800553:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800556:	8d 80 ac ee ff ff    	lea    -0x1154(%eax),%eax
  80055c:	0f 45 c2             	cmovne %edx,%eax
  80055f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800562:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800566:	7e 06                	jle    80056e <.L24+0x2e>
  800568:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80056c:	75 0d                	jne    80057b <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800571:	89 c3                	mov    %eax,%ebx
  800573:	03 45 d0             	add    -0x30(%ebp),%eax
  800576:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800579:	eb 58                	jmp    8005d3 <.L24+0x93>
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 d8             	push   -0x28(%ebp)
  800581:	ff 75 c8             	push   -0x38(%ebp)
  800584:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800587:	e8 0b 03 00 00       	call   800897 <strnlen>
  80058c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058f:	29 c2                	sub    %eax,%edx
  800591:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800599:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80059d:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a0:	eb 0f                	jmp    8005b1 <.L24+0x71>
					putch(padc, putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	57                   	push   %edi
  8005a6:	ff 75 d0             	push   -0x30(%ebp)
  8005a9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ab:	83 eb 01             	sub    $0x1,%ebx
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	85 db                	test   %ebx,%ebx
  8005b3:	7f ed                	jg     8005a2 <.L24+0x62>
  8005b5:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	0f 49 c2             	cmovns %edx,%eax
  8005c2:	29 c2                	sub    %eax,%edx
  8005c4:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c7:	eb a5                	jmp    80056e <.L24+0x2e>
					putch(ch, putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	57                   	push   %edi
  8005cd:	52                   	push   %edx
  8005ce:	ff d6                	call   *%esi
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d6:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d8:	83 c3 01             	add    $0x1,%ebx
  8005db:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005df:	0f be d0             	movsbl %al,%edx
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	74 4b                	je     800631 <.L24+0xf1>
  8005e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ea:	78 06                	js     8005f2 <.L24+0xb2>
  8005ec:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005f0:	78 1e                	js     800610 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f6:	74 d1                	je     8005c9 <.L24+0x89>
  8005f8:	0f be c0             	movsbl %al,%eax
  8005fb:	83 e8 20             	sub    $0x20,%eax
  8005fe:	83 f8 5e             	cmp    $0x5e,%eax
  800601:	76 c6                	jbe    8005c9 <.L24+0x89>
					putch('?', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	57                   	push   %edi
  800607:	6a 3f                	push   $0x3f
  800609:	ff d6                	call   *%esi
  80060b:	83 c4 10             	add    $0x10,%esp
  80060e:	eb c3                	jmp    8005d3 <.L24+0x93>
  800610:	89 cb                	mov    %ecx,%ebx
  800612:	eb 0e                	jmp    800622 <.L24+0xe2>
				putch(' ', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	57                   	push   %edi
  800618:	6a 20                	push   $0x20
  80061a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80061c:	83 eb 01             	sub    $0x1,%ebx
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	85 db                	test   %ebx,%ebx
  800624:	7f ee                	jg     800614 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800626:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
  80062c:	e9 44 01 00 00       	jmp    800775 <.L25+0x45>
  800631:	89 cb                	mov    %ecx,%ebx
  800633:	eb ed                	jmp    800622 <.L24+0xe2>

00800635 <.L29>:
	if (lflag >= 2)
  800635:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800638:	8b 75 08             	mov    0x8(%ebp),%esi
  80063b:	83 f9 01             	cmp    $0x1,%ecx
  80063e:	7f 1b                	jg     80065b <.L29+0x26>
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 63                	je     8006a7 <.L29+0x72>
		return va_arg(*ap, long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064c:	99                   	cltd   
  80064d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	eb 17                	jmp    800672 <.L29+0x3d>
		return va_arg(*ap, long long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 50 04             	mov    0x4(%eax),%edx
  800661:	8b 00                	mov    (%eax),%eax
  800663:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800666:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 40 08             	lea    0x8(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800672:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800675:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800678:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80067d:	85 db                	test   %ebx,%ebx
  80067f:	0f 89 d6 00 00 00    	jns    80075b <.L25+0x2b>
				putch('-', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	57                   	push   %edi
  800689:	6a 2d                	push   $0x2d
  80068b:	ff d6                	call   *%esi
				num = -(long long) num;
  80068d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800690:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800693:	f7 d9                	neg    %ecx
  800695:	83 d3 00             	adc    $0x0,%ebx
  800698:	f7 db                	neg    %ebx
  80069a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80069d:	ba 0a 00 00 00       	mov    $0xa,%edx
  8006a2:	e9 b4 00 00 00       	jmp    80075b <.L25+0x2b>
		return va_arg(*ap, int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006af:	99                   	cltd   
  8006b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bc:	eb b4                	jmp    800672 <.L29+0x3d>

008006be <.L23>:
	if (lflag >= 2)
  8006be:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c4:	83 f9 01             	cmp    $0x1,%ecx
  8006c7:	7f 1b                	jg     8006e4 <.L23+0x26>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 2c                	je     8006f9 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 08                	mov    (%eax),%ecx
  8006d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006dd:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006e2:	eb 77                	jmp    80075b <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 08                	mov    (%eax),%ecx
  8006e9:	8b 58 04             	mov    0x4(%eax),%ebx
  8006ec:	8d 40 08             	lea    0x8(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f7:	eb 62                	jmp    80075b <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 08                	mov    (%eax),%ecx
  8006fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800709:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  80070e:	eb 4b                	jmp    80075b <.L25+0x2b>

00800710 <.L26>:
			putch('X', putdat);
  800710:	8b 75 08             	mov    0x8(%ebp),%esi
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	57                   	push   %edi
  800717:	6a 58                	push   $0x58
  800719:	ff d6                	call   *%esi
			putch('X', putdat);
  80071b:	83 c4 08             	add    $0x8,%esp
  80071e:	57                   	push   %edi
  80071f:	6a 58                	push   $0x58
  800721:	ff d6                	call   *%esi
			putch('X', putdat);
  800723:	83 c4 08             	add    $0x8,%esp
  800726:	57                   	push   %edi
  800727:	6a 58                	push   $0x58
  800729:	ff d6                	call   *%esi
			break;
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 45                	jmp    800775 <.L25+0x45>

00800730 <.L25>:
			putch('0', putdat);
  800730:	8b 75 08             	mov    0x8(%ebp),%esi
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	57                   	push   %edi
  800737:	6a 30                	push   $0x30
  800739:	ff d6                	call   *%esi
			putch('x', putdat);
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	57                   	push   %edi
  80073f:	6a 78                	push   $0x78
  800741:	ff d6                	call   *%esi
			num = (unsigned long long)
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 08                	mov    (%eax),%ecx
  800748:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80074d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800750:	8d 40 04             	lea    0x4(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800756:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80075b:	83 ec 0c             	sub    $0xc,%esp
  80075e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	ff 75 d0             	push   -0x30(%ebp)
  800766:	52                   	push   %edx
  800767:	53                   	push   %ebx
  800768:	51                   	push   %ecx
  800769:	89 fa                	mov    %edi,%edx
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	e8 2c fb ff ff       	call   80029e <printnum>
			break;
  800772:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800775:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800778:	e9 4d fc ff ff       	jmp    8003ca <vprintfmt+0x34>

0080077d <.L21>:
	if (lflag >= 2)
  80077d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	83 f9 01             	cmp    $0x1,%ecx
  800786:	7f 1b                	jg     8007a3 <.L21+0x26>
	else if (lflag)
  800788:	85 c9                	test   %ecx,%ecx
  80078a:	74 2c                	je     8007b8 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 08                	mov    (%eax),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079c:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007a1:	eb b8                	jmp    80075b <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 08                	mov    (%eax),%ecx
  8007a8:	8b 58 04             	mov    0x4(%eax),%ebx
  8007ab:	8d 40 08             	lea    0x8(%eax),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b1:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007b6:	eb a3                	jmp    80075b <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 08                	mov    (%eax),%ecx
  8007bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c2:	8d 40 04             	lea    0x4(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007cd:	eb 8c                	jmp    80075b <.L25+0x2b>

008007cf <.L35>:
			putch(ch, putdat);
  8007cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	57                   	push   %edi
  8007d6:	6a 25                	push   $0x25
  8007d8:	ff d6                	call   *%esi
			break;
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 96                	jmp    800775 <.L25+0x45>

008007df <.L20>:
			putch('%', putdat);
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	83 ec 08             	sub    $0x8,%esp
  8007e5:	57                   	push   %edi
  8007e6:	6a 25                	push   $0x25
  8007e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007ea:	83 c4 10             	add    $0x10,%esp
  8007ed:	89 d8                	mov    %ebx,%eax
  8007ef:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007f3:	74 05                	je     8007fa <.L20+0x1b>
  8007f5:	83 e8 01             	sub    $0x1,%eax
  8007f8:	eb f5                	jmp    8007ef <.L20+0x10>
  8007fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007fd:	e9 73 ff ff ff       	jmp    800775 <.L25+0x45>

00800802 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	83 ec 14             	sub    $0x14,%esp
  800809:	e8 4f f8 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80080e:	81 c3 f2 17 00 00    	add    $0x17f2,%ebx
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80081d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800821:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800824:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80082b:	85 c0                	test   %eax,%eax
  80082d:	74 2b                	je     80085a <vsnprintf+0x58>
  80082f:	85 d2                	test   %edx,%edx
  800831:	7e 27                	jle    80085a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800833:	ff 75 14             	push   0x14(%ebp)
  800836:	ff 75 10             	push   0x10(%ebp)
  800839:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	8d 83 5c e3 ff ff    	lea    -0x1ca4(%ebx),%eax
  800843:	50                   	push   %eax
  800844:	e8 4d fb ff ff       	call   800396 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800849:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800852:	83 c4 10             	add    $0x10,%esp
}
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    
		return -E_INVAL;
  80085a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085f:	eb f4                	jmp    800855 <vsnprintf+0x53>

00800861 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086a:	50                   	push   %eax
  80086b:	ff 75 10             	push   0x10(%ebp)
  80086e:	ff 75 0c             	push   0xc(%ebp)
  800871:	ff 75 08             	push   0x8(%ebp)
  800874:	e8 89 ff ff ff       	call   800802 <vsnprintf>
	va_end(ap);

	return rc;
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <__x86.get_pc_thunk.cx>:
  80087b:	8b 0c 24             	mov    (%esp),%ecx
  80087e:	c3                   	ret    

0080087f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	eb 03                	jmp    80088f <strlen+0x10>
		n++;
  80088c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800893:	75 f7                	jne    80088c <strlen+0xd>
	return n;
}
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	eb 03                	jmp    8008aa <strnlen+0x13>
		n++;
  8008a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008aa:	39 d0                	cmp    %edx,%eax
  8008ac:	74 08                	je     8008b6 <strnlen+0x1f>
  8008ae:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b2:	75 f3                	jne    8008a7 <strnlen+0x10>
  8008b4:	89 c2                	mov    %eax,%edx
	return n;
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008cd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d7:	89 c8                	mov    %ecx,%eax
  8008d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	53                   	push   %ebx
  8008e2:	83 ec 10             	sub    $0x10,%esp
  8008e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e8:	53                   	push   %ebx
  8008e9:	e8 91 ff ff ff       	call   80087f <strlen>
  8008ee:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008f1:	ff 75 0c             	push   0xc(%ebp)
  8008f4:	01 d8                	add    %ebx,%eax
  8008f6:	50                   	push   %eax
  8008f7:	e8 be ff ff ff       	call   8008ba <strcpy>
	return dst;
}
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 f3                	mov    %esi,%ebx
  800910:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800913:	89 f0                	mov    %esi,%eax
  800915:	eb 0f                	jmp    800926 <strncpy+0x23>
		*dst++ = *src;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	0f b6 0a             	movzbl (%edx),%ecx
  80091d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800920:	80 f9 01             	cmp    $0x1,%cl
  800923:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800926:	39 d8                	cmp    %ebx,%eax
  800928:	75 ed                	jne    800917 <strncpy+0x14>
	}
	return ret;
}
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 75 08             	mov    0x8(%ebp),%esi
  800938:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093b:	8b 55 10             	mov    0x10(%ebp),%edx
  80093e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800940:	85 d2                	test   %edx,%edx
  800942:	74 21                	je     800965 <strlcpy+0x35>
  800944:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800948:	89 f2                	mov    %esi,%edx
  80094a:	eb 09                	jmp    800955 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094c:	83 c1 01             	add    $0x1,%ecx
  80094f:	83 c2 01             	add    $0x1,%edx
  800952:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800955:	39 c2                	cmp    %eax,%edx
  800957:	74 09                	je     800962 <strlcpy+0x32>
  800959:	0f b6 19             	movzbl (%ecx),%ebx
  80095c:	84 db                	test   %bl,%bl
  80095e:	75 ec                	jne    80094c <strlcpy+0x1c>
  800960:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800962:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800965:	29 f0                	sub    %esi,%eax
}
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800974:	eb 06                	jmp    80097c <strcmp+0x11>
		p++, q++;
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097c:	0f b6 01             	movzbl (%ecx),%eax
  80097f:	84 c0                	test   %al,%al
  800981:	74 04                	je     800987 <strcmp+0x1c>
  800983:	3a 02                	cmp    (%edx),%al
  800985:	74 ef                	je     800976 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800987:	0f b6 c0             	movzbl %al,%eax
  80098a:	0f b6 12             	movzbl (%edx),%edx
  80098d:	29 d0                	sub    %edx,%eax
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	89 c3                	mov    %eax,%ebx
  80099d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a0:	eb 06                	jmp    8009a8 <strncmp+0x17>
		n--, p++, q++;
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a8:	39 d8                	cmp    %ebx,%eax
  8009aa:	74 18                	je     8009c4 <strncmp+0x33>
  8009ac:	0f b6 08             	movzbl (%eax),%ecx
  8009af:	84 c9                	test   %cl,%cl
  8009b1:	74 04                	je     8009b7 <strncmp+0x26>
  8009b3:	3a 0a                	cmp    (%edx),%cl
  8009b5:	74 eb                	je     8009a2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f b6 12             	movzbl (%edx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
}
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    
		return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	eb f4                	jmp    8009bf <strncmp+0x2e>

008009cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 03                	jmp    8009da <strchr+0xf>
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
  8009dd:	84 d2                	test   %dl,%dl
  8009df:	74 06                	je     8009e7 <strchr+0x1c>
		if (*s == c)
  8009e1:	38 ca                	cmp    %cl,%dl
  8009e3:	75 f2                	jne    8009d7 <strchr+0xc>
  8009e5:	eb 05                	jmp    8009ec <strchr+0x21>
			return (char *) s;
	return 0;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 09                	je     800a08 <strfind+0x1a>
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	74 05                	je     800a08 <strfind+0x1a>
	for (; *s; s++)
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	eb f0                	jmp    8009f8 <strfind+0xa>
			break;
	return (char *) s;
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a16:	85 c9                	test   %ecx,%ecx
  800a18:	74 2f                	je     800a49 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1a:	89 f8                	mov    %edi,%eax
  800a1c:	09 c8                	or     %ecx,%eax
  800a1e:	a8 03                	test   $0x3,%al
  800a20:	75 21                	jne    800a43 <memset+0x39>
		c &= 0xFF;
  800a22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a26:	89 d0                	mov    %edx,%eax
  800a28:	c1 e0 08             	shl    $0x8,%eax
  800a2b:	89 d3                	mov    %edx,%ebx
  800a2d:	c1 e3 18             	shl    $0x18,%ebx
  800a30:	89 d6                	mov    %edx,%esi
  800a32:	c1 e6 10             	shl    $0x10,%esi
  800a35:	09 f3                	or     %esi,%ebx
  800a37:	09 da                	or     %ebx,%edx
  800a39:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a3b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3e:	fc                   	cld    
  800a3f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a41:	eb 06                	jmp    800a49 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a46:	fc                   	cld    
  800a47:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5e:	39 c6                	cmp    %eax,%esi
  800a60:	73 32                	jae    800a94 <memmove+0x44>
  800a62:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a65:	39 c2                	cmp    %eax,%edx
  800a67:	76 2b                	jbe    800a94 <memmove+0x44>
		s += n;
		d += n;
  800a69:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6c:	89 d6                	mov    %edx,%esi
  800a6e:	09 fe                	or     %edi,%esi
  800a70:	09 ce                	or     %ecx,%esi
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 0e                	jne    800a88 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb 09                	jmp    800a91 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a88:	83 ef 01             	sub    $0x1,%edi
  800a8b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8e:	fd                   	std    
  800a8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a91:	fc                   	cld    
  800a92:	eb 1a                	jmp    800aae <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a94:	89 f2                	mov    %esi,%edx
  800a96:	09 c2                	or     %eax,%edx
  800a98:	09 ca                	or     %ecx,%edx
  800a9a:	f6 c2 03             	test   $0x3,%dl
  800a9d:	75 0a                	jne    800aa9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb 05                	jmp    800aae <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa9:	89 c7                	mov    %eax,%edi
  800aab:	fc                   	cld    
  800aac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab8:	ff 75 10             	push   0x10(%ebp)
  800abb:	ff 75 0c             	push   0xc(%ebp)
  800abe:	ff 75 08             	push   0x8(%ebp)
  800ac1:	e8 8a ff ff ff       	call   800a50 <memmove>
}
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad3:	89 c6                	mov    %eax,%esi
  800ad5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad8:	eb 06                	jmp    800ae0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800ae0:	39 f0                	cmp    %esi,%eax
  800ae2:	74 14                	je     800af8 <memcmp+0x30>
		if (*s1 != *s2)
  800ae4:	0f b6 08             	movzbl (%eax),%ecx
  800ae7:	0f b6 1a             	movzbl (%edx),%ebx
  800aea:	38 d9                	cmp    %bl,%cl
  800aec:	74 ec                	je     800ada <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aee:	0f b6 c1             	movzbl %cl,%eax
  800af1:	0f b6 db             	movzbl %bl,%ebx
  800af4:	29 d8                	sub    %ebx,%eax
  800af6:	eb 05                	jmp    800afd <memcmp+0x35>
	}

	return 0;
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0f:	eb 03                	jmp    800b14 <memfind+0x13>
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	73 04                	jae    800b1c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	38 08                	cmp    %cl,(%eax)
  800b1a:	75 f5                	jne    800b11 <memfind+0x10>
			break;
	return (void *) s;
}
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	eb 03                	jmp    800b2f <strtol+0x11>
		s++;
  800b2c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b2f:	0f b6 02             	movzbl (%edx),%eax
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	74 f6                	je     800b2c <strtol+0xe>
  800b36:	3c 09                	cmp    $0x9,%al
  800b38:	74 f2                	je     800b2c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b3a:	3c 2b                	cmp    $0x2b,%al
  800b3c:	74 2a                	je     800b68 <strtol+0x4a>
	int neg = 0;
  800b3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b43:	3c 2d                	cmp    $0x2d,%al
  800b45:	74 2b                	je     800b72 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4d:	75 0f                	jne    800b5e <strtol+0x40>
  800b4f:	80 3a 30             	cmpb   $0x30,(%edx)
  800b52:	74 28                	je     800b7c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b54:	85 db                	test   %ebx,%ebx
  800b56:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5b:	0f 44 d8             	cmove  %eax,%ebx
  800b5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b63:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b66:	eb 46                	jmp    800bae <strtol+0x90>
		s++;
  800b68:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b6b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b70:	eb d5                	jmp    800b47 <strtol+0x29>
		s++, neg = 1;
  800b72:	83 c2 01             	add    $0x1,%edx
  800b75:	bf 01 00 00 00       	mov    $0x1,%edi
  800b7a:	eb cb                	jmp    800b47 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b80:	74 0e                	je     800b90 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b82:	85 db                	test   %ebx,%ebx
  800b84:	75 d8                	jne    800b5e <strtol+0x40>
		s++, base = 8;
  800b86:	83 c2 01             	add    $0x1,%edx
  800b89:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b8e:	eb ce                	jmp    800b5e <strtol+0x40>
		s += 2, base = 16;
  800b90:	83 c2 02             	add    $0x2,%edx
  800b93:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b98:	eb c4                	jmp    800b5e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b9a:	0f be c0             	movsbl %al,%eax
  800b9d:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ba3:	7d 3a                	jge    800bdf <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ba5:	83 c2 01             	add    $0x1,%edx
  800ba8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bac:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bae:	0f b6 02             	movzbl (%edx),%eax
  800bb1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bb4:	89 f3                	mov    %esi,%ebx
  800bb6:	80 fb 09             	cmp    $0x9,%bl
  800bb9:	76 df                	jbe    800b9a <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bbb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 08                	ja     800bcd <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bc5:	0f be c0             	movsbl %al,%eax
  800bc8:	83 e8 57             	sub    $0x57,%eax
  800bcb:	eb d3                	jmp    800ba0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bcd:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bd0:	89 f3                	mov    %esi,%ebx
  800bd2:	80 fb 19             	cmp    $0x19,%bl
  800bd5:	77 08                	ja     800bdf <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bd7:	0f be c0             	movsbl %al,%eax
  800bda:	83 e8 37             	sub    $0x37,%eax
  800bdd:	eb c1                	jmp    800ba0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be3:	74 05                	je     800bea <strtol+0xcc>
		*endptr = (char *) s;
  800be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bea:	89 c8                	mov    %ecx,%eax
  800bec:	f7 d8                	neg    %eax
  800bee:	85 ff                	test   %edi,%edi
  800bf0:	0f 45 c8             	cmovne %eax,%ecx
}
  800bf3:	89 c8                	mov    %ecx,%eax
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
  800bfa:	66 90                	xchg   %ax,%ax
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
