
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 2c 00 00 00       	call   80005d <libmain>
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
  80003a:	e8 1a 00 00 00       	call   800059 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800045:	6a 64                	push   $0x64
  800047:	68 0c 00 10 f0       	push   $0xf010000c
  80004c:	e8 74 00 00 00       	call   8000c5 <sys_cputs>
}
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <__x86.get_pc_thunk.bx>:
  800059:	8b 1c 24             	mov    (%esp),%ebx
  80005c:	c3                   	ret    

0080005d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	53                   	push   %ebx
  800061:	83 ec 04             	sub    $0x4,%esp
  800064:	e8 f0 ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800069:	81 c3 97 1f 00 00    	add    $0x1f97,%ebx
  80006f:	8b 45 08             	mov    0x8(%ebp),%eax
  800072:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs;
  800075:	c7 c1 00 00 c0 ee    	mov    $0xeec00000,%ecx
  80007b:	89 8b 2c 00 00 00    	mov    %ecx,0x2c(%ebx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 c0                	test   %eax,%eax
  800083:	7e 08                	jle    80008d <libmain+0x30>
		binaryname = argv[0];
  800085:	8b 0a                	mov    (%edx),%ecx
  800087:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	52                   	push   %edx
  800091:	50                   	push   %eax
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 08 00 00 00       	call   8000a4 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	53                   	push   %ebx
  8000a8:	83 ec 10             	sub    $0x10,%esp
  8000ab:	e8 a9 ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8000b0:	81 c3 50 1f 00 00    	add    $0x1f50,%ebx
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 45 00 00 00       	call   800102 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 1c             	sub    $0x1c,%esp
  80010b:	e8 66 00 00 00       	call   800176 <__x86.get_pc_thunk.ax>
  800110:	05 f0 1e 00 00       	add    $0x1ef0,%eax
  800115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011d:	8b 55 08             	mov    0x8(%ebp),%edx
  800120:	b8 03 00 00 00       	mov    $0x3,%eax
  800125:	89 cb                	mov    %ecx,%ebx
  800127:	89 cf                	mov    %ecx,%edi
  800129:	89 ce                	mov    %ecx,%esi
  80012b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012d:	85 c0                	test   %eax,%eax
  80012f:	7f 08                	jg     800139 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800142:	8d 83 3e ee ff ff    	lea    -0x11c2(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	6a 23                	push   $0x23
  80014b:	8d 83 5b ee ff ff    	lea    -0x11a5(%ebx),%eax
  800151:	50                   	push   %eax
  800152:	e8 23 00 00 00       	call   80017a <_panic>

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <__x86.get_pc_thunk.ax>:
  800176:	8b 04 24             	mov    (%esp),%eax
  800179:	c3                   	ret    

0080017a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	e8 d1 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800188:	81 c3 78 1e 00 00    	add    $0x1e78,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800191:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800197:	8b 38                	mov    (%eax),%edi
  800199:	e8 b9 ff ff ff       	call   800157 <sys_getenvid>
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 0c             	push   0xc(%ebp)
  8001a4:	ff 75 08             	push   0x8(%ebp)
  8001a7:	57                   	push   %edi
  8001a8:	50                   	push   %eax
  8001a9:	8d 83 6c ee ff ff    	lea    -0x1194(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 d1 00 00 00       	call   800286 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	56                   	push   %esi
  8001b9:	ff 75 10             	push   0x10(%ebp)
  8001bc:	e8 63 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  8001c1:	8d 83 8f ee ff ff    	lea    -0x1171(%ebx),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 b7 00 00 00       	call   800286 <cprintf>
  8001cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x58>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	e8 7a fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8001df:	81 c3 21 1e 00 00    	add    $0x1e21,%ebx
  8001e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e8:	8b 16                	mov    (%esi),%edx
  8001ea:	8d 42 01             	lea    0x1(%edx),%eax
  8001ed:	89 06                	mov    %eax,(%esi)
  8001ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f2:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fb:	74 0b                	je     800208 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fd:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	68 ff 00 00 00       	push   $0xff
  800210:	8d 46 08             	lea    0x8(%esi),%eax
  800213:	50                   	push   %eax
  800214:	e8 ac fe ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  800219:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	eb d9                	jmp    8001fd <putch+0x28>

00800224 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022e:	e8 26 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800233:	81 c3 cd 1d 00 00    	add    $0x1dcd,%ebx
	struct printbuf b;

	b.idx = 0;
  800239:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800240:	00 00 00 
	b.cnt = 0;
  800243:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024d:	ff 75 0c             	push   0xc(%ebp)
  800250:	ff 75 08             	push   0x8(%ebp)
  800253:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800259:	50                   	push   %eax
  80025a:	8d 83 d5 e1 ff ff    	lea    -0x1e2b(%ebx),%eax
  800260:	50                   	push   %eax
  800261:	e8 2c 01 00 00       	call   800392 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800266:	83 c4 08             	add    $0x8,%esp
  800269:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80026f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	e8 4a fe ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80027b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028f:	50                   	push   %eax
  800290:	ff 75 08             	push   0x8(%ebp)
  800293:	e8 8c ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	57                   	push   %edi
  80029e:	56                   	push   %esi
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 2c             	sub    $0x2c,%esp
  8002a3:	e8 cf 05 00 00       	call   800877 <__x86.get_pc_thunk.cx>
  8002a8:	81 c1 58 1d 00 00    	add    $0x1d58,%ecx
  8002ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 d1                	mov    %edx,%ecx
  8002bd:	89 c2                	mov    %eax,%edx
  8002bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d5:	39 c2                	cmp    %eax,%edx
  8002d7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002da:	72 41                	jb     80031d <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	ff 75 18             	push   0x18(%ebp)
  8002e2:	83 eb 01             	sub    $0x1,%ebx
  8002e5:	53                   	push   %ebx
  8002e6:	50                   	push   %eax
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	ff 75 e4             	push   -0x1c(%ebp)
  8002ed:	ff 75 e0             	push   -0x20(%ebp)
  8002f0:	ff 75 d4             	push   -0x2c(%ebp)
  8002f3:	ff 75 d0             	push   -0x30(%ebp)
  8002f6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f9:	e8 02 09 00 00       	call   800c00 <__udivdi3>
  8002fe:	83 c4 18             	add    $0x18,%esp
  800301:	52                   	push   %edx
  800302:	50                   	push   %eax
  800303:	89 f2                	mov    %esi,%edx
  800305:	89 f8                	mov    %edi,%eax
  800307:	e8 8e ff ff ff       	call   80029a <printnum>
  80030c:	83 c4 20             	add    $0x20,%esp
  80030f:	eb 13                	jmp    800324 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	56                   	push   %esi
  800315:	ff 75 18             	push   0x18(%ebp)
  800318:	ff d7                	call   *%edi
  80031a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f ed                	jg     800311 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800324:	83 ec 08             	sub    $0x8,%esp
  800327:	56                   	push   %esi
  800328:	83 ec 04             	sub    $0x4,%esp
  80032b:	ff 75 e4             	push   -0x1c(%ebp)
  80032e:	ff 75 e0             	push   -0x20(%ebp)
  800331:	ff 75 d4             	push   -0x2c(%ebp)
  800334:	ff 75 d0             	push   -0x30(%ebp)
  800337:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80033a:	e8 e1 09 00 00       	call   800d20 <__umoddi3>
  80033f:	83 c4 14             	add    $0x14,%esp
  800342:	0f be 84 03 91 ee ff 	movsbl -0x116f(%ebx,%eax,1),%eax
  800349:	ff 
  80034a:	50                   	push   %eax
  80034b:	ff d7                	call   *%edi
}
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800362:	8b 10                	mov    (%eax),%edx
  800364:	3b 50 04             	cmp    0x4(%eax),%edx
  800367:	73 0a                	jae    800373 <sprintputch+0x1b>
		*b->buf++ = ch;
  800369:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	88 02                	mov    %al,(%edx)
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <printfmt>:
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037e:	50                   	push   %eax
  80037f:	ff 75 10             	push   0x10(%ebp)
  800382:	ff 75 0c             	push   0xc(%ebp)
  800385:	ff 75 08             	push   0x8(%ebp)
  800388:	e8 05 00 00 00       	call   800392 <vprintfmt>
}
  80038d:	83 c4 10             	add    $0x10,%esp
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vprintfmt>:
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	57                   	push   %edi
  800396:	56                   	push   %esi
  800397:	53                   	push   %ebx
  800398:	83 ec 3c             	sub    $0x3c,%esp
  80039b:	e8 d6 fd ff ff       	call   800176 <__x86.get_pc_thunk.ax>
  8003a0:	05 60 1c 00 00       	add    $0x1c60,%eax
  8003a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b1:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003b7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003ba:	eb 0a                	jmp    8003c6 <vprintfmt+0x34>
			putch(ch, putdat);
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	57                   	push   %edi
  8003c0:	50                   	push   %eax
  8003c1:	ff d6                	call   *%esi
  8003c3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c6:	83 c3 01             	add    $0x1,%ebx
  8003c9:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003cd:	83 f8 25             	cmp    $0x25,%eax
  8003d0:	74 0c                	je     8003de <vprintfmt+0x4c>
			if (ch == '\0')
  8003d2:	85 c0                	test   %eax,%eax
  8003d4:	75 e6                	jne    8003bc <vprintfmt+0x2a>
}
  8003d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d9:	5b                   	pop    %ebx
  8003da:	5e                   	pop    %esi
  8003db:	5f                   	pop    %edi
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    
		padc = ' ';
  8003de:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003e9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003ff:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8d 43 01             	lea    0x1(%ebx),%eax
  800405:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800408:	0f b6 13             	movzbl (%ebx),%edx
  80040b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040e:	3c 55                	cmp    $0x55,%al
  800410:	0f 87 c5 03 00 00    	ja     8007db <.L20>
  800416:	0f b6 c0             	movzbl %al,%eax
  800419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041c:	89 ce                	mov    %ecx,%esi
  80041e:	03 b4 81 20 ef ff ff 	add    -0x10e0(%ecx,%eax,4),%esi
  800425:	ff e6                	jmp    *%esi

00800427 <.L66>:
  800427:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80042a:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80042e:	eb d2                	jmp    800402 <vprintfmt+0x70>

00800430 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800433:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800437:	eb c9                	jmp    800402 <vprintfmt+0x70>

00800439 <.L31>:
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800447:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80044a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800451:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800454:	83 f9 09             	cmp    $0x9,%ecx
  800457:	77 58                	ja     8004b1 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800459:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80045c:	eb e9                	jmp    800447 <.L31+0xe>

0080045e <.L34>:
			precision = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8b 00                	mov    (%eax),%eax
  800463:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 40 04             	lea    0x4(%eax),%eax
  80046c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800472:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800476:	79 8a                	jns    800402 <vprintfmt+0x70>
				width = precision, precision = -1;
  800478:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80047b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80047e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800485:	e9 78 ff ff ff       	jmp    800402 <vprintfmt+0x70>

0080048a <.L33>:
  80048a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	0f 49 c2             	cmovns %edx,%eax
  800497:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049d:	e9 60 ff ff ff       	jmp    800402 <vprintfmt+0x70>

008004a2 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ac:	e9 51 ff ff ff       	jmp    800402 <vprintfmt+0x70>
  8004b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b7:	eb b9                	jmp    800472 <.L34+0x14>

008004b9 <.L27>:
			lflag++;
  8004b9:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004c0:	e9 3d ff ff ff       	jmp    800402 <vprintfmt+0x70>

008004c5 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	57                   	push   %edi
  8004d2:	ff 30                	push   (%eax)
  8004d4:	ff d6                	call   *%esi
			break;
  8004d6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d9:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004dc:	e9 90 02 00 00       	jmp    800771 <.L25+0x45>

008004e1 <.L28>:
			err = va_arg(ap, int);
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	89 d0                	mov    %edx,%eax
  8004ee:	f7 d8                	neg    %eax
  8004f0:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 06             	cmp    $0x6,%eax
  8004f6:	7f 27                	jg     80051f <.L28+0x3e>
  8004f8:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fb:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	74 1d                	je     80051f <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  800502:	52                   	push   %edx
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  80050c:	50                   	push   %eax
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	e8 61 fe ff ff       	call   800375 <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800517:	89 5d 14             	mov    %ebx,0x14(%ebp)
  80051a:	e9 52 02 00 00       	jmp    800771 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80051f:	50                   	push   %eax
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	8d 80 a9 ee ff ff    	lea    -0x1157(%eax),%eax
  800529:	50                   	push   %eax
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	e8 44 fe ff ff       	call   800375 <printfmt>
  800531:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800534:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800537:	e9 35 02 00 00       	jmp    800771 <.L25+0x45>

0080053c <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80053c:	8b 75 08             	mov    0x8(%ebp),%esi
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	83 c0 04             	add    $0x4,%eax
  800545:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80054d:	85 d2                	test   %edx,%edx
  80054f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800552:	8d 80 a2 ee ff ff    	lea    -0x115e(%eax),%eax
  800558:	0f 45 c2             	cmovne %edx,%eax
  80055b:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80055e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800562:	7e 06                	jle    80056a <.L24+0x2e>
  800564:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800568:	75 0d                	jne    800577 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80056a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056d:	89 c3                	mov    %eax,%ebx
  80056f:	03 45 d0             	add    -0x30(%ebp),%eax
  800572:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800575:	eb 58                	jmp    8005cf <.L24+0x93>
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	ff 75 d8             	push   -0x28(%ebp)
  80057d:	ff 75 c8             	push   -0x38(%ebp)
  800580:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800583:	e8 0b 03 00 00       	call   800893 <strnlen>
  800588:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80058b:	29 c2                	sub    %eax,%edx
  80058d:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800595:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800599:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059c:	eb 0f                	jmp    8005ad <.L24+0x71>
					putch(padc, putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	57                   	push   %edi
  8005a2:	ff 75 d0             	push   -0x30(%ebp)
  8005a5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a7:	83 eb 01             	sub    $0x1,%ebx
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	85 db                	test   %ebx,%ebx
  8005af:	7f ed                	jg     80059e <.L24+0x62>
  8005b1:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bb:	0f 49 c2             	cmovns %edx,%eax
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c3:	eb a5                	jmp    80056a <.L24+0x2e>
					putch(ch, putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	57                   	push   %edi
  8005c9:	52                   	push   %edx
  8005ca:	ff d6                	call   *%esi
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d2:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d4:	83 c3 01             	add    $0x1,%ebx
  8005d7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005db:	0f be d0             	movsbl %al,%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 4b                	je     80062d <.L24+0xf1>
  8005e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e6:	78 06                	js     8005ee <.L24+0xb2>
  8005e8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ec:	78 1e                	js     80060c <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f2:	74 d1                	je     8005c5 <.L24+0x89>
  8005f4:	0f be c0             	movsbl %al,%eax
  8005f7:	83 e8 20             	sub    $0x20,%eax
  8005fa:	83 f8 5e             	cmp    $0x5e,%eax
  8005fd:	76 c6                	jbe    8005c5 <.L24+0x89>
					putch('?', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	57                   	push   %edi
  800603:	6a 3f                	push   $0x3f
  800605:	ff d6                	call   *%esi
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	eb c3                	jmp    8005cf <.L24+0x93>
  80060c:	89 cb                	mov    %ecx,%ebx
  80060e:	eb 0e                	jmp    80061e <.L24+0xe2>
				putch(' ', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	57                   	push   %edi
  800614:	6a 20                	push   $0x20
  800616:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800618:	83 eb 01             	sub    $0x1,%ebx
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	85 db                	test   %ebx,%ebx
  800620:	7f ee                	jg     800610 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800622:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
  800628:	e9 44 01 00 00       	jmp    800771 <.L25+0x45>
  80062d:	89 cb                	mov    %ecx,%ebx
  80062f:	eb ed                	jmp    80061e <.L24+0xe2>

00800631 <.L29>:
	if (lflag >= 2)
  800631:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800634:	8b 75 08             	mov    0x8(%ebp),%esi
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7f 1b                	jg     800657 <.L29+0x26>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 63                	je     8006a3 <.L29+0x72>
		return va_arg(*ap, long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	99                   	cltd   
  800649:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 40 04             	lea    0x4(%eax),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
  800655:	eb 17                	jmp    80066e <.L29+0x3d>
		return va_arg(*ap, long long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 50 04             	mov    0x4(%eax),%edx
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 40 08             	lea    0x8(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80066e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800671:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800674:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800679:	85 db                	test   %ebx,%ebx
  80067b:	0f 89 d6 00 00 00    	jns    800757 <.L25+0x2b>
				putch('-', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	57                   	push   %edi
  800685:	6a 2d                	push   $0x2d
  800687:	ff d6                	call   *%esi
				num = -(long long) num;
  800689:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80068c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068f:	f7 d9                	neg    %ecx
  800691:	83 d3 00             	adc    $0x0,%ebx
  800694:	f7 db                	neg    %ebx
  800696:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800699:	ba 0a 00 00 00       	mov    $0xa,%edx
  80069e:	e9 b4 00 00 00       	jmp    800757 <.L25+0x2b>
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ab:	99                   	cltd   
  8006ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b8:	eb b4                	jmp    80066e <.L29+0x3d>

008006ba <.L23>:
	if (lflag >= 2)
  8006ba:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c0:	83 f9 01             	cmp    $0x1,%ecx
  8006c3:	7f 1b                	jg     8006e0 <.L23+0x26>
	else if (lflag)
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	74 2c                	je     8006f5 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 08                	mov    (%eax),%ecx
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d9:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006de:	eb 77                	jmp    800757 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 08                	mov    (%eax),%ecx
  8006e5:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e8:	8d 40 08             	lea    0x8(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ee:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f3:	eb 62                	jmp    800757 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 08                	mov    (%eax),%ecx
  8006fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800705:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  80070a:	eb 4b                	jmp    800757 <.L25+0x2b>

0080070c <.L26>:
			putch('X', putdat);
  80070c:	8b 75 08             	mov    0x8(%ebp),%esi
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	57                   	push   %edi
  800713:	6a 58                	push   $0x58
  800715:	ff d6                	call   *%esi
			putch('X', putdat);
  800717:	83 c4 08             	add    $0x8,%esp
  80071a:	57                   	push   %edi
  80071b:	6a 58                	push   $0x58
  80071d:	ff d6                	call   *%esi
			putch('X', putdat);
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	57                   	push   %edi
  800723:	6a 58                	push   $0x58
  800725:	ff d6                	call   *%esi
			break;
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	eb 45                	jmp    800771 <.L25+0x45>

0080072c <.L25>:
			putch('0', putdat);
  80072c:	8b 75 08             	mov    0x8(%ebp),%esi
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	57                   	push   %edi
  800733:	6a 30                	push   $0x30
  800735:	ff d6                	call   *%esi
			putch('x', putdat);
  800737:	83 c4 08             	add    $0x8,%esp
  80073a:	57                   	push   %edi
  80073b:	6a 78                	push   $0x78
  80073d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 08                	mov    (%eax),%ecx
  800744:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800749:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80074c:	8d 40 04             	lea    0x4(%eax),%eax
  80074f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800752:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800757:	83 ec 0c             	sub    $0xc,%esp
  80075a:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	ff 75 d0             	push   -0x30(%ebp)
  800762:	52                   	push   %edx
  800763:	53                   	push   %ebx
  800764:	51                   	push   %ecx
  800765:	89 fa                	mov    %edi,%edx
  800767:	89 f0                	mov    %esi,%eax
  800769:	e8 2c fb ff ff       	call   80029a <printnum>
			break;
  80076e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800771:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800774:	e9 4d fc ff ff       	jmp    8003c6 <vprintfmt+0x34>

00800779 <.L21>:
	if (lflag >= 2)
  800779:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	83 f9 01             	cmp    $0x1,%ecx
  800782:	7f 1b                	jg     80079f <.L21+0x26>
	else if (lflag)
  800784:	85 c9                	test   %ecx,%ecx
  800786:	74 2c                	je     8007b4 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 08                	mov    (%eax),%ecx
  80078d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800798:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  80079d:	eb b8                	jmp    800757 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 08                	mov    (%eax),%ecx
  8007a4:	8b 58 04             	mov    0x4(%eax),%ebx
  8007a7:	8d 40 08             	lea    0x8(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ad:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007b2:	eb a3                	jmp    800757 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 08                	mov    (%eax),%ecx
  8007b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007be:	8d 40 04             	lea    0x4(%eax),%eax
  8007c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c4:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007c9:	eb 8c                	jmp    800757 <.L25+0x2b>

008007cb <.L35>:
			putch(ch, putdat);
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	57                   	push   %edi
  8007d2:	6a 25                	push   $0x25
  8007d4:	ff d6                	call   *%esi
			break;
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 96                	jmp    800771 <.L25+0x45>

008007db <.L20>:
			putch('%', putdat);
  8007db:	8b 75 08             	mov    0x8(%ebp),%esi
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	57                   	push   %edi
  8007e2:	6a 25                	push   $0x25
  8007e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	89 d8                	mov    %ebx,%eax
  8007eb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ef:	74 05                	je     8007f6 <.L20+0x1b>
  8007f1:	83 e8 01             	sub    $0x1,%eax
  8007f4:	eb f5                	jmp    8007eb <.L20+0x10>
  8007f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f9:	e9 73 ff ff ff       	jmp    800771 <.L25+0x45>

008007fe <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	83 ec 14             	sub    $0x14,%esp
  800805:	e8 4f f8 ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80080a:	81 c3 f6 17 00 00    	add    $0x17f6,%ebx
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800816:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800819:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80081d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800820:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800827:	85 c0                	test   %eax,%eax
  800829:	74 2b                	je     800856 <vsnprintf+0x58>
  80082b:	85 d2                	test   %edx,%edx
  80082d:	7e 27                	jle    800856 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80082f:	ff 75 14             	push   0x14(%ebp)
  800832:	ff 75 10             	push   0x10(%ebp)
  800835:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800838:	50                   	push   %eax
  800839:	8d 83 58 e3 ff ff    	lea    -0x1ca8(%ebx),%eax
  80083f:	50                   	push   %eax
  800840:	e8 4d fb ff ff       	call   800392 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800845:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800848:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084e:	83 c4 10             	add    $0x10,%esp
}
  800851:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800854:	c9                   	leave  
  800855:	c3                   	ret    
		return -E_INVAL;
  800856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085b:	eb f4                	jmp    800851 <vsnprintf+0x53>

0080085d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800866:	50                   	push   %eax
  800867:	ff 75 10             	push   0x10(%ebp)
  80086a:	ff 75 0c             	push   0xc(%ebp)
  80086d:	ff 75 08             	push   0x8(%ebp)
  800870:	e8 89 ff ff ff       	call   8007fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <__x86.get_pc_thunk.cx>:
  800877:	8b 0c 24             	mov    (%esp),%ecx
  80087a:	c3                   	ret    

0080087b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strlen+0x10>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088f:	75 f7                	jne    800888 <strlen+0xd>
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	eb 03                	jmp    8008a6 <strnlen+0x13>
		n++;
  8008a3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a6:	39 d0                	cmp    %edx,%eax
  8008a8:	74 08                	je     8008b2 <strnlen+0x1f>
  8008aa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ae:	75 f3                	jne    8008a3 <strnlen+0x10>
  8008b0:	89 c2                	mov    %eax,%edx
	return n;
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f2                	jne    8008c5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d3:	89 c8                	mov    %ecx,%eax
  8008d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	83 ec 10             	sub    $0x10,%esp
  8008e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e4:	53                   	push   %ebx
  8008e5:	e8 91 ff ff ff       	call   80087b <strlen>
  8008ea:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ed:	ff 75 0c             	push   0xc(%ebp)
  8008f0:	01 d8                	add    %ebx,%eax
  8008f2:	50                   	push   %eax
  8008f3:	e8 be ff ff ff       	call   8008b6 <strcpy>
	return dst;
}
  8008f8:	89 d8                	mov    %ebx,%eax
  8008fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090a:	89 f3                	mov    %esi,%ebx
  80090c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80090f:	89 f0                	mov    %esi,%eax
  800911:	eb 0f                	jmp    800922 <strncpy+0x23>
		*dst++ = *src;
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	0f b6 0a             	movzbl (%edx),%ecx
  800919:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091c:	80 f9 01             	cmp    $0x1,%cl
  80091f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800922:	39 d8                	cmp    %ebx,%eax
  800924:	75 ed                	jne    800913 <strncpy+0x14>
	}
	return ret;
}
  800926:	89 f0                	mov    %esi,%eax
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800937:	8b 55 10             	mov    0x10(%ebp),%edx
  80093a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093c:	85 d2                	test   %edx,%edx
  80093e:	74 21                	je     800961 <strlcpy+0x35>
  800940:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800944:	89 f2                	mov    %esi,%edx
  800946:	eb 09                	jmp    800951 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800948:	83 c1 01             	add    $0x1,%ecx
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800951:	39 c2                	cmp    %eax,%edx
  800953:	74 09                	je     80095e <strlcpy+0x32>
  800955:	0f b6 19             	movzbl (%ecx),%ebx
  800958:	84 db                	test   %bl,%bl
  80095a:	75 ec                	jne    800948 <strlcpy+0x1c>
  80095c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80095e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800961:	29 f0                	sub    %esi,%eax
}
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800970:	eb 06                	jmp    800978 <strcmp+0x11>
		p++, q++;
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800978:	0f b6 01             	movzbl (%ecx),%eax
  80097b:	84 c0                	test   %al,%al
  80097d:	74 04                	je     800983 <strcmp+0x1c>
  80097f:	3a 02                	cmp    (%edx),%al
  800981:	74 ef                	je     800972 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800983:	0f b6 c0             	movzbl %al,%eax
  800986:	0f b6 12             	movzbl (%edx),%edx
  800989:	29 d0                	sub    %edx,%eax
}
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	89 c3                	mov    %eax,%ebx
  800999:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099c:	eb 06                	jmp    8009a4 <strncmp+0x17>
		n--, p++, q++;
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a4:	39 d8                	cmp    %ebx,%eax
  8009a6:	74 18                	je     8009c0 <strncmp+0x33>
  8009a8:	0f b6 08             	movzbl (%eax),%ecx
  8009ab:	84 c9                	test   %cl,%cl
  8009ad:	74 04                	je     8009b3 <strncmp+0x26>
  8009af:	3a 0a                	cmp    (%edx),%cl
  8009b1:	74 eb                	je     80099e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b3:	0f b6 00             	movzbl (%eax),%eax
  8009b6:	0f b6 12             	movzbl (%edx),%edx
  8009b9:	29 d0                	sub    %edx,%eax
}
  8009bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	eb f4                	jmp    8009bb <strncmp+0x2e>

008009c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d1:	eb 03                	jmp    8009d6 <strchr+0xf>
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	0f b6 10             	movzbl (%eax),%edx
  8009d9:	84 d2                	test   %dl,%dl
  8009db:	74 06                	je     8009e3 <strchr+0x1c>
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	75 f2                	jne    8009d3 <strchr+0xc>
  8009e1:	eb 05                	jmp    8009e8 <strchr+0x21>
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f7:	38 ca                	cmp    %cl,%dl
  8009f9:	74 09                	je     800a04 <strfind+0x1a>
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	74 05                	je     800a04 <strfind+0x1a>
	for (; *s; s++)
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	eb f0                	jmp    8009f4 <strfind+0xa>
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a12:	85 c9                	test   %ecx,%ecx
  800a14:	74 2f                	je     800a45 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a16:	89 f8                	mov    %edi,%eax
  800a18:	09 c8                	or     %ecx,%eax
  800a1a:	a8 03                	test   $0x3,%al
  800a1c:	75 21                	jne    800a3f <memset+0x39>
		c &= 0xFF;
  800a1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a22:	89 d0                	mov    %edx,%eax
  800a24:	c1 e0 08             	shl    $0x8,%eax
  800a27:	89 d3                	mov    %edx,%ebx
  800a29:	c1 e3 18             	shl    $0x18,%ebx
  800a2c:	89 d6                	mov    %edx,%esi
  800a2e:	c1 e6 10             	shl    $0x10,%esi
  800a31:	09 f3                	or     %esi,%ebx
  800a33:	09 da                	or     %ebx,%edx
  800a35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3a:	fc                   	cld    
  800a3b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3d:	eb 06                	jmp    800a45 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a42:	fc                   	cld    
  800a43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a45:	89 f8                	mov    %edi,%eax
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 32                	jae    800a90 <memmove+0x44>
  800a5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a61:	39 c2                	cmp    %eax,%edx
  800a63:	76 2b                	jbe    800a90 <memmove+0x44>
		s += n;
		d += n;
  800a65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	09 fe                	or     %edi,%esi
  800a6c:	09 ce                	or     %ecx,%esi
  800a6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a74:	75 0e                	jne    800a84 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a76:	83 ef 04             	sub    $0x4,%edi
  800a79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a7f:	fd                   	std    
  800a80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a82:	eb 09                	jmp    800a8d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a84:	83 ef 01             	sub    $0x1,%edi
  800a87:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8a:	fd                   	std    
  800a8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8d:	fc                   	cld    
  800a8e:	eb 1a                	jmp    800aaa <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a90:	89 f2                	mov    %esi,%edx
  800a92:	09 c2                	or     %eax,%edx
  800a94:	09 ca                	or     %ecx,%edx
  800a96:	f6 c2 03             	test   $0x3,%dl
  800a99:	75 0a                	jne    800aa5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9e:	89 c7                	mov    %eax,%edi
  800aa0:	fc                   	cld    
  800aa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa3:	eb 05                	jmp    800aaa <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	fc                   	cld    
  800aa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab4:	ff 75 10             	push   0x10(%ebp)
  800ab7:	ff 75 0c             	push   0xc(%ebp)
  800aba:	ff 75 08             	push   0x8(%ebp)
  800abd:	e8 8a ff ff ff       	call   800a4c <memmove>
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad4:	eb 06                	jmp    800adc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ad6:	83 c0 01             	add    $0x1,%eax
  800ad9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800adc:	39 f0                	cmp    %esi,%eax
  800ade:	74 14                	je     800af4 <memcmp+0x30>
		if (*s1 != *s2)
  800ae0:	0f b6 08             	movzbl (%eax),%ecx
  800ae3:	0f b6 1a             	movzbl (%edx),%ebx
  800ae6:	38 d9                	cmp    %bl,%cl
  800ae8:	74 ec                	je     800ad6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800aea:	0f b6 c1             	movzbl %cl,%eax
  800aed:	0f b6 db             	movzbl %bl,%ebx
  800af0:	29 d8                	sub    %ebx,%eax
  800af2:	eb 05                	jmp    800af9 <memcmp+0x35>
	}

	return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b06:	89 c2                	mov    %eax,%edx
  800b08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0b:	eb 03                	jmp    800b10 <memfind+0x13>
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	39 d0                	cmp    %edx,%eax
  800b12:	73 04                	jae    800b18 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b14:	38 08                	cmp    %cl,(%eax)
  800b16:	75 f5                	jne    800b0d <memfind+0x10>
			break;
	return (void *) s;
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b26:	eb 03                	jmp    800b2b <strtol+0x11>
		s++;
  800b28:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b2b:	0f b6 02             	movzbl (%edx),%eax
  800b2e:	3c 20                	cmp    $0x20,%al
  800b30:	74 f6                	je     800b28 <strtol+0xe>
  800b32:	3c 09                	cmp    $0x9,%al
  800b34:	74 f2                	je     800b28 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b36:	3c 2b                	cmp    $0x2b,%al
  800b38:	74 2a                	je     800b64 <strtol+0x4a>
	int neg = 0;
  800b3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b3f:	3c 2d                	cmp    $0x2d,%al
  800b41:	74 2b                	je     800b6e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b49:	75 0f                	jne    800b5a <strtol+0x40>
  800b4b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b4e:	74 28                	je     800b78 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b50:	85 db                	test   %ebx,%ebx
  800b52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b57:	0f 44 d8             	cmove  %eax,%ebx
  800b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b62:	eb 46                	jmp    800baa <strtol+0x90>
		s++;
  800b64:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b67:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6c:	eb d5                	jmp    800b43 <strtol+0x29>
		s++, neg = 1;
  800b6e:	83 c2 01             	add    $0x1,%edx
  800b71:	bf 01 00 00 00       	mov    $0x1,%edi
  800b76:	eb cb                	jmp    800b43 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7c:	74 0e                	je     800b8c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b7e:	85 db                	test   %ebx,%ebx
  800b80:	75 d8                	jne    800b5a <strtol+0x40>
		s++, base = 8;
  800b82:	83 c2 01             	add    $0x1,%edx
  800b85:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b8a:	eb ce                	jmp    800b5a <strtol+0x40>
		s += 2, base = 16;
  800b8c:	83 c2 02             	add    $0x2,%edx
  800b8f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b94:	eb c4                	jmp    800b5a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b96:	0f be c0             	movsbl %al,%eax
  800b99:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b9c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b9f:	7d 3a                	jge    800bdb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ba1:	83 c2 01             	add    $0x1,%edx
  800ba4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ba8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800baa:	0f b6 02             	movzbl (%edx),%eax
  800bad:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bb0:	89 f3                	mov    %esi,%ebx
  800bb2:	80 fb 09             	cmp    $0x9,%bl
  800bb5:	76 df                	jbe    800b96 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bb7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bba:	89 f3                	mov    %esi,%ebx
  800bbc:	80 fb 19             	cmp    $0x19,%bl
  800bbf:	77 08                	ja     800bc9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bc1:	0f be c0             	movsbl %al,%eax
  800bc4:	83 e8 57             	sub    $0x57,%eax
  800bc7:	eb d3                	jmp    800b9c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bc9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bcc:	89 f3                	mov    %esi,%ebx
  800bce:	80 fb 19             	cmp    $0x19,%bl
  800bd1:	77 08                	ja     800bdb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bd3:	0f be c0             	movsbl %al,%eax
  800bd6:	83 e8 37             	sub    $0x37,%eax
  800bd9:	eb c1                	jmp    800b9c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdf:	74 05                	je     800be6 <strtol+0xcc>
		*endptr = (char *) s;
  800be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800be6:	89 c8                	mov    %ecx,%eax
  800be8:	f7 d8                	neg    %eax
  800bea:	85 ff                	test   %edi,%edi
  800bec:	0f 45 c8             	cmovne %eax,%ecx
}
  800bef:	89 c8                	mov    %ecx,%eax
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
  800bf6:	66 90                	xchg   %ax,%ax
  800bf8:	66 90                	xchg   %ax,%ax
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
