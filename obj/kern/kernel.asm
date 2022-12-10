
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 18 00       	mov    $0x180000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 1c f8 07 00    	add    $0x7f81c,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 00 20 18 f0    	mov    $0xf0182000,%eax
f0100058:	c7 c2 e0 10 18 f0    	mov    $0xf01810e0,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 6b 4e 00 00       	call   f0104ed4 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4f 05 00 00       	call   f01005bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 b8 5a f8 ff    	lea    -0x7a548(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 c5 38 00 00       	call   f0103947 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 ae 11 00 00       	call   f0101235 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 c8 31 00 00       	call   f0103254 <env_init>
	trap_init();
f010008c:	e8 69 39 00 00       	call   f01039fa <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f010009c:	e8 ab 33 00 00       	call   f010344c <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f01000aa:	ff 30                	push   (%eax)
f01000ac:	e8 9a 37 00 00       	call   f010384b <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	e8 ac 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bb:	81 c3 ad f7 07 00    	add    $0x7f7ad,%ebx
	va_list ap;

	if (panicstr)
f01000c1:	83 bb 78 18 00 00 00 	cmpl   $0x0,0x1878(%ebx)
f01000c8:	74 0f                	je     f01000d9 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000ca:	83 ec 0c             	sub    $0xc,%esp
f01000cd:	6a 00                	push   $0x0
f01000cf:	e8 54 07 00 00       	call   f0100828 <monitor>
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	eb f1                	jmp    f01000ca <_panic+0x19>
	panicstr = fmt;
f01000d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01000dc:	89 83 78 18 00 00    	mov    %eax,0x1878(%ebx)
	asm volatile("cli; cld");
f01000e2:	fa                   	cli    
f01000e3:	fc                   	cld    
	va_start(ap, fmt);
f01000e4:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e7:	83 ec 04             	sub    $0x4,%esp
f01000ea:	ff 75 0c             	push   0xc(%ebp)
f01000ed:	ff 75 08             	push   0x8(%ebp)
f01000f0:	8d 83 d3 5a f8 ff    	lea    -0x7a52d(%ebx),%eax
f01000f6:	50                   	push   %eax
f01000f7:	e8 4b 38 00 00       	call   f0103947 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	56                   	push   %esi
f0100100:	ff 75 10             	push   0x10(%ebp)
f0100103:	e8 08 38 00 00       	call   f0103910 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 0e 6a f8 ff    	lea    -0x795f2(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 31 38 00 00       	call   f0103947 <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb af                	jmp    f01000ca <_panic+0x19>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 43 f7 07 00    	add    $0x7f743,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	push   0xc(%ebp)
f0100134:	ff 75 08             	push   0x8(%ebp)
f0100137:	8d 83 eb 5a f8 ff    	lea    -0x7a515(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 04 38 00 00       	call   f0103947 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	push   0x10(%ebp)
f010014a:	e8 c1 37 00 00       	call   f0103910 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 0e 6a f8 ff    	lea    -0x795f2(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 ea 37 00 00       	call   f0103947 <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100170:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100171:	a8 01                	test   $0x1,%al
f0100173:	74 0a                	je     f010017f <serial_proc_data+0x14>
f0100175:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017a:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017b:	0f b6 c0             	movzbl %al,%eax
f010017e:	c3                   	ret    
		return -1;
f010017f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100184:	c3                   	ret    

f0100185 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100185:	55                   	push   %ebp
f0100186:	89 e5                	mov    %esp,%ebp
f0100188:	57                   	push   %edi
f0100189:	56                   	push   %esi
f010018a:	53                   	push   %ebx
f010018b:	83 ec 1c             	sub    $0x1c,%esp
f010018e:	e8 6a 05 00 00       	call   f01006fd <__x86.get_pc_thunk.si>
f0100193:	81 c6 d5 f6 07 00    	add    $0x7f6d5,%esi
f0100199:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f010019b:	8d 1d b8 18 00 00    	lea    0x18b8,%ebx
f01001a1:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001aa:	eb 25                	jmp    f01001d1 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001b3:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001b9:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c7:	0f 44 d0             	cmove  %eax,%edx
f01001ca:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001d4:	ff d0                	call   *%eax
f01001d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d9:	74 06                	je     f01001e1 <cons_intr+0x5c>
		if (c == 0)
f01001db:	85 c0                	test   %eax,%eax
f01001dd:	75 cd                	jne    f01001ac <cons_intr+0x27>
f01001df:	eb f0                	jmp    f01001d1 <cons_intr+0x4c>
	}
}
f01001e1:	83 c4 1c             	add    $0x1c,%esp
f01001e4:	5b                   	pop    %ebx
f01001e5:	5e                   	pop    %esi
f01001e6:	5f                   	pop    %edi
f01001e7:	5d                   	pop    %ebp
f01001e8:	c3                   	ret    

f01001e9 <kbd_proc_data>:
{
f01001e9:	55                   	push   %ebp
f01001ea:	89 e5                	mov    %esp,%ebp
f01001ec:	56                   	push   %esi
f01001ed:	53                   	push   %ebx
f01001ee:	e8 74 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001f3:	81 c3 75 f6 07 00    	add    $0x7f675,%ebx
f01001f9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001fe:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001ff:	a8 01                	test   $0x1,%al
f0100201:	0f 84 f7 00 00 00    	je     f01002fe <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100207:	a8 20                	test   $0x20,%al
f0100209:	0f 85 f6 00 00 00    	jne    f0100305 <kbd_proc_data+0x11c>
f010020f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100214:	ec                   	in     (%dx),%al
f0100215:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100217:	3c e0                	cmp    $0xe0,%al
f0100219:	74 64                	je     f010027f <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010021b:	84 c0                	test   %al,%al
f010021d:	78 75                	js     f0100294 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010021f:	8b 8b 98 18 00 00    	mov    0x1898(%ebx),%ecx
f0100225:	f6 c1 40             	test   $0x40,%cl
f0100228:	74 0e                	je     f0100238 <kbd_proc_data+0x4f>
		data |= 0x80;
f010022a:	83 c8 80             	or     $0xffffff80,%eax
f010022d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010022f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100232:	89 8b 98 18 00 00    	mov    %ecx,0x1898(%ebx)
	shift |= shiftcode[data];
f0100238:	0f b6 d2             	movzbl %dl,%edx
f010023b:	0f b6 84 13 38 5c f8 	movzbl -0x7a3c8(%ebx,%edx,1),%eax
f0100242:	ff 
f0100243:	0b 83 98 18 00 00    	or     0x1898(%ebx),%eax
	shift ^= togglecode[data];
f0100249:	0f b6 8c 13 38 5b f8 	movzbl -0x7a4c8(%ebx,%edx,1),%ecx
f0100250:	ff 
f0100251:	31 c8                	xor    %ecx,%eax
f0100253:	89 83 98 18 00 00    	mov    %eax,0x1898(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100259:	89 c1                	mov    %eax,%ecx
f010025b:	83 e1 03             	and    $0x3,%ecx
f010025e:	8b 8c 8b b8 17 00 00 	mov    0x17b8(%ebx,%ecx,4),%ecx
f0100265:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100269:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f010026c:	a8 08                	test   $0x8,%al
f010026e:	74 61                	je     f01002d1 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f0100270:	89 f2                	mov    %esi,%edx
f0100272:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100275:	83 f9 19             	cmp    $0x19,%ecx
f0100278:	77 4b                	ja     f01002c5 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f010027a:	83 ee 20             	sub    $0x20,%esi
f010027d:	eb 0c                	jmp    f010028b <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010027f:	83 8b 98 18 00 00 40 	orl    $0x40,0x1898(%ebx)
		return 0;
f0100286:	be 00 00 00 00       	mov    $0x0,%esi
}
f010028b:	89 f0                	mov    %esi,%eax
f010028d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100290:	5b                   	pop    %ebx
f0100291:	5e                   	pop    %esi
f0100292:	5d                   	pop    %ebp
f0100293:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100294:	8b 8b 98 18 00 00    	mov    0x1898(%ebx),%ecx
f010029a:	83 e0 7f             	and    $0x7f,%eax
f010029d:	f6 c1 40             	test   $0x40,%cl
f01002a0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 38 5c f8 	movzbl -0x7a3c8(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	83 c8 40             	or     $0x40,%eax
f01002b1:	0f b6 c0             	movzbl %al,%eax
f01002b4:	f7 d0                	not    %eax
f01002b6:	21 c8                	and    %ecx,%eax
f01002b8:	89 83 98 18 00 00    	mov    %eax,0x1898(%ebx)
		return 0;
f01002be:	be 00 00 00 00       	mov    $0x0,%esi
f01002c3:	eb c6                	jmp    f010028b <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002c5:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002c8:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002cb:	83 fa 1a             	cmp    $0x1a,%edx
f01002ce:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d1:	f7 d0                	not    %eax
f01002d3:	a8 06                	test   $0x6,%al
f01002d5:	75 b4                	jne    f010028b <kbd_proc_data+0xa2>
f01002d7:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002dd:	75 ac                	jne    f010028b <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01002df:	83 ec 0c             	sub    $0xc,%esp
f01002e2:	8d 83 05 5b f8 ff    	lea    -0x7a4fb(%ebx),%eax
f01002e8:	50                   	push   %eax
f01002e9:	e8 59 36 00 00       	call   f0103947 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f8:	ee                   	out    %al,(%dx)
}
f01002f9:	83 c4 10             	add    $0x10,%esp
f01002fc:	eb 8d                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f01002fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100303:	eb 86                	jmp    f010028b <kbd_proc_data+0xa2>
		return -1;
f0100305:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010030a:	e9 7c ff ff ff       	jmp    f010028b <kbd_proc_data+0xa2>

f010030f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010030f:	55                   	push   %ebp
f0100310:	89 e5                	mov    %esp,%ebp
f0100312:	57                   	push   %edi
f0100313:	56                   	push   %esi
f0100314:	53                   	push   %ebx
f0100315:	83 ec 1c             	sub    $0x1c,%esp
f0100318:	e8 4a fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010031d:	81 c3 4b f5 07 00    	add    $0x7f54b,%ebx
f0100323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100326:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100330:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100335:	89 fa                	mov    %edi,%edx
f0100337:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100338:	a8 20                	test   $0x20,%al
f010033a:	75 13                	jne    f010034f <cons_putc+0x40>
f010033c:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100342:	7f 0b                	jg     f010034f <cons_putc+0x40>
f0100344:	89 ca                	mov    %ecx,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	ec                   	in     (%dx),%al
f0100349:	ec                   	in     (%dx),%al
	     i++)
f010034a:	83 c6 01             	add    $0x1,%esi
f010034d:	eb e6                	jmp    f0100335 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f010034f:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100353:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100356:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010035b:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010035c:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	bf 79 03 00 00       	mov    $0x379,%edi
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
f010036e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100374:	7f 0f                	jg     f0100385 <cons_putc+0x76>
f0100376:	84 c0                	test   %al,%al
f0100378:	78 0b                	js     f0100385 <cons_putc+0x76>
f010037a:	89 ca                	mov    %ecx,%edx
f010037c:	ec                   	in     (%dx),%al
f010037d:	ec                   	in     (%dx),%al
f010037e:	ec                   	in     (%dx),%al
f010037f:	ec                   	in     (%dx),%al
f0100380:	83 c6 01             	add    $0x1,%esi
f0100383:	eb e6                	jmp    f010036b <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100385:	ba 78 03 00 00       	mov    $0x378,%edx
f010038a:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010038e:	ee                   	out    %al,(%dx)
f010038f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100394:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100399:	ee                   	out    %al,(%dx)
f010039a:	b8 08 00 00 00       	mov    $0x8,%eax
f010039f:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003a3:	89 f8                	mov    %edi,%eax
f01003a5:	80 cc 07             	or     $0x7,%ah
f01003a8:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003ae:	0f 45 c7             	cmovne %edi,%eax
f01003b1:	89 c7                	mov    %eax,%edi
f01003b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b6:	0f b6 c0             	movzbl %al,%eax
f01003b9:	89 f9                	mov    %edi,%ecx
f01003bb:	80 f9 0a             	cmp    $0xa,%cl
f01003be:	0f 84 e4 00 00 00    	je     f01004a8 <cons_putc+0x199>
f01003c4:	83 f8 0a             	cmp    $0xa,%eax
f01003c7:	7f 46                	jg     f010040f <cons_putc+0x100>
f01003c9:	83 f8 08             	cmp    $0x8,%eax
f01003cc:	0f 84 a8 00 00 00    	je     f010047a <cons_putc+0x16b>
f01003d2:	83 f8 09             	cmp    $0x9,%eax
f01003d5:	0f 85 da 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		cons_putc(' ');
f01003db:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e0:	e8 2a ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003e5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ea:	e8 20 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003ef:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f4:	e8 16 ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f01003f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fe:	e8 0c ff ff ff       	call   f010030f <cons_putc>
		cons_putc(' ');
f0100403:	b8 20 00 00 00       	mov    $0x20,%eax
f0100408:	e8 02 ff ff ff       	call   f010030f <cons_putc>
		break;
f010040d:	eb 26                	jmp    f0100435 <cons_putc+0x126>
	switch (c & 0xff) {
f010040f:	83 f8 0d             	cmp    $0xd,%eax
f0100412:	0f 85 9d 00 00 00    	jne    f01004b5 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100418:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f010041f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100425:	c1 e8 16             	shr    $0x16,%eax
f0100428:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010042b:	c1 e0 04             	shl    $0x4,%eax
f010042e:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100435:	66 81 bb c0 1a 00 00 	cmpw   $0x7cf,0x1ac0(%ebx)
f010043c:	cf 07 
f010043e:	0f 87 98 00 00 00    	ja     f01004dc <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100444:	8b 8b c8 1a 00 00    	mov    0x1ac8(%ebx),%ecx
f010044a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010044f:	89 ca                	mov    %ecx,%edx
f0100451:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100452:	0f b7 9b c0 1a 00 00 	movzwl 0x1ac0(%ebx),%ebx
f0100459:	8d 71 01             	lea    0x1(%ecx),%esi
f010045c:	89 d8                	mov    %ebx,%eax
f010045e:	66 c1 e8 08          	shr    $0x8,%ax
f0100462:	89 f2                	mov    %esi,%edx
f0100464:	ee                   	out    %al,(%dx)
f0100465:	b8 0f 00 00 00       	mov    $0xf,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100472:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100475:	5b                   	pop    %ebx
f0100476:	5e                   	pop    %esi
f0100477:	5f                   	pop    %edi
f0100478:	5d                   	pop    %ebp
f0100479:	c3                   	ret    
		if (crt_pos > 0) {
f010047a:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f0100481:	66 85 c0             	test   %ax,%ax
f0100484:	74 be                	je     f0100444 <cons_putc+0x135>
			crt_pos--;
f0100486:	83 e8 01             	sub    $0x1,%eax
f0100489:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100490:	0f b7 c0             	movzwl %ax,%eax
f0100493:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100497:	b2 00                	mov    $0x0,%dl
f0100499:	83 ca 20             	or     $0x20,%edx
f010049c:	8b 8b c4 1a 00 00    	mov    0x1ac4(%ebx),%ecx
f01004a2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004a6:	eb 8d                	jmp    f0100435 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004a8:	66 83 83 c0 1a 00 00 	addw   $0x50,0x1ac0(%ebx)
f01004af:	50 
f01004b0:	e9 63 ff ff ff       	jmp    f0100418 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004b5:	0f b7 83 c0 1a 00 00 	movzwl 0x1ac0(%ebx),%eax
f01004bc:	8d 50 01             	lea    0x1(%eax),%edx
f01004bf:	66 89 93 c0 1a 00 00 	mov    %dx,0x1ac0(%ebx)
f01004c6:	0f b7 c0             	movzwl %ax,%eax
f01004c9:	8b 93 c4 1a 00 00    	mov    0x1ac4(%ebx),%edx
f01004cf:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004d3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01004d7:	e9 59 ff ff ff       	jmp    f0100435 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004dc:	8b 83 c4 1a 00 00    	mov    0x1ac4(%ebx),%eax
f01004e2:	83 ec 04             	sub    $0x4,%esp
f01004e5:	68 00 0f 00 00       	push   $0xf00
f01004ea:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f0:	52                   	push   %edx
f01004f1:	50                   	push   %eax
f01004f2:	e8 23 4a 00 00       	call   f0104f1a <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004f7:	8b 93 c4 1a 00 00    	mov    0x1ac4(%ebx),%edx
f01004fd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100503:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100509:	83 c4 10             	add    $0x10,%esp
f010050c:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100511:	83 c0 02             	add    $0x2,%eax
f0100514:	39 d0                	cmp    %edx,%eax
f0100516:	75 f4                	jne    f010050c <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100518:	66 83 ab c0 1a 00 00 	subw   $0x50,0x1ac0(%ebx)
f010051f:	50 
f0100520:	e9 1f ff ff ff       	jmp    f0100444 <cons_putc+0x135>

f0100525 <serial_intr>:
{
f0100525:	e8 cf 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010052a:	05 3e f3 07 00       	add    $0x7f33e,%eax
	if (serial_exists)
f010052f:	80 b8 cc 1a 00 00 00 	cmpb   $0x0,0x1acc(%eax)
f0100536:	75 01                	jne    f0100539 <serial_intr+0x14>
f0100538:	c3                   	ret    
{
f0100539:	55                   	push   %ebp
f010053a:	89 e5                	mov    %esp,%ebp
f010053c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053f:	8d 80 03 09 f8 ff    	lea    -0x7f6fd(%eax),%eax
f0100545:	e8 3b fc ff ff       	call   f0100185 <cons_intr>
}
f010054a:	c9                   	leave  
f010054b:	c3                   	ret    

f010054c <kbd_intr>:
{
f010054c:	55                   	push   %ebp
f010054d:	89 e5                	mov    %esp,%ebp
f010054f:	83 ec 08             	sub    $0x8,%esp
f0100552:	e8 a2 01 00 00       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0100557:	05 11 f3 07 00       	add    $0x7f311,%eax
	cons_intr(kbd_proc_data);
f010055c:	8d 80 81 09 f8 ff    	lea    -0x7f67f(%eax),%eax
f0100562:	e8 1e fc ff ff       	call   f0100185 <cons_intr>
}
f0100567:	c9                   	leave  
f0100568:	c3                   	ret    

f0100569 <cons_getc>:
{
f0100569:	55                   	push   %ebp
f010056a:	89 e5                	mov    %esp,%ebp
f010056c:	53                   	push   %ebx
f010056d:	83 ec 04             	sub    $0x4,%esp
f0100570:	e8 f2 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100575:	81 c3 f3 f2 07 00    	add    $0x7f2f3,%ebx
	serial_intr();
f010057b:	e8 a5 ff ff ff       	call   f0100525 <serial_intr>
	kbd_intr();
f0100580:	e8 c7 ff ff ff       	call   f010054c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100585:	8b 83 b8 1a 00 00    	mov    0x1ab8(%ebx),%eax
	return 0;
f010058b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100590:	3b 83 bc 1a 00 00    	cmp    0x1abc(%ebx),%eax
f0100596:	74 1e                	je     f01005b6 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100598:	8d 48 01             	lea    0x1(%eax),%ecx
f010059b:	0f b6 94 03 b8 18 00 	movzbl 0x18b8(%ebx,%eax,1),%edx
f01005a2:	00 
			cons.rpos = 0;
f01005a3:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	0f 45 c1             	cmovne %ecx,%eax
f01005b0:	89 83 b8 1a 00 00    	mov    %eax,0x1ab8(%ebx)
}
f01005b6:	89 d0                	mov    %edx,%eax
f01005b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005bb:	c9                   	leave  
f01005bc:	c3                   	ret    

f01005bd <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bd:	55                   	push   %ebp
f01005be:	89 e5                	mov    %esp,%ebp
f01005c0:	57                   	push   %edi
f01005c1:	56                   	push   %esi
f01005c2:	53                   	push   %ebx
f01005c3:	83 ec 1c             	sub    $0x1c,%esp
f01005c6:	e8 9c fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005cb:	81 c3 9d f2 07 00    	add    $0x7f29d,%ebx
	was = *cp;
f01005d1:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005df:	5a a5 
	if (*cp != 0xA55A) {
f01005e1:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e8:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005ed:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f01005f2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005f6:	0f 84 ac 00 00 00    	je     f01006a8 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f01005fc:	89 8b c8 1a 00 00    	mov    %ecx,0x1ac8(%ebx)
f0100602:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010060a:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060d:	89 f2                	mov    %esi,%edx
f010060f:	ec                   	in     (%dx),%al
f0100610:	0f b6 c0             	movzbl %al,%eax
f0100613:	c1 e0 08             	shl    $0x8,%eax
f0100616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100619:	b8 0f 00 00 00       	mov    $0xf,%eax
f010061e:	89 ca                	mov    %ecx,%edx
f0100620:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100621:	89 f2                	mov    %esi,%edx
f0100623:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100624:	89 bb c4 1a 00 00    	mov    %edi,0x1ac4(%ebx)
	pos |= inb(addr_6845 + 1);
f010062a:	0f b6 c0             	movzbl %al,%eax
f010062d:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100630:	66 89 83 c0 1a 00 00 	mov    %ax,0x1ac0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100637:	b9 00 00 00 00       	mov    $0x0,%ecx
f010063c:	89 c8                	mov    %ecx,%eax
f010063e:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100643:	ee                   	out    %al,(%dx)
f0100644:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100649:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010064e:	89 fa                	mov    %edi,%edx
f0100650:	ee                   	out    %al,(%dx)
f0100651:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100656:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010065b:	ee                   	out    %al,(%dx)
f010065c:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100661:	89 c8                	mov    %ecx,%eax
f0100663:	89 f2                	mov    %esi,%edx
f0100665:	ee                   	out    %al,(%dx)
f0100666:	b8 03 00 00 00       	mov    $0x3,%eax
f010066b:	89 fa                	mov    %edi,%edx
f010066d:	ee                   	out    %al,(%dx)
f010066e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100673:	89 c8                	mov    %ecx,%eax
f0100675:	ee                   	out    %al,(%dx)
f0100676:	b8 01 00 00 00       	mov    $0x1,%eax
f010067b:	89 f2                	mov    %esi,%edx
f010067d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010067e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100683:	ec                   	in     (%dx),%al
f0100684:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100686:	3c ff                	cmp    $0xff,%al
f0100688:	0f 95 83 cc 1a 00 00 	setne  0x1acc(%ebx)
f010068f:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100694:	ec                   	in     (%dx),%al
f0100695:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069a:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010069b:	80 f9 ff             	cmp    $0xff,%cl
f010069e:	74 1e                	je     f01006be <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a3:	5b                   	pop    %ebx
f01006a4:	5e                   	pop    %esi
f01006a5:	5f                   	pop    %edi
f01006a6:	5d                   	pop    %ebp
f01006a7:	c3                   	ret    
		*cp = was;
f01006a8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006af:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006b9:	e9 3e ff ff ff       	jmp    f01005fc <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006be:	83 ec 0c             	sub    $0xc,%esp
f01006c1:	8d 83 11 5b f8 ff    	lea    -0x7a4ef(%ebx),%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 7a 32 00 00       	call   f0103947 <cprintf>
f01006cd:	83 c4 10             	add    $0x10,%esp
}
f01006d0:	eb ce                	jmp    f01006a0 <cons_init+0xe3>

f01006d2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006d2:	55                   	push   %ebp
f01006d3:	89 e5                	mov    %esp,%ebp
f01006d5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006db:	e8 2f fc ff ff       	call   f010030f <cons_putc>
}
f01006e0:	c9                   	leave  
f01006e1:	c3                   	ret    

f01006e2 <getchar>:

int
getchar(void)
{
f01006e2:	55                   	push   %ebp
f01006e3:	89 e5                	mov    %esp,%ebp
f01006e5:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006e8:	e8 7c fe ff ff       	call   f0100569 <cons_getc>
f01006ed:	85 c0                	test   %eax,%eax
f01006ef:	74 f7                	je     f01006e8 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006f1:	c9                   	leave  
f01006f2:	c3                   	ret    

f01006f3 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01006f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f8:	c3                   	ret    

f01006f9 <__x86.get_pc_thunk.ax>:
f01006f9:	8b 04 24             	mov    (%esp),%eax
f01006fc:	c3                   	ret    

f01006fd <__x86.get_pc_thunk.si>:
f01006fd:	8b 34 24             	mov    (%esp),%esi
f0100700:	c3                   	ret    

f0100701 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100701:	55                   	push   %ebp
f0100702:	89 e5                	mov    %esp,%ebp
f0100704:	56                   	push   %esi
f0100705:	53                   	push   %ebx
f0100706:	e8 5c fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010070b:	81 c3 5d f1 07 00    	add    $0x7f15d,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100711:	83 ec 04             	sub    $0x4,%esp
f0100714:	8d 83 38 5d f8 ff    	lea    -0x7a2c8(%ebx),%eax
f010071a:	50                   	push   %eax
f010071b:	8d 83 56 5d f8 ff    	lea    -0x7a2aa(%ebx),%eax
f0100721:	50                   	push   %eax
f0100722:	8d b3 5b 5d f8 ff    	lea    -0x7a2a5(%ebx),%esi
f0100728:	56                   	push   %esi
f0100729:	e8 19 32 00 00       	call   f0103947 <cprintf>
f010072e:	83 c4 0c             	add    $0xc,%esp
f0100731:	8d 83 c4 5d f8 ff    	lea    -0x7a23c(%ebx),%eax
f0100737:	50                   	push   %eax
f0100738:	8d 83 64 5d f8 ff    	lea    -0x7a29c(%ebx),%eax
f010073e:	50                   	push   %eax
f010073f:	56                   	push   %esi
f0100740:	e8 02 32 00 00       	call   f0103947 <cprintf>
	return 0;
}
f0100745:	b8 00 00 00 00       	mov    $0x0,%eax
f010074a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010074d:	5b                   	pop    %ebx
f010074e:	5e                   	pop    %esi
f010074f:	5d                   	pop    %ebp
f0100750:	c3                   	ret    

f0100751 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	57                   	push   %edi
f0100755:	56                   	push   %esi
f0100756:	53                   	push   %ebx
f0100757:	83 ec 18             	sub    $0x18,%esp
f010075a:	e8 08 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010075f:	81 c3 09 f1 07 00    	add    $0x7f109,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100765:	8d 83 6d 5d f8 ff    	lea    -0x7a293(%ebx),%eax
f010076b:	50                   	push   %eax
f010076c:	e8 d6 31 00 00       	call   f0103947 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100771:	83 c4 08             	add    $0x8,%esp
f0100774:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010077a:	8d 83 ec 5d f8 ff    	lea    -0x7a214(%ebx),%eax
f0100780:	50                   	push   %eax
f0100781:	e8 c1 31 00 00       	call   f0103947 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078f:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100795:	50                   	push   %eax
f0100796:	57                   	push   %edi
f0100797:	8d 83 14 5e f8 ff    	lea    -0x7a1ec(%ebx),%eax
f010079d:	50                   	push   %eax
f010079e:	e8 a4 31 00 00       	call   f0103947 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a3:	83 c4 0c             	add    $0xc,%esp
f01007a6:	c7 c0 01 53 10 f0    	mov    $0xf0105301,%eax
f01007ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b2:	52                   	push   %edx
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 38 5e f8 ff    	lea    -0x7a1c8(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	e8 87 31 00 00       	call   f0103947 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	c7 c0 e0 10 18 f0    	mov    $0xf01810e0,%eax
f01007c9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007cf:	52                   	push   %edx
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 5c 5e f8 ff    	lea    -0x7a1a4(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	e8 6a 31 00 00       	call   f0103947 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dd:	83 c4 0c             	add    $0xc,%esp
f01007e0:	c7 c6 00 20 18 f0    	mov    $0xf0182000,%esi
f01007e6:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007ec:	50                   	push   %eax
f01007ed:	56                   	push   %esi
f01007ee:	8d 83 80 5e f8 ff    	lea    -0x7a180(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	e8 4d 31 00 00       	call   f0103947 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007fa:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fd:	29 fe                	sub    %edi,%esi
f01007ff:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	c1 fe 0a             	sar    $0xa,%esi
f0100808:	56                   	push   %esi
f0100809:	8d 83 a4 5e f8 ff    	lea    -0x7a15c(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 32 31 00 00       	call   f0103947 <cprintf>
	return 0;
}
f0100815:	b8 00 00 00 00       	mov    $0x0,%eax
f010081a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081d:	5b                   	pop    %ebx
f010081e:	5e                   	pop    %esi
f010081f:	5f                   	pop    %edi
f0100820:	5d                   	pop    %ebp
f0100821:	c3                   	ret    

f0100822 <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
f0100822:	b8 00 00 00 00       	mov    $0x0,%eax
f0100827:	c3                   	ret    

f0100828 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100828:	55                   	push   %ebp
f0100829:	89 e5                	mov    %esp,%ebp
f010082b:	57                   	push   %edi
f010082c:	56                   	push   %esi
f010082d:	53                   	push   %ebx
f010082e:	83 ec 68             	sub    $0x68,%esp
f0100831:	e8 31 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100836:	81 c3 32 f0 07 00    	add    $0x7f032,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010083c:	8d 83 d0 5e f8 ff    	lea    -0x7a130(%ebx),%eax
f0100842:	50                   	push   %eax
f0100843:	e8 ff 30 00 00       	call   f0103947 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100848:	8d 83 f4 5e f8 ff    	lea    -0x7a10c(%ebx),%eax
f010084e:	89 04 24             	mov    %eax,(%esp)
f0100851:	e8 f1 30 00 00       	call   f0103947 <cprintf>

	if (tf != NULL)
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010085d:	74 0e                	je     f010086d <monitor+0x45>
		print_trapframe(tf);
f010085f:	83 ec 0c             	sub    $0xc,%esp
f0100862:	ff 75 08             	push   0x8(%ebp)
f0100865:	e8 ba 35 00 00       	call   f0103e24 <print_trapframe>
f010086a:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010086d:	8d bb 8a 5d f8 ff    	lea    -0x7a276(%ebx),%edi
f0100873:	eb 4a                	jmp    f01008bf <monitor+0x97>
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	0f be c0             	movsbl %al,%eax
f010087b:	50                   	push   %eax
f010087c:	57                   	push   %edi
f010087d:	e8 13 46 00 00       	call   f0104e95 <strchr>
f0100882:	83 c4 10             	add    $0x10,%esp
f0100885:	85 c0                	test   %eax,%eax
f0100887:	74 08                	je     f0100891 <monitor+0x69>
			*buf++ = 0;
f0100889:	c6 06 00             	movb   $0x0,(%esi)
f010088c:	8d 76 01             	lea    0x1(%esi),%esi
f010088f:	eb 79                	jmp    f010090a <monitor+0xe2>
		if (*buf == 0)
f0100891:	80 3e 00             	cmpb   $0x0,(%esi)
f0100894:	74 7f                	je     f0100915 <monitor+0xed>
		if (argc == MAXARGS-1) {
f0100896:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010089a:	74 0f                	je     f01008ab <monitor+0x83>
		argv[argc++] = buf;
f010089c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010089f:	8d 48 01             	lea    0x1(%eax),%ecx
f01008a2:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01008a5:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a9:	eb 44                	jmp    f01008ef <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008ab:	83 ec 08             	sub    $0x8,%esp
f01008ae:	6a 10                	push   $0x10
f01008b0:	8d 83 8f 5d f8 ff    	lea    -0x7a271(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 8b 30 00 00       	call   f0103947 <cprintf>
			return 0;
f01008bc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008bf:	8d 83 86 5d f8 ff    	lea    -0x7a27a(%ebx),%eax
f01008c5:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01008c8:	83 ec 0c             	sub    $0xc,%esp
f01008cb:	ff 75 a4             	push   -0x5c(%ebp)
f01008ce:	e8 71 43 00 00       	call   f0104c44 <readline>
f01008d3:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01008d5:	83 c4 10             	add    $0x10,%esp
f01008d8:	85 c0                	test   %eax,%eax
f01008da:	74 ec                	je     f01008c8 <monitor+0xa0>
	argv[argc] = 0;
f01008dc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01008e3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01008ea:	eb 1e                	jmp    f010090a <monitor+0xe2>
			buf++;
f01008ec:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008ef:	0f b6 06             	movzbl (%esi),%eax
f01008f2:	84 c0                	test   %al,%al
f01008f4:	74 14                	je     f010090a <monitor+0xe2>
f01008f6:	83 ec 08             	sub    $0x8,%esp
f01008f9:	0f be c0             	movsbl %al,%eax
f01008fc:	50                   	push   %eax
f01008fd:	57                   	push   %edi
f01008fe:	e8 92 45 00 00       	call   f0104e95 <strchr>
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 e2                	je     f01008ec <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f010090a:	0f b6 06             	movzbl (%esi),%eax
f010090d:	84 c0                	test   %al,%al
f010090f:	0f 85 60 ff ff ff    	jne    f0100875 <monitor+0x4d>
	argv[argc] = 0;
f0100915:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100918:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f010091f:	00 
	if (argc == 0)
f0100920:	85 c0                	test   %eax,%eax
f0100922:	74 9b                	je     f01008bf <monitor+0x97>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100924:	83 ec 08             	sub    $0x8,%esp
f0100927:	8d 83 56 5d f8 ff    	lea    -0x7a2aa(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	ff 75 a8             	push   -0x58(%ebp)
f0100931:	e8 ff 44 00 00       	call   f0104e35 <strcmp>
f0100936:	83 c4 10             	add    $0x10,%esp
f0100939:	85 c0                	test   %eax,%eax
f010093b:	74 38                	je     f0100975 <monitor+0x14d>
f010093d:	83 ec 08             	sub    $0x8,%esp
f0100940:	8d 83 64 5d f8 ff    	lea    -0x7a29c(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	ff 75 a8             	push   -0x58(%ebp)
f010094a:	e8 e6 44 00 00       	call   f0104e35 <strcmp>
f010094f:	83 c4 10             	add    $0x10,%esp
f0100952:	85 c0                	test   %eax,%eax
f0100954:	74 1a                	je     f0100970 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100956:	83 ec 08             	sub    $0x8,%esp
f0100959:	ff 75 a8             	push   -0x58(%ebp)
f010095c:	8d 83 ac 5d f8 ff    	lea    -0x7a254(%ebx),%eax
f0100962:	50                   	push   %eax
f0100963:	e8 df 2f 00 00       	call   f0103947 <cprintf>
	return 0;
f0100968:	83 c4 10             	add    $0x10,%esp
f010096b:	e9 4f ff ff ff       	jmp    f01008bf <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100970:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100975:	83 ec 04             	sub    $0x4,%esp
f0100978:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010097b:	ff 75 08             	push   0x8(%ebp)
f010097e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100981:	52                   	push   %edx
f0100982:	ff 75 a4             	push   -0x5c(%ebp)
f0100985:	ff 94 83 d0 17 00 00 	call   *0x17d0(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f010098c:	83 c4 10             	add    $0x10,%esp
f010098f:	85 c0                	test   %eax,%eax
f0100991:	0f 89 28 ff ff ff    	jns    f01008bf <monitor+0x97>
				break;
	}
}
f0100997:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010099a:	5b                   	pop    %ebx
f010099b:	5e                   	pop    %esi
f010099c:	5f                   	pop    %edi
f010099d:	5d                   	pop    %ebp
f010099e:	c3                   	ret    

f010099f <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010099f:	e8 41 27 00 00       	call   f01030e5 <__x86.get_pc_thunk.dx>
f01009a4:	81 c2 c4 ee 07 00    	add    $0x7eec4,%edx
// Initialize nextfree if this is the first time.
// 'end' is a magic symbol automatically generated by the linker,
// which points to the end of the kernel's bss segment:
// the first virtual address that the linker did *not* assign
// to any kernel code or global variables.
if (!nextfree) {
f01009aa:	83 ba dc 1a 00 00 00 	cmpl   $0x0,0x1adc(%edx)
f01009b1:	74 1b                	je     f01009ce <boot_alloc+0x2f>
// Allocate a chunk large enough to hold 'n' bytes, then update
// nextfree.  Make sure nextfree is kept aligned
// to a multiple of PGSIZE.
//
// LAB 2: Your code here.
result=nextfree;
f01009b3:	8b 8a dc 1a 00 00    	mov    0x1adc(%edx),%ecx
nextfree = ROUNDUP((char *)result +n, PGSIZE);
f01009b9:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f01009c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009c5:	89 82 dc 1a 00 00    	mov    %eax,0x1adc(%edx)
return result;
}
f01009cb:	89 c8                	mov    %ecx,%eax
f01009cd:	c3                   	ret    
nextfree = ROUNDUP((char *) end, PGSIZE);
f01009ce:	c7 c1 00 20 18 f0    	mov    $0xf0182000,%ecx
f01009d4:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01009da:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01009e0:	89 8a dc 1a 00 00    	mov    %ecx,0x1adc(%edx)
f01009e6:	eb cb                	jmp    f01009b3 <boot_alloc+0x14>

f01009e8 <nvram_read>:
{
f01009e8:	55                   	push   %ebp
f01009e9:	89 e5                	mov    %esp,%ebp
f01009eb:	57                   	push   %edi
f01009ec:	56                   	push   %esi
f01009ed:	53                   	push   %ebx
f01009ee:	83 ec 18             	sub    $0x18,%esp
f01009f1:	e8 71 f7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01009f6:	81 c3 72 ee 07 00    	add    $0x7ee72,%ebx
f01009fc:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009fe:	50                   	push   %eax
f01009ff:	e8 bc 2e 00 00       	call   f01038c0 <mc146818_read>
f0100a04:	89 c7                	mov    %eax,%edi
f0100a06:	83 c6 01             	add    $0x1,%esi
f0100a09:	89 34 24             	mov    %esi,(%esp)
f0100a0c:	e8 af 2e 00 00       	call   f01038c0 <mc146818_read>
f0100a11:	c1 e0 08             	shl    $0x8,%eax
f0100a14:	09 f8                	or     %edi,%eax
}
f0100a16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a19:	5b                   	pop    %ebx
f0100a1a:	5e                   	pop    %esi
f0100a1b:	5f                   	pop    %edi
f0100a1c:	5d                   	pop    %ebp
f0100a1d:	c3                   	ret    

f0100a1e <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a1e:	55                   	push   %ebp
f0100a1f:	89 e5                	mov    %esp,%ebp
f0100a21:	53                   	push   %ebx
f0100a22:	83 ec 04             	sub    $0x4,%esp
f0100a25:	e8 bf 26 00 00       	call   f01030e9 <__x86.get_pc_thunk.cx>
f0100a2a:	81 c1 3e ee 07 00    	add    $0x7ee3e,%ecx
f0100a30:	89 c3                	mov    %eax,%ebx
f0100a32:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a34:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100a37:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100a3a:	f6 c2 01             	test   $0x1,%dl
f0100a3d:	74 54                	je     f0100a93 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a3f:	89 d3                	mov    %edx,%ebx
f0100a41:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a47:	c1 ea 0c             	shr    $0xc,%edx
f0100a4a:	3b 91 d8 1a 00 00    	cmp    0x1ad8(%ecx),%edx
f0100a50:	73 26                	jae    f0100a78 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100a52:	c1 e8 0c             	shr    $0xc,%eax
f0100a55:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100a5a:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a61:	89 d0                	mov    %edx,%eax
f0100a63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a68:	f6 c2 01             	test   $0x1,%dl
f0100a6b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a70:	0f 44 c2             	cmove  %edx,%eax
}
f0100a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a76:	c9                   	leave  
f0100a77:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a78:	53                   	push   %ebx
f0100a79:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f0100a7f:	50                   	push   %eax
f0100a80:	68 1b 03 00 00       	push   $0x31b
f0100a85:	8d 81 5d 67 f8 ff    	lea    -0x798a3(%ecx),%eax
f0100a8b:	50                   	push   %eax
f0100a8c:	89 cb                	mov    %ecx,%ebx
f0100a8e:	e8 1e f6 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100a93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a98:	eb d9                	jmp    f0100a73 <check_va2pa+0x55>

f0100a9a <check_page_free_list>:
{
f0100a9a:	55                   	push   %ebp
f0100a9b:	89 e5                	mov    %esp,%ebp
f0100a9d:	57                   	push   %edi
f0100a9e:	56                   	push   %esi
f0100a9f:	53                   	push   %ebx
f0100aa0:	83 ec 2c             	sub    $0x2c,%esp
f0100aa3:	e8 45 26 00 00       	call   f01030ed <__x86.get_pc_thunk.di>
f0100aa8:	81 c7 c0 ed 07 00    	add    $0x7edc0,%edi
f0100aae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ab1:	84 c0                	test   %al,%al
f0100ab3:	0f 85 dc 02 00 00    	jne    f0100d95 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100ab9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100abc:	83 b8 e4 1a 00 00 00 	cmpl   $0x0,0x1ae4(%eax)
f0100ac3:	74 0a                	je     f0100acf <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ac5:	bf 00 04 00 00       	mov    $0x400,%edi
f0100aca:	e9 29 03 00 00       	jmp    f0100df8 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100acf:	83 ec 04             	sub    $0x4,%esp
f0100ad2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ad5:	8d 83 40 5f f8 ff    	lea    -0x7a0c0(%ebx),%eax
f0100adb:	50                   	push   %eax
f0100adc:	68 57 02 00 00       	push   $0x257
f0100ae1:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100ae7:	50                   	push   %eax
f0100ae8:	e8 c4 f5 ff ff       	call   f01000b1 <_panic>
f0100aed:	50                   	push   %eax
f0100aee:	89 cb                	mov    %ecx,%ebx
f0100af0:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f0100af6:	50                   	push   %eax
f0100af7:	6a 56                	push   $0x56
f0100af9:	8d 81 69 67 f8 ff    	lea    -0x79897(%ecx),%eax
f0100aff:	50                   	push   %eax
f0100b00:	e8 ac f5 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b05:	8b 36                	mov    (%esi),%esi
f0100b07:	85 f6                	test   %esi,%esi
f0100b09:	74 47                	je     f0100b52 <check_page_free_list+0xb8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b0b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100b0e:	89 f0                	mov    %esi,%eax
f0100b10:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0100b16:	c1 f8 03             	sar    $0x3,%eax
f0100b19:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b1c:	89 c2                	mov    %eax,%edx
f0100b1e:	c1 ea 16             	shr    $0x16,%edx
f0100b21:	39 fa                	cmp    %edi,%edx
f0100b23:	73 e0                	jae    f0100b05 <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100b25:	89 c2                	mov    %eax,%edx
f0100b27:	c1 ea 0c             	shr    $0xc,%edx
f0100b2a:	3b 91 d8 1a 00 00    	cmp    0x1ad8(%ecx),%edx
f0100b30:	73 bb                	jae    f0100aed <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100b32:	83 ec 04             	sub    $0x4,%esp
f0100b35:	68 80 00 00 00       	push   $0x80
f0100b3a:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b3f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b44:	50                   	push   %eax
f0100b45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b48:	e8 87 43 00 00       	call   f0104ed4 <memset>
f0100b4d:	83 c4 10             	add    $0x10,%esp
f0100b50:	eb b3                	jmp    f0100b05 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100b52:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b57:	e8 43 fe ff ff       	call   f010099f <boot_alloc>
f0100b5c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b62:	8b 90 e4 1a 00 00    	mov    0x1ae4(%eax),%edx
		assert(pp >= pages);
f0100b68:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
		assert(pp < pages + npages);
f0100b6e:	8b 80 d8 1a 00 00    	mov    0x1ad8(%eax),%eax
f0100b74:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100b77:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b7a:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b7f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100b84:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b87:	e9 07 01 00 00       	jmp    f0100c93 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100b8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b8f:	8d 83 77 67 f8 ff    	lea    -0x79889(%ebx),%eax
f0100b95:	50                   	push   %eax
f0100b96:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100b9c:	50                   	push   %eax
f0100b9d:	68 71 02 00 00       	push   $0x271
f0100ba2:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100ba8:	50                   	push   %eax
f0100ba9:	e8 03 f5 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bb1:	8d 83 98 67 f8 ff    	lea    -0x79868(%ebx),%eax
f0100bb7:	50                   	push   %eax
f0100bb8:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100bbe:	50                   	push   %eax
f0100bbf:	68 72 02 00 00       	push   $0x272
f0100bc4:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100bca:	50                   	push   %eax
f0100bcb:	e8 e1 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bd0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bd3:	8d 83 64 5f f8 ff    	lea    -0x7a09c(%ebx),%eax
f0100bd9:	50                   	push   %eax
f0100bda:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100be0:	50                   	push   %eax
f0100be1:	68 73 02 00 00       	push   $0x273
f0100be6:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100bec:	50                   	push   %eax
f0100bed:	e8 bf f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100bf2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100bf5:	8d 83 ac 67 f8 ff    	lea    -0x79854(%ebx),%eax
f0100bfb:	50                   	push   %eax
f0100bfc:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100c02:	50                   	push   %eax
f0100c03:	68 76 02 00 00       	push   $0x276
f0100c08:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100c0e:	50                   	push   %eax
f0100c0f:	e8 9d f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c17:	8d 83 bd 67 f8 ff    	lea    -0x79843(%ebx),%eax
f0100c1d:	50                   	push   %eax
f0100c1e:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100c24:	50                   	push   %eax
f0100c25:	68 77 02 00 00       	push   $0x277
f0100c2a:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100c30:	50                   	push   %eax
f0100c31:	e8 7b f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c36:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c39:	8d 83 98 5f f8 ff    	lea    -0x7a068(%ebx),%eax
f0100c3f:	50                   	push   %eax
f0100c40:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100c46:	50                   	push   %eax
f0100c47:	68 78 02 00 00       	push   $0x278
f0100c4c:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100c52:	50                   	push   %eax
f0100c53:	e8 59 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c5b:	8d 83 d6 67 f8 ff    	lea    -0x7982a(%ebx),%eax
f0100c61:	50                   	push   %eax
f0100c62:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100c68:	50                   	push   %eax
f0100c69:	68 79 02 00 00       	push   $0x279
f0100c6e:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100c74:	50                   	push   %eax
f0100c75:	e8 37 f4 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100c7a:	89 c3                	mov    %eax,%ebx
f0100c7c:	c1 eb 0c             	shr    $0xc,%ebx
f0100c7f:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100c82:	76 6d                	jbe    f0100cf1 <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100c84:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c89:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c8c:	77 7c                	ja     f0100d0a <check_page_free_list+0x270>
			++nfree_extmem;
f0100c8e:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c91:	8b 12                	mov    (%edx),%edx
f0100c93:	85 d2                	test   %edx,%edx
f0100c95:	0f 84 91 00 00 00    	je     f0100d2c <check_page_free_list+0x292>
		assert(pp >= pages);
f0100c9b:	39 d1                	cmp    %edx,%ecx
f0100c9d:	0f 87 e9 fe ff ff    	ja     f0100b8c <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100ca3:	39 d6                	cmp    %edx,%esi
f0100ca5:	0f 86 03 ff ff ff    	jbe    f0100bae <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cab:	89 d0                	mov    %edx,%eax
f0100cad:	29 c8                	sub    %ecx,%eax
f0100caf:	a8 07                	test   $0x7,%al
f0100cb1:	0f 85 19 ff ff ff    	jne    f0100bd0 <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;
f0100cb7:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100cba:	c1 e0 0c             	shl    $0xc,%eax
f0100cbd:	0f 84 2f ff ff ff    	je     f0100bf2 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cc8:	0f 84 46 ff ff ff    	je     f0100c14 <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cce:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cd3:	0f 84 5d ff ff ff    	je     f0100c36 <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cd9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cde:	0f 84 74 ff ff ff    	je     f0100c58 <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ce4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ce9:	77 8f                	ja     f0100c7a <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100ceb:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100cef:	eb a0                	jmp    f0100c91 <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf1:	50                   	push   %eax
f0100cf2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cf5:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f0100cfb:	50                   	push   %eax
f0100cfc:	6a 56                	push   $0x56
f0100cfe:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0100d04:	50                   	push   %eax
f0100d05:	e8 a7 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d0d:	8d 83 bc 5f f8 ff    	lea    -0x7a044(%ebx),%eax
f0100d13:	50                   	push   %eax
f0100d14:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100d1a:	50                   	push   %eax
f0100d1b:	68 7a 02 00 00       	push   $0x27a
f0100d20:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100d26:	50                   	push   %eax
f0100d27:	e8 85 f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_basemem > 0);
f0100d2c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100d2f:	85 db                	test   %ebx,%ebx
f0100d31:	7e 1e                	jle    f0100d51 <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100d33:	85 ff                	test   %edi,%edi
f0100d35:	7e 3c                	jle    f0100d73 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100d37:	83 ec 0c             	sub    $0xc,%esp
f0100d3a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d3d:	8d 83 04 60 f8 ff    	lea    -0x79ffc(%ebx),%eax
f0100d43:	50                   	push   %eax
f0100d44:	e8 fe 2b 00 00       	call   f0103947 <cprintf>
}
f0100d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d4c:	5b                   	pop    %ebx
f0100d4d:	5e                   	pop    %esi
f0100d4e:	5f                   	pop    %edi
f0100d4f:	5d                   	pop    %ebp
f0100d50:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d54:	8d 83 f0 67 f8 ff    	lea    -0x79810(%ebx),%eax
f0100d5a:	50                   	push   %eax
f0100d5b:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100d61:	50                   	push   %eax
f0100d62:	68 82 02 00 00       	push   $0x282
f0100d67:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	e8 3e f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d73:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d76:	8d 83 02 68 f8 ff    	lea    -0x797fe(%ebx),%eax
f0100d7c:	50                   	push   %eax
f0100d7d:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0100d83:	50                   	push   %eax
f0100d84:	68 83 02 00 00       	push   $0x283
f0100d89:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100d8f:	50                   	push   %eax
f0100d90:	e8 1c f3 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100d95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d98:	8b 80 e4 1a 00 00    	mov    0x1ae4(%eax),%eax
f0100d9e:	85 c0                	test   %eax,%eax
f0100da0:	0f 84 29 fd ff ff    	je     f0100acf <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100da6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100da9:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dac:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100daf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100db2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100db5:	89 c2                	mov    %eax,%edx
f0100db7:	2b 97 d0 1a 00 00    	sub    0x1ad0(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dbd:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100dc3:	0f 95 c2             	setne  %dl
f0100dc6:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100dc9:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100dcd:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100dcf:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd3:	8b 00                	mov    (%eax),%eax
f0100dd5:	85 c0                	test   %eax,%eax
f0100dd7:	75 d9                	jne    f0100db2 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100dd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ddc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100de2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100de5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100de8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100dea:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ded:	89 87 e4 1a 00 00    	mov    %eax,0x1ae4(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100df3:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dfb:	8b b0 e4 1a 00 00    	mov    0x1ae4(%eax),%esi
f0100e01:	e9 01 fd ff ff       	jmp    f0100b07 <check_page_free_list+0x6d>

f0100e06 <page_init>:
{
f0100e06:	55                   	push   %ebp
f0100e07:	89 e5                	mov    %esp,%ebp
f0100e09:	57                   	push   %edi
f0100e0a:	56                   	push   %esi
f0100e0b:	53                   	push   %ebx
f0100e0c:	83 ec 0c             	sub    $0xc,%esp
f0100e0f:	e8 53 f3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100e14:	81 c3 54 ea 07 00    	add    $0x7ea54,%ebx
uint32_t nextfree = (uint32_t)boot_alloc(0);
f0100e1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e1f:	e8 7b fb ff ff       	call   f010099f <boot_alloc>
pages[0].pp_link = NULL;
f0100e24:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f0100e2a:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
pages[0].pp_ref=1;
f0100e30:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f0100e36:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		if ((i < ((nextfree-KERNBASE) / PGSIZE))&& (i>= (IOPHYSMEM /PGSIZE))){
f0100e3c:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100e42:	c1 e9 0c             	shr    $0xc,%ecx
f0100e45:	8b 93 e4 1a 00 00    	mov    0x1ae4(%ebx),%edx
for (i = 1; i < npages; i++) {
f0100e4b:	be 00 00 00 00       	mov    $0x0,%esi
f0100e50:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e55:	eb 20                	jmp    f0100e77 <page_init+0x71>
		pages[i].pp_link = page_free_list;
f0100e57:	8b b3 d0 1a 00 00    	mov    0x1ad0(%ebx),%esi
f0100e5d:	89 14 c6             	mov    %edx,(%esi,%eax,8)
		pages[i].pp_ref = 0;
f0100e60:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f0100e66:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100e69:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
f0100e6f:	be 01 00 00 00       	mov    $0x1,%esi
for (i = 1; i < npages; i++) {
f0100e74:	83 c0 01             	add    $0x1,%eax
f0100e77:	39 83 d8 1a 00 00    	cmp    %eax,0x1ad8(%ebx)
f0100e7d:	76 27                	jbe    f0100ea6 <page_init+0xa0>
		if ((i < ((nextfree-KERNBASE) / PGSIZE))&& (i>= (IOPHYSMEM /PGSIZE))){
f0100e7f:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100e84:	76 d1                	jbe    f0100e57 <page_init+0x51>
f0100e86:	39 c1                	cmp    %eax,%ecx
f0100e88:	76 cd                	jbe    f0100e57 <page_init+0x51>
		pages[i].pp_link=NULL;
f0100e8a:	8b bb d0 1a 00 00    	mov    0x1ad0(%ebx),%edi
f0100e90:	c7 04 c7 00 00 00 00 	movl   $0x0,(%edi,%eax,8)
		pages[i].pp_ref =1;
f0100e97:	8b bb d0 1a 00 00    	mov    0x1ad0(%ebx),%edi
f0100e9d:	66 c7 44 c7 04 01 00 	movw   $0x1,0x4(%edi,%eax,8)
f0100ea4:	eb ce                	jmp    f0100e74 <page_init+0x6e>
f0100ea6:	89 f0                	mov    %esi,%eax
f0100ea8:	84 c0                	test   %al,%al
f0100eaa:	74 06                	je     f0100eb2 <page_init+0xac>
f0100eac:	89 93 e4 1a 00 00    	mov    %edx,0x1ae4(%ebx)
}
f0100eb2:	83 c4 0c             	add    $0xc,%esp
f0100eb5:	5b                   	pop    %ebx
f0100eb6:	5e                   	pop    %esi
f0100eb7:	5f                   	pop    %edi
f0100eb8:	5d                   	pop    %ebp
f0100eb9:	c3                   	ret    

f0100eba <page_alloc>:
{
f0100eba:	55                   	push   %ebp
f0100ebb:	89 e5                	mov    %esp,%ebp
f0100ebd:	56                   	push   %esi
f0100ebe:	53                   	push   %ebx
f0100ebf:	e8 a3 f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ec4:	81 c3 a4 e9 07 00    	add    $0x7e9a4,%ebx
	if (page_free_list==NULL) {
f0100eca:	8b b3 e4 1a 00 00    	mov    0x1ae4(%ebx),%esi
f0100ed0:	85 f6                	test   %esi,%esi
f0100ed2:	74 14                	je     f0100ee8 <page_alloc+0x2e>
  	page_free_list = page_free_list->pp_link;
f0100ed4:	8b 06                	mov    (%esi),%eax
f0100ed6:	89 83 e4 1a 00 00    	mov    %eax,0x1ae4(%ebx)
  	pginfo->pp_link = NULL;
f0100edc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (alloc_flags & ALLOC_ZERO){ 
f0100ee2:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ee6:	75 09                	jne    f0100ef1 <page_alloc+0x37>
}
f0100ee8:	89 f0                	mov    %esi,%eax
f0100eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100eed:	5b                   	pop    %ebx
f0100eee:	5e                   	pop    %esi
f0100eef:	5d                   	pop    %ebp
f0100ef0:	c3                   	ret    
f0100ef1:	89 f0                	mov    %esi,%eax
f0100ef3:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0100ef9:	c1 f8 03             	sar    $0x3,%eax
f0100efc:	89 c2                	mov    %eax,%edx
f0100efe:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f01:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f06:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0100f0c:	73 1b                	jae    f0100f29 <page_alloc+0x6f>
		memset(page2kva(pginfo), 0, PGSIZE);
f0100f0e:	83 ec 04             	sub    $0x4,%esp
f0100f11:	68 00 10 00 00       	push   $0x1000
f0100f16:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f18:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f1e:	52                   	push   %edx
f0100f1f:	e8 b0 3f 00 00       	call   f0104ed4 <memset>
f0100f24:	83 c4 10             	add    $0x10,%esp
f0100f27:	eb bf                	jmp    f0100ee8 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f29:	52                   	push   %edx
f0100f2a:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f0100f30:	50                   	push   %eax
f0100f31:	6a 56                	push   $0x56
f0100f33:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0100f39:	50                   	push   %eax
f0100f3a:	e8 72 f1 ff ff       	call   f01000b1 <_panic>

f0100f3f <page_free>:
{
f0100f3f:	55                   	push   %ebp
f0100f40:	89 e5                	mov    %esp,%ebp
f0100f42:	53                   	push   %ebx
f0100f43:	83 ec 04             	sub    $0x4,%esp
f0100f46:	e8 1c f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100f4b:	81 c3 1d e9 07 00    	add    $0x7e91d,%ebx
f0100f51:	8b 45 08             	mov    0x8(%ebp),%eax
if (pp->pp_ref > 0){
f0100f54:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f59:	75 18                	jne    f0100f73 <page_free+0x34>
if (pp->pp_link){ 
f0100f5b:	83 38 00             	cmpl   $0x0,(%eax)
f0100f5e:	75 2e                	jne    f0100f8e <page_free+0x4f>
pp->pp_link=page_free_list;
f0100f60:	8b 8b e4 1a 00 00    	mov    0x1ae4(%ebx),%ecx
f0100f66:	89 08                	mov    %ecx,(%eax)
page_free_list=pp;
f0100f68:	89 83 e4 1a 00 00    	mov    %eax,0x1ae4(%ebx)
}
f0100f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f71:	c9                   	leave  
f0100f72:	c3                   	ret    
	panic("Page free not working. The page is being reffered \n");
f0100f73:	83 ec 04             	sub    $0x4,%esp
f0100f76:	8d 83 28 60 f8 ff    	lea    -0x79fd8(%ebx),%eax
f0100f7c:	50                   	push   %eax
f0100f7d:	68 48 01 00 00       	push   $0x148
f0100f82:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100f88:	50                   	push   %eax
f0100f89:	e8 23 f1 ff ff       	call   f01000b1 <_panic>
	panic("Page link is not null. Page free broken.\n");
f0100f8e:	83 ec 04             	sub    $0x4,%esp
f0100f91:	8d 83 5c 60 f8 ff    	lea    -0x79fa4(%ebx),%eax
f0100f97:	50                   	push   %eax
f0100f98:	68 4b 01 00 00       	push   $0x14b
f0100f9d:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0100fa3:	50                   	push   %eax
f0100fa4:	e8 08 f1 ff ff       	call   f01000b1 <_panic>

f0100fa9 <page_decref>:
{
f0100fa9:	55                   	push   %ebp
f0100faa:	89 e5                	mov    %esp,%ebp
f0100fac:	83 ec 08             	sub    $0x8,%esp
f0100faf:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fb2:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fb6:	83 e8 01             	sub    $0x1,%eax
f0100fb9:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fbd:	66 85 c0             	test   %ax,%ax
f0100fc0:	74 02                	je     f0100fc4 <page_decref+0x1b>
}
f0100fc2:	c9                   	leave  
f0100fc3:	c3                   	ret    
		page_free(pp);
f0100fc4:	83 ec 0c             	sub    $0xc,%esp
f0100fc7:	52                   	push   %edx
f0100fc8:	e8 72 ff ff ff       	call   f0100f3f <page_free>
f0100fcd:	83 c4 10             	add    $0x10,%esp
}
f0100fd0:	eb f0                	jmp    f0100fc2 <page_decref+0x19>

f0100fd2 <pgdir_walk>:
{
f0100fd2:	55                   	push   %ebp
f0100fd3:	89 e5                	mov    %esp,%ebp
f0100fd5:	57                   	push   %edi
f0100fd6:	56                   	push   %esi
f0100fd7:	53                   	push   %ebx
f0100fd8:	83 ec 0c             	sub    $0xc,%esp
f0100fdb:	e8 0d 21 00 00       	call   f01030ed <__x86.get_pc_thunk.di>
f0100fe0:	81 c7 88 e8 07 00    	add    $0x7e888,%edi
f0100fe6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int pageTableEntry = PTX(va);
f0100fe9:	89 de                	mov    %ebx,%esi
f0100feb:	c1 ee 0c             	shr    $0xc,%esi
f0100fee:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    int pageDirInx = PDX(va);
f0100ff4:	c1 eb 16             	shr    $0x16,%ebx
    if (pgdir[pageDirInx] & PTE_P){
f0100ff7:	c1 e3 02             	shl    $0x2,%ebx
f0100ffa:	03 5d 08             	add    0x8(%ebp),%ebx
f0100ffd:	8b 03                	mov    (%ebx),%eax
f0100fff:	a8 01                	test   $0x1,%al
f0101001:	75 4f                	jne    f0101052 <pgdir_walk+0x80>
    if (!create){
f0101003:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101007:	0f 84 97 00 00 00    	je     f01010a4 <pgdir_walk+0xd2>
    struct PageInfo* pg = page_alloc(ALLOC_ZERO);
f010100d:	83 ec 0c             	sub    $0xc,%esp
f0101010:	6a 01                	push   $0x1
f0101012:	e8 a3 fe ff ff       	call   f0100eba <page_alloc>
    if (!pg)
f0101017:	83 c4 10             	add    $0x10,%esp
f010101a:	85 c0                	test   %eax,%eax
f010101c:	74 2c                	je     f010104a <pgdir_walk+0x78>
    pg->pp_ref++;
f010101e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101023:	2b 87 d0 1a 00 00    	sub    0x1ad0(%edi),%eax
f0101029:	c1 f8 03             	sar    $0x3,%eax
f010102c:	c1 e0 0c             	shl    $0xc,%eax
    pgdir[pageDirInx] = page2pa(pg) | PTE_P | PTE_U | PTE_W;  
f010102f:	89 c2                	mov    %eax,%edx
f0101031:	83 ca 07             	or     $0x7,%edx
f0101034:	89 13                	mov    %edx,(%ebx)
	if (PGNUM(pa) >= npages)
f0101036:	89 c2                	mov    %eax,%edx
f0101038:	c1 ea 0c             	shr    $0xc,%edx
f010103b:	3b 97 d8 1a 00 00    	cmp    0x1ad8(%edi),%edx
f0101041:	73 46                	jae    f0101089 <pgdir_walk+0xb7>
    return ptebase + pageTableEntry;
f0101043:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
}
f010104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010104d:	5b                   	pop    %ebx
f010104e:	5e                   	pop    %esi
f010104f:	5f                   	pop    %edi
f0101050:	5d                   	pop    %ebp
f0101051:	c3                   	ret    
        pte_t *ptebase = KADDR(PTE_ADDR(pgdir[pageDirInx]));  
f0101052:	89 c2                	mov    %eax,%edx
f0101054:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010105a:	c1 e8 0c             	shr    $0xc,%eax
f010105d:	3b 87 d8 1a 00 00    	cmp    0x1ad8(%edi),%eax
f0101063:	73 09                	jae    f010106e <pgdir_walk+0x9c>
        return ptebase + pageTableEntry;
f0101065:	8d 84 b2 00 00 00 f0 	lea    -0x10000000(%edx,%esi,4),%eax
f010106c:	eb dc                	jmp    f010104a <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010106e:	52                   	push   %edx
f010106f:	8d 87 1c 5f f8 ff    	lea    -0x7a0e4(%edi),%eax
f0101075:	50                   	push   %eax
f0101076:	68 79 01 00 00       	push   $0x179
f010107b:	8d 87 5d 67 f8 ff    	lea    -0x798a3(%edi),%eax
f0101081:	50                   	push   %eax
f0101082:	89 fb                	mov    %edi,%ebx
f0101084:	e8 28 f0 ff ff       	call   f01000b1 <_panic>
f0101089:	50                   	push   %eax
f010108a:	8d 87 1c 5f f8 ff    	lea    -0x7a0e4(%edi),%eax
f0101090:	50                   	push   %eax
f0101091:	68 84 01 00 00       	push   $0x184
f0101096:	8d 87 5d 67 f8 ff    	lea    -0x798a3(%edi),%eax
f010109c:	50                   	push   %eax
f010109d:	89 fb                	mov    %edi,%ebx
f010109f:	e8 0d f0 ff ff       	call   f01000b1 <_panic>
        return NULL;
f01010a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a9:	eb 9f                	jmp    f010104a <pgdir_walk+0x78>

f01010ab <boot_map_region>:
{
f01010ab:	55                   	push   %ebp
f01010ac:	89 e5                	mov    %esp,%ebp
f01010ae:	57                   	push   %edi
f01010af:	56                   	push   %esi
f01010b0:	53                   	push   %ebx
f01010b1:	83 ec 1c             	sub    $0x1c,%esp
f01010b4:	89 c7                	mov    %eax,%edi
f01010b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01010b9:	89 ce                	mov    %ecx,%esi
    for(i = 0; i < size; i += PGSIZE) {
f01010bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010c0:	eb 13                	jmp    f01010d5 <boot_map_region+0x2a>
    	*pageTblEntry = (pa + i) | perm | PTE_P; 
f01010c2:	89 d8                	mov    %ebx,%eax
f01010c4:	03 45 08             	add    0x8(%ebp),%eax
f01010c7:	0b 45 0c             	or     0xc(%ebp),%eax
f01010ca:	83 c8 01             	or     $0x1,%eax
f01010cd:	89 02                	mov    %eax,(%edx)
    for(i = 0; i < size; i += PGSIZE) {
f01010cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010d5:	39 f3                	cmp    %esi,%ebx
f01010d7:	73 1a                	jae    f01010f3 <boot_map_region+0x48>
    	pageTblEntry = pgdir_walk(pgdir, (void*) (va + i), 1);
f01010d9:	83 ec 04             	sub    $0x4,%esp
f01010dc:	6a 01                	push   $0x1
f01010de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010e1:	01 d8                	add    %ebx,%eax
f01010e3:	50                   	push   %eax
f01010e4:	57                   	push   %edi
f01010e5:	e8 e8 fe ff ff       	call   f0100fd2 <pgdir_walk>
f01010ea:	89 c2                	mov    %eax,%edx
    	if(!pageTblEntry) return;
f01010ec:	83 c4 10             	add    $0x10,%esp
f01010ef:	85 c0                	test   %eax,%eax
f01010f1:	75 cf                	jne    f01010c2 <boot_map_region+0x17>
}
f01010f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010f6:	5b                   	pop    %ebx
f01010f7:	5e                   	pop    %esi
f01010f8:	5f                   	pop    %edi
f01010f9:	5d                   	pop    %ebp
f01010fa:	c3                   	ret    

f01010fb <page_lookup>:
{
f01010fb:	55                   	push   %ebp
f01010fc:	89 e5                	mov    %esp,%ebp
f01010fe:	53                   	push   %ebx
f01010ff:	83 ec 08             	sub    $0x8,%esp
f0101102:	e8 60 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101107:	81 c3 61 e7 07 00    	add    $0x7e761,%ebx
  pte_t * pg_tlb_entry = pgdir_walk(pgdir, va, 0);
f010110d:	6a 00                	push   $0x0
f010110f:	ff 75 0c             	push   0xc(%ebp)
f0101112:	ff 75 08             	push   0x8(%ebp)
f0101115:	e8 b8 fe ff ff       	call   f0100fd2 <pgdir_walk>
  *pte_store = pg_tlb_entry;
f010111a:	8b 55 10             	mov    0x10(%ebp),%edx
f010111d:	89 02                	mov    %eax,(%edx)
  if(pg_tlb_entry == NULL){
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	85 c0                	test   %eax,%eax
f0101124:	74 16                	je     f010113c <page_lookup+0x41>
f0101126:	8b 00                	mov    (%eax),%eax
f0101128:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010112b:	39 83 d8 1a 00 00    	cmp    %eax,0x1ad8(%ebx)
f0101131:	76 0e                	jbe    f0101141 <page_lookup+0x46>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101133:	8b 93 d0 1a 00 00    	mov    0x1ad0(%ebx),%edx
f0101139:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010113c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010113f:	c9                   	leave  
f0101140:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101141:	83 ec 04             	sub    $0x4,%esp
f0101144:	8d 83 88 60 f8 ff    	lea    -0x79f78(%ebx),%eax
f010114a:	50                   	push   %eax
f010114b:	6a 4f                	push   $0x4f
f010114d:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0101153:	50                   	push   %eax
f0101154:	e8 58 ef ff ff       	call   f01000b1 <_panic>

f0101159 <page_remove>:
{
f0101159:	55                   	push   %ebp
f010115a:	89 e5                	mov    %esp,%ebp
f010115c:	53                   	push   %ebx
f010115d:	83 ec 18             	sub    $0x18,%esp
f0101160:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    struct PageInfo* p = page_lookup(pgdir, va, &pageTblEntry);	
f0101163:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101166:	50                   	push   %eax
f0101167:	53                   	push   %ebx
f0101168:	ff 75 08             	push   0x8(%ebp)
f010116b:	e8 8b ff ff ff       	call   f01010fb <page_lookup>
    if(!p || !(*pageTblEntry & PTE_P)) {
f0101170:	83 c4 10             	add    $0x10,%esp
f0101173:	85 c0                	test   %eax,%eax
f0101175:	74 08                	je     f010117f <page_remove+0x26>
f0101177:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010117a:	f6 02 01             	testb  $0x1,(%edx)
f010117d:	75 05                	jne    f0101184 <page_remove+0x2b>
}
f010117f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101182:	c9                   	leave  
f0101183:	c3                   	ret    
    page_decref(p); 
f0101184:	83 ec 0c             	sub    $0xc,%esp
f0101187:	50                   	push   %eax
f0101188:	e8 1c fe ff ff       	call   f0100fa9 <page_decref>
    *pageTblEntry = 0; 
f010118d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101190:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101196:	0f 01 3b             	invlpg (%ebx)
f0101199:	83 c4 10             	add    $0x10,%esp
f010119c:	eb e1                	jmp    f010117f <page_remove+0x26>

f010119e <page_insert>:
{
f010119e:	55                   	push   %ebp
f010119f:	89 e5                	mov    %esp,%ebp
f01011a1:	57                   	push   %edi
f01011a2:	56                   	push   %esi
f01011a3:	53                   	push   %ebx
f01011a4:	83 ec 10             	sub    $0x10,%esp
f01011a7:	e8 41 1f 00 00       	call   f01030ed <__x86.get_pc_thunk.di>
f01011ac:	81 c7 bc e6 07 00    	add    $0x7e6bc,%edi
f01011b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t * pg_tlb_entry = pgdir_walk(pgdir, va, 1);
f01011b5:	6a 01                	push   $0x1
f01011b7:	ff 75 10             	push   0x10(%ebp)
f01011ba:	ff 75 08             	push   0x8(%ebp)
f01011bd:	e8 10 fe ff ff       	call   f0100fd2 <pgdir_walk>
  if(pg_tlb_entry == NULL)
f01011c2:	83 c4 10             	add    $0x10,%esp
f01011c5:	85 c0                	test   %eax,%eax
f01011c7:	74 65                	je     f010122e <page_insert+0x90>
f01011c9:	89 c3                	mov    %eax,%ebx
  if(*pg_tlb_entry & PTE_P){
f01011cb:	8b 00                	mov    (%eax),%eax
f01011cd:	a8 01                	test   $0x1,%al
f01011cf:	74 28                	je     f01011f9 <page_insert+0x5b>
    if(PTE_ADDR(*pg_tlb_entry) == pa){
f01011d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	return (pp - pages) << PGSHIFT;
f01011d6:	89 f2                	mov    %esi,%edx
f01011d8:	2b 97 d0 1a 00 00    	sub    0x1ad0(%edi),%edx
f01011de:	c1 fa 03             	sar    $0x3,%edx
f01011e1:	c1 e2 0c             	shl    $0xc,%edx
f01011e4:	39 d0                	cmp    %edx,%eax
f01011e6:	74 39                	je     f0101221 <page_insert+0x83>
    else{ page_remove(pgdir, va); }
f01011e8:	83 ec 08             	sub    $0x8,%esp
f01011eb:	ff 75 10             	push   0x10(%ebp)
f01011ee:	ff 75 08             	push   0x8(%ebp)
f01011f1:	e8 63 ff ff ff       	call   f0101159 <page_remove>
f01011f6:	83 c4 10             	add    $0x10,%esp
f01011f9:	89 f0                	mov    %esi,%eax
f01011fb:	2b 87 d0 1a 00 00    	sub    0x1ad0(%edi),%eax
f0101201:	c1 f8 03             	sar    $0x3,%eax
f0101204:	c1 e0 0c             	shl    $0xc,%eax
  *pg_tlb_entry = page2pa(pp)|perm|PTE_P;
f0101207:	0b 45 14             	or     0x14(%ebp),%eax
f010120a:	83 c8 01             	or     $0x1,%eax
f010120d:	89 03                	mov    %eax,(%ebx)
  pp->pp_ref ++;
f010120f:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
  return 0;
f0101214:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101219:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121c:	5b                   	pop    %ebx
f010121d:	5e                   	pop    %esi
f010121e:	5f                   	pop    %edi
f010121f:	5d                   	pop    %ebp
f0101220:	c3                   	ret    
f0101221:	8b 45 10             	mov    0x10(%ebp),%eax
f0101224:	0f 01 38             	invlpg (%eax)
      pp->pp_ref --;
f0101227:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f010122c:	eb cb                	jmp    f01011f9 <page_insert+0x5b>
    return -E_NO_MEM;
f010122e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101233:	eb e4                	jmp    f0101219 <page_insert+0x7b>

f0101235 <mem_init>:
{
f0101235:	55                   	push   %ebp
f0101236:	89 e5                	mov    %esp,%ebp
f0101238:	57                   	push   %edi
f0101239:	56                   	push   %esi
f010123a:	53                   	push   %ebx
f010123b:	83 ec 3c             	sub    $0x3c,%esp
f010123e:	e8 b6 f4 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0101243:	05 25 e6 07 00       	add    $0x7e625,%eax
f0101248:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f010124b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101250:	e8 93 f7 ff ff       	call   f01009e8 <nvram_read>
f0101255:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101257:	b8 17 00 00 00       	mov    $0x17,%eax
f010125c:	e8 87 f7 ff ff       	call   f01009e8 <nvram_read>
f0101261:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101263:	b8 34 00 00 00       	mov    $0x34,%eax
f0101268:	e8 7b f7 ff ff       	call   f01009e8 <nvram_read>
	if (ext16mem)
f010126d:	c1 e0 06             	shl    $0x6,%eax
f0101270:	0f 84 df 00 00 00    	je     f0101355 <mem_init+0x120>
		totalmem = 16 * 1024 + ext16mem;
f0101276:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010127b:	89 c2                	mov    %eax,%edx
f010127d:	c1 ea 02             	shr    $0x2,%edx
f0101280:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101283:	89 91 d8 1a 00 00    	mov    %edx,0x1ad8(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101289:	89 c2                	mov    %eax,%edx
f010128b:	29 da                	sub    %ebx,%edx
f010128d:	52                   	push   %edx
f010128e:	53                   	push   %ebx
f010128f:	50                   	push   %eax
f0101290:	8d 81 a8 60 f8 ff    	lea    -0x79f58(%ecx),%eax
f0101296:	50                   	push   %eax
f0101297:	89 cb                	mov    %ecx,%ebx
f0101299:	e8 a9 26 00 00       	call   f0103947 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010129e:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012a3:	e8 f7 f6 ff ff       	call   f010099f <boot_alloc>
f01012a8:	89 83 d4 1a 00 00    	mov    %eax,0x1ad4(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f01012ae:	83 c4 0c             	add    $0xc,%esp
f01012b1:	68 00 10 00 00       	push   $0x1000
f01012b6:	6a 00                	push   $0x0
f01012b8:	50                   	push   %eax
f01012b9:	e8 16 3c 00 00       	call   f0104ed4 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012be:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01012c4:	83 c4 10             	add    $0x10,%esp
f01012c7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012cc:	0f 86 93 00 00 00    	jbe    f0101365 <mem_init+0x130>
	return (physaddr_t)kva - KERNBASE;
f01012d2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012d8:	83 ca 05             	or     $0x5,%edx
f01012db:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	int spaceNeeded = (sizeof(struct PageInfo)*npages);
f01012e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01012e4:	8b 9f d8 1a 00 00    	mov    0x1ad8(%edi),%ebx
f01012ea:	c1 e3 03             	shl    $0x3,%ebx
	pages = (struct PageInfo*)boot_alloc(spaceNeeded);
f01012ed:	89 d8                	mov    %ebx,%eax
f01012ef:	e8 ab f6 ff ff       	call   f010099f <boot_alloc>
f01012f4:	89 87 d0 1a 00 00    	mov    %eax,0x1ad0(%edi)
	memset(pages,0,spaceNeeded);
f01012fa:	83 ec 04             	sub    $0x4,%esp
f01012fd:	53                   	push   %ebx
f01012fe:	6a 00                	push   $0x0
f0101300:	50                   	push   %eax
f0101301:	89 fb                	mov    %edi,%ebx
f0101303:	e8 cc 3b 00 00       	call   f0104ed4 <memset>
	envs = (struct Env*)boot_alloc(ROUNDUP(NENV * sizeof(struct Env), PGSIZE));
f0101308:	b8 00 80 01 00       	mov    $0x18000,%eax
f010130d:	e8 8d f6 ff ff       	call   f010099f <boot_alloc>
f0101312:	c7 c2 54 13 18 f0    	mov    $0xf0181354,%edx
f0101318:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, sizeof(struct Env) * NENV);
f010131a:	83 c4 0c             	add    $0xc,%esp
f010131d:	68 00 80 01 00       	push   $0x18000
f0101322:	6a 00                	push   $0x0
f0101324:	50                   	push   %eax
f0101325:	e8 aa 3b 00 00       	call   f0104ed4 <memset>
	page_init();
f010132a:	e8 d7 fa ff ff       	call   f0100e06 <page_init>
	check_page_free_list(1);
f010132f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101334:	e8 61 f7 ff ff       	call   f0100a9a <check_page_free_list>
	if (!pages)
f0101339:	83 c4 10             	add    $0x10,%esp
f010133c:	83 bf d0 1a 00 00 00 	cmpl   $0x0,0x1ad0(%edi)
f0101343:	74 3c                	je     f0101381 <mem_init+0x14c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101345:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101348:	8b 80 e4 1a 00 00    	mov    0x1ae4(%eax),%eax
f010134e:	be 00 00 00 00       	mov    $0x0,%esi
f0101353:	eb 4f                	jmp    f01013a4 <mem_init+0x16f>
		totalmem = 1 * 1024 + extmem;
f0101355:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010135b:	85 f6                	test   %esi,%esi
f010135d:	0f 44 c3             	cmove  %ebx,%eax
f0101360:	e9 16 ff ff ff       	jmp    f010127b <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101365:	50                   	push   %eax
f0101366:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101369:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f010136f:	50                   	push   %eax
f0101370:	68 91 00 00 00       	push   $0x91
f0101375:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010137b:	50                   	push   %eax
f010137c:	e8 30 ed ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101381:	83 ec 04             	sub    $0x4,%esp
f0101384:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101387:	8d 83 13 68 f8 ff    	lea    -0x797ed(%ebx),%eax
f010138d:	50                   	push   %eax
f010138e:	68 96 02 00 00       	push   $0x296
f0101393:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101399:	50                   	push   %eax
f010139a:	e8 12 ed ff ff       	call   f01000b1 <_panic>
		++nfree;
f010139f:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013a2:	8b 00                	mov    (%eax),%eax
f01013a4:	85 c0                	test   %eax,%eax
f01013a6:	75 f7                	jne    f010139f <mem_init+0x16a>
	assert((pp0 = page_alloc(0)));
f01013a8:	83 ec 0c             	sub    $0xc,%esp
f01013ab:	6a 00                	push   $0x0
f01013ad:	e8 08 fb ff ff       	call   f0100eba <page_alloc>
f01013b2:	89 c3                	mov    %eax,%ebx
f01013b4:	83 c4 10             	add    $0x10,%esp
f01013b7:	85 c0                	test   %eax,%eax
f01013b9:	0f 84 3a 02 00 00    	je     f01015f9 <mem_init+0x3c4>
	assert((pp1 = page_alloc(0)));
f01013bf:	83 ec 0c             	sub    $0xc,%esp
f01013c2:	6a 00                	push   $0x0
f01013c4:	e8 f1 fa ff ff       	call   f0100eba <page_alloc>
f01013c9:	89 c7                	mov    %eax,%edi
f01013cb:	83 c4 10             	add    $0x10,%esp
f01013ce:	85 c0                	test   %eax,%eax
f01013d0:	0f 84 45 02 00 00    	je     f010161b <mem_init+0x3e6>
	assert((pp2 = page_alloc(0)));
f01013d6:	83 ec 0c             	sub    $0xc,%esp
f01013d9:	6a 00                	push   $0x0
f01013db:	e8 da fa ff ff       	call   f0100eba <page_alloc>
f01013e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01013e3:	83 c4 10             	add    $0x10,%esp
f01013e6:	85 c0                	test   %eax,%eax
f01013e8:	0f 84 4f 02 00 00    	je     f010163d <mem_init+0x408>
	assert(pp1 && pp1 != pp0);
f01013ee:	39 fb                	cmp    %edi,%ebx
f01013f0:	0f 84 69 02 00 00    	je     f010165f <mem_init+0x42a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01013f9:	39 c3                	cmp    %eax,%ebx
f01013fb:	0f 84 80 02 00 00    	je     f0101681 <mem_init+0x44c>
f0101401:	39 c7                	cmp    %eax,%edi
f0101403:	0f 84 78 02 00 00    	je     f0101681 <mem_init+0x44c>
	return (pp - pages) << PGSHIFT;
f0101409:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010140c:	8b 88 d0 1a 00 00    	mov    0x1ad0(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101412:	8b 90 d8 1a 00 00    	mov    0x1ad8(%eax),%edx
f0101418:	c1 e2 0c             	shl    $0xc,%edx
f010141b:	89 d8                	mov    %ebx,%eax
f010141d:	29 c8                	sub    %ecx,%eax
f010141f:	c1 f8 03             	sar    $0x3,%eax
f0101422:	c1 e0 0c             	shl    $0xc,%eax
f0101425:	39 d0                	cmp    %edx,%eax
f0101427:	0f 83 76 02 00 00    	jae    f01016a3 <mem_init+0x46e>
f010142d:	89 f8                	mov    %edi,%eax
f010142f:	29 c8                	sub    %ecx,%eax
f0101431:	c1 f8 03             	sar    $0x3,%eax
f0101434:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101437:	39 c2                	cmp    %eax,%edx
f0101439:	0f 86 86 02 00 00    	jbe    f01016c5 <mem_init+0x490>
f010143f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101442:	29 c8                	sub    %ecx,%eax
f0101444:	c1 f8 03             	sar    $0x3,%eax
f0101447:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010144a:	39 c2                	cmp    %eax,%edx
f010144c:	0f 86 95 02 00 00    	jbe    f01016e7 <mem_init+0x4b2>
	fl = page_free_list;
f0101452:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101455:	8b 88 e4 1a 00 00    	mov    0x1ae4(%eax),%ecx
f010145b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f010145e:	c7 80 e4 1a 00 00 00 	movl   $0x0,0x1ae4(%eax)
f0101465:	00 00 00 
	assert(!page_alloc(0));
f0101468:	83 ec 0c             	sub    $0xc,%esp
f010146b:	6a 00                	push   $0x0
f010146d:	e8 48 fa ff ff       	call   f0100eba <page_alloc>
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	85 c0                	test   %eax,%eax
f0101477:	0f 85 8c 02 00 00    	jne    f0101709 <mem_init+0x4d4>
	page_free(pp0);
f010147d:	83 ec 0c             	sub    $0xc,%esp
f0101480:	53                   	push   %ebx
f0101481:	e8 b9 fa ff ff       	call   f0100f3f <page_free>
	page_free(pp1);
f0101486:	89 3c 24             	mov    %edi,(%esp)
f0101489:	e8 b1 fa ff ff       	call   f0100f3f <page_free>
	page_free(pp2);
f010148e:	83 c4 04             	add    $0x4,%esp
f0101491:	ff 75 d0             	push   -0x30(%ebp)
f0101494:	e8 a6 fa ff ff       	call   f0100f3f <page_free>
	assert((pp0 = page_alloc(0)));
f0101499:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014a0:	e8 15 fa ff ff       	call   f0100eba <page_alloc>
f01014a5:	89 c7                	mov    %eax,%edi
f01014a7:	83 c4 10             	add    $0x10,%esp
f01014aa:	85 c0                	test   %eax,%eax
f01014ac:	0f 84 79 02 00 00    	je     f010172b <mem_init+0x4f6>
	assert((pp1 = page_alloc(0)));
f01014b2:	83 ec 0c             	sub    $0xc,%esp
f01014b5:	6a 00                	push   $0x0
f01014b7:	e8 fe f9 ff ff       	call   f0100eba <page_alloc>
f01014bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014bf:	83 c4 10             	add    $0x10,%esp
f01014c2:	85 c0                	test   %eax,%eax
f01014c4:	0f 84 83 02 00 00    	je     f010174d <mem_init+0x518>
	assert((pp2 = page_alloc(0)));
f01014ca:	83 ec 0c             	sub    $0xc,%esp
f01014cd:	6a 00                	push   $0x0
f01014cf:	e8 e6 f9 ff ff       	call   f0100eba <page_alloc>
f01014d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01014d7:	83 c4 10             	add    $0x10,%esp
f01014da:	85 c0                	test   %eax,%eax
f01014dc:	0f 84 8d 02 00 00    	je     f010176f <mem_init+0x53a>
	assert(pp1 && pp1 != pp0);
f01014e2:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01014e5:	0f 84 a6 02 00 00    	je     f0101791 <mem_init+0x55c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01014ee:	39 c7                	cmp    %eax,%edi
f01014f0:	0f 84 bd 02 00 00    	je     f01017b3 <mem_init+0x57e>
f01014f6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01014f9:	0f 84 b4 02 00 00    	je     f01017b3 <mem_init+0x57e>
	assert(!page_alloc(0));
f01014ff:	83 ec 0c             	sub    $0xc,%esp
f0101502:	6a 00                	push   $0x0
f0101504:	e8 b1 f9 ff ff       	call   f0100eba <page_alloc>
f0101509:	83 c4 10             	add    $0x10,%esp
f010150c:	85 c0                	test   %eax,%eax
f010150e:	0f 85 c1 02 00 00    	jne    f01017d5 <mem_init+0x5a0>
f0101514:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101517:	89 f8                	mov    %edi,%eax
f0101519:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f010151f:	c1 f8 03             	sar    $0x3,%eax
f0101522:	89 c2                	mov    %eax,%edx
f0101524:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101527:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010152c:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101532:	0f 83 bf 02 00 00    	jae    f01017f7 <mem_init+0x5c2>
	memset(page2kva(pp0), 1, PGSIZE);
f0101538:	83 ec 04             	sub    $0x4,%esp
f010153b:	68 00 10 00 00       	push   $0x1000
f0101540:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101542:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101548:	52                   	push   %edx
f0101549:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010154c:	e8 83 39 00 00       	call   f0104ed4 <memset>
	page_free(pp0);
f0101551:	89 3c 24             	mov    %edi,(%esp)
f0101554:	e8 e6 f9 ff ff       	call   f0100f3f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101559:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101560:	e8 55 f9 ff ff       	call   f0100eba <page_alloc>
f0101565:	83 c4 10             	add    $0x10,%esp
f0101568:	85 c0                	test   %eax,%eax
f010156a:	0f 84 9f 02 00 00    	je     f010180f <mem_init+0x5da>
	assert(pp && pp0 == pp);
f0101570:	39 c7                	cmp    %eax,%edi
f0101572:	0f 85 b9 02 00 00    	jne    f0101831 <mem_init+0x5fc>
	return (pp - pages) << PGSHIFT;
f0101578:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010157b:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101581:	c1 f8 03             	sar    $0x3,%eax
f0101584:	89 c2                	mov    %eax,%edx
f0101586:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101589:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010158e:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101594:	0f 83 b9 02 00 00    	jae    f0101853 <mem_init+0x61e>
	return (void *)(pa + KERNBASE);
f010159a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015a0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015a6:	80 38 00             	cmpb   $0x0,(%eax)
f01015a9:	0f 85 bc 02 00 00    	jne    f010186b <mem_init+0x636>
	for (i = 0; i < PGSIZE; i++)
f01015af:	83 c0 01             	add    $0x1,%eax
f01015b2:	39 d0                	cmp    %edx,%eax
f01015b4:	75 f0                	jne    f01015a6 <mem_init+0x371>
	page_free_list = fl;
f01015b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01015b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01015bc:	89 8b e4 1a 00 00    	mov    %ecx,0x1ae4(%ebx)
	page_free(pp0);
f01015c2:	83 ec 0c             	sub    $0xc,%esp
f01015c5:	57                   	push   %edi
f01015c6:	e8 74 f9 ff ff       	call   f0100f3f <page_free>
	page_free(pp1);
f01015cb:	83 c4 04             	add    $0x4,%esp
f01015ce:	ff 75 d0             	push   -0x30(%ebp)
f01015d1:	e8 69 f9 ff ff       	call   f0100f3f <page_free>
	page_free(pp2);
f01015d6:	83 c4 04             	add    $0x4,%esp
f01015d9:	ff 75 cc             	push   -0x34(%ebp)
f01015dc:	e8 5e f9 ff ff       	call   f0100f3f <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015e1:	8b 83 e4 1a 00 00    	mov    0x1ae4(%ebx),%eax
f01015e7:	83 c4 10             	add    $0x10,%esp
f01015ea:	85 c0                	test   %eax,%eax
f01015ec:	0f 84 9b 02 00 00    	je     f010188d <mem_init+0x658>
		--nfree;
f01015f2:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015f5:	8b 00                	mov    (%eax),%eax
f01015f7:	eb f1                	jmp    f01015ea <mem_init+0x3b5>
	assert((pp0 = page_alloc(0)));
f01015f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01015fc:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101602:	50                   	push   %eax
f0101603:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0101609:	50                   	push   %eax
f010160a:	68 9e 02 00 00       	push   $0x29e
f010160f:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101615:	50                   	push   %eax
f0101616:	e8 96 ea ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010161b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010161e:	8d 83 44 68 f8 ff    	lea    -0x797bc(%ebx),%eax
f0101624:	50                   	push   %eax
f0101625:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010162b:	50                   	push   %eax
f010162c:	68 9f 02 00 00       	push   $0x29f
f0101631:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101637:	50                   	push   %eax
f0101638:	e8 74 ea ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010163d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101640:	8d 83 5a 68 f8 ff    	lea    -0x797a6(%ebx),%eax
f0101646:	50                   	push   %eax
f0101647:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010164d:	50                   	push   %eax
f010164e:	68 a0 02 00 00       	push   $0x2a0
f0101653:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101659:	50                   	push   %eax
f010165a:	e8 52 ea ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010165f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101662:	8d 83 70 68 f8 ff    	lea    -0x79790(%ebx),%eax
f0101668:	50                   	push   %eax
f0101669:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010166f:	50                   	push   %eax
f0101670:	68 a3 02 00 00       	push   $0x2a3
f0101675:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010167b:	50                   	push   %eax
f010167c:	e8 30 ea ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101681:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101684:	8d 83 08 61 f8 ff    	lea    -0x79ef8(%ebx),%eax
f010168a:	50                   	push   %eax
f010168b:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0101691:	50                   	push   %eax
f0101692:	68 a4 02 00 00       	push   $0x2a4
f0101697:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010169d:	50                   	push   %eax
f010169e:	e8 0e ea ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016a6:	8d 83 82 68 f8 ff    	lea    -0x7977e(%ebx),%eax
f01016ac:	50                   	push   %eax
f01016ad:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01016b3:	50                   	push   %eax
f01016b4:	68 a5 02 00 00       	push   $0x2a5
f01016b9:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01016bf:	50                   	push   %eax
f01016c0:	e8 ec e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016c8:	8d 83 9f 68 f8 ff    	lea    -0x79761(%ebx),%eax
f01016ce:	50                   	push   %eax
f01016cf:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01016d5:	50                   	push   %eax
f01016d6:	68 a6 02 00 00       	push   $0x2a6
f01016db:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01016e1:	50                   	push   %eax
f01016e2:	e8 ca e9 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ea:	8d 83 bc 68 f8 ff    	lea    -0x79744(%ebx),%eax
f01016f0:	50                   	push   %eax
f01016f1:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01016f7:	50                   	push   %eax
f01016f8:	68 a7 02 00 00       	push   $0x2a7
f01016fd:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101703:	50                   	push   %eax
f0101704:	e8 a8 e9 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101709:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010170c:	8d 83 d9 68 f8 ff    	lea    -0x79727(%ebx),%eax
f0101712:	50                   	push   %eax
f0101713:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0101719:	50                   	push   %eax
f010171a:	68 ae 02 00 00       	push   $0x2ae
f010171f:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101725:	50                   	push   %eax
f0101726:	e8 86 e9 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f010172b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010172e:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0101734:	50                   	push   %eax
f0101735:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010173b:	50                   	push   %eax
f010173c:	68 b5 02 00 00       	push   $0x2b5
f0101741:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101747:	50                   	push   %eax
f0101748:	e8 64 e9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010174d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101750:	8d 83 44 68 f8 ff    	lea    -0x797bc(%ebx),%eax
f0101756:	50                   	push   %eax
f0101757:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010175d:	50                   	push   %eax
f010175e:	68 b6 02 00 00       	push   $0x2b6
f0101763:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101769:	50                   	push   %eax
f010176a:	e8 42 e9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010176f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101772:	8d 83 5a 68 f8 ff    	lea    -0x797a6(%ebx),%eax
f0101778:	50                   	push   %eax
f0101779:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010177f:	50                   	push   %eax
f0101780:	68 b7 02 00 00       	push   $0x2b7
f0101785:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010178b:	50                   	push   %eax
f010178c:	e8 20 e9 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101791:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101794:	8d 83 70 68 f8 ff    	lea    -0x79790(%ebx),%eax
f010179a:	50                   	push   %eax
f010179b:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01017a1:	50                   	push   %eax
f01017a2:	68 b9 02 00 00       	push   $0x2b9
f01017a7:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01017ad:	50                   	push   %eax
f01017ae:	e8 fe e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017b6:	8d 83 08 61 f8 ff    	lea    -0x79ef8(%ebx),%eax
f01017bc:	50                   	push   %eax
f01017bd:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01017c3:	50                   	push   %eax
f01017c4:	68 ba 02 00 00       	push   $0x2ba
f01017c9:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01017cf:	50                   	push   %eax
f01017d0:	e8 dc e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01017d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017d8:	8d 83 d9 68 f8 ff    	lea    -0x79727(%ebx),%eax
f01017de:	50                   	push   %eax
f01017df:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01017e5:	50                   	push   %eax
f01017e6:	68 bb 02 00 00       	push   $0x2bb
f01017eb:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01017f1:	50                   	push   %eax
f01017f2:	e8 ba e8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017f7:	52                   	push   %edx
f01017f8:	89 cb                	mov    %ecx,%ebx
f01017fa:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f0101800:	50                   	push   %eax
f0101801:	6a 56                	push   $0x56
f0101803:	8d 81 69 67 f8 ff    	lea    -0x79897(%ecx),%eax
f0101809:	50                   	push   %eax
f010180a:	e8 a2 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010180f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101812:	8d 83 e8 68 f8 ff    	lea    -0x79718(%ebx),%eax
f0101818:	50                   	push   %eax
f0101819:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010181f:	50                   	push   %eax
f0101820:	68 c0 02 00 00       	push   $0x2c0
f0101825:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010182b:	50                   	push   %eax
f010182c:	e8 80 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101831:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101834:	8d 83 06 69 f8 ff    	lea    -0x796fa(%ebx),%eax
f010183a:	50                   	push   %eax
f010183b:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0101841:	50                   	push   %eax
f0101842:	68 c1 02 00 00       	push   $0x2c1
f0101847:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010184d:	50                   	push   %eax
f010184e:	e8 5e e8 ff ff       	call   f01000b1 <_panic>
f0101853:	52                   	push   %edx
f0101854:	89 cb                	mov    %ecx,%ebx
f0101856:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f010185c:	50                   	push   %eax
f010185d:	6a 56                	push   $0x56
f010185f:	8d 81 69 67 f8 ff    	lea    -0x79897(%ecx),%eax
f0101865:	50                   	push   %eax
f0101866:	e8 46 e8 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f010186b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010186e:	8d 83 16 69 f8 ff    	lea    -0x796ea(%ebx),%eax
f0101874:	50                   	push   %eax
f0101875:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010187b:	50                   	push   %eax
f010187c:	68 c4 02 00 00       	push   $0x2c4
f0101881:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0101887:	50                   	push   %eax
f0101888:	e8 24 e8 ff ff       	call   f01000b1 <_panic>
	assert(nfree == 0);
f010188d:	85 f6                	test   %esi,%esi
f010188f:	0f 85 3f 08 00 00    	jne    f01020d4 <mem_init+0xe9f>
	cprintf("check_page_alloc() succeeded!\n");
f0101895:	83 ec 0c             	sub    $0xc,%esp
f0101898:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010189b:	8d 83 28 61 f8 ff    	lea    -0x79ed8(%ebx),%eax
f01018a1:	50                   	push   %eax
f01018a2:	e8 a0 20 00 00       	call   f0103947 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ae:	e8 07 f6 ff ff       	call   f0100eba <page_alloc>
f01018b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018b6:	83 c4 10             	add    $0x10,%esp
f01018b9:	85 c0                	test   %eax,%eax
f01018bb:	0f 84 35 08 00 00    	je     f01020f6 <mem_init+0xec1>
	assert((pp1 = page_alloc(0)));
f01018c1:	83 ec 0c             	sub    $0xc,%esp
f01018c4:	6a 00                	push   $0x0
f01018c6:	e8 ef f5 ff ff       	call   f0100eba <page_alloc>
f01018cb:	89 c7                	mov    %eax,%edi
f01018cd:	83 c4 10             	add    $0x10,%esp
f01018d0:	85 c0                	test   %eax,%eax
f01018d2:	0f 84 40 08 00 00    	je     f0102118 <mem_init+0xee3>
	assert((pp2 = page_alloc(0)));
f01018d8:	83 ec 0c             	sub    $0xc,%esp
f01018db:	6a 00                	push   $0x0
f01018dd:	e8 d8 f5 ff ff       	call   f0100eba <page_alloc>
f01018e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01018e5:	83 c4 10             	add    $0x10,%esp
f01018e8:	85 c0                	test   %eax,%eax
f01018ea:	0f 84 4a 08 00 00    	je     f010213a <mem_init+0xf05>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018f0:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01018f3:	0f 84 63 08 00 00    	je     f010215c <mem_init+0xf27>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018fc:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01018ff:	0f 84 79 08 00 00    	je     f010217e <mem_init+0xf49>
f0101905:	39 c7                	cmp    %eax,%edi
f0101907:	0f 84 71 08 00 00    	je     f010217e <mem_init+0xf49>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010190d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101910:	8b 88 e4 1a 00 00    	mov    0x1ae4(%eax),%ecx
f0101916:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101919:	c7 80 e4 1a 00 00 00 	movl   $0x0,0x1ae4(%eax)
f0101920:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101923:	83 ec 0c             	sub    $0xc,%esp
f0101926:	6a 00                	push   $0x0
f0101928:	e8 8d f5 ff ff       	call   f0100eba <page_alloc>
f010192d:	83 c4 10             	add    $0x10,%esp
f0101930:	85 c0                	test   %eax,%eax
f0101932:	0f 85 68 08 00 00    	jne    f01021a0 <mem_init+0xf6b>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101938:	83 ec 04             	sub    $0x4,%esp
f010193b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010193e:	50                   	push   %eax
f010193f:	6a 00                	push   $0x0
f0101941:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101944:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f010194a:	e8 ac f7 ff ff       	call   f01010fb <page_lookup>
f010194f:	83 c4 10             	add    $0x10,%esp
f0101952:	85 c0                	test   %eax,%eax
f0101954:	0f 85 68 08 00 00    	jne    f01021c2 <mem_init+0xf8d>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010195a:	6a 02                	push   $0x2
f010195c:	6a 00                	push   $0x0
f010195e:	57                   	push   %edi
f010195f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101962:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101968:	e8 31 f8 ff ff       	call   f010119e <page_insert>
f010196d:	83 c4 10             	add    $0x10,%esp
f0101970:	85 c0                	test   %eax,%eax
f0101972:	0f 89 6c 08 00 00    	jns    f01021e4 <mem_init+0xfaf>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101978:	83 ec 0c             	sub    $0xc,%esp
f010197b:	ff 75 cc             	push   -0x34(%ebp)
f010197e:	e8 bc f5 ff ff       	call   f0100f3f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101983:	6a 02                	push   $0x2
f0101985:	6a 00                	push   $0x0
f0101987:	57                   	push   %edi
f0101988:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010198b:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101991:	e8 08 f8 ff ff       	call   f010119e <page_insert>
f0101996:	83 c4 20             	add    $0x20,%esp
f0101999:	85 c0                	test   %eax,%eax
f010199b:	0f 85 65 08 00 00    	jne    f0102206 <mem_init+0xfd1>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a4:	8b 98 d4 1a 00 00    	mov    0x1ad4(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f01019aa:	8b b0 d0 1a 00 00    	mov    0x1ad0(%eax),%esi
f01019b0:	8b 13                	mov    (%ebx),%edx
f01019b2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01019bb:	29 f0                	sub    %esi,%eax
f01019bd:	c1 f8 03             	sar    $0x3,%eax
f01019c0:	c1 e0 0c             	shl    $0xc,%eax
f01019c3:	39 c2                	cmp    %eax,%edx
f01019c5:	0f 85 5d 08 00 00    	jne    f0102228 <mem_init+0xff3>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01019d0:	89 d8                	mov    %ebx,%eax
f01019d2:	e8 47 f0 ff ff       	call   f0100a1e <check_va2pa>
f01019d7:	89 c2                	mov    %eax,%edx
f01019d9:	89 f8                	mov    %edi,%eax
f01019db:	29 f0                	sub    %esi,%eax
f01019dd:	c1 f8 03             	sar    $0x3,%eax
f01019e0:	c1 e0 0c             	shl    $0xc,%eax
f01019e3:	39 c2                	cmp    %eax,%edx
f01019e5:	0f 85 5f 08 00 00    	jne    f010224a <mem_init+0x1015>
	assert(pp1->pp_ref == 1);
f01019eb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019f0:	0f 85 76 08 00 00    	jne    f010226c <mem_init+0x1037>
	assert(pp0->pp_ref == 1);
f01019f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01019f9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019fe:	0f 85 8a 08 00 00    	jne    f010228e <mem_init+0x1059>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a04:	6a 02                	push   $0x2
f0101a06:	68 00 10 00 00       	push   $0x1000
f0101a0b:	ff 75 d0             	push   -0x30(%ebp)
f0101a0e:	53                   	push   %ebx
f0101a0f:	e8 8a f7 ff ff       	call   f010119e <page_insert>
f0101a14:	83 c4 10             	add    $0x10,%esp
f0101a17:	85 c0                	test   %eax,%eax
f0101a19:	0f 85 91 08 00 00    	jne    f01022b0 <mem_init+0x107b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a1f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a24:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a27:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101a2d:	e8 ec ef ff ff       	call   f0100a1e <check_va2pa>
f0101a32:	89 c2                	mov    %eax,%edx
f0101a34:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a37:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101a3d:	c1 f8 03             	sar    $0x3,%eax
f0101a40:	c1 e0 0c             	shl    $0xc,%eax
f0101a43:	39 c2                	cmp    %eax,%edx
f0101a45:	0f 85 87 08 00 00    	jne    f01022d2 <mem_init+0x109d>
	assert(pp2->pp_ref == 1);
f0101a4b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a4e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a53:	0f 85 9b 08 00 00    	jne    f01022f4 <mem_init+0x10bf>

	// should be no free memory
	assert(!page_alloc(0));
f0101a59:	83 ec 0c             	sub    $0xc,%esp
f0101a5c:	6a 00                	push   $0x0
f0101a5e:	e8 57 f4 ff ff       	call   f0100eba <page_alloc>
f0101a63:	83 c4 10             	add    $0x10,%esp
f0101a66:	85 c0                	test   %eax,%eax
f0101a68:	0f 85 a8 08 00 00    	jne    f0102316 <mem_init+0x10e1>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a6e:	6a 02                	push   $0x2
f0101a70:	68 00 10 00 00       	push   $0x1000
f0101a75:	ff 75 d0             	push   -0x30(%ebp)
f0101a78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a7b:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101a81:	e8 18 f7 ff ff       	call   f010119e <page_insert>
f0101a86:	83 c4 10             	add    $0x10,%esp
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	0f 85 a7 08 00 00    	jne    f0102338 <mem_init+0x1103>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a91:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a96:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a99:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101a9f:	e8 7a ef ff ff       	call   f0100a1e <check_va2pa>
f0101aa4:	89 c2                	mov    %eax,%edx
f0101aa6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101aa9:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101aaf:	c1 f8 03             	sar    $0x3,%eax
f0101ab2:	c1 e0 0c             	shl    $0xc,%eax
f0101ab5:	39 c2                	cmp    %eax,%edx
f0101ab7:	0f 85 9d 08 00 00    	jne    f010235a <mem_init+0x1125>
	assert(pp2->pp_ref == 1);
f0101abd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ac0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ac5:	0f 85 b1 08 00 00    	jne    f010237c <mem_init+0x1147>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101acb:	83 ec 0c             	sub    $0xc,%esp
f0101ace:	6a 00                	push   $0x0
f0101ad0:	e8 e5 f3 ff ff       	call   f0100eba <page_alloc>
f0101ad5:	83 c4 10             	add    $0x10,%esp
f0101ad8:	85 c0                	test   %eax,%eax
f0101ada:	0f 85 be 08 00 00    	jne    f010239e <mem_init+0x1169>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ae0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ae3:	8b 91 d4 1a 00 00    	mov    0x1ad4(%ecx),%edx
f0101ae9:	8b 02                	mov    (%edx),%eax
f0101aeb:	89 c3                	mov    %eax,%ebx
f0101aed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101af3:	c1 e8 0c             	shr    $0xc,%eax
f0101af6:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0101afc:	0f 83 be 08 00 00    	jae    f01023c0 <mem_init+0x118b>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b02:	83 ec 04             	sub    $0x4,%esp
f0101b05:	6a 00                	push   $0x0
f0101b07:	68 00 10 00 00       	push   $0x1000
f0101b0c:	52                   	push   %edx
f0101b0d:	e8 c0 f4 ff ff       	call   f0100fd2 <pgdir_walk>
f0101b12:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101b18:	83 c4 10             	add    $0x10,%esp
f0101b1b:	39 d8                	cmp    %ebx,%eax
f0101b1d:	0f 85 b8 08 00 00    	jne    f01023db <mem_init+0x11a6>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b23:	6a 06                	push   $0x6
f0101b25:	68 00 10 00 00       	push   $0x1000
f0101b2a:	ff 75 d0             	push   -0x30(%ebp)
f0101b2d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b30:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101b36:	e8 63 f6 ff ff       	call   f010119e <page_insert>
f0101b3b:	83 c4 10             	add    $0x10,%esp
f0101b3e:	85 c0                	test   %eax,%eax
f0101b40:	0f 85 b7 08 00 00    	jne    f01023fd <mem_init+0x11c8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b46:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101b49:	8b 9e d4 1a 00 00    	mov    0x1ad4(%esi),%ebx
f0101b4f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b54:	89 d8                	mov    %ebx,%eax
f0101b56:	e8 c3 ee ff ff       	call   f0100a1e <check_va2pa>
f0101b5b:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101b5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b60:	2b 86 d0 1a 00 00    	sub    0x1ad0(%esi),%eax
f0101b66:	c1 f8 03             	sar    $0x3,%eax
f0101b69:	c1 e0 0c             	shl    $0xc,%eax
f0101b6c:	39 c2                	cmp    %eax,%edx
f0101b6e:	0f 85 ab 08 00 00    	jne    f010241f <mem_init+0x11ea>
	assert(pp2->pp_ref == 1);
f0101b74:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b77:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b7c:	0f 85 bf 08 00 00    	jne    f0102441 <mem_init+0x120c>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b82:	83 ec 04             	sub    $0x4,%esp
f0101b85:	6a 00                	push   $0x0
f0101b87:	68 00 10 00 00       	push   $0x1000
f0101b8c:	53                   	push   %ebx
f0101b8d:	e8 40 f4 ff ff       	call   f0100fd2 <pgdir_walk>
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	f6 00 04             	testb  $0x4,(%eax)
f0101b98:	0f 84 c5 08 00 00    	je     f0102463 <mem_init+0x122e>
	assert(kern_pgdir[0] & PTE_U);
f0101b9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba1:	8b 80 d4 1a 00 00    	mov    0x1ad4(%eax),%eax
f0101ba7:	f6 00 04             	testb  $0x4,(%eax)
f0101baa:	0f 84 d5 08 00 00    	je     f0102485 <mem_init+0x1250>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bb0:	6a 02                	push   $0x2
f0101bb2:	68 00 10 00 00       	push   $0x1000
f0101bb7:	ff 75 d0             	push   -0x30(%ebp)
f0101bba:	50                   	push   %eax
f0101bbb:	e8 de f5 ff ff       	call   f010119e <page_insert>
f0101bc0:	83 c4 10             	add    $0x10,%esp
f0101bc3:	85 c0                	test   %eax,%eax
f0101bc5:	0f 85 dc 08 00 00    	jne    f01024a7 <mem_init+0x1272>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bcb:	83 ec 04             	sub    $0x4,%esp
f0101bce:	6a 00                	push   $0x0
f0101bd0:	68 00 10 00 00       	push   $0x1000
f0101bd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bd8:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101bde:	e8 ef f3 ff ff       	call   f0100fd2 <pgdir_walk>
f0101be3:	83 c4 10             	add    $0x10,%esp
f0101be6:	f6 00 02             	testb  $0x2,(%eax)
f0101be9:	0f 84 da 08 00 00    	je     f01024c9 <mem_init+0x1294>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bef:	83 ec 04             	sub    $0x4,%esp
f0101bf2:	6a 00                	push   $0x0
f0101bf4:	68 00 10 00 00       	push   $0x1000
f0101bf9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bfc:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c02:	e8 cb f3 ff ff       	call   f0100fd2 <pgdir_walk>
f0101c07:	83 c4 10             	add    $0x10,%esp
f0101c0a:	f6 00 04             	testb  $0x4,(%eax)
f0101c0d:	0f 85 d8 08 00 00    	jne    f01024eb <mem_init+0x12b6>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c13:	6a 02                	push   $0x2
f0101c15:	68 00 00 40 00       	push   $0x400000
f0101c1a:	ff 75 cc             	push   -0x34(%ebp)
f0101c1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c20:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c26:	e8 73 f5 ff ff       	call   f010119e <page_insert>
f0101c2b:	83 c4 10             	add    $0x10,%esp
f0101c2e:	85 c0                	test   %eax,%eax
f0101c30:	0f 89 d7 08 00 00    	jns    f010250d <mem_init+0x12d8>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c36:	6a 02                	push   $0x2
f0101c38:	68 00 10 00 00       	push   $0x1000
f0101c3d:	57                   	push   %edi
f0101c3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c41:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c47:	e8 52 f5 ff ff       	call   f010119e <page_insert>
f0101c4c:	83 c4 10             	add    $0x10,%esp
f0101c4f:	85 c0                	test   %eax,%eax
f0101c51:	0f 85 d8 08 00 00    	jne    f010252f <mem_init+0x12fa>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c57:	83 ec 04             	sub    $0x4,%esp
f0101c5a:	6a 00                	push   $0x0
f0101c5c:	68 00 10 00 00       	push   $0x1000
f0101c61:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c64:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0101c6a:	e8 63 f3 ff ff       	call   f0100fd2 <pgdir_walk>
f0101c6f:	83 c4 10             	add    $0x10,%esp
f0101c72:	f6 00 04             	testb  $0x4,(%eax)
f0101c75:	0f 85 d6 08 00 00    	jne    f0102551 <mem_init+0x131c>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c7e:	8b b3 d4 1a 00 00    	mov    0x1ad4(%ebx),%esi
f0101c84:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c89:	89 f0                	mov    %esi,%eax
f0101c8b:	e8 8e ed ff ff       	call   f0100a1e <check_va2pa>
f0101c90:	89 d9                	mov    %ebx,%ecx
f0101c92:	89 fb                	mov    %edi,%ebx
f0101c94:	2b 99 d0 1a 00 00    	sub    0x1ad0(%ecx),%ebx
f0101c9a:	c1 fb 03             	sar    $0x3,%ebx
f0101c9d:	c1 e3 0c             	shl    $0xc,%ebx
f0101ca0:	39 d8                	cmp    %ebx,%eax
f0101ca2:	0f 85 cb 08 00 00    	jne    f0102573 <mem_init+0x133e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ca8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cad:	89 f0                	mov    %esi,%eax
f0101caf:	e8 6a ed ff ff       	call   f0100a1e <check_va2pa>
f0101cb4:	39 c3                	cmp    %eax,%ebx
f0101cb6:	0f 85 d9 08 00 00    	jne    f0102595 <mem_init+0x1360>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cbc:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101cc1:	0f 85 f0 08 00 00    	jne    f01025b7 <mem_init+0x1382>
	assert(pp2->pp_ref == 0);
f0101cc7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cca:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ccf:	0f 85 04 09 00 00    	jne    f01025d9 <mem_init+0x13a4>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101cd5:	83 ec 0c             	sub    $0xc,%esp
f0101cd8:	6a 00                	push   $0x0
f0101cda:	e8 db f1 ff ff       	call   f0100eba <page_alloc>
f0101cdf:	83 c4 10             	add    $0x10,%esp
f0101ce2:	85 c0                	test   %eax,%eax
f0101ce4:	0f 84 11 09 00 00    	je     f01025fb <mem_init+0x13c6>
f0101cea:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ced:	0f 85 08 09 00 00    	jne    f01025fb <mem_init+0x13c6>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101cf3:	83 ec 08             	sub    $0x8,%esp
f0101cf6:	6a 00                	push   $0x0
f0101cf8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cfb:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101d01:	e8 53 f4 ff ff       	call   f0101159 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d06:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101d0c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d11:	89 d8                	mov    %ebx,%eax
f0101d13:	e8 06 ed ff ff       	call   f0100a1e <check_va2pa>
f0101d18:	83 c4 10             	add    $0x10,%esp
f0101d1b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d1e:	0f 85 f9 08 00 00    	jne    f010261d <mem_init+0x13e8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d24:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d29:	89 d8                	mov    %ebx,%eax
f0101d2b:	e8 ee ec ff ff       	call   f0100a1e <check_va2pa>
f0101d30:	89 c2                	mov    %eax,%edx
f0101d32:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d35:	89 f8                	mov    %edi,%eax
f0101d37:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0101d3d:	c1 f8 03             	sar    $0x3,%eax
f0101d40:	c1 e0 0c             	shl    $0xc,%eax
f0101d43:	39 c2                	cmp    %eax,%edx
f0101d45:	0f 85 f4 08 00 00    	jne    f010263f <mem_init+0x140a>
	assert(pp1->pp_ref == 1);
f0101d4b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d50:	0f 85 0a 09 00 00    	jne    f0102660 <mem_init+0x142b>
	assert(pp2->pp_ref == 0);
f0101d56:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d59:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d5e:	0f 85 1e 09 00 00    	jne    f0102682 <mem_init+0x144d>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d64:	6a 00                	push   $0x0
f0101d66:	68 00 10 00 00       	push   $0x1000
f0101d6b:	57                   	push   %edi
f0101d6c:	53                   	push   %ebx
f0101d6d:	e8 2c f4 ff ff       	call   f010119e <page_insert>
f0101d72:	83 c4 10             	add    $0x10,%esp
f0101d75:	85 c0                	test   %eax,%eax
f0101d77:	0f 85 27 09 00 00    	jne    f01026a4 <mem_init+0x146f>
	assert(pp1->pp_ref);
f0101d7d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d82:	0f 84 3e 09 00 00    	je     f01026c6 <mem_init+0x1491>
	assert(pp1->pp_link == NULL);
f0101d88:	83 3f 00             	cmpl   $0x0,(%edi)
f0101d8b:	0f 85 57 09 00 00    	jne    f01026e8 <mem_init+0x14b3>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d91:	83 ec 08             	sub    $0x8,%esp
f0101d94:	68 00 10 00 00       	push   $0x1000
f0101d99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d9c:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101da2:	e8 b2 f3 ff ff       	call   f0101159 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101da7:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101dad:	ba 00 00 00 00       	mov    $0x0,%edx
f0101db2:	89 d8                	mov    %ebx,%eax
f0101db4:	e8 65 ec ff ff       	call   f0100a1e <check_va2pa>
f0101db9:	83 c4 10             	add    $0x10,%esp
f0101dbc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dbf:	0f 85 45 09 00 00    	jne    f010270a <mem_init+0x14d5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101dc5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dca:	89 d8                	mov    %ebx,%eax
f0101dcc:	e8 4d ec ff ff       	call   f0100a1e <check_va2pa>
f0101dd1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dd4:	0f 85 52 09 00 00    	jne    f010272c <mem_init+0x14f7>
	assert(pp1->pp_ref == 0);
f0101dda:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ddf:	0f 85 69 09 00 00    	jne    f010274e <mem_init+0x1519>
	assert(pp2->pp_ref == 0);
f0101de5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101de8:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ded:	0f 85 7d 09 00 00    	jne    f0102770 <mem_init+0x153b>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101df3:	83 ec 0c             	sub    $0xc,%esp
f0101df6:	6a 00                	push   $0x0
f0101df8:	e8 bd f0 ff ff       	call   f0100eba <page_alloc>
f0101dfd:	83 c4 10             	add    $0x10,%esp
f0101e00:	39 c7                	cmp    %eax,%edi
f0101e02:	0f 85 8a 09 00 00    	jne    f0102792 <mem_init+0x155d>
f0101e08:	85 c0                	test   %eax,%eax
f0101e0a:	0f 84 82 09 00 00    	je     f0102792 <mem_init+0x155d>

	// should be no free memory
	assert(!page_alloc(0));
f0101e10:	83 ec 0c             	sub    $0xc,%esp
f0101e13:	6a 00                	push   $0x0
f0101e15:	e8 a0 f0 ff ff       	call   f0100eba <page_alloc>
f0101e1a:	83 c4 10             	add    $0x10,%esp
f0101e1d:	85 c0                	test   %eax,%eax
f0101e1f:	0f 85 8f 09 00 00    	jne    f01027b4 <mem_init+0x157f>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e28:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0101e2e:	8b 11                	mov    (%ecx),%edx
f0101e30:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e36:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101e39:	2b 98 d0 1a 00 00    	sub    0x1ad0(%eax),%ebx
f0101e3f:	89 d8                	mov    %ebx,%eax
f0101e41:	c1 f8 03             	sar    $0x3,%eax
f0101e44:	c1 e0 0c             	shl    $0xc,%eax
f0101e47:	39 c2                	cmp    %eax,%edx
f0101e49:	0f 85 87 09 00 00    	jne    f01027d6 <mem_init+0x15a1>
	kern_pgdir[0] = 0;
f0101e4f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e55:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e58:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e5d:	0f 85 95 09 00 00    	jne    f01027f8 <mem_init+0x15c3>
	pp0->pp_ref = 0;
f0101e63:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e66:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e6c:	83 ec 0c             	sub    $0xc,%esp
f0101e6f:	50                   	push   %eax
f0101e70:	e8 ca f0 ff ff       	call   f0100f3f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e75:	83 c4 0c             	add    $0xc,%esp
f0101e78:	6a 01                	push   $0x1
f0101e7a:	68 00 10 40 00       	push   $0x401000
f0101e7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e82:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101e88:	e8 45 f1 ff ff       	call   f0100fd2 <pgdir_walk>
f0101e8d:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e8f:	89 d9                	mov    %ebx,%ecx
f0101e91:	8b 9b d4 1a 00 00    	mov    0x1ad4(%ebx),%ebx
f0101e97:	8b 43 04             	mov    0x4(%ebx),%eax
f0101e9a:	89 c2                	mov    %eax,%edx
f0101e9c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101ea2:	8b 89 d8 1a 00 00    	mov    0x1ad8(%ecx),%ecx
f0101ea8:	c1 e8 0c             	shr    $0xc,%eax
f0101eab:	83 c4 10             	add    $0x10,%esp
f0101eae:	39 c8                	cmp    %ecx,%eax
f0101eb0:	0f 83 64 09 00 00    	jae    f010281a <mem_init+0x15e5>
	assert(ptep == ptep1 + PTX(va));
f0101eb6:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101ebc:	39 d6                	cmp    %edx,%esi
f0101ebe:	0f 85 72 09 00 00    	jne    f0102836 <mem_init+0x1601>
	kern_pgdir[PDX(va)] = 0;
f0101ec4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101ecb:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ece:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101ed4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ed7:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101edd:	c1 f8 03             	sar    $0x3,%eax
f0101ee0:	89 c2                	mov    %eax,%edx
f0101ee2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ee5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101eea:	39 c1                	cmp    %eax,%ecx
f0101eec:	0f 86 66 09 00 00    	jbe    f0102858 <mem_init+0x1623>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101ef2:	83 ec 04             	sub    $0x4,%esp
f0101ef5:	68 00 10 00 00       	push   $0x1000
f0101efa:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101eff:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101f05:	52                   	push   %edx
f0101f06:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f09:	e8 c6 2f 00 00       	call   f0104ed4 <memset>
	page_free(pp0);
f0101f0e:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101f11:	89 34 24             	mov    %esi,(%esp)
f0101f14:	e8 26 f0 ff ff       	call   f0100f3f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f19:	83 c4 0c             	add    $0xc,%esp
f0101f1c:	6a 01                	push   $0x1
f0101f1e:	6a 00                	push   $0x0
f0101f20:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0101f26:	e8 a7 f0 ff ff       	call   f0100fd2 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f2b:	89 f0                	mov    %esi,%eax
f0101f2d:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0101f33:	c1 f8 03             	sar    $0x3,%eax
f0101f36:	89 c2                	mov    %eax,%edx
f0101f38:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f3b:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f40:	83 c4 10             	add    $0x10,%esp
f0101f43:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0101f49:	0f 83 1f 09 00 00    	jae    f010286e <mem_init+0x1639>
	return (void *)(pa + KERNBASE);
f0101f4f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101f55:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f5b:	8b 30                	mov    (%eax),%esi
f0101f5d:	83 e6 01             	and    $0x1,%esi
f0101f60:	0f 85 21 09 00 00    	jne    f0102887 <mem_init+0x1652>
	for(i=0; i<NPTENTRIES; i++)
f0101f66:	83 c0 04             	add    $0x4,%eax
f0101f69:	39 c2                	cmp    %eax,%edx
f0101f6b:	75 ee                	jne    f0101f5b <mem_init+0xd26>
	kern_pgdir[0] = 0;
f0101f6d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f70:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
f0101f76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f7c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f7f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101f85:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0101f88:	89 93 e4 1a 00 00    	mov    %edx,0x1ae4(%ebx)

	// free the pages we took
	page_free(pp0);
f0101f8e:	83 ec 0c             	sub    $0xc,%esp
f0101f91:	50                   	push   %eax
f0101f92:	e8 a8 ef ff ff       	call   f0100f3f <page_free>
	page_free(pp1);
f0101f97:	89 3c 24             	mov    %edi,(%esp)
f0101f9a:	e8 a0 ef ff ff       	call   f0100f3f <page_free>
	page_free(pp2);
f0101f9f:	83 c4 04             	add    $0x4,%esp
f0101fa2:	ff 75 d0             	push   -0x30(%ebp)
f0101fa5:	e8 95 ef ff ff       	call   f0100f3f <page_free>

	cprintf("check_page() succeeded!\n");
f0101faa:	8d 83 f7 69 f8 ff    	lea    -0x79609(%ebx),%eax
f0101fb0:	89 04 24             	mov    %eax,(%esp)
f0101fb3:	e8 8f 19 00 00       	call   f0103947 <cprintf>
boot_map_region(kern_pgdir,UPAGES,ROUNDUP((sizeof(struct PageInfo) * npages), PGSIZE),PADDR(pages),(PTE_U | PTE_P));
f0101fb8:	8b 83 d0 1a 00 00    	mov    0x1ad0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101fbe:	83 c4 10             	add    $0x10,%esp
f0101fc1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101fc6:	0f 86 dd 08 00 00    	jbe    f01028a9 <mem_init+0x1674>
f0101fcc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101fcf:	8b 97 d8 1a 00 00    	mov    0x1ad8(%edi),%edx
f0101fd5:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0101fdc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101fe2:	83 ec 08             	sub    $0x8,%esp
f0101fe5:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101fe7:	05 00 00 00 10       	add    $0x10000000,%eax
f0101fec:	50                   	push   %eax
f0101fed:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101ff2:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f0101ff8:	e8 ae f0 ff ff       	call   f01010ab <boot_map_region>
boot_map_region(kern_pgdir,UENVS, ROUNDUP((sizeof(struct Env) * NENV),PGSIZE),PADDR(envs),(PTE_U | PTE_P));
f0101ffd:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f0102003:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102005:	83 c4 10             	add    $0x10,%esp
f0102008:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010200d:	0f 86 b2 08 00 00    	jbe    f01028c5 <mem_init+0x1690>
f0102013:	83 ec 08             	sub    $0x8,%esp
f0102016:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102018:	05 00 00 00 10       	add    $0x10000000,%eax
f010201d:	50                   	push   %eax
f010201e:	b9 00 80 01 00       	mov    $0x18000,%ecx
f0102023:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102028:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010202b:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f0102031:	e8 75 f0 ff ff       	call   f01010ab <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102036:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f010203c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010203f:	83 c4 10             	add    $0x10,%esp
f0102042:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102047:	0f 86 94 08 00 00    	jbe    f01028e1 <mem_init+0x16ac>
boot_map_region(kern_pgdir,(KSTACKTOP - KSTKSIZE),KSTKSIZE,PADDR(bootstack),(PTE_W | PTE_P));
f010204d:	83 ec 08             	sub    $0x8,%esp
f0102050:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102052:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102055:	05 00 00 00 10       	add    $0x10000000,%eax
f010205a:	50                   	push   %eax
f010205b:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102060:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102065:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102068:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f010206e:	e8 38 f0 ff ff       	call   f01010ab <boot_map_region>
boot_map_region(kern_pgdir,KERNBASE,ROUNDUP((0xFFFFFFFF - KERNBASE), PGSIZE),0,(PTE_W) | (PTE_P));
f0102073:	83 c4 08             	add    $0x8,%esp
f0102076:	6a 03                	push   $0x3
f0102078:	6a 00                	push   $0x0
f010207a:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010207f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102084:	8b 87 d4 1a 00 00    	mov    0x1ad4(%edi),%eax
f010208a:	e8 1c f0 ff ff       	call   f01010ab <boot_map_region>
	pgdir = kern_pgdir;
f010208f:	89 f9                	mov    %edi,%ecx
f0102091:	8b bf d4 1a 00 00    	mov    0x1ad4(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102097:	8b 81 d8 1a 00 00    	mov    0x1ad8(%ecx),%eax
f010209d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01020a0:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01020a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020ac:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020ae:	8b 81 d0 1a 00 00    	mov    0x1ad0(%ecx),%eax
f01020b4:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01020b7:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01020bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f01020c0:	83 c4 10             	add    $0x10,%esp
f01020c3:	89 f3                	mov    %esi,%ebx
f01020c5:	89 75 c0             	mov    %esi,-0x40(%ebp)
f01020c8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01020cb:	89 d6                	mov    %edx,%esi
f01020cd:	89 c7                	mov    %eax,%edi
f01020cf:	e9 52 08 00 00       	jmp    f0102926 <mem_init+0x16f1>
	assert(nfree == 0);
f01020d4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020d7:	8d 83 20 69 f8 ff    	lea    -0x796e0(%ebx),%eax
f01020dd:	50                   	push   %eax
f01020de:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01020e4:	50                   	push   %eax
f01020e5:	68 d1 02 00 00       	push   $0x2d1
f01020ea:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01020f0:	50                   	push   %eax
f01020f1:	e8 bb df ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01020f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020f9:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f01020ff:	50                   	push   %eax
f0102100:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102106:	50                   	push   %eax
f0102107:	68 2f 03 00 00       	push   $0x32f
f010210c:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102112:	50                   	push   %eax
f0102113:	e8 99 df ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102118:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010211b:	8d 83 44 68 f8 ff    	lea    -0x797bc(%ebx),%eax
f0102121:	50                   	push   %eax
f0102122:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102128:	50                   	push   %eax
f0102129:	68 30 03 00 00       	push   $0x330
f010212e:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102134:	50                   	push   %eax
f0102135:	e8 77 df ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010213a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010213d:	8d 83 5a 68 f8 ff    	lea    -0x797a6(%ebx),%eax
f0102143:	50                   	push   %eax
f0102144:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010214a:	50                   	push   %eax
f010214b:	68 31 03 00 00       	push   $0x331
f0102150:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102156:	50                   	push   %eax
f0102157:	e8 55 df ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010215c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010215f:	8d 83 70 68 f8 ff    	lea    -0x79790(%ebx),%eax
f0102165:	50                   	push   %eax
f0102166:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010216c:	50                   	push   %eax
f010216d:	68 34 03 00 00       	push   $0x334
f0102172:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102178:	50                   	push   %eax
f0102179:	e8 33 df ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010217e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102181:	8d 83 08 61 f8 ff    	lea    -0x79ef8(%ebx),%eax
f0102187:	50                   	push   %eax
f0102188:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010218e:	50                   	push   %eax
f010218f:	68 35 03 00 00       	push   $0x335
f0102194:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010219a:	50                   	push   %eax
f010219b:	e8 11 df ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01021a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021a3:	8d 83 d9 68 f8 ff    	lea    -0x79727(%ebx),%eax
f01021a9:	50                   	push   %eax
f01021aa:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01021b0:	50                   	push   %eax
f01021b1:	68 3c 03 00 00       	push   $0x33c
f01021b6:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01021bc:	50                   	push   %eax
f01021bd:	e8 ef de ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01021c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021c5:	8d 83 48 61 f8 ff    	lea    -0x79eb8(%ebx),%eax
f01021cb:	50                   	push   %eax
f01021cc:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01021d2:	50                   	push   %eax
f01021d3:	68 3f 03 00 00       	push   $0x33f
f01021d8:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01021de:	50                   	push   %eax
f01021df:	e8 cd de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01021e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021e7:	8d 83 80 61 f8 ff    	lea    -0x79e80(%ebx),%eax
f01021ed:	50                   	push   %eax
f01021ee:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01021f4:	50                   	push   %eax
f01021f5:	68 42 03 00 00       	push   $0x342
f01021fa:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102200:	50                   	push   %eax
f0102201:	e8 ab de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102206:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102209:	8d 83 b0 61 f8 ff    	lea    -0x79e50(%ebx),%eax
f010220f:	50                   	push   %eax
f0102210:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102216:	50                   	push   %eax
f0102217:	68 46 03 00 00       	push   $0x346
f010221c:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102222:	50                   	push   %eax
f0102223:	e8 89 de ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102228:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010222b:	8d 83 e0 61 f8 ff    	lea    -0x79e20(%ebx),%eax
f0102231:	50                   	push   %eax
f0102232:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102238:	50                   	push   %eax
f0102239:	68 47 03 00 00       	push   $0x347
f010223e:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102244:	50                   	push   %eax
f0102245:	e8 67 de ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010224a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010224d:	8d 83 08 62 f8 ff    	lea    -0x79df8(%ebx),%eax
f0102253:	50                   	push   %eax
f0102254:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010225a:	50                   	push   %eax
f010225b:	68 48 03 00 00       	push   $0x348
f0102260:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102266:	50                   	push   %eax
f0102267:	e8 45 de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010226c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010226f:	8d 83 2b 69 f8 ff    	lea    -0x796d5(%ebx),%eax
f0102275:	50                   	push   %eax
f0102276:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010227c:	50                   	push   %eax
f010227d:	68 49 03 00 00       	push   $0x349
f0102282:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102288:	50                   	push   %eax
f0102289:	e8 23 de ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010228e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102291:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0102297:	50                   	push   %eax
f0102298:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010229e:	50                   	push   %eax
f010229f:	68 4a 03 00 00       	push   $0x34a
f01022a4:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01022aa:	50                   	push   %eax
f01022ab:	e8 01 de ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022b3:	8d 83 38 62 f8 ff    	lea    -0x79dc8(%ebx),%eax
f01022b9:	50                   	push   %eax
f01022ba:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01022c0:	50                   	push   %eax
f01022c1:	68 4d 03 00 00       	push   $0x34d
f01022c6:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01022cc:	50                   	push   %eax
f01022cd:	e8 df dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022d5:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f01022db:	50                   	push   %eax
f01022dc:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01022e2:	50                   	push   %eax
f01022e3:	68 4e 03 00 00       	push   $0x34e
f01022e8:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01022ee:	50                   	push   %eax
f01022ef:	e8 bd dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01022f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022f7:	8d 83 4d 69 f8 ff    	lea    -0x796b3(%ebx),%eax
f01022fd:	50                   	push   %eax
f01022fe:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102304:	50                   	push   %eax
f0102305:	68 4f 03 00 00       	push   $0x34f
f010230a:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102310:	50                   	push   %eax
f0102311:	e8 9b dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102316:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102319:	8d 83 d9 68 f8 ff    	lea    -0x79727(%ebx),%eax
f010231f:	50                   	push   %eax
f0102320:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102326:	50                   	push   %eax
f0102327:	68 52 03 00 00       	push   $0x352
f010232c:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102332:	50                   	push   %eax
f0102333:	e8 79 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102338:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010233b:	8d 83 38 62 f8 ff    	lea    -0x79dc8(%ebx),%eax
f0102341:	50                   	push   %eax
f0102342:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102348:	50                   	push   %eax
f0102349:	68 55 03 00 00       	push   $0x355
f010234e:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102354:	50                   	push   %eax
f0102355:	e8 57 dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010235a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010235d:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0102363:	50                   	push   %eax
f0102364:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010236a:	50                   	push   %eax
f010236b:	68 56 03 00 00       	push   $0x356
f0102370:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102376:	50                   	push   %eax
f0102377:	e8 35 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f010237c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010237f:	8d 83 4d 69 f8 ff    	lea    -0x796b3(%ebx),%eax
f0102385:	50                   	push   %eax
f0102386:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010238c:	50                   	push   %eax
f010238d:	68 57 03 00 00       	push   $0x357
f0102392:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102398:	50                   	push   %eax
f0102399:	e8 13 dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010239e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023a1:	8d 83 d9 68 f8 ff    	lea    -0x79727(%ebx),%eax
f01023a7:	50                   	push   %eax
f01023a8:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01023ae:	50                   	push   %eax
f01023af:	68 5b 03 00 00       	push   $0x35b
f01023b4:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01023ba:	50                   	push   %eax
f01023bb:	e8 f1 dc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023c0:	53                   	push   %ebx
f01023c1:	89 cb                	mov    %ecx,%ebx
f01023c3:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f01023c9:	50                   	push   %eax
f01023ca:	68 5e 03 00 00       	push   $0x35e
f01023cf:	8d 81 5d 67 f8 ff    	lea    -0x798a3(%ecx),%eax
f01023d5:	50                   	push   %eax
f01023d6:	e8 d6 dc ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023db:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023de:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f01023e4:	50                   	push   %eax
f01023e5:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01023eb:	50                   	push   %eax
f01023ec:	68 5f 03 00 00       	push   $0x35f
f01023f1:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01023f7:	50                   	push   %eax
f01023f8:	e8 b4 dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102400:	8d 83 e4 62 f8 ff    	lea    -0x79d1c(%ebx),%eax
f0102406:	50                   	push   %eax
f0102407:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010240d:	50                   	push   %eax
f010240e:	68 62 03 00 00       	push   $0x362
f0102413:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102419:	50                   	push   %eax
f010241a:	e8 92 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010241f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102422:	8d 83 74 62 f8 ff    	lea    -0x79d8c(%ebx),%eax
f0102428:	50                   	push   %eax
f0102429:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010242f:	50                   	push   %eax
f0102430:	68 63 03 00 00       	push   $0x363
f0102435:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010243b:	50                   	push   %eax
f010243c:	e8 70 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102441:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102444:	8d 83 4d 69 f8 ff    	lea    -0x796b3(%ebx),%eax
f010244a:	50                   	push   %eax
f010244b:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102451:	50                   	push   %eax
f0102452:	68 64 03 00 00       	push   $0x364
f0102457:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010245d:	50                   	push   %eax
f010245e:	e8 4e dc ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102463:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102466:	8d 83 24 63 f8 ff    	lea    -0x79cdc(%ebx),%eax
f010246c:	50                   	push   %eax
f010246d:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102473:	50                   	push   %eax
f0102474:	68 65 03 00 00       	push   $0x365
f0102479:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010247f:	50                   	push   %eax
f0102480:	e8 2c dc ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102485:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102488:	8d 83 5e 69 f8 ff    	lea    -0x796a2(%ebx),%eax
f010248e:	50                   	push   %eax
f010248f:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102495:	50                   	push   %eax
f0102496:	68 66 03 00 00       	push   $0x366
f010249b:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	e8 0a dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024aa:	8d 83 38 62 f8 ff    	lea    -0x79dc8(%ebx),%eax
f01024b0:	50                   	push   %eax
f01024b1:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01024b7:	50                   	push   %eax
f01024b8:	68 69 03 00 00       	push   $0x369
f01024bd:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01024c3:	50                   	push   %eax
f01024c4:	e8 e8 db ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01024c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024cc:	8d 83 58 63 f8 ff    	lea    -0x79ca8(%ebx),%eax
f01024d2:	50                   	push   %eax
f01024d3:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01024d9:	50                   	push   %eax
f01024da:	68 6a 03 00 00       	push   $0x36a
f01024df:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	e8 c6 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024ee:	8d 83 8c 63 f8 ff    	lea    -0x79c74(%ebx),%eax
f01024f4:	50                   	push   %eax
f01024f5:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01024fb:	50                   	push   %eax
f01024fc:	68 6b 03 00 00       	push   $0x36b
f0102501:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	e8 a4 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010250d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102510:	8d 83 c4 63 f8 ff    	lea    -0x79c3c(%ebx),%eax
f0102516:	50                   	push   %eax
f0102517:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010251d:	50                   	push   %eax
f010251e:	68 6e 03 00 00       	push   $0x36e
f0102523:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	e8 82 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010252f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102532:	8d 83 fc 63 f8 ff    	lea    -0x79c04(%ebx),%eax
f0102538:	50                   	push   %eax
f0102539:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010253f:	50                   	push   %eax
f0102540:	68 71 03 00 00       	push   $0x371
f0102545:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010254b:	50                   	push   %eax
f010254c:	e8 60 db ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102551:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102554:	8d 83 8c 63 f8 ff    	lea    -0x79c74(%ebx),%eax
f010255a:	50                   	push   %eax
f010255b:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102561:	50                   	push   %eax
f0102562:	68 72 03 00 00       	push   $0x372
f0102567:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010256d:	50                   	push   %eax
f010256e:	e8 3e db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102573:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102576:	8d 83 38 64 f8 ff    	lea    -0x79bc8(%ebx),%eax
f010257c:	50                   	push   %eax
f010257d:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102583:	50                   	push   %eax
f0102584:	68 75 03 00 00       	push   $0x375
f0102589:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010258f:	50                   	push   %eax
f0102590:	e8 1c db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102595:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102598:	8d 83 64 64 f8 ff    	lea    -0x79b9c(%ebx),%eax
f010259e:	50                   	push   %eax
f010259f:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01025a5:	50                   	push   %eax
f01025a6:	68 76 03 00 00       	push   $0x376
f01025ab:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01025b1:	50                   	push   %eax
f01025b2:	e8 fa da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f01025b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ba:	8d 83 74 69 f8 ff    	lea    -0x7968c(%ebx),%eax
f01025c0:	50                   	push   %eax
f01025c1:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01025c7:	50                   	push   %eax
f01025c8:	68 78 03 00 00       	push   $0x378
f01025cd:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01025d3:	50                   	push   %eax
f01025d4:	e8 d8 da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01025d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025dc:	8d 83 85 69 f8 ff    	lea    -0x7967b(%ebx),%eax
f01025e2:	50                   	push   %eax
f01025e3:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01025e9:	50                   	push   %eax
f01025ea:	68 79 03 00 00       	push   $0x379
f01025ef:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01025f5:	50                   	push   %eax
f01025f6:	e8 b6 da ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01025fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025fe:	8d 83 94 64 f8 ff    	lea    -0x79b6c(%ebx),%eax
f0102604:	50                   	push   %eax
f0102605:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010260b:	50                   	push   %eax
f010260c:	68 7c 03 00 00       	push   $0x37c
f0102611:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102617:	50                   	push   %eax
f0102618:	e8 94 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010261d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102620:	8d 83 b8 64 f8 ff    	lea    -0x79b48(%ebx),%eax
f0102626:	50                   	push   %eax
f0102627:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010262d:	50                   	push   %eax
f010262e:	68 80 03 00 00       	push   $0x380
f0102633:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102639:	50                   	push   %eax
f010263a:	e8 72 da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010263f:	89 cb                	mov    %ecx,%ebx
f0102641:	8d 81 64 64 f8 ff    	lea    -0x79b9c(%ecx),%eax
f0102647:	50                   	push   %eax
f0102648:	8d 81 83 67 f8 ff    	lea    -0x7987d(%ecx),%eax
f010264e:	50                   	push   %eax
f010264f:	68 81 03 00 00       	push   $0x381
f0102654:	8d 81 5d 67 f8 ff    	lea    -0x798a3(%ecx),%eax
f010265a:	50                   	push   %eax
f010265b:	e8 51 da ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102660:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102663:	8d 83 2b 69 f8 ff    	lea    -0x796d5(%ebx),%eax
f0102669:	50                   	push   %eax
f010266a:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102670:	50                   	push   %eax
f0102671:	68 82 03 00 00       	push   $0x382
f0102676:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010267c:	50                   	push   %eax
f010267d:	e8 2f da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102682:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102685:	8d 83 85 69 f8 ff    	lea    -0x7967b(%ebx),%eax
f010268b:	50                   	push   %eax
f010268c:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102692:	50                   	push   %eax
f0102693:	68 83 03 00 00       	push   $0x383
f0102698:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010269e:	50                   	push   %eax
f010269f:	e8 0d da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026a7:	8d 83 dc 64 f8 ff    	lea    -0x79b24(%ebx),%eax
f01026ad:	50                   	push   %eax
f01026ae:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01026b4:	50                   	push   %eax
f01026b5:	68 86 03 00 00       	push   $0x386
f01026ba:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01026c0:	50                   	push   %eax
f01026c1:	e8 eb d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01026c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c9:	8d 83 96 69 f8 ff    	lea    -0x7966a(%ebx),%eax
f01026cf:	50                   	push   %eax
f01026d0:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01026d6:	50                   	push   %eax
f01026d7:	68 87 03 00 00       	push   $0x387
f01026dc:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01026e2:	50                   	push   %eax
f01026e3:	e8 c9 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f01026e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026eb:	8d 83 a2 69 f8 ff    	lea    -0x7965e(%ebx),%eax
f01026f1:	50                   	push   %eax
f01026f2:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01026f8:	50                   	push   %eax
f01026f9:	68 88 03 00 00       	push   $0x388
f01026fe:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102704:	50                   	push   %eax
f0102705:	e8 a7 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010270a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010270d:	8d 83 b8 64 f8 ff    	lea    -0x79b48(%ebx),%eax
f0102713:	50                   	push   %eax
f0102714:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010271a:	50                   	push   %eax
f010271b:	68 8c 03 00 00       	push   $0x38c
f0102720:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102726:	50                   	push   %eax
f0102727:	e8 85 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010272c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010272f:	8d 83 14 65 f8 ff    	lea    -0x79aec(%ebx),%eax
f0102735:	50                   	push   %eax
f0102736:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010273c:	50                   	push   %eax
f010273d:	68 8d 03 00 00       	push   $0x38d
f0102742:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102748:	50                   	push   %eax
f0102749:	e8 63 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f010274e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102751:	8d 83 b7 69 f8 ff    	lea    -0x79649(%ebx),%eax
f0102757:	50                   	push   %eax
f0102758:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010275e:	50                   	push   %eax
f010275f:	68 8e 03 00 00       	push   $0x38e
f0102764:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010276a:	50                   	push   %eax
f010276b:	e8 41 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102770:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102773:	8d 83 85 69 f8 ff    	lea    -0x7967b(%ebx),%eax
f0102779:	50                   	push   %eax
f010277a:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102780:	50                   	push   %eax
f0102781:	68 8f 03 00 00       	push   $0x38f
f0102786:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010278c:	50                   	push   %eax
f010278d:	e8 1f d9 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102792:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102795:	8d 83 3c 65 f8 ff    	lea    -0x79ac4(%ebx),%eax
f010279b:	50                   	push   %eax
f010279c:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01027a2:	50                   	push   %eax
f01027a3:	68 92 03 00 00       	push   $0x392
f01027a8:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01027ae:	50                   	push   %eax
f01027af:	e8 fd d8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01027b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b7:	8d 83 d9 68 f8 ff    	lea    -0x79727(%ebx),%eax
f01027bd:	50                   	push   %eax
f01027be:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01027c4:	50                   	push   %eax
f01027c5:	68 95 03 00 00       	push   $0x395
f01027ca:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01027d0:	50                   	push   %eax
f01027d1:	e8 db d8 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d9:	8d 83 e0 61 f8 ff    	lea    -0x79e20(%ebx),%eax
f01027df:	50                   	push   %eax
f01027e0:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f01027e6:	50                   	push   %eax
f01027e7:	68 98 03 00 00       	push   $0x398
f01027ec:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01027f2:	50                   	push   %eax
f01027f3:	e8 b9 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01027f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027fb:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0102801:	50                   	push   %eax
f0102802:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102808:	50                   	push   %eax
f0102809:	68 9a 03 00 00       	push   $0x39a
f010280e:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102814:	50                   	push   %eax
f0102815:	e8 97 d8 ff ff       	call   f01000b1 <_panic>
f010281a:	52                   	push   %edx
f010281b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010281e:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f0102824:	50                   	push   %eax
f0102825:	68 a1 03 00 00       	push   $0x3a1
f010282a:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102830:	50                   	push   %eax
f0102831:	e8 7b d8 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102836:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102839:	8d 83 c8 69 f8 ff    	lea    -0x79638(%ebx),%eax
f010283f:	50                   	push   %eax
f0102840:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102846:	50                   	push   %eax
f0102847:	68 a2 03 00 00       	push   $0x3a2
f010284c:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102852:	50                   	push   %eax
f0102853:	e8 59 d8 ff ff       	call   f01000b1 <_panic>
f0102858:	52                   	push   %edx
f0102859:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f010285f:	50                   	push   %eax
f0102860:	6a 56                	push   $0x56
f0102862:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0102868:	50                   	push   %eax
f0102869:	e8 43 d8 ff ff       	call   f01000b1 <_panic>
f010286e:	52                   	push   %edx
f010286f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102872:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	6a 56                	push   $0x56
f010287b:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0102881:	50                   	push   %eax
f0102882:	e8 2a d8 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102887:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288a:	8d 83 e0 69 f8 ff    	lea    -0x79620(%ebx),%eax
f0102890:	50                   	push   %eax
f0102891:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102897:	50                   	push   %eax
f0102898:	68 ac 03 00 00       	push   $0x3ac
f010289d:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01028a3:	50                   	push   %eax
f01028a4:	e8 08 d8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028a9:	50                   	push   %eax
f01028aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ad:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01028b3:	50                   	push   %eax
f01028b4:	68 b9 00 00 00       	push   $0xb9
f01028b9:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01028bf:	50                   	push   %eax
f01028c0:	e8 ec d7 ff ff       	call   f01000b1 <_panic>
f01028c5:	50                   	push   %eax
f01028c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028c9:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01028cf:	50                   	push   %eax
f01028d0:	68 c1 00 00 00       	push   $0xc1
f01028d5:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	e8 d0 d7 ff ff       	call   f01000b1 <_panic>
f01028e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e4:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f01028ea:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01028f0:	50                   	push   %eax
f01028f1:	68 cd 00 00 00       	push   $0xcd
f01028f6:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f01028fc:	50                   	push   %eax
f01028fd:	e8 af d7 ff ff       	call   f01000b1 <_panic>
f0102902:	ff 75 bc             	push   -0x44(%ebp)
f0102905:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102908:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f010290e:	50                   	push   %eax
f010290f:	68 e9 02 00 00       	push   $0x2e9
f0102914:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f010291a:	50                   	push   %eax
f010291b:	e8 91 d7 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102920:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102926:	39 de                	cmp    %ebx,%esi
f0102928:	76 42                	jbe    f010296c <mem_init+0x1737>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010292a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102930:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102933:	e8 e6 e0 ff ff       	call   f0100a1e <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102938:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010293e:	76 c2                	jbe    f0102902 <mem_init+0x16cd>
f0102940:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102943:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102946:	39 c2                	cmp    %eax,%edx
f0102948:	74 d6                	je     f0102920 <mem_init+0x16eb>
f010294a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010294d:	8d 83 60 65 f8 ff    	lea    -0x79aa0(%ebx),%eax
f0102953:	50                   	push   %eax
f0102954:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010295a:	50                   	push   %eax
f010295b:	68 e9 02 00 00       	push   $0x2e9
f0102960:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102966:	50                   	push   %eax
f0102967:	e8 45 d7 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010296c:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010296f:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102972:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102975:	c7 c0 54 13 18 f0    	mov    $0xf0181354,%eax
f010297b:	8b 00                	mov    (%eax),%eax
f010297d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0102980:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102985:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f010298b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010298e:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102991:	89 c6                	mov    %eax,%esi
f0102993:	89 da                	mov    %ebx,%edx
f0102995:	89 f8                	mov    %edi,%eax
f0102997:	e8 82 e0 ff ff       	call   f0100a1e <check_va2pa>
f010299c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029a2:	76 45                	jbe    f01029e9 <mem_init+0x17b4>
f01029a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01029a7:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01029aa:	39 c2                	cmp    %eax,%edx
f01029ac:	75 59                	jne    f0102a07 <mem_init+0x17d2>
	for (i = 0; i < n; i += PGSIZE)
f01029ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029b4:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f01029ba:	75 d7                	jne    f0102993 <mem_init+0x175e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029bc:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01029bf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029c2:	c1 e0 0c             	shl    $0xc,%eax
f01029c5:	89 f3                	mov    %esi,%ebx
f01029c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01029ca:	89 c6                	mov    %eax,%esi
f01029cc:	39 f3                	cmp    %esi,%ebx
f01029ce:	73 7b                	jae    f0102a4b <mem_init+0x1816>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029d0:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029d6:	89 f8                	mov    %edi,%eax
f01029d8:	e8 41 e0 ff ff       	call   f0100a1e <check_va2pa>
f01029dd:	39 c3                	cmp    %eax,%ebx
f01029df:	75 48                	jne    f0102a29 <mem_init+0x17f4>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029e1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029e7:	eb e3                	jmp    f01029cc <mem_init+0x1797>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029e9:	ff 75 c0             	push   -0x40(%ebp)
f01029ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ef:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01029f5:	50                   	push   %eax
f01029f6:	68 ee 02 00 00       	push   $0x2ee
f01029fb:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102a01:	50                   	push   %eax
f0102a02:	e8 aa d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102a07:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a0a:	8d 83 94 65 f8 ff    	lea    -0x79a6c(%ebx),%eax
f0102a10:	50                   	push   %eax
f0102a11:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102a17:	50                   	push   %eax
f0102a18:	68 ee 02 00 00       	push   $0x2ee
f0102a1d:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102a23:	50                   	push   %eax
f0102a24:	e8 88 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a29:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a2c:	8d 83 c8 65 f8 ff    	lea    -0x79a38(%ebx),%eax
f0102a32:	50                   	push   %eax
f0102a33:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102a39:	50                   	push   %eax
f0102a3a:	68 f2 02 00 00       	push   $0x2f2
f0102a3f:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102a45:	50                   	push   %eax
f0102a46:	e8 66 d6 ff ff       	call   f01000b1 <_panic>
f0102a4b:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a50:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a53:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a58:	89 c6                	mov    %eax,%esi
f0102a5a:	89 da                	mov    %ebx,%edx
f0102a5c:	89 f8                	mov    %edi,%eax
f0102a5e:	e8 bb df ff ff       	call   f0100a1e <check_va2pa>
f0102a63:	89 c2                	mov    %eax,%edx
f0102a65:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102a68:	39 c2                	cmp    %eax,%edx
f0102a6a:	75 44                	jne    f0102ab0 <mem_init+0x187b>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a6c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a72:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a78:	75 e0                	jne    f0102a5a <mem_init+0x1825>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a7a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102a7d:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a82:	89 f8                	mov    %edi,%eax
f0102a84:	e8 95 df ff ff       	call   f0100a1e <check_va2pa>
f0102a89:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a8c:	74 71                	je     f0102aff <mem_init+0x18ca>
f0102a8e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a91:	8d 83 38 66 f8 ff    	lea    -0x799c8(%ebx),%eax
f0102a97:	50                   	push   %eax
f0102a98:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102a9e:	50                   	push   %eax
f0102a9f:	68 f7 02 00 00       	push   $0x2f7
f0102aa4:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102aaa:	50                   	push   %eax
f0102aab:	e8 01 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102ab0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab3:	8d 83 f0 65 f8 ff    	lea    -0x79a10(%ebx),%eax
f0102ab9:	50                   	push   %eax
f0102aba:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102ac0:	50                   	push   %eax
f0102ac1:	68 f6 02 00 00       	push   $0x2f6
f0102ac6:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102acc:	50                   	push   %eax
f0102acd:	e8 df d5 ff ff       	call   f01000b1 <_panic>
		switch (i) {
f0102ad2:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102ad8:	75 25                	jne    f0102aff <mem_init+0x18ca>
			assert(pgdir[i] & PTE_P);
f0102ada:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102ade:	74 4f                	je     f0102b2f <mem_init+0x18fa>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ae0:	83 c6 01             	add    $0x1,%esi
f0102ae3:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102ae9:	0f 87 b1 00 00 00    	ja     f0102ba0 <mem_init+0x196b>
		switch (i) {
f0102aef:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102af5:	77 db                	ja     f0102ad2 <mem_init+0x189d>
f0102af7:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0102afd:	77 db                	ja     f0102ada <mem_init+0x18a5>
			if (i >= PDX(KERNBASE)) {
f0102aff:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102b05:	77 4a                	ja     f0102b51 <mem_init+0x191c>
				assert(pgdir[i] == 0);
f0102b07:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102b0b:	74 d3                	je     f0102ae0 <mem_init+0x18ab>
f0102b0d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b10:	8d 83 32 6a f8 ff    	lea    -0x795ce(%ebx),%eax
f0102b16:	50                   	push   %eax
f0102b17:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102b1d:	50                   	push   %eax
f0102b1e:	68 07 03 00 00       	push   $0x307
f0102b23:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102b29:	50                   	push   %eax
f0102b2a:	e8 82 d5 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b2f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b32:	8d 83 10 6a f8 ff    	lea    -0x795f0(%ebx),%eax
f0102b38:	50                   	push   %eax
f0102b39:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102b3f:	50                   	push   %eax
f0102b40:	68 00 03 00 00       	push   $0x300
f0102b45:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102b4b:	50                   	push   %eax
f0102b4c:	e8 60 d5 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b51:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102b54:	a8 01                	test   $0x1,%al
f0102b56:	74 26                	je     f0102b7e <mem_init+0x1949>
				assert(pgdir[i] & PTE_W);
f0102b58:	a8 02                	test   $0x2,%al
f0102b5a:	75 84                	jne    f0102ae0 <mem_init+0x18ab>
f0102b5c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b5f:	8d 83 21 6a f8 ff    	lea    -0x795df(%ebx),%eax
f0102b65:	50                   	push   %eax
f0102b66:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102b6c:	50                   	push   %eax
f0102b6d:	68 05 03 00 00       	push   $0x305
f0102b72:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102b78:	50                   	push   %eax
f0102b79:	e8 33 d5 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b7e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b81:	8d 83 10 6a f8 ff    	lea    -0x795f0(%ebx),%eax
f0102b87:	50                   	push   %eax
f0102b88:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102b8e:	50                   	push   %eax
f0102b8f:	68 04 03 00 00       	push   $0x304
f0102b94:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102b9a:	50                   	push   %eax
f0102b9b:	e8 11 d5 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102ba0:	83 ec 0c             	sub    $0xc,%esp
f0102ba3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba6:	8d 83 68 66 f8 ff    	lea    -0x79998(%ebx),%eax
f0102bac:	50                   	push   %eax
f0102bad:	e8 95 0d 00 00       	call   f0103947 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bb2:	8b 83 d4 1a 00 00    	mov    0x1ad4(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102bb8:	83 c4 10             	add    $0x10,%esp
f0102bbb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bc0:	0f 86 2c 02 00 00    	jbe    f0102df2 <mem_init+0x1bbd>
	return (physaddr_t)kva - KERNBASE;
f0102bc6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bcb:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bce:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bd3:	e8 c2 de ff ff       	call   f0100a9a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bd8:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bdb:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bde:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102be3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102be6:	83 ec 0c             	sub    $0xc,%esp
f0102be9:	6a 00                	push   $0x0
f0102beb:	e8 ca e2 ff ff       	call   f0100eba <page_alloc>
f0102bf0:	89 c6                	mov    %eax,%esi
f0102bf2:	83 c4 10             	add    $0x10,%esp
f0102bf5:	85 c0                	test   %eax,%eax
f0102bf7:	0f 84 11 02 00 00    	je     f0102e0e <mem_init+0x1bd9>
	assert((pp1 = page_alloc(0)));
f0102bfd:	83 ec 0c             	sub    $0xc,%esp
f0102c00:	6a 00                	push   $0x0
f0102c02:	e8 b3 e2 ff ff       	call   f0100eba <page_alloc>
f0102c07:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c0a:	83 c4 10             	add    $0x10,%esp
f0102c0d:	85 c0                	test   %eax,%eax
f0102c0f:	0f 84 1b 02 00 00    	je     f0102e30 <mem_init+0x1bfb>
	assert((pp2 = page_alloc(0)));
f0102c15:	83 ec 0c             	sub    $0xc,%esp
f0102c18:	6a 00                	push   $0x0
f0102c1a:	e8 9b e2 ff ff       	call   f0100eba <page_alloc>
f0102c1f:	89 c7                	mov    %eax,%edi
f0102c21:	83 c4 10             	add    $0x10,%esp
f0102c24:	85 c0                	test   %eax,%eax
f0102c26:	0f 84 26 02 00 00    	je     f0102e52 <mem_init+0x1c1d>
	page_free(pp0);
f0102c2c:	83 ec 0c             	sub    $0xc,%esp
f0102c2f:	56                   	push   %esi
f0102c30:	e8 0a e3 ff ff       	call   f0100f3f <page_free>
	return (pp - pages) << PGSHIFT;
f0102c35:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c38:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c3b:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102c41:	c1 f8 03             	sar    $0x3,%eax
f0102c44:	89 c2                	mov    %eax,%edx
f0102c46:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c49:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102c57:	0f 83 17 02 00 00    	jae    f0102e74 <mem_init+0x1c3f>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c5d:	83 ec 04             	sub    $0x4,%esp
f0102c60:	68 00 10 00 00       	push   $0x1000
f0102c65:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c67:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c6d:	52                   	push   %edx
f0102c6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c71:	e8 5e 22 00 00       	call   f0104ed4 <memset>
	return (pp - pages) << PGSHIFT;
f0102c76:	89 f8                	mov    %edi,%eax
f0102c78:	2b 83 d0 1a 00 00    	sub    0x1ad0(%ebx),%eax
f0102c7e:	c1 f8 03             	sar    $0x3,%eax
f0102c81:	89 c2                	mov    %eax,%edx
f0102c83:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c86:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c8b:	83 c4 10             	add    $0x10,%esp
f0102c8e:	3b 83 d8 1a 00 00    	cmp    0x1ad8(%ebx),%eax
f0102c94:	0f 83 f2 01 00 00    	jae    f0102e8c <mem_init+0x1c57>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c9a:	83 ec 04             	sub    $0x4,%esp
f0102c9d:	68 00 10 00 00       	push   $0x1000
f0102ca2:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ca4:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102caa:	52                   	push   %edx
f0102cab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cae:	e8 21 22 00 00       	call   f0104ed4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cb3:	6a 02                	push   $0x2
f0102cb5:	68 00 10 00 00       	push   $0x1000
f0102cba:	ff 75 d0             	push   -0x30(%ebp)
f0102cbd:	ff b3 d4 1a 00 00    	push   0x1ad4(%ebx)
f0102cc3:	e8 d6 e4 ff ff       	call   f010119e <page_insert>
	assert(pp1->pp_ref == 1);
f0102cc8:	83 c4 20             	add    $0x20,%esp
f0102ccb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cce:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102cd3:	0f 85 cc 01 00 00    	jne    f0102ea5 <mem_init+0x1c70>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cd9:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ce0:	01 01 01 
f0102ce3:	0f 85 de 01 00 00    	jne    f0102ec7 <mem_init+0x1c92>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ce9:	6a 02                	push   $0x2
f0102ceb:	68 00 10 00 00       	push   $0x1000
f0102cf0:	57                   	push   %edi
f0102cf1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cf4:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102cfa:	e8 9f e4 ff ff       	call   f010119e <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cff:	83 c4 10             	add    $0x10,%esp
f0102d02:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d09:	02 02 02 
f0102d0c:	0f 85 d7 01 00 00    	jne    f0102ee9 <mem_init+0x1cb4>
	assert(pp2->pp_ref == 1);
f0102d12:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d17:	0f 85 ee 01 00 00    	jne    f0102f0b <mem_init+0x1cd6>
	assert(pp1->pp_ref == 0);
f0102d1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d20:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d25:	0f 85 02 02 00 00    	jne    f0102f2d <mem_init+0x1cf8>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d2b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d32:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d35:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d38:	89 f8                	mov    %edi,%eax
f0102d3a:	2b 81 d0 1a 00 00    	sub    0x1ad0(%ecx),%eax
f0102d40:	c1 f8 03             	sar    $0x3,%eax
f0102d43:	89 c2                	mov    %eax,%edx
f0102d45:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d48:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d4d:	3b 81 d8 1a 00 00    	cmp    0x1ad8(%ecx),%eax
f0102d53:	0f 83 f6 01 00 00    	jae    f0102f4f <mem_init+0x1d1a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d59:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d60:	03 03 03 
f0102d63:	0f 85 fe 01 00 00    	jne    f0102f67 <mem_init+0x1d32>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d69:	83 ec 08             	sub    $0x8,%esp
f0102d6c:	68 00 10 00 00       	push   $0x1000
f0102d71:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d74:	ff b0 d4 1a 00 00    	push   0x1ad4(%eax)
f0102d7a:	e8 da e3 ff ff       	call   f0101159 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d7f:	83 c4 10             	add    $0x10,%esp
f0102d82:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d87:	0f 85 fc 01 00 00    	jne    f0102f89 <mem_init+0x1d54>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d8d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d90:	8b 88 d4 1a 00 00    	mov    0x1ad4(%eax),%ecx
f0102d96:	8b 11                	mov    (%ecx),%edx
f0102d98:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d9e:	89 f7                	mov    %esi,%edi
f0102da0:	2b b8 d0 1a 00 00    	sub    0x1ad0(%eax),%edi
f0102da6:	89 f8                	mov    %edi,%eax
f0102da8:	c1 f8 03             	sar    $0x3,%eax
f0102dab:	c1 e0 0c             	shl    $0xc,%eax
f0102dae:	39 c2                	cmp    %eax,%edx
f0102db0:	0f 85 f5 01 00 00    	jne    f0102fab <mem_init+0x1d76>
	kern_pgdir[0] = 0;
f0102db6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dbc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dc1:	0f 85 06 02 00 00    	jne    f0102fcd <mem_init+0x1d98>
	pp0->pp_ref = 0;
f0102dc7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102dcd:	83 ec 0c             	sub    $0xc,%esp
f0102dd0:	56                   	push   %esi
f0102dd1:	e8 69 e1 ff ff       	call   f0100f3f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dd6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd9:	8d 83 fc 66 f8 ff    	lea    -0x79904(%ebx),%eax
f0102ddf:	89 04 24             	mov    %eax,(%esp)
f0102de2:	e8 60 0b 00 00       	call   f0103947 <cprintf>
}
f0102de7:	83 c4 10             	add    $0x10,%esp
f0102dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ded:	5b                   	pop    %ebx
f0102dee:	5e                   	pop    %esi
f0102def:	5f                   	pop    %edi
f0102df0:	5d                   	pop    %ebp
f0102df1:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102df2:	50                   	push   %eax
f0102df3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df6:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f0102dfc:	50                   	push   %eax
f0102dfd:	68 e1 00 00 00       	push   $0xe1
f0102e02:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102e08:	50                   	push   %eax
f0102e09:	e8 a3 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e11:	8d 83 2e 68 f8 ff    	lea    -0x797d2(%ebx),%eax
f0102e17:	50                   	push   %eax
f0102e18:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102e1e:	50                   	push   %eax
f0102e1f:	68 c7 03 00 00       	push   $0x3c7
f0102e24:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102e2a:	50                   	push   %eax
f0102e2b:	e8 81 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e33:	8d 83 44 68 f8 ff    	lea    -0x797bc(%ebx),%eax
f0102e39:	50                   	push   %eax
f0102e3a:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102e40:	50                   	push   %eax
f0102e41:	68 c8 03 00 00       	push   $0x3c8
f0102e46:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102e4c:	50                   	push   %eax
f0102e4d:	e8 5f d2 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e52:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e55:	8d 83 5a 68 f8 ff    	lea    -0x797a6(%ebx),%eax
f0102e5b:	50                   	push   %eax
f0102e5c:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102e62:	50                   	push   %eax
f0102e63:	68 c9 03 00 00       	push   $0x3c9
f0102e68:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102e6e:	50                   	push   %eax
f0102e6f:	e8 3d d2 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e74:	52                   	push   %edx
f0102e75:	89 cb                	mov    %ecx,%ebx
f0102e77:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f0102e7d:	50                   	push   %eax
f0102e7e:	6a 56                	push   $0x56
f0102e80:	8d 81 69 67 f8 ff    	lea    -0x79897(%ecx),%eax
f0102e86:	50                   	push   %eax
f0102e87:	e8 25 d2 ff ff       	call   f01000b1 <_panic>
f0102e8c:	52                   	push   %edx
f0102e8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e90:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f0102e96:	50                   	push   %eax
f0102e97:	6a 56                	push   $0x56
f0102e99:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0102e9f:	50                   	push   %eax
f0102ea0:	e8 0c d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102ea5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ea8:	8d 83 2b 69 f8 ff    	lea    -0x796d5(%ebx),%eax
f0102eae:	50                   	push   %eax
f0102eaf:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102eb5:	50                   	push   %eax
f0102eb6:	68 ce 03 00 00       	push   $0x3ce
f0102ebb:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102ec1:	50                   	push   %eax
f0102ec2:	e8 ea d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ec7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eca:	8d 83 88 66 f8 ff    	lea    -0x79978(%ebx),%eax
f0102ed0:	50                   	push   %eax
f0102ed1:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102ed7:	50                   	push   %eax
f0102ed8:	68 cf 03 00 00       	push   $0x3cf
f0102edd:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102ee3:	50                   	push   %eax
f0102ee4:	e8 c8 d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ee9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eec:	8d 83 ac 66 f8 ff    	lea    -0x79954(%ebx),%eax
f0102ef2:	50                   	push   %eax
f0102ef3:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102ef9:	50                   	push   %eax
f0102efa:	68 d1 03 00 00       	push   $0x3d1
f0102eff:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102f05:	50                   	push   %eax
f0102f06:	e8 a6 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102f0b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f0e:	8d 83 4d 69 f8 ff    	lea    -0x796b3(%ebx),%eax
f0102f14:	50                   	push   %eax
f0102f15:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102f1b:	50                   	push   %eax
f0102f1c:	68 d2 03 00 00       	push   $0x3d2
f0102f21:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102f27:	50                   	push   %eax
f0102f28:	e8 84 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102f2d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f30:	8d 83 b7 69 f8 ff    	lea    -0x79649(%ebx),%eax
f0102f36:	50                   	push   %eax
f0102f37:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102f3d:	50                   	push   %eax
f0102f3e:	68 d3 03 00 00       	push   $0x3d3
f0102f43:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102f49:	50                   	push   %eax
f0102f4a:	e8 62 d1 ff ff       	call   f01000b1 <_panic>
f0102f4f:	52                   	push   %edx
f0102f50:	89 cb                	mov    %ecx,%ebx
f0102f52:	8d 81 1c 5f f8 ff    	lea    -0x7a0e4(%ecx),%eax
f0102f58:	50                   	push   %eax
f0102f59:	6a 56                	push   $0x56
f0102f5b:	8d 81 69 67 f8 ff    	lea    -0x79897(%ecx),%eax
f0102f61:	50                   	push   %eax
f0102f62:	e8 4a d1 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6a:	8d 83 d0 66 f8 ff    	lea    -0x79930(%ebx),%eax
f0102f70:	50                   	push   %eax
f0102f71:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102f77:	50                   	push   %eax
f0102f78:	68 d5 03 00 00       	push   $0x3d5
f0102f7d:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102f83:	50                   	push   %eax
f0102f84:	e8 28 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102f89:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8c:	8d 83 85 69 f8 ff    	lea    -0x7967b(%ebx),%eax
f0102f92:	50                   	push   %eax
f0102f93:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102f99:	50                   	push   %eax
f0102f9a:	68 d7 03 00 00       	push   $0x3d7
f0102f9f:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102fa5:	50                   	push   %eax
f0102fa6:	e8 06 d1 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fae:	8d 83 e0 61 f8 ff    	lea    -0x79e20(%ebx),%eax
f0102fb4:	50                   	push   %eax
f0102fb5:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102fbb:	50                   	push   %eax
f0102fbc:	68 da 03 00 00       	push   $0x3da
f0102fc1:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102fc7:	50                   	push   %eax
f0102fc8:	e8 e4 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102fcd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd0:	8d 83 3c 69 f8 ff    	lea    -0x796c4(%ebx),%eax
f0102fd6:	50                   	push   %eax
f0102fd7:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0102fdd:	50                   	push   %eax
f0102fde:	68 dc 03 00 00       	push   $0x3dc
f0102fe3:	8d 83 5d 67 f8 ff    	lea    -0x798a3(%ebx),%eax
f0102fe9:	50                   	push   %eax
f0102fea:	e8 c2 d0 ff ff       	call   f01000b1 <_panic>

f0102fef <tlb_invalidate>:
{
f0102fef:	55                   	push   %ebp
f0102ff0:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ff5:	0f 01 38             	invlpg (%eax)
}
f0102ff8:	5d                   	pop    %ebp
f0102ff9:	c3                   	ret    

f0102ffa <user_mem_check>:
{
f0102ffa:	55                   	push   %ebp
f0102ffb:	89 e5                	mov    %esp,%ebp
f0102ffd:	57                   	push   %edi
f0102ffe:	56                   	push   %esi
f0102fff:	53                   	push   %ebx
f0103000:	83 ec 1c             	sub    $0x1c,%esp
f0103003:	e8 f1 d6 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103008:	05 60 c8 07 00       	add    $0x7c860,%eax
f010300d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103010:	8b 7d 08             	mov    0x8(%ebp),%edi
    uint32_t start = ROUNDDOWN(addr, PGSIZE);
f0103013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103016:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    uint32_t end = ROUNDUP(addr + len, PGSIZE);
f010301c:	8b 45 10             	mov    0x10(%ebp),%eax
f010301f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103022:	8d b4 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%esi
f0103029:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    while (start < end) {
f010302f:	39 f3                	cmp    %esi,%ebx
f0103031:	73 52                	jae    f0103085 <user_mem_check+0x8b>
        pte_t *pte = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0103033:	83 ec 04             	sub    $0x4,%esp
f0103036:	6a 00                	push   $0x0
f0103038:	53                   	push   %ebx
f0103039:	ff 77 5c             	push   0x5c(%edi)
f010303c:	e8 91 df ff ff       	call   f0100fd2 <pgdir_walk>
        if (start >= ULIM || pte == NULL || !(*pte & PTE_P) || (*pte & perm) != perm) {
f0103041:	83 c4 10             	add    $0x10,%esp
f0103044:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010304a:	77 1a                	ja     f0103066 <user_mem_check+0x6c>
f010304c:	85 c0                	test   %eax,%eax
f010304e:	74 16                	je     f0103066 <user_mem_check+0x6c>
f0103050:	8b 00                	mov    (%eax),%eax
f0103052:	a8 01                	test   $0x1,%al
f0103054:	74 10                	je     f0103066 <user_mem_check+0x6c>
f0103056:	23 45 14             	and    0x14(%ebp),%eax
f0103059:	39 45 14             	cmp    %eax,0x14(%ebp)
f010305c:	75 08                	jne    f0103066 <user_mem_check+0x6c>
        start += PGSIZE;
f010305e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103064:	eb c9                	jmp    f010302f <user_mem_check+0x35>
            user_mem_check_addr = (start < addr) ? addr : start;
f0103066:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0103069:	89 d8                	mov    %ebx,%eax
f010306b:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f010306f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103072:	89 81 e0 1a 00 00    	mov    %eax,0x1ae0(%ecx)
            return -E_FAULT;
f0103078:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010307d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103080:	5b                   	pop    %ebx
f0103081:	5e                   	pop    %esi
f0103082:	5f                   	pop    %edi
f0103083:	5d                   	pop    %ebp
f0103084:	c3                   	ret    
    return 0;
f0103085:	b8 00 00 00 00       	mov    $0x0,%eax
f010308a:	eb f1                	jmp    f010307d <user_mem_check+0x83>

f010308c <user_mem_assert>:
{
f010308c:	55                   	push   %ebp
f010308d:	89 e5                	mov    %esp,%ebp
f010308f:	56                   	push   %esi
f0103090:	53                   	push   %ebx
f0103091:	e8 d1 d0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103096:	81 c3 d2 c7 07 00    	add    $0x7c7d2,%ebx
f010309c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010309f:	8b 45 14             	mov    0x14(%ebp),%eax
f01030a2:	83 c8 04             	or     $0x4,%eax
f01030a5:	50                   	push   %eax
f01030a6:	ff 75 10             	push   0x10(%ebp)
f01030a9:	ff 75 0c             	push   0xc(%ebp)
f01030ac:	56                   	push   %esi
f01030ad:	e8 48 ff ff ff       	call   f0102ffa <user_mem_check>
f01030b2:	83 c4 10             	add    $0x10,%esp
f01030b5:	85 c0                	test   %eax,%eax
f01030b7:	78 07                	js     f01030c0 <user_mem_assert+0x34>
}
f01030b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030bc:	5b                   	pop    %ebx
f01030bd:	5e                   	pop    %esi
f01030be:	5d                   	pop    %ebp
f01030bf:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01030c0:	83 ec 04             	sub    $0x4,%esp
f01030c3:	ff b3 e0 1a 00 00    	push   0x1ae0(%ebx)
f01030c9:	ff 76 48             	push   0x48(%esi)
f01030cc:	8d 83 28 67 f8 ff    	lea    -0x798d8(%ebx),%eax
f01030d2:	50                   	push   %eax
f01030d3:	e8 6f 08 00 00       	call   f0103947 <cprintf>
		env_destroy(env);	// may not return
f01030d8:	89 34 24             	mov    %esi,(%esp)
f01030db:	e8 fd 06 00 00       	call   f01037dd <env_destroy>
f01030e0:	83 c4 10             	add    $0x10,%esp
}
f01030e3:	eb d4                	jmp    f01030b9 <user_mem_assert+0x2d>

f01030e5 <__x86.get_pc_thunk.dx>:
f01030e5:	8b 14 24             	mov    (%esp),%edx
f01030e8:	c3                   	ret    

f01030e9 <__x86.get_pc_thunk.cx>:
f01030e9:	8b 0c 24             	mov    (%esp),%ecx
f01030ec:	c3                   	ret    

f01030ed <__x86.get_pc_thunk.di>:
f01030ed:	8b 3c 24             	mov    (%esp),%edi
f01030f0:	c3                   	ret    

f01030f1 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01030f1:	55                   	push   %ebp
f01030f2:	89 e5                	mov    %esp,%ebp
f01030f4:	57                   	push   %edi
f01030f5:	56                   	push   %esi
f01030f6:	53                   	push   %ebx
f01030f7:	83 ec 1c             	sub    $0x1c,%esp
f01030fa:	e8 68 d0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01030ff:	81 c3 69 c7 07 00    	add    $0x7c769,%ebx
f0103105:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va, PGSIZE);
f0103107:	89 d0                	mov    %edx,%eax
f0103109:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010310e:	89 c6                	mov    %eax,%esi
     len = ROUNDUP(len, PGSIZE);
f0103110:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0103116:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010311c:	01 c8                	add    %ecx,%eax
f010311e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 
     struct PageInfo *pp;
     int ret = 0;
 
     for(; len > 0; len -= PGSIZE, va += PGSIZE)
f0103121:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103124:	74 62                	je     f0103188 <region_alloc+0x97>
     {
         pp = page_alloc(0);
f0103126:	83 ec 0c             	sub    $0xc,%esp
f0103129:	6a 00                	push   $0x0
f010312b:	e8 8a dd ff ff       	call   f0100eba <page_alloc>
 
         if(!pp)
f0103130:	83 c4 10             	add    $0x10,%esp
f0103133:	85 c0                	test   %eax,%eax
f0103135:	74 1b                	je     f0103152 <region_alloc+0x61>
         {
             panic("no work :(\n");
         }
 
         ret = page_insert(e->env_pgdir, pp, va, PTE_U | PTE_W | PTE_P);
f0103137:	6a 07                	push   $0x7
f0103139:	56                   	push   %esi
f010313a:	50                   	push   %eax
f010313b:	ff 77 5c             	push   0x5c(%edi)
f010313e:	e8 5b e0 ff ff       	call   f010119e <page_insert>
 
         if(ret)
f0103143:	83 c4 10             	add    $0x10,%esp
f0103146:	85 c0                	test   %eax,%eax
f0103148:	75 23                	jne    f010316d <region_alloc+0x7c>
     for(; len > 0; len -= PGSIZE, va += PGSIZE)
f010314a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103150:	eb cf                	jmp    f0103121 <region_alloc+0x30>
             panic("no work :(\n");
f0103152:	83 ec 04             	sub    $0x4,%esp
f0103155:	8d 83 40 6a f8 ff    	lea    -0x795c0(%ebx),%eax
f010315b:	50                   	push   %eax
f010315c:	68 29 01 00 00       	push   $0x129
f0103161:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f0103167:	50                   	push   %eax
f0103168:	e8 44 cf ff ff       	call   f01000b1 <_panic>
         {
             panic("no work :(\n");
f010316d:	83 ec 04             	sub    $0x4,%esp
f0103170:	8d 83 40 6a f8 ff    	lea    -0x795c0(%ebx),%eax
f0103176:	50                   	push   %eax
f0103177:	68 30 01 00 00       	push   $0x130
f010317c:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f0103182:	50                   	push   %eax
f0103183:	e8 29 cf ff ff       	call   f01000b1 <_panic>
         }
     }
}
f0103188:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010318b:	5b                   	pop    %ebx
f010318c:	5e                   	pop    %esi
f010318d:	5f                   	pop    %edi
f010318e:	5d                   	pop    %ebp
f010318f:	c3                   	ret    

f0103190 <envid2env>:
{
f0103190:	55                   	push   %ebp
f0103191:	89 e5                	mov    %esp,%ebp
f0103193:	53                   	push   %ebx
f0103194:	e8 50 ff ff ff       	call   f01030e9 <__x86.get_pc_thunk.cx>
f0103199:	81 c1 cf c6 07 00    	add    $0x7c6cf,%ecx
f010319f:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f01031a5:	85 c0                	test   %eax,%eax
f01031a7:	74 4c                	je     f01031f5 <envid2env+0x65>
	e = &envs[ENVX(envid)];
f01031a9:	89 c2                	mov    %eax,%edx
f01031ab:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01031b1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01031b4:	c1 e2 05             	shl    $0x5,%edx
f01031b7:	03 91 ec 1a 00 00    	add    0x1aec(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01031bd:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f01031c1:	74 42                	je     f0103205 <envid2env+0x75>
f01031c3:	39 42 48             	cmp    %eax,0x48(%edx)
f01031c6:	75 49                	jne    f0103211 <envid2env+0x81>
	return 0;
f01031c8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031cd:	84 db                	test   %bl,%bl
f01031cf:	74 2a                	je     f01031fb <envid2env+0x6b>
f01031d1:	8b 89 e8 1a 00 00    	mov    0x1ae8(%ecx),%ecx
f01031d7:	39 d1                	cmp    %edx,%ecx
f01031d9:	74 20                	je     f01031fb <envid2env+0x6b>
f01031db:	8b 42 4c             	mov    0x4c(%edx),%eax
f01031de:	3b 41 48             	cmp    0x48(%ecx),%eax
f01031e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01031e6:	0f 45 d3             	cmovne %ebx,%edx
f01031e9:	0f 94 c0             	sete   %al
f01031ec:	0f b6 c0             	movzbl %al,%eax
f01031ef:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f01031f3:	eb 06                	jmp    f01031fb <envid2env+0x6b>
		*env_store = curenv;
f01031f5:	8b 91 e8 1a 00 00    	mov    0x1ae8(%ecx),%edx
f01031fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031fe:	89 11                	mov    %edx,(%ecx)
}
f0103200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103203:	c9                   	leave  
f0103204:	c3                   	ret    
f0103205:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f010320a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010320f:	eb ea                	jmp    f01031fb <envid2env+0x6b>
f0103211:	ba 00 00 00 00       	mov    $0x0,%edx
f0103216:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010321b:	eb de                	jmp    f01031fb <envid2env+0x6b>

f010321d <env_init_percpu>:
{
f010321d:	e8 d7 d4 ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103222:	05 46 c6 07 00       	add    $0x7c646,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103227:	8d 80 98 17 00 00    	lea    0x1798(%eax),%eax
f010322d:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103230:	b8 23 00 00 00       	mov    $0x23,%eax
f0103235:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103237:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103239:	b8 10 00 00 00       	mov    $0x10,%eax
f010323e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103240:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103242:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103244:	ea 4b 32 10 f0 08 00 	ljmp   $0x8,$0xf010324b
	asm volatile("lldt %0" : : "r" (sel));
f010324b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103250:	0f 00 d0             	lldt   %ax
}
f0103253:	c3                   	ret    

f0103254 <env_init>:
{
f0103254:	55                   	push   %ebp
f0103255:	89 e5                	mov    %esp,%ebp
f0103257:	56                   	push   %esi
f0103258:	53                   	push   %ebx
f0103259:	e8 9f d4 ff ff       	call   f01006fd <__x86.get_pc_thunk.si>
f010325e:	81 c6 0a c6 07 00    	add    $0x7c60a,%esi
         envs[i].env_id = 0;
f0103264:	8b 9e ec 1a 00 00    	mov    0x1aec(%esi),%ebx
f010326a:	8d 83 a0 7f 01 00    	lea    0x17fa0(%ebx),%eax
f0103270:	ba 00 00 00 00       	mov    $0x0,%edx
f0103275:	89 d1                	mov    %edx,%ecx
f0103277:	89 c2                	mov    %eax,%edx
f0103279:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
         envs[i].env_parent_id = 0;
f0103280:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
         envs[i].env_type = ENV_TYPE_USER;
f0103287:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
         envs[i].env_status = ENV_FREE;
f010328e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
         envs[i].env_runs = 0;
f0103295:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
         envs[i].env_pgdir = NULL;
f010329c:	c7 40 5c 00 00 00 00 	movl   $0x0,0x5c(%eax)
         envs[i].env_link = env_free_list;
f01032a3:	89 48 44             	mov    %ecx,0x44(%eax)
     for (i = NENV -1; i >= 0; i--)
f01032a6:	83 e8 60             	sub    $0x60,%eax
f01032a9:	39 da                	cmp    %ebx,%edx
f01032ab:	75 c8                	jne    f0103275 <env_init+0x21>
f01032ad:	89 9e f0 1a 00 00    	mov    %ebx,0x1af0(%esi)
	env_init_percpu();
f01032b3:	e8 65 ff ff ff       	call   f010321d <env_init_percpu>
}
f01032b8:	5b                   	pop    %ebx
f01032b9:	5e                   	pop    %esi
f01032ba:	5d                   	pop    %ebp
f01032bb:	c3                   	ret    

f01032bc <env_alloc>:
{
f01032bc:	55                   	push   %ebp
f01032bd:	89 e5                	mov    %esp,%ebp
f01032bf:	57                   	push   %edi
f01032c0:	56                   	push   %esi
f01032c1:	53                   	push   %ebx
f01032c2:	83 ec 1c             	sub    $0x1c,%esp
f01032c5:	e8 9d ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01032ca:	81 c3 9e c5 07 00    	add    $0x7c59e,%ebx
	if (!(e = env_free_list))
f01032d0:	8b b3 f0 1a 00 00    	mov    0x1af0(%ebx),%esi
f01032d6:	85 f6                	test   %esi,%esi
f01032d8:	0f 84 60 01 00 00    	je     f010343e <env_alloc+0x182>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01032de:	83 ec 0c             	sub    $0xc,%esp
f01032e1:	6a 01                	push   $0x1
f01032e3:	e8 d2 db ff ff       	call   f0100eba <page_alloc>
f01032e8:	83 c4 10             	add    $0x10,%esp
f01032eb:	85 c0                	test   %eax,%eax
f01032ed:	0f 84 52 01 00 00    	je     f0103445 <env_alloc+0x189>
	return (pp - pages) << PGSHIFT;
f01032f3:	c7 c2 38 13 18 f0    	mov    $0xf0181338,%edx
f01032f9:	2b 02                	sub    (%edx),%eax
f01032fb:	c1 f8 03             	sar    $0x3,%eax
f01032fe:	89 c1                	mov    %eax,%ecx
f0103300:	c1 e1 0c             	shl    $0xc,%ecx
f0103303:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0103306:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010330b:	c7 c2 40 13 18 f0    	mov    $0xf0181340,%edx
f0103311:	3b 02                	cmp    (%edx),%eax
f0103313:	0f 83 f6 00 00 00    	jae    f010340f <env_alloc+0x153>
	return (void *)(pa + KERNBASE);
f0103319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010331c:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
     memcpy(page_dir, kern_pgdir, PGSIZE);
f0103322:	83 ec 04             	sub    $0x4,%esp
f0103325:	68 00 10 00 00       	push   $0x1000
f010332a:	c7 c0 3c 13 18 f0    	mov    $0xf018133c,%eax
f0103330:	ff 30                	push   (%eax)
f0103332:	57                   	push   %edi
f0103333:	e8 44 1c 00 00       	call   f0104f7c <memcpy>
     e->env_pgdir = page_dir;
f0103338:	89 7e 5c             	mov    %edi,0x5c(%esi)
	if ((uint32_t)kva < KERNBASE)
f010333b:	83 c4 10             	add    $0x10,%esp
f010333e:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0103344:	0f 86 db 00 00 00    	jbe    f0103425 <env_alloc+0x169>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010334a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010334d:	83 c8 05             	or     $0x5,%eax
f0103350:	89 87 f4 0e 00 00    	mov    %eax,0xef4(%edi)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103356:	8b 46 48             	mov    0x48(%esi),%eax
f0103359:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f010335e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103363:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103368:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010336b:	89 f2                	mov    %esi,%edx
f010336d:	2b 93 ec 1a 00 00    	sub    0x1aec(%ebx),%edx
f0103373:	c1 fa 05             	sar    $0x5,%edx
f0103376:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010337c:	09 d0                	or     %edx,%eax
f010337e:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103381:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103384:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103387:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f010338e:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103395:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010339c:	83 ec 04             	sub    $0x4,%esp
f010339f:	6a 44                	push   $0x44
f01033a1:	6a 00                	push   $0x0
f01033a3:	56                   	push   %esi
f01033a4:	e8 2b 1b 00 00       	call   f0104ed4 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01033a9:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01033af:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01033b5:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01033bb:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01033c2:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f01033c8:	8b 46 44             	mov    0x44(%esi),%eax
f01033cb:	89 83 f0 1a 00 00    	mov    %eax,0x1af0(%ebx)
	*newenv_store = e;
f01033d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01033d4:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033d6:	8b 4e 48             	mov    0x48(%esi),%ecx
f01033d9:	8b 83 e8 1a 00 00    	mov    0x1ae8(%ebx),%eax
f01033df:	83 c4 10             	add    $0x10,%esp
f01033e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01033e7:	85 c0                	test   %eax,%eax
f01033e9:	74 03                	je     f01033ee <env_alloc+0x132>
f01033eb:	8b 50 48             	mov    0x48(%eax),%edx
f01033ee:	83 ec 04             	sub    $0x4,%esp
f01033f1:	51                   	push   %ecx
f01033f2:	52                   	push   %edx
f01033f3:	8d 83 57 6a f8 ff    	lea    -0x795a9(%ebx),%eax
f01033f9:	50                   	push   %eax
f01033fa:	e8 48 05 00 00       	call   f0103947 <cprintf>
	return 0;
f01033ff:	83 c4 10             	add    $0x10,%esp
f0103402:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103407:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010340a:	5b                   	pop    %ebx
f010340b:	5e                   	pop    %esi
f010340c:	5f                   	pop    %edi
f010340d:	5d                   	pop    %ebp
f010340e:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010340f:	51                   	push   %ecx
f0103410:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f0103416:	50                   	push   %eax
f0103417:	6a 56                	push   $0x56
f0103419:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f010341f:	50                   	push   %eax
f0103420:	e8 8c cc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103425:	57                   	push   %edi
f0103426:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f010342c:	50                   	push   %eax
f010342d:	68 c8 00 00 00       	push   $0xc8
f0103432:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f0103438:	50                   	push   %eax
f0103439:	e8 73 cc ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f010343e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103443:	eb c2                	jmp    f0103407 <env_alloc+0x14b>
		return -E_NO_MEM;
f0103445:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010344a:	eb bb                	jmp    f0103407 <env_alloc+0x14b>

f010344c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010344c:	55                   	push   %ebp
f010344d:	89 e5                	mov    %esp,%ebp
f010344f:	57                   	push   %edi
f0103450:	56                   	push   %esi
f0103451:	53                   	push   %ebx
f0103452:	83 ec 34             	sub    $0x34,%esp
f0103455:	e8 0d cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010345a:	81 c3 0e c4 07 00    	add    $0x7c40e,%ebx
	// LAB 3: Your code here.
      struct Env *e = NULL;
f0103460:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
      int ret = 0;
      ret = env_alloc(&e, 0);
f0103467:	6a 00                	push   $0x0
f0103469:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010346c:	50                   	push   %eax
f010346d:	e8 4a fe ff ff       	call   f01032bc <env_alloc>
  
      if(ret < 0)
f0103472:	83 c4 10             	add    $0x10,%esp
f0103475:	85 c0                	test   %eax,%eax
f0103477:	78 3c                	js     f01034b5 <env_create+0x69>
     {
         panic("", ret);
     }
 
     load_icode(e, binary);
f0103479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010347c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     if(elfhdr->e_magic != ELF_MAGIC)
f010347f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103482:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103488:	75 44                	jne    f01034ce <env_create+0x82>
     ph = (struct Proghdr *)((uint8_t *)elfhdr + elfhdr->e_phoff);
f010348a:	8b 45 08             	mov    0x8(%ebp),%eax
f010348d:	89 c6                	mov    %eax,%esi
f010348f:	03 70 1c             	add    0x1c(%eax),%esi
     eph = ph + elfhdr->e_phnum;
f0103492:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f0103496:	c1 e7 05             	shl    $0x5,%edi
f0103499:	01 f7                	add    %esi,%edi
     lcr3(PADDR(e->env_pgdir));
f010349b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010349e:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01034a1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034a6:	76 41                	jbe    f01034e9 <env_create+0x9d>
	return (physaddr_t)kva - KERNBASE;
f01034a8:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01034ad:	0f 22 d8             	mov    %eax,%cr3
}
f01034b0:	e9 8a 00 00 00       	jmp    f010353f <env_create+0xf3>
         panic("", ret);
f01034b5:	50                   	push   %eax
f01034b6:	8d 83 0f 6a f8 ff    	lea    -0x795f1(%ebx),%eax
f01034bc:	50                   	push   %eax
f01034bd:	68 a0 01 00 00       	push   $0x1a0
f01034c2:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f01034c8:	50                   	push   %eax
f01034c9:	e8 e3 cb ff ff       	call   f01000b1 <_panic>
         panic("elf header wrong\n");
f01034ce:	83 ec 04             	sub    $0x4,%esp
f01034d1:	8d 83 6c 6a f8 ff    	lea    -0x79594(%ebx),%eax
f01034d7:	50                   	push   %eax
f01034d8:	68 70 01 00 00       	push   $0x170
f01034dd:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f01034e3:	50                   	push   %eax
f01034e4:	e8 c8 cb ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034e9:	50                   	push   %eax
f01034ea:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01034f0:	50                   	push   %eax
f01034f1:	68 74 01 00 00       	push   $0x174
f01034f6:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f01034fc:	50                   	push   %eax
f01034fd:	e8 af cb ff ff       	call   f01000b1 <_panic>
         region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103502:	8b 56 08             	mov    0x8(%esi),%edx
f0103505:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103508:	e8 e4 fb ff ff       	call   f01030f1 <region_alloc>
         memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010350d:	83 ec 04             	sub    $0x4,%esp
f0103510:	ff 76 10             	push   0x10(%esi)
f0103513:	8b 45 08             	mov    0x8(%ebp),%eax
f0103516:	03 46 04             	add    0x4(%esi),%eax
f0103519:	50                   	push   %eax
f010351a:	ff 76 08             	push   0x8(%esi)
f010351d:	e8 f8 19 00 00       	call   f0104f1a <memmove>
         memset((void *)ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz));
f0103522:	8b 46 10             	mov    0x10(%esi),%eax
f0103525:	83 c4 0c             	add    $0xc,%esp
f0103528:	8b 56 14             	mov    0x14(%esi),%edx
f010352b:	29 c2                	sub    %eax,%edx
f010352d:	52                   	push   %edx
f010352e:	6a 00                	push   $0x0
f0103530:	03 46 08             	add    0x8(%esi),%eax
f0103533:	50                   	push   %eax
f0103534:	e8 9b 19 00 00       	call   f0104ed4 <memset>
f0103539:	83 c4 10             	add    $0x10,%esp
     for(;ph < eph; ph++)
f010353c:	83 c6 20             	add    $0x20,%esi
f010353f:	39 f7                	cmp    %esi,%edi
f0103541:	76 28                	jbe    f010356b <env_create+0x11f>
         if(ph->p_type != ELF_PROG_LOAD)
f0103543:	83 3e 01             	cmpl   $0x1,(%esi)
f0103546:	75 f4                	jne    f010353c <env_create+0xf0>
         if(ph->p_filesz > ph->p_memsz)
f0103548:	8b 4e 14             	mov    0x14(%esi),%ecx
f010354b:	39 4e 10             	cmp    %ecx,0x10(%esi)
f010354e:	76 b2                	jbe    f0103502 <env_create+0xb6>
             panic("file size too big\n");
f0103550:	83 ec 04             	sub    $0x4,%esp
f0103553:	8d 83 7e 6a f8 ff    	lea    -0x79582(%ebx),%eax
f0103559:	50                   	push   %eax
f010355a:	68 7e 01 00 00       	push   $0x17e
f010355f:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f0103565:	50                   	push   %eax
f0103566:	e8 46 cb ff ff       	call   f01000b1 <_panic>
	lcr3(PADDR(kern_pgdir));
f010356b:	c7 c0 3c 13 18 f0    	mov    $0xf018133c,%eax
f0103571:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103573:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103578:	76 36                	jbe    f01035b0 <env_create+0x164>
	return (physaddr_t)kva - KERNBASE;
f010357a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010357f:	0f 22 d8             	mov    %eax,%cr3
     e->env_tf.tf_eip = elfhdr->e_entry;
f0103582:	8b 45 08             	mov    0x8(%ebp),%eax
f0103585:	8b 40 18             	mov    0x18(%eax),%eax
f0103588:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010358b:	89 47 30             	mov    %eax,0x30(%edi)
     region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010358e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103593:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103598:	89 f8                	mov    %edi,%eax
f010359a:	e8 52 fb ff ff       	call   f01030f1 <region_alloc>
     e->env_type = type;
f010359f:	8b 55 0c             	mov    0xc(%ebp),%edx
f01035a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035a5:	89 50 50             	mov    %edx,0x50(%eax)
}
f01035a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035ab:	5b                   	pop    %ebx
f01035ac:	5e                   	pop    %esi
f01035ad:	5f                   	pop    %edi
f01035ae:	5d                   	pop    %ebp
f01035af:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035b0:	50                   	push   %eax
f01035b1:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01035b7:	50                   	push   %eax
f01035b8:	68 8a 01 00 00       	push   $0x18a
f01035bd:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f01035c3:	50                   	push   %eax
f01035c4:	e8 e8 ca ff ff       	call   f01000b1 <_panic>

f01035c9 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01035c9:	55                   	push   %ebp
f01035ca:	89 e5                	mov    %esp,%ebp
f01035cc:	57                   	push   %edi
f01035cd:	56                   	push   %esi
f01035ce:	53                   	push   %ebx
f01035cf:	83 ec 2c             	sub    $0x2c,%esp
f01035d2:	e8 90 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035d7:	81 c3 91 c2 07 00    	add    $0x7c291,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01035dd:	8b 93 e8 1a 00 00    	mov    0x1ae8(%ebx),%edx
f01035e3:	3b 55 08             	cmp    0x8(%ebp),%edx
f01035e6:	74 47                	je     f010362f <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01035eb:	8b 48 48             	mov    0x48(%eax),%ecx
f01035ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01035f3:	85 d2                	test   %edx,%edx
f01035f5:	74 03                	je     f01035fa <env_free+0x31>
f01035f7:	8b 42 48             	mov    0x48(%edx),%eax
f01035fa:	83 ec 04             	sub    $0x4,%esp
f01035fd:	51                   	push   %ecx
f01035fe:	50                   	push   %eax
f01035ff:	8d 83 91 6a f8 ff    	lea    -0x7956f(%ebx),%eax
f0103605:	50                   	push   %eax
f0103606:	e8 3c 03 00 00       	call   f0103947 <cprintf>
f010360b:	83 c4 10             	add    $0x10,%esp
f010360e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0103615:	c7 c0 40 13 18 f0    	mov    $0xf0181340,%eax
f010361b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f010361e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f0103621:	c7 c0 38 13 18 f0    	mov    $0xf0181338,%eax
f0103627:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010362a:	e9 bf 00 00 00       	jmp    f01036ee <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f010362f:	c7 c0 3c 13 18 f0    	mov    $0xf018133c,%eax
f0103635:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103637:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010363c:	76 10                	jbe    f010364e <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f010363e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103643:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103646:	8b 45 08             	mov    0x8(%ebp),%eax
f0103649:	8b 48 48             	mov    0x48(%eax),%ecx
f010364c:	eb a9                	jmp    f01035f7 <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010364e:	50                   	push   %eax
f010364f:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f0103655:	50                   	push   %eax
f0103656:	68 b5 01 00 00       	push   $0x1b5
f010365b:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f0103661:	50                   	push   %eax
f0103662:	e8 4a ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103667:	57                   	push   %edi
f0103668:	8d 83 1c 5f f8 ff    	lea    -0x7a0e4(%ebx),%eax
f010366e:	50                   	push   %eax
f010366f:	68 c4 01 00 00       	push   $0x1c4
f0103674:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f010367a:	50                   	push   %eax
f010367b:	e8 31 ca ff ff       	call   f01000b1 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103680:	83 c7 04             	add    $0x4,%edi
f0103683:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103689:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f010368f:	74 1e                	je     f01036af <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f0103691:	f6 07 01             	testb  $0x1,(%edi)
f0103694:	74 ea                	je     f0103680 <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103696:	83 ec 08             	sub    $0x8,%esp
f0103699:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010369c:	09 f0                	or     %esi,%eax
f010369e:	50                   	push   %eax
f010369f:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a2:	ff 70 5c             	push   0x5c(%eax)
f01036a5:	e8 af da ff ff       	call   f0101159 <page_remove>
f01036aa:	83 c4 10             	add    $0x10,%esp
f01036ad:	eb d1                	jmp    f0103680 <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01036af:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b2:	8b 40 5c             	mov    0x5c(%eax),%eax
f01036b5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036b8:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01036bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01036c5:	3b 10                	cmp    (%eax),%edx
f01036c7:	73 67                	jae    f0103730 <env_free+0x167>
		page_decref(pa2page(pa));
f01036c9:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01036cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036cf:	8b 00                	mov    (%eax),%eax
f01036d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01036d4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01036d7:	50                   	push   %eax
f01036d8:	e8 cc d8 ff ff       	call   f0100fa9 <page_decref>
f01036dd:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01036e0:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01036e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036e7:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01036ec:	74 5a                	je     f0103748 <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01036ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f1:	8b 40 5c             	mov    0x5c(%eax),%eax
f01036f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01036f7:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01036fa:	a8 01                	test   $0x1,%al
f01036fc:	74 e2                	je     f01036e0 <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036fe:	89 c7                	mov    %eax,%edi
f0103700:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0103706:	c1 e8 0c             	shr    $0xc,%eax
f0103709:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010370c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010370f:	3b 02                	cmp    (%edx),%eax
f0103711:	0f 83 50 ff ff ff    	jae    f0103667 <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f0103717:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f010371d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103720:	c1 e0 14             	shl    $0x14,%eax
f0103723:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103726:	be 00 00 00 00       	mov    $0x0,%esi
f010372b:	e9 61 ff ff ff       	jmp    f0103691 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f0103730:	83 ec 04             	sub    $0x4,%esp
f0103733:	8d 83 88 60 f8 ff    	lea    -0x79f78(%ebx),%eax
f0103739:	50                   	push   %eax
f010373a:	6a 4f                	push   $0x4f
f010373c:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f0103742:	50                   	push   %eax
f0103743:	e8 69 c9 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103748:	8b 45 08             	mov    0x8(%ebp),%eax
f010374b:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010374e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103753:	76 57                	jbe    f01037ac <env_free+0x1e3>
	e->env_pgdir = 0;
f0103755:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103758:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f010375f:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103764:	c1 e8 0c             	shr    $0xc,%eax
f0103767:	c7 c2 40 13 18 f0    	mov    $0xf0181340,%edx
f010376d:	3b 02                	cmp    (%edx),%eax
f010376f:	73 54                	jae    f01037c5 <env_free+0x1fc>
	page_decref(pa2page(pa));
f0103771:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103774:	c7 c2 38 13 18 f0    	mov    $0xf0181338,%edx
f010377a:	8b 12                	mov    (%edx),%edx
f010377c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010377f:	50                   	push   %eax
f0103780:	e8 24 d8 ff ff       	call   f0100fa9 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103785:	8b 45 08             	mov    0x8(%ebp),%eax
f0103788:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010378f:	8b 83 f0 1a 00 00    	mov    0x1af0(%ebx),%eax
f0103795:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103798:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f010379b:	89 8b f0 1a 00 00    	mov    %ecx,0x1af0(%ebx)
}
f01037a1:	83 c4 10             	add    $0x10,%esp
f01037a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037a7:	5b                   	pop    %ebx
f01037a8:	5e                   	pop    %esi
f01037a9:	5f                   	pop    %edi
f01037aa:	5d                   	pop    %ebp
f01037ab:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037ac:	50                   	push   %eax
f01037ad:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01037b3:	50                   	push   %eax
f01037b4:	68 d2 01 00 00       	push   $0x1d2
f01037b9:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f01037bf:	50                   	push   %eax
f01037c0:	e8 ec c8 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f01037c5:	83 ec 04             	sub    $0x4,%esp
f01037c8:	8d 83 88 60 f8 ff    	lea    -0x79f78(%ebx),%eax
f01037ce:	50                   	push   %eax
f01037cf:	6a 4f                	push   $0x4f
f01037d1:	8d 83 69 67 f8 ff    	lea    -0x79897(%ebx),%eax
f01037d7:	50                   	push   %eax
f01037d8:	e8 d4 c8 ff ff       	call   f01000b1 <_panic>

f01037dd <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01037dd:	55                   	push   %ebp
f01037de:	89 e5                	mov    %esp,%ebp
f01037e0:	53                   	push   %ebx
f01037e1:	83 ec 10             	sub    $0x10,%esp
f01037e4:	e8 7e c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01037e9:	81 c3 7f c0 07 00    	add    $0x7c07f,%ebx
	env_free(e);
f01037ef:	ff 75 08             	push   0x8(%ebp)
f01037f2:	e8 d2 fd ff ff       	call   f01035c9 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01037f7:	8d 83 b4 6a f8 ff    	lea    -0x7954c(%ebx),%eax
f01037fd:	89 04 24             	mov    %eax,(%esp)
f0103800:	e8 42 01 00 00       	call   f0103947 <cprintf>
f0103805:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103808:	83 ec 0c             	sub    $0xc,%esp
f010380b:	6a 00                	push   $0x0
f010380d:	e8 16 d0 ff ff       	call   f0100828 <monitor>
f0103812:	83 c4 10             	add    $0x10,%esp
f0103815:	eb f1                	jmp    f0103808 <env_destroy+0x2b>

f0103817 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103817:	55                   	push   %ebp
f0103818:	89 e5                	mov    %esp,%ebp
f010381a:	53                   	push   %ebx
f010381b:	83 ec 08             	sub    $0x8,%esp
f010381e:	e8 44 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103823:	81 c3 45 c0 07 00    	add    $0x7c045,%ebx
	asm volatile(
f0103829:	8b 65 08             	mov    0x8(%ebp),%esp
f010382c:	61                   	popa   
f010382d:	07                   	pop    %es
f010382e:	1f                   	pop    %ds
f010382f:	83 c4 08             	add    $0x8,%esp
f0103832:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103833:	8d 83 a7 6a f8 ff    	lea    -0x79559(%ebx),%eax
f0103839:	50                   	push   %eax
f010383a:	68 fb 01 00 00       	push   $0x1fb
f010383f:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f0103845:	50                   	push   %eax
f0103846:	e8 66 c8 ff ff       	call   f01000b1 <_panic>

f010384b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010384b:	55                   	push   %ebp
f010384c:	89 e5                	mov    %esp,%ebp
f010384e:	53                   	push   %ebx
f010384f:	83 ec 04             	sub    $0x4,%esp
f0103852:	e8 10 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103857:	81 c3 11 c0 07 00    	add    $0x7c011,%ebx
f010385d:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv !=NULL && curenv->env_status == ENV_RUNNING)
f0103860:	8b 93 e8 1a 00 00    	mov    0x1ae8(%ebx),%edx
f0103866:	85 d2                	test   %edx,%edx
f0103868:	74 06                	je     f0103870 <env_run+0x25>
f010386a:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f010386e:	74 2e                	je     f010389e <env_run+0x53>
     {
         curenv->env_status = ENV_RUNNABLE;
     }
     curenv = e;
f0103870:	89 83 e8 1a 00 00    	mov    %eax,0x1ae8(%ebx)
     e->env_status = ENV_RUNNING;
f0103876:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
     e->env_runs++;
f010387d:	83 40 58 01          	addl   $0x1,0x58(%eax)
     lcr3(PADDR(e->env_pgdir));
f0103881:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103884:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010388a:	76 1b                	jbe    f01038a7 <env_run+0x5c>
	return (physaddr_t)kva - KERNBASE;
f010388c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103892:	0f 22 da             	mov    %edx,%cr3
     env_pop_tf(&(e->env_tf));
f0103895:	83 ec 0c             	sub    $0xc,%esp
f0103898:	50                   	push   %eax
f0103899:	e8 79 ff ff ff       	call   f0103817 <env_pop_tf>
         curenv->env_status = ENV_RUNNABLE;
f010389e:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f01038a5:	eb c9                	jmp    f0103870 <env_run+0x25>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038a7:	52                   	push   %edx
f01038a8:	8d 83 e4 60 f8 ff    	lea    -0x79f1c(%ebx),%eax
f01038ae:	50                   	push   %eax
f01038af:	68 20 02 00 00       	push   $0x220
f01038b4:	8d 83 4c 6a f8 ff    	lea    -0x795b4(%ebx),%eax
f01038ba:	50                   	push   %eax
f01038bb:	e8 f1 c7 ff ff       	call   f01000b1 <_panic>

f01038c0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01038c0:	55                   	push   %ebp
f01038c1:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01038c6:	ba 70 00 00 00       	mov    $0x70,%edx
f01038cb:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01038cc:	ba 71 00 00 00       	mov    $0x71,%edx
f01038d1:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01038d2:	0f b6 c0             	movzbl %al,%eax
}
f01038d5:	5d                   	pop    %ebp
f01038d6:	c3                   	ret    

f01038d7 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01038d7:	55                   	push   %ebp
f01038d8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01038da:	8b 45 08             	mov    0x8(%ebp),%eax
f01038dd:	ba 70 00 00 00       	mov    $0x70,%edx
f01038e2:	ee                   	out    %al,(%dx)
f01038e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038e6:	ba 71 00 00 00       	mov    $0x71,%edx
f01038eb:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01038ec:	5d                   	pop    %ebp
f01038ed:	c3                   	ret    

f01038ee <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038ee:	55                   	push   %ebp
f01038ef:	89 e5                	mov    %esp,%ebp
f01038f1:	53                   	push   %ebx
f01038f2:	83 ec 10             	sub    $0x10,%esp
f01038f5:	e8 6d c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038fa:	81 c3 6e bf 07 00    	add    $0x7bf6e,%ebx
	cputchar(ch);
f0103900:	ff 75 08             	push   0x8(%ebp)
f0103903:	e8 ca cd ff ff       	call   f01006d2 <cputchar>
	*cnt++;
}
f0103908:	83 c4 10             	add    $0x10,%esp
f010390b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010390e:	c9                   	leave  
f010390f:	c3                   	ret    

f0103910 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103910:	55                   	push   %ebp
f0103911:	89 e5                	mov    %esp,%ebp
f0103913:	53                   	push   %ebx
f0103914:	83 ec 14             	sub    $0x14,%esp
f0103917:	e8 4b c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010391c:	81 c3 4c bf 07 00    	add    $0x7bf4c,%ebx
	int cnt = 0;
f0103922:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103929:	ff 75 0c             	push   0xc(%ebp)
f010392c:	ff 75 08             	push   0x8(%ebp)
f010392f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103932:	50                   	push   %eax
f0103933:	8d 83 86 40 f8 ff    	lea    -0x7bf7a(%ebx),%eax
f0103939:	50                   	push   %eax
f010393a:	e8 20 0e 00 00       	call   f010475f <vprintfmt>
	return cnt;
}
f010393f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103945:	c9                   	leave  
f0103946:	c3                   	ret    

f0103947 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103947:	55                   	push   %ebp
f0103948:	89 e5                	mov    %esp,%ebp
f010394a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010394d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103950:	50                   	push   %eax
f0103951:	ff 75 08             	push   0x8(%ebp)
f0103954:	e8 b7 ff ff ff       	call   f0103910 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103959:	c9                   	leave  
f010395a:	c3                   	ret    

f010395b <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010395b:	55                   	push   %ebp
f010395c:	89 e5                	mov    %esp,%ebp
f010395e:	57                   	push   %edi
f010395f:	56                   	push   %esi
f0103960:	53                   	push   %ebx
f0103961:	83 ec 04             	sub    $0x4,%esp
f0103964:	e8 fe c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103969:	81 c3 ff be 07 00    	add    $0x7beff,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010396f:	c7 83 1c 23 00 00 00 	movl   $0xf0000000,0x231c(%ebx)
f0103976:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103979:	66 c7 83 20 23 00 00 	movw   $0x10,0x2320(%ebx)
f0103980:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103982:	66 c7 83 7e 23 00 00 	movw   $0x68,0x237e(%ebx)
f0103989:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010398b:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103991:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103997:	8d b3 18 23 00 00    	lea    0x2318(%ebx),%esi
f010399d:	66 89 70 2a          	mov    %si,0x2a(%eax)
f01039a1:	89 f2                	mov    %esi,%edx
f01039a3:	c1 ea 10             	shr    $0x10,%edx
f01039a6:	88 50 2c             	mov    %dl,0x2c(%eax)
f01039a9:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f01039ad:	83 e2 f0             	and    $0xfffffff0,%edx
f01039b0:	83 ca 09             	or     $0x9,%edx
f01039b3:	83 e2 9f             	and    $0xffffff9f,%edx
f01039b6:	83 ca 80             	or     $0xffffff80,%edx
f01039b9:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01039bc:	88 50 2d             	mov    %dl,0x2d(%eax)
f01039bf:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01039c3:	83 e1 c0             	and    $0xffffffc0,%ecx
f01039c6:	83 c9 40             	or     $0x40,%ecx
f01039c9:	83 e1 7f             	and    $0x7f,%ecx
f01039cc:	88 48 2e             	mov    %cl,0x2e(%eax)
f01039cf:	c1 ee 18             	shr    $0x18,%esi
f01039d2:	89 f1                	mov    %esi,%ecx
f01039d4:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01039d7:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01039db:	83 e2 ef             	and    $0xffffffef,%edx
f01039de:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01039e1:	b8 28 00 00 00       	mov    $0x28,%eax
f01039e6:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01039e9:	8d 83 a0 17 00 00    	lea    0x17a0(%ebx),%eax
f01039ef:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01039f2:	83 c4 04             	add    $0x4,%esp
f01039f5:	5b                   	pop    %ebx
f01039f6:	5e                   	pop    %esi
f01039f7:	5f                   	pop    %edi
f01039f8:	5d                   	pop    %ebp
f01039f9:	c3                   	ret    

f01039fa <trap_init>:
{
f01039fa:	55                   	push   %ebp
f01039fb:	89 e5                	mov    %esp,%ebp
f01039fd:	e8 f7 cc ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f0103a02:	05 66 be 07 00       	add    $0x7be66,%eax
    SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0); 
f0103a07:	c7 c2 c2 41 10 f0    	mov    $0xf01041c2,%edx
f0103a0d:	66 89 90 f8 1a 00 00 	mov    %dx,0x1af8(%eax)
f0103a14:	66 c7 80 fa 1a 00 00 	movw   $0x8,0x1afa(%eax)
f0103a1b:	08 00 
f0103a1d:	c6 80 fc 1a 00 00 00 	movb   $0x0,0x1afc(%eax)
f0103a24:	c6 80 fd 1a 00 00 8e 	movb   $0x8e,0x1afd(%eax)
f0103a2b:	c1 ea 10             	shr    $0x10,%edx
f0103a2e:	66 89 90 fe 1a 00 00 	mov    %dx,0x1afe(%eax)
    SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0); 
f0103a35:	c7 c2 c8 41 10 f0    	mov    $0xf01041c8,%edx
f0103a3b:	66 89 90 00 1b 00 00 	mov    %dx,0x1b00(%eax)
f0103a42:	66 c7 80 02 1b 00 00 	movw   $0x8,0x1b02(%eax)
f0103a49:	08 00 
f0103a4b:	c6 80 04 1b 00 00 00 	movb   $0x0,0x1b04(%eax)
f0103a52:	c6 80 05 1b 00 00 8e 	movb   $0x8e,0x1b05(%eax)
f0103a59:	c1 ea 10             	shr    $0x10,%edx
f0103a5c:	66 89 90 06 1b 00 00 	mov    %dx,0x1b06(%eax)
    SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0); 
f0103a63:	c7 c2 ce 41 10 f0    	mov    $0xf01041ce,%edx
f0103a69:	66 89 90 08 1b 00 00 	mov    %dx,0x1b08(%eax)
f0103a70:	66 c7 80 0a 1b 00 00 	movw   $0x8,0x1b0a(%eax)
f0103a77:	08 00 
f0103a79:	c6 80 0c 1b 00 00 00 	movb   $0x0,0x1b0c(%eax)
f0103a80:	c6 80 0d 1b 00 00 8e 	movb   $0x8e,0x1b0d(%eax)
f0103a87:	c1 ea 10             	shr    $0x10,%edx
f0103a8a:	66 89 90 0e 1b 00 00 	mov    %dx,0x1b0e(%eax)
    SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3); 
f0103a91:	c7 c2 d4 41 10 f0    	mov    $0xf01041d4,%edx
f0103a97:	66 89 90 10 1b 00 00 	mov    %dx,0x1b10(%eax)
f0103a9e:	66 c7 80 12 1b 00 00 	movw   $0x8,0x1b12(%eax)
f0103aa5:	08 00 
f0103aa7:	c6 80 14 1b 00 00 00 	movb   $0x0,0x1b14(%eax)
f0103aae:	c6 80 15 1b 00 00 ee 	movb   $0xee,0x1b15(%eax)
f0103ab5:	c1 ea 10             	shr    $0x10,%edx
f0103ab8:	66 89 90 16 1b 00 00 	mov    %dx,0x1b16(%eax)
    SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0); 
f0103abf:	c7 c2 da 41 10 f0    	mov    $0xf01041da,%edx
f0103ac5:	66 89 90 18 1b 00 00 	mov    %dx,0x1b18(%eax)
f0103acc:	66 c7 80 1a 1b 00 00 	movw   $0x8,0x1b1a(%eax)
f0103ad3:	08 00 
f0103ad5:	c6 80 1c 1b 00 00 00 	movb   $0x0,0x1b1c(%eax)
f0103adc:	c6 80 1d 1b 00 00 8e 	movb   $0x8e,0x1b1d(%eax)
f0103ae3:	c1 ea 10             	shr    $0x10,%edx
f0103ae6:	66 89 90 1e 1b 00 00 	mov    %dx,0x1b1e(%eax)
    SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0); 
f0103aed:	c7 c2 e0 41 10 f0    	mov    $0xf01041e0,%edx
f0103af3:	66 89 90 20 1b 00 00 	mov    %dx,0x1b20(%eax)
f0103afa:	66 c7 80 22 1b 00 00 	movw   $0x8,0x1b22(%eax)
f0103b01:	08 00 
f0103b03:	c6 80 24 1b 00 00 00 	movb   $0x0,0x1b24(%eax)
f0103b0a:	c6 80 25 1b 00 00 8e 	movb   $0x8e,0x1b25(%eax)
f0103b11:	c1 ea 10             	shr    $0x10,%edx
f0103b14:	66 89 90 26 1b 00 00 	mov    %dx,0x1b26(%eax)
    SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0); 
f0103b1b:	c7 c2 e6 41 10 f0    	mov    $0xf01041e6,%edx
f0103b21:	66 89 90 28 1b 00 00 	mov    %dx,0x1b28(%eax)
f0103b28:	66 c7 80 2a 1b 00 00 	movw   $0x8,0x1b2a(%eax)
f0103b2f:	08 00 
f0103b31:	c6 80 2c 1b 00 00 00 	movb   $0x0,0x1b2c(%eax)
f0103b38:	c6 80 2d 1b 00 00 8e 	movb   $0x8e,0x1b2d(%eax)
f0103b3f:	c1 ea 10             	shr    $0x10,%edx
f0103b42:	66 89 90 2e 1b 00 00 	mov    %dx,0x1b2e(%eax)
    SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0); 
f0103b49:	c7 c2 ec 41 10 f0    	mov    $0xf01041ec,%edx
f0103b4f:	66 89 90 30 1b 00 00 	mov    %dx,0x1b30(%eax)
f0103b56:	66 c7 80 32 1b 00 00 	movw   $0x8,0x1b32(%eax)
f0103b5d:	08 00 
f0103b5f:	c6 80 34 1b 00 00 00 	movb   $0x0,0x1b34(%eax)
f0103b66:	c6 80 35 1b 00 00 8e 	movb   $0x8e,0x1b35(%eax)
f0103b6d:	c1 ea 10             	shr    $0x10,%edx
f0103b70:	66 89 90 36 1b 00 00 	mov    %dx,0x1b36(%eax)
    SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0); 
f0103b77:	c7 c2 f2 41 10 f0    	mov    $0xf01041f2,%edx
f0103b7d:	66 89 90 38 1b 00 00 	mov    %dx,0x1b38(%eax)
f0103b84:	66 c7 80 3a 1b 00 00 	movw   $0x8,0x1b3a(%eax)
f0103b8b:	08 00 
f0103b8d:	c6 80 3c 1b 00 00 00 	movb   $0x0,0x1b3c(%eax)
f0103b94:	c6 80 3d 1b 00 00 8e 	movb   $0x8e,0x1b3d(%eax)
f0103b9b:	c1 ea 10             	shr    $0x10,%edx
f0103b9e:	66 89 90 3e 1b 00 00 	mov    %dx,0x1b3e(%eax)
    SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0); 
f0103ba5:	c7 c2 f6 41 10 f0    	mov    $0xf01041f6,%edx
f0103bab:	66 89 90 48 1b 00 00 	mov    %dx,0x1b48(%eax)
f0103bb2:	66 c7 80 4a 1b 00 00 	movw   $0x8,0x1b4a(%eax)
f0103bb9:	08 00 
f0103bbb:	c6 80 4c 1b 00 00 00 	movb   $0x0,0x1b4c(%eax)
f0103bc2:	c6 80 4d 1b 00 00 8e 	movb   $0x8e,0x1b4d(%eax)
f0103bc9:	c1 ea 10             	shr    $0x10,%edx
f0103bcc:	66 89 90 4e 1b 00 00 	mov    %dx,0x1b4e(%eax)
    SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0); 
f0103bd3:	c7 c2 fa 41 10 f0    	mov    $0xf01041fa,%edx
f0103bd9:	66 89 90 50 1b 00 00 	mov    %dx,0x1b50(%eax)
f0103be0:	66 c7 80 52 1b 00 00 	movw   $0x8,0x1b52(%eax)
f0103be7:	08 00 
f0103be9:	c6 80 54 1b 00 00 00 	movb   $0x0,0x1b54(%eax)
f0103bf0:	c6 80 55 1b 00 00 8e 	movb   $0x8e,0x1b55(%eax)
f0103bf7:	c1 ea 10             	shr    $0x10,%edx
f0103bfa:	66 89 90 56 1b 00 00 	mov    %dx,0x1b56(%eax)
    SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0); 
f0103c01:	c7 c2 00 42 10 f0    	mov    $0xf0104200,%edx
f0103c07:	66 89 90 58 1b 00 00 	mov    %dx,0x1b58(%eax)
f0103c0e:	66 c7 80 5a 1b 00 00 	movw   $0x8,0x1b5a(%eax)
f0103c15:	08 00 
f0103c17:	c6 80 5c 1b 00 00 00 	movb   $0x0,0x1b5c(%eax)
f0103c1e:	c6 80 5d 1b 00 00 8e 	movb   $0x8e,0x1b5d(%eax)
f0103c25:	c1 ea 10             	shr    $0x10,%edx
f0103c28:	66 89 90 5e 1b 00 00 	mov    %dx,0x1b5e(%eax)
    SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0); 
f0103c2f:	c7 c2 04 42 10 f0    	mov    $0xf0104204,%edx
f0103c35:	66 89 90 60 1b 00 00 	mov    %dx,0x1b60(%eax)
f0103c3c:	66 c7 80 62 1b 00 00 	movw   $0x8,0x1b62(%eax)
f0103c43:	08 00 
f0103c45:	c6 80 64 1b 00 00 00 	movb   $0x0,0x1b64(%eax)
f0103c4c:	c6 80 65 1b 00 00 8e 	movb   $0x8e,0x1b65(%eax)
f0103c53:	c1 ea 10             	shr    $0x10,%edx
f0103c56:	66 89 90 66 1b 00 00 	mov    %dx,0x1b66(%eax)
    SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0); 
f0103c5d:	c7 c2 08 42 10 f0    	mov    $0xf0104208,%edx
f0103c63:	66 89 90 68 1b 00 00 	mov    %dx,0x1b68(%eax)
f0103c6a:	66 c7 80 6a 1b 00 00 	movw   $0x8,0x1b6a(%eax)
f0103c71:	08 00 
f0103c73:	c6 80 6c 1b 00 00 00 	movb   $0x0,0x1b6c(%eax)
f0103c7a:	c6 80 6d 1b 00 00 8e 	movb   $0x8e,0x1b6d(%eax)
f0103c81:	c1 ea 10             	shr    $0x10,%edx
f0103c84:	66 89 90 6e 1b 00 00 	mov    %dx,0x1b6e(%eax)
    SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0); 
f0103c8b:	c7 c2 0c 42 10 f0    	mov    $0xf010420c,%edx
f0103c91:	66 89 90 78 1b 00 00 	mov    %dx,0x1b78(%eax)
f0103c98:	66 c7 80 7a 1b 00 00 	movw   $0x8,0x1b7a(%eax)
f0103c9f:	08 00 
f0103ca1:	c6 80 7c 1b 00 00 00 	movb   $0x0,0x1b7c(%eax)
f0103ca8:	c6 80 7d 1b 00 00 8e 	movb   $0x8e,0x1b7d(%eax)
f0103caf:	c1 ea 10             	shr    $0x10,%edx
f0103cb2:	66 89 90 7e 1b 00 00 	mov    %dx,0x1b7e(%eax)
    SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0); 
f0103cb9:	c7 c2 12 42 10 f0    	mov    $0xf0104212,%edx
f0103cbf:	66 89 90 80 1b 00 00 	mov    %dx,0x1b80(%eax)
f0103cc6:	66 c7 80 82 1b 00 00 	movw   $0x8,0x1b82(%eax)
f0103ccd:	08 00 
f0103ccf:	c6 80 84 1b 00 00 00 	movb   $0x0,0x1b84(%eax)
f0103cd6:	c6 80 85 1b 00 00 8e 	movb   $0x8e,0x1b85(%eax)
f0103cdd:	c1 ea 10             	shr    $0x10,%edx
f0103ce0:	66 89 90 86 1b 00 00 	mov    %dx,0x1b86(%eax)
    SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0); 
f0103ce7:	c7 c2 16 42 10 f0    	mov    $0xf0104216,%edx
f0103ced:	66 89 90 88 1b 00 00 	mov    %dx,0x1b88(%eax)
f0103cf4:	66 c7 80 8a 1b 00 00 	movw   $0x8,0x1b8a(%eax)
f0103cfb:	08 00 
f0103cfd:	c6 80 8c 1b 00 00 00 	movb   $0x0,0x1b8c(%eax)
f0103d04:	c6 80 8d 1b 00 00 8e 	movb   $0x8e,0x1b8d(%eax)
f0103d0b:	c1 ea 10             	shr    $0x10,%edx
f0103d0e:	66 89 90 8e 1b 00 00 	mov    %dx,0x1b8e(%eax)
    SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0); 
f0103d15:	c7 c2 1c 42 10 f0    	mov    $0xf010421c,%edx
f0103d1b:	66 89 90 90 1b 00 00 	mov    %dx,0x1b90(%eax)
f0103d22:	66 c7 80 92 1b 00 00 	movw   $0x8,0x1b92(%eax)
f0103d29:	08 00 
f0103d2b:	c6 80 94 1b 00 00 00 	movb   $0x0,0x1b94(%eax)
f0103d32:	c6 80 95 1b 00 00 8e 	movb   $0x8e,0x1b95(%eax)
f0103d39:	c1 ea 10             	shr    $0x10,%edx
f0103d3c:	66 89 90 96 1b 00 00 	mov    %dx,0x1b96(%eax)
    SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3); 
f0103d43:	c7 c2 22 42 10 f0    	mov    $0xf0104222,%edx
f0103d49:	66 89 90 78 1c 00 00 	mov    %dx,0x1c78(%eax)
f0103d50:	66 c7 80 7a 1c 00 00 	movw   $0x8,0x1c7a(%eax)
f0103d57:	08 00 
f0103d59:	c6 80 7c 1c 00 00 00 	movb   $0x0,0x1c7c(%eax)
f0103d60:	c6 80 7d 1c 00 00 ee 	movb   $0xee,0x1c7d(%eax)
f0103d67:	c1 ea 10             	shr    $0x10,%edx
f0103d6a:	66 89 90 7e 1c 00 00 	mov    %dx,0x1c7e(%eax)
	trap_init_percpu();
f0103d71:	e8 e5 fb ff ff       	call   f010395b <trap_init_percpu>
}
f0103d76:	5d                   	pop    %ebp
f0103d77:	c3                   	ret    

f0103d78 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d78:	55                   	push   %ebp
f0103d79:	89 e5                	mov    %esp,%ebp
f0103d7b:	56                   	push   %esi
f0103d7c:	53                   	push   %ebx
f0103d7d:	e8 e5 c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d82:	81 c3 e6 ba 07 00    	add    $0x7bae6,%ebx
f0103d88:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d8b:	83 ec 08             	sub    $0x8,%esp
f0103d8e:	ff 36                	push   (%esi)
f0103d90:	8d 83 ea 6a f8 ff    	lea    -0x79516(%ebx),%eax
f0103d96:	50                   	push   %eax
f0103d97:	e8 ab fb ff ff       	call   f0103947 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d9c:	83 c4 08             	add    $0x8,%esp
f0103d9f:	ff 76 04             	push   0x4(%esi)
f0103da2:	8d 83 f9 6a f8 ff    	lea    -0x79507(%ebx),%eax
f0103da8:	50                   	push   %eax
f0103da9:	e8 99 fb ff ff       	call   f0103947 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103dae:	83 c4 08             	add    $0x8,%esp
f0103db1:	ff 76 08             	push   0x8(%esi)
f0103db4:	8d 83 08 6b f8 ff    	lea    -0x794f8(%ebx),%eax
f0103dba:	50                   	push   %eax
f0103dbb:	e8 87 fb ff ff       	call   f0103947 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103dc0:	83 c4 08             	add    $0x8,%esp
f0103dc3:	ff 76 0c             	push   0xc(%esi)
f0103dc6:	8d 83 17 6b f8 ff    	lea    -0x794e9(%ebx),%eax
f0103dcc:	50                   	push   %eax
f0103dcd:	e8 75 fb ff ff       	call   f0103947 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103dd2:	83 c4 08             	add    $0x8,%esp
f0103dd5:	ff 76 10             	push   0x10(%esi)
f0103dd8:	8d 83 26 6b f8 ff    	lea    -0x794da(%ebx),%eax
f0103dde:	50                   	push   %eax
f0103ddf:	e8 63 fb ff ff       	call   f0103947 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103de4:	83 c4 08             	add    $0x8,%esp
f0103de7:	ff 76 14             	push   0x14(%esi)
f0103dea:	8d 83 35 6b f8 ff    	lea    -0x794cb(%ebx),%eax
f0103df0:	50                   	push   %eax
f0103df1:	e8 51 fb ff ff       	call   f0103947 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103df6:	83 c4 08             	add    $0x8,%esp
f0103df9:	ff 76 18             	push   0x18(%esi)
f0103dfc:	8d 83 44 6b f8 ff    	lea    -0x794bc(%ebx),%eax
f0103e02:	50                   	push   %eax
f0103e03:	e8 3f fb ff ff       	call   f0103947 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e08:	83 c4 08             	add    $0x8,%esp
f0103e0b:	ff 76 1c             	push   0x1c(%esi)
f0103e0e:	8d 83 53 6b f8 ff    	lea    -0x794ad(%ebx),%eax
f0103e14:	50                   	push   %eax
f0103e15:	e8 2d fb ff ff       	call   f0103947 <cprintf>
}
f0103e1a:	83 c4 10             	add    $0x10,%esp
f0103e1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e20:	5b                   	pop    %ebx
f0103e21:	5e                   	pop    %esi
f0103e22:	5d                   	pop    %ebp
f0103e23:	c3                   	ret    

f0103e24 <print_trapframe>:
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
f0103e27:	57                   	push   %edi
f0103e28:	56                   	push   %esi
f0103e29:	53                   	push   %ebx
f0103e2a:	83 ec 14             	sub    $0x14,%esp
f0103e2d:	e8 35 c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103e32:	81 c3 36 ba 07 00    	add    $0x7ba36,%ebx
f0103e38:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103e3b:	56                   	push   %esi
f0103e3c:	8d 83 a3 6c f8 ff    	lea    -0x7935d(%ebx),%eax
f0103e42:	50                   	push   %eax
f0103e43:	e8 ff fa ff ff       	call   f0103947 <cprintf>
	print_regs(&tf->tf_regs);
f0103e48:	89 34 24             	mov    %esi,(%esp)
f0103e4b:	e8 28 ff ff ff       	call   f0103d78 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e50:	83 c4 08             	add    $0x8,%esp
f0103e53:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103e57:	50                   	push   %eax
f0103e58:	8d 83 a4 6b f8 ff    	lea    -0x7945c(%ebx),%eax
f0103e5e:	50                   	push   %eax
f0103e5f:	e8 e3 fa ff ff       	call   f0103947 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e64:	83 c4 08             	add    $0x8,%esp
f0103e67:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103e6b:	50                   	push   %eax
f0103e6c:	8d 83 b7 6b f8 ff    	lea    -0x79449(%ebx),%eax
f0103e72:	50                   	push   %eax
f0103e73:	e8 cf fa ff ff       	call   f0103947 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e78:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103e7b:	83 c4 10             	add    $0x10,%esp
f0103e7e:	83 fa 13             	cmp    $0x13,%edx
f0103e81:	0f 86 e2 00 00 00    	jbe    f0103f69 <print_trapframe+0x145>
		return "System call";
f0103e87:	83 fa 30             	cmp    $0x30,%edx
f0103e8a:	8d 83 62 6b f8 ff    	lea    -0x7949e(%ebx),%eax
f0103e90:	8d 8b 71 6b f8 ff    	lea    -0x7948f(%ebx),%ecx
f0103e96:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e99:	83 ec 04             	sub    $0x4,%esp
f0103e9c:	50                   	push   %eax
f0103e9d:	52                   	push   %edx
f0103e9e:	8d 83 ca 6b f8 ff    	lea    -0x79436(%ebx),%eax
f0103ea4:	50                   	push   %eax
f0103ea5:	e8 9d fa ff ff       	call   f0103947 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103eaa:	83 c4 10             	add    $0x10,%esp
f0103ead:	39 b3 f8 22 00 00    	cmp    %esi,0x22f8(%ebx)
f0103eb3:	0f 84 bc 00 00 00    	je     f0103f75 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0103eb9:	83 ec 08             	sub    $0x8,%esp
f0103ebc:	ff 76 2c             	push   0x2c(%esi)
f0103ebf:	8d 83 eb 6b f8 ff    	lea    -0x79415(%ebx),%eax
f0103ec5:	50                   	push   %eax
f0103ec6:	e8 7c fa ff ff       	call   f0103947 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103ecb:	83 c4 10             	add    $0x10,%esp
f0103ece:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103ed2:	0f 85 c2 00 00 00    	jne    f0103f9a <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ed8:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103edb:	a8 01                	test   $0x1,%al
f0103edd:	8d 8b 7d 6b f8 ff    	lea    -0x79483(%ebx),%ecx
f0103ee3:	8d 93 88 6b f8 ff    	lea    -0x79478(%ebx),%edx
f0103ee9:	0f 44 ca             	cmove  %edx,%ecx
f0103eec:	a8 02                	test   $0x2,%al
f0103eee:	8d 93 94 6b f8 ff    	lea    -0x7946c(%ebx),%edx
f0103ef4:	8d bb 9a 6b f8 ff    	lea    -0x79466(%ebx),%edi
f0103efa:	0f 44 d7             	cmove  %edi,%edx
f0103efd:	a8 04                	test   $0x4,%al
f0103eff:	8d 83 9f 6b f8 ff    	lea    -0x79461(%ebx),%eax
f0103f05:	8d bb ca 6c f8 ff    	lea    -0x79336(%ebx),%edi
f0103f0b:	0f 44 c7             	cmove  %edi,%eax
f0103f0e:	51                   	push   %ecx
f0103f0f:	52                   	push   %edx
f0103f10:	50                   	push   %eax
f0103f11:	8d 83 f9 6b f8 ff    	lea    -0x79407(%ebx),%eax
f0103f17:	50                   	push   %eax
f0103f18:	e8 2a fa ff ff       	call   f0103947 <cprintf>
f0103f1d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f20:	83 ec 08             	sub    $0x8,%esp
f0103f23:	ff 76 30             	push   0x30(%esi)
f0103f26:	8d 83 08 6c f8 ff    	lea    -0x793f8(%ebx),%eax
f0103f2c:	50                   	push   %eax
f0103f2d:	e8 15 fa ff ff       	call   f0103947 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f32:	83 c4 08             	add    $0x8,%esp
f0103f35:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f39:	50                   	push   %eax
f0103f3a:	8d 83 17 6c f8 ff    	lea    -0x793e9(%ebx),%eax
f0103f40:	50                   	push   %eax
f0103f41:	e8 01 fa ff ff       	call   f0103947 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f46:	83 c4 08             	add    $0x8,%esp
f0103f49:	ff 76 38             	push   0x38(%esi)
f0103f4c:	8d 83 2a 6c f8 ff    	lea    -0x793d6(%ebx),%eax
f0103f52:	50                   	push   %eax
f0103f53:	e8 ef f9 ff ff       	call   f0103947 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f58:	83 c4 10             	add    $0x10,%esp
f0103f5b:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103f5f:	75 50                	jne    f0103fb1 <print_trapframe+0x18d>
}
f0103f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f64:	5b                   	pop    %ebx
f0103f65:	5e                   	pop    %esi
f0103f66:	5f                   	pop    %edi
f0103f67:	5d                   	pop    %ebp
f0103f68:	c3                   	ret    
		return excnames[trapno];
f0103f69:	8b 84 93 f8 17 00 00 	mov    0x17f8(%ebx,%edx,4),%eax
f0103f70:	e9 24 ff ff ff       	jmp    f0103e99 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f75:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103f79:	0f 85 3a ff ff ff    	jne    f0103eb9 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f7f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f82:	83 ec 08             	sub    $0x8,%esp
f0103f85:	50                   	push   %eax
f0103f86:	8d 83 dc 6b f8 ff    	lea    -0x79424(%ebx),%eax
f0103f8c:	50                   	push   %eax
f0103f8d:	e8 b5 f9 ff ff       	call   f0103947 <cprintf>
f0103f92:	83 c4 10             	add    $0x10,%esp
f0103f95:	e9 1f ff ff ff       	jmp    f0103eb9 <print_trapframe+0x95>
		cprintf("\n");
f0103f9a:	83 ec 0c             	sub    $0xc,%esp
f0103f9d:	8d 83 0e 6a f8 ff    	lea    -0x795f2(%ebx),%eax
f0103fa3:	50                   	push   %eax
f0103fa4:	e8 9e f9 ff ff       	call   f0103947 <cprintf>
f0103fa9:	83 c4 10             	add    $0x10,%esp
f0103fac:	e9 6f ff ff ff       	jmp    f0103f20 <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103fb1:	83 ec 08             	sub    $0x8,%esp
f0103fb4:	ff 76 3c             	push   0x3c(%esi)
f0103fb7:	8d 83 39 6c f8 ff    	lea    -0x793c7(%ebx),%eax
f0103fbd:	50                   	push   %eax
f0103fbe:	e8 84 f9 ff ff       	call   f0103947 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103fc3:	83 c4 08             	add    $0x8,%esp
f0103fc6:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103fca:	50                   	push   %eax
f0103fcb:	8d 83 48 6c f8 ff    	lea    -0x793b8(%ebx),%eax
f0103fd1:	50                   	push   %eax
f0103fd2:	e8 70 f9 ff ff       	call   f0103947 <cprintf>
f0103fd7:	83 c4 10             	add    $0x10,%esp
}
f0103fda:	eb 85                	jmp    f0103f61 <print_trapframe+0x13d>

f0103fdc <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103fdc:	55                   	push   %ebp
f0103fdd:	89 e5                	mov    %esp,%ebp
f0103fdf:	57                   	push   %edi
f0103fe0:	56                   	push   %esi
f0103fe1:	53                   	push   %ebx
f0103fe2:	83 ec 0c             	sub    $0xc,%esp
f0103fe5:	e8 7d c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103fea:	81 c3 7e b8 07 00    	add    $0x7b87e,%ebx
f0103ff0:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ff3:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 0x3) ==0) {
f0103ff6:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103ffa:	74 38                	je     f0104034 <page_fault_handler+0x58>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ffc:	ff 76 30             	push   0x30(%esi)
f0103fff:	50                   	push   %eax
f0104000:	c7 c7 50 13 18 f0    	mov    $0xf0181350,%edi
f0104006:	8b 07                	mov    (%edi),%eax
f0104008:	ff 70 48             	push   0x48(%eax)
f010400b:	8d 83 14 6e f8 ff    	lea    -0x791ec(%ebx),%eax
f0104011:	50                   	push   %eax
f0104012:	e8 30 f9 ff ff       	call   f0103947 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104017:	89 34 24             	mov    %esi,(%esp)
f010401a:	e8 05 fe ff ff       	call   f0103e24 <print_trapframe>
	env_destroy(curenv);
f010401f:	83 c4 04             	add    $0x4,%esp
f0104022:	ff 37                	push   (%edi)
f0104024:	e8 b4 f7 ff ff       	call   f01037dd <env_destroy>
}
f0104029:	83 c4 10             	add    $0x10,%esp
f010402c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010402f:	5b                   	pop    %ebx
f0104030:	5e                   	pop    %esi
f0104031:	5f                   	pop    %edi
f0104032:	5d                   	pop    %ebp
f0104033:	c3                   	ret    
	panic("page fault in kernel mode");
f0104034:	83 ec 04             	sub    $0x4,%esp
f0104037:	8d 83 5b 6c f8 ff    	lea    -0x793a5(%ebx),%eax
f010403d:	50                   	push   %eax
f010403e:	68 08 01 00 00       	push   $0x108
f0104043:	8d 83 75 6c f8 ff    	lea    -0x7938b(%ebx),%eax
f0104049:	50                   	push   %eax
f010404a:	e8 62 c0 ff ff       	call   f01000b1 <_panic>

f010404f <trap>:
{
f010404f:	55                   	push   %ebp
f0104050:	89 e5                	mov    %esp,%ebp
f0104052:	57                   	push   %edi
f0104053:	56                   	push   %esi
f0104054:	53                   	push   %ebx
f0104055:	83 ec 0c             	sub    $0xc,%esp
f0104058:	e8 0a c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010405d:	81 c3 0b b8 07 00    	add    $0x7b80b,%ebx
f0104063:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104066:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104067:	9c                   	pushf  
f0104068:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104069:	f6 c4 02             	test   $0x2,%ah
f010406c:	74 1f                	je     f010408d <trap+0x3e>
f010406e:	8d 83 81 6c f8 ff    	lea    -0x7937f(%ebx),%eax
f0104074:	50                   	push   %eax
f0104075:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f010407b:	50                   	push   %eax
f010407c:	68 df 00 00 00       	push   $0xdf
f0104081:	8d 83 75 6c f8 ff    	lea    -0x7938b(%ebx),%eax
f0104087:	50                   	push   %eax
f0104088:	e8 24 c0 ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f010408d:	83 ec 08             	sub    $0x8,%esp
f0104090:	56                   	push   %esi
f0104091:	8d 83 9a 6c f8 ff    	lea    -0x79366(%ebx),%eax
f0104097:	50                   	push   %eax
f0104098:	e8 aa f8 ff ff       	call   f0103947 <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f010409d:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040a1:	83 e0 03             	and    $0x3,%eax
f01040a4:	83 c4 10             	add    $0x10,%esp
f01040a7:	66 83 f8 03          	cmp    $0x3,%ax
f01040ab:	75 1d                	jne    f01040ca <trap+0x7b>
		assert(curenv);
f01040ad:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f01040b3:	8b 00                	mov    (%eax),%eax
f01040b5:	85 c0                	test   %eax,%eax
f01040b7:	74 5d                	je     f0104116 <trap+0xc7>
		curenv->env_tf = *tf;
f01040b9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01040be:	89 c7                	mov    %eax,%edi
f01040c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01040c2:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f01040c8:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f01040ca:	89 b3 f8 22 00 00    	mov    %esi,0x22f8(%ebx)
        switch(tf->tf_trapno){
f01040d0:	8b 46 28             	mov    0x28(%esi),%eax
f01040d3:	83 f8 0e             	cmp    $0xe,%eax
f01040d6:	0f 84 96 00 00 00    	je     f0104172 <trap+0x123>
f01040dc:	83 f8 30             	cmp    $0x30,%eax
f01040df:	0f 84 9b 00 00 00    	je     f0104180 <trap+0x131>
f01040e5:	83 f8 03             	cmp    $0x3,%eax
f01040e8:	74 4b                	je     f0104135 <trap+0xe6>
		print_trapframe(tf);
f01040ea:	83 ec 0c             	sub    $0xc,%esp
f01040ed:	56                   	push   %esi
f01040ee:	e8 31 fd ff ff       	call   f0103e24 <print_trapframe>
		if (GD_KT == tf->tf_cs)
f01040f3:	83 c4 10             	add    $0x10,%esp
f01040f6:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01040fb:	0f 84 9d 00 00 00    	je     f010419e <trap+0x14f>
			env_destroy(curenv);
f0104101:	83 ec 0c             	sub    $0xc,%esp
f0104104:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f010410a:	ff 30                	push   (%eax)
f010410c:	e8 cc f6 ff ff       	call   f01037dd <env_destroy>
			return;
f0104111:	83 c4 10             	add    $0x10,%esp
f0104114:	eb 2b                	jmp    f0104141 <trap+0xf2>
		assert(curenv);
f0104116:	8d 83 b5 6c f8 ff    	lea    -0x7934b(%ebx),%eax
f010411c:	50                   	push   %eax
f010411d:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0104123:	50                   	push   %eax
f0104124:	68 e5 00 00 00       	push   $0xe5
f0104129:	8d 83 75 6c f8 ff    	lea    -0x7938b(%ebx),%eax
f010412f:	50                   	push   %eax
f0104130:	e8 7c bf ff ff       	call   f01000b1 <_panic>
            monitor(tf);
f0104135:	83 ec 0c             	sub    $0xc,%esp
f0104138:	56                   	push   %esi
f0104139:	e8 ea c6 ff ff       	call   f0100828 <monitor>
            break;
f010413e:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104141:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f0104147:	8b 00                	mov    (%eax),%eax
f0104149:	85 c0                	test   %eax,%eax
f010414b:	74 06                	je     f0104153 <trap+0x104>
f010414d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104151:	74 66                	je     f01041b9 <trap+0x16a>
f0104153:	8d 83 38 6e f8 ff    	lea    -0x791c8(%ebx),%eax
f0104159:	50                   	push   %eax
f010415a:	8d 83 83 67 f8 ff    	lea    -0x7987d(%ebx),%eax
f0104160:	50                   	push   %eax
f0104161:	68 f7 00 00 00       	push   $0xf7
f0104166:	8d 83 75 6c f8 ff    	lea    -0x7938b(%ebx),%eax
f010416c:	50                   	push   %eax
f010416d:	e8 3f bf ff ff       	call   f01000b1 <_panic>
            page_fault_handler(tf);
f0104172:	83 ec 0c             	sub    $0xc,%esp
f0104175:	56                   	push   %esi
f0104176:	e8 61 fe ff ff       	call   f0103fdc <page_fault_handler>
            break;
f010417b:	83 c4 10             	add    $0x10,%esp
f010417e:	eb c1                	jmp    f0104141 <trap+0xf2>
            syscall(eax, edx, ecx, ebx, edi, esi);
f0104180:	83 ec 08             	sub    $0x8,%esp
f0104183:	ff 76 04             	push   0x4(%esi)
f0104186:	ff 36                	push   (%esi)
f0104188:	ff 76 10             	push   0x10(%esi)
f010418b:	ff 76 18             	push   0x18(%esi)
f010418e:	ff 76 14             	push   0x14(%esi)
f0104191:	ff 76 1c             	push   0x1c(%esi)
f0104194:	e8 9e 00 00 00       	call   f0104237 <syscall>
            break;
f0104199:	83 c4 20             	add    $0x20,%esp
f010419c:	eb a3                	jmp    f0104141 <trap+0xf2>
			panic("trap break in kernel");
f010419e:	83 ec 04             	sub    $0x4,%esp
f01041a1:	8d 83 bc 6c f8 ff    	lea    -0x79344(%ebx),%eax
f01041a7:	50                   	push   %eax
f01041a8:	68 cd 00 00 00       	push   $0xcd
f01041ad:	8d 83 75 6c f8 ff    	lea    -0x7938b(%ebx),%eax
f01041b3:	50                   	push   %eax
f01041b4:	e8 f8 be ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f01041b9:	83 ec 0c             	sub    $0xc,%esp
f01041bc:	50                   	push   %eax
f01041bd:	e8 89 f6 ff ff       	call   f010384b <env_run>

f01041c2 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
    TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f01041c2:	6a 00                	push   $0x0
f01041c4:	6a 00                	push   $0x0
f01041c6:	eb 60                	jmp    f0104228 <_alltraps>

f01041c8 <t_debug>:
	TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f01041c8:	6a 00                	push   $0x0
f01041ca:	6a 01                	push   $0x1
f01041cc:	eb 5a                	jmp    f0104228 <_alltraps>

f01041ce <t_nmi>:
	TRAPHANDLER_NOEC(t_nmi, T_NMI)
f01041ce:	6a 00                	push   $0x0
f01041d0:	6a 02                	push   $0x2
f01041d2:	eb 54                	jmp    f0104228 <_alltraps>

f01041d4 <t_brkpt>:
	TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01041d4:	6a 00                	push   $0x0
f01041d6:	6a 03                	push   $0x3
f01041d8:	eb 4e                	jmp    f0104228 <_alltraps>

f01041da <t_oflow>:
	TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f01041da:	6a 00                	push   $0x0
f01041dc:	6a 04                	push   $0x4
f01041de:	eb 48                	jmp    f0104228 <_alltraps>

f01041e0 <t_bound>:
	TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01041e0:	6a 00                	push   $0x0
f01041e2:	6a 05                	push   $0x5
f01041e4:	eb 42                	jmp    f0104228 <_alltraps>

f01041e6 <t_illop>:
	TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01041e6:	6a 00                	push   $0x0
f01041e8:	6a 06                	push   $0x6
f01041ea:	eb 3c                	jmp    f0104228 <_alltraps>

f01041ec <t_device>:
	TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01041ec:	6a 00                	push   $0x0
f01041ee:	6a 07                	push   $0x7
f01041f0:	eb 36                	jmp    f0104228 <_alltraps>

f01041f2 <t_dblflt>:
	TRAPHANDLER(t_dblflt, T_DBLFLT)
f01041f2:	6a 08                	push   $0x8
f01041f4:	eb 32                	jmp    f0104228 <_alltraps>

f01041f6 <t_tss>:
	TRAPHANDLER(t_tss, T_TSS)
f01041f6:	6a 0a                	push   $0xa
f01041f8:	eb 2e                	jmp    f0104228 <_alltraps>

f01041fa <t_segnp>:
	TRAPHANDLER_NOEC(t_segnp, T_SEGNP)
f01041fa:	6a 00                	push   $0x0
f01041fc:	6a 0b                	push   $0xb
f01041fe:	eb 28                	jmp    f0104228 <_alltraps>

f0104200 <t_stack>:
	TRAPHANDLER(t_stack, T_STACK)
f0104200:	6a 0c                	push   $0xc
f0104202:	eb 24                	jmp    f0104228 <_alltraps>

f0104204 <t_gpflt>:
	TRAPHANDLER(t_gpflt, T_GPFLT)
f0104204:	6a 0d                	push   $0xd
f0104206:	eb 20                	jmp    f0104228 <_alltraps>

f0104208 <t_pgflt>:
	TRAPHANDLER(t_pgflt, T_PGFLT)
f0104208:	6a 0e                	push   $0xe
f010420a:	eb 1c                	jmp    f0104228 <_alltraps>

f010420c <t_fperr>:
	TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f010420c:	6a 00                	push   $0x0
f010420e:	6a 10                	push   $0x10
f0104210:	eb 16                	jmp    f0104228 <_alltraps>

f0104212 <t_align>:
	TRAPHANDLER(t_align, T_ALIGN)
f0104212:	6a 11                	push   $0x11
f0104214:	eb 12                	jmp    f0104228 <_alltraps>

f0104216 <t_mchk>:
	TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104216:	6a 00                	push   $0x0
f0104218:	6a 12                	push   $0x12
f010421a:	eb 0c                	jmp    f0104228 <_alltraps>

f010421c <t_simderr>:
	TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f010421c:	6a 00                	push   $0x0
f010421e:	6a 13                	push   $0x13
f0104220:	eb 06                	jmp    f0104228 <_alltraps>

f0104222 <t_syscall>:
	TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104222:	6a 00                	push   $0x0
f0104224:	6a 30                	push   $0x30
f0104226:	eb 00                	jmp    f0104228 <_alltraps>

f0104228 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
    pushl %ds
f0104228:	1e                   	push   %ds
    pushl %es
f0104229:	06                   	push   %es
    pushal
f010422a:	60                   	pusha  
    movl %ss, %eax
f010422b:	8c d0                	mov    %ss,%eax
    movw %ax, %ds
f010422d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f010422f:	8e c0                	mov    %eax,%es
    pushl %esp
f0104231:	54                   	push   %esp
    call trap
f0104232:	e8 18 fe ff ff       	call   f010404f <trap>

f0104237 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104237:	55                   	push   %ebp
f0104238:	89 e5                	mov    %esp,%ebp
f010423a:	53                   	push   %ebx
f010423b:	83 ec 14             	sub    $0x14,%esp
f010423e:	e8 24 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104243:	81 c3 25 b6 07 00    	add    $0x7b625,%ebx
f0104249:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f010424c:	83 f8 02             	cmp    $0x2,%eax
f010424f:	0f 84 be 00 00 00    	je     f0104313 <syscall+0xdc>
f0104255:	83 f8 02             	cmp    $0x2,%eax
f0104258:	77 0b                	ja     f0104265 <syscall+0x2e>
f010425a:	85 c0                	test   %eax,%eax
f010425c:	74 6a                	je     f01042c8 <syscall+0x91>
	return cons_getc();
f010425e:	e8 06 c3 ff ff       	call   f0100569 <cons_getc>
	case SYS_cgetc:
            return sys_cgetc();
f0104263:	eb 5e                	jmp    f01042c3 <syscall+0x8c>
	switch (syscallno) {
f0104265:	83 f8 03             	cmp    $0x3,%eax
f0104268:	75 54                	jne    f01042be <syscall+0x87>
	if ((r = envid2env(envid, &e, 1)) < 0)
f010426a:	83 ec 04             	sub    $0x4,%esp
f010426d:	6a 01                	push   $0x1
f010426f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104272:	50                   	push   %eax
f0104273:	ff 75 0c             	push   0xc(%ebp)
f0104276:	e8 15 ef ff ff       	call   f0103190 <envid2env>
f010427b:	83 c4 10             	add    $0x10,%esp
f010427e:	85 c0                	test   %eax,%eax
f0104280:	78 41                	js     f01042c3 <syscall+0x8c>
	if (e == curenv)
f0104282:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104285:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f010428b:	8b 00                	mov    (%eax),%eax
f010428d:	39 c2                	cmp    %eax,%edx
f010428f:	74 6b                	je     f01042fc <syscall+0xc5>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104291:	83 ec 04             	sub    $0x4,%esp
f0104294:	ff 72 48             	push   0x48(%edx)
f0104297:	ff 70 48             	push   0x48(%eax)
f010429a:	8d 83 84 6e f8 ff    	lea    -0x7917c(%ebx),%eax
f01042a0:	50                   	push   %eax
f01042a1:	e8 a1 f6 ff ff       	call   f0103947 <cprintf>
f01042a6:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01042a9:	83 ec 0c             	sub    $0xc,%esp
f01042ac:	ff 75 f4             	push   -0xc(%ebp)
f01042af:	e8 29 f5 ff ff       	call   f01037dd <env_destroy>
	return 0;
f01042b4:	83 c4 10             	add    $0x10,%esp
f01042b7:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_cputs:
            sys_cputs((char *)a1, a2);
            return 0;
        case SYS_env_destroy:
            return sys_env_destroy(a1);
f01042bc:	eb 05                	jmp    f01042c3 <syscall+0x8c>
	switch (syscallno) {
f01042be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
        case SYS_getenvid:
            return sys_getenvid();
	default:
		return -E_INVAL;
	}
}
f01042c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01042c6:	c9                   	leave  
f01042c7:	c3                   	ret    
    user_mem_assert(curenv,s, len, PTE_U);
f01042c8:	6a 04                	push   $0x4
f01042ca:	ff 75 10             	push   0x10(%ebp)
f01042cd:	ff 75 0c             	push   0xc(%ebp)
f01042d0:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f01042d6:	ff 30                	push   (%eax)
f01042d8:	e8 af ed ff ff       	call   f010308c <user_mem_assert>
    cprintf("%.*s", len, s);
f01042dd:	83 c4 0c             	add    $0xc,%esp
f01042e0:	ff 75 0c             	push   0xc(%ebp)
f01042e3:	ff 75 10             	push   0x10(%ebp)
f01042e6:	8d 83 64 6e f8 ff    	lea    -0x7919c(%ebx),%eax
f01042ec:	50                   	push   %eax
f01042ed:	e8 55 f6 ff ff       	call   f0103947 <cprintf>
}
f01042f2:	83 c4 10             	add    $0x10,%esp
            return 0;
f01042f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042fa:	eb c7                	jmp    f01042c3 <syscall+0x8c>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01042fc:	83 ec 08             	sub    $0x8,%esp
f01042ff:	ff 70 48             	push   0x48(%eax)
f0104302:	8d 83 69 6e f8 ff    	lea    -0x79197(%ebx),%eax
f0104308:	50                   	push   %eax
f0104309:	e8 39 f6 ff ff       	call   f0103947 <cprintf>
f010430e:	83 c4 10             	add    $0x10,%esp
f0104311:	eb 96                	jmp    f01042a9 <syscall+0x72>
	return curenv->env_id;
f0104313:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f0104319:	8b 00                	mov    (%eax),%eax
f010431b:	8b 40 48             	mov    0x48(%eax),%eax
            return sys_getenvid();
f010431e:	eb a3                	jmp    f01042c3 <syscall+0x8c>

f0104320 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104320:	55                   	push   %ebp
f0104321:	89 e5                	mov    %esp,%ebp
f0104323:	57                   	push   %edi
f0104324:	56                   	push   %esi
f0104325:	53                   	push   %ebx
f0104326:	83 ec 14             	sub    $0x14,%esp
f0104329:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010432c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010432f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104332:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104335:	8b 1a                	mov    (%edx),%ebx
f0104337:	8b 01                	mov    (%ecx),%eax
f0104339:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010433c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104343:	eb 2f                	jmp    f0104374 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104345:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104348:	39 c3                	cmp    %eax,%ebx
f010434a:	7f 4e                	jg     f010439a <stab_binsearch+0x7a>
f010434c:	0f b6 0a             	movzbl (%edx),%ecx
f010434f:	83 ea 0c             	sub    $0xc,%edx
f0104352:	39 f1                	cmp    %esi,%ecx
f0104354:	75 ef                	jne    f0104345 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104356:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104359:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010435c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104360:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104363:	73 3a                	jae    f010439f <stab_binsearch+0x7f>
			*region_left = m;
f0104365:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104368:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010436a:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010436d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104374:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104377:	7f 53                	jg     f01043cc <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104379:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010437c:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f010437f:	89 d0                	mov    %edx,%eax
f0104381:	c1 e8 1f             	shr    $0x1f,%eax
f0104384:	01 d0                	add    %edx,%eax
f0104386:	89 c7                	mov    %eax,%edi
f0104388:	d1 ff                	sar    %edi
f010438a:	83 e0 fe             	and    $0xfffffffe,%eax
f010438d:	01 f8                	add    %edi,%eax
f010438f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104392:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104396:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104398:	eb ae                	jmp    f0104348 <stab_binsearch+0x28>
			l = true_m + 1;
f010439a:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010439d:	eb d5                	jmp    f0104374 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010439f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01043a2:	76 14                	jbe    f01043b8 <stab_binsearch+0x98>
			*region_right = m - 1;
f01043a4:	83 e8 01             	sub    $0x1,%eax
f01043a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01043aa:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01043ad:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01043af:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01043b6:	eb bc                	jmp    f0104374 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01043b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01043bb:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01043bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01043c1:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f01043c3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01043ca:	eb a8                	jmp    f0104374 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01043cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01043d0:	75 15                	jne    f01043e7 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01043d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043d5:	8b 00                	mov    (%eax),%eax
f01043d7:	83 e8 01             	sub    $0x1,%eax
f01043da:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01043dd:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01043df:	83 c4 14             	add    $0x14,%esp
f01043e2:	5b                   	pop    %ebx
f01043e3:	5e                   	pop    %esi
f01043e4:	5f                   	pop    %edi
f01043e5:	5d                   	pop    %ebp
f01043e6:	c3                   	ret    
		for (l = *region_right;
f01043e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043ea:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01043ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01043ef:	8b 0f                	mov    (%edi),%ecx
f01043f1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01043f4:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01043f7:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01043fb:	39 c1                	cmp    %eax,%ecx
f01043fd:	7d 0f                	jge    f010440e <stab_binsearch+0xee>
f01043ff:	0f b6 1a             	movzbl (%edx),%ebx
f0104402:	83 ea 0c             	sub    $0xc,%edx
f0104405:	39 f3                	cmp    %esi,%ebx
f0104407:	74 05                	je     f010440e <stab_binsearch+0xee>
		     l--)
f0104409:	83 e8 01             	sub    $0x1,%eax
f010440c:	eb ed                	jmp    f01043fb <stab_binsearch+0xdb>
		*region_left = l;
f010440e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104411:	89 07                	mov    %eax,(%edi)
}
f0104413:	eb ca                	jmp    f01043df <stab_binsearch+0xbf>

f0104415 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104415:	55                   	push   %ebp
f0104416:	89 e5                	mov    %esp,%ebp
f0104418:	57                   	push   %edi
f0104419:	56                   	push   %esi
f010441a:	53                   	push   %ebx
f010441b:	83 ec 3c             	sub    $0x3c,%esp
f010441e:	e8 44 bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104423:	81 c3 45 b4 07 00    	add    $0x7b445,%ebx
f0104429:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010442c:	8d 83 9c 6e f8 ff    	lea    -0x79164(%ebx),%eax
f0104432:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104434:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010443b:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f010443e:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104445:	8b 45 08             	mov    0x8(%ebp),%eax
f0104448:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f010444b:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104452:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0104457:	0f 86 f9 00 00 00    	jbe    f0104556 <debuginfo_eip+0x141>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010445d:	c7 c0 ef 28 11 f0    	mov    $0xf01128ef,%eax
f0104463:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104466:	c7 c0 4d ec 10 f0    	mov    $0xf010ec4d,%eax
f010446c:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f010446f:	c7 c6 4c ec 10 f0    	mov    $0xf010ec4c,%esi
		stabs = __STAB_BEGIN__;
f0104475:	c7 c0 00 69 10 f0    	mov    $0xf0106900,%eax
f010447b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		return-1;
		}	
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010447e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104481:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104484:	0f 83 bb 01 00 00    	jae    f0104645 <debuginfo_eip+0x230>
f010448a:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010448e:	0f 85 b8 01 00 00    	jne    f010464c <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104494:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010449b:	2b 75 d4             	sub    -0x2c(%ebp),%esi
f010449e:	c1 fe 02             	sar    $0x2,%esi
f01044a1:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01044a7:	83 e8 01             	sub    $0x1,%eax
f01044aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01044ad:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01044b0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01044b3:	83 ec 08             	sub    $0x8,%esp
f01044b6:	ff 75 08             	push   0x8(%ebp)
f01044b9:	6a 64                	push   $0x64
f01044bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01044be:	e8 5d fe ff ff       	call   f0104320 <stab_binsearch>
	if (lfile == 0)
f01044c3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01044c6:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f01044c9:	83 c4 10             	add    $0x10,%esp
f01044cc:	85 f6                	test   %esi,%esi
f01044ce:	0f 84 7f 01 00 00    	je     f0104653 <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01044d4:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f01044d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044da:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01044dd:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01044e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01044e3:	83 ec 08             	sub    $0x8,%esp
f01044e6:	ff 75 08             	push   0x8(%ebp)
f01044e9:	6a 24                	push   $0x24
f01044eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01044ee:	e8 2d fe ff ff       	call   f0104320 <stab_binsearch>

	if (lfun <= rfun) {
f01044f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01044f6:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01044f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044fc:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01044ff:	83 c4 10             	add    $0x10,%esp
f0104502:	39 c2                	cmp    %eax,%edx
f0104504:	7f 25                	jg     f010452b <debuginfo_eip+0x116>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104506:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104509:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010450c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010450f:	8b 02                	mov    (%edx),%eax
f0104511:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104514:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104517:	29 f1                	sub    %esi,%ecx
f0104519:	39 c8                	cmp    %ecx,%eax
f010451b:	73 05                	jae    f0104522 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010451d:	01 f0                	add    %esi,%eax
f010451f:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104522:	8b 42 08             	mov    0x8(%edx),%eax
f0104525:	89 45 08             	mov    %eax,0x8(%ebp)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0104528:	8b 75 c8             	mov    -0x38(%ebp),%esi
		info->eip_fn_addr = stabs[lfun].n_value;
f010452b:	8b 45 08             	mov    0x8(%ebp),%eax
f010452e:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104531:	83 ec 08             	sub    $0x8,%esp
f0104534:	6a 3a                	push   $0x3a
f0104536:	ff 77 08             	push   0x8(%edi)
f0104539:	e8 7a 09 00 00       	call   f0104eb8 <strfind>
f010453e:	2b 47 08             	sub    0x8(%edi),%eax
f0104541:	89 47 0c             	mov    %eax,0xc(%edi)
f0104544:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104547:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010454a:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010454e:	83 c4 10             	add    $0x10,%esp
f0104551:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104554:	eb 7d                	jmp    f01045d3 <debuginfo_eip+0x1be>
		stabs = usd->stabs;
f0104556:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f010455c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010455f:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104565:	a1 08 00 20 00       	mov    0x200008,%eax
f010456a:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010456d:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104573:	89 55 d0             	mov    %edx,-0x30(%ebp)
	if((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))||(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U)) <00){
f0104576:	6a 04                	push   $0x4
f0104578:	89 f0                	mov    %esi,%eax
f010457a:	29 c8                	sub    %ecx,%eax
f010457c:	c1 f8 02             	sar    $0x2,%eax
f010457f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104585:	50                   	push   %eax
f0104586:	51                   	push   %ecx
f0104587:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f010458d:	ff 30                	push   (%eax)
f010458f:	e8 66 ea ff ff       	call   f0102ffa <user_mem_check>
f0104594:	83 c4 10             	add    $0x10,%esp
f0104597:	85 c0                	test   %eax,%eax
f0104599:	0f 85 9f 00 00 00    	jne    f010463e <debuginfo_eip+0x229>
f010459f:	6a 04                	push   $0x4
f01045a1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01045a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01045a7:	29 ca                	sub    %ecx,%edx
f01045a9:	52                   	push   %edx
f01045aa:	51                   	push   %ecx
f01045ab:	c7 c0 50 13 18 f0    	mov    $0xf0181350,%eax
f01045b1:	ff 30                	push   (%eax)
f01045b3:	e8 42 ea ff ff       	call   f0102ffa <user_mem_check>
f01045b8:	83 c4 10             	add    $0x10,%esp
f01045bb:	85 c0                	test   %eax,%eax
f01045bd:	0f 89 bb fe ff ff    	jns    f010447e <debuginfo_eip+0x69>
		return-1;
f01045c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01045c8:	e9 92 00 00 00       	jmp    f010465f <debuginfo_eip+0x24a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01045cd:	83 ee 01             	sub    $0x1,%esi
f01045d0:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01045d3:	39 f3                	cmp    %esi,%ebx
f01045d5:	7f 2e                	jg     f0104605 <debuginfo_eip+0x1f0>
	       && stabs[lline].n_type != N_SOL
f01045d7:	0f b6 10             	movzbl (%eax),%edx
f01045da:	80 fa 84             	cmp    $0x84,%dl
f01045dd:	74 0b                	je     f01045ea <debuginfo_eip+0x1d5>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01045df:	80 fa 64             	cmp    $0x64,%dl
f01045e2:	75 e9                	jne    f01045cd <debuginfo_eip+0x1b8>
f01045e4:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f01045e8:	74 e3                	je     f01045cd <debuginfo_eip+0x1b8>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01045ea:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01045ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01045f0:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01045f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01045f6:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f01045f9:	29 d8                	sub    %ebx,%eax
f01045fb:	39 c2                	cmp    %eax,%edx
f01045fd:	73 06                	jae    f0104605 <debuginfo_eip+0x1f0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01045ff:	89 d8                	mov    %ebx,%eax
f0104601:	01 d0                	add    %edx,%eax
f0104603:	89 07                	mov    %eax,(%edi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104605:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010460a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f010460d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104610:	39 cb                	cmp    %ecx,%ebx
f0104612:	7d 4b                	jge    f010465f <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f0104614:	8d 53 01             	lea    0x1(%ebx),%edx
f0104617:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010461a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010461d:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f0104621:	eb 07                	jmp    f010462a <debuginfo_eip+0x215>
			info->eip_fn_narg++;
f0104623:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0104627:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010462a:	39 d1                	cmp    %edx,%ecx
f010462c:	74 2c                	je     f010465a <debuginfo_eip+0x245>
f010462e:	83 c0 0c             	add    $0xc,%eax
f0104631:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104635:	74 ec                	je     f0104623 <debuginfo_eip+0x20e>
	return 0;
f0104637:	b8 00 00 00 00       	mov    $0x0,%eax
f010463c:	eb 21                	jmp    f010465f <debuginfo_eip+0x24a>
		return-1;
f010463e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104643:	eb 1a                	jmp    f010465f <debuginfo_eip+0x24a>
		return -1;
f0104645:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010464a:	eb 13                	jmp    f010465f <debuginfo_eip+0x24a>
f010464c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104651:	eb 0c                	jmp    f010465f <debuginfo_eip+0x24a>
		return -1;
f0104653:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104658:	eb 05                	jmp    f010465f <debuginfo_eip+0x24a>
	return 0;
f010465a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010465f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104662:	5b                   	pop    %ebx
f0104663:	5e                   	pop    %esi
f0104664:	5f                   	pop    %edi
f0104665:	5d                   	pop    %ebp
f0104666:	c3                   	ret    

f0104667 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104667:	55                   	push   %ebp
f0104668:	89 e5                	mov    %esp,%ebp
f010466a:	57                   	push   %edi
f010466b:	56                   	push   %esi
f010466c:	53                   	push   %ebx
f010466d:	83 ec 2c             	sub    $0x2c,%esp
f0104670:	e8 74 ea ff ff       	call   f01030e9 <__x86.get_pc_thunk.cx>
f0104675:	81 c1 f3 b1 07 00    	add    $0x7b1f3,%ecx
f010467b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010467e:	89 c7                	mov    %eax,%edi
f0104680:	89 d6                	mov    %edx,%esi
f0104682:	8b 45 08             	mov    0x8(%ebp),%eax
f0104685:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104688:	89 d1                	mov    %edx,%ecx
f010468a:	89 c2                	mov    %eax,%edx
f010468c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010468f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104692:	8b 45 10             	mov    0x10(%ebp),%eax
f0104695:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104698:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010469b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01046a2:	39 c2                	cmp    %eax,%edx
f01046a4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01046a7:	72 41                	jb     f01046ea <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01046a9:	83 ec 0c             	sub    $0xc,%esp
f01046ac:	ff 75 18             	push   0x18(%ebp)
f01046af:	83 eb 01             	sub    $0x1,%ebx
f01046b2:	53                   	push   %ebx
f01046b3:	50                   	push   %eax
f01046b4:	83 ec 08             	sub    $0x8,%esp
f01046b7:	ff 75 e4             	push   -0x1c(%ebp)
f01046ba:	ff 75 e0             	push   -0x20(%ebp)
f01046bd:	ff 75 d4             	push   -0x2c(%ebp)
f01046c0:	ff 75 d0             	push   -0x30(%ebp)
f01046c3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01046c6:	e8 05 0a 00 00       	call   f01050d0 <__udivdi3>
f01046cb:	83 c4 18             	add    $0x18,%esp
f01046ce:	52                   	push   %edx
f01046cf:	50                   	push   %eax
f01046d0:	89 f2                	mov    %esi,%edx
f01046d2:	89 f8                	mov    %edi,%eax
f01046d4:	e8 8e ff ff ff       	call   f0104667 <printnum>
f01046d9:	83 c4 20             	add    $0x20,%esp
f01046dc:	eb 13                	jmp    f01046f1 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01046de:	83 ec 08             	sub    $0x8,%esp
f01046e1:	56                   	push   %esi
f01046e2:	ff 75 18             	push   0x18(%ebp)
f01046e5:	ff d7                	call   *%edi
f01046e7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01046ea:	83 eb 01             	sub    $0x1,%ebx
f01046ed:	85 db                	test   %ebx,%ebx
f01046ef:	7f ed                	jg     f01046de <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01046f1:	83 ec 08             	sub    $0x8,%esp
f01046f4:	56                   	push   %esi
f01046f5:	83 ec 04             	sub    $0x4,%esp
f01046f8:	ff 75 e4             	push   -0x1c(%ebp)
f01046fb:	ff 75 e0             	push   -0x20(%ebp)
f01046fe:	ff 75 d4             	push   -0x2c(%ebp)
f0104701:	ff 75 d0             	push   -0x30(%ebp)
f0104704:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104707:	e8 e4 0a 00 00       	call   f01051f0 <__umoddi3>
f010470c:	83 c4 14             	add    $0x14,%esp
f010470f:	0f be 84 03 a6 6e f8 	movsbl -0x7915a(%ebx,%eax,1),%eax
f0104716:	ff 
f0104717:	50                   	push   %eax
f0104718:	ff d7                	call   *%edi
}
f010471a:	83 c4 10             	add    $0x10,%esp
f010471d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104720:	5b                   	pop    %ebx
f0104721:	5e                   	pop    %esi
f0104722:	5f                   	pop    %edi
f0104723:	5d                   	pop    %ebp
f0104724:	c3                   	ret    

f0104725 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104725:	55                   	push   %ebp
f0104726:	89 e5                	mov    %esp,%ebp
f0104728:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010472b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010472f:	8b 10                	mov    (%eax),%edx
f0104731:	3b 50 04             	cmp    0x4(%eax),%edx
f0104734:	73 0a                	jae    f0104740 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104736:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104739:	89 08                	mov    %ecx,(%eax)
f010473b:	8b 45 08             	mov    0x8(%ebp),%eax
f010473e:	88 02                	mov    %al,(%edx)
}
f0104740:	5d                   	pop    %ebp
f0104741:	c3                   	ret    

f0104742 <printfmt>:
{
f0104742:	55                   	push   %ebp
f0104743:	89 e5                	mov    %esp,%ebp
f0104745:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104748:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010474b:	50                   	push   %eax
f010474c:	ff 75 10             	push   0x10(%ebp)
f010474f:	ff 75 0c             	push   0xc(%ebp)
f0104752:	ff 75 08             	push   0x8(%ebp)
f0104755:	e8 05 00 00 00       	call   f010475f <vprintfmt>
}
f010475a:	83 c4 10             	add    $0x10,%esp
f010475d:	c9                   	leave  
f010475e:	c3                   	ret    

f010475f <vprintfmt>:
{
f010475f:	55                   	push   %ebp
f0104760:	89 e5                	mov    %esp,%ebp
f0104762:	57                   	push   %edi
f0104763:	56                   	push   %esi
f0104764:	53                   	push   %ebx
f0104765:	83 ec 3c             	sub    $0x3c,%esp
f0104768:	e8 8c bf ff ff       	call   f01006f9 <__x86.get_pc_thunk.ax>
f010476d:	05 fb b0 07 00       	add    $0x7b0fb,%eax
f0104772:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104775:	8b 75 08             	mov    0x8(%ebp),%esi
f0104778:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010477b:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010477e:	8d 80 48 18 00 00    	lea    0x1848(%eax),%eax
f0104784:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104787:	eb 0a                	jmp    f0104793 <vprintfmt+0x34>
			putch(ch, putdat);
f0104789:	83 ec 08             	sub    $0x8,%esp
f010478c:	57                   	push   %edi
f010478d:	50                   	push   %eax
f010478e:	ff d6                	call   *%esi
f0104790:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104793:	83 c3 01             	add    $0x1,%ebx
f0104796:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010479a:	83 f8 25             	cmp    $0x25,%eax
f010479d:	74 0c                	je     f01047ab <vprintfmt+0x4c>
			if (ch == '\0')
f010479f:	85 c0                	test   %eax,%eax
f01047a1:	75 e6                	jne    f0104789 <vprintfmt+0x2a>
}
f01047a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047a6:	5b                   	pop    %ebx
f01047a7:	5e                   	pop    %esi
f01047a8:	5f                   	pop    %edi
f01047a9:	5d                   	pop    %ebp
f01047aa:	c3                   	ret    
		padc = ' ';
f01047ab:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01047af:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01047b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01047bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f01047c4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01047c9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01047cc:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01047cf:	8d 43 01             	lea    0x1(%ebx),%eax
f01047d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01047d5:	0f b6 13             	movzbl (%ebx),%edx
f01047d8:	8d 42 dd             	lea    -0x23(%edx),%eax
f01047db:	3c 55                	cmp    $0x55,%al
f01047dd:	0f 87 c5 03 00 00    	ja     f0104ba8 <.L20>
f01047e3:	0f b6 c0             	movzbl %al,%eax
f01047e6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01047e9:	89 ce                	mov    %ecx,%esi
f01047eb:	03 b4 81 30 6f f8 ff 	add    -0x790d0(%ecx,%eax,4),%esi
f01047f2:	ff e6                	jmp    *%esi

f01047f4 <.L66>:
f01047f4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01047f7:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01047fb:	eb d2                	jmp    f01047cf <vprintfmt+0x70>

f01047fd <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01047fd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104800:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0104804:	eb c9                	jmp    f01047cf <vprintfmt+0x70>

f0104806 <.L31>:
f0104806:	0f b6 d2             	movzbl %dl,%edx
f0104809:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010480c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104811:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0104814:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104817:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010481b:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010481e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104821:	83 f9 09             	cmp    $0x9,%ecx
f0104824:	77 58                	ja     f010487e <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0104826:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0104829:	eb e9                	jmp    f0104814 <.L31+0xe>

f010482b <.L34>:
			precision = va_arg(ap, int);
f010482b:	8b 45 14             	mov    0x14(%ebp),%eax
f010482e:	8b 00                	mov    (%eax),%eax
f0104830:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104833:	8b 45 14             	mov    0x14(%ebp),%eax
f0104836:	8d 40 04             	lea    0x4(%eax),%eax
f0104839:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010483c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010483f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104843:	79 8a                	jns    f01047cf <vprintfmt+0x70>
				width = precision, precision = -1;
f0104845:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104848:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010484b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104852:	e9 78 ff ff ff       	jmp    f01047cf <vprintfmt+0x70>

f0104857 <.L33>:
f0104857:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010485a:	85 d2                	test   %edx,%edx
f010485c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104861:	0f 49 c2             	cmovns %edx,%eax
f0104864:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104867:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010486a:	e9 60 ff ff ff       	jmp    f01047cf <vprintfmt+0x70>

f010486f <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010486f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0104872:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0104879:	e9 51 ff ff ff       	jmp    f01047cf <vprintfmt+0x70>
f010487e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104881:	89 75 08             	mov    %esi,0x8(%ebp)
f0104884:	eb b9                	jmp    f010483f <.L34+0x14>

f0104886 <.L27>:
			lflag++;
f0104886:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010488a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010488d:	e9 3d ff ff ff       	jmp    f01047cf <vprintfmt+0x70>

f0104892 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104892:	8b 75 08             	mov    0x8(%ebp),%esi
f0104895:	8b 45 14             	mov    0x14(%ebp),%eax
f0104898:	8d 58 04             	lea    0x4(%eax),%ebx
f010489b:	83 ec 08             	sub    $0x8,%esp
f010489e:	57                   	push   %edi
f010489f:	ff 30                	push   (%eax)
f01048a1:	ff d6                	call   *%esi
			break;
f01048a3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01048a6:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01048a9:	e9 90 02 00 00       	jmp    f0104b3e <.L25+0x45>

f01048ae <.L28>:
			err = va_arg(ap, int);
f01048ae:	8b 75 08             	mov    0x8(%ebp),%esi
f01048b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01048b4:	8d 58 04             	lea    0x4(%eax),%ebx
f01048b7:	8b 10                	mov    (%eax),%edx
f01048b9:	89 d0                	mov    %edx,%eax
f01048bb:	f7 d8                	neg    %eax
f01048bd:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01048c0:	83 f8 06             	cmp    $0x6,%eax
f01048c3:	7f 27                	jg     f01048ec <.L28+0x3e>
f01048c5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01048c8:	8b 14 82             	mov    (%edx,%eax,4),%edx
f01048cb:	85 d2                	test   %edx,%edx
f01048cd:	74 1d                	je     f01048ec <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f01048cf:	52                   	push   %edx
f01048d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048d3:	8d 80 95 67 f8 ff    	lea    -0x7986b(%eax),%eax
f01048d9:	50                   	push   %eax
f01048da:	57                   	push   %edi
f01048db:	56                   	push   %esi
f01048dc:	e8 61 fe ff ff       	call   f0104742 <printfmt>
f01048e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01048e4:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01048e7:	e9 52 02 00 00       	jmp    f0104b3e <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01048ec:	50                   	push   %eax
f01048ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048f0:	8d 80 be 6e f8 ff    	lea    -0x79142(%eax),%eax
f01048f6:	50                   	push   %eax
f01048f7:	57                   	push   %edi
f01048f8:	56                   	push   %esi
f01048f9:	e8 44 fe ff ff       	call   f0104742 <printfmt>
f01048fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104901:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104904:	e9 35 02 00 00       	jmp    f0104b3e <.L25+0x45>

f0104909 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104909:	8b 75 08             	mov    0x8(%ebp),%esi
f010490c:	8b 45 14             	mov    0x14(%ebp),%eax
f010490f:	83 c0 04             	add    $0x4,%eax
f0104912:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104915:	8b 45 14             	mov    0x14(%ebp),%eax
f0104918:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010491a:	85 d2                	test   %edx,%edx
f010491c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010491f:	8d 80 b7 6e f8 ff    	lea    -0x79149(%eax),%eax
f0104925:	0f 45 c2             	cmovne %edx,%eax
f0104928:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f010492b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010492f:	7e 06                	jle    f0104937 <.L24+0x2e>
f0104931:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0104935:	75 0d                	jne    f0104944 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104937:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010493a:	89 c3                	mov    %eax,%ebx
f010493c:	03 45 d0             	add    -0x30(%ebp),%eax
f010493f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104942:	eb 58                	jmp    f010499c <.L24+0x93>
f0104944:	83 ec 08             	sub    $0x8,%esp
f0104947:	ff 75 d8             	push   -0x28(%ebp)
f010494a:	ff 75 c8             	push   -0x38(%ebp)
f010494d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104950:	e8 0c 04 00 00       	call   f0104d61 <strnlen>
f0104955:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104958:	29 c2                	sub    %eax,%edx
f010495a:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010495d:	83 c4 10             	add    $0x10,%esp
f0104960:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0104962:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104966:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104969:	eb 0f                	jmp    f010497a <.L24+0x71>
					putch(padc, putdat);
f010496b:	83 ec 08             	sub    $0x8,%esp
f010496e:	57                   	push   %edi
f010496f:	ff 75 d0             	push   -0x30(%ebp)
f0104972:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104974:	83 eb 01             	sub    $0x1,%ebx
f0104977:	83 c4 10             	add    $0x10,%esp
f010497a:	85 db                	test   %ebx,%ebx
f010497c:	7f ed                	jg     f010496b <.L24+0x62>
f010497e:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104981:	85 d2                	test   %edx,%edx
f0104983:	b8 00 00 00 00       	mov    $0x0,%eax
f0104988:	0f 49 c2             	cmovns %edx,%eax
f010498b:	29 c2                	sub    %eax,%edx
f010498d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104990:	eb a5                	jmp    f0104937 <.L24+0x2e>
					putch(ch, putdat);
f0104992:	83 ec 08             	sub    $0x8,%esp
f0104995:	57                   	push   %edi
f0104996:	52                   	push   %edx
f0104997:	ff d6                	call   *%esi
f0104999:	83 c4 10             	add    $0x10,%esp
f010499c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010499f:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01049a1:	83 c3 01             	add    $0x1,%ebx
f01049a4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01049a8:	0f be d0             	movsbl %al,%edx
f01049ab:	85 d2                	test   %edx,%edx
f01049ad:	74 4b                	je     f01049fa <.L24+0xf1>
f01049af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01049b3:	78 06                	js     f01049bb <.L24+0xb2>
f01049b5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01049b9:	78 1e                	js     f01049d9 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01049bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01049bf:	74 d1                	je     f0104992 <.L24+0x89>
f01049c1:	0f be c0             	movsbl %al,%eax
f01049c4:	83 e8 20             	sub    $0x20,%eax
f01049c7:	83 f8 5e             	cmp    $0x5e,%eax
f01049ca:	76 c6                	jbe    f0104992 <.L24+0x89>
					putch('?', putdat);
f01049cc:	83 ec 08             	sub    $0x8,%esp
f01049cf:	57                   	push   %edi
f01049d0:	6a 3f                	push   $0x3f
f01049d2:	ff d6                	call   *%esi
f01049d4:	83 c4 10             	add    $0x10,%esp
f01049d7:	eb c3                	jmp    f010499c <.L24+0x93>
f01049d9:	89 cb                	mov    %ecx,%ebx
f01049db:	eb 0e                	jmp    f01049eb <.L24+0xe2>
				putch(' ', putdat);
f01049dd:	83 ec 08             	sub    $0x8,%esp
f01049e0:	57                   	push   %edi
f01049e1:	6a 20                	push   $0x20
f01049e3:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01049e5:	83 eb 01             	sub    $0x1,%ebx
f01049e8:	83 c4 10             	add    $0x10,%esp
f01049eb:	85 db                	test   %ebx,%ebx
f01049ed:	7f ee                	jg     f01049dd <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01049ef:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01049f2:	89 45 14             	mov    %eax,0x14(%ebp)
f01049f5:	e9 44 01 00 00       	jmp    f0104b3e <.L25+0x45>
f01049fa:	89 cb                	mov    %ecx,%ebx
f01049fc:	eb ed                	jmp    f01049eb <.L24+0xe2>

f01049fe <.L29>:
	if (lflag >= 2)
f01049fe:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104a01:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a04:	83 f9 01             	cmp    $0x1,%ecx
f0104a07:	7f 1b                	jg     f0104a24 <.L29+0x26>
	else if (lflag)
f0104a09:	85 c9                	test   %ecx,%ecx
f0104a0b:	74 63                	je     f0104a70 <.L29+0x72>
		return va_arg(*ap, long);
f0104a0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a10:	8b 00                	mov    (%eax),%eax
f0104a12:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a15:	99                   	cltd   
f0104a16:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a19:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a1c:	8d 40 04             	lea    0x4(%eax),%eax
f0104a1f:	89 45 14             	mov    %eax,0x14(%ebp)
f0104a22:	eb 17                	jmp    f0104a3b <.L29+0x3d>
		return va_arg(*ap, long long);
f0104a24:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a27:	8b 50 04             	mov    0x4(%eax),%edx
f0104a2a:	8b 00                	mov    (%eax),%eax
f0104a2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a2f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a32:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a35:	8d 40 08             	lea    0x8(%eax),%eax
f0104a38:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104a3b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a3e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0104a41:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0104a46:	85 db                	test   %ebx,%ebx
f0104a48:	0f 89 d6 00 00 00    	jns    f0104b24 <.L25+0x2b>
				putch('-', putdat);
f0104a4e:	83 ec 08             	sub    $0x8,%esp
f0104a51:	57                   	push   %edi
f0104a52:	6a 2d                	push   $0x2d
f0104a54:	ff d6                	call   *%esi
				num = -(long long) num;
f0104a56:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104a59:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104a5c:	f7 d9                	neg    %ecx
f0104a5e:	83 d3 00             	adc    $0x0,%ebx
f0104a61:	f7 db                	neg    %ebx
f0104a63:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104a66:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104a6b:	e9 b4 00 00 00       	jmp    f0104b24 <.L25+0x2b>
		return va_arg(*ap, int);
f0104a70:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a73:	8b 00                	mov    (%eax),%eax
f0104a75:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104a78:	99                   	cltd   
f0104a79:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104a7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a7f:	8d 40 04             	lea    0x4(%eax),%eax
f0104a82:	89 45 14             	mov    %eax,0x14(%ebp)
f0104a85:	eb b4                	jmp    f0104a3b <.L29+0x3d>

f0104a87 <.L23>:
	if (lflag >= 2)
f0104a87:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104a8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a8d:	83 f9 01             	cmp    $0x1,%ecx
f0104a90:	7f 1b                	jg     f0104aad <.L23+0x26>
	else if (lflag)
f0104a92:	85 c9                	test   %ecx,%ecx
f0104a94:	74 2c                	je     f0104ac2 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0104a96:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a99:	8b 08                	mov    (%eax),%ecx
f0104a9b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104aa0:	8d 40 04             	lea    0x4(%eax),%eax
f0104aa3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104aa6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104aab:	eb 77                	jmp    f0104b24 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104aad:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ab0:	8b 08                	mov    (%eax),%ecx
f0104ab2:	8b 58 04             	mov    0x4(%eax),%ebx
f0104ab5:	8d 40 08             	lea    0x8(%eax),%eax
f0104ab8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104abb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0104ac0:	eb 62                	jmp    f0104b24 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104ac2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac5:	8b 08                	mov    (%eax),%ecx
f0104ac7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104acc:	8d 40 04             	lea    0x4(%eax),%eax
f0104acf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104ad2:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0104ad7:	eb 4b                	jmp    f0104b24 <.L25+0x2b>

f0104ad9 <.L26>:
			putch('X', putdat);
f0104ad9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104adc:	83 ec 08             	sub    $0x8,%esp
f0104adf:	57                   	push   %edi
f0104ae0:	6a 58                	push   $0x58
f0104ae2:	ff d6                	call   *%esi
			putch('X', putdat);
f0104ae4:	83 c4 08             	add    $0x8,%esp
f0104ae7:	57                   	push   %edi
f0104ae8:	6a 58                	push   $0x58
f0104aea:	ff d6                	call   *%esi
			putch('X', putdat);
f0104aec:	83 c4 08             	add    $0x8,%esp
f0104aef:	57                   	push   %edi
f0104af0:	6a 58                	push   $0x58
f0104af2:	ff d6                	call   *%esi
			break;
f0104af4:	83 c4 10             	add    $0x10,%esp
f0104af7:	eb 45                	jmp    f0104b3e <.L25+0x45>

f0104af9 <.L25>:
			putch('0', putdat);
f0104af9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104afc:	83 ec 08             	sub    $0x8,%esp
f0104aff:	57                   	push   %edi
f0104b00:	6a 30                	push   $0x30
f0104b02:	ff d6                	call   *%esi
			putch('x', putdat);
f0104b04:	83 c4 08             	add    $0x8,%esp
f0104b07:	57                   	push   %edi
f0104b08:	6a 78                	push   $0x78
f0104b0a:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104b0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b0f:	8b 08                	mov    (%eax),%ecx
f0104b11:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0104b16:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104b19:	8d 40 04             	lea    0x4(%eax),%eax
f0104b1c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b1f:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104b24:	83 ec 0c             	sub    $0xc,%esp
f0104b27:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104b2b:	50                   	push   %eax
f0104b2c:	ff 75 d0             	push   -0x30(%ebp)
f0104b2f:	52                   	push   %edx
f0104b30:	53                   	push   %ebx
f0104b31:	51                   	push   %ecx
f0104b32:	89 fa                	mov    %edi,%edx
f0104b34:	89 f0                	mov    %esi,%eax
f0104b36:	e8 2c fb ff ff       	call   f0104667 <printnum>
			break;
f0104b3b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104b3e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104b41:	e9 4d fc ff ff       	jmp    f0104793 <vprintfmt+0x34>

f0104b46 <.L21>:
	if (lflag >= 2)
f0104b46:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104b49:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b4c:	83 f9 01             	cmp    $0x1,%ecx
f0104b4f:	7f 1b                	jg     f0104b6c <.L21+0x26>
	else if (lflag)
f0104b51:	85 c9                	test   %ecx,%ecx
f0104b53:	74 2c                	je     f0104b81 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0104b55:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b58:	8b 08                	mov    (%eax),%ecx
f0104b5a:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b5f:	8d 40 04             	lea    0x4(%eax),%eax
f0104b62:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b65:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0104b6a:	eb b8                	jmp    f0104b24 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104b6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b6f:	8b 08                	mov    (%eax),%ecx
f0104b71:	8b 58 04             	mov    0x4(%eax),%ebx
f0104b74:	8d 40 08             	lea    0x8(%eax),%eax
f0104b77:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b7a:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0104b7f:	eb a3                	jmp    f0104b24 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104b81:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b84:	8b 08                	mov    (%eax),%ecx
f0104b86:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b8b:	8d 40 04             	lea    0x4(%eax),%eax
f0104b8e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b91:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0104b96:	eb 8c                	jmp    f0104b24 <.L25+0x2b>

f0104b98 <.L35>:
			putch(ch, putdat);
f0104b98:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b9b:	83 ec 08             	sub    $0x8,%esp
f0104b9e:	57                   	push   %edi
f0104b9f:	6a 25                	push   $0x25
f0104ba1:	ff d6                	call   *%esi
			break;
f0104ba3:	83 c4 10             	add    $0x10,%esp
f0104ba6:	eb 96                	jmp    f0104b3e <.L25+0x45>

f0104ba8 <.L20>:
			putch('%', putdat);
f0104ba8:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bab:	83 ec 08             	sub    $0x8,%esp
f0104bae:	57                   	push   %edi
f0104baf:	6a 25                	push   $0x25
f0104bb1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104bb3:	83 c4 10             	add    $0x10,%esp
f0104bb6:	89 d8                	mov    %ebx,%eax
f0104bb8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104bbc:	74 05                	je     f0104bc3 <.L20+0x1b>
f0104bbe:	83 e8 01             	sub    $0x1,%eax
f0104bc1:	eb f5                	jmp    f0104bb8 <.L20+0x10>
f0104bc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104bc6:	e9 73 ff ff ff       	jmp    f0104b3e <.L25+0x45>

f0104bcb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104bcb:	55                   	push   %ebp
f0104bcc:	89 e5                	mov    %esp,%ebp
f0104bce:	53                   	push   %ebx
f0104bcf:	83 ec 14             	sub    $0x14,%esp
f0104bd2:	e8 90 b5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104bd7:	81 c3 91 ac 07 00    	add    $0x7ac91,%ebx
f0104bdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104be0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104be3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104be6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104bea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104bed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104bf4:	85 c0                	test   %eax,%eax
f0104bf6:	74 2b                	je     f0104c23 <vsnprintf+0x58>
f0104bf8:	85 d2                	test   %edx,%edx
f0104bfa:	7e 27                	jle    f0104c23 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104bfc:	ff 75 14             	push   0x14(%ebp)
f0104bff:	ff 75 10             	push   0x10(%ebp)
f0104c02:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104c05:	50                   	push   %eax
f0104c06:	8d 83 bd 4e f8 ff    	lea    -0x7b143(%ebx),%eax
f0104c0c:	50                   	push   %eax
f0104c0d:	e8 4d fb ff ff       	call   f010475f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104c12:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104c15:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104c1b:	83 c4 10             	add    $0x10,%esp
}
f0104c1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104c21:	c9                   	leave  
f0104c22:	c3                   	ret    
		return -E_INVAL;
f0104c23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104c28:	eb f4                	jmp    f0104c1e <vsnprintf+0x53>

f0104c2a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104c2a:	55                   	push   %ebp
f0104c2b:	89 e5                	mov    %esp,%ebp
f0104c2d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104c30:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104c33:	50                   	push   %eax
f0104c34:	ff 75 10             	push   0x10(%ebp)
f0104c37:	ff 75 0c             	push   0xc(%ebp)
f0104c3a:	ff 75 08             	push   0x8(%ebp)
f0104c3d:	e8 89 ff ff ff       	call   f0104bcb <vsnprintf>
	va_end(ap);

	return rc;
}
f0104c42:	c9                   	leave  
f0104c43:	c3                   	ret    

f0104c44 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104c44:	55                   	push   %ebp
f0104c45:	89 e5                	mov    %esp,%ebp
f0104c47:	57                   	push   %edi
f0104c48:	56                   	push   %esi
f0104c49:	53                   	push   %ebx
f0104c4a:	83 ec 1c             	sub    $0x1c,%esp
f0104c4d:	e8 15 b5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104c52:	81 c3 16 ac 07 00    	add    $0x7ac16,%ebx
f0104c58:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104c5b:	85 c0                	test   %eax,%eax
f0104c5d:	74 13                	je     f0104c72 <readline+0x2e>
		cprintf("%s", prompt);
f0104c5f:	83 ec 08             	sub    $0x8,%esp
f0104c62:	50                   	push   %eax
f0104c63:	8d 83 95 67 f8 ff    	lea    -0x7986b(%ebx),%eax
f0104c69:	50                   	push   %eax
f0104c6a:	e8 d8 ec ff ff       	call   f0103947 <cprintf>
f0104c6f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104c72:	83 ec 0c             	sub    $0xc,%esp
f0104c75:	6a 00                	push   $0x0
f0104c77:	e8 77 ba ff ff       	call   f01006f3 <iscons>
f0104c7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c7f:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104c82:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0104c87:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f0104c8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104c90:	eb 45                	jmp    f0104cd7 <readline+0x93>
			cprintf("read error: %e\n", c);
f0104c92:	83 ec 08             	sub    $0x8,%esp
f0104c95:	50                   	push   %eax
f0104c96:	8d 83 88 70 f8 ff    	lea    -0x78f78(%ebx),%eax
f0104c9c:	50                   	push   %eax
f0104c9d:	e8 a5 ec ff ff       	call   f0103947 <cprintf>
			return NULL;
f0104ca2:	83 c4 10             	add    $0x10,%esp
f0104ca5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104cad:	5b                   	pop    %ebx
f0104cae:	5e                   	pop    %esi
f0104caf:	5f                   	pop    %edi
f0104cb0:	5d                   	pop    %ebp
f0104cb1:	c3                   	ret    
			if (echoing)
f0104cb2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104cb6:	75 05                	jne    f0104cbd <readline+0x79>
			i--;
f0104cb8:	83 ef 01             	sub    $0x1,%edi
f0104cbb:	eb 1a                	jmp    f0104cd7 <readline+0x93>
				cputchar('\b');
f0104cbd:	83 ec 0c             	sub    $0xc,%esp
f0104cc0:	6a 08                	push   $0x8
f0104cc2:	e8 0b ba ff ff       	call   f01006d2 <cputchar>
f0104cc7:	83 c4 10             	add    $0x10,%esp
f0104cca:	eb ec                	jmp    f0104cb8 <readline+0x74>
			buf[i++] = c;
f0104ccc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104ccf:	89 f0                	mov    %esi,%eax
f0104cd1:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0104cd4:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104cd7:	e8 06 ba ff ff       	call   f01006e2 <getchar>
f0104cdc:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104cde:	85 c0                	test   %eax,%eax
f0104ce0:	78 b0                	js     f0104c92 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104ce2:	83 f8 08             	cmp    $0x8,%eax
f0104ce5:	0f 94 c0             	sete   %al
f0104ce8:	83 fe 7f             	cmp    $0x7f,%esi
f0104ceb:	0f 94 c2             	sete   %dl
f0104cee:	08 d0                	or     %dl,%al
f0104cf0:	74 04                	je     f0104cf6 <readline+0xb2>
f0104cf2:	85 ff                	test   %edi,%edi
f0104cf4:	7f bc                	jg     f0104cb2 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104cf6:	83 fe 1f             	cmp    $0x1f,%esi
f0104cf9:	7e 1c                	jle    f0104d17 <readline+0xd3>
f0104cfb:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104d01:	7f 14                	jg     f0104d17 <readline+0xd3>
			if (echoing)
f0104d03:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d07:	74 c3                	je     f0104ccc <readline+0x88>
				cputchar(c);
f0104d09:	83 ec 0c             	sub    $0xc,%esp
f0104d0c:	56                   	push   %esi
f0104d0d:	e8 c0 b9 ff ff       	call   f01006d2 <cputchar>
f0104d12:	83 c4 10             	add    $0x10,%esp
f0104d15:	eb b5                	jmp    f0104ccc <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0104d17:	83 fe 0a             	cmp    $0xa,%esi
f0104d1a:	74 05                	je     f0104d21 <readline+0xdd>
f0104d1c:	83 fe 0d             	cmp    $0xd,%esi
f0104d1f:	75 b6                	jne    f0104cd7 <readline+0x93>
			if (echoing)
f0104d21:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104d25:	75 13                	jne    f0104d3a <readline+0xf6>
			buf[i] = 0;
f0104d27:	c6 84 3b 98 23 00 00 	movb   $0x0,0x2398(%ebx,%edi,1)
f0104d2e:	00 
			return buf;
f0104d2f:	8d 83 98 23 00 00    	lea    0x2398(%ebx),%eax
f0104d35:	e9 70 ff ff ff       	jmp    f0104caa <readline+0x66>
				cputchar('\n');
f0104d3a:	83 ec 0c             	sub    $0xc,%esp
f0104d3d:	6a 0a                	push   $0xa
f0104d3f:	e8 8e b9 ff ff       	call   f01006d2 <cputchar>
f0104d44:	83 c4 10             	add    $0x10,%esp
f0104d47:	eb de                	jmp    f0104d27 <readline+0xe3>

f0104d49 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104d49:	55                   	push   %ebp
f0104d4a:	89 e5                	mov    %esp,%ebp
f0104d4c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104d4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d54:	eb 03                	jmp    f0104d59 <strlen+0x10>
		n++;
f0104d56:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104d59:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104d5d:	75 f7                	jne    f0104d56 <strlen+0xd>
	return n;
}
f0104d5f:	5d                   	pop    %ebp
f0104d60:	c3                   	ret    

f0104d61 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104d61:	55                   	push   %ebp
f0104d62:	89 e5                	mov    %esp,%ebp
f0104d64:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d67:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104d6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d6f:	eb 03                	jmp    f0104d74 <strnlen+0x13>
		n++;
f0104d71:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104d74:	39 d0                	cmp    %edx,%eax
f0104d76:	74 08                	je     f0104d80 <strnlen+0x1f>
f0104d78:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104d7c:	75 f3                	jne    f0104d71 <strnlen+0x10>
f0104d7e:	89 c2                	mov    %eax,%edx
	return n;
}
f0104d80:	89 d0                	mov    %edx,%eax
f0104d82:	5d                   	pop    %ebp
f0104d83:	c3                   	ret    

f0104d84 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104d84:	55                   	push   %ebp
f0104d85:	89 e5                	mov    %esp,%ebp
f0104d87:	53                   	push   %ebx
f0104d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104d8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104d8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d93:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0104d97:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0104d9a:	83 c0 01             	add    $0x1,%eax
f0104d9d:	84 d2                	test   %dl,%dl
f0104d9f:	75 f2                	jne    f0104d93 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0104da1:	89 c8                	mov    %ecx,%eax
f0104da3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104da6:	c9                   	leave  
f0104da7:	c3                   	ret    

f0104da8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104da8:	55                   	push   %ebp
f0104da9:	89 e5                	mov    %esp,%ebp
f0104dab:	53                   	push   %ebx
f0104dac:	83 ec 10             	sub    $0x10,%esp
f0104daf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104db2:	53                   	push   %ebx
f0104db3:	e8 91 ff ff ff       	call   f0104d49 <strlen>
f0104db8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0104dbb:	ff 75 0c             	push   0xc(%ebp)
f0104dbe:	01 d8                	add    %ebx,%eax
f0104dc0:	50                   	push   %eax
f0104dc1:	e8 be ff ff ff       	call   f0104d84 <strcpy>
	return dst;
}
f0104dc6:	89 d8                	mov    %ebx,%eax
f0104dc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104dcb:	c9                   	leave  
f0104dcc:	c3                   	ret    

f0104dcd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104dcd:	55                   	push   %ebp
f0104dce:	89 e5                	mov    %esp,%ebp
f0104dd0:	56                   	push   %esi
f0104dd1:	53                   	push   %ebx
f0104dd2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104dd5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104dd8:	89 f3                	mov    %esi,%ebx
f0104dda:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ddd:	89 f0                	mov    %esi,%eax
f0104ddf:	eb 0f                	jmp    f0104df0 <strncpy+0x23>
		*dst++ = *src;
f0104de1:	83 c0 01             	add    $0x1,%eax
f0104de4:	0f b6 0a             	movzbl (%edx),%ecx
f0104de7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104dea:	80 f9 01             	cmp    $0x1,%cl
f0104ded:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0104df0:	39 d8                	cmp    %ebx,%eax
f0104df2:	75 ed                	jne    f0104de1 <strncpy+0x14>
	}
	return ret;
}
f0104df4:	89 f0                	mov    %esi,%eax
f0104df6:	5b                   	pop    %ebx
f0104df7:	5e                   	pop    %esi
f0104df8:	5d                   	pop    %ebp
f0104df9:	c3                   	ret    

f0104dfa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104dfa:	55                   	push   %ebp
f0104dfb:	89 e5                	mov    %esp,%ebp
f0104dfd:	56                   	push   %esi
f0104dfe:	53                   	push   %ebx
f0104dff:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104e05:	8b 55 10             	mov    0x10(%ebp),%edx
f0104e08:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104e0a:	85 d2                	test   %edx,%edx
f0104e0c:	74 21                	je     f0104e2f <strlcpy+0x35>
f0104e0e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104e12:	89 f2                	mov    %esi,%edx
f0104e14:	eb 09                	jmp    f0104e1f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104e16:	83 c1 01             	add    $0x1,%ecx
f0104e19:	83 c2 01             	add    $0x1,%edx
f0104e1c:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0104e1f:	39 c2                	cmp    %eax,%edx
f0104e21:	74 09                	je     f0104e2c <strlcpy+0x32>
f0104e23:	0f b6 19             	movzbl (%ecx),%ebx
f0104e26:	84 db                	test   %bl,%bl
f0104e28:	75 ec                	jne    f0104e16 <strlcpy+0x1c>
f0104e2a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0104e2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104e2f:	29 f0                	sub    %esi,%eax
}
f0104e31:	5b                   	pop    %ebx
f0104e32:	5e                   	pop    %esi
f0104e33:	5d                   	pop    %ebp
f0104e34:	c3                   	ret    

f0104e35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104e35:	55                   	push   %ebp
f0104e36:	89 e5                	mov    %esp,%ebp
f0104e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104e3e:	eb 06                	jmp    f0104e46 <strcmp+0x11>
		p++, q++;
f0104e40:	83 c1 01             	add    $0x1,%ecx
f0104e43:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104e46:	0f b6 01             	movzbl (%ecx),%eax
f0104e49:	84 c0                	test   %al,%al
f0104e4b:	74 04                	je     f0104e51 <strcmp+0x1c>
f0104e4d:	3a 02                	cmp    (%edx),%al
f0104e4f:	74 ef                	je     f0104e40 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e51:	0f b6 c0             	movzbl %al,%eax
f0104e54:	0f b6 12             	movzbl (%edx),%edx
f0104e57:	29 d0                	sub    %edx,%eax
}
f0104e59:	5d                   	pop    %ebp
f0104e5a:	c3                   	ret    

f0104e5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104e5b:	55                   	push   %ebp
f0104e5c:	89 e5                	mov    %esp,%ebp
f0104e5e:	53                   	push   %ebx
f0104e5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e62:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e65:	89 c3                	mov    %eax,%ebx
f0104e67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104e6a:	eb 06                	jmp    f0104e72 <strncmp+0x17>
		n--, p++, q++;
f0104e6c:	83 c0 01             	add    $0x1,%eax
f0104e6f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104e72:	39 d8                	cmp    %ebx,%eax
f0104e74:	74 18                	je     f0104e8e <strncmp+0x33>
f0104e76:	0f b6 08             	movzbl (%eax),%ecx
f0104e79:	84 c9                	test   %cl,%cl
f0104e7b:	74 04                	je     f0104e81 <strncmp+0x26>
f0104e7d:	3a 0a                	cmp    (%edx),%cl
f0104e7f:	74 eb                	je     f0104e6c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104e81:	0f b6 00             	movzbl (%eax),%eax
f0104e84:	0f b6 12             	movzbl (%edx),%edx
f0104e87:	29 d0                	sub    %edx,%eax
}
f0104e89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104e8c:	c9                   	leave  
f0104e8d:	c3                   	ret    
		return 0;
f0104e8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e93:	eb f4                	jmp    f0104e89 <strncmp+0x2e>

f0104e95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104e95:	55                   	push   %ebp
f0104e96:	89 e5                	mov    %esp,%ebp
f0104e98:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e9f:	eb 03                	jmp    f0104ea4 <strchr+0xf>
f0104ea1:	83 c0 01             	add    $0x1,%eax
f0104ea4:	0f b6 10             	movzbl (%eax),%edx
f0104ea7:	84 d2                	test   %dl,%dl
f0104ea9:	74 06                	je     f0104eb1 <strchr+0x1c>
		if (*s == c)
f0104eab:	38 ca                	cmp    %cl,%dl
f0104ead:	75 f2                	jne    f0104ea1 <strchr+0xc>
f0104eaf:	eb 05                	jmp    f0104eb6 <strchr+0x21>
			return (char *) s;
	return 0;
f0104eb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104eb6:	5d                   	pop    %ebp
f0104eb7:	c3                   	ret    

f0104eb8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104eb8:	55                   	push   %ebp
f0104eb9:	89 e5                	mov    %esp,%ebp
f0104ebb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ebe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ec2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104ec5:	38 ca                	cmp    %cl,%dl
f0104ec7:	74 09                	je     f0104ed2 <strfind+0x1a>
f0104ec9:	84 d2                	test   %dl,%dl
f0104ecb:	74 05                	je     f0104ed2 <strfind+0x1a>
	for (; *s; s++)
f0104ecd:	83 c0 01             	add    $0x1,%eax
f0104ed0:	eb f0                	jmp    f0104ec2 <strfind+0xa>
			break;
	return (char *) s;
}
f0104ed2:	5d                   	pop    %ebp
f0104ed3:	c3                   	ret    

f0104ed4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104ed4:	55                   	push   %ebp
f0104ed5:	89 e5                	mov    %esp,%ebp
f0104ed7:	57                   	push   %edi
f0104ed8:	56                   	push   %esi
f0104ed9:	53                   	push   %ebx
f0104eda:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104edd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104ee0:	85 c9                	test   %ecx,%ecx
f0104ee2:	74 2f                	je     f0104f13 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104ee4:	89 f8                	mov    %edi,%eax
f0104ee6:	09 c8                	or     %ecx,%eax
f0104ee8:	a8 03                	test   $0x3,%al
f0104eea:	75 21                	jne    f0104f0d <memset+0x39>
		c &= 0xFF;
f0104eec:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104ef0:	89 d0                	mov    %edx,%eax
f0104ef2:	c1 e0 08             	shl    $0x8,%eax
f0104ef5:	89 d3                	mov    %edx,%ebx
f0104ef7:	c1 e3 18             	shl    $0x18,%ebx
f0104efa:	89 d6                	mov    %edx,%esi
f0104efc:	c1 e6 10             	shl    $0x10,%esi
f0104eff:	09 f3                	or     %esi,%ebx
f0104f01:	09 da                	or     %ebx,%edx
f0104f03:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104f05:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104f08:	fc                   	cld    
f0104f09:	f3 ab                	rep stos %eax,%es:(%edi)
f0104f0b:	eb 06                	jmp    f0104f13 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f10:	fc                   	cld    
f0104f11:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104f13:	89 f8                	mov    %edi,%eax
f0104f15:	5b                   	pop    %ebx
f0104f16:	5e                   	pop    %esi
f0104f17:	5f                   	pop    %edi
f0104f18:	5d                   	pop    %ebp
f0104f19:	c3                   	ret    

f0104f1a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104f1a:	55                   	push   %ebp
f0104f1b:	89 e5                	mov    %esp,%ebp
f0104f1d:	57                   	push   %edi
f0104f1e:	56                   	push   %esi
f0104f1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f22:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104f25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104f28:	39 c6                	cmp    %eax,%esi
f0104f2a:	73 32                	jae    f0104f5e <memmove+0x44>
f0104f2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104f2f:	39 c2                	cmp    %eax,%edx
f0104f31:	76 2b                	jbe    f0104f5e <memmove+0x44>
		s += n;
		d += n;
f0104f33:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f36:	89 d6                	mov    %edx,%esi
f0104f38:	09 fe                	or     %edi,%esi
f0104f3a:	09 ce                	or     %ecx,%esi
f0104f3c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104f42:	75 0e                	jne    f0104f52 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104f44:	83 ef 04             	sub    $0x4,%edi
f0104f47:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104f4a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104f4d:	fd                   	std    
f0104f4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f50:	eb 09                	jmp    f0104f5b <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104f52:	83 ef 01             	sub    $0x1,%edi
f0104f55:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104f58:	fd                   	std    
f0104f59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104f5b:	fc                   	cld    
f0104f5c:	eb 1a                	jmp    f0104f78 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104f5e:	89 f2                	mov    %esi,%edx
f0104f60:	09 c2                	or     %eax,%edx
f0104f62:	09 ca                	or     %ecx,%edx
f0104f64:	f6 c2 03             	test   $0x3,%dl
f0104f67:	75 0a                	jne    f0104f73 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104f69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104f6c:	89 c7                	mov    %eax,%edi
f0104f6e:	fc                   	cld    
f0104f6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104f71:	eb 05                	jmp    f0104f78 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0104f73:	89 c7                	mov    %eax,%edi
f0104f75:	fc                   	cld    
f0104f76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104f78:	5e                   	pop    %esi
f0104f79:	5f                   	pop    %edi
f0104f7a:	5d                   	pop    %ebp
f0104f7b:	c3                   	ret    

f0104f7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104f7c:	55                   	push   %ebp
f0104f7d:	89 e5                	mov    %esp,%ebp
f0104f7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104f82:	ff 75 10             	push   0x10(%ebp)
f0104f85:	ff 75 0c             	push   0xc(%ebp)
f0104f88:	ff 75 08             	push   0x8(%ebp)
f0104f8b:	e8 8a ff ff ff       	call   f0104f1a <memmove>
}
f0104f90:	c9                   	leave  
f0104f91:	c3                   	ret    

f0104f92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104f92:	55                   	push   %ebp
f0104f93:	89 e5                	mov    %esp,%ebp
f0104f95:	56                   	push   %esi
f0104f96:	53                   	push   %ebx
f0104f97:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f9a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f9d:	89 c6                	mov    %eax,%esi
f0104f9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104fa2:	eb 06                	jmp    f0104faa <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104fa4:	83 c0 01             	add    $0x1,%eax
f0104fa7:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0104faa:	39 f0                	cmp    %esi,%eax
f0104fac:	74 14                	je     f0104fc2 <memcmp+0x30>
		if (*s1 != *s2)
f0104fae:	0f b6 08             	movzbl (%eax),%ecx
f0104fb1:	0f b6 1a             	movzbl (%edx),%ebx
f0104fb4:	38 d9                	cmp    %bl,%cl
f0104fb6:	74 ec                	je     f0104fa4 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0104fb8:	0f b6 c1             	movzbl %cl,%eax
f0104fbb:	0f b6 db             	movzbl %bl,%ebx
f0104fbe:	29 d8                	sub    %ebx,%eax
f0104fc0:	eb 05                	jmp    f0104fc7 <memcmp+0x35>
	}

	return 0;
f0104fc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104fc7:	5b                   	pop    %ebx
f0104fc8:	5e                   	pop    %esi
f0104fc9:	5d                   	pop    %ebp
f0104fca:	c3                   	ret    

f0104fcb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104fcb:	55                   	push   %ebp
f0104fcc:	89 e5                	mov    %esp,%ebp
f0104fce:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104fd4:	89 c2                	mov    %eax,%edx
f0104fd6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104fd9:	eb 03                	jmp    f0104fde <memfind+0x13>
f0104fdb:	83 c0 01             	add    $0x1,%eax
f0104fde:	39 d0                	cmp    %edx,%eax
f0104fe0:	73 04                	jae    f0104fe6 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104fe2:	38 08                	cmp    %cl,(%eax)
f0104fe4:	75 f5                	jne    f0104fdb <memfind+0x10>
			break;
	return (void *) s;
}
f0104fe6:	5d                   	pop    %ebp
f0104fe7:	c3                   	ret    

f0104fe8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104fe8:	55                   	push   %ebp
f0104fe9:	89 e5                	mov    %esp,%ebp
f0104feb:	57                   	push   %edi
f0104fec:	56                   	push   %esi
f0104fed:	53                   	push   %ebx
f0104fee:	8b 55 08             	mov    0x8(%ebp),%edx
f0104ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104ff4:	eb 03                	jmp    f0104ff9 <strtol+0x11>
		s++;
f0104ff6:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0104ff9:	0f b6 02             	movzbl (%edx),%eax
f0104ffc:	3c 20                	cmp    $0x20,%al
f0104ffe:	74 f6                	je     f0104ff6 <strtol+0xe>
f0105000:	3c 09                	cmp    $0x9,%al
f0105002:	74 f2                	je     f0104ff6 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105004:	3c 2b                	cmp    $0x2b,%al
f0105006:	74 2a                	je     f0105032 <strtol+0x4a>
	int neg = 0;
f0105008:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010500d:	3c 2d                	cmp    $0x2d,%al
f010500f:	74 2b                	je     f010503c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105011:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105017:	75 0f                	jne    f0105028 <strtol+0x40>
f0105019:	80 3a 30             	cmpb   $0x30,(%edx)
f010501c:	74 28                	je     f0105046 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010501e:	85 db                	test   %ebx,%ebx
f0105020:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105025:	0f 44 d8             	cmove  %eax,%ebx
f0105028:	b9 00 00 00 00       	mov    $0x0,%ecx
f010502d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105030:	eb 46                	jmp    f0105078 <strtol+0x90>
		s++;
f0105032:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105035:	bf 00 00 00 00       	mov    $0x0,%edi
f010503a:	eb d5                	jmp    f0105011 <strtol+0x29>
		s++, neg = 1;
f010503c:	83 c2 01             	add    $0x1,%edx
f010503f:	bf 01 00 00 00       	mov    $0x1,%edi
f0105044:	eb cb                	jmp    f0105011 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105046:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010504a:	74 0e                	je     f010505a <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010504c:	85 db                	test   %ebx,%ebx
f010504e:	75 d8                	jne    f0105028 <strtol+0x40>
		s++, base = 8;
f0105050:	83 c2 01             	add    $0x1,%edx
f0105053:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105058:	eb ce                	jmp    f0105028 <strtol+0x40>
		s += 2, base = 16;
f010505a:	83 c2 02             	add    $0x2,%edx
f010505d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105062:	eb c4                	jmp    f0105028 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105064:	0f be c0             	movsbl %al,%eax
f0105067:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010506a:	3b 45 10             	cmp    0x10(%ebp),%eax
f010506d:	7d 3a                	jge    f01050a9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f010506f:	83 c2 01             	add    $0x1,%edx
f0105072:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105076:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0105078:	0f b6 02             	movzbl (%edx),%eax
f010507b:	8d 70 d0             	lea    -0x30(%eax),%esi
f010507e:	89 f3                	mov    %esi,%ebx
f0105080:	80 fb 09             	cmp    $0x9,%bl
f0105083:	76 df                	jbe    f0105064 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105085:	8d 70 9f             	lea    -0x61(%eax),%esi
f0105088:	89 f3                	mov    %esi,%ebx
f010508a:	80 fb 19             	cmp    $0x19,%bl
f010508d:	77 08                	ja     f0105097 <strtol+0xaf>
			dig = *s - 'a' + 10;
f010508f:	0f be c0             	movsbl %al,%eax
f0105092:	83 e8 57             	sub    $0x57,%eax
f0105095:	eb d3                	jmp    f010506a <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105097:	8d 70 bf             	lea    -0x41(%eax),%esi
f010509a:	89 f3                	mov    %esi,%ebx
f010509c:	80 fb 19             	cmp    $0x19,%bl
f010509f:	77 08                	ja     f01050a9 <strtol+0xc1>
			dig = *s - 'A' + 10;
f01050a1:	0f be c0             	movsbl %al,%eax
f01050a4:	83 e8 37             	sub    $0x37,%eax
f01050a7:	eb c1                	jmp    f010506a <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01050a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01050ad:	74 05                	je     f01050b4 <strtol+0xcc>
		*endptr = (char *) s;
f01050af:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050b2:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01050b4:	89 c8                	mov    %ecx,%eax
f01050b6:	f7 d8                	neg    %eax
f01050b8:	85 ff                	test   %edi,%edi
f01050ba:	0f 45 c8             	cmovne %eax,%ecx
}
f01050bd:	89 c8                	mov    %ecx,%eax
f01050bf:	5b                   	pop    %ebx
f01050c0:	5e                   	pop    %esi
f01050c1:	5f                   	pop    %edi
f01050c2:	5d                   	pop    %ebp
f01050c3:	c3                   	ret    
f01050c4:	66 90                	xchg   %ax,%ax
f01050c6:	66 90                	xchg   %ax,%ax
f01050c8:	66 90                	xchg   %ax,%ax
f01050ca:	66 90                	xchg   %ax,%ax
f01050cc:	66 90                	xchg   %ax,%ax
f01050ce:	66 90                	xchg   %ax,%ax

f01050d0 <__udivdi3>:
f01050d0:	f3 0f 1e fb          	endbr32 
f01050d4:	55                   	push   %ebp
f01050d5:	57                   	push   %edi
f01050d6:	56                   	push   %esi
f01050d7:	53                   	push   %ebx
f01050d8:	83 ec 1c             	sub    $0x1c,%esp
f01050db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01050df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01050e3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01050e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01050eb:	85 c0                	test   %eax,%eax
f01050ed:	75 19                	jne    f0105108 <__udivdi3+0x38>
f01050ef:	39 f3                	cmp    %esi,%ebx
f01050f1:	76 4d                	jbe    f0105140 <__udivdi3+0x70>
f01050f3:	31 ff                	xor    %edi,%edi
f01050f5:	89 e8                	mov    %ebp,%eax
f01050f7:	89 f2                	mov    %esi,%edx
f01050f9:	f7 f3                	div    %ebx
f01050fb:	89 fa                	mov    %edi,%edx
f01050fd:	83 c4 1c             	add    $0x1c,%esp
f0105100:	5b                   	pop    %ebx
f0105101:	5e                   	pop    %esi
f0105102:	5f                   	pop    %edi
f0105103:	5d                   	pop    %ebp
f0105104:	c3                   	ret    
f0105105:	8d 76 00             	lea    0x0(%esi),%esi
f0105108:	39 f0                	cmp    %esi,%eax
f010510a:	76 14                	jbe    f0105120 <__udivdi3+0x50>
f010510c:	31 ff                	xor    %edi,%edi
f010510e:	31 c0                	xor    %eax,%eax
f0105110:	89 fa                	mov    %edi,%edx
f0105112:	83 c4 1c             	add    $0x1c,%esp
f0105115:	5b                   	pop    %ebx
f0105116:	5e                   	pop    %esi
f0105117:	5f                   	pop    %edi
f0105118:	5d                   	pop    %ebp
f0105119:	c3                   	ret    
f010511a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105120:	0f bd f8             	bsr    %eax,%edi
f0105123:	83 f7 1f             	xor    $0x1f,%edi
f0105126:	75 48                	jne    f0105170 <__udivdi3+0xa0>
f0105128:	39 f0                	cmp    %esi,%eax
f010512a:	72 06                	jb     f0105132 <__udivdi3+0x62>
f010512c:	31 c0                	xor    %eax,%eax
f010512e:	39 eb                	cmp    %ebp,%ebx
f0105130:	77 de                	ja     f0105110 <__udivdi3+0x40>
f0105132:	b8 01 00 00 00       	mov    $0x1,%eax
f0105137:	eb d7                	jmp    f0105110 <__udivdi3+0x40>
f0105139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105140:	89 d9                	mov    %ebx,%ecx
f0105142:	85 db                	test   %ebx,%ebx
f0105144:	75 0b                	jne    f0105151 <__udivdi3+0x81>
f0105146:	b8 01 00 00 00       	mov    $0x1,%eax
f010514b:	31 d2                	xor    %edx,%edx
f010514d:	f7 f3                	div    %ebx
f010514f:	89 c1                	mov    %eax,%ecx
f0105151:	31 d2                	xor    %edx,%edx
f0105153:	89 f0                	mov    %esi,%eax
f0105155:	f7 f1                	div    %ecx
f0105157:	89 c6                	mov    %eax,%esi
f0105159:	89 e8                	mov    %ebp,%eax
f010515b:	89 f7                	mov    %esi,%edi
f010515d:	f7 f1                	div    %ecx
f010515f:	89 fa                	mov    %edi,%edx
f0105161:	83 c4 1c             	add    $0x1c,%esp
f0105164:	5b                   	pop    %ebx
f0105165:	5e                   	pop    %esi
f0105166:	5f                   	pop    %edi
f0105167:	5d                   	pop    %ebp
f0105168:	c3                   	ret    
f0105169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105170:	89 f9                	mov    %edi,%ecx
f0105172:	ba 20 00 00 00       	mov    $0x20,%edx
f0105177:	29 fa                	sub    %edi,%edx
f0105179:	d3 e0                	shl    %cl,%eax
f010517b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010517f:	89 d1                	mov    %edx,%ecx
f0105181:	89 d8                	mov    %ebx,%eax
f0105183:	d3 e8                	shr    %cl,%eax
f0105185:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105189:	09 c1                	or     %eax,%ecx
f010518b:	89 f0                	mov    %esi,%eax
f010518d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105191:	89 f9                	mov    %edi,%ecx
f0105193:	d3 e3                	shl    %cl,%ebx
f0105195:	89 d1                	mov    %edx,%ecx
f0105197:	d3 e8                	shr    %cl,%eax
f0105199:	89 f9                	mov    %edi,%ecx
f010519b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010519f:	89 eb                	mov    %ebp,%ebx
f01051a1:	d3 e6                	shl    %cl,%esi
f01051a3:	89 d1                	mov    %edx,%ecx
f01051a5:	d3 eb                	shr    %cl,%ebx
f01051a7:	09 f3                	or     %esi,%ebx
f01051a9:	89 c6                	mov    %eax,%esi
f01051ab:	89 f2                	mov    %esi,%edx
f01051ad:	89 d8                	mov    %ebx,%eax
f01051af:	f7 74 24 08          	divl   0x8(%esp)
f01051b3:	89 d6                	mov    %edx,%esi
f01051b5:	89 c3                	mov    %eax,%ebx
f01051b7:	f7 64 24 0c          	mull   0xc(%esp)
f01051bb:	39 d6                	cmp    %edx,%esi
f01051bd:	72 19                	jb     f01051d8 <__udivdi3+0x108>
f01051bf:	89 f9                	mov    %edi,%ecx
f01051c1:	d3 e5                	shl    %cl,%ebp
f01051c3:	39 c5                	cmp    %eax,%ebp
f01051c5:	73 04                	jae    f01051cb <__udivdi3+0xfb>
f01051c7:	39 d6                	cmp    %edx,%esi
f01051c9:	74 0d                	je     f01051d8 <__udivdi3+0x108>
f01051cb:	89 d8                	mov    %ebx,%eax
f01051cd:	31 ff                	xor    %edi,%edi
f01051cf:	e9 3c ff ff ff       	jmp    f0105110 <__udivdi3+0x40>
f01051d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01051d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01051db:	31 ff                	xor    %edi,%edi
f01051dd:	e9 2e ff ff ff       	jmp    f0105110 <__udivdi3+0x40>
f01051e2:	66 90                	xchg   %ax,%ax
f01051e4:	66 90                	xchg   %ax,%ax
f01051e6:	66 90                	xchg   %ax,%ax
f01051e8:	66 90                	xchg   %ax,%ax
f01051ea:	66 90                	xchg   %ax,%ax
f01051ec:	66 90                	xchg   %ax,%ax
f01051ee:	66 90                	xchg   %ax,%ax

f01051f0 <__umoddi3>:
f01051f0:	f3 0f 1e fb          	endbr32 
f01051f4:	55                   	push   %ebp
f01051f5:	57                   	push   %edi
f01051f6:	56                   	push   %esi
f01051f7:	53                   	push   %ebx
f01051f8:	83 ec 1c             	sub    $0x1c,%esp
f01051fb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01051ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105203:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0105207:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010520b:	89 f0                	mov    %esi,%eax
f010520d:	89 da                	mov    %ebx,%edx
f010520f:	85 ff                	test   %edi,%edi
f0105211:	75 15                	jne    f0105228 <__umoddi3+0x38>
f0105213:	39 dd                	cmp    %ebx,%ebp
f0105215:	76 39                	jbe    f0105250 <__umoddi3+0x60>
f0105217:	f7 f5                	div    %ebp
f0105219:	89 d0                	mov    %edx,%eax
f010521b:	31 d2                	xor    %edx,%edx
f010521d:	83 c4 1c             	add    $0x1c,%esp
f0105220:	5b                   	pop    %ebx
f0105221:	5e                   	pop    %esi
f0105222:	5f                   	pop    %edi
f0105223:	5d                   	pop    %ebp
f0105224:	c3                   	ret    
f0105225:	8d 76 00             	lea    0x0(%esi),%esi
f0105228:	39 df                	cmp    %ebx,%edi
f010522a:	77 f1                	ja     f010521d <__umoddi3+0x2d>
f010522c:	0f bd cf             	bsr    %edi,%ecx
f010522f:	83 f1 1f             	xor    $0x1f,%ecx
f0105232:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105236:	75 40                	jne    f0105278 <__umoddi3+0x88>
f0105238:	39 df                	cmp    %ebx,%edi
f010523a:	72 04                	jb     f0105240 <__umoddi3+0x50>
f010523c:	39 f5                	cmp    %esi,%ebp
f010523e:	77 dd                	ja     f010521d <__umoddi3+0x2d>
f0105240:	89 da                	mov    %ebx,%edx
f0105242:	89 f0                	mov    %esi,%eax
f0105244:	29 e8                	sub    %ebp,%eax
f0105246:	19 fa                	sbb    %edi,%edx
f0105248:	eb d3                	jmp    f010521d <__umoddi3+0x2d>
f010524a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105250:	89 e9                	mov    %ebp,%ecx
f0105252:	85 ed                	test   %ebp,%ebp
f0105254:	75 0b                	jne    f0105261 <__umoddi3+0x71>
f0105256:	b8 01 00 00 00       	mov    $0x1,%eax
f010525b:	31 d2                	xor    %edx,%edx
f010525d:	f7 f5                	div    %ebp
f010525f:	89 c1                	mov    %eax,%ecx
f0105261:	89 d8                	mov    %ebx,%eax
f0105263:	31 d2                	xor    %edx,%edx
f0105265:	f7 f1                	div    %ecx
f0105267:	89 f0                	mov    %esi,%eax
f0105269:	f7 f1                	div    %ecx
f010526b:	89 d0                	mov    %edx,%eax
f010526d:	31 d2                	xor    %edx,%edx
f010526f:	eb ac                	jmp    f010521d <__umoddi3+0x2d>
f0105271:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105278:	8b 44 24 04          	mov    0x4(%esp),%eax
f010527c:	ba 20 00 00 00       	mov    $0x20,%edx
f0105281:	29 c2                	sub    %eax,%edx
f0105283:	89 c1                	mov    %eax,%ecx
f0105285:	89 e8                	mov    %ebp,%eax
f0105287:	d3 e7                	shl    %cl,%edi
f0105289:	89 d1                	mov    %edx,%ecx
f010528b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010528f:	d3 e8                	shr    %cl,%eax
f0105291:	89 c1                	mov    %eax,%ecx
f0105293:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105297:	09 f9                	or     %edi,%ecx
f0105299:	89 df                	mov    %ebx,%edi
f010529b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010529f:	89 c1                	mov    %eax,%ecx
f01052a1:	d3 e5                	shl    %cl,%ebp
f01052a3:	89 d1                	mov    %edx,%ecx
f01052a5:	d3 ef                	shr    %cl,%edi
f01052a7:	89 c1                	mov    %eax,%ecx
f01052a9:	89 f0                	mov    %esi,%eax
f01052ab:	d3 e3                	shl    %cl,%ebx
f01052ad:	89 d1                	mov    %edx,%ecx
f01052af:	89 fa                	mov    %edi,%edx
f01052b1:	d3 e8                	shr    %cl,%eax
f01052b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01052b8:	09 d8                	or     %ebx,%eax
f01052ba:	f7 74 24 08          	divl   0x8(%esp)
f01052be:	89 d3                	mov    %edx,%ebx
f01052c0:	d3 e6                	shl    %cl,%esi
f01052c2:	f7 e5                	mul    %ebp
f01052c4:	89 c7                	mov    %eax,%edi
f01052c6:	89 d1                	mov    %edx,%ecx
f01052c8:	39 d3                	cmp    %edx,%ebx
f01052ca:	72 06                	jb     f01052d2 <__umoddi3+0xe2>
f01052cc:	75 0e                	jne    f01052dc <__umoddi3+0xec>
f01052ce:	39 c6                	cmp    %eax,%esi
f01052d0:	73 0a                	jae    f01052dc <__umoddi3+0xec>
f01052d2:	29 e8                	sub    %ebp,%eax
f01052d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01052d8:	89 d1                	mov    %edx,%ecx
f01052da:	89 c7                	mov    %eax,%edi
f01052dc:	89 f5                	mov    %esi,%ebp
f01052de:	8b 74 24 04          	mov    0x4(%esp),%esi
f01052e2:	29 fd                	sub    %edi,%ebp
f01052e4:	19 cb                	sbb    %ecx,%ebx
f01052e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01052eb:	89 d8                	mov    %ebx,%eax
f01052ed:	d3 e0                	shl    %cl,%eax
f01052ef:	89 f1                	mov    %esi,%ecx
f01052f1:	d3 ed                	shr    %cl,%ebp
f01052f3:	d3 eb                	shr    %cl,%ebx
f01052f5:	09 e8                	or     %ebp,%eax
f01052f7:	89 da                	mov    %ebx,%edx
f01052f9:	83 c4 1c             	add    $0x1c,%esp
f01052fc:	5b                   	pop    %ebx
f01052fd:	5e                   	pop    %esi
f01052fe:	5f                   	pop    %edi
f01052ff:	5d                   	pop    %ebp
f0105300:	c3                   	ret    
