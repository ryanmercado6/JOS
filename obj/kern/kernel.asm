
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 03 01 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010004c:	81 c3 c0 72 01 00    	add    $0x172c0,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c2 60 90 11 f0    	mov    $0xf0119060,%edx
f0100058:	c7 c0 e0 96 11 f0    	mov    $0xf01196e0,%eax
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 cc 3b 00 00       	call   f0103c35 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 37 05 00 00       	call   f01005a5 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 74 cd fe ff    	lea    -0x1328c(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 ca 2f 00 00       	call   f010304c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 6c 12 00 00       	call   f01012f3 <mem_init>
f0100087:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010008a:	83 ec 0c             	sub    $0xc,%esp
f010008d:	6a 00                	push   $0x0
f010008f:	e8 69 08 00 00       	call   f01008fd <monitor>
f0100094:	83 c4 10             	add    $0x10,%esp
f0100097:	eb f1                	jmp    f010008a <i386_init+0x4a>

f0100099 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100099:	55                   	push   %ebp
f010009a:	89 e5                	mov    %esp,%ebp
f010009c:	56                   	push   %esi
f010009d:	53                   	push   %ebx
f010009e:	e8 ac 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f01000a3:	81 c3 69 72 01 00    	add    $0x17269,%ebx
	va_list ap;

	if (panicstr)
f01000a9:	83 bb 54 1d 00 00 00 	cmpl   $0x0,0x1d54(%ebx)
f01000b0:	74 0f                	je     f01000c1 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000b2:	83 ec 0c             	sub    $0xc,%esp
f01000b5:	6a 00                	push   $0x0
f01000b7:	e8 41 08 00 00       	call   f01008fd <monitor>
f01000bc:	83 c4 10             	add    $0x10,%esp
f01000bf:	eb f1                	jmp    f01000b2 <_panic+0x19>
	panicstr = fmt;
f01000c1:	8b 45 10             	mov    0x10(%ebp),%eax
f01000c4:	89 83 54 1d 00 00    	mov    %eax,0x1d54(%ebx)
	asm volatile("cli; cld");
f01000ca:	fa                   	cli    
f01000cb:	fc                   	cld    
	va_start(ap, fmt);
f01000cc:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000cf:	83 ec 04             	sub    $0x4,%esp
f01000d2:	ff 75 0c             	push   0xc(%ebp)
f01000d5:	ff 75 08             	push   0x8(%ebp)
f01000d8:	8d 83 8f cd fe ff    	lea    -0x13271(%ebx),%eax
f01000de:	50                   	push   %eax
f01000df:	e8 68 2f 00 00       	call   f010304c <cprintf>
	vcprintf(fmt, ap);
f01000e4:	83 c4 08             	add    $0x8,%esp
f01000e7:	56                   	push   %esi
f01000e8:	ff 75 10             	push   0x10(%ebp)
f01000eb:	e8 25 2f 00 00       	call   f0103015 <vcprintf>
	cprintf("\n");
f01000f0:	8d 83 d2 dc fe ff    	lea    -0x1232e(%ebx),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 4e 2f 00 00       	call   f010304c <cprintf>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb af                	jmp    f01000b2 <_panic+0x19>

f0100103 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100103:	55                   	push   %ebp
f0100104:	89 e5                	mov    %esp,%ebp
f0100106:	56                   	push   %esi
f0100107:	53                   	push   %ebx
f0100108:	e8 42 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010010d:	81 c3 ff 71 01 00    	add    $0x171ff,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100113:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100116:	83 ec 04             	sub    $0x4,%esp
f0100119:	ff 75 0c             	push   0xc(%ebp)
f010011c:	ff 75 08             	push   0x8(%ebp)
f010011f:	8d 83 a7 cd fe ff    	lea    -0x13259(%ebx),%eax
f0100125:	50                   	push   %eax
f0100126:	e8 21 2f 00 00       	call   f010304c <cprintf>
	vcprintf(fmt, ap);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	56                   	push   %esi
f010012f:	ff 75 10             	push   0x10(%ebp)
f0100132:	e8 de 2e 00 00       	call   f0103015 <vcprintf>
	cprintf("\n");
f0100137:	8d 83 d2 dc fe ff    	lea    -0x1232e(%ebx),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 07 2f 00 00       	call   f010304c <cprintf>
	va_end(ap);
}
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010014b:	5b                   	pop    %ebx
f010014c:	5e                   	pop    %esi
f010014d:	5d                   	pop    %ebp
f010014e:	c3                   	ret    

f010014f <__x86.get_pc_thunk.bx>:
f010014f:	8b 1c 24             	mov    (%esp),%ebx
f0100152:	c3                   	ret    

f0100153 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100153:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100158:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100159:	a8 01                	test   $0x1,%al
f010015b:	74 0a                	je     f0100167 <serial_proc_data+0x14>
f010015d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100162:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100163:	0f b6 c0             	movzbl %al,%eax
f0100166:	c3                   	ret    
		return -1;
f0100167:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010016c:	c3                   	ret    

f010016d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010016d:	55                   	push   %ebp
f010016e:	89 e5                	mov    %esp,%ebp
f0100170:	57                   	push   %edi
f0100171:	56                   	push   %esi
f0100172:	53                   	push   %ebx
f0100173:	83 ec 1c             	sub    $0x1c,%esp
f0100176:	e8 6a 05 00 00       	call   f01006e5 <__x86.get_pc_thunk.si>
f010017b:	81 c6 91 71 01 00    	add    $0x17191,%esi
f0100181:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100183:	8d 1d 94 1d 00 00    	lea    0x1d94,%ebx
f0100189:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010018c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010018f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100192:	eb 25                	jmp    f01001b9 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100194:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f010019b:	8d 51 01             	lea    0x1(%ecx),%edx
f010019e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001a1:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001a4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01001af:	0f 44 d0             	cmove  %eax,%edx
f01001b2:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001bc:	ff d0                	call   *%eax
f01001be:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001c1:	74 06                	je     f01001c9 <cons_intr+0x5c>
		if (c == 0)
f01001c3:	85 c0                	test   %eax,%eax
f01001c5:	75 cd                	jne    f0100194 <cons_intr+0x27>
f01001c7:	eb f0                	jmp    f01001b9 <cons_intr+0x4c>
	}
}
f01001c9:	83 c4 1c             	add    $0x1c,%esp
f01001cc:	5b                   	pop    %ebx
f01001cd:	5e                   	pop    %esi
f01001ce:	5f                   	pop    %edi
f01001cf:	5d                   	pop    %ebp
f01001d0:	c3                   	ret    

f01001d1 <kbd_proc_data>:
{
f01001d1:	55                   	push   %ebp
f01001d2:	89 e5                	mov    %esp,%ebp
f01001d4:	56                   	push   %esi
f01001d5:	53                   	push   %ebx
f01001d6:	e8 74 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01001db:	81 c3 31 71 01 00    	add    $0x17131,%ebx
f01001e1:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e6:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001e7:	a8 01                	test   $0x1,%al
f01001e9:	0f 84 f7 00 00 00    	je     f01002e6 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f01001ef:	a8 20                	test   $0x20,%al
f01001f1:	0f 85 f6 00 00 00    	jne    f01002ed <kbd_proc_data+0x11c>
f01001f7:	ba 60 00 00 00       	mov    $0x60,%edx
f01001fc:	ec                   	in     (%dx),%al
f01001fd:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001ff:	3c e0                	cmp    $0xe0,%al
f0100201:	74 64                	je     f0100267 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100203:	84 c0                	test   %al,%al
f0100205:	78 75                	js     f010027c <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100207:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f010020d:	f6 c1 40             	test   $0x40,%cl
f0100210:	74 0e                	je     f0100220 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100212:	83 c8 80             	or     $0xffffff80,%eax
f0100215:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100217:	83 e1 bf             	and    $0xffffffbf,%ecx
f010021a:	89 8b 74 1d 00 00    	mov    %ecx,0x1d74(%ebx)
	shift |= shiftcode[data];
f0100220:	0f b6 d2             	movzbl %dl,%edx
f0100223:	0f b6 84 13 f4 ce fe 	movzbl -0x1310c(%ebx,%edx,1),%eax
f010022a:	ff 
f010022b:	0b 83 74 1d 00 00    	or     0x1d74(%ebx),%eax
	shift ^= togglecode[data];
f0100231:	0f b6 8c 13 f4 cd fe 	movzbl -0x1320c(%ebx,%edx,1),%ecx
f0100238:	ff 
f0100239:	31 c8                	xor    %ecx,%eax
f010023b:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100241:	89 c1                	mov    %eax,%ecx
f0100243:	83 e1 03             	and    $0x3,%ecx
f0100246:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f010024d:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100251:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100254:	a8 08                	test   $0x8,%al
f0100256:	74 61                	je     f01002b9 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f0100258:	89 f2                	mov    %esi,%edx
f010025a:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f010025d:	83 f9 19             	cmp    $0x19,%ecx
f0100260:	77 4b                	ja     f01002ad <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f0100262:	83 ee 20             	sub    $0x20,%esi
f0100265:	eb 0c                	jmp    f0100273 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f0100267:	83 8b 74 1d 00 00 40 	orl    $0x40,0x1d74(%ebx)
		return 0;
f010026e:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100273:	89 f0                	mov    %esi,%eax
f0100275:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100278:	5b                   	pop    %ebx
f0100279:	5e                   	pop    %esi
f010027a:	5d                   	pop    %ebp
f010027b:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010027c:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100282:	83 e0 7f             	and    $0x7f,%eax
f0100285:	f6 c1 40             	test   $0x40,%cl
f0100288:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010028b:	0f b6 d2             	movzbl %dl,%edx
f010028e:	0f b6 84 13 f4 ce fe 	movzbl -0x1310c(%ebx,%edx,1),%eax
f0100295:	ff 
f0100296:	83 c8 40             	or     $0x40,%eax
f0100299:	0f b6 c0             	movzbl %al,%eax
f010029c:	f7 d0                	not    %eax
f010029e:	21 c8                	and    %ecx,%eax
f01002a0:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
		return 0;
f01002a6:	be 00 00 00 00       	mov    $0x0,%esi
f01002ab:	eb c6                	jmp    f0100273 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002ad:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002b0:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002b3:	83 fa 1a             	cmp    $0x1a,%edx
f01002b6:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b9:	f7 d0                	not    %eax
f01002bb:	a8 06                	test   $0x6,%al
f01002bd:	75 b4                	jne    f0100273 <kbd_proc_data+0xa2>
f01002bf:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002c5:	75 ac                	jne    f0100273 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f01002c7:	83 ec 0c             	sub    $0xc,%esp
f01002ca:	8d 83 c1 cd fe ff    	lea    -0x1323f(%ebx),%eax
f01002d0:	50                   	push   %eax
f01002d1:	e8 76 2d 00 00       	call   f010304c <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d6:	b8 03 00 00 00       	mov    $0x3,%eax
f01002db:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e0:	ee                   	out    %al,(%dx)
}
f01002e1:	83 c4 10             	add    $0x10,%esp
f01002e4:	eb 8d                	jmp    f0100273 <kbd_proc_data+0xa2>
		return -1;
f01002e6:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002eb:	eb 86                	jmp    f0100273 <kbd_proc_data+0xa2>
		return -1;
f01002ed:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002f2:	e9 7c ff ff ff       	jmp    f0100273 <kbd_proc_data+0xa2>

f01002f7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f7:	55                   	push   %ebp
f01002f8:	89 e5                	mov    %esp,%ebp
f01002fa:	57                   	push   %edi
f01002fb:	56                   	push   %esi
f01002fc:	53                   	push   %ebx
f01002fd:	83 ec 1c             	sub    $0x1c,%esp
f0100300:	e8 4a fe ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100305:	81 c3 07 70 01 00    	add    $0x17007,%ebx
f010030b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010030e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100313:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100318:	b9 84 00 00 00       	mov    $0x84,%ecx
f010031d:	89 fa                	mov    %edi,%edx
f010031f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100320:	a8 20                	test   $0x20,%al
f0100322:	75 13                	jne    f0100337 <cons_putc+0x40>
f0100324:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010032a:	7f 0b                	jg     f0100337 <cons_putc+0x40>
f010032c:	89 ca                	mov    %ecx,%edx
f010032e:	ec                   	in     (%dx),%al
f010032f:	ec                   	in     (%dx),%al
f0100330:	ec                   	in     (%dx),%al
f0100331:	ec                   	in     (%dx),%al
	     i++)
f0100332:	83 c6 01             	add    $0x1,%esi
f0100335:	eb e6                	jmp    f010031d <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f0100337:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010033b:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010033e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100343:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100344:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100349:	bf 79 03 00 00       	mov    $0x379,%edi
f010034e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100353:	89 fa                	mov    %edi,%edx
f0100355:	ec                   	in     (%dx),%al
f0100356:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010035c:	7f 0f                	jg     f010036d <cons_putc+0x76>
f010035e:	84 c0                	test   %al,%al
f0100360:	78 0b                	js     f010036d <cons_putc+0x76>
f0100362:	89 ca                	mov    %ecx,%edx
f0100364:	ec                   	in     (%dx),%al
f0100365:	ec                   	in     (%dx),%al
f0100366:	ec                   	in     (%dx),%al
f0100367:	ec                   	in     (%dx),%al
f0100368:	83 c6 01             	add    $0x1,%esi
f010036b:	eb e6                	jmp    f0100353 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100372:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100376:	ee                   	out    %al,(%dx)
f0100377:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010037c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100381:	ee                   	out    %al,(%dx)
f0100382:	b8 08 00 00 00       	mov    $0x8,%eax
f0100387:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010038b:	89 f8                	mov    %edi,%eax
f010038d:	80 cc 07             	or     $0x7,%ah
f0100390:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100396:	0f 45 c7             	cmovne %edi,%eax
f0100399:	89 c7                	mov    %eax,%edi
f010039b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f010039e:	0f b6 c0             	movzbl %al,%eax
f01003a1:	89 f9                	mov    %edi,%ecx
f01003a3:	80 f9 0a             	cmp    $0xa,%cl
f01003a6:	0f 84 e4 00 00 00    	je     f0100490 <cons_putc+0x199>
f01003ac:	83 f8 0a             	cmp    $0xa,%eax
f01003af:	7f 46                	jg     f01003f7 <cons_putc+0x100>
f01003b1:	83 f8 08             	cmp    $0x8,%eax
f01003b4:	0f 84 a8 00 00 00    	je     f0100462 <cons_putc+0x16b>
f01003ba:	83 f8 09             	cmp    $0x9,%eax
f01003bd:	0f 85 da 00 00 00    	jne    f010049d <cons_putc+0x1a6>
		cons_putc(' ');
f01003c3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c8:	e8 2a ff ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f01003cd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d2:	e8 20 ff ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f01003d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003dc:	e8 16 ff ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f01003e1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e6:	e8 0c ff ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f01003eb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f0:	e8 02 ff ff ff       	call   f01002f7 <cons_putc>
		break;
f01003f5:	eb 26                	jmp    f010041d <cons_putc+0x126>
	switch (c & 0xff) {
f01003f7:	83 f8 0d             	cmp    $0xd,%eax
f01003fa:	0f 85 9d 00 00 00    	jne    f010049d <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100400:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100407:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010040d:	c1 e8 16             	shr    $0x16,%eax
f0100410:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100413:	c1 e0 04             	shl    $0x4,%eax
f0100416:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010041d:	66 81 bb 9c 1f 00 00 	cmpw   $0x7cf,0x1f9c(%ebx)
f0100424:	cf 07 
f0100426:	0f 87 98 00 00 00    	ja     f01004c4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f010042c:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f0100432:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100437:	89 ca                	mov    %ecx,%edx
f0100439:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010043a:	0f b7 9b 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%ebx
f0100441:	8d 71 01             	lea    0x1(%ecx),%esi
f0100444:	89 d8                	mov    %ebx,%eax
f0100446:	66 c1 e8 08          	shr    $0x8,%ax
f010044a:	89 f2                	mov    %esi,%edx
f010044c:	ee                   	out    %al,(%dx)
f010044d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100452:	89 ca                	mov    %ecx,%edx
f0100454:	ee                   	out    %al,(%dx)
f0100455:	89 d8                	mov    %ebx,%eax
f0100457:	89 f2                	mov    %esi,%edx
f0100459:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010045a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010045d:	5b                   	pop    %ebx
f010045e:	5e                   	pop    %esi
f010045f:	5f                   	pop    %edi
f0100460:	5d                   	pop    %ebp
f0100461:	c3                   	ret    
		if (crt_pos > 0) {
f0100462:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100469:	66 85 c0             	test   %ax,%ax
f010046c:	74 be                	je     f010042c <cons_putc+0x135>
			crt_pos--;
f010046e:	83 e8 01             	sub    $0x1,%eax
f0100471:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100478:	0f b7 c0             	movzwl %ax,%eax
f010047b:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f010047f:	b2 00                	mov    $0x0,%dl
f0100481:	83 ca 20             	or     $0x20,%edx
f0100484:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f010048a:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010048e:	eb 8d                	jmp    f010041d <cons_putc+0x126>
		crt_pos += CRT_COLS;
f0100490:	66 83 83 9c 1f 00 00 	addw   $0x50,0x1f9c(%ebx)
f0100497:	50 
f0100498:	e9 63 ff ff ff       	jmp    f0100400 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f010049d:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f01004a4:	8d 50 01             	lea    0x1(%eax),%edx
f01004a7:	66 89 93 9c 1f 00 00 	mov    %dx,0x1f9c(%ebx)
f01004ae:	0f b7 c0             	movzwl %ax,%eax
f01004b1:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f01004b7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004bb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01004bf:	e9 59 ff ff ff       	jmp    f010041d <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004c4:	8b 83 a0 1f 00 00    	mov    0x1fa0(%ebx),%eax
f01004ca:	83 ec 04             	sub    $0x4,%esp
f01004cd:	68 00 0f 00 00       	push   $0xf00
f01004d2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d8:	52                   	push   %edx
f01004d9:	50                   	push   %eax
f01004da:	e8 9c 37 00 00       	call   f0103c7b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004df:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f01004e5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004eb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004f1:	83 c4 10             	add    $0x10,%esp
f01004f4:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004f9:	83 c0 02             	add    $0x2,%eax
f01004fc:	39 d0                	cmp    %edx,%eax
f01004fe:	75 f4                	jne    f01004f4 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100500:	66 83 ab 9c 1f 00 00 	subw   $0x50,0x1f9c(%ebx)
f0100507:	50 
f0100508:	e9 1f ff ff ff       	jmp    f010042c <cons_putc+0x135>

f010050d <serial_intr>:
{
f010050d:	e8 cf 01 00 00       	call   f01006e1 <__x86.get_pc_thunk.ax>
f0100512:	05 fa 6d 01 00       	add    $0x16dfa,%eax
	if (serial_exists)
f0100517:	80 b8 a8 1f 00 00 00 	cmpb   $0x0,0x1fa8(%eax)
f010051e:	75 01                	jne    f0100521 <serial_intr+0x14>
f0100520:	c3                   	ret    
{
f0100521:	55                   	push   %ebp
f0100522:	89 e5                	mov    %esp,%ebp
f0100524:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100527:	8d 80 47 8e fe ff    	lea    -0x171b9(%eax),%eax
f010052d:	e8 3b fc ff ff       	call   f010016d <cons_intr>
}
f0100532:	c9                   	leave  
f0100533:	c3                   	ret    

f0100534 <kbd_intr>:
{
f0100534:	55                   	push   %ebp
f0100535:	89 e5                	mov    %esp,%ebp
f0100537:	83 ec 08             	sub    $0x8,%esp
f010053a:	e8 a2 01 00 00       	call   f01006e1 <__x86.get_pc_thunk.ax>
f010053f:	05 cd 6d 01 00       	add    $0x16dcd,%eax
	cons_intr(kbd_proc_data);
f0100544:	8d 80 c5 8e fe ff    	lea    -0x1713b(%eax),%eax
f010054a:	e8 1e fc ff ff       	call   f010016d <cons_intr>
}
f010054f:	c9                   	leave  
f0100550:	c3                   	ret    

f0100551 <cons_getc>:
{
f0100551:	55                   	push   %ebp
f0100552:	89 e5                	mov    %esp,%ebp
f0100554:	53                   	push   %ebx
f0100555:	83 ec 04             	sub    $0x4,%esp
f0100558:	e8 f2 fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010055d:	81 c3 af 6d 01 00    	add    $0x16daf,%ebx
	serial_intr();
f0100563:	e8 a5 ff ff ff       	call   f010050d <serial_intr>
	kbd_intr();
f0100568:	e8 c7 ff ff ff       	call   f0100534 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010056d:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
	return 0;
f0100573:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100578:	3b 83 98 1f 00 00    	cmp    0x1f98(%ebx),%eax
f010057e:	74 1e                	je     f010059e <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100580:	8d 48 01             	lea    0x1(%eax),%ecx
f0100583:	0f b6 94 03 94 1d 00 	movzbl 0x1d94(%ebx,%eax,1),%edx
f010058a:	00 
			cons.rpos = 0;
f010058b:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100590:	b8 00 00 00 00       	mov    $0x0,%eax
f0100595:	0f 45 c1             	cmovne %ecx,%eax
f0100598:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
}
f010059e:	89 d0                	mov    %edx,%eax
f01005a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005a3:	c9                   	leave  
f01005a4:	c3                   	ret    

f01005a5 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005a5:	55                   	push   %ebp
f01005a6:	89 e5                	mov    %esp,%ebp
f01005a8:	57                   	push   %edi
f01005a9:	56                   	push   %esi
f01005aa:	53                   	push   %ebx
f01005ab:	83 ec 1c             	sub    $0x1c,%esp
f01005ae:	e8 9c fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01005b3:	81 c3 59 6d 01 00    	add    $0x16d59,%ebx
	was = *cp;
f01005b9:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005c0:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005c7:	5a a5 
	if (*cp != 0xA55A) {
f01005c9:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005d0:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005d5:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f01005da:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005de:	0f 84 ac 00 00 00    	je     f0100690 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f01005e4:	89 8b a4 1f 00 00    	mov    %ecx,0x1fa4(%ebx)
f01005ea:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ef:	89 ca                	mov    %ecx,%edx
f01005f1:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f2:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f5:	89 f2                	mov    %esi,%edx
f01005f7:	ec                   	in     (%dx),%al
f01005f8:	0f b6 c0             	movzbl %al,%eax
f01005fb:	c1 e0 08             	shl    $0x8,%eax
f01005fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100601:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100606:	89 ca                	mov    %ecx,%edx
f0100608:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100609:	89 f2                	mov    %esi,%edx
f010060b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010060c:	89 bb a0 1f 00 00    	mov    %edi,0x1fa0(%ebx)
	pos |= inb(addr_6845 + 1);
f0100612:	0f b6 c0             	movzbl %al,%eax
f0100615:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100618:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100624:	89 c8                	mov    %ecx,%eax
f0100626:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010062b:	ee                   	out    %al,(%dx)
f010062c:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100631:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100636:	89 fa                	mov    %edi,%edx
f0100638:	ee                   	out    %al,(%dx)
f0100639:	b8 0c 00 00 00       	mov    $0xc,%eax
f010063e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100643:	ee                   	out    %al,(%dx)
f0100644:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100649:	89 c8                	mov    %ecx,%eax
f010064b:	89 f2                	mov    %esi,%edx
f010064d:	ee                   	out    %al,(%dx)
f010064e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100653:	89 fa                	mov    %edi,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010065b:	89 c8                	mov    %ecx,%eax
f010065d:	ee                   	out    %al,(%dx)
f010065e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100663:	89 f2                	mov    %esi,%edx
f0100665:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100666:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010066b:	ec                   	in     (%dx),%al
f010066c:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010066e:	3c ff                	cmp    $0xff,%al
f0100670:	0f 95 83 a8 1f 00 00 	setne  0x1fa8(%ebx)
f0100677:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010067c:	ec                   	in     (%dx),%al
f010067d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100682:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100683:	80 f9 ff             	cmp    $0xff,%cl
f0100686:	74 1e                	je     f01006a6 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f0100688:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010068b:	5b                   	pop    %ebx
f010068c:	5e                   	pop    %esi
f010068d:	5f                   	pop    %edi
f010068e:	5d                   	pop    %ebp
f010068f:	c3                   	ret    
		*cp = was;
f0100690:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100697:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010069c:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006a1:	e9 3e ff ff ff       	jmp    f01005e4 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006a6:	83 ec 0c             	sub    $0xc,%esp
f01006a9:	8d 83 cd cd fe ff    	lea    -0x13233(%ebx),%eax
f01006af:	50                   	push   %eax
f01006b0:	e8 97 29 00 00       	call   f010304c <cprintf>
f01006b5:	83 c4 10             	add    $0x10,%esp
}
f01006b8:	eb ce                	jmp    f0100688 <cons_init+0xe3>

f01006ba <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006ba:	55                   	push   %ebp
f01006bb:	89 e5                	mov    %esp,%ebp
f01006bd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01006c3:	e8 2f fc ff ff       	call   f01002f7 <cons_putc>
}
f01006c8:	c9                   	leave  
f01006c9:	c3                   	ret    

f01006ca <getchar>:

int
getchar(void)
{
f01006ca:	55                   	push   %ebp
f01006cb:	89 e5                	mov    %esp,%ebp
f01006cd:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006d0:	e8 7c fe ff ff       	call   f0100551 <cons_getc>
f01006d5:	85 c0                	test   %eax,%eax
f01006d7:	74 f7                	je     f01006d0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006d9:	c9                   	leave  
f01006da:	c3                   	ret    

f01006db <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f01006db:	b8 01 00 00 00       	mov    $0x1,%eax
f01006e0:	c3                   	ret    

f01006e1 <__x86.get_pc_thunk.ax>:
f01006e1:	8b 04 24             	mov    (%esp),%eax
f01006e4:	c3                   	ret    

f01006e5 <__x86.get_pc_thunk.si>:
f01006e5:	8b 34 24             	mov    (%esp),%esi
f01006e8:	c3                   	ret    

f01006e9 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006e9:	55                   	push   %ebp
f01006ea:	89 e5                	mov    %esp,%ebp
f01006ec:	56                   	push   %esi
f01006ed:	53                   	push   %ebx
f01006ee:	e8 5c fa ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01006f3:	81 c3 19 6c 01 00    	add    $0x16c19,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006f9:	83 ec 04             	sub    $0x4,%esp
f01006fc:	8d 83 f4 cf fe ff    	lea    -0x1300c(%ebx),%eax
f0100702:	50                   	push   %eax
f0100703:	8d 83 fa cf fe ff    	lea    -0x13006(%ebx),%eax
f0100709:	50                   	push   %eax
f010070a:	8d b3 04 d0 fe ff    	lea    -0x12ffc(%ebx),%esi
f0100710:	56                   	push   %esi
f0100711:	e8 36 29 00 00       	call   f010304c <cprintf>
f0100716:	83 c4 0c             	add    $0xc,%esp
f0100719:	8d 83 0d d0 fe ff    	lea    -0x12ff3(%ebx),%eax
f010071f:	50                   	push   %eax
f0100720:	8d 83 2b d0 fe ff    	lea    -0x12fd5(%ebx),%eax
f0100726:	50                   	push   %eax
f0100727:	56                   	push   %esi
f0100728:	e8 1f 29 00 00       	call   f010304c <cprintf>
f010072d:	83 c4 0c             	add    $0xc,%esp
f0100730:	8d 83 bc d0 fe ff    	lea    -0x12f44(%ebx),%eax
f0100736:	50                   	push   %eax
f0100737:	8d 83 30 d0 fe ff    	lea    -0x12fd0(%ebx),%eax
f010073d:	50                   	push   %eax
f010073e:	56                   	push   %esi
f010073f:	e8 08 29 00 00       	call   f010304c <cprintf>
	return 0;
}
f0100744:	b8 00 00 00 00       	mov    $0x0,%eax
f0100749:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010074c:	5b                   	pop    %ebx
f010074d:	5e                   	pop    %esi
f010074e:	5d                   	pop    %ebp
f010074f:	c3                   	ret    

f0100750 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100750:	55                   	push   %ebp
f0100751:	89 e5                	mov    %esp,%ebp
f0100753:	57                   	push   %edi
f0100754:	56                   	push   %esi
f0100755:	53                   	push   %ebx
f0100756:	83 ec 18             	sub    $0x18,%esp
f0100759:	e8 f1 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010075e:	81 c3 ae 6b 01 00    	add    $0x16bae,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100764:	8d 83 39 d0 fe ff    	lea    -0x12fc7(%ebx),%eax
f010076a:	50                   	push   %eax
f010076b:	e8 dc 28 00 00       	call   f010304c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100770:	83 c4 08             	add    $0x8,%esp
f0100773:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f0100779:	8d 83 e4 d0 fe ff    	lea    -0x12f1c(%ebx),%eax
f010077f:	50                   	push   %eax
f0100780:	e8 c7 28 00 00       	call   f010304c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100785:	83 c4 0c             	add    $0xc,%esp
f0100788:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010078e:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100794:	50                   	push   %eax
f0100795:	57                   	push   %edi
f0100796:	8d 83 0c d1 fe ff    	lea    -0x12ef4(%ebx),%eax
f010079c:	50                   	push   %eax
f010079d:	e8 aa 28 00 00       	call   f010304c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007a2:	83 c4 0c             	add    $0xc,%esp
f01007a5:	c7 c0 61 40 10 f0    	mov    $0xf0104061,%eax
f01007ab:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007b1:	52                   	push   %edx
f01007b2:	50                   	push   %eax
f01007b3:	8d 83 30 d1 fe ff    	lea    -0x12ed0(%ebx),%eax
f01007b9:	50                   	push   %eax
f01007ba:	e8 8d 28 00 00       	call   f010304c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f01007c8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007ce:	52                   	push   %edx
f01007cf:	50                   	push   %eax
f01007d0:	8d 83 54 d1 fe ff    	lea    -0x12eac(%ebx),%eax
f01007d6:	50                   	push   %eax
f01007d7:	e8 70 28 00 00       	call   f010304c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007dc:	83 c4 0c             	add    $0xc,%esp
f01007df:	c7 c6 e0 96 11 f0    	mov    $0xf01196e0,%esi
f01007e5:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007eb:	50                   	push   %eax
f01007ec:	56                   	push   %esi
f01007ed:	8d 83 78 d1 fe ff    	lea    -0x12e88(%ebx),%eax
f01007f3:	50                   	push   %eax
f01007f4:	e8 53 28 00 00       	call   f010304c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007f9:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007fc:	29 fe                	sub    %edi,%esi
f01007fe:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100804:	c1 fe 0a             	sar    $0xa,%esi
f0100807:	56                   	push   %esi
f0100808:	8d 83 9c d1 fe ff    	lea    -0x12e64(%ebx),%eax
f010080e:	50                   	push   %eax
f010080f:	e8 38 28 00 00       	call   f010304c <cprintf>
	return 0;
}
f0100814:	b8 00 00 00 00       	mov    $0x0,%eax
f0100819:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010081c:	5b                   	pop    %ebx
f010081d:	5e                   	pop    %esi
f010081e:	5f                   	pop    %edi
f010081f:	5d                   	pop    %ebp
f0100820:	c3                   	ret    

f0100821 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100821:	55                   	push   %ebp
f0100822:	89 e5                	mov    %esp,%ebp
f0100824:	57                   	push   %edi
f0100825:	56                   	push   %esi
f0100826:	53                   	push   %ebx
f0100827:	83 ec 48             	sub    $0x48,%esp
f010082a:	e8 20 f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010082f:	81 c3 dd 6a 01 00    	add    $0x16add,%ebx
    int hasinfo;
    uint32_t eip, ebp;
    register int i;
    struct Eipdebuginfo info;
    cprintf("Stack backtraces");
f0100835:	8d 83 52 d0 fe ff    	lea    -0x12fae(%ebx),%eax
f010083b:	50                   	push   %eax
f010083c:	e8 0b 28 00 00       	call   f010304c <cprintf>
    cprintf("\n");
f0100841:	8d 83 d2 dc fe ff    	lea    -0x1232e(%ebx),%eax
f0100847:	89 04 24             	mov    %eax,(%esp)
f010084a:	e8 fd 27 00 00       	call   f010304c <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010084f:	89 ef                	mov    %ebp,%edi
    ebp = read_ebp();
    while (ebp > 1) {
f0100851:	83 c4 10             	add    $0x10,%esp
       //assigning eip
       eip = *(uint32_t *) ((uint32_t *) ebp +1);
       hasinfo = debuginfo_eip(eip, &info);
       cprintf("          %s:%d: ", info.eip_file, info.eip_line);
       for(i=0; i<info.eip_fn_namelen; i++)
            cprintf("%c", *(info.eip_fn_name+i));
f0100854:	8d 83 75 d0 fe ff    	lea    -0x12f8b(%ebx),%eax
f010085a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    while (ebp > 1) {
f010085d:	eb 39                	jmp    f0100898 <mon_backtrace+0x77>
            cprintf("%c", *(info.eip_fn_name+i));
f010085f:	83 ec 08             	sub    $0x8,%esp
f0100862:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100865:	0f be 04 30          	movsbl (%eax,%esi,1),%eax
f0100869:	50                   	push   %eax
f010086a:	ff 75 c4             	push   -0x3c(%ebp)
f010086d:	e8 da 27 00 00       	call   f010304c <cprintf>
       for(i=0; i<info.eip_fn_namelen; i++)
f0100872:	83 c6 01             	add    $0x1,%esi
f0100875:	83 c4 10             	add    $0x10,%esp
f0100878:	39 75 dc             	cmp    %esi,-0x24(%ebp)
f010087b:	7f e2                	jg     f010085f <mon_backtrace+0x3e>
       cprintf("+%d\n", eip - info.eip_fn_addr);
f010087d:	83 ec 08             	sub    $0x8,%esp
f0100880:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100883:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100886:	50                   	push   %eax
f0100887:	8d 83 78 d0 fe ff    	lea    -0x12f88(%ebx),%eax
f010088d:	50                   	push   %eax
f010088e:	e8 b9 27 00 00       	call   f010304c <cprintf>
       //host ebp
       ebp = *(uint32_t *)ebp;
f0100893:	8b 3f                	mov    (%edi),%edi
f0100895:	83 c4 10             	add    $0x10,%esp
    while (ebp > 1) {
f0100898:	83 ff 01             	cmp    $0x1,%edi
f010089b:	76 53                	jbe    f01008f0 <mon_backtrace+0xcf>
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", 
f010089d:	ff 77 18             	push   0x18(%edi)
f01008a0:	ff 77 14             	push   0x14(%edi)
f01008a3:	ff 77 10             	push   0x10(%edi)
f01008a6:	ff 77 0c             	push   0xc(%edi)
f01008a9:	ff 77 08             	push   0x8(%edi)
f01008ac:	ff 77 04             	push   0x4(%edi)
f01008af:	57                   	push   %edi
f01008b0:	8d 83 c8 d1 fe ff    	lea    -0x12e38(%ebx),%eax
f01008b6:	50                   	push   %eax
f01008b7:	e8 90 27 00 00       	call   f010304c <cprintf>
       eip = *(uint32_t *) ((uint32_t *) ebp +1);
f01008bc:	8b 47 04             	mov    0x4(%edi),%eax
f01008bf:	89 c2                	mov    %eax,%edx
f01008c1:	89 45 c0             	mov    %eax,-0x40(%ebp)
       hasinfo = debuginfo_eip(eip, &info);
f01008c4:	83 c4 18             	add    $0x18,%esp
f01008c7:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008ca:	50                   	push   %eax
f01008cb:	52                   	push   %edx
f01008cc:	e8 84 28 00 00       	call   f0103155 <debuginfo_eip>
       cprintf("          %s:%d: ", info.eip_file, info.eip_line);
f01008d1:	83 c4 0c             	add    $0xc,%esp
f01008d4:	ff 75 d4             	push   -0x2c(%ebp)
f01008d7:	ff 75 d0             	push   -0x30(%ebp)
f01008da:	8d 83 63 d0 fe ff    	lea    -0x12f9d(%ebx),%eax
f01008e0:	50                   	push   %eax
f01008e1:	e8 66 27 00 00       	call   f010304c <cprintf>
       for(i=0; i<info.eip_fn_namelen; i++)
f01008e6:	83 c4 10             	add    $0x10,%esp
f01008e9:	be 00 00 00 00       	mov    $0x0,%esi
f01008ee:	eb 88                	jmp    f0100878 <mon_backtrace+0x57>
    }
    return 0;

}
f01008f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008f8:	5b                   	pop    %ebx
f01008f9:	5e                   	pop    %esi
f01008fa:	5f                   	pop    %edi
f01008fb:	5d                   	pop    %ebp
f01008fc:	c3                   	ret    

f01008fd <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008fd:	55                   	push   %ebp
f01008fe:	89 e5                	mov    %esp,%ebp
f0100900:	57                   	push   %edi
f0100901:	56                   	push   %esi
f0100902:	53                   	push   %ebx
f0100903:	83 ec 68             	sub    $0x68,%esp
f0100906:	e8 44 f8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010090b:	81 c3 01 6a 01 00    	add    $0x16a01,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100911:	8d 83 00 d2 fe ff    	lea    -0x12e00(%ebx),%eax
f0100917:	50                   	push   %eax
f0100918:	e8 2f 27 00 00       	call   f010304c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010091d:	8d 83 24 d2 fe ff    	lea    -0x12ddc(%ebx),%eax
f0100923:	89 04 24             	mov    %eax,(%esp)
f0100926:	e8 21 27 00 00       	call   f010304c <cprintf>
f010092b:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010092e:	8d bb 81 d0 fe ff    	lea    -0x12f7f(%ebx),%edi
f0100934:	eb 4a                	jmp    f0100980 <monitor+0x83>
f0100936:	83 ec 08             	sub    $0x8,%esp
f0100939:	0f be c0             	movsbl %al,%eax
f010093c:	50                   	push   %eax
f010093d:	57                   	push   %edi
f010093e:	e8 b3 32 00 00       	call   f0103bf6 <strchr>
f0100943:	83 c4 10             	add    $0x10,%esp
f0100946:	85 c0                	test   %eax,%eax
f0100948:	74 08                	je     f0100952 <monitor+0x55>
			*buf++ = 0;
f010094a:	c6 06 00             	movb   $0x0,(%esi)
f010094d:	8d 76 01             	lea    0x1(%esi),%esi
f0100950:	eb 76                	jmp    f01009c8 <monitor+0xcb>
		if (*buf == 0)
f0100952:	80 3e 00             	cmpb   $0x0,(%esi)
f0100955:	74 7c                	je     f01009d3 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f0100957:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010095b:	74 0f                	je     f010096c <monitor+0x6f>
		argv[argc++] = buf;
f010095d:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100960:	8d 48 01             	lea    0x1(%eax),%ecx
f0100963:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100966:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010096a:	eb 41                	jmp    f01009ad <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010096c:	83 ec 08             	sub    $0x8,%esp
f010096f:	6a 10                	push   $0x10
f0100971:	8d 83 86 d0 fe ff    	lea    -0x12f7a(%ebx),%eax
f0100977:	50                   	push   %eax
f0100978:	e8 cf 26 00 00       	call   f010304c <cprintf>
			return 0;
f010097d:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100980:	8d 83 7d d0 fe ff    	lea    -0x12f83(%ebx),%eax
f0100986:	89 c6                	mov    %eax,%esi
f0100988:	83 ec 0c             	sub    $0xc,%esp
f010098b:	56                   	push   %esi
f010098c:	e8 14 30 00 00       	call   f01039a5 <readline>
		if (buf != NULL)
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	85 c0                	test   %eax,%eax
f0100996:	74 f0                	je     f0100988 <monitor+0x8b>
	argv[argc] = 0;
f0100998:	89 c6                	mov    %eax,%esi
f010099a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009a1:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009a8:	eb 1e                	jmp    f01009c8 <monitor+0xcb>
			buf++;
f01009aa:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ad:	0f b6 06             	movzbl (%esi),%eax
f01009b0:	84 c0                	test   %al,%al
f01009b2:	74 14                	je     f01009c8 <monitor+0xcb>
f01009b4:	83 ec 08             	sub    $0x8,%esp
f01009b7:	0f be c0             	movsbl %al,%eax
f01009ba:	50                   	push   %eax
f01009bb:	57                   	push   %edi
f01009bc:	e8 35 32 00 00       	call   f0103bf6 <strchr>
f01009c1:	83 c4 10             	add    $0x10,%esp
f01009c4:	85 c0                	test   %eax,%eax
f01009c6:	74 e2                	je     f01009aa <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f01009c8:	0f b6 06             	movzbl (%esi),%eax
f01009cb:	84 c0                	test   %al,%al
f01009cd:	0f 85 63 ff ff ff    	jne    f0100936 <monitor+0x39>
	argv[argc] = 0;
f01009d3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009d6:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009dd:	00 
	if (argc == 0)
f01009de:	85 c0                	test   %eax,%eax
f01009e0:	74 9e                	je     f0100980 <monitor+0x83>
f01009e2:	8d b3 14 1d 00 00    	lea    0x1d14(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ed:	89 7d a0             	mov    %edi,-0x60(%ebp)
f01009f0:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f2:	83 ec 08             	sub    $0x8,%esp
f01009f5:	ff 36                	push   (%esi)
f01009f7:	ff 75 a8             	push   -0x58(%ebp)
f01009fa:	e8 97 31 00 00       	call   f0103b96 <strcmp>
f01009ff:	83 c4 10             	add    $0x10,%esp
f0100a02:	85 c0                	test   %eax,%eax
f0100a04:	74 28                	je     f0100a2e <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a06:	83 c7 01             	add    $0x1,%edi
f0100a09:	83 c6 0c             	add    $0xc,%esi
f0100a0c:	83 ff 03             	cmp    $0x3,%edi
f0100a0f:	75 e1                	jne    f01009f2 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a11:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a14:	83 ec 08             	sub    $0x8,%esp
f0100a17:	ff 75 a8             	push   -0x58(%ebp)
f0100a1a:	8d 83 a3 d0 fe ff    	lea    -0x12f5d(%ebx),%eax
f0100a20:	50                   	push   %eax
f0100a21:	e8 26 26 00 00       	call   f010304c <cprintf>
	return 0;
f0100a26:	83 c4 10             	add    $0x10,%esp
f0100a29:	e9 52 ff ff ff       	jmp    f0100980 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a2e:	89 f8                	mov    %edi,%eax
f0100a30:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a33:	83 ec 04             	sub    $0x4,%esp
f0100a36:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a39:	ff 75 08             	push   0x8(%ebp)
f0100a3c:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a3f:	52                   	push   %edx
f0100a40:	ff 75 a4             	push   -0x5c(%ebp)
f0100a43:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a4a:	83 c4 10             	add    $0x10,%esp
f0100a4d:	85 c0                	test   %eax,%eax
f0100a4f:	0f 89 2b ff ff ff    	jns    f0100980 <monitor+0x83>
				break;
	}
}
f0100a55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a58:	5b                   	pop    %ebx
f0100a59:	5e                   	pop    %esi
f0100a5a:	5f                   	pop    %edi
f0100a5b:	5d                   	pop    %ebp
f0100a5c:	c3                   	ret    

f0100a5d <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a5d:	e8 57 25 00 00       	call   f0102fb9 <__x86.get_pc_thunk.dx>
f0100a62:	81 c2 aa 68 01 00    	add    $0x168aa,%edx
// Initialize nextfree if this is the first time.
// 'end' is a magic symbol automatically generated by the linker,
// which points to the end of the kernel's bss segment:
// the first virtual address that the linker did *not* assign
// to any kernel code or global variables.
if (!nextfree) {
f0100a68:	83 ba b8 1f 00 00 00 	cmpl   $0x0,0x1fb8(%edx)
f0100a6f:	74 1b                	je     f0100a8c <boot_alloc+0x2f>
// Allocate a chunk large enough to hold 'n' bytes, then update
// nextfree.  Make sure nextfree is kept aligned
// to a multiple of PGSIZE.
//
// LAB 2: Your code here.
result=nextfree;
f0100a71:	8b 8a b8 1f 00 00    	mov    0x1fb8(%edx),%ecx
nextfree = ROUNDUP((char *)result +n, PGSIZE);
f0100a77:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100a7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a83:	89 82 b8 1f 00 00    	mov    %eax,0x1fb8(%edx)
return result;
}
f0100a89:	89 c8                	mov    %ecx,%eax
f0100a8b:	c3                   	ret    
nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a8c:	c7 c1 e0 96 11 f0    	mov    $0xf01196e0,%ecx
f0100a92:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100a98:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100a9e:	89 8a b8 1f 00 00    	mov    %ecx,0x1fb8(%edx)
f0100aa4:	eb cb                	jmp    f0100a71 <boot_alloc+0x14>

f0100aa6 <nvram_read>:
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	57                   	push   %edi
f0100aaa:	56                   	push   %esi
f0100aab:	53                   	push   %ebx
f0100aac:	83 ec 18             	sub    $0x18,%esp
f0100aaf:	e8 9b f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100ab4:	81 c3 58 68 01 00    	add    $0x16858,%ebx
f0100aba:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100abc:	50                   	push   %eax
f0100abd:	e8 03 25 00 00       	call   f0102fc5 <mc146818_read>
f0100ac2:	89 c7                	mov    %eax,%edi
f0100ac4:	83 c6 01             	add    $0x1,%esi
f0100ac7:	89 34 24             	mov    %esi,(%esp)
f0100aca:	e8 f6 24 00 00       	call   f0102fc5 <mc146818_read>
f0100acf:	c1 e0 08             	shl    $0x8,%eax
f0100ad2:	09 f8                	or     %edi,%eax
}
f0100ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad7:	5b                   	pop    %ebx
f0100ad8:	5e                   	pop    %esi
f0100ad9:	5f                   	pop    %edi
f0100ada:	5d                   	pop    %ebp
f0100adb:	c3                   	ret    

f0100adc <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100adc:	55                   	push   %ebp
f0100add:	89 e5                	mov    %esp,%ebp
f0100adf:	53                   	push   %ebx
f0100ae0:	83 ec 04             	sub    $0x4,%esp
f0100ae3:	e8 d5 24 00 00       	call   f0102fbd <__x86.get_pc_thunk.cx>
f0100ae8:	81 c1 24 68 01 00    	add    $0x16824,%ecx
f0100aee:	89 c3                	mov    %eax,%ebx
f0100af0:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100af2:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100af5:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100af8:	f6 c2 01             	test   $0x1,%dl
f0100afb:	74 54                	je     f0100b51 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100afd:	89 d3                	mov    %edx,%ebx
f0100aff:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b05:	c1 ea 0c             	shr    $0xc,%edx
f0100b08:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100b0e:	73 26                	jae    f0100b36 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100b10:	c1 e8 0c             	shr    $0xc,%eax
f0100b13:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100b18:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b1f:	89 d0                	mov    %edx,%eax
f0100b21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b26:	f6 c2 01             	test   $0x1,%dl
f0100b29:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b2e:	0f 44 c2             	cmove  %edx,%eax
}
f0100b31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b34:	c9                   	leave  
f0100b35:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b36:	53                   	push   %ebx
f0100b37:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f0100b3d:	50                   	push   %eax
f0100b3e:	68 d2 02 00 00       	push   $0x2d2
f0100b43:	8d 81 21 da fe ff    	lea    -0x125df(%ecx),%eax
f0100b49:	50                   	push   %eax
f0100b4a:	89 cb                	mov    %ecx,%ebx
f0100b4c:	e8 48 f5 ff ff       	call   f0100099 <_panic>
		return ~0;
f0100b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b56:	eb d9                	jmp    f0100b31 <check_va2pa+0x55>

f0100b58 <check_page_free_list>:
{
f0100b58:	55                   	push   %ebp
f0100b59:	89 e5                	mov    %esp,%ebp
f0100b5b:	57                   	push   %edi
f0100b5c:	56                   	push   %esi
f0100b5d:	53                   	push   %ebx
f0100b5e:	83 ec 2c             	sub    $0x2c,%esp
f0100b61:	e8 5b 24 00 00       	call   f0102fc1 <__x86.get_pc_thunk.di>
f0100b66:	81 c7 a6 67 01 00    	add    $0x167a6,%edi
f0100b6c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b6f:	84 c0                	test   %al,%al
f0100b71:	0f 85 dc 02 00 00    	jne    f0100e53 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100b77:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100b7a:	83 b8 bc 1f 00 00 00 	cmpl   $0x0,0x1fbc(%eax)
f0100b81:	74 0a                	je     f0100b8d <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b83:	bf 00 04 00 00       	mov    $0x400,%edi
f0100b88:	e9 29 03 00 00       	jmp    f0100eb6 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100b8d:	83 ec 04             	sub    $0x4,%esp
f0100b90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100b93:	8d 83 70 d2 fe ff    	lea    -0x12d90(%ebx),%eax
f0100b99:	50                   	push   %eax
f0100b9a:	68 13 02 00 00       	push   $0x213
f0100b9f:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100ba5:	50                   	push   %eax
f0100ba6:	e8 ee f4 ff ff       	call   f0100099 <_panic>
f0100bab:	50                   	push   %eax
f0100bac:	89 cb                	mov    %ecx,%ebx
f0100bae:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f0100bb4:	50                   	push   %eax
f0100bb5:	6a 52                	push   $0x52
f0100bb7:	8d 81 2d da fe ff    	lea    -0x125d3(%ecx),%eax
f0100bbd:	50                   	push   %eax
f0100bbe:	e8 d6 f4 ff ff       	call   f0100099 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bc3:	8b 36                	mov    (%esi),%esi
f0100bc5:	85 f6                	test   %esi,%esi
f0100bc7:	74 47                	je     f0100c10 <check_page_free_list+0xb8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bc9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100bcc:	89 f0                	mov    %esi,%eax
f0100bce:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0100bd4:	c1 f8 03             	sar    $0x3,%eax
f0100bd7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bda:	89 c2                	mov    %eax,%edx
f0100bdc:	c1 ea 16             	shr    $0x16,%edx
f0100bdf:	39 fa                	cmp    %edi,%edx
f0100be1:	73 e0                	jae    f0100bc3 <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100be3:	89 c2                	mov    %eax,%edx
f0100be5:	c1 ea 0c             	shr    $0xc,%edx
f0100be8:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100bee:	73 bb                	jae    f0100bab <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100bf0:	83 ec 04             	sub    $0x4,%esp
f0100bf3:	68 80 00 00 00       	push   $0x80
f0100bf8:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bfd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c02:	50                   	push   %eax
f0100c03:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c06:	e8 2a 30 00 00       	call   f0103c35 <memset>
f0100c0b:	83 c4 10             	add    $0x10,%esp
f0100c0e:	eb b3                	jmp    f0100bc3 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100c10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c15:	e8 43 fe ff ff       	call   f0100a5d <boot_alloc>
f0100c1a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c20:	8b 90 bc 1f 00 00    	mov    0x1fbc(%eax),%edx
		assert(pp >= pages);
f0100c26:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
		assert(pp < pages + npages);
f0100c2c:	8b 80 b4 1f 00 00    	mov    0x1fb4(%eax),%eax
f0100c32:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c35:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c38:	bf 00 00 00 00       	mov    $0x0,%edi
f0100c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c42:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c45:	e9 07 01 00 00       	jmp    f0100d51 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100c4a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c4d:	8d 83 3b da fe ff    	lea    -0x125c5(%ebx),%eax
f0100c53:	50                   	push   %eax
f0100c54:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100c5a:	50                   	push   %eax
f0100c5b:	68 2d 02 00 00       	push   $0x22d
f0100c60:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100c66:	50                   	push   %eax
f0100c67:	e8 2d f4 ff ff       	call   f0100099 <_panic>
		assert(pp < pages + npages);
f0100c6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c6f:	8d 83 5c da fe ff    	lea    -0x125a4(%ebx),%eax
f0100c75:	50                   	push   %eax
f0100c76:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100c7c:	50                   	push   %eax
f0100c7d:	68 2e 02 00 00       	push   $0x22e
f0100c82:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100c88:	50                   	push   %eax
f0100c89:	e8 0b f4 ff ff       	call   f0100099 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c8e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c91:	8d 83 94 d2 fe ff    	lea    -0x12d6c(%ebx),%eax
f0100c97:	50                   	push   %eax
f0100c98:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100c9e:	50                   	push   %eax
f0100c9f:	68 2f 02 00 00       	push   $0x22f
f0100ca4:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100caa:	50                   	push   %eax
f0100cab:	e8 e9 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != 0);
f0100cb0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cb3:	8d 83 70 da fe ff    	lea    -0x12590(%ebx),%eax
f0100cb9:	50                   	push   %eax
f0100cba:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100cc0:	50                   	push   %eax
f0100cc1:	68 32 02 00 00       	push   $0x232
f0100cc6:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100ccc:	50                   	push   %eax
f0100ccd:	e8 c7 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cd2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cd5:	8d 83 81 da fe ff    	lea    -0x1257f(%ebx),%eax
f0100cdb:	50                   	push   %eax
f0100cdc:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100ce2:	50                   	push   %eax
f0100ce3:	68 33 02 00 00       	push   $0x233
f0100ce8:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100cee:	50                   	push   %eax
f0100cef:	e8 a5 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cf4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cf7:	8d 83 c8 d2 fe ff    	lea    -0x12d38(%ebx),%eax
f0100cfd:	50                   	push   %eax
f0100cfe:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100d04:	50                   	push   %eax
f0100d05:	68 34 02 00 00       	push   $0x234
f0100d0a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100d10:	50                   	push   %eax
f0100d11:	e8 83 f3 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d16:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d19:	8d 83 9a da fe ff    	lea    -0x12566(%ebx),%eax
f0100d1f:	50                   	push   %eax
f0100d20:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100d26:	50                   	push   %eax
f0100d27:	68 35 02 00 00       	push   $0x235
f0100d2c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100d32:	50                   	push   %eax
f0100d33:	e8 61 f3 ff ff       	call   f0100099 <_panic>
	if (PGNUM(pa) >= npages)
f0100d38:	89 c3                	mov    %eax,%ebx
f0100d3a:	c1 eb 0c             	shr    $0xc,%ebx
f0100d3d:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100d40:	76 6d                	jbe    f0100daf <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100d42:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d47:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100d4a:	77 7c                	ja     f0100dc8 <check_page_free_list+0x270>
			++nfree_extmem;
f0100d4c:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4f:	8b 12                	mov    (%edx),%edx
f0100d51:	85 d2                	test   %edx,%edx
f0100d53:	0f 84 91 00 00 00    	je     f0100dea <check_page_free_list+0x292>
		assert(pp >= pages);
f0100d59:	39 d1                	cmp    %edx,%ecx
f0100d5b:	0f 87 e9 fe ff ff    	ja     f0100c4a <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100d61:	39 d6                	cmp    %edx,%esi
f0100d63:	0f 86 03 ff ff ff    	jbe    f0100c6c <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d69:	89 d0                	mov    %edx,%eax
f0100d6b:	29 c8                	sub    %ecx,%eax
f0100d6d:	a8 07                	test   $0x7,%al
f0100d6f:	0f 85 19 ff ff ff    	jne    f0100c8e <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;
f0100d75:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d78:	c1 e0 0c             	shl    $0xc,%eax
f0100d7b:	0f 84 2f ff ff ff    	je     f0100cb0 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d81:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d86:	0f 84 46 ff ff ff    	je     f0100cd2 <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d91:	0f 84 5d ff ff ff    	je     f0100cf4 <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d97:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d9c:	0f 84 74 ff ff ff    	je     f0100d16 <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100da2:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100da7:	77 8f                	ja     f0100d38 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100da9:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100dad:	eb a0                	jmp    f0100d4f <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100daf:	50                   	push   %eax
f0100db0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100db3:	8d 83 4c d2 fe ff    	lea    -0x12db4(%ebx),%eax
f0100db9:	50                   	push   %eax
f0100dba:	6a 52                	push   $0x52
f0100dbc:	8d 83 2d da fe ff    	lea    -0x125d3(%ebx),%eax
f0100dc2:	50                   	push   %eax
f0100dc3:	e8 d1 f2 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dc8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100dcb:	8d 83 ec d2 fe ff    	lea    -0x12d14(%ebx),%eax
f0100dd1:	50                   	push   %eax
f0100dd2:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100dd8:	50                   	push   %eax
f0100dd9:	68 36 02 00 00       	push   $0x236
f0100dde:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100de4:	50                   	push   %eax
f0100de5:	e8 af f2 ff ff       	call   f0100099 <_panic>
	assert(nfree_basemem > 0);
f0100dea:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100ded:	85 db                	test   %ebx,%ebx
f0100def:	7e 1e                	jle    f0100e0f <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100df1:	85 ff                	test   %edi,%edi
f0100df3:	7e 3c                	jle    f0100e31 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100df5:	83 ec 0c             	sub    $0xc,%esp
f0100df8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100dfb:	8d 83 34 d3 fe ff    	lea    -0x12ccc(%ebx),%eax
f0100e01:	50                   	push   %eax
f0100e02:	e8 45 22 00 00       	call   f010304c <cprintf>
}
f0100e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e0a:	5b                   	pop    %ebx
f0100e0b:	5e                   	pop    %esi
f0100e0c:	5f                   	pop    %edi
f0100e0d:	5d                   	pop    %ebp
f0100e0e:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e12:	8d 83 b4 da fe ff    	lea    -0x1254c(%ebx),%eax
f0100e18:	50                   	push   %eax
f0100e19:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100e1f:	50                   	push   %eax
f0100e20:	68 3e 02 00 00       	push   $0x23e
f0100e25:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100e2b:	50                   	push   %eax
f0100e2c:	e8 68 f2 ff ff       	call   f0100099 <_panic>
	assert(nfree_extmem > 0);
f0100e31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e34:	8d 83 c6 da fe ff    	lea    -0x1253a(%ebx),%eax
f0100e3a:	50                   	push   %eax
f0100e3b:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0100e41:	50                   	push   %eax
f0100e42:	68 3f 02 00 00       	push   $0x23f
f0100e47:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0100e4d:	50                   	push   %eax
f0100e4e:	e8 46 f2 ff ff       	call   f0100099 <_panic>
	if (!page_free_list)
f0100e53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e56:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f0100e5c:	85 c0                	test   %eax,%eax
f0100e5e:	0f 84 29 fd ff ff    	je     f0100b8d <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e64:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100e67:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e6a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100e6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100e70:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100e73:	89 c2                	mov    %eax,%edx
f0100e75:	2b 97 ac 1f 00 00    	sub    0x1fac(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e7b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e81:	0f 95 c2             	setne  %dl
f0100e84:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e87:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e8b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e8d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e91:	8b 00                	mov    (%eax),%eax
f0100e93:	85 c0                	test   %eax,%eax
f0100e95:	75 d9                	jne    f0100e70 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100e97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ea0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ea6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ea8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100eab:	89 87 bc 1f 00 00    	mov    %eax,0x1fbc(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eb1:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100eb6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100eb9:	8b b0 bc 1f 00 00    	mov    0x1fbc(%eax),%esi
f0100ebf:	e9 01 fd ff ff       	jmp    f0100bc5 <check_page_free_list+0x6d>

f0100ec4 <page_init>:
{
f0100ec4:	55                   	push   %ebp
f0100ec5:	89 e5                	mov    %esp,%ebp
f0100ec7:	57                   	push   %edi
f0100ec8:	56                   	push   %esi
f0100ec9:	53                   	push   %ebx
f0100eca:	83 ec 0c             	sub    $0xc,%esp
f0100ecd:	e8 7d f2 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100ed2:	81 c3 3a 64 01 00    	add    $0x1643a,%ebx
uint32_t nextfree = (uint32_t)boot_alloc(0);
f0100ed8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100edd:	e8 7b fb ff ff       	call   f0100a5d <boot_alloc>
pages[0].pp_link = NULL;
f0100ee2:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f0100ee8:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
pages[0].pp_ref=1;
f0100eee:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f0100ef4:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
		if ((i < ((nextfree-KERNBASE) / PGSIZE))&& (i>= (IOPHYSMEM /PGSIZE))){
f0100efa:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100f00:	c1 e9 0c             	shr    $0xc,%ecx
f0100f03:	8b 93 bc 1f 00 00    	mov    0x1fbc(%ebx),%edx
for (i = 1; i < npages; i++) {
f0100f09:	be 00 00 00 00       	mov    $0x0,%esi
f0100f0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f13:	eb 20                	jmp    f0100f35 <page_init+0x71>
		pages[i].pp_link = page_free_list;
f0100f15:	8b b3 ac 1f 00 00    	mov    0x1fac(%ebx),%esi
f0100f1b:	89 14 c6             	mov    %edx,(%esi,%eax,8)
		pages[i].pp_ref = 0;
f0100f1e:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f0100f24:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100f27:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
f0100f2d:	be 01 00 00 00       	mov    $0x1,%esi
for (i = 1; i < npages; i++) {
f0100f32:	83 c0 01             	add    $0x1,%eax
f0100f35:	39 83 b4 1f 00 00    	cmp    %eax,0x1fb4(%ebx)
f0100f3b:	76 27                	jbe    f0100f64 <page_init+0xa0>
		if ((i < ((nextfree-KERNBASE) / PGSIZE))&& (i>= (IOPHYSMEM /PGSIZE))){
f0100f3d:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100f42:	76 d1                	jbe    f0100f15 <page_init+0x51>
f0100f44:	39 c1                	cmp    %eax,%ecx
f0100f46:	76 cd                	jbe    f0100f15 <page_init+0x51>
		pages[i].pp_link=NULL;
f0100f48:	8b bb ac 1f 00 00    	mov    0x1fac(%ebx),%edi
f0100f4e:	c7 04 c7 00 00 00 00 	movl   $0x0,(%edi,%eax,8)
		pages[i].pp_ref =1;
f0100f55:	8b bb ac 1f 00 00    	mov    0x1fac(%ebx),%edi
f0100f5b:	66 c7 44 c7 04 01 00 	movw   $0x1,0x4(%edi,%eax,8)
f0100f62:	eb ce                	jmp    f0100f32 <page_init+0x6e>
f0100f64:	89 f0                	mov    %esi,%eax
f0100f66:	84 c0                	test   %al,%al
f0100f68:	74 06                	je     f0100f70 <page_init+0xac>
f0100f6a:	89 93 bc 1f 00 00    	mov    %edx,0x1fbc(%ebx)
}
f0100f70:	83 c4 0c             	add    $0xc,%esp
f0100f73:	5b                   	pop    %ebx
f0100f74:	5e                   	pop    %esi
f0100f75:	5f                   	pop    %edi
f0100f76:	5d                   	pop    %ebp
f0100f77:	c3                   	ret    

f0100f78 <page_alloc>:
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	56                   	push   %esi
f0100f7c:	53                   	push   %ebx
f0100f7d:	e8 cd f1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100f82:	81 c3 8a 63 01 00    	add    $0x1638a,%ebx
	if (page_free_list==NULL) {
f0100f88:	8b b3 bc 1f 00 00    	mov    0x1fbc(%ebx),%esi
f0100f8e:	85 f6                	test   %esi,%esi
f0100f90:	74 14                	je     f0100fa6 <page_alloc+0x2e>
  	page_free_list = page_free_list->pp_link;
f0100f92:	8b 06                	mov    (%esi),%eax
f0100f94:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
  	pginfo->pp_link = NULL;
f0100f9a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
    if (alloc_flags & ALLOC_ZERO){ 
f0100fa0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fa4:	75 09                	jne    f0100faf <page_alloc+0x37>
}
f0100fa6:	89 f0                	mov    %esi,%eax
f0100fa8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fab:	5b                   	pop    %ebx
f0100fac:	5e                   	pop    %esi
f0100fad:	5d                   	pop    %ebp
f0100fae:	c3                   	ret    
f0100faf:	89 f0                	mov    %esi,%eax
f0100fb1:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0100fb7:	c1 f8 03             	sar    $0x3,%eax
f0100fba:	89 c2                	mov    %eax,%edx
f0100fbc:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100fbf:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100fc4:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0100fca:	73 1b                	jae    f0100fe7 <page_alloc+0x6f>
		memset(page2kva(pginfo), 0, PGSIZE);
f0100fcc:	83 ec 04             	sub    $0x4,%esp
f0100fcf:	68 00 10 00 00       	push   $0x1000
f0100fd4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100fd6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100fdc:	52                   	push   %edx
f0100fdd:	e8 53 2c 00 00       	call   f0103c35 <memset>
f0100fe2:	83 c4 10             	add    $0x10,%esp
f0100fe5:	eb bf                	jmp    f0100fa6 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe7:	52                   	push   %edx
f0100fe8:	8d 83 4c d2 fe ff    	lea    -0x12db4(%ebx),%eax
f0100fee:	50                   	push   %eax
f0100fef:	6a 52                	push   $0x52
f0100ff1:	8d 83 2d da fe ff    	lea    -0x125d3(%ebx),%eax
f0100ff7:	50                   	push   %eax
f0100ff8:	e8 9c f0 ff ff       	call   f0100099 <_panic>

f0100ffd <page_free>:
{
f0100ffd:	55                   	push   %ebp
f0100ffe:	89 e5                	mov    %esp,%ebp
f0101000:	53                   	push   %ebx
f0101001:	83 ec 04             	sub    $0x4,%esp
f0101004:	e8 46 f1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101009:	81 c3 03 63 01 00    	add    $0x16303,%ebx
f010100f:	8b 45 08             	mov    0x8(%ebp),%eax
if (pp->pp_ref > 0){
f0101012:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101017:	75 18                	jne    f0101031 <page_free+0x34>
if (pp->pp_link){ 
f0101019:	83 38 00             	cmpl   $0x0,(%eax)
f010101c:	75 2e                	jne    f010104c <page_free+0x4f>
pp->pp_link=page_free_list;
f010101e:	8b 8b bc 1f 00 00    	mov    0x1fbc(%ebx),%ecx
f0101024:	89 08                	mov    %ecx,(%eax)
page_free_list=pp;
f0101026:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
}
f010102c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010102f:	c9                   	leave  
f0101030:	c3                   	ret    
	panic("Page free not working. The page is being reffered \n");
f0101031:	83 ec 04             	sub    $0x4,%esp
f0101034:	8d 83 58 d3 fe ff    	lea    -0x12ca8(%ebx),%eax
f010103a:	50                   	push   %eax
f010103b:	68 3b 01 00 00       	push   $0x13b
f0101040:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101046:	50                   	push   %eax
f0101047:	e8 4d f0 ff ff       	call   f0100099 <_panic>
	panic("Page link is not null. Page free broken.\n");
f010104c:	83 ec 04             	sub    $0x4,%esp
f010104f:	8d 83 8c d3 fe ff    	lea    -0x12c74(%ebx),%eax
f0101055:	50                   	push   %eax
f0101056:	68 3e 01 00 00       	push   $0x13e
f010105b:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101061:	50                   	push   %eax
f0101062:	e8 32 f0 ff ff       	call   f0100099 <_panic>

f0101067 <page_decref>:
{
f0101067:	55                   	push   %ebp
f0101068:	89 e5                	mov    %esp,%ebp
f010106a:	83 ec 08             	sub    $0x8,%esp
f010106d:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101070:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101074:	83 e8 01             	sub    $0x1,%eax
f0101077:	66 89 42 04          	mov    %ax,0x4(%edx)
f010107b:	66 85 c0             	test   %ax,%ax
f010107e:	74 02                	je     f0101082 <page_decref+0x1b>
}
f0101080:	c9                   	leave  
f0101081:	c3                   	ret    
		page_free(pp);
f0101082:	83 ec 0c             	sub    $0xc,%esp
f0101085:	52                   	push   %edx
f0101086:	e8 72 ff ff ff       	call   f0100ffd <page_free>
f010108b:	83 c4 10             	add    $0x10,%esp
}
f010108e:	eb f0                	jmp    f0101080 <page_decref+0x19>

f0101090 <pgdir_walk>:
{
f0101090:	55                   	push   %ebp
f0101091:	89 e5                	mov    %esp,%ebp
f0101093:	57                   	push   %edi
f0101094:	56                   	push   %esi
f0101095:	53                   	push   %ebx
f0101096:	83 ec 0c             	sub    $0xc,%esp
f0101099:	e8 23 1f 00 00       	call   f0102fc1 <__x86.get_pc_thunk.di>
f010109e:	81 c7 6e 62 01 00    	add    $0x1626e,%edi
f01010a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int pageTableEntry = PTX(va);
f01010a7:	89 de                	mov    %ebx,%esi
f01010a9:	c1 ee 0c             	shr    $0xc,%esi
f01010ac:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
    int pageDirInx = PDX(va);
f01010b2:	c1 eb 16             	shr    $0x16,%ebx
    if (pgdir[pageDirInx] & PTE_P){
f01010b5:	c1 e3 02             	shl    $0x2,%ebx
f01010b8:	03 5d 08             	add    0x8(%ebp),%ebx
f01010bb:	8b 03                	mov    (%ebx),%eax
f01010bd:	a8 01                	test   $0x1,%al
f01010bf:	75 4f                	jne    f0101110 <pgdir_walk+0x80>
    if (!create){
f01010c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01010c5:	0f 84 97 00 00 00    	je     f0101162 <pgdir_walk+0xd2>
    struct PageInfo* pg = page_alloc(ALLOC_ZERO);
f01010cb:	83 ec 0c             	sub    $0xc,%esp
f01010ce:	6a 01                	push   $0x1
f01010d0:	e8 a3 fe ff ff       	call   f0100f78 <page_alloc>
    if (!pg)
f01010d5:	83 c4 10             	add    $0x10,%esp
f01010d8:	85 c0                	test   %eax,%eax
f01010da:	74 2c                	je     f0101108 <pgdir_walk+0x78>
    pg->pp_ref++;
f01010dc:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01010e1:	2b 87 ac 1f 00 00    	sub    0x1fac(%edi),%eax
f01010e7:	c1 f8 03             	sar    $0x3,%eax
f01010ea:	c1 e0 0c             	shl    $0xc,%eax
    pgdir[pageDirInx] = page2pa(pg) | PTE_P | PTE_U | PTE_W;  
f01010ed:	89 c2                	mov    %eax,%edx
f01010ef:	83 ca 07             	or     $0x7,%edx
f01010f2:	89 13                	mov    %edx,(%ebx)
	if (PGNUM(pa) >= npages)
f01010f4:	89 c2                	mov    %eax,%edx
f01010f6:	c1 ea 0c             	shr    $0xc,%edx
f01010f9:	3b 97 b4 1f 00 00    	cmp    0x1fb4(%edi),%edx
f01010ff:	73 46                	jae    f0101147 <pgdir_walk+0xb7>
    return ptebase + pageTableEntry;
f0101101:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
}
f0101108:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010110b:	5b                   	pop    %ebx
f010110c:	5e                   	pop    %esi
f010110d:	5f                   	pop    %edi
f010110e:	5d                   	pop    %ebp
f010110f:	c3                   	ret    
        pte_t *ptebase = KADDR(PTE_ADDR(pgdir[pageDirInx]));  
f0101110:	89 c2                	mov    %eax,%edx
f0101112:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101118:	c1 e8 0c             	shr    $0xc,%eax
f010111b:	3b 87 b4 1f 00 00    	cmp    0x1fb4(%edi),%eax
f0101121:	73 09                	jae    f010112c <pgdir_walk+0x9c>
        return ptebase + pageTableEntry;
f0101123:	8d 84 b2 00 00 00 f0 	lea    -0x10000000(%edx,%esi,4),%eax
f010112a:	eb dc                	jmp    f0101108 <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010112c:	52                   	push   %edx
f010112d:	8d 87 4c d2 fe ff    	lea    -0x12db4(%edi),%eax
f0101133:	50                   	push   %eax
f0101134:	68 6c 01 00 00       	push   $0x16c
f0101139:	8d 87 21 da fe ff    	lea    -0x125df(%edi),%eax
f010113f:	50                   	push   %eax
f0101140:	89 fb                	mov    %edi,%ebx
f0101142:	e8 52 ef ff ff       	call   f0100099 <_panic>
f0101147:	50                   	push   %eax
f0101148:	8d 87 4c d2 fe ff    	lea    -0x12db4(%edi),%eax
f010114e:	50                   	push   %eax
f010114f:	68 77 01 00 00       	push   $0x177
f0101154:	8d 87 21 da fe ff    	lea    -0x125df(%edi),%eax
f010115a:	50                   	push   %eax
f010115b:	89 fb                	mov    %edi,%ebx
f010115d:	e8 37 ef ff ff       	call   f0100099 <_panic>
        return NULL;
f0101162:	b8 00 00 00 00       	mov    $0x0,%eax
f0101167:	eb 9f                	jmp    f0101108 <pgdir_walk+0x78>

f0101169 <boot_map_region>:
{
f0101169:	55                   	push   %ebp
f010116a:	89 e5                	mov    %esp,%ebp
f010116c:	57                   	push   %edi
f010116d:	56                   	push   %esi
f010116e:	53                   	push   %ebx
f010116f:	83 ec 1c             	sub    $0x1c,%esp
f0101172:	89 c7                	mov    %eax,%edi
f0101174:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101177:	89 ce                	mov    %ecx,%esi
    for(i = 0; i < size; i += PGSIZE) {
f0101179:	bb 00 00 00 00       	mov    $0x0,%ebx
f010117e:	eb 13                	jmp    f0101193 <boot_map_region+0x2a>
    	*pageTblEntry = (pa + i) | perm | PTE_P; 
f0101180:	89 d8                	mov    %ebx,%eax
f0101182:	03 45 08             	add    0x8(%ebp),%eax
f0101185:	0b 45 0c             	or     0xc(%ebp),%eax
f0101188:	83 c8 01             	or     $0x1,%eax
f010118b:	89 02                	mov    %eax,(%edx)
    for(i = 0; i < size; i += PGSIZE) {
f010118d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101193:	39 f3                	cmp    %esi,%ebx
f0101195:	73 1a                	jae    f01011b1 <boot_map_region+0x48>
    	pageTblEntry = pgdir_walk(pgdir, (void*) (va + i), 1);
f0101197:	83 ec 04             	sub    $0x4,%esp
f010119a:	6a 01                	push   $0x1
f010119c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010119f:	01 d8                	add    %ebx,%eax
f01011a1:	50                   	push   %eax
f01011a2:	57                   	push   %edi
f01011a3:	e8 e8 fe ff ff       	call   f0101090 <pgdir_walk>
f01011a8:	89 c2                	mov    %eax,%edx
    	if(!pageTblEntry) return;
f01011aa:	83 c4 10             	add    $0x10,%esp
f01011ad:	85 c0                	test   %eax,%eax
f01011af:	75 cf                	jne    f0101180 <boot_map_region+0x17>
}
f01011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b4:	5b                   	pop    %ebx
f01011b5:	5e                   	pop    %esi
f01011b6:	5f                   	pop    %edi
f01011b7:	5d                   	pop    %ebp
f01011b8:	c3                   	ret    

f01011b9 <page_lookup>:
{
f01011b9:	55                   	push   %ebp
f01011ba:	89 e5                	mov    %esp,%ebp
f01011bc:	53                   	push   %ebx
f01011bd:	83 ec 08             	sub    $0x8,%esp
f01011c0:	e8 8a ef ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01011c5:	81 c3 47 61 01 00    	add    $0x16147,%ebx
  pte_t * pg_tlb_entry = pgdir_walk(pgdir, va, 0);
f01011cb:	6a 00                	push   $0x0
f01011cd:	ff 75 0c             	push   0xc(%ebp)
f01011d0:	ff 75 08             	push   0x8(%ebp)
f01011d3:	e8 b8 fe ff ff       	call   f0101090 <pgdir_walk>
  *pte_store = pg_tlb_entry;
f01011d8:	8b 55 10             	mov    0x10(%ebp),%edx
f01011db:	89 02                	mov    %eax,(%edx)
  if(pg_tlb_entry == NULL){
f01011dd:	83 c4 10             	add    $0x10,%esp
f01011e0:	85 c0                	test   %eax,%eax
f01011e2:	74 16                	je     f01011fa <page_lookup+0x41>
f01011e4:	8b 00                	mov    (%eax),%eax
f01011e6:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011e9:	39 83 b4 1f 00 00    	cmp    %eax,0x1fb4(%ebx)
f01011ef:	76 0e                	jbe    f01011ff <page_lookup+0x46>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01011f1:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f01011f7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01011fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011fd:	c9                   	leave  
f01011fe:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01011ff:	83 ec 04             	sub    $0x4,%esp
f0101202:	8d 83 b8 d3 fe ff    	lea    -0x12c48(%ebx),%eax
f0101208:	50                   	push   %eax
f0101209:	6a 4b                	push   $0x4b
f010120b:	8d 83 2d da fe ff    	lea    -0x125d3(%ebx),%eax
f0101211:	50                   	push   %eax
f0101212:	e8 82 ee ff ff       	call   f0100099 <_panic>

f0101217 <page_remove>:
{
f0101217:	55                   	push   %ebp
f0101218:	89 e5                	mov    %esp,%ebp
f010121a:	53                   	push   %ebx
f010121b:	83 ec 18             	sub    $0x18,%esp
f010121e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    struct PageInfo* p = page_lookup(pgdir, va, &pageTblEntry);	
f0101221:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101224:	50                   	push   %eax
f0101225:	53                   	push   %ebx
f0101226:	ff 75 08             	push   0x8(%ebp)
f0101229:	e8 8b ff ff ff       	call   f01011b9 <page_lookup>
    if(!p || !(*pageTblEntry & PTE_P)) {
f010122e:	83 c4 10             	add    $0x10,%esp
f0101231:	85 c0                	test   %eax,%eax
f0101233:	74 08                	je     f010123d <page_remove+0x26>
f0101235:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101238:	f6 02 01             	testb  $0x1,(%edx)
f010123b:	75 05                	jne    f0101242 <page_remove+0x2b>
}
f010123d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101240:	c9                   	leave  
f0101241:	c3                   	ret    
    page_decref(p); 
f0101242:	83 ec 0c             	sub    $0xc,%esp
f0101245:	50                   	push   %eax
f0101246:	e8 1c fe ff ff       	call   f0101067 <page_decref>
    *pageTblEntry = 0; 
f010124b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010124e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101254:	0f 01 3b             	invlpg (%ebx)
f0101257:	83 c4 10             	add    $0x10,%esp
f010125a:	eb e1                	jmp    f010123d <page_remove+0x26>

f010125c <page_insert>:
{
f010125c:	55                   	push   %ebp
f010125d:	89 e5                	mov    %esp,%ebp
f010125f:	57                   	push   %edi
f0101260:	56                   	push   %esi
f0101261:	53                   	push   %ebx
f0101262:	83 ec 10             	sub    $0x10,%esp
f0101265:	e8 57 1d 00 00       	call   f0102fc1 <__x86.get_pc_thunk.di>
f010126a:	81 c7 a2 60 01 00    	add    $0x160a2,%edi
f0101270:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t * pg_tlb_entry = pgdir_walk(pgdir, va, 1);
f0101273:	6a 01                	push   $0x1
f0101275:	ff 75 10             	push   0x10(%ebp)
f0101278:	ff 75 08             	push   0x8(%ebp)
f010127b:	e8 10 fe ff ff       	call   f0101090 <pgdir_walk>
  if(pg_tlb_entry == NULL)
f0101280:	83 c4 10             	add    $0x10,%esp
f0101283:	85 c0                	test   %eax,%eax
f0101285:	74 65                	je     f01012ec <page_insert+0x90>
f0101287:	89 c3                	mov    %eax,%ebx
  if(*pg_tlb_entry & PTE_P){
f0101289:	8b 00                	mov    (%eax),%eax
f010128b:	a8 01                	test   $0x1,%al
f010128d:	74 28                	je     f01012b7 <page_insert+0x5b>
    if(PTE_ADDR(*pg_tlb_entry) == pa){
f010128f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	return (pp - pages) << PGSHIFT;
f0101294:	89 f2                	mov    %esi,%edx
f0101296:	2b 97 ac 1f 00 00    	sub    0x1fac(%edi),%edx
f010129c:	c1 fa 03             	sar    $0x3,%edx
f010129f:	c1 e2 0c             	shl    $0xc,%edx
f01012a2:	39 d0                	cmp    %edx,%eax
f01012a4:	74 39                	je     f01012df <page_insert+0x83>
    else{ page_remove(pgdir, va); }
f01012a6:	83 ec 08             	sub    $0x8,%esp
f01012a9:	ff 75 10             	push   0x10(%ebp)
f01012ac:	ff 75 08             	push   0x8(%ebp)
f01012af:	e8 63 ff ff ff       	call   f0101217 <page_remove>
f01012b4:	83 c4 10             	add    $0x10,%esp
f01012b7:	89 f0                	mov    %esi,%eax
f01012b9:	2b 87 ac 1f 00 00    	sub    0x1fac(%edi),%eax
f01012bf:	c1 f8 03             	sar    $0x3,%eax
f01012c2:	c1 e0 0c             	shl    $0xc,%eax
  *pg_tlb_entry = page2pa(pp)|perm|PTE_P;
f01012c5:	0b 45 14             	or     0x14(%ebp),%eax
f01012c8:	83 c8 01             	or     $0x1,%eax
f01012cb:	89 03                	mov    %eax,(%ebx)
  pp->pp_ref ++;
f01012cd:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
  return 0;
f01012d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012da:	5b                   	pop    %ebx
f01012db:	5e                   	pop    %esi
f01012dc:	5f                   	pop    %edi
f01012dd:	5d                   	pop    %ebp
f01012de:	c3                   	ret    
f01012df:	8b 45 10             	mov    0x10(%ebp),%eax
f01012e2:	0f 01 38             	invlpg (%eax)
      pp->pp_ref --;
f01012e5:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f01012ea:	eb cb                	jmp    f01012b7 <page_insert+0x5b>
    return -E_NO_MEM;
f01012ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01012f1:	eb e4                	jmp    f01012d7 <page_insert+0x7b>

f01012f3 <mem_init>:
{
f01012f3:	55                   	push   %ebp
f01012f4:	89 e5                	mov    %esp,%ebp
f01012f6:	57                   	push   %edi
f01012f7:	56                   	push   %esi
f01012f8:	53                   	push   %ebx
f01012f9:	83 ec 3c             	sub    $0x3c,%esp
f01012fc:	e8 e0 f3 ff ff       	call   f01006e1 <__x86.get_pc_thunk.ax>
f0101301:	05 0b 60 01 00       	add    $0x1600b,%eax
f0101306:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101309:	b8 15 00 00 00       	mov    $0x15,%eax
f010130e:	e8 93 f7 ff ff       	call   f0100aa6 <nvram_read>
f0101313:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101315:	b8 17 00 00 00       	mov    $0x17,%eax
f010131a:	e8 87 f7 ff ff       	call   f0100aa6 <nvram_read>
f010131f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101321:	b8 34 00 00 00       	mov    $0x34,%eax
f0101326:	e8 7b f7 ff ff       	call   f0100aa6 <nvram_read>
	if (ext16mem)
f010132b:	c1 e0 06             	shl    $0x6,%eax
f010132e:	0f 84 b9 00 00 00    	je     f01013ed <mem_init+0xfa>
		totalmem = 16 * 1024 + ext16mem;
f0101334:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101339:	89 c2                	mov    %eax,%edx
f010133b:	c1 ea 02             	shr    $0x2,%edx
f010133e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101341:	89 91 b4 1f 00 00    	mov    %edx,0x1fb4(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101347:	89 c2                	mov    %eax,%edx
f0101349:	29 da                	sub    %ebx,%edx
f010134b:	52                   	push   %edx
f010134c:	53                   	push   %ebx
f010134d:	50                   	push   %eax
f010134e:	8d 81 d8 d3 fe ff    	lea    -0x12c28(%ecx),%eax
f0101354:	50                   	push   %eax
f0101355:	89 cb                	mov    %ecx,%ebx
f0101357:	e8 f0 1c 00 00       	call   f010304c <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010135c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101361:	e8 f7 f6 ff ff       	call   f0100a5d <boot_alloc>
f0101366:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f010136c:	83 c4 0c             	add    $0xc,%esp
f010136f:	68 00 10 00 00       	push   $0x1000
f0101374:	6a 00                	push   $0x0
f0101376:	50                   	push   %eax
f0101377:	e8 b9 28 00 00       	call   f0103c35 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010137c:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101382:	83 c4 10             	add    $0x10,%esp
f0101385:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010138a:	76 71                	jbe    f01013fd <mem_init+0x10a>
	return (physaddr_t)kva - KERNBASE;
f010138c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101392:	83 ca 05             	or     $0x5,%edx
f0101395:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	int spaceNeeded = (sizeof(struct PageInfo)*npages);
f010139b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010139e:	8b 9f b4 1f 00 00    	mov    0x1fb4(%edi),%ebx
f01013a4:	c1 e3 03             	shl    $0x3,%ebx
	pages = (struct PageInfo*)boot_alloc(spaceNeeded);
f01013a7:	89 d8                	mov    %ebx,%eax
f01013a9:	e8 af f6 ff ff       	call   f0100a5d <boot_alloc>
f01013ae:	89 87 ac 1f 00 00    	mov    %eax,0x1fac(%edi)
	memset(pages,0,spaceNeeded);
f01013b4:	83 ec 04             	sub    $0x4,%esp
f01013b7:	53                   	push   %ebx
f01013b8:	6a 00                	push   $0x0
f01013ba:	50                   	push   %eax
f01013bb:	89 fb                	mov    %edi,%ebx
f01013bd:	e8 73 28 00 00       	call   f0103c35 <memset>
	page_init();
f01013c2:	e8 fd fa ff ff       	call   f0100ec4 <page_init>
	check_page_free_list(1);
f01013c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01013cc:	e8 87 f7 ff ff       	call   f0100b58 <check_page_free_list>
	if (!pages)
f01013d1:	83 c4 10             	add    $0x10,%esp
f01013d4:	83 bf ac 1f 00 00 00 	cmpl   $0x0,0x1fac(%edi)
f01013db:	74 3c                	je     f0101419 <mem_init+0x126>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013e0:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f01013e6:	be 00 00 00 00       	mov    $0x0,%esi
f01013eb:	eb 4f                	jmp    f010143c <mem_init+0x149>
		totalmem = 1 * 1024 + extmem;
f01013ed:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013f3:	85 f6                	test   %esi,%esi
f01013f5:	0f 44 c3             	cmove  %ebx,%eax
f01013f8:	e9 3c ff ff ff       	jmp    f0101339 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013fd:	50                   	push   %eax
f01013fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101401:	8d 83 14 d4 fe ff    	lea    -0x12bec(%ebx),%eax
f0101407:	50                   	push   %eax
f0101408:	68 90 00 00 00       	push   $0x90
f010140d:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101413:	50                   	push   %eax
f0101414:	e8 80 ec ff ff       	call   f0100099 <_panic>
		panic("'pages' is a null pointer!");
f0101419:	83 ec 04             	sub    $0x4,%esp
f010141c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010141f:	8d 83 d7 da fe ff    	lea    -0x12529(%ebx),%eax
f0101425:	50                   	push   %eax
f0101426:	68 52 02 00 00       	push   $0x252
f010142b:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101431:	50                   	push   %eax
f0101432:	e8 62 ec ff ff       	call   f0100099 <_panic>
		++nfree;
f0101437:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010143a:	8b 00                	mov    (%eax),%eax
f010143c:	85 c0                	test   %eax,%eax
f010143e:	75 f7                	jne    f0101437 <mem_init+0x144>
	assert((pp0 = page_alloc(0)));
f0101440:	83 ec 0c             	sub    $0xc,%esp
f0101443:	6a 00                	push   $0x0
f0101445:	e8 2e fb ff ff       	call   f0100f78 <page_alloc>
f010144a:	89 c3                	mov    %eax,%ebx
f010144c:	83 c4 10             	add    $0x10,%esp
f010144f:	85 c0                	test   %eax,%eax
f0101451:	0f 84 3a 02 00 00    	je     f0101691 <mem_init+0x39e>
	assert((pp1 = page_alloc(0)));
f0101457:	83 ec 0c             	sub    $0xc,%esp
f010145a:	6a 00                	push   $0x0
f010145c:	e8 17 fb ff ff       	call   f0100f78 <page_alloc>
f0101461:	89 c7                	mov    %eax,%edi
f0101463:	83 c4 10             	add    $0x10,%esp
f0101466:	85 c0                	test   %eax,%eax
f0101468:	0f 84 45 02 00 00    	je     f01016b3 <mem_init+0x3c0>
	assert((pp2 = page_alloc(0)));
f010146e:	83 ec 0c             	sub    $0xc,%esp
f0101471:	6a 00                	push   $0x0
f0101473:	e8 00 fb ff ff       	call   f0100f78 <page_alloc>
f0101478:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010147b:	83 c4 10             	add    $0x10,%esp
f010147e:	85 c0                	test   %eax,%eax
f0101480:	0f 84 4f 02 00 00    	je     f01016d5 <mem_init+0x3e2>
	assert(pp1 && pp1 != pp0);
f0101486:	39 fb                	cmp    %edi,%ebx
f0101488:	0f 84 69 02 00 00    	je     f01016f7 <mem_init+0x404>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010148e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101491:	39 c3                	cmp    %eax,%ebx
f0101493:	0f 84 80 02 00 00    	je     f0101719 <mem_init+0x426>
f0101499:	39 c7                	cmp    %eax,%edi
f010149b:	0f 84 78 02 00 00    	je     f0101719 <mem_init+0x426>
	return (pp - pages) << PGSHIFT;
f01014a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a4:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014aa:	8b 90 b4 1f 00 00    	mov    0x1fb4(%eax),%edx
f01014b0:	c1 e2 0c             	shl    $0xc,%edx
f01014b3:	89 d8                	mov    %ebx,%eax
f01014b5:	29 c8                	sub    %ecx,%eax
f01014b7:	c1 f8 03             	sar    $0x3,%eax
f01014ba:	c1 e0 0c             	shl    $0xc,%eax
f01014bd:	39 d0                	cmp    %edx,%eax
f01014bf:	0f 83 76 02 00 00    	jae    f010173b <mem_init+0x448>
f01014c5:	89 f8                	mov    %edi,%eax
f01014c7:	29 c8                	sub    %ecx,%eax
f01014c9:	c1 f8 03             	sar    $0x3,%eax
f01014cc:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014cf:	39 c2                	cmp    %eax,%edx
f01014d1:	0f 86 86 02 00 00    	jbe    f010175d <mem_init+0x46a>
f01014d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014da:	29 c8                	sub    %ecx,%eax
f01014dc:	c1 f8 03             	sar    $0x3,%eax
f01014df:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014e2:	39 c2                	cmp    %eax,%edx
f01014e4:	0f 86 95 02 00 00    	jbe    f010177f <mem_init+0x48c>
	fl = page_free_list;
f01014ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014ed:	8b 88 bc 1f 00 00    	mov    0x1fbc(%eax),%ecx
f01014f3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01014f6:	c7 80 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%eax)
f01014fd:	00 00 00 
	assert(!page_alloc(0));
f0101500:	83 ec 0c             	sub    $0xc,%esp
f0101503:	6a 00                	push   $0x0
f0101505:	e8 6e fa ff ff       	call   f0100f78 <page_alloc>
f010150a:	83 c4 10             	add    $0x10,%esp
f010150d:	85 c0                	test   %eax,%eax
f010150f:	0f 85 8c 02 00 00    	jne    f01017a1 <mem_init+0x4ae>
	page_free(pp0);
f0101515:	83 ec 0c             	sub    $0xc,%esp
f0101518:	53                   	push   %ebx
f0101519:	e8 df fa ff ff       	call   f0100ffd <page_free>
	page_free(pp1);
f010151e:	89 3c 24             	mov    %edi,(%esp)
f0101521:	e8 d7 fa ff ff       	call   f0100ffd <page_free>
	page_free(pp2);
f0101526:	83 c4 04             	add    $0x4,%esp
f0101529:	ff 75 d0             	push   -0x30(%ebp)
f010152c:	e8 cc fa ff ff       	call   f0100ffd <page_free>
	assert((pp0 = page_alloc(0)));
f0101531:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101538:	e8 3b fa ff ff       	call   f0100f78 <page_alloc>
f010153d:	89 c7                	mov    %eax,%edi
f010153f:	83 c4 10             	add    $0x10,%esp
f0101542:	85 c0                	test   %eax,%eax
f0101544:	0f 84 79 02 00 00    	je     f01017c3 <mem_init+0x4d0>
	assert((pp1 = page_alloc(0)));
f010154a:	83 ec 0c             	sub    $0xc,%esp
f010154d:	6a 00                	push   $0x0
f010154f:	e8 24 fa ff ff       	call   f0100f78 <page_alloc>
f0101554:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101557:	83 c4 10             	add    $0x10,%esp
f010155a:	85 c0                	test   %eax,%eax
f010155c:	0f 84 83 02 00 00    	je     f01017e5 <mem_init+0x4f2>
	assert((pp2 = page_alloc(0)));
f0101562:	83 ec 0c             	sub    $0xc,%esp
f0101565:	6a 00                	push   $0x0
f0101567:	e8 0c fa ff ff       	call   f0100f78 <page_alloc>
f010156c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010156f:	83 c4 10             	add    $0x10,%esp
f0101572:	85 c0                	test   %eax,%eax
f0101574:	0f 84 8d 02 00 00    	je     f0101807 <mem_init+0x514>
	assert(pp1 && pp1 != pp0);
f010157a:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f010157d:	0f 84 a6 02 00 00    	je     f0101829 <mem_init+0x536>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101583:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101586:	39 c7                	cmp    %eax,%edi
f0101588:	0f 84 bd 02 00 00    	je     f010184b <mem_init+0x558>
f010158e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101591:	0f 84 b4 02 00 00    	je     f010184b <mem_init+0x558>
	assert(!page_alloc(0));
f0101597:	83 ec 0c             	sub    $0xc,%esp
f010159a:	6a 00                	push   $0x0
f010159c:	e8 d7 f9 ff ff       	call   f0100f78 <page_alloc>
f01015a1:	83 c4 10             	add    $0x10,%esp
f01015a4:	85 c0                	test   %eax,%eax
f01015a6:	0f 85 c1 02 00 00    	jne    f010186d <mem_init+0x57a>
f01015ac:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015af:	89 f8                	mov    %edi,%eax
f01015b1:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f01015b7:	c1 f8 03             	sar    $0x3,%eax
f01015ba:	89 c2                	mov    %eax,%edx
f01015bc:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015bf:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015c4:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f01015ca:	0f 83 bf 02 00 00    	jae    f010188f <mem_init+0x59c>
	memset(page2kva(pp0), 1, PGSIZE);
f01015d0:	83 ec 04             	sub    $0x4,%esp
f01015d3:	68 00 10 00 00       	push   $0x1000
f01015d8:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015da:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015e0:	52                   	push   %edx
f01015e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01015e4:	e8 4c 26 00 00       	call   f0103c35 <memset>
	page_free(pp0);
f01015e9:	89 3c 24             	mov    %edi,(%esp)
f01015ec:	e8 0c fa ff ff       	call   f0100ffd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015f8:	e8 7b f9 ff ff       	call   f0100f78 <page_alloc>
f01015fd:	83 c4 10             	add    $0x10,%esp
f0101600:	85 c0                	test   %eax,%eax
f0101602:	0f 84 9f 02 00 00    	je     f01018a7 <mem_init+0x5b4>
	assert(pp && pp0 == pp);
f0101608:	39 c7                	cmp    %eax,%edi
f010160a:	0f 85 b9 02 00 00    	jne    f01018c9 <mem_init+0x5d6>
	return (pp - pages) << PGSHIFT;
f0101610:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101613:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0101619:	c1 f8 03             	sar    $0x3,%eax
f010161c:	89 c2                	mov    %eax,%edx
f010161e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101621:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101626:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f010162c:	0f 83 b9 02 00 00    	jae    f01018eb <mem_init+0x5f8>
	return (void *)(pa + KERNBASE);
f0101632:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101638:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010163e:	80 38 00             	cmpb   $0x0,(%eax)
f0101641:	0f 85 bc 02 00 00    	jne    f0101903 <mem_init+0x610>
	for (i = 0; i < PGSIZE; i++)
f0101647:	83 c0 01             	add    $0x1,%eax
f010164a:	39 c2                	cmp    %eax,%edx
f010164c:	75 f0                	jne    f010163e <mem_init+0x34b>
	page_free_list = fl;
f010164e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101651:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101654:	89 8b bc 1f 00 00    	mov    %ecx,0x1fbc(%ebx)
	page_free(pp0);
f010165a:	83 ec 0c             	sub    $0xc,%esp
f010165d:	57                   	push   %edi
f010165e:	e8 9a f9 ff ff       	call   f0100ffd <page_free>
	page_free(pp1);
f0101663:	83 c4 04             	add    $0x4,%esp
f0101666:	ff 75 d0             	push   -0x30(%ebp)
f0101669:	e8 8f f9 ff ff       	call   f0100ffd <page_free>
	page_free(pp2);
f010166e:	83 c4 04             	add    $0x4,%esp
f0101671:	ff 75 cc             	push   -0x34(%ebp)
f0101674:	e8 84 f9 ff ff       	call   f0100ffd <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101679:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f010167f:	83 c4 10             	add    $0x10,%esp
f0101682:	85 c0                	test   %eax,%eax
f0101684:	0f 84 9b 02 00 00    	je     f0101925 <mem_init+0x632>
		--nfree;
f010168a:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010168d:	8b 00                	mov    (%eax),%eax
f010168f:	eb f1                	jmp    f0101682 <mem_init+0x38f>
	assert((pp0 = page_alloc(0)));
f0101691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101694:	8d 83 f2 da fe ff    	lea    -0x1250e(%ebx),%eax
f010169a:	50                   	push   %eax
f010169b:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01016a1:	50                   	push   %eax
f01016a2:	68 5a 02 00 00       	push   $0x25a
f01016a7:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01016ad:	50                   	push   %eax
f01016ae:	e8 e6 e9 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01016b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016b6:	8d 83 08 db fe ff    	lea    -0x124f8(%ebx),%eax
f01016bc:	50                   	push   %eax
f01016bd:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01016c3:	50                   	push   %eax
f01016c4:	68 5b 02 00 00       	push   $0x25b
f01016c9:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01016cf:	50                   	push   %eax
f01016d0:	e8 c4 e9 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01016d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016d8:	8d 83 1e db fe ff    	lea    -0x124e2(%ebx),%eax
f01016de:	50                   	push   %eax
f01016df:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01016e5:	50                   	push   %eax
f01016e6:	68 5c 02 00 00       	push   $0x25c
f01016eb:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01016f1:	50                   	push   %eax
f01016f2:	e8 a2 e9 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01016f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fa:	8d 83 34 db fe ff    	lea    -0x124cc(%ebx),%eax
f0101700:	50                   	push   %eax
f0101701:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0101707:	50                   	push   %eax
f0101708:	68 5f 02 00 00       	push   $0x25f
f010170d:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101713:	50                   	push   %eax
f0101714:	e8 80 e9 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101719:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010171c:	8d 83 38 d4 fe ff    	lea    -0x12bc8(%ebx),%eax
f0101722:	50                   	push   %eax
f0101723:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0101729:	50                   	push   %eax
f010172a:	68 60 02 00 00       	push   $0x260
f010172f:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101735:	50                   	push   %eax
f0101736:	e8 5e e9 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010173b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010173e:	8d 83 46 db fe ff    	lea    -0x124ba(%ebx),%eax
f0101744:	50                   	push   %eax
f0101745:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010174b:	50                   	push   %eax
f010174c:	68 61 02 00 00       	push   $0x261
f0101751:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101757:	50                   	push   %eax
f0101758:	e8 3c e9 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010175d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101760:	8d 83 63 db fe ff    	lea    -0x1249d(%ebx),%eax
f0101766:	50                   	push   %eax
f0101767:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010176d:	50                   	push   %eax
f010176e:	68 62 02 00 00       	push   $0x262
f0101773:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101779:	50                   	push   %eax
f010177a:	e8 1a e9 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010177f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101782:	8d 83 80 db fe ff    	lea    -0x12480(%ebx),%eax
f0101788:	50                   	push   %eax
f0101789:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010178f:	50                   	push   %eax
f0101790:	68 63 02 00 00       	push   $0x263
f0101795:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010179b:	50                   	push   %eax
f010179c:	e8 f8 e8 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01017a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a4:	8d 83 9d db fe ff    	lea    -0x12463(%ebx),%eax
f01017aa:	50                   	push   %eax
f01017ab:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01017b1:	50                   	push   %eax
f01017b2:	68 6a 02 00 00       	push   $0x26a
f01017b7:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01017bd:	50                   	push   %eax
f01017be:	e8 d6 e8 ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f01017c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017c6:	8d 83 f2 da fe ff    	lea    -0x1250e(%ebx),%eax
f01017cc:	50                   	push   %eax
f01017cd:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01017d3:	50                   	push   %eax
f01017d4:	68 71 02 00 00       	push   $0x271
f01017d9:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01017df:	50                   	push   %eax
f01017e0:	e8 b4 e8 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017e8:	8d 83 08 db fe ff    	lea    -0x124f8(%ebx),%eax
f01017ee:	50                   	push   %eax
f01017ef:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01017f5:	50                   	push   %eax
f01017f6:	68 72 02 00 00       	push   $0x272
f01017fb:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101801:	50                   	push   %eax
f0101802:	e8 92 e8 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0101807:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180a:	8d 83 1e db fe ff    	lea    -0x124e2(%ebx),%eax
f0101810:	50                   	push   %eax
f0101811:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0101817:	50                   	push   %eax
f0101818:	68 73 02 00 00       	push   $0x273
f010181d:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101823:	50                   	push   %eax
f0101824:	e8 70 e8 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f0101829:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010182c:	8d 83 34 db fe ff    	lea    -0x124cc(%ebx),%eax
f0101832:	50                   	push   %eax
f0101833:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0101839:	50                   	push   %eax
f010183a:	68 75 02 00 00       	push   $0x275
f010183f:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101845:	50                   	push   %eax
f0101846:	e8 4e e8 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010184b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010184e:	8d 83 38 d4 fe ff    	lea    -0x12bc8(%ebx),%eax
f0101854:	50                   	push   %eax
f0101855:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010185b:	50                   	push   %eax
f010185c:	68 76 02 00 00       	push   $0x276
f0101861:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101867:	50                   	push   %eax
f0101868:	e8 2c e8 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f010186d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101870:	8d 83 9d db fe ff    	lea    -0x12463(%ebx),%eax
f0101876:	50                   	push   %eax
f0101877:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010187d:	50                   	push   %eax
f010187e:	68 77 02 00 00       	push   $0x277
f0101883:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0101889:	50                   	push   %eax
f010188a:	e8 0a e8 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010188f:	52                   	push   %edx
f0101890:	89 cb                	mov    %ecx,%ebx
f0101892:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f0101898:	50                   	push   %eax
f0101899:	6a 52                	push   $0x52
f010189b:	8d 81 2d da fe ff    	lea    -0x125d3(%ecx),%eax
f01018a1:	50                   	push   %eax
f01018a2:	e8 f2 e7 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018aa:	8d 83 ac db fe ff    	lea    -0x12454(%ebx),%eax
f01018b0:	50                   	push   %eax
f01018b1:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01018b7:	50                   	push   %eax
f01018b8:	68 7c 02 00 00       	push   $0x27c
f01018bd:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01018c3:	50                   	push   %eax
f01018c4:	e8 d0 e7 ff ff       	call   f0100099 <_panic>
	assert(pp && pp0 == pp);
f01018c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018cc:	8d 83 ca db fe ff    	lea    -0x12436(%ebx),%eax
f01018d2:	50                   	push   %eax
f01018d3:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01018d9:	50                   	push   %eax
f01018da:	68 7d 02 00 00       	push   $0x27d
f01018df:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01018e5:	50                   	push   %eax
f01018e6:	e8 ae e7 ff ff       	call   f0100099 <_panic>
f01018eb:	52                   	push   %edx
f01018ec:	89 cb                	mov    %ecx,%ebx
f01018ee:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f01018f4:	50                   	push   %eax
f01018f5:	6a 52                	push   $0x52
f01018f7:	8d 81 2d da fe ff    	lea    -0x125d3(%ecx),%eax
f01018fd:	50                   	push   %eax
f01018fe:	e8 96 e7 ff ff       	call   f0100099 <_panic>
		assert(c[i] == 0);
f0101903:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101906:	8d 83 da db fe ff    	lea    -0x12426(%ebx),%eax
f010190c:	50                   	push   %eax
f010190d:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0101913:	50                   	push   %eax
f0101914:	68 80 02 00 00       	push   $0x280
f0101919:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010191f:	50                   	push   %eax
f0101920:	e8 74 e7 ff ff       	call   f0100099 <_panic>
	assert(nfree == 0);
f0101925:	85 f6                	test   %esi,%esi
f0101927:	0f 85 39 08 00 00    	jne    f0102166 <mem_init+0xe73>
	cprintf("check_page_alloc() succeeded!\n");
f010192d:	83 ec 0c             	sub    $0xc,%esp
f0101930:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101933:	8d 83 58 d4 fe ff    	lea    -0x12ba8(%ebx),%eax
f0101939:	50                   	push   %eax
f010193a:	e8 0d 17 00 00       	call   f010304c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010193f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101946:	e8 2d f6 ff ff       	call   f0100f78 <page_alloc>
f010194b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010194e:	83 c4 10             	add    $0x10,%esp
f0101951:	85 c0                	test   %eax,%eax
f0101953:	0f 84 2f 08 00 00    	je     f0102188 <mem_init+0xe95>
	assert((pp1 = page_alloc(0)));
f0101959:	83 ec 0c             	sub    $0xc,%esp
f010195c:	6a 00                	push   $0x0
f010195e:	e8 15 f6 ff ff       	call   f0100f78 <page_alloc>
f0101963:	89 c7                	mov    %eax,%edi
f0101965:	83 c4 10             	add    $0x10,%esp
f0101968:	85 c0                	test   %eax,%eax
f010196a:	0f 84 3a 08 00 00    	je     f01021aa <mem_init+0xeb7>
	assert((pp2 = page_alloc(0)));
f0101970:	83 ec 0c             	sub    $0xc,%esp
f0101973:	6a 00                	push   $0x0
f0101975:	e8 fe f5 ff ff       	call   f0100f78 <page_alloc>
f010197a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010197d:	83 c4 10             	add    $0x10,%esp
f0101980:	85 c0                	test   %eax,%eax
f0101982:	0f 84 44 08 00 00    	je     f01021cc <mem_init+0xed9>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101988:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010198b:	0f 84 5d 08 00 00    	je     f01021ee <mem_init+0xefb>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101991:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101994:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101997:	0f 84 73 08 00 00    	je     f0102210 <mem_init+0xf1d>
f010199d:	39 c7                	cmp    %eax,%edi
f010199f:	0f 84 6b 08 00 00    	je     f0102210 <mem_init+0xf1d>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019a5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a8:	8b 88 bc 1f 00 00    	mov    0x1fbc(%eax),%ecx
f01019ae:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01019b1:	c7 80 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%eax)
f01019b8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019bb:	83 ec 0c             	sub    $0xc,%esp
f01019be:	6a 00                	push   $0x0
f01019c0:	e8 b3 f5 ff ff       	call   f0100f78 <page_alloc>
f01019c5:	83 c4 10             	add    $0x10,%esp
f01019c8:	85 c0                	test   %eax,%eax
f01019ca:	0f 85 62 08 00 00    	jne    f0102232 <mem_init+0xf3f>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019d0:	83 ec 04             	sub    $0x4,%esp
f01019d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019d6:	50                   	push   %eax
f01019d7:	6a 00                	push   $0x0
f01019d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019dc:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f01019e2:	e8 d2 f7 ff ff       	call   f01011b9 <page_lookup>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	0f 85 62 08 00 00    	jne    f0102254 <mem_init+0xf61>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019f2:	6a 02                	push   $0x2
f01019f4:	6a 00                	push   $0x0
f01019f6:	57                   	push   %edi
f01019f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019fa:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101a00:	e8 57 f8 ff ff       	call   f010125c <page_insert>
f0101a05:	83 c4 10             	add    $0x10,%esp
f0101a08:	85 c0                	test   %eax,%eax
f0101a0a:	0f 89 66 08 00 00    	jns    f0102276 <mem_init+0xf83>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a10:	83 ec 0c             	sub    $0xc,%esp
f0101a13:	ff 75 cc             	push   -0x34(%ebp)
f0101a16:	e8 e2 f5 ff ff       	call   f0100ffd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a1b:	6a 02                	push   $0x2
f0101a1d:	6a 00                	push   $0x0
f0101a1f:	57                   	push   %edi
f0101a20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a23:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101a29:	e8 2e f8 ff ff       	call   f010125c <page_insert>
f0101a2e:	83 c4 20             	add    $0x20,%esp
f0101a31:	85 c0                	test   %eax,%eax
f0101a33:	0f 85 5f 08 00 00    	jne    f0102298 <mem_init+0xfa5>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a39:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3c:	8b 98 b0 1f 00 00    	mov    0x1fb0(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101a42:	8b b0 ac 1f 00 00    	mov    0x1fac(%eax),%esi
f0101a48:	8b 13                	mov    (%ebx),%edx
f0101a4a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a50:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a53:	29 f0                	sub    %esi,%eax
f0101a55:	c1 f8 03             	sar    $0x3,%eax
f0101a58:	c1 e0 0c             	shl    $0xc,%eax
f0101a5b:	39 c2                	cmp    %eax,%edx
f0101a5d:	0f 85 57 08 00 00    	jne    f01022ba <mem_init+0xfc7>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a63:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a68:	89 d8                	mov    %ebx,%eax
f0101a6a:	e8 6d f0 ff ff       	call   f0100adc <check_va2pa>
f0101a6f:	89 c2                	mov    %eax,%edx
f0101a71:	89 f8                	mov    %edi,%eax
f0101a73:	29 f0                	sub    %esi,%eax
f0101a75:	c1 f8 03             	sar    $0x3,%eax
f0101a78:	c1 e0 0c             	shl    $0xc,%eax
f0101a7b:	39 c2                	cmp    %eax,%edx
f0101a7d:	0f 85 59 08 00 00    	jne    f01022dc <mem_init+0xfe9>
	assert(pp1->pp_ref == 1);
f0101a83:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a88:	0f 85 70 08 00 00    	jne    f01022fe <mem_init+0x100b>
	assert(pp0->pp_ref == 1);
f0101a8e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a91:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a96:	0f 85 84 08 00 00    	jne    f0102320 <mem_init+0x102d>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a9c:	6a 02                	push   $0x2
f0101a9e:	68 00 10 00 00       	push   $0x1000
f0101aa3:	ff 75 d0             	push   -0x30(%ebp)
f0101aa6:	53                   	push   %ebx
f0101aa7:	e8 b0 f7 ff ff       	call   f010125c <page_insert>
f0101aac:	83 c4 10             	add    $0x10,%esp
f0101aaf:	85 c0                	test   %eax,%eax
f0101ab1:	0f 85 8b 08 00 00    	jne    f0102342 <mem_init+0x104f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ab7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101abc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101abf:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101ac5:	e8 12 f0 ff ff       	call   f0100adc <check_va2pa>
f0101aca:	89 c2                	mov    %eax,%edx
f0101acc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101acf:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101ad5:	c1 f8 03             	sar    $0x3,%eax
f0101ad8:	c1 e0 0c             	shl    $0xc,%eax
f0101adb:	39 c2                	cmp    %eax,%edx
f0101add:	0f 85 81 08 00 00    	jne    f0102364 <mem_init+0x1071>
	assert(pp2->pp_ref == 1);
f0101ae3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ae6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101aeb:	0f 85 95 08 00 00    	jne    f0102386 <mem_init+0x1093>

	// should be no free memory
	assert(!page_alloc(0));
f0101af1:	83 ec 0c             	sub    $0xc,%esp
f0101af4:	6a 00                	push   $0x0
f0101af6:	e8 7d f4 ff ff       	call   f0100f78 <page_alloc>
f0101afb:	83 c4 10             	add    $0x10,%esp
f0101afe:	85 c0                	test   %eax,%eax
f0101b00:	0f 85 a2 08 00 00    	jne    f01023a8 <mem_init+0x10b5>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b06:	6a 02                	push   $0x2
f0101b08:	68 00 10 00 00       	push   $0x1000
f0101b0d:	ff 75 d0             	push   -0x30(%ebp)
f0101b10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b13:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101b19:	e8 3e f7 ff ff       	call   f010125c <page_insert>
f0101b1e:	83 c4 10             	add    $0x10,%esp
f0101b21:	85 c0                	test   %eax,%eax
f0101b23:	0f 85 a1 08 00 00    	jne    f01023ca <mem_init+0x10d7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b31:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101b37:	e8 a0 ef ff ff       	call   f0100adc <check_va2pa>
f0101b3c:	89 c2                	mov    %eax,%edx
f0101b3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b41:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101b47:	c1 f8 03             	sar    $0x3,%eax
f0101b4a:	c1 e0 0c             	shl    $0xc,%eax
f0101b4d:	39 c2                	cmp    %eax,%edx
f0101b4f:	0f 85 97 08 00 00    	jne    f01023ec <mem_init+0x10f9>
	assert(pp2->pp_ref == 1);
f0101b55:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b58:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b5d:	0f 85 ab 08 00 00    	jne    f010240e <mem_init+0x111b>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b63:	83 ec 0c             	sub    $0xc,%esp
f0101b66:	6a 00                	push   $0x0
f0101b68:	e8 0b f4 ff ff       	call   f0100f78 <page_alloc>
f0101b6d:	83 c4 10             	add    $0x10,%esp
f0101b70:	85 c0                	test   %eax,%eax
f0101b72:	0f 85 b8 08 00 00    	jne    f0102430 <mem_init+0x113d>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b78:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b7b:	8b 91 b0 1f 00 00    	mov    0x1fb0(%ecx),%edx
f0101b81:	8b 02                	mov    (%edx),%eax
f0101b83:	89 c3                	mov    %eax,%ebx
f0101b85:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101b8b:	c1 e8 0c             	shr    $0xc,%eax
f0101b8e:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0101b94:	0f 83 b8 08 00 00    	jae    f0102452 <mem_init+0x115f>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b9a:	83 ec 04             	sub    $0x4,%esp
f0101b9d:	6a 00                	push   $0x0
f0101b9f:	68 00 10 00 00       	push   $0x1000
f0101ba4:	52                   	push   %edx
f0101ba5:	e8 e6 f4 ff ff       	call   f0101090 <pgdir_walk>
f0101baa:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101bb0:	83 c4 10             	add    $0x10,%esp
f0101bb3:	39 d8                	cmp    %ebx,%eax
f0101bb5:	0f 85 b2 08 00 00    	jne    f010246d <mem_init+0x117a>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101bbb:	6a 06                	push   $0x6
f0101bbd:	68 00 10 00 00       	push   $0x1000
f0101bc2:	ff 75 d0             	push   -0x30(%ebp)
f0101bc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bc8:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101bce:	e8 89 f6 ff ff       	call   f010125c <page_insert>
f0101bd3:	83 c4 10             	add    $0x10,%esp
f0101bd6:	85 c0                	test   %eax,%eax
f0101bd8:	0f 85 b1 08 00 00    	jne    f010248f <mem_init+0x119c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bde:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101be1:	8b 9e b0 1f 00 00    	mov    0x1fb0(%esi),%ebx
f0101be7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bec:	89 d8                	mov    %ebx,%eax
f0101bee:	e8 e9 ee ff ff       	call   f0100adc <check_va2pa>
f0101bf3:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101bf5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bf8:	2b 86 ac 1f 00 00    	sub    0x1fac(%esi),%eax
f0101bfe:	c1 f8 03             	sar    $0x3,%eax
f0101c01:	c1 e0 0c             	shl    $0xc,%eax
f0101c04:	39 c2                	cmp    %eax,%edx
f0101c06:	0f 85 a5 08 00 00    	jne    f01024b1 <mem_init+0x11be>
	assert(pp2->pp_ref == 1);
f0101c0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c0f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c14:	0f 85 b9 08 00 00    	jne    f01024d3 <mem_init+0x11e0>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c1a:	83 ec 04             	sub    $0x4,%esp
f0101c1d:	6a 00                	push   $0x0
f0101c1f:	68 00 10 00 00       	push   $0x1000
f0101c24:	53                   	push   %ebx
f0101c25:	e8 66 f4 ff ff       	call   f0101090 <pgdir_walk>
f0101c2a:	83 c4 10             	add    $0x10,%esp
f0101c2d:	f6 00 04             	testb  $0x4,(%eax)
f0101c30:	0f 84 bf 08 00 00    	je     f01024f5 <mem_init+0x1202>
	assert(kern_pgdir[0] & PTE_U);
f0101c36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c39:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f0101c3f:	f6 00 04             	testb  $0x4,(%eax)
f0101c42:	0f 84 cf 08 00 00    	je     f0102517 <mem_init+0x1224>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c48:	6a 02                	push   $0x2
f0101c4a:	68 00 10 00 00       	push   $0x1000
f0101c4f:	ff 75 d0             	push   -0x30(%ebp)
f0101c52:	50                   	push   %eax
f0101c53:	e8 04 f6 ff ff       	call   f010125c <page_insert>
f0101c58:	83 c4 10             	add    $0x10,%esp
f0101c5b:	85 c0                	test   %eax,%eax
f0101c5d:	0f 85 d6 08 00 00    	jne    f0102539 <mem_init+0x1246>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c63:	83 ec 04             	sub    $0x4,%esp
f0101c66:	6a 00                	push   $0x0
f0101c68:	68 00 10 00 00       	push   $0x1000
f0101c6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c70:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101c76:	e8 15 f4 ff ff       	call   f0101090 <pgdir_walk>
f0101c7b:	83 c4 10             	add    $0x10,%esp
f0101c7e:	f6 00 02             	testb  $0x2,(%eax)
f0101c81:	0f 84 d4 08 00 00    	je     f010255b <mem_init+0x1268>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c87:	83 ec 04             	sub    $0x4,%esp
f0101c8a:	6a 00                	push   $0x0
f0101c8c:	68 00 10 00 00       	push   $0x1000
f0101c91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c94:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101c9a:	e8 f1 f3 ff ff       	call   f0101090 <pgdir_walk>
f0101c9f:	83 c4 10             	add    $0x10,%esp
f0101ca2:	f6 00 04             	testb  $0x4,(%eax)
f0101ca5:	0f 85 d2 08 00 00    	jne    f010257d <mem_init+0x128a>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cab:	6a 02                	push   $0x2
f0101cad:	68 00 00 40 00       	push   $0x400000
f0101cb2:	ff 75 cc             	push   -0x34(%ebp)
f0101cb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cb8:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101cbe:	e8 99 f5 ff ff       	call   f010125c <page_insert>
f0101cc3:	83 c4 10             	add    $0x10,%esp
f0101cc6:	85 c0                	test   %eax,%eax
f0101cc8:	0f 89 d1 08 00 00    	jns    f010259f <mem_init+0x12ac>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cce:	6a 02                	push   $0x2
f0101cd0:	68 00 10 00 00       	push   $0x1000
f0101cd5:	57                   	push   %edi
f0101cd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd9:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101cdf:	e8 78 f5 ff ff       	call   f010125c <page_insert>
f0101ce4:	83 c4 10             	add    $0x10,%esp
f0101ce7:	85 c0                	test   %eax,%eax
f0101ce9:	0f 85 d2 08 00 00    	jne    f01025c1 <mem_init+0x12ce>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cef:	83 ec 04             	sub    $0x4,%esp
f0101cf2:	6a 00                	push   $0x0
f0101cf4:	68 00 10 00 00       	push   $0x1000
f0101cf9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cfc:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101d02:	e8 89 f3 ff ff       	call   f0101090 <pgdir_walk>
f0101d07:	83 c4 10             	add    $0x10,%esp
f0101d0a:	f6 00 04             	testb  $0x4,(%eax)
f0101d0d:	0f 85 d0 08 00 00    	jne    f01025e3 <mem_init+0x12f0>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d16:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0101d1c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d21:	89 f0                	mov    %esi,%eax
f0101d23:	e8 b4 ed ff ff       	call   f0100adc <check_va2pa>
f0101d28:	89 d9                	mov    %ebx,%ecx
f0101d2a:	89 fb                	mov    %edi,%ebx
f0101d2c:	2b 99 ac 1f 00 00    	sub    0x1fac(%ecx),%ebx
f0101d32:	c1 fb 03             	sar    $0x3,%ebx
f0101d35:	c1 e3 0c             	shl    $0xc,%ebx
f0101d38:	39 d8                	cmp    %ebx,%eax
f0101d3a:	0f 85 c5 08 00 00    	jne    f0102605 <mem_init+0x1312>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d40:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d45:	89 f0                	mov    %esi,%eax
f0101d47:	e8 90 ed ff ff       	call   f0100adc <check_va2pa>
f0101d4c:	39 c3                	cmp    %eax,%ebx
f0101d4e:	0f 85 d3 08 00 00    	jne    f0102627 <mem_init+0x1334>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d54:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101d59:	0f 85 ea 08 00 00    	jne    f0102649 <mem_init+0x1356>
	assert(pp2->pp_ref == 0);
f0101d5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d62:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d67:	0f 85 fe 08 00 00    	jne    f010266b <mem_init+0x1378>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d6d:	83 ec 0c             	sub    $0xc,%esp
f0101d70:	6a 00                	push   $0x0
f0101d72:	e8 01 f2 ff ff       	call   f0100f78 <page_alloc>
f0101d77:	83 c4 10             	add    $0x10,%esp
f0101d7a:	85 c0                	test   %eax,%eax
f0101d7c:	0f 84 0b 09 00 00    	je     f010268d <mem_init+0x139a>
f0101d82:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101d85:	0f 85 02 09 00 00    	jne    f010268d <mem_init+0x139a>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d8b:	83 ec 08             	sub    $0x8,%esp
f0101d8e:	6a 00                	push   $0x0
f0101d90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d93:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101d99:	e8 79 f4 ff ff       	call   f0101217 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d9e:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101da4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101da9:	89 d8                	mov    %ebx,%eax
f0101dab:	e8 2c ed ff ff       	call   f0100adc <check_va2pa>
f0101db0:	83 c4 10             	add    $0x10,%esp
f0101db3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101db6:	0f 85 f3 08 00 00    	jne    f01026af <mem_init+0x13bc>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dbc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc1:	89 d8                	mov    %ebx,%eax
f0101dc3:	e8 14 ed ff ff       	call   f0100adc <check_va2pa>
f0101dc8:	89 c2                	mov    %eax,%edx
f0101dca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101dcd:	89 f8                	mov    %edi,%eax
f0101dcf:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0101dd5:	c1 f8 03             	sar    $0x3,%eax
f0101dd8:	c1 e0 0c             	shl    $0xc,%eax
f0101ddb:	39 c2                	cmp    %eax,%edx
f0101ddd:	0f 85 ee 08 00 00    	jne    f01026d1 <mem_init+0x13de>
	assert(pp1->pp_ref == 1);
f0101de3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101de8:	0f 85 04 09 00 00    	jne    f01026f2 <mem_init+0x13ff>
	assert(pp2->pp_ref == 0);
f0101dee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101df1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101df6:	0f 85 18 09 00 00    	jne    f0102714 <mem_init+0x1421>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101dfc:	6a 00                	push   $0x0
f0101dfe:	68 00 10 00 00       	push   $0x1000
f0101e03:	57                   	push   %edi
f0101e04:	53                   	push   %ebx
f0101e05:	e8 52 f4 ff ff       	call   f010125c <page_insert>
f0101e0a:	83 c4 10             	add    $0x10,%esp
f0101e0d:	85 c0                	test   %eax,%eax
f0101e0f:	0f 85 21 09 00 00    	jne    f0102736 <mem_init+0x1443>
	assert(pp1->pp_ref);
f0101e15:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e1a:	0f 84 38 09 00 00    	je     f0102758 <mem_init+0x1465>
	assert(pp1->pp_link == NULL);
f0101e20:	83 3f 00             	cmpl   $0x0,(%edi)
f0101e23:	0f 85 51 09 00 00    	jne    f010277a <mem_init+0x1487>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e29:	83 ec 08             	sub    $0x8,%esp
f0101e2c:	68 00 10 00 00       	push   $0x1000
f0101e31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e34:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101e3a:	e8 d8 f3 ff ff       	call   f0101217 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e3f:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101e45:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e4a:	89 d8                	mov    %ebx,%eax
f0101e4c:	e8 8b ec ff ff       	call   f0100adc <check_va2pa>
f0101e51:	83 c4 10             	add    $0x10,%esp
f0101e54:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e57:	0f 85 3f 09 00 00    	jne    f010279c <mem_init+0x14a9>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e5d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e62:	89 d8                	mov    %ebx,%eax
f0101e64:	e8 73 ec ff ff       	call   f0100adc <check_va2pa>
f0101e69:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e6c:	0f 85 4c 09 00 00    	jne    f01027be <mem_init+0x14cb>
	assert(pp1->pp_ref == 0);
f0101e72:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e77:	0f 85 63 09 00 00    	jne    f01027e0 <mem_init+0x14ed>
	assert(pp2->pp_ref == 0);
f0101e7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e80:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e85:	0f 85 77 09 00 00    	jne    f0102802 <mem_init+0x150f>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e8b:	83 ec 0c             	sub    $0xc,%esp
f0101e8e:	6a 00                	push   $0x0
f0101e90:	e8 e3 f0 ff ff       	call   f0100f78 <page_alloc>
f0101e95:	83 c4 10             	add    $0x10,%esp
f0101e98:	39 c7                	cmp    %eax,%edi
f0101e9a:	0f 85 84 09 00 00    	jne    f0102824 <mem_init+0x1531>
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	0f 84 7c 09 00 00    	je     f0102824 <mem_init+0x1531>

	// should be no free memory
	assert(!page_alloc(0));
f0101ea8:	83 ec 0c             	sub    $0xc,%esp
f0101eab:	6a 00                	push   $0x0
f0101ead:	e8 c6 f0 ff ff       	call   f0100f78 <page_alloc>
f0101eb2:	83 c4 10             	add    $0x10,%esp
f0101eb5:	85 c0                	test   %eax,%eax
f0101eb7:	0f 85 89 09 00 00    	jne    f0102846 <mem_init+0x1553>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ebd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ec0:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0101ec6:	8b 11                	mov    (%ecx),%edx
f0101ec8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ece:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101ed1:	2b 98 ac 1f 00 00    	sub    0x1fac(%eax),%ebx
f0101ed7:	89 d8                	mov    %ebx,%eax
f0101ed9:	c1 f8 03             	sar    $0x3,%eax
f0101edc:	c1 e0 0c             	shl    $0xc,%eax
f0101edf:	39 c2                	cmp    %eax,%edx
f0101ee1:	0f 85 81 09 00 00    	jne    f0102868 <mem_init+0x1575>
	kern_pgdir[0] = 0;
f0101ee7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101eed:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ef0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ef5:	0f 85 8f 09 00 00    	jne    f010288a <mem_init+0x1597>
	pp0->pp_ref = 0;
f0101efb:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101efe:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f04:	83 ec 0c             	sub    $0xc,%esp
f0101f07:	50                   	push   %eax
f0101f08:	e8 f0 f0 ff ff       	call   f0100ffd <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f0d:	83 c4 0c             	add    $0xc,%esp
f0101f10:	6a 01                	push   $0x1
f0101f12:	68 00 10 40 00       	push   $0x401000
f0101f17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f1a:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101f20:	e8 6b f1 ff ff       	call   f0101090 <pgdir_walk>
f0101f25:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f27:	89 d9                	mov    %ebx,%ecx
f0101f29:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101f2f:	8b 43 04             	mov    0x4(%ebx),%eax
f0101f32:	89 c2                	mov    %eax,%edx
f0101f34:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101f3a:	8b 89 b4 1f 00 00    	mov    0x1fb4(%ecx),%ecx
f0101f40:	c1 e8 0c             	shr    $0xc,%eax
f0101f43:	83 c4 10             	add    $0x10,%esp
f0101f46:	39 c8                	cmp    %ecx,%eax
f0101f48:	0f 83 5e 09 00 00    	jae    f01028ac <mem_init+0x15b9>
	assert(ptep == ptep1 + PTX(va));
f0101f4e:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f54:	39 d6                	cmp    %edx,%esi
f0101f56:	0f 85 6c 09 00 00    	jne    f01028c8 <mem_init+0x15d5>
	kern_pgdir[PDX(va)] = 0;
f0101f5c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101f63:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f66:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101f6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f6f:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101f75:	c1 f8 03             	sar    $0x3,%eax
f0101f78:	89 c2                	mov    %eax,%edx
f0101f7a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f7d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101f82:	39 c1                	cmp    %eax,%ecx
f0101f84:	0f 86 60 09 00 00    	jbe    f01028ea <mem_init+0x15f7>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f8a:	83 ec 04             	sub    $0x4,%esp
f0101f8d:	68 00 10 00 00       	push   $0x1000
f0101f92:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101f97:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101f9d:	52                   	push   %edx
f0101f9e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fa1:	e8 8f 1c 00 00       	call   f0103c35 <memset>
	page_free(pp0);
f0101fa6:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101fa9:	89 34 24             	mov    %esi,(%esp)
f0101fac:	e8 4c f0 ff ff       	call   f0100ffd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101fb1:	83 c4 0c             	add    $0xc,%esp
f0101fb4:	6a 01                	push   $0x1
f0101fb6:	6a 00                	push   $0x0
f0101fb8:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101fbe:	e8 cd f0 ff ff       	call   f0101090 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101fc3:	89 f0                	mov    %esi,%eax
f0101fc5:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101fcb:	c1 f8 03             	sar    $0x3,%eax
f0101fce:	89 c2                	mov    %eax,%edx
f0101fd0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101fd3:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101fd8:	83 c4 10             	add    $0x10,%esp
f0101fdb:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0101fe1:	0f 83 19 09 00 00    	jae    f0102900 <mem_init+0x160d>
	return (void *)(pa + KERNBASE);
f0101fe7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101fed:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101ff3:	8b 30                	mov    (%eax),%esi
f0101ff5:	83 e6 01             	and    $0x1,%esi
f0101ff8:	0f 85 1b 09 00 00    	jne    f0102919 <mem_init+0x1626>
	for(i=0; i<NPTENTRIES; i++)
f0101ffe:	83 c0 04             	add    $0x4,%eax
f0102001:	39 c2                	cmp    %eax,%edx
f0102003:	75 ee                	jne    f0101ff3 <mem_init+0xd00>
	kern_pgdir[0] = 0;
f0102005:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102008:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f010200e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102014:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102017:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010201d:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102020:	89 93 bc 1f 00 00    	mov    %edx,0x1fbc(%ebx)

	// free the pages we took
	page_free(pp0);
f0102026:	83 ec 0c             	sub    $0xc,%esp
f0102029:	50                   	push   %eax
f010202a:	e8 ce ef ff ff       	call   f0100ffd <page_free>
	page_free(pp1);
f010202f:	89 3c 24             	mov    %edi,(%esp)
f0102032:	e8 c6 ef ff ff       	call   f0100ffd <page_free>
	page_free(pp2);
f0102037:	83 c4 04             	add    $0x4,%esp
f010203a:	ff 75 d0             	push   -0x30(%ebp)
f010203d:	e8 bb ef ff ff       	call   f0100ffd <page_free>

	cprintf("check_page() succeeded!\n");
f0102042:	8d 83 bb dc fe ff    	lea    -0x12345(%ebx),%eax
f0102048:	89 04 24             	mov    %eax,(%esp)
f010204b:	e8 fc 0f 00 00       	call   f010304c <cprintf>
boot_map_region(kern_pgdir,UPAGES,ROUNDUP((sizeof(struct PageInfo) * npages), PGSIZE),PADDR(pages),(PTE_U | PTE_P));
f0102050:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102056:	83 c4 10             	add    $0x10,%esp
f0102059:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010205e:	0f 86 d7 08 00 00    	jbe    f010293b <mem_init+0x1648>
f0102064:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102067:	8b 97 b4 1f 00 00    	mov    0x1fb4(%edi),%edx
f010206d:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102074:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010207a:	83 ec 08             	sub    $0x8,%esp
f010207d:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010207f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102084:	50                   	push   %eax
f0102085:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010208a:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f0102090:	e8 d4 f0 ff ff       	call   f0101169 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102095:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f010209b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010209e:	83 c4 10             	add    $0x10,%esp
f01020a1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a6:	0f 86 ab 08 00 00    	jbe    f0102957 <mem_init+0x1664>
boot_map_region(kern_pgdir,(KSTACKTOP - KSTKSIZE),KSTKSIZE,PADDR(bootstack),(PTE_W | PTE_P));
f01020ac:	83 ec 08             	sub    $0x8,%esp
f01020af:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f01020b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01020b4:	05 00 00 00 10       	add    $0x10000000,%eax
f01020b9:	50                   	push   %eax
f01020ba:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020bf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020c7:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01020cd:	e8 97 f0 ff ff       	call   f0101169 <boot_map_region>
boot_map_region(kern_pgdir,KERNBASE,ROUNDUP((0xFFFFFFFF - KERNBASE), PGSIZE),0,(PTE_W) | (PTE_P));
f01020d2:	83 c4 08             	add    $0x8,%esp
f01020d5:	6a 03                	push   $0x3
f01020d7:	6a 00                	push   $0x0
f01020d9:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020de:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020e3:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01020e9:	e8 7b f0 ff ff       	call   f0101169 <boot_map_region>
	pgdir = kern_pgdir;
f01020ee:	89 f9                	mov    %edi,%ecx
f01020f0:	8b bf b0 1f 00 00    	mov    0x1fb0(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020f6:	8b 81 b4 1f 00 00    	mov    0x1fb4(%ecx),%eax
f01020fc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01020ff:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102106:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010210b:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010210d:	8b 81 ac 1f 00 00    	mov    0x1fac(%ecx),%eax
f0102113:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102116:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f010211c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010211f:	83 c4 10             	add    $0x10,%esp
f0102122:	89 f3                	mov    %esi,%ebx
f0102124:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0102127:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010212a:	89 d6                	mov    %edx,%esi
f010212c:	89 c7                	mov    %eax,%edi
f010212e:	39 de                	cmp    %ebx,%esi
f0102130:	0f 86 82 08 00 00    	jbe    f01029b8 <mem_init+0x16c5>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102136:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010213c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010213f:	e8 98 e9 ff ff       	call   f0100adc <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102144:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010214a:	0f 86 28 08 00 00    	jbe    f0102978 <mem_init+0x1685>
f0102150:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102153:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102156:	39 d0                	cmp    %edx,%eax
f0102158:	0f 85 38 08 00 00    	jne    f0102996 <mem_init+0x16a3>
	for (i = 0; i < n; i += PGSIZE)
f010215e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102164:	eb c8                	jmp    f010212e <mem_init+0xe3b>
	assert(nfree == 0);
f0102166:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102169:	8d 83 e4 db fe ff    	lea    -0x1241c(%ebx),%eax
f010216f:	50                   	push   %eax
f0102170:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102176:	50                   	push   %eax
f0102177:	68 8d 02 00 00       	push   $0x28d
f010217c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102182:	50                   	push   %eax
f0102183:	e8 11 df ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102188:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010218b:	8d 83 f2 da fe ff    	lea    -0x1250e(%ebx),%eax
f0102191:	50                   	push   %eax
f0102192:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102198:	50                   	push   %eax
f0102199:	68 e6 02 00 00       	push   $0x2e6
f010219e:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01021a4:	50                   	push   %eax
f01021a5:	e8 ef de ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01021aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021ad:	8d 83 08 db fe ff    	lea    -0x124f8(%ebx),%eax
f01021b3:	50                   	push   %eax
f01021b4:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01021ba:	50                   	push   %eax
f01021bb:	68 e7 02 00 00       	push   $0x2e7
f01021c0:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01021c6:	50                   	push   %eax
f01021c7:	e8 cd de ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01021cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021cf:	8d 83 1e db fe ff    	lea    -0x124e2(%ebx),%eax
f01021d5:	50                   	push   %eax
f01021d6:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01021dc:	50                   	push   %eax
f01021dd:	68 e8 02 00 00       	push   $0x2e8
f01021e2:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01021e8:	50                   	push   %eax
f01021e9:	e8 ab de ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01021ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021f1:	8d 83 34 db fe ff    	lea    -0x124cc(%ebx),%eax
f01021f7:	50                   	push   %eax
f01021f8:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01021fe:	50                   	push   %eax
f01021ff:	68 eb 02 00 00       	push   $0x2eb
f0102204:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010220a:	50                   	push   %eax
f010220b:	e8 89 de ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102210:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102213:	8d 83 38 d4 fe ff    	lea    -0x12bc8(%ebx),%eax
f0102219:	50                   	push   %eax
f010221a:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102220:	50                   	push   %eax
f0102221:	68 ec 02 00 00       	push   $0x2ec
f0102226:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010222c:	50                   	push   %eax
f010222d:	e8 67 de ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102232:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102235:	8d 83 9d db fe ff    	lea    -0x12463(%ebx),%eax
f010223b:	50                   	push   %eax
f010223c:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102242:	50                   	push   %eax
f0102243:	68 f3 02 00 00       	push   $0x2f3
f0102248:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010224e:	50                   	push   %eax
f010224f:	e8 45 de ff ff       	call   f0100099 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102254:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102257:	8d 83 78 d4 fe ff    	lea    -0x12b88(%ebx),%eax
f010225d:	50                   	push   %eax
f010225e:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102264:	50                   	push   %eax
f0102265:	68 f6 02 00 00       	push   $0x2f6
f010226a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102270:	50                   	push   %eax
f0102271:	e8 23 de ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102276:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102279:	8d 83 b0 d4 fe ff    	lea    -0x12b50(%ebx),%eax
f010227f:	50                   	push   %eax
f0102280:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102286:	50                   	push   %eax
f0102287:	68 f9 02 00 00       	push   $0x2f9
f010228c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102292:	50                   	push   %eax
f0102293:	e8 01 de ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102298:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229b:	8d 83 e0 d4 fe ff    	lea    -0x12b20(%ebx),%eax
f01022a1:	50                   	push   %eax
f01022a2:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01022a8:	50                   	push   %eax
f01022a9:	68 fd 02 00 00       	push   $0x2fd
f01022ae:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01022b4:	50                   	push   %eax
f01022b5:	e8 df dd ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022bd:	8d 83 10 d5 fe ff    	lea    -0x12af0(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	68 fe 02 00 00       	push   $0x2fe
f01022d0:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01022d6:	50                   	push   %eax
f01022d7:	e8 bd dd ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022df:	8d 83 38 d5 fe ff    	lea    -0x12ac8(%ebx),%eax
f01022e5:	50                   	push   %eax
f01022e6:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01022ec:	50                   	push   %eax
f01022ed:	68 ff 02 00 00       	push   $0x2ff
f01022f2:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01022f8:	50                   	push   %eax
f01022f9:	e8 9b dd ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f01022fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102301:	8d 83 ef db fe ff    	lea    -0x12411(%ebx),%eax
f0102307:	50                   	push   %eax
f0102308:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	68 00 03 00 00       	push   $0x300
f0102314:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010231a:	50                   	push   %eax
f010231b:	e8 79 dd ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102320:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102323:	8d 83 00 dc fe ff    	lea    -0x12400(%ebx),%eax
f0102329:	50                   	push   %eax
f010232a:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102330:	50                   	push   %eax
f0102331:	68 01 03 00 00       	push   $0x301
f0102336:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010233c:	50                   	push   %eax
f010233d:	e8 57 dd ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102342:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102345:	8d 83 68 d5 fe ff    	lea    -0x12a98(%ebx),%eax
f010234b:	50                   	push   %eax
f010234c:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	68 04 03 00 00       	push   $0x304
f0102358:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010235e:	50                   	push   %eax
f010235f:	e8 35 dd ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102364:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102367:	8d 83 a4 d5 fe ff    	lea    -0x12a5c(%ebx),%eax
f010236d:	50                   	push   %eax
f010236e:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102374:	50                   	push   %eax
f0102375:	68 05 03 00 00       	push   $0x305
f010237a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102380:	50                   	push   %eax
f0102381:	e8 13 dd ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102386:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102389:	8d 83 11 dc fe ff    	lea    -0x123ef(%ebx),%eax
f010238f:	50                   	push   %eax
f0102390:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	68 06 03 00 00       	push   $0x306
f010239c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01023a2:	50                   	push   %eax
f01023a3:	e8 f1 dc ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01023a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ab:	8d 83 9d db fe ff    	lea    -0x12463(%ebx),%eax
f01023b1:	50                   	push   %eax
f01023b2:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	68 09 03 00 00       	push   $0x309
f01023be:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01023c4:	50                   	push   %eax
f01023c5:	e8 cf dc ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cd:	8d 83 68 d5 fe ff    	lea    -0x12a98(%ebx),%eax
f01023d3:	50                   	push   %eax
f01023d4:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	68 0c 03 00 00       	push   $0x30c
f01023e0:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01023e6:	50                   	push   %eax
f01023e7:	e8 ad dc ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ef:	8d 83 a4 d5 fe ff    	lea    -0x12a5c(%ebx),%eax
f01023f5:	50                   	push   %eax
f01023f6:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01023fc:	50                   	push   %eax
f01023fd:	68 0d 03 00 00       	push   $0x30d
f0102402:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102408:	50                   	push   %eax
f0102409:	e8 8b dc ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f010240e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102411:	8d 83 11 dc fe ff    	lea    -0x123ef(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	68 0e 03 00 00       	push   $0x30e
f0102424:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010242a:	50                   	push   %eax
f010242b:	e8 69 dc ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102430:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102433:	8d 83 9d db fe ff    	lea    -0x12463(%ebx),%eax
f0102439:	50                   	push   %eax
f010243a:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102440:	50                   	push   %eax
f0102441:	68 12 03 00 00       	push   $0x312
f0102446:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010244c:	50                   	push   %eax
f010244d:	e8 47 dc ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102452:	53                   	push   %ebx
f0102453:	89 cb                	mov    %ecx,%ebx
f0102455:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f010245b:	50                   	push   %eax
f010245c:	68 15 03 00 00       	push   $0x315
f0102461:	8d 81 21 da fe ff    	lea    -0x125df(%ecx),%eax
f0102467:	50                   	push   %eax
f0102468:	e8 2c dc ff ff       	call   f0100099 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010246d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102470:	8d 83 d4 d5 fe ff    	lea    -0x12a2c(%ebx),%eax
f0102476:	50                   	push   %eax
f0102477:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010247d:	50                   	push   %eax
f010247e:	68 16 03 00 00       	push   $0x316
f0102483:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102489:	50                   	push   %eax
f010248a:	e8 0a dc ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010248f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102492:	8d 83 14 d6 fe ff    	lea    -0x129ec(%ebx),%eax
f0102498:	50                   	push   %eax
f0102499:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010249f:	50                   	push   %eax
f01024a0:	68 19 03 00 00       	push   $0x319
f01024a5:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01024ab:	50                   	push   %eax
f01024ac:	e8 e8 db ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b4:	8d 83 a4 d5 fe ff    	lea    -0x12a5c(%ebx),%eax
f01024ba:	50                   	push   %eax
f01024bb:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01024c1:	50                   	push   %eax
f01024c2:	68 1a 03 00 00       	push   $0x31a
f01024c7:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01024cd:	50                   	push   %eax
f01024ce:	e8 c6 db ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01024d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d6:	8d 83 11 dc fe ff    	lea    -0x123ef(%ebx),%eax
f01024dc:	50                   	push   %eax
f01024dd:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01024e3:	50                   	push   %eax
f01024e4:	68 1b 03 00 00       	push   $0x31b
f01024e9:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01024ef:	50                   	push   %eax
f01024f0:	e8 a4 db ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024f8:	8d 83 54 d6 fe ff    	lea    -0x129ac(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102505:	50                   	push   %eax
f0102506:	68 1c 03 00 00       	push   $0x31c
f010250b:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102511:	50                   	push   %eax
f0102512:	e8 82 db ff ff       	call   f0100099 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102517:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010251a:	8d 83 22 dc fe ff    	lea    -0x123de(%ebx),%eax
f0102520:	50                   	push   %eax
f0102521:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102527:	50                   	push   %eax
f0102528:	68 1d 03 00 00       	push   $0x31d
f010252d:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102533:	50                   	push   %eax
f0102534:	e8 60 db ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102539:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010253c:	8d 83 68 d5 fe ff    	lea    -0x12a98(%ebx),%eax
f0102542:	50                   	push   %eax
f0102543:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102549:	50                   	push   %eax
f010254a:	68 20 03 00 00       	push   $0x320
f010254f:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102555:	50                   	push   %eax
f0102556:	e8 3e db ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010255b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010255e:	8d 83 88 d6 fe ff    	lea    -0x12978(%ebx),%eax
f0102564:	50                   	push   %eax
f0102565:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010256b:	50                   	push   %eax
f010256c:	68 21 03 00 00       	push   $0x321
f0102571:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102577:	50                   	push   %eax
f0102578:	e8 1c db ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010257d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102580:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0102586:	50                   	push   %eax
f0102587:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	68 22 03 00 00       	push   $0x322
f0102593:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102599:	50                   	push   %eax
f010259a:	e8 fa da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010259f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a2:	8d 83 f4 d6 fe ff    	lea    -0x1290c(%ebx),%eax
f01025a8:	50                   	push   %eax
f01025a9:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01025af:	50                   	push   %eax
f01025b0:	68 25 03 00 00       	push   $0x325
f01025b5:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01025bb:	50                   	push   %eax
f01025bc:	e8 d8 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c4:	8d 83 2c d7 fe ff    	lea    -0x128d4(%ebx),%eax
f01025ca:	50                   	push   %eax
f01025cb:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	68 28 03 00 00       	push   $0x328
f01025d7:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	e8 b6 da ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e6:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f01025ec:	50                   	push   %eax
f01025ed:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01025f3:	50                   	push   %eax
f01025f4:	68 29 03 00 00       	push   $0x329
f01025f9:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01025ff:	50                   	push   %eax
f0102600:	e8 94 da ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102605:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102608:	8d 83 68 d7 fe ff    	lea    -0x12898(%ebx),%eax
f010260e:	50                   	push   %eax
f010260f:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	68 2c 03 00 00       	push   $0x32c
f010261b:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102621:	50                   	push   %eax
f0102622:	e8 72 da ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102627:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262a:	8d 83 94 d7 fe ff    	lea    -0x1286c(%ebx),%eax
f0102630:	50                   	push   %eax
f0102631:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102637:	50                   	push   %eax
f0102638:	68 2d 03 00 00       	push   $0x32d
f010263d:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102643:	50                   	push   %eax
f0102644:	e8 50 da ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 2);
f0102649:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264c:	8d 83 38 dc fe ff    	lea    -0x123c8(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	68 2f 03 00 00       	push   $0x32f
f010265f:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102665:	50                   	push   %eax
f0102666:	e8 2e da ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f010266b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010266e:	8d 83 49 dc fe ff    	lea    -0x123b7(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	68 30 03 00 00       	push   $0x330
f0102681:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102687:	50                   	push   %eax
f0102688:	e8 0c da ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010268d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102690:	8d 83 c4 d7 fe ff    	lea    -0x1283c(%ebx),%eax
f0102696:	50                   	push   %eax
f0102697:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	68 33 03 00 00       	push   $0x333
f01026a3:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01026a9:	50                   	push   %eax
f01026aa:	e8 ea d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b2:	8d 83 e8 d7 fe ff    	lea    -0x12818(%ebx),%eax
f01026b8:	50                   	push   %eax
f01026b9:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01026bf:	50                   	push   %eax
f01026c0:	68 37 03 00 00       	push   $0x337
f01026c5:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01026cb:	50                   	push   %eax
f01026cc:	e8 c8 d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026d1:	89 cb                	mov    %ecx,%ebx
f01026d3:	8d 81 94 d7 fe ff    	lea    -0x1286c(%ecx),%eax
f01026d9:	50                   	push   %eax
f01026da:	8d 81 47 da fe ff    	lea    -0x125b9(%ecx),%eax
f01026e0:	50                   	push   %eax
f01026e1:	68 38 03 00 00       	push   $0x338
f01026e6:	8d 81 21 da fe ff    	lea    -0x125df(%ecx),%eax
f01026ec:	50                   	push   %eax
f01026ed:	e8 a7 d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f01026f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f5:	8d 83 ef db fe ff    	lea    -0x12411(%ebx),%eax
f01026fb:	50                   	push   %eax
f01026fc:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102702:	50                   	push   %eax
f0102703:	68 39 03 00 00       	push   $0x339
f0102708:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010270e:	50                   	push   %eax
f010270f:	e8 85 d9 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102714:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102717:	8d 83 49 dc fe ff    	lea    -0x123b7(%ebx),%eax
f010271d:	50                   	push   %eax
f010271e:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102724:	50                   	push   %eax
f0102725:	68 3a 03 00 00       	push   $0x33a
f010272a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102730:	50                   	push   %eax
f0102731:	e8 63 d9 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102736:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102739:	8d 83 0c d8 fe ff    	lea    -0x127f4(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102746:	50                   	push   %eax
f0102747:	68 3d 03 00 00       	push   $0x33d
f010274c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102752:	50                   	push   %eax
f0102753:	e8 41 d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref);
f0102758:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275b:	8d 83 5a dc fe ff    	lea    -0x123a6(%ebx),%eax
f0102761:	50                   	push   %eax
f0102762:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102768:	50                   	push   %eax
f0102769:	68 3e 03 00 00       	push   $0x33e
f010276e:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102774:	50                   	push   %eax
f0102775:	e8 1f d9 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_link == NULL);
f010277a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010277d:	8d 83 66 dc fe ff    	lea    -0x1239a(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010278a:	50                   	push   %eax
f010278b:	68 3f 03 00 00       	push   $0x33f
f0102790:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102796:	50                   	push   %eax
f0102797:	e8 fd d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010279c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010279f:	8d 83 e8 d7 fe ff    	lea    -0x12818(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01027ac:	50                   	push   %eax
f01027ad:	68 43 03 00 00       	push   $0x343
f01027b2:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01027b8:	50                   	push   %eax
f01027b9:	e8 db d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c1:	8d 83 44 d8 fe ff    	lea    -0x127bc(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	68 44 03 00 00       	push   $0x344
f01027d4:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01027da:	50                   	push   %eax
f01027db:	e8 b9 d8 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f01027e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e3:	8d 83 7b dc fe ff    	lea    -0x12385(%ebx),%eax
f01027e9:	50                   	push   %eax
f01027ea:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	68 45 03 00 00       	push   $0x345
f01027f6:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01027fc:	50                   	push   %eax
f01027fd:	e8 97 d8 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102802:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102805:	8d 83 49 dc fe ff    	lea    -0x123b7(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	68 46 03 00 00       	push   $0x346
f0102818:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	e8 75 d8 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102824:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102827:	8d 83 6c d8 fe ff    	lea    -0x12794(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102834:	50                   	push   %eax
f0102835:	68 49 03 00 00       	push   $0x349
f010283a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102840:	50                   	push   %eax
f0102841:	e8 53 d8 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102846:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102849:	8d 83 9d db fe ff    	lea    -0x12463(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102856:	50                   	push   %eax
f0102857:	68 4c 03 00 00       	push   $0x34c
f010285c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102862:	50                   	push   %eax
f0102863:	e8 31 d8 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102868:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286b:	8d 83 10 d5 fe ff    	lea    -0x12af0(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	68 4f 03 00 00       	push   $0x34f
f010287e:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102884:	50                   	push   %eax
f0102885:	e8 0f d8 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f010288a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288d:	8d 83 00 dc fe ff    	lea    -0x12400(%ebx),%eax
f0102893:	50                   	push   %eax
f0102894:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f010289a:	50                   	push   %eax
f010289b:	68 51 03 00 00       	push   $0x351
f01028a0:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01028a6:	50                   	push   %eax
f01028a7:	e8 ed d7 ff ff       	call   f0100099 <_panic>
f01028ac:	52                   	push   %edx
f01028ad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b0:	8d 83 4c d2 fe ff    	lea    -0x12db4(%ebx),%eax
f01028b6:	50                   	push   %eax
f01028b7:	68 58 03 00 00       	push   $0x358
f01028bc:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01028c2:	50                   	push   %eax
f01028c3:	e8 d1 d7 ff ff       	call   f0100099 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028c8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028cb:	8d 83 8c dc fe ff    	lea    -0x12374(%ebx),%eax
f01028d1:	50                   	push   %eax
f01028d2:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	68 59 03 00 00       	push   $0x359
f01028de:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	e8 af d7 ff ff       	call   f0100099 <_panic>
f01028ea:	52                   	push   %edx
f01028eb:	8d 83 4c d2 fe ff    	lea    -0x12db4(%ebx),%eax
f01028f1:	50                   	push   %eax
f01028f2:	6a 52                	push   $0x52
f01028f4:	8d 83 2d da fe ff    	lea    -0x125d3(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	e8 99 d7 ff ff       	call   f0100099 <_panic>
f0102900:	52                   	push   %edx
f0102901:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102904:	8d 83 4c d2 fe ff    	lea    -0x12db4(%ebx),%eax
f010290a:	50                   	push   %eax
f010290b:	6a 52                	push   $0x52
f010290d:	8d 83 2d da fe ff    	lea    -0x125d3(%ebx),%eax
f0102913:	50                   	push   %eax
f0102914:	e8 80 d7 ff ff       	call   f0100099 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102919:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010291c:	8d 83 a4 dc fe ff    	lea    -0x1235c(%ebx),%eax
f0102922:	50                   	push   %eax
f0102923:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102929:	50                   	push   %eax
f010292a:	68 63 03 00 00       	push   $0x363
f010292f:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102935:	50                   	push   %eax
f0102936:	e8 5e d7 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010293b:	50                   	push   %eax
f010293c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293f:	8d 83 14 d4 fe ff    	lea    -0x12bec(%ebx),%eax
f0102945:	50                   	push   %eax
f0102946:	68 b4 00 00 00       	push   $0xb4
f010294b:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102951:	50                   	push   %eax
f0102952:	e8 42 d7 ff ff       	call   f0100099 <_panic>
f0102957:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010295a:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102960:	8d 83 14 d4 fe ff    	lea    -0x12bec(%ebx),%eax
f0102966:	50                   	push   %eax
f0102967:	68 c0 00 00 00       	push   $0xc0
f010296c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102972:	50                   	push   %eax
f0102973:	e8 21 d7 ff ff       	call   f0100099 <_panic>
f0102978:	ff 75 bc             	push   -0x44(%ebp)
f010297b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010297e:	8d 83 14 d4 fe ff    	lea    -0x12bec(%ebx),%eax
f0102984:	50                   	push   %eax
f0102985:	68 a5 02 00 00       	push   $0x2a5
f010298a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102990:	50                   	push   %eax
f0102991:	e8 03 d7 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102996:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102999:	8d 83 90 d8 fe ff    	lea    -0x12770(%ebx),%eax
f010299f:	50                   	push   %eax
f01029a0:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01029a6:	50                   	push   %eax
f01029a7:	68 a5 02 00 00       	push   $0x2a5
f01029ac:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f01029b2:	50                   	push   %eax
f01029b3:	e8 e1 d6 ff ff       	call   f0100099 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029b8:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01029bb:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029be:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029c1:	c1 e0 0c             	shl    $0xc,%eax
f01029c4:	89 f3                	mov    %esi,%ebx
f01029c6:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01029c9:	89 c6                	mov    %eax,%esi
f01029cb:	39 f3                	cmp    %esi,%ebx
f01029cd:	73 3b                	jae    f0102a0a <mem_init+0x1717>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029cf:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029d5:	89 f8                	mov    %edi,%eax
f01029d7:	e8 00 e1 ff ff       	call   f0100adc <check_va2pa>
f01029dc:	39 c3                	cmp    %eax,%ebx
f01029de:	75 08                	jne    f01029e8 <mem_init+0x16f5>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029e6:	eb e3                	jmp    f01029cb <mem_init+0x16d8>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029eb:	8d 83 c4 d8 fe ff    	lea    -0x1273c(%ebx),%eax
f01029f1:	50                   	push   %eax
f01029f2:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f01029f8:	50                   	push   %eax
f01029f9:	68 aa 02 00 00       	push   $0x2aa
f01029fe:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102a04:	50                   	push   %eax
f0102a05:	e8 8f d6 ff ff       	call   f0100099 <_panic>
f0102a0a:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a0f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a12:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a17:	89 c6                	mov    %eax,%esi
f0102a19:	89 da                	mov    %ebx,%edx
f0102a1b:	89 f8                	mov    %edi,%eax
f0102a1d:	e8 ba e0 ff ff       	call   f0100adc <check_va2pa>
f0102a22:	89 c2                	mov    %eax,%edx
f0102a24:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102a27:	39 c2                	cmp    %eax,%edx
f0102a29:	75 44                	jne    f0102a6f <mem_init+0x177c>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a2b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a31:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a37:	75 e0                	jne    f0102a19 <mem_init+0x1726>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a39:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102a3c:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a41:	89 f8                	mov    %edi,%eax
f0102a43:	e8 94 e0 ff ff       	call   f0100adc <check_va2pa>
f0102a48:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a4b:	74 71                	je     f0102abe <mem_init+0x17cb>
f0102a4d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a50:	8d 83 34 d9 fe ff    	lea    -0x126cc(%ebx),%eax
f0102a56:	50                   	push   %eax
f0102a57:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102a5d:	50                   	push   %eax
f0102a5e:	68 af 02 00 00       	push   $0x2af
f0102a63:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102a69:	50                   	push   %eax
f0102a6a:	e8 2a d6 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a6f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a72:	8d 83 ec d8 fe ff    	lea    -0x12714(%ebx),%eax
f0102a78:	50                   	push   %eax
f0102a79:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102a7f:	50                   	push   %eax
f0102a80:	68 ae 02 00 00       	push   $0x2ae
f0102a85:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102a8b:	50                   	push   %eax
f0102a8c:	e8 08 d6 ff ff       	call   f0100099 <_panic>
		switch (i) {
f0102a91:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102a97:	75 25                	jne    f0102abe <mem_init+0x17cb>
			assert(pgdir[i] & PTE_P);
f0102a99:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102a9d:	74 4f                	je     f0102aee <mem_init+0x17fb>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a9f:	83 c6 01             	add    $0x1,%esi
f0102aa2:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102aa8:	0f 87 b1 00 00 00    	ja     f0102b5f <mem_init+0x186c>
		switch (i) {
f0102aae:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102ab4:	77 db                	ja     f0102a91 <mem_init+0x179e>
f0102ab6:	81 fe bb 03 00 00    	cmp    $0x3bb,%esi
f0102abc:	77 db                	ja     f0102a99 <mem_init+0x17a6>
			if (i >= PDX(KERNBASE)) {
f0102abe:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102ac4:	77 4a                	ja     f0102b10 <mem_init+0x181d>
				assert(pgdir[i] == 0);
f0102ac6:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102aca:	74 d3                	je     f0102a9f <mem_init+0x17ac>
f0102acc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102acf:	8d 83 f6 dc fe ff    	lea    -0x1230a(%ebx),%eax
f0102ad5:	50                   	push   %eax
f0102ad6:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102adc:	50                   	push   %eax
f0102add:	68 be 02 00 00       	push   $0x2be
f0102ae2:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102ae8:	50                   	push   %eax
f0102ae9:	e8 ab d5 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102aee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af1:	8d 83 d4 dc fe ff    	lea    -0x1232c(%ebx),%eax
f0102af7:	50                   	push   %eax
f0102af8:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102afe:	50                   	push   %eax
f0102aff:	68 b7 02 00 00       	push   $0x2b7
f0102b04:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102b0a:	50                   	push   %eax
f0102b0b:	e8 89 d5 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b10:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102b13:	a8 01                	test   $0x1,%al
f0102b15:	74 26                	je     f0102b3d <mem_init+0x184a>
				assert(pgdir[i] & PTE_W);
f0102b17:	a8 02                	test   $0x2,%al
f0102b19:	75 84                	jne    f0102a9f <mem_init+0x17ac>
f0102b1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b1e:	8d 83 e5 dc fe ff    	lea    -0x1231b(%ebx),%eax
f0102b24:	50                   	push   %eax
f0102b25:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102b2b:	50                   	push   %eax
f0102b2c:	68 bc 02 00 00       	push   $0x2bc
f0102b31:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102b37:	50                   	push   %eax
f0102b38:	e8 5c d5 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b3d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b40:	8d 83 d4 dc fe ff    	lea    -0x1232c(%ebx),%eax
f0102b46:	50                   	push   %eax
f0102b47:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102b4d:	50                   	push   %eax
f0102b4e:	68 bb 02 00 00       	push   $0x2bb
f0102b53:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102b59:	50                   	push   %eax
f0102b5a:	e8 3a d5 ff ff       	call   f0100099 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b5f:	83 ec 0c             	sub    $0xc,%esp
f0102b62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b65:	8d 83 64 d9 fe ff    	lea    -0x1269c(%ebx),%eax
f0102b6b:	50                   	push   %eax
f0102b6c:	e8 db 04 00 00       	call   f010304c <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b71:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102b77:	83 c4 10             	add    $0x10,%esp
f0102b7a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b7f:	0f 86 2c 02 00 00    	jbe    f0102db1 <mem_init+0x1abe>
	return (physaddr_t)kva - KERNBASE;
f0102b85:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b8a:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b92:	e8 c1 df ff ff       	call   f0100b58 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b97:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b9a:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b9d:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ba2:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ba5:	83 ec 0c             	sub    $0xc,%esp
f0102ba8:	6a 00                	push   $0x0
f0102baa:	e8 c9 e3 ff ff       	call   f0100f78 <page_alloc>
f0102baf:	89 c6                	mov    %eax,%esi
f0102bb1:	83 c4 10             	add    $0x10,%esp
f0102bb4:	85 c0                	test   %eax,%eax
f0102bb6:	0f 84 11 02 00 00    	je     f0102dcd <mem_init+0x1ada>
	assert((pp1 = page_alloc(0)));
f0102bbc:	83 ec 0c             	sub    $0xc,%esp
f0102bbf:	6a 00                	push   $0x0
f0102bc1:	e8 b2 e3 ff ff       	call   f0100f78 <page_alloc>
f0102bc6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102bc9:	83 c4 10             	add    $0x10,%esp
f0102bcc:	85 c0                	test   %eax,%eax
f0102bce:	0f 84 1b 02 00 00    	je     f0102def <mem_init+0x1afc>
	assert((pp2 = page_alloc(0)));
f0102bd4:	83 ec 0c             	sub    $0xc,%esp
f0102bd7:	6a 00                	push   $0x0
f0102bd9:	e8 9a e3 ff ff       	call   f0100f78 <page_alloc>
f0102bde:	89 c7                	mov    %eax,%edi
f0102be0:	83 c4 10             	add    $0x10,%esp
f0102be3:	85 c0                	test   %eax,%eax
f0102be5:	0f 84 26 02 00 00    	je     f0102e11 <mem_init+0x1b1e>
	page_free(pp0);
f0102beb:	83 ec 0c             	sub    $0xc,%esp
f0102bee:	56                   	push   %esi
f0102bef:	e8 09 e4 ff ff       	call   f0100ffd <page_free>
	return (pp - pages) << PGSHIFT;
f0102bf4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102bf7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102bfa:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0102c00:	c1 f8 03             	sar    $0x3,%eax
f0102c03:	89 c2                	mov    %eax,%edx
f0102c05:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c08:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c0d:	83 c4 10             	add    $0x10,%esp
f0102c10:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0102c16:	0f 83 17 02 00 00    	jae    f0102e33 <mem_init+0x1b40>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c1c:	83 ec 04             	sub    $0x4,%esp
f0102c1f:	68 00 10 00 00       	push   $0x1000
f0102c24:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c26:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c2c:	52                   	push   %edx
f0102c2d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c30:	e8 00 10 00 00       	call   f0103c35 <memset>
	return (pp - pages) << PGSHIFT;
f0102c35:	89 f8                	mov    %edi,%eax
f0102c37:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102c3d:	c1 f8 03             	sar    $0x3,%eax
f0102c40:	89 c2                	mov    %eax,%edx
f0102c42:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c45:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c4a:	83 c4 10             	add    $0x10,%esp
f0102c4d:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102c53:	0f 83 f2 01 00 00    	jae    f0102e4b <mem_init+0x1b58>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c59:	83 ec 04             	sub    $0x4,%esp
f0102c5c:	68 00 10 00 00       	push   $0x1000
f0102c61:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c63:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c69:	52                   	push   %edx
f0102c6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c6d:	e8 c3 0f 00 00       	call   f0103c35 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c72:	6a 02                	push   $0x2
f0102c74:	68 00 10 00 00       	push   $0x1000
f0102c79:	ff 75 d0             	push   -0x30(%ebp)
f0102c7c:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0102c82:	e8 d5 e5 ff ff       	call   f010125c <page_insert>
	assert(pp1->pp_ref == 1);
f0102c87:	83 c4 20             	add    $0x20,%esp
f0102c8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c8d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102c92:	0f 85 cc 01 00 00    	jne    f0102e64 <mem_init+0x1b71>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c98:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c9f:	01 01 01 
f0102ca2:	0f 85 de 01 00 00    	jne    f0102e86 <mem_init+0x1b93>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ca8:	6a 02                	push   $0x2
f0102caa:	68 00 10 00 00       	push   $0x1000
f0102caf:	57                   	push   %edi
f0102cb0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cb3:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0102cb9:	e8 9e e5 ff ff       	call   f010125c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cbe:	83 c4 10             	add    $0x10,%esp
f0102cc1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cc8:	02 02 02 
f0102ccb:	0f 85 d7 01 00 00    	jne    f0102ea8 <mem_init+0x1bb5>
	assert(pp2->pp_ref == 1);
f0102cd1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cd6:	0f 85 ee 01 00 00    	jne    f0102eca <mem_init+0x1bd7>
	assert(pp1->pp_ref == 0);
f0102cdc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cdf:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102ce4:	0f 85 02 02 00 00    	jne    f0102eec <mem_init+0x1bf9>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cea:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cf1:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102cf4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102cf7:	89 f8                	mov    %edi,%eax
f0102cf9:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0102cff:	c1 f8 03             	sar    $0x3,%eax
f0102d02:	89 c2                	mov    %eax,%edx
f0102d04:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d07:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d0c:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0102d12:	0f 83 f6 01 00 00    	jae    f0102f0e <mem_init+0x1c1b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d18:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d1f:	03 03 03 
f0102d22:	0f 85 fe 01 00 00    	jne    f0102f26 <mem_init+0x1c33>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d28:	83 ec 08             	sub    $0x8,%esp
f0102d2b:	68 00 10 00 00       	push   $0x1000
f0102d30:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d33:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0102d39:	e8 d9 e4 ff ff       	call   f0101217 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d3e:	83 c4 10             	add    $0x10,%esp
f0102d41:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d46:	0f 85 fc 01 00 00    	jne    f0102f48 <mem_init+0x1c55>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d4f:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0102d55:	8b 11                	mov    (%ecx),%edx
f0102d57:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d5d:	89 f7                	mov    %esi,%edi
f0102d5f:	2b b8 ac 1f 00 00    	sub    0x1fac(%eax),%edi
f0102d65:	89 f8                	mov    %edi,%eax
f0102d67:	c1 f8 03             	sar    $0x3,%eax
f0102d6a:	c1 e0 0c             	shl    $0xc,%eax
f0102d6d:	39 c2                	cmp    %eax,%edx
f0102d6f:	0f 85 f5 01 00 00    	jne    f0102f6a <mem_init+0x1c77>
	kern_pgdir[0] = 0;
f0102d75:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d7b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d80:	0f 85 06 02 00 00    	jne    f0102f8c <mem_init+0x1c99>
	pp0->pp_ref = 0;
f0102d86:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d8c:	83 ec 0c             	sub    $0xc,%esp
f0102d8f:	56                   	push   %esi
f0102d90:	e8 68 e2 ff ff       	call   f0100ffd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d95:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d98:	8d 83 f8 d9 fe ff    	lea    -0x12608(%ebx),%eax
f0102d9e:	89 04 24             	mov    %eax,(%esp)
f0102da1:	e8 a6 02 00 00       	call   f010304c <cprintf>
}
f0102da6:	83 c4 10             	add    $0x10,%esp
f0102da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dac:	5b                   	pop    %ebx
f0102dad:	5e                   	pop    %esi
f0102dae:	5f                   	pop    %edi
f0102daf:	5d                   	pop    %ebp
f0102db0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102db1:	50                   	push   %eax
f0102db2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102db5:	8d 83 14 d4 fe ff    	lea    -0x12bec(%ebx),%eax
f0102dbb:	50                   	push   %eax
f0102dbc:	68 d4 00 00 00       	push   $0xd4
f0102dc1:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102dc7:	50                   	push   %eax
f0102dc8:	e8 cc d2 ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102dcd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd0:	8d 83 f2 da fe ff    	lea    -0x1250e(%ebx),%eax
f0102dd6:	50                   	push   %eax
f0102dd7:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102ddd:	50                   	push   %eax
f0102dde:	68 7e 03 00 00       	push   $0x37e
f0102de3:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102de9:	50                   	push   %eax
f0102dea:	e8 aa d2 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f0102def:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df2:	8d 83 08 db fe ff    	lea    -0x124f8(%ebx),%eax
f0102df8:	50                   	push   %eax
f0102df9:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102dff:	50                   	push   %eax
f0102e00:	68 7f 03 00 00       	push   $0x37f
f0102e05:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102e0b:	50                   	push   %eax
f0102e0c:	e8 88 d2 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e11:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e14:	8d 83 1e db fe ff    	lea    -0x124e2(%ebx),%eax
f0102e1a:	50                   	push   %eax
f0102e1b:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102e21:	50                   	push   %eax
f0102e22:	68 80 03 00 00       	push   $0x380
f0102e27:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102e2d:	50                   	push   %eax
f0102e2e:	e8 66 d2 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e33:	52                   	push   %edx
f0102e34:	89 cb                	mov    %ecx,%ebx
f0102e36:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f0102e3c:	50                   	push   %eax
f0102e3d:	6a 52                	push   $0x52
f0102e3f:	8d 81 2d da fe ff    	lea    -0x125d3(%ecx),%eax
f0102e45:	50                   	push   %eax
f0102e46:	e8 4e d2 ff ff       	call   f0100099 <_panic>
f0102e4b:	52                   	push   %edx
f0102e4c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e4f:	8d 83 4c d2 fe ff    	lea    -0x12db4(%ebx),%eax
f0102e55:	50                   	push   %eax
f0102e56:	6a 52                	push   $0x52
f0102e58:	8d 83 2d da fe ff    	lea    -0x125d3(%ebx),%eax
f0102e5e:	50                   	push   %eax
f0102e5f:	e8 35 d2 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0102e64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e67:	8d 83 ef db fe ff    	lea    -0x12411(%ebx),%eax
f0102e6d:	50                   	push   %eax
f0102e6e:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102e74:	50                   	push   %eax
f0102e75:	68 85 03 00 00       	push   $0x385
f0102e7a:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102e80:	50                   	push   %eax
f0102e81:	e8 13 d2 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e86:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e89:	8d 83 84 d9 fe ff    	lea    -0x1267c(%ebx),%eax
f0102e8f:	50                   	push   %eax
f0102e90:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102e96:	50                   	push   %eax
f0102e97:	68 86 03 00 00       	push   $0x386
f0102e9c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102ea2:	50                   	push   %eax
f0102ea3:	e8 f1 d1 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ea8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eab:	8d 83 a8 d9 fe ff    	lea    -0x12658(%ebx),%eax
f0102eb1:	50                   	push   %eax
f0102eb2:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102eb8:	50                   	push   %eax
f0102eb9:	68 88 03 00 00       	push   $0x388
f0102ebe:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102ec4:	50                   	push   %eax
f0102ec5:	e8 cf d1 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102eca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ecd:	8d 83 11 dc fe ff    	lea    -0x123ef(%ebx),%eax
f0102ed3:	50                   	push   %eax
f0102ed4:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102eda:	50                   	push   %eax
f0102edb:	68 89 03 00 00       	push   $0x389
f0102ee0:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102ee6:	50                   	push   %eax
f0102ee7:	e8 ad d1 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f0102eec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eef:	8d 83 7b dc fe ff    	lea    -0x12385(%ebx),%eax
f0102ef5:	50                   	push   %eax
f0102ef6:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102efc:	50                   	push   %eax
f0102efd:	68 8a 03 00 00       	push   $0x38a
f0102f02:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102f08:	50                   	push   %eax
f0102f09:	e8 8b d1 ff ff       	call   f0100099 <_panic>
f0102f0e:	52                   	push   %edx
f0102f0f:	89 cb                	mov    %ecx,%ebx
f0102f11:	8d 81 4c d2 fe ff    	lea    -0x12db4(%ecx),%eax
f0102f17:	50                   	push   %eax
f0102f18:	6a 52                	push   $0x52
f0102f1a:	8d 81 2d da fe ff    	lea    -0x125d3(%ecx),%eax
f0102f20:	50                   	push   %eax
f0102f21:	e8 73 d1 ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f26:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f29:	8d 83 cc d9 fe ff    	lea    -0x12634(%ebx),%eax
f0102f2f:	50                   	push   %eax
f0102f30:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102f36:	50                   	push   %eax
f0102f37:	68 8c 03 00 00       	push   $0x38c
f0102f3c:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102f42:	50                   	push   %eax
f0102f43:	e8 51 d1 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102f48:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f4b:	8d 83 49 dc fe ff    	lea    -0x123b7(%ebx),%eax
f0102f51:	50                   	push   %eax
f0102f52:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102f58:	50                   	push   %eax
f0102f59:	68 8e 03 00 00       	push   $0x38e
f0102f5e:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102f64:	50                   	push   %eax
f0102f65:	e8 2f d1 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6d:	8d 83 10 d5 fe ff    	lea    -0x12af0(%ebx),%eax
f0102f73:	50                   	push   %eax
f0102f74:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102f7a:	50                   	push   %eax
f0102f7b:	68 91 03 00 00       	push   $0x391
f0102f80:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102f86:	50                   	push   %eax
f0102f87:	e8 0d d1 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102f8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8f:	8d 83 00 dc fe ff    	lea    -0x12400(%ebx),%eax
f0102f95:	50                   	push   %eax
f0102f96:	8d 83 47 da fe ff    	lea    -0x125b9(%ebx),%eax
f0102f9c:	50                   	push   %eax
f0102f9d:	68 93 03 00 00       	push   $0x393
f0102fa2:	8d 83 21 da fe ff    	lea    -0x125df(%ebx),%eax
f0102fa8:	50                   	push   %eax
f0102fa9:	e8 eb d0 ff ff       	call   f0100099 <_panic>

f0102fae <tlb_invalidate>:
{
f0102fae:	55                   	push   %ebp
f0102faf:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fb4:	0f 01 38             	invlpg (%eax)
}
f0102fb7:	5d                   	pop    %ebp
f0102fb8:	c3                   	ret    

f0102fb9 <__x86.get_pc_thunk.dx>:
f0102fb9:	8b 14 24             	mov    (%esp),%edx
f0102fbc:	c3                   	ret    

f0102fbd <__x86.get_pc_thunk.cx>:
f0102fbd:	8b 0c 24             	mov    (%esp),%ecx
f0102fc0:	c3                   	ret    

f0102fc1 <__x86.get_pc_thunk.di>:
f0102fc1:	8b 3c 24             	mov    (%esp),%edi
f0102fc4:	c3                   	ret    

f0102fc5 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102fc5:	55                   	push   %ebp
f0102fc6:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fcb:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fd0:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102fd1:	ba 71 00 00 00       	mov    $0x71,%edx
f0102fd6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102fd7:	0f b6 c0             	movzbl %al,%eax
}
f0102fda:	5d                   	pop    %ebp
f0102fdb:	c3                   	ret    

f0102fdc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102fdc:	55                   	push   %ebp
f0102fdd:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fe2:	ba 70 00 00 00       	mov    $0x70,%edx
f0102fe7:	ee                   	out    %al,(%dx)
f0102fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102feb:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ff0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102ff1:	5d                   	pop    %ebp
f0102ff2:	c3                   	ret    

f0102ff3 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102ff3:	55                   	push   %ebp
f0102ff4:	89 e5                	mov    %esp,%ebp
f0102ff6:	53                   	push   %ebx
f0102ff7:	83 ec 10             	sub    $0x10,%esp
f0102ffa:	e8 50 d1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0102fff:	81 c3 0d 43 01 00    	add    $0x1430d,%ebx
	cputchar(ch);
f0103005:	ff 75 08             	push   0x8(%ebp)
f0103008:	e8 ad d6 ff ff       	call   f01006ba <cputchar>
	*cnt++;
}
f010300d:	83 c4 10             	add    $0x10,%esp
f0103010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103013:	c9                   	leave  
f0103014:	c3                   	ret    

f0103015 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103015:	55                   	push   %ebp
f0103016:	89 e5                	mov    %esp,%ebp
f0103018:	53                   	push   %ebx
f0103019:	83 ec 14             	sub    $0x14,%esp
f010301c:	e8 2e d1 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103021:	81 c3 eb 42 01 00    	add    $0x142eb,%ebx
	int cnt = 0;
f0103027:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010302e:	ff 75 0c             	push   0xc(%ebp)
f0103031:	ff 75 08             	push   0x8(%ebp)
f0103034:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103037:	50                   	push   %eax
f0103038:	8d 83 e7 bc fe ff    	lea    -0x14319(%ebx),%eax
f010303e:	50                   	push   %eax
f010303f:	e8 44 04 00 00       	call   f0103488 <vprintfmt>
	return cnt;
}
f0103044:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103047:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010304a:	c9                   	leave  
f010304b:	c3                   	ret    

f010304c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010304c:	55                   	push   %ebp
f010304d:	89 e5                	mov    %esp,%ebp
f010304f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103052:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103055:	50                   	push   %eax
f0103056:	ff 75 08             	push   0x8(%ebp)
f0103059:	e8 b7 ff ff ff       	call   f0103015 <vcprintf>
	va_end(ap);

	return cnt;
}
f010305e:	c9                   	leave  
f010305f:	c3                   	ret    

f0103060 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103060:	55                   	push   %ebp
f0103061:	89 e5                	mov    %esp,%ebp
f0103063:	57                   	push   %edi
f0103064:	56                   	push   %esi
f0103065:	53                   	push   %ebx
f0103066:	83 ec 14             	sub    $0x14,%esp
f0103069:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010306c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010306f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103072:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103075:	8b 1a                	mov    (%edx),%ebx
f0103077:	8b 01                	mov    (%ecx),%eax
f0103079:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010307c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103083:	eb 2f                	jmp    f01030b4 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103085:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103088:	39 c3                	cmp    %eax,%ebx
f010308a:	7f 4e                	jg     f01030da <stab_binsearch+0x7a>
f010308c:	0f b6 0a             	movzbl (%edx),%ecx
f010308f:	83 ea 0c             	sub    $0xc,%edx
f0103092:	39 f1                	cmp    %esi,%ecx
f0103094:	75 ef                	jne    f0103085 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103096:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103099:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010309c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01030a0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01030a3:	73 3a                	jae    f01030df <stab_binsearch+0x7f>
			*region_left = m;
f01030a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01030a8:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01030aa:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01030ad:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01030b4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01030b7:	7f 53                	jg     f010310c <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01030b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01030bc:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01030bf:	89 d0                	mov    %edx,%eax
f01030c1:	c1 e8 1f             	shr    $0x1f,%eax
f01030c4:	01 d0                	add    %edx,%eax
f01030c6:	89 c7                	mov    %eax,%edi
f01030c8:	d1 ff                	sar    %edi
f01030ca:	83 e0 fe             	and    $0xfffffffe,%eax
f01030cd:	01 f8                	add    %edi,%eax
f01030cf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01030d2:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01030d6:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f01030d8:	eb ae                	jmp    f0103088 <stab_binsearch+0x28>
			l = true_m + 1;
f01030da:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01030dd:	eb d5                	jmp    f01030b4 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01030df:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01030e2:	76 14                	jbe    f01030f8 <stab_binsearch+0x98>
			*region_right = m - 1;
f01030e4:	83 e8 01             	sub    $0x1,%eax
f01030e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01030ea:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01030ed:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f01030ef:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01030f6:	eb bc                	jmp    f01030b4 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01030f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01030fb:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f01030fd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103101:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103103:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010310a:	eb a8                	jmp    f01030b4 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010310c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103110:	75 15                	jne    f0103127 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103115:	8b 00                	mov    (%eax),%eax
f0103117:	83 e8 01             	sub    $0x1,%eax
f010311a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010311d:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010311f:	83 c4 14             	add    $0x14,%esp
f0103122:	5b                   	pop    %ebx
f0103123:	5e                   	pop    %esi
f0103124:	5f                   	pop    %edi
f0103125:	5d                   	pop    %ebp
f0103126:	c3                   	ret    
		for (l = *region_right;
f0103127:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010312a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010312c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010312f:	8b 0f                	mov    (%edi),%ecx
f0103131:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103134:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103137:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010313b:	39 c1                	cmp    %eax,%ecx
f010313d:	7d 0f                	jge    f010314e <stab_binsearch+0xee>
f010313f:	0f b6 1a             	movzbl (%edx),%ebx
f0103142:	83 ea 0c             	sub    $0xc,%edx
f0103145:	39 f3                	cmp    %esi,%ebx
f0103147:	74 05                	je     f010314e <stab_binsearch+0xee>
		     l--)
f0103149:	83 e8 01             	sub    $0x1,%eax
f010314c:	eb ed                	jmp    f010313b <stab_binsearch+0xdb>
		*region_left = l;
f010314e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103151:	89 07                	mov    %eax,(%edi)
}
f0103153:	eb ca                	jmp    f010311f <stab_binsearch+0xbf>

f0103155 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103155:	55                   	push   %ebp
f0103156:	89 e5                	mov    %esp,%ebp
f0103158:	57                   	push   %edi
f0103159:	56                   	push   %esi
f010315a:	53                   	push   %ebx
f010315b:	83 ec 2c             	sub    $0x2c,%esp
f010315e:	e8 ec cf ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103163:	81 c3 a9 41 01 00    	add    $0x141a9,%ebx
f0103169:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010316c:	8d 83 04 dd fe ff    	lea    -0x122fc(%ebx),%eax
f0103172:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103174:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010317b:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f010317e:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103185:	8b 45 08             	mov    0x8(%ebp),%eax
f0103188:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f010318b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103192:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103197:	0f 86 03 01 00 00    	jbe    f01032a0 <debuginfo_eip+0x14b>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010319d:	c7 c0 e5 b6 10 f0    	mov    $0xf010b6e5,%eax
f01031a3:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f01031a9:	0f 86 b8 01 00 00    	jbe    f0103367 <debuginfo_eip+0x212>
f01031af:	c7 c0 ff d3 10 f0    	mov    $0xf010d3ff,%eax
f01031b5:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01031b9:	0f 85 af 01 00 00    	jne    f010336e <debuginfo_eip+0x219>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01031bf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01031c6:	c7 c0 28 52 10 f0    	mov    $0xf0105228,%eax
f01031cc:	c7 c2 e4 b6 10 f0    	mov    $0xf010b6e4,%edx
f01031d2:	29 c2                	sub    %eax,%edx
f01031d4:	c1 fa 02             	sar    $0x2,%edx
f01031d7:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01031dd:	83 ea 01             	sub    $0x1,%edx
f01031e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01031e3:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01031e6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01031e9:	83 ec 08             	sub    $0x8,%esp
f01031ec:	ff 75 08             	push   0x8(%ebp)
f01031ef:	6a 64                	push   $0x64
f01031f1:	e8 6a fe ff ff       	call   f0103060 <stab_binsearch>
	if (lfile == 0)
f01031f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031f9:	83 c4 10             	add    $0x10,%esp
f01031fc:	85 ff                	test   %edi,%edi
f01031fe:	0f 84 71 01 00 00    	je     f0103375 <debuginfo_eip+0x220>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103204:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0103207:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010320a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010320d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103210:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103213:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103216:	83 ec 08             	sub    $0x8,%esp
f0103219:	ff 75 08             	push   0x8(%ebp)
f010321c:	6a 24                	push   $0x24
f010321e:	c7 c0 28 52 10 f0    	mov    $0xf0105228,%eax
f0103224:	e8 37 fe ff ff       	call   f0103060 <stab_binsearch>

	if (lfun <= rfun) {
f0103229:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010322c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010322f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103232:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0103235:	83 c4 10             	add    $0x10,%esp
f0103238:	39 c8                	cmp    %ecx,%eax
f010323a:	7f 7c                	jg     f01032b8 <debuginfo_eip+0x163>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010323c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010323f:	c7 c2 28 52 10 f0    	mov    $0xf0105228,%edx
f0103245:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0103248:	8b 11                	mov    (%ecx),%edx
f010324a:	c7 c0 ff d3 10 f0    	mov    $0xf010d3ff,%eax
f0103250:	81 e8 e5 b6 10 f0    	sub    $0xf010b6e5,%eax
f0103256:	39 c2                	cmp    %eax,%edx
f0103258:	73 09                	jae    f0103263 <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010325a:	81 c2 e5 b6 10 f0    	add    $0xf010b6e5,%edx
f0103260:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103263:	8b 41 08             	mov    0x8(%ecx),%eax
f0103266:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103269:	83 ec 08             	sub    $0x8,%esp
f010326c:	6a 3a                	push   $0x3a
f010326e:	ff 76 08             	push   0x8(%esi)
f0103271:	e8 a3 09 00 00       	call   f0103c19 <strfind>
f0103276:	2b 46 08             	sub    0x8(%esi),%eax
f0103279:	89 46 0c             	mov    %eax,0xc(%esi)
f010327c:	83 c4 10             	add    $0x10,%esp
		rline = rfun;
f010327f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103282:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline = lfun;
f0103285:	8b 55 cc             	mov    -0x34(%ebp),%edx
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	if (lline <=rline) {
	info ->eip_line = rline;}
f0103288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010328b:	89 46 04             	mov    %eax,0x4(%esi)
f010328e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0103291:	c7 c1 28 52 10 f0    	mov    $0xf0105228,%ecx
f0103297:	8d 44 81 04          	lea    0x4(%ecx,%eax,4),%eax
f010329b:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010329e:	eb 45                	jmp    f01032e5 <debuginfo_eip+0x190>
  	        panic("User address");
f01032a0:	83 ec 04             	sub    $0x4,%esp
f01032a3:	8d 83 0e dd fe ff    	lea    -0x122f2(%ebx),%eax
f01032a9:	50                   	push   %eax
f01032aa:	6a 7f                	push   $0x7f
f01032ac:	8d 83 1b dd fe ff    	lea    -0x122e5(%ebx),%eax
f01032b2:	50                   	push   %eax
f01032b3:	e8 e1 cd ff ff       	call   f0100099 <_panic>
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01032b8:	83 ec 08             	sub    $0x8,%esp
f01032bb:	6a 3a                	push   $0x3a
f01032bd:	8d 83 04 dd fe ff    	lea    -0x122fc(%ebx),%eax
f01032c3:	50                   	push   %eax
f01032c4:	e8 50 09 00 00       	call   f0103c19 <strfind>
f01032c9:	2b 46 08             	sub    0x8(%esi),%eax
f01032cc:	89 46 0c             	mov    %eax,0xc(%esi)
	if (lline <=rline) {
f01032cf:	83 c4 10             	add    $0x10,%esp
f01032d2:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01032d5:	0f 8f a1 00 00 00    	jg     f010337c <debuginfo_eip+0x227>
		lline = lfile;
f01032db:	89 fa                	mov    %edi,%edx
f01032dd:	eb a9                	jmp    f0103288 <debuginfo_eip+0x133>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01032df:	83 ea 01             	sub    $0x1,%edx
f01032e2:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01032e5:	39 d7                	cmp    %edx,%edi
f01032e7:	7f 3c                	jg     f0103325 <debuginfo_eip+0x1d0>
	       && stabs[lline].n_type != N_SOL
f01032e9:	0f b6 08             	movzbl (%eax),%ecx
f01032ec:	80 f9 84             	cmp    $0x84,%cl
f01032ef:	74 0b                	je     f01032fc <debuginfo_eip+0x1a7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01032f1:	80 f9 64             	cmp    $0x64,%cl
f01032f4:	75 e9                	jne    f01032df <debuginfo_eip+0x18a>
f01032f6:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f01032fa:	74 e3                	je     f01032df <debuginfo_eip+0x18a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01032fc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01032ff:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103302:	c7 c0 28 52 10 f0    	mov    $0xf0105228,%eax
f0103308:	8b 14 90             	mov    (%eax,%edx,4),%edx
f010330b:	c7 c0 ff d3 10 f0    	mov    $0xf010d3ff,%eax
f0103311:	81 e8 e5 b6 10 f0    	sub    $0xf010b6e5,%eax
f0103317:	39 c2                	cmp    %eax,%edx
f0103319:	73 0d                	jae    f0103328 <debuginfo_eip+0x1d3>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010331b:	81 c2 e5 b6 10 f0    	add    $0xf010b6e5,%edx
f0103321:	89 16                	mov    %edx,(%esi)
f0103323:	eb 03                	jmp    f0103328 <debuginfo_eip+0x1d3>
f0103325:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103328:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f010332d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103330:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103333:	39 cf                	cmp    %ecx,%edi
f0103335:	7d 51                	jge    f0103388 <debuginfo_eip+0x233>
		for (lline = lfun + 1;
f0103337:	8d 57 01             	lea    0x1(%edi),%edx
f010333a:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f010333d:	c7 c0 28 52 10 f0    	mov    $0xf0105228,%eax
f0103343:	8d 44 88 10          	lea    0x10(%eax,%ecx,4),%eax
f0103347:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010334a:	eb 07                	jmp    f0103353 <debuginfo_eip+0x1fe>
			info->eip_fn_narg++;
f010334c:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline++)
f0103350:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103353:	39 d1                	cmp    %edx,%ecx
f0103355:	74 2c                	je     f0103383 <debuginfo_eip+0x22e>
f0103357:	83 c0 0c             	add    $0xc,%eax
f010335a:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f010335e:	74 ec                	je     f010334c <debuginfo_eip+0x1f7>
	return 0;
f0103360:	b8 00 00 00 00       	mov    $0x0,%eax
f0103365:	eb 21                	jmp    f0103388 <debuginfo_eip+0x233>
		return -1;
f0103367:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010336c:	eb 1a                	jmp    f0103388 <debuginfo_eip+0x233>
f010336e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103373:	eb 13                	jmp    f0103388 <debuginfo_eip+0x233>
		return -1;
f0103375:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010337a:	eb 0c                	jmp    f0103388 <debuginfo_eip+0x233>
	return -1;
f010337c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103381:	eb 05                	jmp    f0103388 <debuginfo_eip+0x233>
	return 0;
f0103383:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103388:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010338b:	5b                   	pop    %ebx
f010338c:	5e                   	pop    %esi
f010338d:	5f                   	pop    %edi
f010338e:	5d                   	pop    %ebp
f010338f:	c3                   	ret    

f0103390 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103390:	55                   	push   %ebp
f0103391:	89 e5                	mov    %esp,%ebp
f0103393:	57                   	push   %edi
f0103394:	56                   	push   %esi
f0103395:	53                   	push   %ebx
f0103396:	83 ec 2c             	sub    $0x2c,%esp
f0103399:	e8 1f fc ff ff       	call   f0102fbd <__x86.get_pc_thunk.cx>
f010339e:	81 c1 6e 3f 01 00    	add    $0x13f6e,%ecx
f01033a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01033a7:	89 c7                	mov    %eax,%edi
f01033a9:	89 d6                	mov    %edx,%esi
f01033ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01033ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033b1:	89 d1                	mov    %edx,%ecx
f01033b3:	89 c2                	mov    %eax,%edx
f01033b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033b8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01033bb:	8b 45 10             	mov    0x10(%ebp),%eax
f01033be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01033c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01033c4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01033cb:	39 c2                	cmp    %eax,%edx
f01033cd:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01033d0:	72 41                	jb     f0103413 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01033d2:	83 ec 0c             	sub    $0xc,%esp
f01033d5:	ff 75 18             	push   0x18(%ebp)
f01033d8:	83 eb 01             	sub    $0x1,%ebx
f01033db:	53                   	push   %ebx
f01033dc:	50                   	push   %eax
f01033dd:	83 ec 08             	sub    $0x8,%esp
f01033e0:	ff 75 e4             	push   -0x1c(%ebp)
f01033e3:	ff 75 e0             	push   -0x20(%ebp)
f01033e6:	ff 75 d4             	push   -0x2c(%ebp)
f01033e9:	ff 75 d0             	push   -0x30(%ebp)
f01033ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01033ef:	e8 3c 0a 00 00       	call   f0103e30 <__udivdi3>
f01033f4:	83 c4 18             	add    $0x18,%esp
f01033f7:	52                   	push   %edx
f01033f8:	50                   	push   %eax
f01033f9:	89 f2                	mov    %esi,%edx
f01033fb:	89 f8                	mov    %edi,%eax
f01033fd:	e8 8e ff ff ff       	call   f0103390 <printnum>
f0103402:	83 c4 20             	add    $0x20,%esp
f0103405:	eb 13                	jmp    f010341a <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103407:	83 ec 08             	sub    $0x8,%esp
f010340a:	56                   	push   %esi
f010340b:	ff 75 18             	push   0x18(%ebp)
f010340e:	ff d7                	call   *%edi
f0103410:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103413:	83 eb 01             	sub    $0x1,%ebx
f0103416:	85 db                	test   %ebx,%ebx
f0103418:	7f ed                	jg     f0103407 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010341a:	83 ec 08             	sub    $0x8,%esp
f010341d:	56                   	push   %esi
f010341e:	83 ec 04             	sub    $0x4,%esp
f0103421:	ff 75 e4             	push   -0x1c(%ebp)
f0103424:	ff 75 e0             	push   -0x20(%ebp)
f0103427:	ff 75 d4             	push   -0x2c(%ebp)
f010342a:	ff 75 d0             	push   -0x30(%ebp)
f010342d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103430:	e8 1b 0b 00 00       	call   f0103f50 <__umoddi3>
f0103435:	83 c4 14             	add    $0x14,%esp
f0103438:	0f be 84 03 29 dd fe 	movsbl -0x122d7(%ebx,%eax,1),%eax
f010343f:	ff 
f0103440:	50                   	push   %eax
f0103441:	ff d7                	call   *%edi
}
f0103443:	83 c4 10             	add    $0x10,%esp
f0103446:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103449:	5b                   	pop    %ebx
f010344a:	5e                   	pop    %esi
f010344b:	5f                   	pop    %edi
f010344c:	5d                   	pop    %ebp
f010344d:	c3                   	ret    

f010344e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010344e:	55                   	push   %ebp
f010344f:	89 e5                	mov    %esp,%ebp
f0103451:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103454:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103458:	8b 10                	mov    (%eax),%edx
f010345a:	3b 50 04             	cmp    0x4(%eax),%edx
f010345d:	73 0a                	jae    f0103469 <sprintputch+0x1b>
		*b->buf++ = ch;
f010345f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103462:	89 08                	mov    %ecx,(%eax)
f0103464:	8b 45 08             	mov    0x8(%ebp),%eax
f0103467:	88 02                	mov    %al,(%edx)
}
f0103469:	5d                   	pop    %ebp
f010346a:	c3                   	ret    

f010346b <printfmt>:
{
f010346b:	55                   	push   %ebp
f010346c:	89 e5                	mov    %esp,%ebp
f010346e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103471:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103474:	50                   	push   %eax
f0103475:	ff 75 10             	push   0x10(%ebp)
f0103478:	ff 75 0c             	push   0xc(%ebp)
f010347b:	ff 75 08             	push   0x8(%ebp)
f010347e:	e8 05 00 00 00       	call   f0103488 <vprintfmt>
}
f0103483:	83 c4 10             	add    $0x10,%esp
f0103486:	c9                   	leave  
f0103487:	c3                   	ret    

f0103488 <vprintfmt>:
{
f0103488:	55                   	push   %ebp
f0103489:	89 e5                	mov    %esp,%ebp
f010348b:	57                   	push   %edi
f010348c:	56                   	push   %esi
f010348d:	53                   	push   %ebx
f010348e:	83 ec 3c             	sub    $0x3c,%esp
f0103491:	e8 4b d2 ff ff       	call   f01006e1 <__x86.get_pc_thunk.ax>
f0103496:	05 76 3e 01 00       	add    $0x13e76,%eax
f010349b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010349e:	8b 75 08             	mov    0x8(%ebp),%esi
f01034a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01034a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01034a7:	8d 80 38 1d 00 00    	lea    0x1d38(%eax),%eax
f01034ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01034b0:	eb 0a                	jmp    f01034bc <vprintfmt+0x34>
			putch(ch, putdat);
f01034b2:	83 ec 08             	sub    $0x8,%esp
f01034b5:	57                   	push   %edi
f01034b6:	50                   	push   %eax
f01034b7:	ff d6                	call   *%esi
f01034b9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034bc:	83 c3 01             	add    $0x1,%ebx
f01034bf:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01034c3:	83 f8 25             	cmp    $0x25,%eax
f01034c6:	74 0c                	je     f01034d4 <vprintfmt+0x4c>
			if (ch == '\0')
f01034c8:	85 c0                	test   %eax,%eax
f01034ca:	75 e6                	jne    f01034b2 <vprintfmt+0x2a>
}
f01034cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034cf:	5b                   	pop    %ebx
f01034d0:	5e                   	pop    %esi
f01034d1:	5f                   	pop    %edi
f01034d2:	5d                   	pop    %ebp
f01034d3:	c3                   	ret    
		padc = ' ';
f01034d4:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01034d8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f01034df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01034e6:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f01034ed:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034f2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01034f5:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01034f8:	8d 43 01             	lea    0x1(%ebx),%eax
f01034fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01034fe:	0f b6 13             	movzbl (%ebx),%edx
f0103501:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103504:	3c 55                	cmp    $0x55,%al
f0103506:	0f 87 fd 03 00 00    	ja     f0103909 <.L20>
f010350c:	0f b6 c0             	movzbl %al,%eax
f010350f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103512:	89 ce                	mov    %ecx,%esi
f0103514:	03 b4 81 b4 dd fe ff 	add    -0x1224c(%ecx,%eax,4),%esi
f010351b:	ff e6                	jmp    *%esi

f010351d <.L68>:
f010351d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0103520:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0103524:	eb d2                	jmp    f01034f8 <vprintfmt+0x70>

f0103526 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0103526:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103529:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f010352d:	eb c9                	jmp    f01034f8 <vprintfmt+0x70>

f010352f <.L31>:
f010352f:	0f b6 d2             	movzbl %dl,%edx
f0103532:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0103535:	b8 00 00 00 00       	mov    $0x0,%eax
f010353a:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f010353d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103540:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103544:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0103547:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010354a:	83 f9 09             	cmp    $0x9,%ecx
f010354d:	77 58                	ja     f01035a7 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f010354f:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0103552:	eb e9                	jmp    f010353d <.L31+0xe>

f0103554 <.L34>:
			precision = va_arg(ap, int);
f0103554:	8b 45 14             	mov    0x14(%ebp),%eax
f0103557:	8b 00                	mov    (%eax),%eax
f0103559:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010355c:	8b 45 14             	mov    0x14(%ebp),%eax
f010355f:	8d 40 04             	lea    0x4(%eax),%eax
f0103562:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103565:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0103568:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010356c:	79 8a                	jns    f01034f8 <vprintfmt+0x70>
				width = precision, precision = -1;
f010356e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103571:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103574:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010357b:	e9 78 ff ff ff       	jmp    f01034f8 <vprintfmt+0x70>

f0103580 <.L33>:
f0103580:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103583:	85 d2                	test   %edx,%edx
f0103585:	b8 00 00 00 00       	mov    $0x0,%eax
f010358a:	0f 49 c2             	cmovns %edx,%eax
f010358d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103590:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103593:	e9 60 ff ff ff       	jmp    f01034f8 <vprintfmt+0x70>

f0103598 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0103598:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010359b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01035a2:	e9 51 ff ff ff       	jmp    f01034f8 <vprintfmt+0x70>
f01035a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01035aa:	89 75 08             	mov    %esi,0x8(%ebp)
f01035ad:	eb b9                	jmp    f0103568 <.L34+0x14>

f01035af <.L27>:
			lflag++;
f01035af:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01035b6:	e9 3d ff ff ff       	jmp    f01034f8 <vprintfmt+0x70>

f01035bb <.L30>:
			putch(va_arg(ap, int), putdat);
f01035bb:	8b 75 08             	mov    0x8(%ebp),%esi
f01035be:	8b 45 14             	mov    0x14(%ebp),%eax
f01035c1:	8d 58 04             	lea    0x4(%eax),%ebx
f01035c4:	83 ec 08             	sub    $0x8,%esp
f01035c7:	57                   	push   %edi
f01035c8:	ff 30                	push   (%eax)
f01035ca:	ff d6                	call   *%esi
			break;
f01035cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01035cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01035d2:	e9 c8 02 00 00       	jmp    f010389f <.L25+0x45>

f01035d7 <.L28>:
			err = va_arg(ap, int);
f01035d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01035da:	8b 45 14             	mov    0x14(%ebp),%eax
f01035dd:	8d 58 04             	lea    0x4(%eax),%ebx
f01035e0:	8b 10                	mov    (%eax),%edx
f01035e2:	89 d0                	mov    %edx,%eax
f01035e4:	f7 d8                	neg    %eax
f01035e6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01035e9:	83 f8 06             	cmp    $0x6,%eax
f01035ec:	7f 27                	jg     f0103615 <.L28+0x3e>
f01035ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01035f1:	8b 14 82             	mov    (%edx,%eax,4),%edx
f01035f4:	85 d2                	test   %edx,%edx
f01035f6:	74 1d                	je     f0103615 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f01035f8:	52                   	push   %edx
f01035f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035fc:	8d 80 59 da fe ff    	lea    -0x125a7(%eax),%eax
f0103602:	50                   	push   %eax
f0103603:	57                   	push   %edi
f0103604:	56                   	push   %esi
f0103605:	e8 61 fe ff ff       	call   f010346b <printfmt>
f010360a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010360d:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103610:	e9 8a 02 00 00       	jmp    f010389f <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0103615:	50                   	push   %eax
f0103616:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103619:	8d 80 41 dd fe ff    	lea    -0x122bf(%eax),%eax
f010361f:	50                   	push   %eax
f0103620:	57                   	push   %edi
f0103621:	56                   	push   %esi
f0103622:	e8 44 fe ff ff       	call   f010346b <printfmt>
f0103627:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010362a:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010362d:	e9 6d 02 00 00       	jmp    f010389f <.L25+0x45>

f0103632 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103632:	8b 75 08             	mov    0x8(%ebp),%esi
f0103635:	8b 45 14             	mov    0x14(%ebp),%eax
f0103638:	83 c0 04             	add    $0x4,%eax
f010363b:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010363e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103641:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0103643:	85 d2                	test   %edx,%edx
f0103645:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103648:	8d 80 3a dd fe ff    	lea    -0x122c6(%eax),%eax
f010364e:	0f 45 c2             	cmovne %edx,%eax
f0103651:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0103654:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103658:	7e 06                	jle    f0103660 <.L24+0x2e>
f010365a:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f010365e:	75 0d                	jne    f010366d <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103660:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103663:	89 c3                	mov    %eax,%ebx
f0103665:	03 45 d4             	add    -0x2c(%ebp),%eax
f0103668:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010366b:	eb 58                	jmp    f01036c5 <.L24+0x93>
f010366d:	83 ec 08             	sub    $0x8,%esp
f0103670:	ff 75 d8             	push   -0x28(%ebp)
f0103673:	ff 75 c8             	push   -0x38(%ebp)
f0103676:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103679:	e8 44 04 00 00       	call   f0103ac2 <strnlen>
f010367e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103681:	29 c2                	sub    %eax,%edx
f0103683:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0103686:	83 c4 10             	add    $0x10,%esp
f0103689:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010368b:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010368f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103692:	eb 0f                	jmp    f01036a3 <.L24+0x71>
					putch(padc, putdat);
f0103694:	83 ec 08             	sub    $0x8,%esp
f0103697:	57                   	push   %edi
f0103698:	ff 75 d4             	push   -0x2c(%ebp)
f010369b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010369d:	83 eb 01             	sub    $0x1,%ebx
f01036a0:	83 c4 10             	add    $0x10,%esp
f01036a3:	85 db                	test   %ebx,%ebx
f01036a5:	7f ed                	jg     f0103694 <.L24+0x62>
f01036a7:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01036aa:	85 d2                	test   %edx,%edx
f01036ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01036b1:	0f 49 c2             	cmovns %edx,%eax
f01036b4:	29 c2                	sub    %eax,%edx
f01036b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01036b9:	eb a5                	jmp    f0103660 <.L24+0x2e>
					putch(ch, putdat);
f01036bb:	83 ec 08             	sub    $0x8,%esp
f01036be:	57                   	push   %edi
f01036bf:	52                   	push   %edx
f01036c0:	ff d6                	call   *%esi
f01036c2:	83 c4 10             	add    $0x10,%esp
f01036c5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01036c8:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01036ca:	83 c3 01             	add    $0x1,%ebx
f01036cd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01036d1:	0f be d0             	movsbl %al,%edx
f01036d4:	85 d2                	test   %edx,%edx
f01036d6:	74 4b                	je     f0103723 <.L24+0xf1>
f01036d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01036dc:	78 06                	js     f01036e4 <.L24+0xb2>
f01036de:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01036e2:	78 1e                	js     f0103702 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01036e4:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01036e8:	74 d1                	je     f01036bb <.L24+0x89>
f01036ea:	0f be c0             	movsbl %al,%eax
f01036ed:	83 e8 20             	sub    $0x20,%eax
f01036f0:	83 f8 5e             	cmp    $0x5e,%eax
f01036f3:	76 c6                	jbe    f01036bb <.L24+0x89>
					putch('?', putdat);
f01036f5:	83 ec 08             	sub    $0x8,%esp
f01036f8:	57                   	push   %edi
f01036f9:	6a 3f                	push   $0x3f
f01036fb:	ff d6                	call   *%esi
f01036fd:	83 c4 10             	add    $0x10,%esp
f0103700:	eb c3                	jmp    f01036c5 <.L24+0x93>
f0103702:	89 cb                	mov    %ecx,%ebx
f0103704:	eb 0e                	jmp    f0103714 <.L24+0xe2>
				putch(' ', putdat);
f0103706:	83 ec 08             	sub    $0x8,%esp
f0103709:	57                   	push   %edi
f010370a:	6a 20                	push   $0x20
f010370c:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010370e:	83 eb 01             	sub    $0x1,%ebx
f0103711:	83 c4 10             	add    $0x10,%esp
f0103714:	85 db                	test   %ebx,%ebx
f0103716:	7f ee                	jg     f0103706 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0103718:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010371b:	89 45 14             	mov    %eax,0x14(%ebp)
f010371e:	e9 7c 01 00 00       	jmp    f010389f <.L25+0x45>
f0103723:	89 cb                	mov    %ecx,%ebx
f0103725:	eb ed                	jmp    f0103714 <.L24+0xe2>

f0103727 <.L29>:
	if (lflag >= 2)
f0103727:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010372a:	8b 75 08             	mov    0x8(%ebp),%esi
f010372d:	83 f9 01             	cmp    $0x1,%ecx
f0103730:	7f 1b                	jg     f010374d <.L29+0x26>
	else if (lflag)
f0103732:	85 c9                	test   %ecx,%ecx
f0103734:	74 63                	je     f0103799 <.L29+0x72>
		return va_arg(*ap, long);
f0103736:	8b 45 14             	mov    0x14(%ebp),%eax
f0103739:	8b 00                	mov    (%eax),%eax
f010373b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010373e:	99                   	cltd   
f010373f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103742:	8b 45 14             	mov    0x14(%ebp),%eax
f0103745:	8d 40 04             	lea    0x4(%eax),%eax
f0103748:	89 45 14             	mov    %eax,0x14(%ebp)
f010374b:	eb 17                	jmp    f0103764 <.L29+0x3d>
		return va_arg(*ap, long long);
f010374d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103750:	8b 50 04             	mov    0x4(%eax),%edx
f0103753:	8b 00                	mov    (%eax),%eax
f0103755:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103758:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010375b:	8b 45 14             	mov    0x14(%ebp),%eax
f010375e:	8d 40 08             	lea    0x8(%eax),%eax
f0103761:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103764:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103767:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f010376a:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f010376f:	85 db                	test   %ebx,%ebx
f0103771:	0f 89 0e 01 00 00    	jns    f0103885 <.L25+0x2b>
				putch('-', putdat);
f0103777:	83 ec 08             	sub    $0x8,%esp
f010377a:	57                   	push   %edi
f010377b:	6a 2d                	push   $0x2d
f010377d:	ff d6                	call   *%esi
				num = -(long long) num;
f010377f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103782:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103785:	f7 d9                	neg    %ecx
f0103787:	83 d3 00             	adc    $0x0,%ebx
f010378a:	f7 db                	neg    %ebx
f010378c:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010378f:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103794:	e9 ec 00 00 00       	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, int);
f0103799:	8b 45 14             	mov    0x14(%ebp),%eax
f010379c:	8b 00                	mov    (%eax),%eax
f010379e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037a1:	99                   	cltd   
f01037a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a8:	8d 40 04             	lea    0x4(%eax),%eax
f01037ab:	89 45 14             	mov    %eax,0x14(%ebp)
f01037ae:	eb b4                	jmp    f0103764 <.L29+0x3d>

f01037b0 <.L23>:
	if (lflag >= 2)
f01037b0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01037b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01037b6:	83 f9 01             	cmp    $0x1,%ecx
f01037b9:	7f 1e                	jg     f01037d9 <.L23+0x29>
	else if (lflag)
f01037bb:	85 c9                	test   %ecx,%ecx
f01037bd:	74 32                	je     f01037f1 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f01037bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01037c2:	8b 08                	mov    (%eax),%ecx
f01037c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01037c9:	8d 40 04             	lea    0x4(%eax),%eax
f01037cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01037cf:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f01037d4:	e9 ac 00 00 00       	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01037d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01037dc:	8b 08                	mov    (%eax),%ecx
f01037de:	8b 58 04             	mov    0x4(%eax),%ebx
f01037e1:	8d 40 08             	lea    0x8(%eax),%eax
f01037e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01037e7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f01037ec:	e9 94 00 00 00       	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01037f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01037f4:	8b 08                	mov    (%eax),%ecx
f01037f6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01037fb:	8d 40 04             	lea    0x4(%eax),%eax
f01037fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103801:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0103806:	eb 7d                	jmp    f0103885 <.L25+0x2b>

f0103808 <.L26>:
	if (lflag >= 2)
f0103808:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010380b:	8b 75 08             	mov    0x8(%ebp),%esi
f010380e:	83 f9 01             	cmp    $0x1,%ecx
f0103811:	7f 1b                	jg     f010382e <.L26+0x26>
	else if (lflag)
f0103813:	85 c9                	test   %ecx,%ecx
f0103815:	74 2c                	je     f0103843 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0103817:	8b 45 14             	mov    0x14(%ebp),%eax
f010381a:	8b 08                	mov    (%eax),%ecx
f010381c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103821:	8d 40 04             	lea    0x4(%eax),%eax
f0103824:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103827:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f010382c:	eb 57                	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010382e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103831:	8b 08                	mov    (%eax),%ecx
f0103833:	8b 58 04             	mov    0x4(%eax),%ebx
f0103836:	8d 40 08             	lea    0x8(%eax),%eax
f0103839:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010383c:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0103841:	eb 42                	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103843:	8b 45 14             	mov    0x14(%ebp),%eax
f0103846:	8b 08                	mov    (%eax),%ecx
f0103848:	bb 00 00 00 00       	mov    $0x0,%ebx
f010384d:	8d 40 04             	lea    0x4(%eax),%eax
f0103850:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103853:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f0103858:	eb 2b                	jmp    f0103885 <.L25+0x2b>

f010385a <.L25>:
			putch('0', putdat);
f010385a:	8b 75 08             	mov    0x8(%ebp),%esi
f010385d:	83 ec 08             	sub    $0x8,%esp
f0103860:	57                   	push   %edi
f0103861:	6a 30                	push   $0x30
f0103863:	ff d6                	call   *%esi
			putch('x', putdat);
f0103865:	83 c4 08             	add    $0x8,%esp
f0103868:	57                   	push   %edi
f0103869:	6a 78                	push   $0x78
f010386b:	ff d6                	call   *%esi
			num = (unsigned long long)
f010386d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103870:	8b 08                	mov    (%eax),%ecx
f0103872:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0103877:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010387a:	8d 40 04             	lea    0x4(%eax),%eax
f010387d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103880:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0103885:	83 ec 0c             	sub    $0xc,%esp
f0103888:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010388c:	50                   	push   %eax
f010388d:	ff 75 d4             	push   -0x2c(%ebp)
f0103890:	52                   	push   %edx
f0103891:	53                   	push   %ebx
f0103892:	51                   	push   %ecx
f0103893:	89 fa                	mov    %edi,%edx
f0103895:	89 f0                	mov    %esi,%eax
f0103897:	e8 f4 fa ff ff       	call   f0103390 <printnum>
			break;
f010389c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010389f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01038a2:	e9 15 fc ff ff       	jmp    f01034bc <vprintfmt+0x34>

f01038a7 <.L21>:
	if (lflag >= 2)
f01038a7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01038aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01038ad:	83 f9 01             	cmp    $0x1,%ecx
f01038b0:	7f 1b                	jg     f01038cd <.L21+0x26>
	else if (lflag)
f01038b2:	85 c9                	test   %ecx,%ecx
f01038b4:	74 2c                	je     f01038e2 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01038b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01038b9:	8b 08                	mov    (%eax),%ecx
f01038bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038c0:	8d 40 04             	lea    0x4(%eax),%eax
f01038c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038c6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f01038cb:	eb b8                	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01038cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01038d0:	8b 08                	mov    (%eax),%ecx
f01038d2:	8b 58 04             	mov    0x4(%eax),%ebx
f01038d5:	8d 40 08             	lea    0x8(%eax),%eax
f01038d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038db:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f01038e0:	eb a3                	jmp    f0103885 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01038e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01038e5:	8b 08                	mov    (%eax),%ecx
f01038e7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038ec:	8d 40 04             	lea    0x4(%eax),%eax
f01038ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038f2:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f01038f7:	eb 8c                	jmp    f0103885 <.L25+0x2b>

f01038f9 <.L35>:
			putch(ch, putdat);
f01038f9:	8b 75 08             	mov    0x8(%ebp),%esi
f01038fc:	83 ec 08             	sub    $0x8,%esp
f01038ff:	57                   	push   %edi
f0103900:	6a 25                	push   $0x25
f0103902:	ff d6                	call   *%esi
			break;
f0103904:	83 c4 10             	add    $0x10,%esp
f0103907:	eb 96                	jmp    f010389f <.L25+0x45>

f0103909 <.L20>:
			putch('%', putdat);
f0103909:	8b 75 08             	mov    0x8(%ebp),%esi
f010390c:	83 ec 08             	sub    $0x8,%esp
f010390f:	57                   	push   %edi
f0103910:	6a 25                	push   $0x25
f0103912:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103914:	83 c4 10             	add    $0x10,%esp
f0103917:	89 d8                	mov    %ebx,%eax
f0103919:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010391d:	74 05                	je     f0103924 <.L20+0x1b>
f010391f:	83 e8 01             	sub    $0x1,%eax
f0103922:	eb f5                	jmp    f0103919 <.L20+0x10>
f0103924:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103927:	e9 73 ff ff ff       	jmp    f010389f <.L25+0x45>

f010392c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010392c:	55                   	push   %ebp
f010392d:	89 e5                	mov    %esp,%ebp
f010392f:	53                   	push   %ebx
f0103930:	83 ec 14             	sub    $0x14,%esp
f0103933:	e8 17 c8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103938:	81 c3 d4 39 01 00    	add    $0x139d4,%ebx
f010393e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103941:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103944:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103947:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010394b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010394e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103955:	85 c0                	test   %eax,%eax
f0103957:	74 2b                	je     f0103984 <vsnprintf+0x58>
f0103959:	85 d2                	test   %edx,%edx
f010395b:	7e 27                	jle    f0103984 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010395d:	ff 75 14             	push   0x14(%ebp)
f0103960:	ff 75 10             	push   0x10(%ebp)
f0103963:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103966:	50                   	push   %eax
f0103967:	8d 83 42 c1 fe ff    	lea    -0x13ebe(%ebx),%eax
f010396d:	50                   	push   %eax
f010396e:	e8 15 fb ff ff       	call   f0103488 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103973:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103976:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103979:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010397c:	83 c4 10             	add    $0x10,%esp
}
f010397f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103982:	c9                   	leave  
f0103983:	c3                   	ret    
		return -E_INVAL;
f0103984:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103989:	eb f4                	jmp    f010397f <vsnprintf+0x53>

f010398b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010398b:	55                   	push   %ebp
f010398c:	89 e5                	mov    %esp,%ebp
f010398e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103991:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103994:	50                   	push   %eax
f0103995:	ff 75 10             	push   0x10(%ebp)
f0103998:	ff 75 0c             	push   0xc(%ebp)
f010399b:	ff 75 08             	push   0x8(%ebp)
f010399e:	e8 89 ff ff ff       	call   f010392c <vsnprintf>
	va_end(ap);

	return rc;
}
f01039a3:	c9                   	leave  
f01039a4:	c3                   	ret    

f01039a5 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01039a5:	55                   	push   %ebp
f01039a6:	89 e5                	mov    %esp,%ebp
f01039a8:	57                   	push   %edi
f01039a9:	56                   	push   %esi
f01039aa:	53                   	push   %ebx
f01039ab:	83 ec 1c             	sub    $0x1c,%esp
f01039ae:	e8 9c c7 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01039b3:	81 c3 59 39 01 00    	add    $0x13959,%ebx
f01039b9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01039bc:	85 c0                	test   %eax,%eax
f01039be:	74 13                	je     f01039d3 <readline+0x2e>
		cprintf("%s", prompt);
f01039c0:	83 ec 08             	sub    $0x8,%esp
f01039c3:	50                   	push   %eax
f01039c4:	8d 83 59 da fe ff    	lea    -0x125a7(%ebx),%eax
f01039ca:	50                   	push   %eax
f01039cb:	e8 7c f6 ff ff       	call   f010304c <cprintf>
f01039d0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01039d3:	83 ec 0c             	sub    $0xc,%esp
f01039d6:	6a 00                	push   $0x0
f01039d8:	e8 fe cc ff ff       	call   f01006db <iscons>
f01039dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039e0:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01039e3:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01039e8:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f01039ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01039f1:	eb 45                	jmp    f0103a38 <readline+0x93>
			cprintf("read error: %e\n", c);
f01039f3:	83 ec 08             	sub    $0x8,%esp
f01039f6:	50                   	push   %eax
f01039f7:	8d 83 0c df fe ff    	lea    -0x120f4(%ebx),%eax
f01039fd:	50                   	push   %eax
f01039fe:	e8 49 f6 ff ff       	call   f010304c <cprintf>
			return NULL;
f0103a03:	83 c4 10             	add    $0x10,%esp
f0103a06:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a0e:	5b                   	pop    %ebx
f0103a0f:	5e                   	pop    %esi
f0103a10:	5f                   	pop    %edi
f0103a11:	5d                   	pop    %ebp
f0103a12:	c3                   	ret    
			if (echoing)
f0103a13:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a17:	75 05                	jne    f0103a1e <readline+0x79>
			i--;
f0103a19:	83 ef 01             	sub    $0x1,%edi
f0103a1c:	eb 1a                	jmp    f0103a38 <readline+0x93>
				cputchar('\b');
f0103a1e:	83 ec 0c             	sub    $0xc,%esp
f0103a21:	6a 08                	push   $0x8
f0103a23:	e8 92 cc ff ff       	call   f01006ba <cputchar>
f0103a28:	83 c4 10             	add    $0x10,%esp
f0103a2b:	eb ec                	jmp    f0103a19 <readline+0x74>
			buf[i++] = c;
f0103a2d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103a30:	89 f0                	mov    %esi,%eax
f0103a32:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0103a35:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103a38:	e8 8d cc ff ff       	call   f01006ca <getchar>
f0103a3d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103a3f:	85 c0                	test   %eax,%eax
f0103a41:	78 b0                	js     f01039f3 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103a43:	83 f8 08             	cmp    $0x8,%eax
f0103a46:	0f 94 c0             	sete   %al
f0103a49:	83 fe 7f             	cmp    $0x7f,%esi
f0103a4c:	0f 94 c2             	sete   %dl
f0103a4f:	08 d0                	or     %dl,%al
f0103a51:	74 04                	je     f0103a57 <readline+0xb2>
f0103a53:	85 ff                	test   %edi,%edi
f0103a55:	7f bc                	jg     f0103a13 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103a57:	83 fe 1f             	cmp    $0x1f,%esi
f0103a5a:	7e 1c                	jle    f0103a78 <readline+0xd3>
f0103a5c:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103a62:	7f 14                	jg     f0103a78 <readline+0xd3>
			if (echoing)
f0103a64:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a68:	74 c3                	je     f0103a2d <readline+0x88>
				cputchar(c);
f0103a6a:	83 ec 0c             	sub    $0xc,%esp
f0103a6d:	56                   	push   %esi
f0103a6e:	e8 47 cc ff ff       	call   f01006ba <cputchar>
f0103a73:	83 c4 10             	add    $0x10,%esp
f0103a76:	eb b5                	jmp    f0103a2d <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0103a78:	83 fe 0a             	cmp    $0xa,%esi
f0103a7b:	74 05                	je     f0103a82 <readline+0xdd>
f0103a7d:	83 fe 0d             	cmp    $0xd,%esi
f0103a80:	75 b6                	jne    f0103a38 <readline+0x93>
			if (echoing)
f0103a82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a86:	75 13                	jne    f0103a9b <readline+0xf6>
			buf[i] = 0;
f0103a88:	c6 84 3b d4 1f 00 00 	movb   $0x0,0x1fd4(%ebx,%edi,1)
f0103a8f:	00 
			return buf;
f0103a90:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103a96:	e9 70 ff ff ff       	jmp    f0103a0b <readline+0x66>
				cputchar('\n');
f0103a9b:	83 ec 0c             	sub    $0xc,%esp
f0103a9e:	6a 0a                	push   $0xa
f0103aa0:	e8 15 cc ff ff       	call   f01006ba <cputchar>
f0103aa5:	83 c4 10             	add    $0x10,%esp
f0103aa8:	eb de                	jmp    f0103a88 <readline+0xe3>

f0103aaa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103aaa:	55                   	push   %ebp
f0103aab:	89 e5                	mov    %esp,%ebp
f0103aad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103ab0:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ab5:	eb 03                	jmp    f0103aba <strlen+0x10>
		n++;
f0103ab7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103aba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103abe:	75 f7                	jne    f0103ab7 <strlen+0xd>
	return n;
}
f0103ac0:	5d                   	pop    %ebp
f0103ac1:	c3                   	ret    

f0103ac2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103ac2:	55                   	push   %ebp
f0103ac3:	89 e5                	mov    %esp,%ebp
f0103ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103acb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ad0:	eb 03                	jmp    f0103ad5 <strnlen+0x13>
		n++;
f0103ad2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103ad5:	39 d0                	cmp    %edx,%eax
f0103ad7:	74 08                	je     f0103ae1 <strnlen+0x1f>
f0103ad9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103add:	75 f3                	jne    f0103ad2 <strnlen+0x10>
f0103adf:	89 c2                	mov    %eax,%edx
	return n;
}
f0103ae1:	89 d0                	mov    %edx,%eax
f0103ae3:	5d                   	pop    %ebp
f0103ae4:	c3                   	ret    

f0103ae5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103ae5:	55                   	push   %ebp
f0103ae6:	89 e5                	mov    %esp,%ebp
f0103ae8:	53                   	push   %ebx
f0103ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103aec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103aef:	b8 00 00 00 00       	mov    $0x0,%eax
f0103af4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0103af8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103afb:	83 c0 01             	add    $0x1,%eax
f0103afe:	84 d2                	test   %dl,%dl
f0103b00:	75 f2                	jne    f0103af4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103b02:	89 c8                	mov    %ecx,%eax
f0103b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b07:	c9                   	leave  
f0103b08:	c3                   	ret    

f0103b09 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103b09:	55                   	push   %ebp
f0103b0a:	89 e5                	mov    %esp,%ebp
f0103b0c:	53                   	push   %ebx
f0103b0d:	83 ec 10             	sub    $0x10,%esp
f0103b10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103b13:	53                   	push   %ebx
f0103b14:	e8 91 ff ff ff       	call   f0103aaa <strlen>
f0103b19:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103b1c:	ff 75 0c             	push   0xc(%ebp)
f0103b1f:	01 d8                	add    %ebx,%eax
f0103b21:	50                   	push   %eax
f0103b22:	e8 be ff ff ff       	call   f0103ae5 <strcpy>
	return dst;
}
f0103b27:	89 d8                	mov    %ebx,%eax
f0103b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b2c:	c9                   	leave  
f0103b2d:	c3                   	ret    

f0103b2e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103b2e:	55                   	push   %ebp
f0103b2f:	89 e5                	mov    %esp,%ebp
f0103b31:	56                   	push   %esi
f0103b32:	53                   	push   %ebx
f0103b33:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b36:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b39:	89 f3                	mov    %esi,%ebx
f0103b3b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b3e:	89 f0                	mov    %esi,%eax
f0103b40:	eb 0f                	jmp    f0103b51 <strncpy+0x23>
		*dst++ = *src;
f0103b42:	83 c0 01             	add    $0x1,%eax
f0103b45:	0f b6 0a             	movzbl (%edx),%ecx
f0103b48:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103b4b:	80 f9 01             	cmp    $0x1,%cl
f0103b4e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0103b51:	39 d8                	cmp    %ebx,%eax
f0103b53:	75 ed                	jne    f0103b42 <strncpy+0x14>
	}
	return ret;
}
f0103b55:	89 f0                	mov    %esi,%eax
f0103b57:	5b                   	pop    %ebx
f0103b58:	5e                   	pop    %esi
f0103b59:	5d                   	pop    %ebp
f0103b5a:	c3                   	ret    

f0103b5b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103b5b:	55                   	push   %ebp
f0103b5c:	89 e5                	mov    %esp,%ebp
f0103b5e:	56                   	push   %esi
f0103b5f:	53                   	push   %ebx
f0103b60:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103b66:	8b 55 10             	mov    0x10(%ebp),%edx
f0103b69:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103b6b:	85 d2                	test   %edx,%edx
f0103b6d:	74 21                	je     f0103b90 <strlcpy+0x35>
f0103b6f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103b73:	89 f2                	mov    %esi,%edx
f0103b75:	eb 09                	jmp    f0103b80 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103b77:	83 c1 01             	add    $0x1,%ecx
f0103b7a:	83 c2 01             	add    $0x1,%edx
f0103b7d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0103b80:	39 c2                	cmp    %eax,%edx
f0103b82:	74 09                	je     f0103b8d <strlcpy+0x32>
f0103b84:	0f b6 19             	movzbl (%ecx),%ebx
f0103b87:	84 db                	test   %bl,%bl
f0103b89:	75 ec                	jne    f0103b77 <strlcpy+0x1c>
f0103b8b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103b8d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103b90:	29 f0                	sub    %esi,%eax
}
f0103b92:	5b                   	pop    %ebx
f0103b93:	5e                   	pop    %esi
f0103b94:	5d                   	pop    %ebp
f0103b95:	c3                   	ret    

f0103b96 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103b96:	55                   	push   %ebp
f0103b97:	89 e5                	mov    %esp,%ebp
f0103b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b9c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103b9f:	eb 06                	jmp    f0103ba7 <strcmp+0x11>
		p++, q++;
f0103ba1:	83 c1 01             	add    $0x1,%ecx
f0103ba4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103ba7:	0f b6 01             	movzbl (%ecx),%eax
f0103baa:	84 c0                	test   %al,%al
f0103bac:	74 04                	je     f0103bb2 <strcmp+0x1c>
f0103bae:	3a 02                	cmp    (%edx),%al
f0103bb0:	74 ef                	je     f0103ba1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bb2:	0f b6 c0             	movzbl %al,%eax
f0103bb5:	0f b6 12             	movzbl (%edx),%edx
f0103bb8:	29 d0                	sub    %edx,%eax
}
f0103bba:	5d                   	pop    %ebp
f0103bbb:	c3                   	ret    

f0103bbc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103bbc:	55                   	push   %ebp
f0103bbd:	89 e5                	mov    %esp,%ebp
f0103bbf:	53                   	push   %ebx
f0103bc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bc6:	89 c3                	mov    %eax,%ebx
f0103bc8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103bcb:	eb 06                	jmp    f0103bd3 <strncmp+0x17>
		n--, p++, q++;
f0103bcd:	83 c0 01             	add    $0x1,%eax
f0103bd0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103bd3:	39 d8                	cmp    %ebx,%eax
f0103bd5:	74 18                	je     f0103bef <strncmp+0x33>
f0103bd7:	0f b6 08             	movzbl (%eax),%ecx
f0103bda:	84 c9                	test   %cl,%cl
f0103bdc:	74 04                	je     f0103be2 <strncmp+0x26>
f0103bde:	3a 0a                	cmp    (%edx),%cl
f0103be0:	74 eb                	je     f0103bcd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103be2:	0f b6 00             	movzbl (%eax),%eax
f0103be5:	0f b6 12             	movzbl (%edx),%edx
f0103be8:	29 d0                	sub    %edx,%eax
}
f0103bea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bed:	c9                   	leave  
f0103bee:	c3                   	ret    
		return 0;
f0103bef:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bf4:	eb f4                	jmp    f0103bea <strncmp+0x2e>

f0103bf6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103bf6:	55                   	push   %ebp
f0103bf7:	89 e5                	mov    %esp,%ebp
f0103bf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bfc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c00:	eb 03                	jmp    f0103c05 <strchr+0xf>
f0103c02:	83 c0 01             	add    $0x1,%eax
f0103c05:	0f b6 10             	movzbl (%eax),%edx
f0103c08:	84 d2                	test   %dl,%dl
f0103c0a:	74 06                	je     f0103c12 <strchr+0x1c>
		if (*s == c)
f0103c0c:	38 ca                	cmp    %cl,%dl
f0103c0e:	75 f2                	jne    f0103c02 <strchr+0xc>
f0103c10:	eb 05                	jmp    f0103c17 <strchr+0x21>
			return (char *) s;
	return 0;
f0103c12:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c17:	5d                   	pop    %ebp
f0103c18:	c3                   	ret    

f0103c19 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103c19:	55                   	push   %ebp
f0103c1a:	89 e5                	mov    %esp,%ebp
f0103c1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c1f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c23:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103c26:	38 ca                	cmp    %cl,%dl
f0103c28:	74 09                	je     f0103c33 <strfind+0x1a>
f0103c2a:	84 d2                	test   %dl,%dl
f0103c2c:	74 05                	je     f0103c33 <strfind+0x1a>
	for (; *s; s++)
f0103c2e:	83 c0 01             	add    $0x1,%eax
f0103c31:	eb f0                	jmp    f0103c23 <strfind+0xa>
			break;
	return (char *) s;
}
f0103c33:	5d                   	pop    %ebp
f0103c34:	c3                   	ret    

f0103c35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103c35:	55                   	push   %ebp
f0103c36:	89 e5                	mov    %esp,%ebp
f0103c38:	57                   	push   %edi
f0103c39:	56                   	push   %esi
f0103c3a:	53                   	push   %ebx
f0103c3b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103c41:	85 c9                	test   %ecx,%ecx
f0103c43:	74 2f                	je     f0103c74 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103c45:	89 f8                	mov    %edi,%eax
f0103c47:	09 c8                	or     %ecx,%eax
f0103c49:	a8 03                	test   $0x3,%al
f0103c4b:	75 21                	jne    f0103c6e <memset+0x39>
		c &= 0xFF;
f0103c4d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103c51:	89 d0                	mov    %edx,%eax
f0103c53:	c1 e0 08             	shl    $0x8,%eax
f0103c56:	89 d3                	mov    %edx,%ebx
f0103c58:	c1 e3 18             	shl    $0x18,%ebx
f0103c5b:	89 d6                	mov    %edx,%esi
f0103c5d:	c1 e6 10             	shl    $0x10,%esi
f0103c60:	09 f3                	or     %esi,%ebx
f0103c62:	09 da                	or     %ebx,%edx
f0103c64:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103c66:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103c69:	fc                   	cld    
f0103c6a:	f3 ab                	rep stos %eax,%es:(%edi)
f0103c6c:	eb 06                	jmp    f0103c74 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c71:	fc                   	cld    
f0103c72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103c74:	89 f8                	mov    %edi,%eax
f0103c76:	5b                   	pop    %ebx
f0103c77:	5e                   	pop    %esi
f0103c78:	5f                   	pop    %edi
f0103c79:	5d                   	pop    %ebp
f0103c7a:	c3                   	ret    

f0103c7b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103c7b:	55                   	push   %ebp
f0103c7c:	89 e5                	mov    %esp,%ebp
f0103c7e:	57                   	push   %edi
f0103c7f:	56                   	push   %esi
f0103c80:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c83:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103c86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103c89:	39 c6                	cmp    %eax,%esi
f0103c8b:	73 32                	jae    f0103cbf <memmove+0x44>
f0103c8d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103c90:	39 c2                	cmp    %eax,%edx
f0103c92:	76 2b                	jbe    f0103cbf <memmove+0x44>
		s += n;
		d += n;
f0103c94:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103c97:	89 d6                	mov    %edx,%esi
f0103c99:	09 fe                	or     %edi,%esi
f0103c9b:	09 ce                	or     %ecx,%esi
f0103c9d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103ca3:	75 0e                	jne    f0103cb3 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103ca5:	83 ef 04             	sub    $0x4,%edi
f0103ca8:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103cab:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103cae:	fd                   	std    
f0103caf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cb1:	eb 09                	jmp    f0103cbc <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103cb3:	83 ef 01             	sub    $0x1,%edi
f0103cb6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103cb9:	fd                   	std    
f0103cba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103cbc:	fc                   	cld    
f0103cbd:	eb 1a                	jmp    f0103cd9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cbf:	89 f2                	mov    %esi,%edx
f0103cc1:	09 c2                	or     %eax,%edx
f0103cc3:	09 ca                	or     %ecx,%edx
f0103cc5:	f6 c2 03             	test   $0x3,%dl
f0103cc8:	75 0a                	jne    f0103cd4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103cca:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103ccd:	89 c7                	mov    %eax,%edi
f0103ccf:	fc                   	cld    
f0103cd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cd2:	eb 05                	jmp    f0103cd9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0103cd4:	89 c7                	mov    %eax,%edi
f0103cd6:	fc                   	cld    
f0103cd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103cd9:	5e                   	pop    %esi
f0103cda:	5f                   	pop    %edi
f0103cdb:	5d                   	pop    %ebp
f0103cdc:	c3                   	ret    

f0103cdd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103cdd:	55                   	push   %ebp
f0103cde:	89 e5                	mov    %esp,%ebp
f0103ce0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103ce3:	ff 75 10             	push   0x10(%ebp)
f0103ce6:	ff 75 0c             	push   0xc(%ebp)
f0103ce9:	ff 75 08             	push   0x8(%ebp)
f0103cec:	e8 8a ff ff ff       	call   f0103c7b <memmove>
}
f0103cf1:	c9                   	leave  
f0103cf2:	c3                   	ret    

f0103cf3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103cf3:	55                   	push   %ebp
f0103cf4:	89 e5                	mov    %esp,%ebp
f0103cf6:	56                   	push   %esi
f0103cf7:	53                   	push   %ebx
f0103cf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cfe:	89 c6                	mov    %eax,%esi
f0103d00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d03:	eb 06                	jmp    f0103d0b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103d05:	83 c0 01             	add    $0x1,%eax
f0103d08:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0103d0b:	39 f0                	cmp    %esi,%eax
f0103d0d:	74 14                	je     f0103d23 <memcmp+0x30>
		if (*s1 != *s2)
f0103d0f:	0f b6 08             	movzbl (%eax),%ecx
f0103d12:	0f b6 1a             	movzbl (%edx),%ebx
f0103d15:	38 d9                	cmp    %bl,%cl
f0103d17:	74 ec                	je     f0103d05 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0103d19:	0f b6 c1             	movzbl %cl,%eax
f0103d1c:	0f b6 db             	movzbl %bl,%ebx
f0103d1f:	29 d8                	sub    %ebx,%eax
f0103d21:	eb 05                	jmp    f0103d28 <memcmp+0x35>
	}

	return 0;
f0103d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d28:	5b                   	pop    %ebx
f0103d29:	5e                   	pop    %esi
f0103d2a:	5d                   	pop    %ebp
f0103d2b:	c3                   	ret    

f0103d2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103d2c:	55                   	push   %ebp
f0103d2d:	89 e5                	mov    %esp,%ebp
f0103d2f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103d35:	89 c2                	mov    %eax,%edx
f0103d37:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103d3a:	eb 03                	jmp    f0103d3f <memfind+0x13>
f0103d3c:	83 c0 01             	add    $0x1,%eax
f0103d3f:	39 d0                	cmp    %edx,%eax
f0103d41:	73 04                	jae    f0103d47 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103d43:	38 08                	cmp    %cl,(%eax)
f0103d45:	75 f5                	jne    f0103d3c <memfind+0x10>
			break;
	return (void *) s;
}
f0103d47:	5d                   	pop    %ebp
f0103d48:	c3                   	ret    

f0103d49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103d49:	55                   	push   %ebp
f0103d4a:	89 e5                	mov    %esp,%ebp
f0103d4c:	57                   	push   %edi
f0103d4d:	56                   	push   %esi
f0103d4e:	53                   	push   %ebx
f0103d4f:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d55:	eb 03                	jmp    f0103d5a <strtol+0x11>
		s++;
f0103d57:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0103d5a:	0f b6 02             	movzbl (%edx),%eax
f0103d5d:	3c 20                	cmp    $0x20,%al
f0103d5f:	74 f6                	je     f0103d57 <strtol+0xe>
f0103d61:	3c 09                	cmp    $0x9,%al
f0103d63:	74 f2                	je     f0103d57 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103d65:	3c 2b                	cmp    $0x2b,%al
f0103d67:	74 2a                	je     f0103d93 <strtol+0x4a>
	int neg = 0;
f0103d69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103d6e:	3c 2d                	cmp    $0x2d,%al
f0103d70:	74 2b                	je     f0103d9d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103d72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103d78:	75 0f                	jne    f0103d89 <strtol+0x40>
f0103d7a:	80 3a 30             	cmpb   $0x30,(%edx)
f0103d7d:	74 28                	je     f0103da7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103d7f:	85 db                	test   %ebx,%ebx
f0103d81:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d86:	0f 44 d8             	cmove  %eax,%ebx
f0103d89:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d8e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103d91:	eb 46                	jmp    f0103dd9 <strtol+0x90>
		s++;
f0103d93:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0103d96:	bf 00 00 00 00       	mov    $0x0,%edi
f0103d9b:	eb d5                	jmp    f0103d72 <strtol+0x29>
		s++, neg = 1;
f0103d9d:	83 c2 01             	add    $0x1,%edx
f0103da0:	bf 01 00 00 00       	mov    $0x1,%edi
f0103da5:	eb cb                	jmp    f0103d72 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103da7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103dab:	74 0e                	je     f0103dbb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0103dad:	85 db                	test   %ebx,%ebx
f0103daf:	75 d8                	jne    f0103d89 <strtol+0x40>
		s++, base = 8;
f0103db1:	83 c2 01             	add    $0x1,%edx
f0103db4:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103db9:	eb ce                	jmp    f0103d89 <strtol+0x40>
		s += 2, base = 16;
f0103dbb:	83 c2 02             	add    $0x2,%edx
f0103dbe:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103dc3:	eb c4                	jmp    f0103d89 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0103dc5:	0f be c0             	movsbl %al,%eax
f0103dc8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103dcb:	3b 45 10             	cmp    0x10(%ebp),%eax
f0103dce:	7d 3a                	jge    f0103e0a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103dd0:	83 c2 01             	add    $0x1,%edx
f0103dd3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0103dd7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0103dd9:	0f b6 02             	movzbl (%edx),%eax
f0103ddc:	8d 70 d0             	lea    -0x30(%eax),%esi
f0103ddf:	89 f3                	mov    %esi,%ebx
f0103de1:	80 fb 09             	cmp    $0x9,%bl
f0103de4:	76 df                	jbe    f0103dc5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0103de6:	8d 70 9f             	lea    -0x61(%eax),%esi
f0103de9:	89 f3                	mov    %esi,%ebx
f0103deb:	80 fb 19             	cmp    $0x19,%bl
f0103dee:	77 08                	ja     f0103df8 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0103df0:	0f be c0             	movsbl %al,%eax
f0103df3:	83 e8 57             	sub    $0x57,%eax
f0103df6:	eb d3                	jmp    f0103dcb <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0103df8:	8d 70 bf             	lea    -0x41(%eax),%esi
f0103dfb:	89 f3                	mov    %esi,%ebx
f0103dfd:	80 fb 19             	cmp    $0x19,%bl
f0103e00:	77 08                	ja     f0103e0a <strtol+0xc1>
			dig = *s - 'A' + 10;
f0103e02:	0f be c0             	movsbl %al,%eax
f0103e05:	83 e8 37             	sub    $0x37,%eax
f0103e08:	eb c1                	jmp    f0103dcb <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103e0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e0e:	74 05                	je     f0103e15 <strtol+0xcc>
		*endptr = (char *) s;
f0103e10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e13:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0103e15:	89 c8                	mov    %ecx,%eax
f0103e17:	f7 d8                	neg    %eax
f0103e19:	85 ff                	test   %edi,%edi
f0103e1b:	0f 45 c8             	cmovne %eax,%ecx
}
f0103e1e:	89 c8                	mov    %ecx,%eax
f0103e20:	5b                   	pop    %ebx
f0103e21:	5e                   	pop    %esi
f0103e22:	5f                   	pop    %edi
f0103e23:	5d                   	pop    %ebp
f0103e24:	c3                   	ret    
f0103e25:	66 90                	xchg   %ax,%ax
f0103e27:	66 90                	xchg   %ax,%ax
f0103e29:	66 90                	xchg   %ax,%ax
f0103e2b:	66 90                	xchg   %ax,%ax
f0103e2d:	66 90                	xchg   %ax,%ax
f0103e2f:	90                   	nop

f0103e30 <__udivdi3>:
f0103e30:	f3 0f 1e fb          	endbr32 
f0103e34:	55                   	push   %ebp
f0103e35:	57                   	push   %edi
f0103e36:	56                   	push   %esi
f0103e37:	53                   	push   %ebx
f0103e38:	83 ec 1c             	sub    $0x1c,%esp
f0103e3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103e3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103e43:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103e47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103e4b:	85 c0                	test   %eax,%eax
f0103e4d:	75 19                	jne    f0103e68 <__udivdi3+0x38>
f0103e4f:	39 f3                	cmp    %esi,%ebx
f0103e51:	76 4d                	jbe    f0103ea0 <__udivdi3+0x70>
f0103e53:	31 ff                	xor    %edi,%edi
f0103e55:	89 e8                	mov    %ebp,%eax
f0103e57:	89 f2                	mov    %esi,%edx
f0103e59:	f7 f3                	div    %ebx
f0103e5b:	89 fa                	mov    %edi,%edx
f0103e5d:	83 c4 1c             	add    $0x1c,%esp
f0103e60:	5b                   	pop    %ebx
f0103e61:	5e                   	pop    %esi
f0103e62:	5f                   	pop    %edi
f0103e63:	5d                   	pop    %ebp
f0103e64:	c3                   	ret    
f0103e65:	8d 76 00             	lea    0x0(%esi),%esi
f0103e68:	39 f0                	cmp    %esi,%eax
f0103e6a:	76 14                	jbe    f0103e80 <__udivdi3+0x50>
f0103e6c:	31 ff                	xor    %edi,%edi
f0103e6e:	31 c0                	xor    %eax,%eax
f0103e70:	89 fa                	mov    %edi,%edx
f0103e72:	83 c4 1c             	add    $0x1c,%esp
f0103e75:	5b                   	pop    %ebx
f0103e76:	5e                   	pop    %esi
f0103e77:	5f                   	pop    %edi
f0103e78:	5d                   	pop    %ebp
f0103e79:	c3                   	ret    
f0103e7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103e80:	0f bd f8             	bsr    %eax,%edi
f0103e83:	83 f7 1f             	xor    $0x1f,%edi
f0103e86:	75 48                	jne    f0103ed0 <__udivdi3+0xa0>
f0103e88:	39 f0                	cmp    %esi,%eax
f0103e8a:	72 06                	jb     f0103e92 <__udivdi3+0x62>
f0103e8c:	31 c0                	xor    %eax,%eax
f0103e8e:	39 eb                	cmp    %ebp,%ebx
f0103e90:	77 de                	ja     f0103e70 <__udivdi3+0x40>
f0103e92:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e97:	eb d7                	jmp    f0103e70 <__udivdi3+0x40>
f0103e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ea0:	89 d9                	mov    %ebx,%ecx
f0103ea2:	85 db                	test   %ebx,%ebx
f0103ea4:	75 0b                	jne    f0103eb1 <__udivdi3+0x81>
f0103ea6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eab:	31 d2                	xor    %edx,%edx
f0103ead:	f7 f3                	div    %ebx
f0103eaf:	89 c1                	mov    %eax,%ecx
f0103eb1:	31 d2                	xor    %edx,%edx
f0103eb3:	89 f0                	mov    %esi,%eax
f0103eb5:	f7 f1                	div    %ecx
f0103eb7:	89 c6                	mov    %eax,%esi
f0103eb9:	89 e8                	mov    %ebp,%eax
f0103ebb:	89 f7                	mov    %esi,%edi
f0103ebd:	f7 f1                	div    %ecx
f0103ebf:	89 fa                	mov    %edi,%edx
f0103ec1:	83 c4 1c             	add    $0x1c,%esp
f0103ec4:	5b                   	pop    %ebx
f0103ec5:	5e                   	pop    %esi
f0103ec6:	5f                   	pop    %edi
f0103ec7:	5d                   	pop    %ebp
f0103ec8:	c3                   	ret    
f0103ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ed0:	89 f9                	mov    %edi,%ecx
f0103ed2:	ba 20 00 00 00       	mov    $0x20,%edx
f0103ed7:	29 fa                	sub    %edi,%edx
f0103ed9:	d3 e0                	shl    %cl,%eax
f0103edb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103edf:	89 d1                	mov    %edx,%ecx
f0103ee1:	89 d8                	mov    %ebx,%eax
f0103ee3:	d3 e8                	shr    %cl,%eax
f0103ee5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103ee9:	09 c1                	or     %eax,%ecx
f0103eeb:	89 f0                	mov    %esi,%eax
f0103eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103ef1:	89 f9                	mov    %edi,%ecx
f0103ef3:	d3 e3                	shl    %cl,%ebx
f0103ef5:	89 d1                	mov    %edx,%ecx
f0103ef7:	d3 e8                	shr    %cl,%eax
f0103ef9:	89 f9                	mov    %edi,%ecx
f0103efb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103eff:	89 eb                	mov    %ebp,%ebx
f0103f01:	d3 e6                	shl    %cl,%esi
f0103f03:	89 d1                	mov    %edx,%ecx
f0103f05:	d3 eb                	shr    %cl,%ebx
f0103f07:	09 f3                	or     %esi,%ebx
f0103f09:	89 c6                	mov    %eax,%esi
f0103f0b:	89 f2                	mov    %esi,%edx
f0103f0d:	89 d8                	mov    %ebx,%eax
f0103f0f:	f7 74 24 08          	divl   0x8(%esp)
f0103f13:	89 d6                	mov    %edx,%esi
f0103f15:	89 c3                	mov    %eax,%ebx
f0103f17:	f7 64 24 0c          	mull   0xc(%esp)
f0103f1b:	39 d6                	cmp    %edx,%esi
f0103f1d:	72 19                	jb     f0103f38 <__udivdi3+0x108>
f0103f1f:	89 f9                	mov    %edi,%ecx
f0103f21:	d3 e5                	shl    %cl,%ebp
f0103f23:	39 c5                	cmp    %eax,%ebp
f0103f25:	73 04                	jae    f0103f2b <__udivdi3+0xfb>
f0103f27:	39 d6                	cmp    %edx,%esi
f0103f29:	74 0d                	je     f0103f38 <__udivdi3+0x108>
f0103f2b:	89 d8                	mov    %ebx,%eax
f0103f2d:	31 ff                	xor    %edi,%edi
f0103f2f:	e9 3c ff ff ff       	jmp    f0103e70 <__udivdi3+0x40>
f0103f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103f38:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103f3b:	31 ff                	xor    %edi,%edi
f0103f3d:	e9 2e ff ff ff       	jmp    f0103e70 <__udivdi3+0x40>
f0103f42:	66 90                	xchg   %ax,%ax
f0103f44:	66 90                	xchg   %ax,%ax
f0103f46:	66 90                	xchg   %ax,%ax
f0103f48:	66 90                	xchg   %ax,%ax
f0103f4a:	66 90                	xchg   %ax,%ax
f0103f4c:	66 90                	xchg   %ax,%ax
f0103f4e:	66 90                	xchg   %ax,%ax

f0103f50 <__umoddi3>:
f0103f50:	f3 0f 1e fb          	endbr32 
f0103f54:	55                   	push   %ebp
f0103f55:	57                   	push   %edi
f0103f56:	56                   	push   %esi
f0103f57:	53                   	push   %ebx
f0103f58:	83 ec 1c             	sub    $0x1c,%esp
f0103f5b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103f5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103f63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0103f67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0103f6b:	89 f0                	mov    %esi,%eax
f0103f6d:	89 da                	mov    %ebx,%edx
f0103f6f:	85 ff                	test   %edi,%edi
f0103f71:	75 15                	jne    f0103f88 <__umoddi3+0x38>
f0103f73:	39 dd                	cmp    %ebx,%ebp
f0103f75:	76 39                	jbe    f0103fb0 <__umoddi3+0x60>
f0103f77:	f7 f5                	div    %ebp
f0103f79:	89 d0                	mov    %edx,%eax
f0103f7b:	31 d2                	xor    %edx,%edx
f0103f7d:	83 c4 1c             	add    $0x1c,%esp
f0103f80:	5b                   	pop    %ebx
f0103f81:	5e                   	pop    %esi
f0103f82:	5f                   	pop    %edi
f0103f83:	5d                   	pop    %ebp
f0103f84:	c3                   	ret    
f0103f85:	8d 76 00             	lea    0x0(%esi),%esi
f0103f88:	39 df                	cmp    %ebx,%edi
f0103f8a:	77 f1                	ja     f0103f7d <__umoddi3+0x2d>
f0103f8c:	0f bd cf             	bsr    %edi,%ecx
f0103f8f:	83 f1 1f             	xor    $0x1f,%ecx
f0103f92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103f96:	75 40                	jne    f0103fd8 <__umoddi3+0x88>
f0103f98:	39 df                	cmp    %ebx,%edi
f0103f9a:	72 04                	jb     f0103fa0 <__umoddi3+0x50>
f0103f9c:	39 f5                	cmp    %esi,%ebp
f0103f9e:	77 dd                	ja     f0103f7d <__umoddi3+0x2d>
f0103fa0:	89 da                	mov    %ebx,%edx
f0103fa2:	89 f0                	mov    %esi,%eax
f0103fa4:	29 e8                	sub    %ebp,%eax
f0103fa6:	19 fa                	sbb    %edi,%edx
f0103fa8:	eb d3                	jmp    f0103f7d <__umoddi3+0x2d>
f0103faa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103fb0:	89 e9                	mov    %ebp,%ecx
f0103fb2:	85 ed                	test   %ebp,%ebp
f0103fb4:	75 0b                	jne    f0103fc1 <__umoddi3+0x71>
f0103fb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fbb:	31 d2                	xor    %edx,%edx
f0103fbd:	f7 f5                	div    %ebp
f0103fbf:	89 c1                	mov    %eax,%ecx
f0103fc1:	89 d8                	mov    %ebx,%eax
f0103fc3:	31 d2                	xor    %edx,%edx
f0103fc5:	f7 f1                	div    %ecx
f0103fc7:	89 f0                	mov    %esi,%eax
f0103fc9:	f7 f1                	div    %ecx
f0103fcb:	89 d0                	mov    %edx,%eax
f0103fcd:	31 d2                	xor    %edx,%edx
f0103fcf:	eb ac                	jmp    f0103f7d <__umoddi3+0x2d>
f0103fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103fd8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103fdc:	ba 20 00 00 00       	mov    $0x20,%edx
f0103fe1:	29 c2                	sub    %eax,%edx
f0103fe3:	89 c1                	mov    %eax,%ecx
f0103fe5:	89 e8                	mov    %ebp,%eax
f0103fe7:	d3 e7                	shl    %cl,%edi
f0103fe9:	89 d1                	mov    %edx,%ecx
f0103feb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103fef:	d3 e8                	shr    %cl,%eax
f0103ff1:	89 c1                	mov    %eax,%ecx
f0103ff3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103ff7:	09 f9                	or     %edi,%ecx
f0103ff9:	89 df                	mov    %ebx,%edi
f0103ffb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103fff:	89 c1                	mov    %eax,%ecx
f0104001:	d3 e5                	shl    %cl,%ebp
f0104003:	89 d1                	mov    %edx,%ecx
f0104005:	d3 ef                	shr    %cl,%edi
f0104007:	89 c1                	mov    %eax,%ecx
f0104009:	89 f0                	mov    %esi,%eax
f010400b:	d3 e3                	shl    %cl,%ebx
f010400d:	89 d1                	mov    %edx,%ecx
f010400f:	89 fa                	mov    %edi,%edx
f0104011:	d3 e8                	shr    %cl,%eax
f0104013:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104018:	09 d8                	or     %ebx,%eax
f010401a:	f7 74 24 08          	divl   0x8(%esp)
f010401e:	89 d3                	mov    %edx,%ebx
f0104020:	d3 e6                	shl    %cl,%esi
f0104022:	f7 e5                	mul    %ebp
f0104024:	89 c7                	mov    %eax,%edi
f0104026:	89 d1                	mov    %edx,%ecx
f0104028:	39 d3                	cmp    %edx,%ebx
f010402a:	72 06                	jb     f0104032 <__umoddi3+0xe2>
f010402c:	75 0e                	jne    f010403c <__umoddi3+0xec>
f010402e:	39 c6                	cmp    %eax,%esi
f0104030:	73 0a                	jae    f010403c <__umoddi3+0xec>
f0104032:	29 e8                	sub    %ebp,%eax
f0104034:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104038:	89 d1                	mov    %edx,%ecx
f010403a:	89 c7                	mov    %eax,%edi
f010403c:	89 f5                	mov    %esi,%ebp
f010403e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104042:	29 fd                	sub    %edi,%ebp
f0104044:	19 cb                	sbb    %ecx,%ebx
f0104046:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010404b:	89 d8                	mov    %ebx,%eax
f010404d:	d3 e0                	shl    %cl,%eax
f010404f:	89 f1                	mov    %esi,%ecx
f0104051:	d3 ed                	shr    %cl,%ebp
f0104053:	d3 eb                	shr    %cl,%ebx
f0104055:	09 e8                	or     %ebp,%eax
f0104057:	89 da                	mov    %ebx,%edx
f0104059:	83 c4 1c             	add    $0x1c,%esp
f010405c:	5b                   	pop    %ebx
f010405d:	5e                   	pop    %esi
f010405e:	5f                   	pop    %edi
f010405f:	5d                   	pop    %ebp
f0104060:	c3                   	ret    
