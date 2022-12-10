
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	53                   	push   %ebx
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	e8 3b 00 00 00       	call   800081 <__x86.get_pc_thunk.bx>
  800046:	81 c3 ba 1f 00 00    	add    $0x1fba,%ebx
  80004c:	8b 45 08             	mov    0x8(%ebp),%eax
  80004f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  800052:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  800058:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	7e 08                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 0a                	mov    (%edx),%ecx
  800064:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	52                   	push   %edx
  80006e:	50                   	push   %eax
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0c 00 00 00       	call   800085 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007f:	c9                   	leave  
  800080:	c3                   	ret    

00800081 <__x86.get_pc_thunk.bx>:
  800081:	8b 1c 24             	mov    (%esp),%ebx
  800084:	c3                   	ret    

00800085 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800085:	55                   	push   %ebp
  800086:	89 e5                	mov    %esp,%ebp
  800088:	53                   	push   %ebx
  800089:	83 ec 10             	sub    $0x10,%esp
  80008c:	e8 f0 ff ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800091:	81 c3 6f 1f 00 00    	add    $0x1f6f,%ebx
	sys_env_destroy(0);
  800097:	6a 00                	push   $0x0
  800099:	e8 45 00 00 00       	call   8000e3 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 1c             	sub    $0x1c,%esp
  8000ec:	e8 66 00 00 00       	call   800157 <__x86.get_pc_thunk.ax>
  8000f1:	05 0f 1f 00 00       	add    $0x1f0f,%eax
  8000f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7f 08                	jg     80011a <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	50                   	push   %eax
  80011e:	6a 03                	push   $0x3
  800120:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800123:	8d 83 1e ee ff ff    	lea    -0x11e2(%ebx),%eax
  800129:	50                   	push   %eax
  80012a:	6a 23                	push   $0x23
  80012c:	8d 83 3b ee ff ff    	lea    -0x11c5(%ebx),%eax
  800132:	50                   	push   %eax
  800133:	e8 23 00 00 00       	call   80015b <_panic>

00800138 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	57                   	push   %edi
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013e:	ba 00 00 00 00       	mov    $0x0,%edx
  800143:	b8 02 00 00 00       	mov    $0x2,%eax
  800148:	89 d1                	mov    %edx,%ecx
  80014a:	89 d3                	mov    %edx,%ebx
  80014c:	89 d7                	mov    %edx,%edi
  80014e:	89 d6                	mov    %edx,%esi
  800150:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <__x86.get_pc_thunk.ax>:
  800157:	8b 04 24             	mov    (%esp),%eax
  80015a:	c3                   	ret    

0080015b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	e8 18 ff ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800169:	81 c3 97 1e 00 00    	add    $0x1e97,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016f:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800172:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800178:	8b 38                	mov    (%eax),%edi
  80017a:	e8 b9 ff ff ff       	call   800138 <sys_getenvid>
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 0c             	push   0xc(%ebp)
  800185:	ff 75 08             	push   0x8(%ebp)
  800188:	57                   	push   %edi
  800189:	50                   	push   %eax
  80018a:	8d 83 4c ee ff ff    	lea    -0x11b4(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 d1 00 00 00       	call   800267 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	83 c4 18             	add    $0x18,%esp
  800199:	56                   	push   %esi
  80019a:	ff 75 10             	push   0x10(%ebp)
  80019d:	e8 63 00 00 00       	call   800205 <vcprintf>
	cprintf("\n");
  8001a2:	8d 83 6f ee ff ff    	lea    -0x1191(%ebx),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 b7 00 00 00       	call   800267 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x58>

008001b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	e8 c1 fe ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  8001c0:	81 c3 40 1e 00 00    	add    $0x1e40,%ebx
  8001c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c9:	8b 16                	mov    (%esi),%edx
  8001cb:	8d 42 01             	lea    0x1(%edx),%eax
  8001ce:	89 06                	mov    %eax,(%esi)
  8001d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d3:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001dc:	74 0b                	je     8001e9 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001de:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	68 ff 00 00 00       	push   $0xff
  8001f1:	8d 46 08             	lea    0x8(%esi),%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 ac fe ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	eb d9                	jmp    8001de <putch+0x28>

00800205 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	53                   	push   %ebx
  800209:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020f:	e8 6d fe ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800214:	81 c3 ec 1d 00 00    	add    $0x1dec,%ebx
	struct printbuf b;

	b.idx = 0;
  80021a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800221:	00 00 00 
	b.cnt = 0;
  800224:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022e:	ff 75 0c             	push   0xc(%ebp)
  800231:	ff 75 08             	push   0x8(%ebp)
  800234:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023a:	50                   	push   %eax
  80023b:	8d 83 b6 e1 ff ff    	lea    -0x1e4a(%ebx),%eax
  800241:	50                   	push   %eax
  800242:	e8 2c 01 00 00       	call   800373 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	83 c4 08             	add    $0x8,%esp
  80024a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	e8 4a fe ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800270:	50                   	push   %eax
  800271:	ff 75 08             	push   0x8(%ebp)
  800274:	e8 8c ff ff ff       	call   800205 <vcprintf>
	va_end(ap);

	return cnt;
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
  800284:	e8 cf 05 00 00       	call   800858 <__x86.get_pc_thunk.cx>
  800289:	81 c1 77 1d 00 00    	add    $0x1d77,%ecx
  80028f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800292:	89 c7                	mov    %eax,%edi
  800294:	89 d6                	mov    %edx,%esi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029c:	89 d1                	mov    %edx,%ecx
  80029e:	89 c2                	mov    %eax,%edx
  8002a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b6:	39 c2                	cmp    %eax,%edx
  8002b8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002bb:	72 41                	jb     8002fe <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	ff 75 18             	push   0x18(%ebp)
  8002c3:	83 eb 01             	sub    $0x1,%ebx
  8002c6:	53                   	push   %ebx
  8002c7:	50                   	push   %eax
  8002c8:	83 ec 08             	sub    $0x8,%esp
  8002cb:	ff 75 e4             	push   -0x1c(%ebp)
  8002ce:	ff 75 e0             	push   -0x20(%ebp)
  8002d1:	ff 75 d4             	push   -0x2c(%ebp)
  8002d4:	ff 75 d0             	push   -0x30(%ebp)
  8002d7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002da:	e8 01 09 00 00       	call   800be0 <__udivdi3>
  8002df:	83 c4 18             	add    $0x18,%esp
  8002e2:	52                   	push   %edx
  8002e3:	50                   	push   %eax
  8002e4:	89 f2                	mov    %esi,%edx
  8002e6:	89 f8                	mov    %edi,%eax
  8002e8:	e8 8e ff ff ff       	call   80027b <printnum>
  8002ed:	83 c4 20             	add    $0x20,%esp
  8002f0:	eb 13                	jmp    800305 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	56                   	push   %esi
  8002f6:	ff 75 18             	push   0x18(%ebp)
  8002f9:	ff d7                	call   *%edi
  8002fb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002fe:	83 eb 01             	sub    $0x1,%ebx
  800301:	85 db                	test   %ebx,%ebx
  800303:	7f ed                	jg     8002f2 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	56                   	push   %esi
  800309:	83 ec 04             	sub    $0x4,%esp
  80030c:	ff 75 e4             	push   -0x1c(%ebp)
  80030f:	ff 75 e0             	push   -0x20(%ebp)
  800312:	ff 75 d4             	push   -0x2c(%ebp)
  800315:	ff 75 d0             	push   -0x30(%ebp)
  800318:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80031b:	e8 e0 09 00 00       	call   800d00 <__umoddi3>
  800320:	83 c4 14             	add    $0x14,%esp
  800323:	0f be 84 03 71 ee ff 	movsbl -0x118f(%ebx,%eax,1),%eax
  80032a:	ff 
  80032b:	50                   	push   %eax
  80032c:	ff d7                	call   *%edi
}
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800343:	8b 10                	mov    (%eax),%edx
  800345:	3b 50 04             	cmp    0x4(%eax),%edx
  800348:	73 0a                	jae    800354 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 45 08             	mov    0x8(%ebp),%eax
  800352:	88 02                	mov    %al,(%edx)
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <printfmt>:
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	50                   	push   %eax
  800360:	ff 75 10             	push   0x10(%ebp)
  800363:	ff 75 0c             	push   0xc(%ebp)
  800366:	ff 75 08             	push   0x8(%ebp)
  800369:	e8 05 00 00 00       	call   800373 <vprintfmt>
}
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <vprintfmt>:
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
  800379:	83 ec 3c             	sub    $0x3c,%esp
  80037c:	e8 d6 fd ff ff       	call   800157 <__x86.get_pc_thunk.ax>
  800381:	05 7f 1c 00 00       	add    $0x1c7f,%eax
  800386:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800389:	8b 75 08             	mov    0x8(%ebp),%esi
  80038c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038f:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800392:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800398:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80039b:	eb 0a                	jmp    8003a7 <vprintfmt+0x34>
			putch(ch, putdat);
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	57                   	push   %edi
  8003a1:	50                   	push   %eax
  8003a2:	ff d6                	call   *%esi
  8003a4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	83 c3 01             	add    $0x1,%ebx
  8003aa:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003ae:	83 f8 25             	cmp    $0x25,%eax
  8003b1:	74 0c                	je     8003bf <vprintfmt+0x4c>
			if (ch == '\0')
  8003b3:	85 c0                	test   %eax,%eax
  8003b5:	75 e6                	jne    80039d <vprintfmt+0x2a>
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
		padc = ' ';
  8003bf:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003c3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ca:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003dd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e0:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e9:	0f b6 13             	movzbl (%ebx),%edx
  8003ec:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ef:	3c 55                	cmp    $0x55,%al
  8003f1:	0f 87 c5 03 00 00    	ja     8007bc <.L20>
  8003f7:	0f b6 c0             	movzbl %al,%eax
  8003fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003fd:	89 ce                	mov    %ecx,%esi
  8003ff:	03 b4 81 00 ef ff ff 	add    -0x1100(%ecx,%eax,4),%esi
  800406:	ff e6                	jmp    *%esi

00800408 <.L66>:
  800408:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80040b:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80040f:	eb d2                	jmp    8003e3 <vprintfmt+0x70>

00800411 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800414:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800418:	eb c9                	jmp    8003e3 <vprintfmt+0x70>

0080041a <.L31>:
  80041a:	0f b6 d2             	movzbl %dl,%edx
  80041d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800420:	b8 00 00 00 00       	mov    $0x0,%eax
  800425:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800428:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042f:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800432:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800435:	83 f9 09             	cmp    $0x9,%ecx
  800438:	77 58                	ja     800492 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80043a:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80043d:	eb e9                	jmp    800428 <.L31+0xe>

0080043f <.L34>:
			precision = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8b 00                	mov    (%eax),%eax
  800444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 40 04             	lea    0x4(%eax),%eax
  80044d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800453:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800457:	79 8a                	jns    8003e3 <vprintfmt+0x70>
				width = precision, precision = -1;
  800459:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800466:	e9 78 ff ff ff       	jmp    8003e3 <vprintfmt+0x70>

0080046b <.L33>:
  80046b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80046e:	85 d2                	test   %edx,%edx
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 49 c2             	cmovns %edx,%eax
  800478:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80047e:	e9 60 ff ff ff       	jmp    8003e3 <vprintfmt+0x70>

00800483 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800486:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048d:	e9 51 ff ff ff       	jmp    8003e3 <vprintfmt+0x70>
  800492:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800495:	89 75 08             	mov    %esi,0x8(%ebp)
  800498:	eb b9                	jmp    800453 <.L34+0x14>

0080049a <.L27>:
			lflag++;
  80049a:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a1:	e9 3d ff ff ff       	jmp    8003e3 <vprintfmt+0x70>

008004a6 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 58 04             	lea    0x4(%eax),%ebx
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	57                   	push   %edi
  8004b3:	ff 30                	push   (%eax)
  8004b5:	ff d6                	call   *%esi
			break;
  8004b7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ba:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004bd:	e9 90 02 00 00       	jmp    800752 <.L25+0x45>

008004c2 <.L28>:
			err = va_arg(ap, int);
  8004c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	89 d0                	mov    %edx,%eax
  8004cf:	f7 d8                	neg    %eax
  8004d1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d4:	83 f8 06             	cmp    $0x6,%eax
  8004d7:	7f 27                	jg     800500 <.L28+0x3e>
  8004d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004dc:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	74 1d                	je     800500 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004e3:	52                   	push   %edx
  8004e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e7:	8d 80 92 ee ff ff    	lea    -0x116e(%eax),%eax
  8004ed:	50                   	push   %eax
  8004ee:	57                   	push   %edi
  8004ef:	56                   	push   %esi
  8004f0:	e8 61 fe ff ff       	call   800356 <printfmt>
  8004f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f8:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004fb:	e9 52 02 00 00       	jmp    800752 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800500:	50                   	push   %eax
  800501:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800504:	8d 80 89 ee ff ff    	lea    -0x1177(%eax),%eax
  80050a:	50                   	push   %eax
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	e8 44 fe ff ff       	call   800356 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800515:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 35 02 00 00       	jmp    800752 <.L25+0x45>

0080051d <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051d:	8b 75 08             	mov    0x8(%ebp),%esi
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	83 c0 04             	add    $0x4,%eax
  800526:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80052e:	85 d2                	test   %edx,%edx
  800530:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800533:	8d 80 82 ee ff ff    	lea    -0x117e(%eax),%eax
  800539:	0f 45 c2             	cmovne %edx,%eax
  80053c:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80053f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800543:	7e 06                	jle    80054b <.L24+0x2e>
  800545:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800549:	75 0d                	jne    800558 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054e:	89 c3                	mov    %eax,%ebx
  800550:	03 45 d0             	add    -0x30(%ebp),%eax
  800553:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800556:	eb 58                	jmp    8005b0 <.L24+0x93>
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 d8             	push   -0x28(%ebp)
  80055e:	ff 75 c8             	push   -0x38(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	e8 0b 03 00 00       	call   800874 <strnlen>
  800569:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80056c:	29 c2                	sub    %eax,%edx
  80056e:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800576:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80057a:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	eb 0f                	jmp    80058e <.L24+0x71>
					putch(padc, putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	57                   	push   %edi
  800583:	ff 75 d0             	push   -0x30(%ebp)
  800586:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	85 db                	test   %ebx,%ebx
  800590:	7f ed                	jg     80057f <.L24+0x62>
  800592:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	0f 49 c2             	cmovns %edx,%eax
  80059f:	29 c2                	sub    %eax,%edx
  8005a1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a4:	eb a5                	jmp    80054b <.L24+0x2e>
					putch(ch, putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	57                   	push   %edi
  8005aa:	52                   	push   %edx
  8005ab:	ff d6                	call   *%esi
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b3:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 c3 01             	add    $0x1,%ebx
  8005b8:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005bc:	0f be d0             	movsbl %al,%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 4b                	je     80060e <.L24+0xf1>
  8005c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c7:	78 06                	js     8005cf <.L24+0xb2>
  8005c9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005cd:	78 1e                	js     8005ed <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d3:	74 d1                	je     8005a6 <.L24+0x89>
  8005d5:	0f be c0             	movsbl %al,%eax
  8005d8:	83 e8 20             	sub    $0x20,%eax
  8005db:	83 f8 5e             	cmp    $0x5e,%eax
  8005de:	76 c6                	jbe    8005a6 <.L24+0x89>
					putch('?', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	57                   	push   %edi
  8005e4:	6a 3f                	push   $0x3f
  8005e6:	ff d6                	call   *%esi
  8005e8:	83 c4 10             	add    $0x10,%esp
  8005eb:	eb c3                	jmp    8005b0 <.L24+0x93>
  8005ed:	89 cb                	mov    %ecx,%ebx
  8005ef:	eb 0e                	jmp    8005ff <.L24+0xe2>
				putch(' ', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	57                   	push   %edi
  8005f5:	6a 20                	push   $0x20
  8005f7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f9:	83 eb 01             	sub    $0x1,%ebx
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	85 db                	test   %ebx,%ebx
  800601:	7f ee                	jg     8005f1 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800603:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
  800609:	e9 44 01 00 00       	jmp    800752 <.L25+0x45>
  80060e:	89 cb                	mov    %ecx,%ebx
  800610:	eb ed                	jmp    8005ff <.L24+0xe2>

00800612 <.L29>:
	if (lflag >= 2)
  800612:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	83 f9 01             	cmp    $0x1,%ecx
  80061b:	7f 1b                	jg     800638 <.L29+0x26>
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 63                	je     800684 <.L29+0x72>
		return va_arg(*ap, long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800629:	99                   	cltd   
  80062a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 40 04             	lea    0x4(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
  800636:	eb 17                	jmp    80064f <.L29+0x3d>
		return va_arg(*ap, long long);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 50 04             	mov    0x4(%eax),%edx
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 40 08             	lea    0x8(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800652:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800655:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80065a:	85 db                	test   %ebx,%ebx
  80065c:	0f 89 d6 00 00 00    	jns    800738 <.L25+0x2b>
				putch('-', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	57                   	push   %edi
  800666:	6a 2d                	push   $0x2d
  800668:	ff d6                	call   *%esi
				num = -(long long) num;
  80066a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800670:	f7 d9                	neg    %ecx
  800672:	83 d3 00             	adc    $0x0,%ebx
  800675:	f7 db                	neg    %ebx
  800677:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80067a:	ba 0a 00 00 00       	mov    $0xa,%edx
  80067f:	e9 b4 00 00 00       	jmp    800738 <.L25+0x2b>
		return va_arg(*ap, int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	99                   	cltd   
  80068d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 40 04             	lea    0x4(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
  800699:	eb b4                	jmp    80064f <.L29+0x3d>

0080069b <.L23>:
	if (lflag >= 2)
  80069b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	83 f9 01             	cmp    $0x1,%ecx
  8006a4:	7f 1b                	jg     8006c1 <.L23+0x26>
	else if (lflag)
  8006a6:	85 c9                	test   %ecx,%ecx
  8006a8:	74 2c                	je     8006d6 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 08                	mov    (%eax),%ecx
  8006af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ba:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006bf:	eb 77                	jmp    800738 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 08                	mov    (%eax),%ecx
  8006c6:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c9:	8d 40 08             	lea    0x8(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cf:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d4:	eb 62                	jmp    800738 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 08                	mov    (%eax),%ecx
  8006db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006eb:	eb 4b                	jmp    800738 <.L25+0x2b>

008006ed <.L26>:
			putch('X', putdat);
  8006ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	57                   	push   %edi
  8006f4:	6a 58                	push   $0x58
  8006f6:	ff d6                	call   *%esi
			putch('X', putdat);
  8006f8:	83 c4 08             	add    $0x8,%esp
  8006fb:	57                   	push   %edi
  8006fc:	6a 58                	push   $0x58
  8006fe:	ff d6                	call   *%esi
			putch('X', putdat);
  800700:	83 c4 08             	add    $0x8,%esp
  800703:	57                   	push   %edi
  800704:	6a 58                	push   $0x58
  800706:	ff d6                	call   *%esi
			break;
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 45                	jmp    800752 <.L25+0x45>

0080070d <.L25>:
			putch('0', putdat);
  80070d:	8b 75 08             	mov    0x8(%ebp),%esi
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	57                   	push   %edi
  800714:	6a 30                	push   $0x30
  800716:	ff d6                	call   *%esi
			putch('x', putdat);
  800718:	83 c4 08             	add    $0x8,%esp
  80071b:	57                   	push   %edi
  80071c:	6a 78                	push   $0x78
  80071e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 08                	mov    (%eax),%ecx
  800725:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80072a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072d:	8d 40 04             	lea    0x4(%eax),%eax
  800730:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800733:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800738:	83 ec 0c             	sub    $0xc,%esp
  80073b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	ff 75 d0             	push   -0x30(%ebp)
  800743:	52                   	push   %edx
  800744:	53                   	push   %ebx
  800745:	51                   	push   %ecx
  800746:	89 fa                	mov    %edi,%edx
  800748:	89 f0                	mov    %esi,%eax
  80074a:	e8 2c fb ff ff       	call   80027b <printnum>
			break;
  80074f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800752:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800755:	e9 4d fc ff ff       	jmp    8003a7 <vprintfmt+0x34>

0080075a <.L21>:
	if (lflag >= 2)
  80075a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	83 f9 01             	cmp    $0x1,%ecx
  800763:	7f 1b                	jg     800780 <.L21+0x26>
	else if (lflag)
  800765:	85 c9                	test   %ecx,%ecx
  800767:	74 2c                	je     800795 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8b 08                	mov    (%eax),%ecx
  80076e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800773:	8d 40 04             	lea    0x4(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800779:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80077e:	eb b8                	jmp    800738 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8b 08                	mov    (%eax),%ecx
  800785:	8b 58 04             	mov    0x4(%eax),%ebx
  800788:	8d 40 08             	lea    0x8(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078e:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  800793:	eb a3                	jmp    800738 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 08                	mov    (%eax),%ecx
  80079a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80079f:	8d 40 04             	lea    0x4(%eax),%eax
  8007a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a5:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007aa:	eb 8c                	jmp    800738 <.L25+0x2b>

008007ac <.L35>:
			putch(ch, putdat);
  8007ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	57                   	push   %edi
  8007b3:	6a 25                	push   $0x25
  8007b5:	ff d6                	call   *%esi
			break;
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	eb 96                	jmp    800752 <.L25+0x45>

008007bc <.L20>:
			putch('%', putdat);
  8007bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	57                   	push   %edi
  8007c3:	6a 25                	push   $0x25
  8007c5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007d0:	74 05                	je     8007d7 <.L20+0x1b>
  8007d2:	83 e8 01             	sub    $0x1,%eax
  8007d5:	eb f5                	jmp    8007cc <.L20+0x10>
  8007d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007da:	e9 73 ff ff ff       	jmp    800752 <.L25+0x45>

008007df <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	83 ec 14             	sub    $0x14,%esp
  8007e6:	e8 96 f8 ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  8007eb:	81 c3 15 18 00 00    	add    $0x1815,%ebx
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800801:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800808:	85 c0                	test   %eax,%eax
  80080a:	74 2b                	je     800837 <vsnprintf+0x58>
  80080c:	85 d2                	test   %edx,%edx
  80080e:	7e 27                	jle    800837 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800810:	ff 75 14             	push   0x14(%ebp)
  800813:	ff 75 10             	push   0x10(%ebp)
  800816:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800819:	50                   	push   %eax
  80081a:	8d 83 39 e3 ff ff    	lea    -0x1cc7(%ebx),%eax
  800820:	50                   	push   %eax
  800821:	e8 4d fb ff ff       	call   800373 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800826:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800829:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082f:	83 c4 10             	add    $0x10,%esp
}
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    
		return -E_INVAL;
  800837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083c:	eb f4                	jmp    800832 <vsnprintf+0x53>

0080083e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800847:	50                   	push   %eax
  800848:	ff 75 10             	push   0x10(%ebp)
  80084b:	ff 75 0c             	push   0xc(%ebp)
  80084e:	ff 75 08             	push   0x8(%ebp)
  800851:	e8 89 ff ff ff       	call   8007df <vsnprintf>
	va_end(ap);

	return rc;
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <__x86.get_pc_thunk.cx>:
  800858:	8b 0c 24             	mov    (%esp),%ecx
  80085b:	c3                   	ret    

0080085c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
  800867:	eb 03                	jmp    80086c <strlen+0x10>
		n++;
  800869:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80086c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800870:	75 f7                	jne    800869 <strlen+0xd>
	return n;
}
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
  800882:	eb 03                	jmp    800887 <strnlen+0x13>
		n++;
  800884:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800887:	39 d0                	cmp    %edx,%eax
  800889:	74 08                	je     800893 <strnlen+0x1f>
  80088b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80088f:	75 f3                	jne    800884 <strnlen+0x10>
  800891:	89 c2                	mov    %eax,%edx
	return n;
}
  800893:	89 d0                	mov    %edx,%eax
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008aa:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	75 f2                	jne    8008a6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b4:	89 c8                	mov    %ecx,%eax
  8008b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b9:	c9                   	leave  
  8008ba:	c3                   	ret    

008008bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 10             	sub    $0x10,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	53                   	push   %ebx
  8008c6:	e8 91 ff ff ff       	call   80085c <strlen>
  8008cb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ce:	ff 75 0c             	push   0xc(%ebp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	50                   	push   %eax
  8008d4:	e8 be ff ff ff       	call   800897 <strcpy>
	return dst;
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 f3                	mov    %esi,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f0:	89 f0                	mov    %esi,%eax
  8008f2:	eb 0f                	jmp    800903 <strncpy+0x23>
		*dst++ = *src;
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 0a             	movzbl (%edx),%ecx
  8008fa:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008fd:	80 f9 01             	cmp    $0x1,%cl
  800900:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800903:	39 d8                	cmp    %ebx,%eax
  800905:	75 ed                	jne    8008f4 <strncpy+0x14>
	}
	return ret;
}
  800907:	89 f0                	mov    %esi,%eax
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	56                   	push   %esi
  800911:	53                   	push   %ebx
  800912:	8b 75 08             	mov    0x8(%ebp),%esi
  800915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800918:	8b 55 10             	mov    0x10(%ebp),%edx
  80091b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80091d:	85 d2                	test   %edx,%edx
  80091f:	74 21                	je     800942 <strlcpy+0x35>
  800921:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800925:	89 f2                	mov    %esi,%edx
  800927:	eb 09                	jmp    800932 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800932:	39 c2                	cmp    %eax,%edx
  800934:	74 09                	je     80093f <strlcpy+0x32>
  800936:	0f b6 19             	movzbl (%ecx),%ebx
  800939:	84 db                	test   %bl,%bl
  80093b:	75 ec                	jne    800929 <strlcpy+0x1c>
  80093d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80093f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800942:	29 f0                	sub    %esi,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800951:	eb 06                	jmp    800959 <strcmp+0x11>
		p++, q++;
  800953:	83 c1 01             	add    $0x1,%ecx
  800956:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800959:	0f b6 01             	movzbl (%ecx),%eax
  80095c:	84 c0                	test   %al,%al
  80095e:	74 04                	je     800964 <strcmp+0x1c>
  800960:	3a 02                	cmp    (%edx),%al
  800962:	74 ef                	je     800953 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800964:	0f b6 c0             	movzbl %al,%eax
  800967:	0f b6 12             	movzbl (%edx),%edx
  80096a:	29 d0                	sub    %edx,%eax
}
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	53                   	push   %ebx
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
  800978:	89 c3                	mov    %eax,%ebx
  80097a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80097d:	eb 06                	jmp    800985 <strncmp+0x17>
		n--, p++, q++;
  80097f:	83 c0 01             	add    $0x1,%eax
  800982:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800985:	39 d8                	cmp    %ebx,%eax
  800987:	74 18                	je     8009a1 <strncmp+0x33>
  800989:	0f b6 08             	movzbl (%eax),%ecx
  80098c:	84 c9                	test   %cl,%cl
  80098e:	74 04                	je     800994 <strncmp+0x26>
  800990:	3a 0a                	cmp    (%edx),%cl
  800992:	74 eb                	je     80097f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800994:	0f b6 00             	movzbl (%eax),%eax
  800997:	0f b6 12             	movzbl (%edx),%edx
  80099a:	29 d0                	sub    %edx,%eax
}
  80099c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    
		return 0;
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a6:	eb f4                	jmp    80099c <strncmp+0x2e>

008009a8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b2:	eb 03                	jmp    8009b7 <strchr+0xf>
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	0f b6 10             	movzbl (%eax),%edx
  8009ba:	84 d2                	test   %dl,%dl
  8009bc:	74 06                	je     8009c4 <strchr+0x1c>
		if (*s == c)
  8009be:	38 ca                	cmp    %cl,%dl
  8009c0:	75 f2                	jne    8009b4 <strchr+0xc>
  8009c2:	eb 05                	jmp    8009c9 <strchr+0x21>
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d8:	38 ca                	cmp    %cl,%dl
  8009da:	74 09                	je     8009e5 <strfind+0x1a>
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	74 05                	je     8009e5 <strfind+0x1a>
	for (; *s; s++)
  8009e0:	83 c0 01             	add    $0x1,%eax
  8009e3:	eb f0                	jmp    8009d5 <strfind+0xa>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 2f                	je     800a26 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	89 f8                	mov    %edi,%eax
  8009f9:	09 c8                	or     %ecx,%eax
  8009fb:	a8 03                	test   $0x3,%al
  8009fd:	75 21                	jne    800a20 <memset+0x39>
		c &= 0xFF;
  8009ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	c1 e0 08             	shl    $0x8,%eax
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 18             	shl    $0x18,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 10             	shl    $0x10,%esi
  800a12:	09 f3                	or     %esi,%ebx
  800a14:	09 da                	or     %ebx,%edx
  800a16:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a18:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a1b:	fc                   	cld    
  800a1c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a1e:	eb 06                	jmp    800a26 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	fc                   	cld    
  800a24:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a26:	89 f8                	mov    %edi,%eax
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3b:	39 c6                	cmp    %eax,%esi
  800a3d:	73 32                	jae    800a71 <memmove+0x44>
  800a3f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a42:	39 c2                	cmp    %eax,%edx
  800a44:	76 2b                	jbe    800a71 <memmove+0x44>
		s += n;
		d += n;
  800a46:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a49:	89 d6                	mov    %edx,%esi
  800a4b:	09 fe                	or     %edi,%esi
  800a4d:	09 ce                	or     %ecx,%esi
  800a4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a55:	75 0e                	jne    800a65 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a57:	83 ef 04             	sub    $0x4,%edi
  800a5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a60:	fd                   	std    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a63:	eb 09                	jmp    800a6e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a65:	83 ef 01             	sub    $0x1,%edi
  800a68:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6b:	fd                   	std    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6e:	fc                   	cld    
  800a6f:	eb 1a                	jmp    800a8b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a71:	89 f2                	mov    %esi,%edx
  800a73:	09 c2                	or     %eax,%edx
  800a75:	09 ca                	or     %ecx,%edx
  800a77:	f6 c2 03             	test   $0x3,%dl
  800a7a:	75 0a                	jne    800a86 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	fc                   	cld    
  800a82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a84:	eb 05                	jmp    800a8b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a95:	ff 75 10             	push   0x10(%ebp)
  800a98:	ff 75 0c             	push   0xc(%ebp)
  800a9b:	ff 75 08             	push   0x8(%ebp)
  800a9e:	e8 8a ff ff ff       	call   800a2d <memmove>
}
  800aa3:	c9                   	leave  
  800aa4:	c3                   	ret    

00800aa5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab0:	89 c6                	mov    %eax,%esi
  800ab2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab5:	eb 06                	jmp    800abd <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800abd:	39 f0                	cmp    %esi,%eax
  800abf:	74 14                	je     800ad5 <memcmp+0x30>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	74 ec                	je     800ab7 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800acb:	0f b6 c1             	movzbl %cl,%eax
  800ace:	0f b6 db             	movzbl %bl,%ebx
  800ad1:	29 d8                	sub    %ebx,%eax
  800ad3:	eb 05                	jmp    800ada <memcmp+0x35>
	}

	return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae7:	89 c2                	mov    %eax,%edx
  800ae9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aec:	eb 03                	jmp    800af1 <memfind+0x13>
  800aee:	83 c0 01             	add    $0x1,%eax
  800af1:	39 d0                	cmp    %edx,%eax
  800af3:	73 04                	jae    800af9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af5:	38 08                	cmp    %cl,(%eax)
  800af7:	75 f5                	jne    800aee <memfind+0x10>
			break;
	return (void *) s;
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b07:	eb 03                	jmp    800b0c <strtol+0x11>
		s++;
  800b09:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b0c:	0f b6 02             	movzbl (%edx),%eax
  800b0f:	3c 20                	cmp    $0x20,%al
  800b11:	74 f6                	je     800b09 <strtol+0xe>
  800b13:	3c 09                	cmp    $0x9,%al
  800b15:	74 f2                	je     800b09 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b17:	3c 2b                	cmp    $0x2b,%al
  800b19:	74 2a                	je     800b45 <strtol+0x4a>
	int neg = 0;
  800b1b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b20:	3c 2d                	cmp    $0x2d,%al
  800b22:	74 2b                	je     800b4f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2a:	75 0f                	jne    800b3b <strtol+0x40>
  800b2c:	80 3a 30             	cmpb   $0x30,(%edx)
  800b2f:	74 28                	je     800b59 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b31:	85 db                	test   %ebx,%ebx
  800b33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b38:	0f 44 d8             	cmove  %eax,%ebx
  800b3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b40:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b43:	eb 46                	jmp    800b8b <strtol+0x90>
		s++;
  800b45:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4d:	eb d5                	jmp    800b24 <strtol+0x29>
		s++, neg = 1;
  800b4f:	83 c2 01             	add    $0x1,%edx
  800b52:	bf 01 00 00 00       	mov    $0x1,%edi
  800b57:	eb cb                	jmp    800b24 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5d:	74 0e                	je     800b6d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b5f:	85 db                	test   %ebx,%ebx
  800b61:	75 d8                	jne    800b3b <strtol+0x40>
		s++, base = 8;
  800b63:	83 c2 01             	add    $0x1,%edx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b6b:	eb ce                	jmp    800b3b <strtol+0x40>
		s += 2, base = 16;
  800b6d:	83 c2 02             	add    $0x2,%edx
  800b70:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b75:	eb c4                	jmp    800b3b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b77:	0f be c0             	movsbl %al,%eax
  800b7a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7d:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b80:	7d 3a                	jge    800bbc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b82:	83 c2 01             	add    $0x1,%edx
  800b85:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b89:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b8b:	0f b6 02             	movzbl (%edx),%eax
  800b8e:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b91:	89 f3                	mov    %esi,%ebx
  800b93:	80 fb 09             	cmp    $0x9,%bl
  800b96:	76 df                	jbe    800b77 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b98:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b9b:	89 f3                	mov    %esi,%ebx
  800b9d:	80 fb 19             	cmp    $0x19,%bl
  800ba0:	77 08                	ja     800baa <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ba2:	0f be c0             	movsbl %al,%eax
  800ba5:	83 e8 57             	sub    $0x57,%eax
  800ba8:	eb d3                	jmp    800b7d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800baa:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bad:	89 f3                	mov    %esi,%ebx
  800baf:	80 fb 19             	cmp    $0x19,%bl
  800bb2:	77 08                	ja     800bbc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bb4:	0f be c0             	movsbl %al,%eax
  800bb7:	83 e8 37             	sub    $0x37,%eax
  800bba:	eb c1                	jmp    800b7d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc0:	74 05                	je     800bc7 <strtol+0xcc>
		*endptr = (char *) s;
  800bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc5:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bc7:	89 c8                	mov    %ecx,%eax
  800bc9:	f7 d8                	neg    %eax
  800bcb:	85 ff                	test   %edi,%edi
  800bcd:	0f 45 c8             	cmovne %eax,%ecx
}
  800bd0:	89 c8                	mov    %ecx,%eax
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    
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
