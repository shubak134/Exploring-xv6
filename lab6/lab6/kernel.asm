
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 d6 10 80       	mov    $0x8010d630,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b0 39 10 80       	mov    $0x801039b0,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 ec 89 10 80       	push   $0x801089ec
80100046:	68 40 d6 10 80       	push   $0x8010d640
8010004b:	e8 30 54 00 00       	call   80105480 <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 8c 1d 11 80 3c 	movl   $0x80111d3c,0x80111d8c
8010005a:	1d 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 90 1d 11 80 3c 	movl   $0x80111d3c,0x80111d90
80100064:	1d 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 74 d6 10 80 	movl   $0x8010d674,-0xc(%ebp)
8010006e:	eb 47                	jmp    801000b7 <binit+0x83>
    b->next = bcache.head.next;
80100070:	8b 15 90 1d 11 80    	mov    0x80111d90,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 50 3c 1d 11 80 	movl   $0x80111d3c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	83 c0 0c             	add    $0xc,%eax
8010008c:	83 ec 08             	sub    $0x8,%esp
8010008f:	68 f3 89 10 80       	push   $0x801089f3
80100094:	50                   	push   %eax
80100095:	e8 53 52 00 00       	call   801052ed <initsleeplock>
8010009a:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010009d:	a1 90 1d 11 80       	mov    0x80111d90,%eax
801000a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000a5:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ab:	a3 90 1d 11 80       	mov    %eax,0x80111d90
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b0:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b7:	b8 3c 1d 11 80       	mov    $0x80111d3c,%eax
801000bc:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000bf:	72 af                	jb     80100070 <binit+0x3c>
  }
}
801000c1:	90                   	nop
801000c2:	90                   	nop
801000c3:	c9                   	leave  
801000c4:	c3                   	ret    

801000c5 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000c5:	f3 0f 1e fb          	endbr32 
801000c9:	55                   	push   %ebp
801000ca:	89 e5                	mov    %esp,%ebp
801000cc:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000cf:	83 ec 0c             	sub    $0xc,%esp
801000d2:	68 40 d6 10 80       	push   $0x8010d640
801000d7:	e8 ca 53 00 00       	call   801054a6 <acquire>
801000dc:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000df:	a1 90 1d 11 80       	mov    0x80111d90,%eax
801000e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000e7:	eb 58                	jmp    80100141 <bget+0x7c>
    if(b->dev == dev && b->blockno == blockno){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 40 04             	mov    0x4(%eax),%eax
801000ef:	39 45 08             	cmp    %eax,0x8(%ebp)
801000f2:	75 44                	jne    80100138 <bget+0x73>
801000f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f7:	8b 40 08             	mov    0x8(%eax),%eax
801000fa:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000fd:	75 39                	jne    80100138 <bget+0x73>
      b->refcnt++;
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	8b 40 4c             	mov    0x4c(%eax),%eax
80100105:	8d 50 01             	lea    0x1(%eax),%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
8010010e:	83 ec 0c             	sub    $0xc,%esp
80100111:	68 40 d6 10 80       	push   $0x8010d640
80100116:	e8 fd 53 00 00       	call   80105518 <release>
8010011b:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	83 c0 0c             	add    $0xc,%eax
80100124:	83 ec 0c             	sub    $0xc,%esp
80100127:	50                   	push   %eax
80100128:	e8 00 52 00 00       	call   8010532d <acquiresleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      return b;
80100130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100133:	e9 9d 00 00 00       	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100138:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013b:	8b 40 54             	mov    0x54(%eax),%eax
8010013e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100141:	81 7d f4 3c 1d 11 80 	cmpl   $0x80111d3c,-0xc(%ebp)
80100148:	75 9f                	jne    801000e9 <bget+0x24>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014a:	a1 8c 1d 11 80       	mov    0x80111d8c,%eax
8010014f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100152:	eb 6b                	jmp    801001bf <bget+0xfa>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100154:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100157:	8b 40 4c             	mov    0x4c(%eax),%eax
8010015a:	85 c0                	test   %eax,%eax
8010015c:	75 58                	jne    801001b6 <bget+0xf1>
8010015e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100161:	8b 00                	mov    (%eax),%eax
80100163:	83 e0 04             	and    $0x4,%eax
80100166:	85 c0                	test   %eax,%eax
80100168:	75 4c                	jne    801001b6 <bget+0xf1>
      b->dev = dev;
8010016a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016d:	8b 55 08             	mov    0x8(%ebp),%edx
80100170:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100176:	8b 55 0c             	mov    0xc(%ebp),%edx
80100179:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
8010017c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
80100185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100188:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
8010018f:	83 ec 0c             	sub    $0xc,%esp
80100192:	68 40 d6 10 80       	push   $0x8010d640
80100197:	e8 7c 53 00 00       	call   80105518 <release>
8010019c:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
8010019f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a2:	83 c0 0c             	add    $0xc,%eax
801001a5:	83 ec 0c             	sub    $0xc,%esp
801001a8:	50                   	push   %eax
801001a9:	e8 7f 51 00 00       	call   8010532d <acquiresleep>
801001ae:	83 c4 10             	add    $0x10,%esp
      return b;
801001b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b4:	eb 1f                	jmp    801001d5 <bget+0x110>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b9:	8b 40 50             	mov    0x50(%eax),%eax
801001bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001bf:	81 7d f4 3c 1d 11 80 	cmpl   $0x80111d3c,-0xc(%ebp)
801001c6:	75 8c                	jne    80100154 <bget+0x8f>
    }
  }
  panic("bget: no buffers");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 fa 89 10 80       	push   $0x801089fa
801001d0:	e8 fc 03 00 00       	call   801005d1 <panic>
}
801001d5:	c9                   	leave  
801001d6:	c3                   	ret    

801001d7 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001d7:	f3 0f 1e fb          	endbr32 
801001db:	55                   	push   %ebp
801001dc:	89 e5                	mov    %esp,%ebp
801001de:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001e1:	83 ec 08             	sub    $0x8,%esp
801001e4:	ff 75 0c             	pushl  0xc(%ebp)
801001e7:	ff 75 08             	pushl  0x8(%ebp)
801001ea:	e8 d6 fe ff ff       	call   801000c5 <bget>
801001ef:	83 c4 10             	add    $0x10,%esp
801001f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 02             	and    $0x2,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0e                	jne    8010020f <bread+0x38>
    iderw(b);
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	ff 75 f4             	pushl  -0xc(%ebp)
80100207:	e8 29 28 00 00       	call   80102a35 <iderw>
8010020c:	83 c4 10             	add    $0x10,%esp
  }
  return b;
8010020f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100212:	c9                   	leave  
80100213:	c3                   	ret    

80100214 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100214:	f3 0f 1e fb          	endbr32 
80100218:	55                   	push   %ebp
80100219:	89 e5                	mov    %esp,%ebp
8010021b:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010021e:	8b 45 08             	mov    0x8(%ebp),%eax
80100221:	83 c0 0c             	add    $0xc,%eax
80100224:	83 ec 0c             	sub    $0xc,%esp
80100227:	50                   	push   %eax
80100228:	e8 ba 51 00 00       	call   801053e7 <holdingsleep>
8010022d:	83 c4 10             	add    $0x10,%esp
80100230:	85 c0                	test   %eax,%eax
80100232:	75 0d                	jne    80100241 <bwrite+0x2d>
    panic("bwrite");
80100234:	83 ec 0c             	sub    $0xc,%esp
80100237:	68 0b 8a 10 80       	push   $0x80108a0b
8010023c:	e8 90 03 00 00       	call   801005d1 <panic>
  b->flags |= B_DIRTY;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 00                	mov    (%eax),%eax
80100246:	83 c8 04             	or     $0x4,%eax
80100249:	89 c2                	mov    %eax,%edx
8010024b:	8b 45 08             	mov    0x8(%ebp),%eax
8010024e:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100250:	83 ec 0c             	sub    $0xc,%esp
80100253:	ff 75 08             	pushl  0x8(%ebp)
80100256:	e8 da 27 00 00       	call   80102a35 <iderw>
8010025b:	83 c4 10             	add    $0x10,%esp
}
8010025e:	90                   	nop
8010025f:	c9                   	leave  
80100260:	c3                   	ret    

80100261 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100261:	f3 0f 1e fb          	endbr32 
80100265:	55                   	push   %ebp
80100266:	89 e5                	mov    %esp,%ebp
80100268:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	83 c0 0c             	add    $0xc,%eax
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	50                   	push   %eax
80100275:	e8 6d 51 00 00       	call   801053e7 <holdingsleep>
8010027a:	83 c4 10             	add    $0x10,%esp
8010027d:	85 c0                	test   %eax,%eax
8010027f:	75 0d                	jne    8010028e <brelse+0x2d>
    panic("brelse");
80100281:	83 ec 0c             	sub    $0xc,%esp
80100284:	68 12 8a 10 80       	push   $0x80108a12
80100289:	e8 43 03 00 00       	call   801005d1 <panic>

  releasesleep(&b->lock);
8010028e:	8b 45 08             	mov    0x8(%ebp),%eax
80100291:	83 c0 0c             	add    $0xc,%eax
80100294:	83 ec 0c             	sub    $0xc,%esp
80100297:	50                   	push   %eax
80100298:	e8 f8 50 00 00       	call   80105395 <releasesleep>
8010029d:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002a0:	83 ec 0c             	sub    $0xc,%esp
801002a3:	68 40 d6 10 80       	push   $0x8010d640
801002a8:	e8 f9 51 00 00       	call   801054a6 <acquire>
801002ad:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002b0:	8b 45 08             	mov    0x8(%ebp),%eax
801002b3:	8b 40 4c             	mov    0x4c(%eax),%eax
801002b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002bf:	8b 45 08             	mov    0x8(%ebp),%eax
801002c2:	8b 40 4c             	mov    0x4c(%eax),%eax
801002c5:	85 c0                	test   %eax,%eax
801002c7:	75 47                	jne    80100310 <brelse+0xaf>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002c9:	8b 45 08             	mov    0x8(%ebp),%eax
801002cc:	8b 40 54             	mov    0x54(%eax),%eax
801002cf:	8b 55 08             	mov    0x8(%ebp),%edx
801002d2:	8b 52 50             	mov    0x50(%edx),%edx
801002d5:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002d8:	8b 45 08             	mov    0x8(%ebp),%eax
801002db:	8b 40 50             	mov    0x50(%eax),%eax
801002de:	8b 55 08             	mov    0x8(%ebp),%edx
801002e1:	8b 52 54             	mov    0x54(%edx),%edx
801002e4:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002e7:	8b 15 90 1d 11 80    	mov    0x80111d90,%edx
801002ed:	8b 45 08             	mov    0x8(%ebp),%eax
801002f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002f3:	8b 45 08             	mov    0x8(%ebp),%eax
801002f6:	c7 40 50 3c 1d 11 80 	movl   $0x80111d3c,0x50(%eax)
    bcache.head.next->prev = b;
801002fd:	a1 90 1d 11 80       	mov    0x80111d90,%eax
80100302:	8b 55 08             	mov    0x8(%ebp),%edx
80100305:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100308:	8b 45 08             	mov    0x8(%ebp),%eax
8010030b:	a3 90 1d 11 80       	mov    %eax,0x80111d90
  }
  
  release(&bcache.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 40 d6 10 80       	push   $0x8010d640
80100318:	e8 fb 51 00 00       	call   80105518 <release>
8010031d:	83 c4 10             	add    $0x10,%esp
}
80100320:	90                   	nop
80100321:	c9                   	leave  
80100322:	c3                   	ret    

80100323 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80100323:	55                   	push   %ebp
80100324:	89 e5                	mov    %esp,%ebp
80100326:	83 ec 14             	sub    $0x14,%esp
80100329:	8b 45 08             	mov    0x8(%ebp),%eax
8010032c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100330:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80100334:	89 c2                	mov    %eax,%edx
80100336:	ec                   	in     (%dx),%al
80100337:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010033a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010033e:	c9                   	leave  
8010033f:	c3                   	ret    

80100340 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100340:	55                   	push   %ebp
80100341:	89 e5                	mov    %esp,%ebp
80100343:	83 ec 08             	sub    $0x8,%esp
80100346:	8b 45 08             	mov    0x8(%ebp),%eax
80100349:	8b 55 0c             	mov    0xc(%ebp),%edx
8010034c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100350:	89 d0                	mov    %edx,%eax
80100352:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100355:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100359:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010035d:	ee                   	out    %al,(%dx)
}
8010035e:	90                   	nop
8010035f:	c9                   	leave  
80100360:	c3                   	ret    

80100361 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100361:	55                   	push   %ebp
80100362:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100364:	fa                   	cli    
}
80100365:	90                   	nop
80100366:	5d                   	pop    %ebp
80100367:	c3                   	ret    

80100368 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100368:	f3 0f 1e fb          	endbr32 
8010036c:	55                   	push   %ebp
8010036d:	89 e5                	mov    %esp,%ebp
8010036f:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100372:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100376:	74 1c                	je     80100394 <printint+0x2c>
80100378:	8b 45 08             	mov    0x8(%ebp),%eax
8010037b:	c1 e8 1f             	shr    $0x1f,%eax
8010037e:	0f b6 c0             	movzbl %al,%eax
80100381:	89 45 10             	mov    %eax,0x10(%ebp)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 0a                	je     80100394 <printint+0x2c>
    x = -xx;
8010038a:	8b 45 08             	mov    0x8(%ebp),%eax
8010038d:	f7 d8                	neg    %eax
8010038f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100392:	eb 06                	jmp    8010039a <printint+0x32>
  else
    x = xx;
80100394:	8b 45 08             	mov    0x8(%ebp),%eax
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
8010039a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
801003a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a7:	ba 00 00 00 00       	mov    $0x0,%edx
801003ac:	f7 f1                	div    %ecx
801003ae:	89 d1                	mov    %edx,%ecx
801003b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003b3:	8d 50 01             	lea    0x1(%eax),%edx
801003b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003b9:	0f b6 91 04 a0 10 80 	movzbl -0x7fef5ffc(%ecx),%edx
801003c0:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003ca:	ba 00 00 00 00       	mov    $0x0,%edx
801003cf:	f7 f1                	div    %ecx
801003d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003d8:	75 c7                	jne    801003a1 <printint+0x39>

  if(sign)
801003da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003de:	74 2a                	je     8010040a <printint+0xa2>
    buf[i++] = '-';
801003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003e3:	8d 50 01             	lea    0x1(%eax),%edx
801003e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003e9:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ee:	eb 1a                	jmp    8010040a <printint+0xa2>
    consputc(buf[i]);
801003f0:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003f6:	01 d0                	add    %edx,%eax
801003f8:	0f b6 00             	movzbl (%eax),%eax
801003fb:	0f be c0             	movsbl %al,%eax
801003fe:	83 ec 0c             	sub    $0xc,%esp
80100401:	50                   	push   %eax
80100402:	e8 ff 03 00 00       	call   80100806 <consputc>
80100407:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
8010040a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010040e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100412:	79 dc                	jns    801003f0 <printint+0x88>
}
80100414:	90                   	nop
80100415:	90                   	nop
80100416:	c9                   	leave  
80100417:	c3                   	ret    

80100418 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
80100418:	f3 0f 1e fb          	endbr32 
8010041c:	55                   	push   %ebp
8010041d:	89 e5                	mov    %esp,%ebp
8010041f:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
80100422:	a1 d4 c5 10 80       	mov    0x8010c5d4,%eax
80100427:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
8010042a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010042e:	74 10                	je     80100440 <cprintf+0x28>
    acquire(&cons.lock);
80100430:	83 ec 0c             	sub    $0xc,%esp
80100433:	68 a0 c5 10 80       	push   $0x8010c5a0
80100438:	e8 69 50 00 00       	call   801054a6 <acquire>
8010043d:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100440:	8b 45 08             	mov    0x8(%ebp),%eax
80100443:	85 c0                	test   %eax,%eax
80100445:	75 0d                	jne    80100454 <cprintf+0x3c>
    panic("null fmt");
80100447:	83 ec 0c             	sub    $0xc,%esp
8010044a:	68 19 8a 10 80       	push   $0x80108a19
8010044f:	e8 7d 01 00 00       	call   801005d1 <panic>

  argp = (uint*)(void*)(&fmt + 1);
80100454:	8d 45 0c             	lea    0xc(%ebp),%eax
80100457:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010045a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100461:	e9 2f 01 00 00       	jmp    80100595 <cprintf+0x17d>
    if(c != '%'){
80100466:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010046a:	74 13                	je     8010047f <cprintf+0x67>
      consputc(c);
8010046c:	83 ec 0c             	sub    $0xc,%esp
8010046f:	ff 75 e4             	pushl  -0x1c(%ebp)
80100472:	e8 8f 03 00 00       	call   80100806 <consputc>
80100477:	83 c4 10             	add    $0x10,%esp
      continue;
8010047a:	e9 12 01 00 00       	jmp    80100591 <cprintf+0x179>
    }
    c = fmt[++i] & 0xff;
8010047f:	8b 55 08             	mov    0x8(%ebp),%edx
80100482:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100489:	01 d0                	add    %edx,%eax
8010048b:	0f b6 00             	movzbl (%eax),%eax
8010048e:	0f be c0             	movsbl %al,%eax
80100491:	25 ff 00 00 00       	and    $0xff,%eax
80100496:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100499:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010049d:	0f 84 14 01 00 00    	je     801005b7 <cprintf+0x19f>
      break;
    switch(c){
801004a3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004a7:	74 5e                	je     80100507 <cprintf+0xef>
801004a9:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
801004ad:	0f 8f c2 00 00 00    	jg     80100575 <cprintf+0x15d>
801004b3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004b7:	74 6b                	je     80100524 <cprintf+0x10c>
801004b9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
801004bd:	0f 8f b2 00 00 00    	jg     80100575 <cprintf+0x15d>
801004c3:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004c7:	74 3e                	je     80100507 <cprintf+0xef>
801004c9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004cd:	0f 8f a2 00 00 00    	jg     80100575 <cprintf+0x15d>
801004d3:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004d7:	0f 84 89 00 00 00    	je     80100566 <cprintf+0x14e>
801004dd:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004e1:	0f 85 8e 00 00 00    	jne    80100575 <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ea:	8d 50 04             	lea    0x4(%eax),%edx
801004ed:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f0:	8b 00                	mov    (%eax),%eax
801004f2:	83 ec 04             	sub    $0x4,%esp
801004f5:	6a 01                	push   $0x1
801004f7:	6a 0a                	push   $0xa
801004f9:	50                   	push   %eax
801004fa:	e8 69 fe ff ff       	call   80100368 <printint>
801004ff:	83 c4 10             	add    $0x10,%esp
      break;
80100502:	e9 8a 00 00 00       	jmp    80100591 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100507:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010050a:	8d 50 04             	lea    0x4(%eax),%edx
8010050d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100510:	8b 00                	mov    (%eax),%eax
80100512:	83 ec 04             	sub    $0x4,%esp
80100515:	6a 00                	push   $0x0
80100517:	6a 10                	push   $0x10
80100519:	50                   	push   %eax
8010051a:	e8 49 fe ff ff       	call   80100368 <printint>
8010051f:	83 c4 10             	add    $0x10,%esp
      break;
80100522:	eb 6d                	jmp    80100591 <cprintf+0x179>
    case 's':
      if((s = (char*)*argp++) == 0)
80100524:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100527:	8d 50 04             	lea    0x4(%eax),%edx
8010052a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010052d:	8b 00                	mov    (%eax),%eax
8010052f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100532:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100536:	75 22                	jne    8010055a <cprintf+0x142>
        s = "(null)";
80100538:	c7 45 ec 22 8a 10 80 	movl   $0x80108a22,-0x14(%ebp)
      for(; *s; s++)
8010053f:	eb 19                	jmp    8010055a <cprintf+0x142>
        consputc(*s);
80100541:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100544:	0f b6 00             	movzbl (%eax),%eax
80100547:	0f be c0             	movsbl %al,%eax
8010054a:	83 ec 0c             	sub    $0xc,%esp
8010054d:	50                   	push   %eax
8010054e:	e8 b3 02 00 00       	call   80100806 <consputc>
80100553:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
80100556:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010055a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010055d:	0f b6 00             	movzbl (%eax),%eax
80100560:	84 c0                	test   %al,%al
80100562:	75 dd                	jne    80100541 <cprintf+0x129>
      break;
80100564:	eb 2b                	jmp    80100591 <cprintf+0x179>
    case '%':
      consputc('%');
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	6a 25                	push   $0x25
8010056b:	e8 96 02 00 00       	call   80100806 <consputc>
80100570:	83 c4 10             	add    $0x10,%esp
      break;
80100573:	eb 1c                	jmp    80100591 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100575:	83 ec 0c             	sub    $0xc,%esp
80100578:	6a 25                	push   $0x25
8010057a:	e8 87 02 00 00       	call   80100806 <consputc>
8010057f:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100582:	83 ec 0c             	sub    $0xc,%esp
80100585:	ff 75 e4             	pushl  -0x1c(%ebp)
80100588:	e8 79 02 00 00       	call   80100806 <consputc>
8010058d:	83 c4 10             	add    $0x10,%esp
      break;
80100590:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100591:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100595:	8b 55 08             	mov    0x8(%ebp),%edx
80100598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010059b:	01 d0                	add    %edx,%eax
8010059d:	0f b6 00             	movzbl (%eax),%eax
801005a0:	0f be c0             	movsbl %al,%eax
801005a3:	25 ff 00 00 00       	and    $0xff,%eax
801005a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801005ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801005af:	0f 85 b1 fe ff ff    	jne    80100466 <cprintf+0x4e>
801005b5:	eb 01                	jmp    801005b8 <cprintf+0x1a0>
      break;
801005b7:	90                   	nop
    }
  }

  if(locking)
801005b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005bc:	74 10                	je     801005ce <cprintf+0x1b6>
    release(&cons.lock);
801005be:	83 ec 0c             	sub    $0xc,%esp
801005c1:	68 a0 c5 10 80       	push   $0x8010c5a0
801005c6:	e8 4d 4f 00 00       	call   80105518 <release>
801005cb:	83 c4 10             	add    $0x10,%esp
}
801005ce:	90                   	nop
801005cf:	c9                   	leave  
801005d0:	c3                   	ret    

801005d1 <panic>:

void
panic(char *s)
{
801005d1:	f3 0f 1e fb          	endbr32 
801005d5:	55                   	push   %ebp
801005d6:	89 e5                	mov    %esp,%ebp
801005d8:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005db:	e8 81 fd ff ff       	call   80100361 <cli>
  cons.locking = 0;
801005e0:	c7 05 d4 c5 10 80 00 	movl   $0x0,0x8010c5d4
801005e7:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005ea:	e8 12 2b 00 00       	call   80103101 <lapicid>
801005ef:	83 ec 08             	sub    $0x8,%esp
801005f2:	50                   	push   %eax
801005f3:	68 29 8a 10 80       	push   $0x80108a29
801005f8:	e8 1b fe ff ff       	call   80100418 <cprintf>
801005fd:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100600:	8b 45 08             	mov    0x8(%ebp),%eax
80100603:	83 ec 0c             	sub    $0xc,%esp
80100606:	50                   	push   %eax
80100607:	e8 0c fe ff ff       	call   80100418 <cprintf>
8010060c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010060f:	83 ec 0c             	sub    $0xc,%esp
80100612:	68 3d 8a 10 80       	push   $0x80108a3d
80100617:	e8 fc fd ff ff       	call   80100418 <cprintf>
8010061c:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010061f:	83 ec 08             	sub    $0x8,%esp
80100622:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100625:	50                   	push   %eax
80100626:	8d 45 08             	lea    0x8(%ebp),%eax
80100629:	50                   	push   %eax
8010062a:	e8 3f 4f 00 00       	call   8010556e <getcallerpcs>
8010062f:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100632:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100639:	eb 1c                	jmp    80100657 <panic+0x86>
    cprintf(" %p", pcs[i]);
8010063b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063e:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100642:	83 ec 08             	sub    $0x8,%esp
80100645:	50                   	push   %eax
80100646:	68 3f 8a 10 80       	push   $0x80108a3f
8010064b:	e8 c8 fd ff ff       	call   80100418 <cprintf>
80100650:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100653:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100657:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010065b:	7e de                	jle    8010063b <panic+0x6a>
  panicked = 1; // freeze other CPU
8010065d:	c7 05 80 c5 10 80 01 	movl   $0x1,0x8010c580
80100664:	00 00 00 
  for(;;)
80100667:	eb fe                	jmp    80100667 <panic+0x96>

80100669 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100669:	f3 0f 1e fb          	endbr32 
8010066d:	55                   	push   %ebp
8010066e:	89 e5                	mov    %esp,%ebp
80100670:	53                   	push   %ebx
80100671:	83 ec 14             	sub    $0x14,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100674:	6a 0e                	push   $0xe
80100676:	68 d4 03 00 00       	push   $0x3d4
8010067b:	e8 c0 fc ff ff       	call   80100340 <outb>
80100680:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100683:	68 d5 03 00 00       	push   $0x3d5
80100688:	e8 96 fc ff ff       	call   80100323 <inb>
8010068d:	83 c4 04             	add    $0x4,%esp
80100690:	0f b6 c0             	movzbl %al,%eax
80100693:	c1 e0 08             	shl    $0x8,%eax
80100696:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100699:	6a 0f                	push   $0xf
8010069b:	68 d4 03 00 00       	push   $0x3d4
801006a0:	e8 9b fc ff ff       	call   80100340 <outb>
801006a5:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
801006a8:	68 d5 03 00 00       	push   $0x3d5
801006ad:	e8 71 fc ff ff       	call   80100323 <inb>
801006b2:	83 c4 04             	add    $0x4,%esp
801006b5:	0f b6 c0             	movzbl %al,%eax
801006b8:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
801006bb:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
801006bf:	75 30                	jne    801006f1 <cgaputc+0x88>
    pos += 80 - pos%80;
801006c1:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006c4:	ba 67 66 66 66       	mov    $0x66666667,%edx
801006c9:	89 c8                	mov    %ecx,%eax
801006cb:	f7 ea                	imul   %edx
801006cd:	c1 fa 05             	sar    $0x5,%edx
801006d0:	89 c8                	mov    %ecx,%eax
801006d2:	c1 f8 1f             	sar    $0x1f,%eax
801006d5:	29 c2                	sub    %eax,%edx
801006d7:	89 d0                	mov    %edx,%eax
801006d9:	c1 e0 02             	shl    $0x2,%eax
801006dc:	01 d0                	add    %edx,%eax
801006de:	c1 e0 04             	shl    $0x4,%eax
801006e1:	29 c1                	sub    %eax,%ecx
801006e3:	89 ca                	mov    %ecx,%edx
801006e5:	b8 50 00 00 00       	mov    $0x50,%eax
801006ea:	29 d0                	sub    %edx,%eax
801006ec:	01 45 f4             	add    %eax,-0xc(%ebp)
801006ef:	eb 38                	jmp    80100729 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006f1:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006f8:	75 0c                	jne    80100706 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006fe:	7e 29                	jle    80100729 <cgaputc+0xc0>
80100700:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100704:	eb 23                	jmp    80100729 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100706:	8b 45 08             	mov    0x8(%ebp),%eax
80100709:	0f b6 c0             	movzbl %al,%eax
8010070c:	80 cc 07             	or     $0x7,%ah
8010070f:	89 c3                	mov    %eax,%ebx
80100711:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
80100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010071a:	8d 50 01             	lea    0x1(%eax),%edx
8010071d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100720:	01 c0                	add    %eax,%eax
80100722:	01 c8                	add    %ecx,%eax
80100724:	89 da                	mov    %ebx,%edx
80100726:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
80100729:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010072d:	78 09                	js     80100738 <cgaputc+0xcf>
8010072f:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100736:	7e 0d                	jle    80100745 <cgaputc+0xdc>
    panic("pos under/overflow");
80100738:	83 ec 0c             	sub    $0xc,%esp
8010073b:	68 43 8a 10 80       	push   $0x80108a43
80100740:	e8 8c fe ff ff       	call   801005d1 <panic>

  if((pos/80) >= 24){  // Scroll up.
80100745:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
8010074c:	7e 4c                	jle    8010079a <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010074e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100753:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100759:	a1 00 a0 10 80       	mov    0x8010a000,%eax
8010075e:	83 ec 04             	sub    $0x4,%esp
80100761:	68 60 0e 00 00       	push   $0xe60
80100766:	52                   	push   %edx
80100767:	50                   	push   %eax
80100768:	e8 9f 50 00 00       	call   8010580c <memmove>
8010076d:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100770:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100774:	b8 80 07 00 00       	mov    $0x780,%eax
80100779:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010077c:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010077f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100784:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100787:	01 c9                	add    %ecx,%ecx
80100789:	01 c8                	add    %ecx,%eax
8010078b:	83 ec 04             	sub    $0x4,%esp
8010078e:	52                   	push   %edx
8010078f:	6a 00                	push   $0x0
80100791:	50                   	push   %eax
80100792:	e8 ae 4f 00 00       	call   80105745 <memset>
80100797:	83 c4 10             	add    $0x10,%esp
  }

  outb(CRTPORT, 14);
8010079a:	83 ec 08             	sub    $0x8,%esp
8010079d:	6a 0e                	push   $0xe
8010079f:	68 d4 03 00 00       	push   $0x3d4
801007a4:	e8 97 fb ff ff       	call   80100340 <outb>
801007a9:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
801007ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007af:	c1 f8 08             	sar    $0x8,%eax
801007b2:	0f b6 c0             	movzbl %al,%eax
801007b5:	83 ec 08             	sub    $0x8,%esp
801007b8:	50                   	push   %eax
801007b9:	68 d5 03 00 00       	push   $0x3d5
801007be:	e8 7d fb ff ff       	call   80100340 <outb>
801007c3:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
801007c6:	83 ec 08             	sub    $0x8,%esp
801007c9:	6a 0f                	push   $0xf
801007cb:	68 d4 03 00 00       	push   $0x3d4
801007d0:	e8 6b fb ff ff       	call   80100340 <outb>
801007d5:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007db:	0f b6 c0             	movzbl %al,%eax
801007de:	83 ec 08             	sub    $0x8,%esp
801007e1:	50                   	push   %eax
801007e2:	68 d5 03 00 00       	push   $0x3d5
801007e7:	e8 54 fb ff ff       	call   80100340 <outb>
801007ec:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007ef:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801007f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007f7:	01 d2                	add    %edx,%edx
801007f9:	01 d0                	add    %edx,%eax
801007fb:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100800:	90                   	nop
80100801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100804:	c9                   	leave  
80100805:	c3                   	ret    

80100806 <consputc>:

void
consputc(int c)
{
80100806:	f3 0f 1e fb          	endbr32 
8010080a:	55                   	push   %ebp
8010080b:	89 e5                	mov    %esp,%ebp
8010080d:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100810:	a1 80 c5 10 80       	mov    0x8010c580,%eax
80100815:	85 c0                	test   %eax,%eax
80100817:	74 07                	je     80100820 <consputc+0x1a>
    cli();
80100819:	e8 43 fb ff ff       	call   80100361 <cli>
    for(;;)
8010081e:	eb fe                	jmp    8010081e <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
80100820:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100827:	75 29                	jne    80100852 <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100829:	83 ec 0c             	sub    $0xc,%esp
8010082c:	6a 08                	push   $0x8
8010082e:	e8 1f 69 00 00       	call   80107152 <uartputc>
80100833:	83 c4 10             	add    $0x10,%esp
80100836:	83 ec 0c             	sub    $0xc,%esp
80100839:	6a 20                	push   $0x20
8010083b:	e8 12 69 00 00       	call   80107152 <uartputc>
80100840:	83 c4 10             	add    $0x10,%esp
80100843:	83 ec 0c             	sub    $0xc,%esp
80100846:	6a 08                	push   $0x8
80100848:	e8 05 69 00 00       	call   80107152 <uartputc>
8010084d:	83 c4 10             	add    $0x10,%esp
80100850:	eb 0e                	jmp    80100860 <consputc+0x5a>
  } else
    uartputc(c);
80100852:	83 ec 0c             	sub    $0xc,%esp
80100855:	ff 75 08             	pushl  0x8(%ebp)
80100858:	e8 f5 68 00 00       	call   80107152 <uartputc>
8010085d:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100860:	83 ec 0c             	sub    $0xc,%esp
80100863:	ff 75 08             	pushl  0x8(%ebp)
80100866:	e8 fe fd ff ff       	call   80100669 <cgaputc>
8010086b:	83 c4 10             	add    $0x10,%esp
}
8010086e:	90                   	nop
8010086f:	c9                   	leave  
80100870:	c3                   	ret    

80100871 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100871:	f3 0f 1e fb          	endbr32 
80100875:	55                   	push   %ebp
80100876:	89 e5                	mov    %esp,%ebp
80100878:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010087b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100882:	83 ec 0c             	sub    $0xc,%esp
80100885:	68 a0 c5 10 80       	push   $0x8010c5a0
8010088a:	e8 17 4c 00 00       	call   801054a6 <acquire>
8010088f:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100892:	e9 52 01 00 00       	jmp    801009e9 <consoleintr+0x178>
    switch(c){
80100897:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010089b:	0f 84 81 00 00 00    	je     80100922 <consoleintr+0xb1>
801008a1:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801008a5:	0f 8f ac 00 00 00    	jg     80100957 <consoleintr+0xe6>
801008ab:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008af:	74 43                	je     801008f4 <consoleintr+0x83>
801008b1:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
801008b5:	0f 8f 9c 00 00 00    	jg     80100957 <consoleintr+0xe6>
801008bb:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
801008bf:	74 61                	je     80100922 <consoleintr+0xb1>
801008c1:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
801008c5:	0f 85 8c 00 00 00    	jne    80100957 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
801008cb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
801008d2:	e9 12 01 00 00       	jmp    801009e9 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008d7:	a1 28 20 11 80       	mov    0x80112028,%eax
801008dc:	83 e8 01             	sub    $0x1,%eax
801008df:	a3 28 20 11 80       	mov    %eax,0x80112028
        consputc(BACKSPACE);
801008e4:	83 ec 0c             	sub    $0xc,%esp
801008e7:	68 00 01 00 00       	push   $0x100
801008ec:	e8 15 ff ff ff       	call   80100806 <consputc>
801008f1:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008f4:	8b 15 28 20 11 80    	mov    0x80112028,%edx
801008fa:	a1 24 20 11 80       	mov    0x80112024,%eax
801008ff:	39 c2                	cmp    %eax,%edx
80100901:	0f 84 e2 00 00 00    	je     801009e9 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100907:	a1 28 20 11 80       	mov    0x80112028,%eax
8010090c:	83 e8 01             	sub    $0x1,%eax
8010090f:	83 e0 7f             	and    $0x7f,%eax
80100912:	0f b6 80 a0 1f 11 80 	movzbl -0x7feee060(%eax),%eax
      while(input.e != input.w &&
80100919:	3c 0a                	cmp    $0xa,%al
8010091b:	75 ba                	jne    801008d7 <consoleintr+0x66>
      }
      break;
8010091d:	e9 c7 00 00 00       	jmp    801009e9 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100922:	8b 15 28 20 11 80    	mov    0x80112028,%edx
80100928:	a1 24 20 11 80       	mov    0x80112024,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	0f 84 b4 00 00 00    	je     801009e9 <consoleintr+0x178>
        input.e--;
80100935:	a1 28 20 11 80       	mov    0x80112028,%eax
8010093a:	83 e8 01             	sub    $0x1,%eax
8010093d:	a3 28 20 11 80       	mov    %eax,0x80112028
        consputc(BACKSPACE);
80100942:	83 ec 0c             	sub    $0xc,%esp
80100945:	68 00 01 00 00       	push   $0x100
8010094a:	e8 b7 fe ff ff       	call   80100806 <consputc>
8010094f:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100952:	e9 92 00 00 00       	jmp    801009e9 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100957:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010095b:	0f 84 87 00 00 00    	je     801009e8 <consoleintr+0x177>
80100961:	8b 15 28 20 11 80    	mov    0x80112028,%edx
80100967:	a1 20 20 11 80       	mov    0x80112020,%eax
8010096c:	29 c2                	sub    %eax,%edx
8010096e:	89 d0                	mov    %edx,%eax
80100970:	83 f8 7f             	cmp    $0x7f,%eax
80100973:	77 73                	ja     801009e8 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100975:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100979:	74 05                	je     80100980 <consoleintr+0x10f>
8010097b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010097e:	eb 05                	jmp    80100985 <consoleintr+0x114>
80100980:	b8 0a 00 00 00       	mov    $0xa,%eax
80100985:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100988:	a1 28 20 11 80       	mov    0x80112028,%eax
8010098d:	8d 50 01             	lea    0x1(%eax),%edx
80100990:	89 15 28 20 11 80    	mov    %edx,0x80112028
80100996:	83 e0 7f             	and    $0x7f,%eax
80100999:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010099c:	88 90 a0 1f 11 80    	mov    %dl,-0x7feee060(%eax)
        consputc(c);
801009a2:	83 ec 0c             	sub    $0xc,%esp
801009a5:	ff 75 f0             	pushl  -0x10(%ebp)
801009a8:	e8 59 fe ff ff       	call   80100806 <consputc>
801009ad:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009b0:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009b4:	74 18                	je     801009ce <consoleintr+0x15d>
801009b6:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009ba:	74 12                	je     801009ce <consoleintr+0x15d>
801009bc:	a1 28 20 11 80       	mov    0x80112028,%eax
801009c1:	8b 15 20 20 11 80    	mov    0x80112020,%edx
801009c7:	83 ea 80             	sub    $0xffffff80,%edx
801009ca:	39 d0                	cmp    %edx,%eax
801009cc:	75 1a                	jne    801009e8 <consoleintr+0x177>
          input.w = input.e;
801009ce:	a1 28 20 11 80       	mov    0x80112028,%eax
801009d3:	a3 24 20 11 80       	mov    %eax,0x80112024
          wakeup(&input.r);
801009d8:	83 ec 0c             	sub    $0xc,%esp
801009db:	68 20 20 11 80       	push   $0x80112020
801009e0:	e8 91 46 00 00       	call   80105076 <wakeup>
801009e5:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009e8:	90                   	nop
  while((c = getc()) >= 0){
801009e9:	8b 45 08             	mov    0x8(%ebp),%eax
801009ec:	ff d0                	call   *%eax
801009ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009f1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009f5:	0f 89 9c fe ff ff    	jns    80100897 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
801009fb:	83 ec 0c             	sub    $0xc,%esp
801009fe:	68 a0 c5 10 80       	push   $0x8010c5a0
80100a03:	e8 10 4b 00 00       	call   80105518 <release>
80100a08:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100a0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a0f:	74 05                	je     80100a16 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
80100a11:	e8 36 47 00 00       	call   8010514c <procdump>
  }
}
80100a16:	90                   	nop
80100a17:	c9                   	leave  
80100a18:	c3                   	ret    

80100a19 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a19:	f3 0f 1e fb          	endbr32 
80100a1d:	55                   	push   %ebp
80100a1e:	89 e5                	mov    %esp,%ebp
80100a20:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a23:	83 ec 0c             	sub    $0xc,%esp
80100a26:	ff 75 08             	pushl  0x8(%ebp)
80100a29:	e8 8d 11 00 00       	call   80101bbb <iunlock>
80100a2e:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a31:	8b 45 10             	mov    0x10(%ebp),%eax
80100a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a37:	83 ec 0c             	sub    $0xc,%esp
80100a3a:	68 a0 c5 10 80       	push   $0x8010c5a0
80100a3f:	e8 62 4a 00 00       	call   801054a6 <acquire>
80100a44:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a47:	e9 ab 00 00 00       	jmp    80100af7 <consoleread+0xde>
    while(input.r == input.w){
      if(myproc()->killed){
80100a4c:	e8 e0 39 00 00       	call   80104431 <myproc>
80100a51:	8b 40 24             	mov    0x24(%eax),%eax
80100a54:	85 c0                	test   %eax,%eax
80100a56:	74 28                	je     80100a80 <consoleread+0x67>
        release(&cons.lock);
80100a58:	83 ec 0c             	sub    $0xc,%esp
80100a5b:	68 a0 c5 10 80       	push   $0x8010c5a0
80100a60:	e8 b3 4a 00 00       	call   80105518 <release>
80100a65:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a68:	83 ec 0c             	sub    $0xc,%esp
80100a6b:	ff 75 08             	pushl  0x8(%ebp)
80100a6e:	e8 31 10 00 00       	call   80101aa4 <ilock>
80100a73:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a7b:	e9 ab 00 00 00       	jmp    80100b2b <consoleread+0x112>
      }
      sleep(&input.r, &cons.lock);
80100a80:	83 ec 08             	sub    $0x8,%esp
80100a83:	68 a0 c5 10 80       	push   $0x8010c5a0
80100a88:	68 20 20 11 80       	push   $0x80112020
80100a8d:	e8 b7 44 00 00       	call   80104f49 <sleep>
80100a92:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a95:	8b 15 20 20 11 80    	mov    0x80112020,%edx
80100a9b:	a1 24 20 11 80       	mov    0x80112024,%eax
80100aa0:	39 c2                	cmp    %eax,%edx
80100aa2:	74 a8                	je     80100a4c <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100aa4:	a1 20 20 11 80       	mov    0x80112020,%eax
80100aa9:	8d 50 01             	lea    0x1(%eax),%edx
80100aac:	89 15 20 20 11 80    	mov    %edx,0x80112020
80100ab2:	83 e0 7f             	and    $0x7f,%eax
80100ab5:	0f b6 80 a0 1f 11 80 	movzbl -0x7feee060(%eax),%eax
80100abc:	0f be c0             	movsbl %al,%eax
80100abf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100ac2:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ac6:	75 17                	jne    80100adf <consoleread+0xc6>
      if(n < target){
80100ac8:	8b 45 10             	mov    0x10(%ebp),%eax
80100acb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100ace:	76 2f                	jbe    80100aff <consoleread+0xe6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100ad0:	a1 20 20 11 80       	mov    0x80112020,%eax
80100ad5:	83 e8 01             	sub    $0x1,%eax
80100ad8:	a3 20 20 11 80       	mov    %eax,0x80112020
      }
      break;
80100add:	eb 20                	jmp    80100aff <consoleread+0xe6>
    }
    *dst++ = c;
80100adf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ae2:	8d 50 01             	lea    0x1(%eax),%edx
80100ae5:	89 55 0c             	mov    %edx,0xc(%ebp)
80100ae8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100aeb:	88 10                	mov    %dl,(%eax)
    --n;
80100aed:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100af1:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100af5:	74 0b                	je     80100b02 <consoleread+0xe9>
  while(n > 0){
80100af7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100afb:	7f 98                	jg     80100a95 <consoleread+0x7c>
80100afd:	eb 04                	jmp    80100b03 <consoleread+0xea>
      break;
80100aff:	90                   	nop
80100b00:	eb 01                	jmp    80100b03 <consoleread+0xea>
      break;
80100b02:	90                   	nop
  }
  release(&cons.lock);
80100b03:	83 ec 0c             	sub    $0xc,%esp
80100b06:	68 a0 c5 10 80       	push   $0x8010c5a0
80100b0b:	e8 08 4a 00 00       	call   80105518 <release>
80100b10:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	ff 75 08             	pushl  0x8(%ebp)
80100b19:	e8 86 0f 00 00       	call   80101aa4 <ilock>
80100b1e:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b21:	8b 45 10             	mov    0x10(%ebp),%eax
80100b24:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b27:	29 c2                	sub    %eax,%edx
80100b29:	89 d0                	mov    %edx,%eax
}
80100b2b:	c9                   	leave  
80100b2c:	c3                   	ret    

80100b2d <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b2d:	f3 0f 1e fb          	endbr32 
80100b31:	55                   	push   %ebp
80100b32:	89 e5                	mov    %esp,%ebp
80100b34:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	ff 75 08             	pushl  0x8(%ebp)
80100b3d:	e8 79 10 00 00       	call   80101bbb <iunlock>
80100b42:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b45:	83 ec 0c             	sub    $0xc,%esp
80100b48:	68 a0 c5 10 80       	push   $0x8010c5a0
80100b4d:	e8 54 49 00 00       	call   801054a6 <acquire>
80100b52:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b5c:	eb 21                	jmp    80100b7f <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b61:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b64:	01 d0                	add    %edx,%eax
80100b66:	0f b6 00             	movzbl (%eax),%eax
80100b69:	0f be c0             	movsbl %al,%eax
80100b6c:	0f b6 c0             	movzbl %al,%eax
80100b6f:	83 ec 0c             	sub    $0xc,%esp
80100b72:	50                   	push   %eax
80100b73:	e8 8e fc ff ff       	call   80100806 <consputc>
80100b78:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b7b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b82:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b85:	7c d7                	jl     80100b5e <consolewrite+0x31>
  release(&cons.lock);
80100b87:	83 ec 0c             	sub    $0xc,%esp
80100b8a:	68 a0 c5 10 80       	push   $0x8010c5a0
80100b8f:	e8 84 49 00 00       	call   80105518 <release>
80100b94:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b97:	83 ec 0c             	sub    $0xc,%esp
80100b9a:	ff 75 08             	pushl  0x8(%ebp)
80100b9d:	e8 02 0f 00 00       	call   80101aa4 <ilock>
80100ba2:	83 c4 10             	add    $0x10,%esp

  return n;
80100ba5:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ba8:	c9                   	leave  
80100ba9:	c3                   	ret    

80100baa <consoleinit>:

void
consoleinit(void)
{
80100baa:	f3 0f 1e fb          	endbr32 
80100bae:	55                   	push   %ebp
80100baf:	89 e5                	mov    %esp,%ebp
80100bb1:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bb4:	83 ec 08             	sub    $0x8,%esp
80100bb7:	68 56 8a 10 80       	push   $0x80108a56
80100bbc:	68 a0 c5 10 80       	push   $0x8010c5a0
80100bc1:	e8 ba 48 00 00       	call   80105480 <initlock>
80100bc6:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100bc9:	c7 05 ec 29 11 80 2d 	movl   $0x80100b2d,0x801129ec
80100bd0:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bd3:	c7 05 e8 29 11 80 19 	movl   $0x80100a19,0x801129e8
80100bda:	0a 10 80 
  cons.locking = 1;
80100bdd:	c7 05 d4 c5 10 80 01 	movl   $0x1,0x8010c5d4
80100be4:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100be7:	83 ec 08             	sub    $0x8,%esp
80100bea:	6a 00                	push   $0x0
80100bec:	6a 01                	push   $0x1
80100bee:	e8 1b 20 00 00       	call   80102c0e <ioapicenable>
80100bf3:	83 c4 10             	add    $0x10,%esp
}
80100bf6:	90                   	nop
80100bf7:	c9                   	leave  
80100bf8:	c3                   	ret    

80100bf9 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bf9:	f3 0f 1e fb          	endbr32 
80100bfd:	55                   	push   %ebp
80100bfe:	89 e5                	mov    %esp,%ebp
80100c00:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c06:	e8 26 38 00 00       	call   80104431 <myproc>
80100c0b:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c0e:	e8 60 2a 00 00       	call   80103673 <begin_op>

  if((ip = namei(path)) == 0){
80100c13:	83 ec 0c             	sub    $0xc,%esp
80100c16:	ff 75 08             	pushl  0x8(%ebp)
80100c19:	e8 f1 19 00 00       	call   8010260f <namei>
80100c1e:	83 c4 10             	add    $0x10,%esp
80100c21:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c24:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c28:	75 1f                	jne    80100c49 <exec+0x50>
    end_op();
80100c2a:	e8 d4 2a 00 00       	call   80103703 <end_op>
    cprintf("exec: fail\n");
80100c2f:	83 ec 0c             	sub    $0xc,%esp
80100c32:	68 5e 8a 10 80       	push   $0x80108a5e
80100c37:	e8 dc f7 ff ff       	call   80100418 <cprintf>
80100c3c:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c44:	e9 f1 03 00 00       	jmp    8010103a <exec+0x441>
  }
  ilock(ip);
80100c49:	83 ec 0c             	sub    $0xc,%esp
80100c4c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c4f:	e8 50 0e 00 00       	call   80101aa4 <ilock>
80100c54:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c57:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c5e:	6a 34                	push   $0x34
80100c60:	6a 00                	push   $0x0
80100c62:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c68:	50                   	push   %eax
80100c69:	ff 75 d8             	pushl  -0x28(%ebp)
80100c6c:	e8 3b 13 00 00       	call   80101fac <readi>
80100c71:	83 c4 10             	add    $0x10,%esp
80100c74:	83 f8 34             	cmp    $0x34,%eax
80100c77:	0f 85 66 03 00 00    	jne    80100fe3 <exec+0x3ea>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c7d:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c83:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c88:	0f 85 58 03 00 00    	jne    80100fe6 <exec+0x3ed>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c8e:	e8 d3 74 00 00       	call   80108166 <setupkvm>
80100c93:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c96:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c9a:	0f 84 49 03 00 00    	je     80100fe9 <exec+0x3f0>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ca0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ca7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cae:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100cb4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cb7:	e9 de 00 00 00       	jmp    80100d9a <exec+0x1a1>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbf:	6a 20                	push   $0x20
80100cc1:	50                   	push   %eax
80100cc2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100cc8:	50                   	push   %eax
80100cc9:	ff 75 d8             	pushl  -0x28(%ebp)
80100ccc:	e8 db 12 00 00       	call   80101fac <readi>
80100cd1:	83 c4 10             	add    $0x10,%esp
80100cd4:	83 f8 20             	cmp    $0x20,%eax
80100cd7:	0f 85 0f 03 00 00    	jne    80100fec <exec+0x3f3>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100cdd:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100ce3:	83 f8 01             	cmp    $0x1,%eax
80100ce6:	0f 85 a0 00 00 00    	jne    80100d8c <exec+0x193>
      continue;
    if(ph.memsz < ph.filesz)
80100cec:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cf2:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100cf8:	39 c2                	cmp    %eax,%edx
80100cfa:	0f 82 ef 02 00 00    	jb     80100fef <exec+0x3f6>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d00:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d06:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d0c:	01 c2                	add    %eax,%edx
80100d0e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d14:	39 c2                	cmp    %eax,%edx
80100d16:	0f 82 d6 02 00 00    	jb     80100ff2 <exec+0x3f9>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d1c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d22:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d28:	01 d0                	add    %edx,%eax
80100d2a:	83 ec 04             	sub    $0x4,%esp
80100d2d:	50                   	push   %eax
80100d2e:	ff 75 e0             	pushl  -0x20(%ebp)
80100d31:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d34:	e8 eb 77 00 00       	call   80108524 <allocuvm>
80100d39:	83 c4 10             	add    $0x10,%esp
80100d3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d43:	0f 84 ac 02 00 00    	je     80100ff5 <exec+0x3fc>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100d49:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d4f:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d54:	85 c0                	test   %eax,%eax
80100d56:	0f 85 9c 02 00 00    	jne    80100ff8 <exec+0x3ff>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d5c:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d62:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d68:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d6e:	83 ec 0c             	sub    $0xc,%esp
80100d71:	52                   	push   %edx
80100d72:	50                   	push   %eax
80100d73:	ff 75 d8             	pushl  -0x28(%ebp)
80100d76:	51                   	push   %ecx
80100d77:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d7a:	e8 d4 76 00 00       	call   80108453 <loaduvm>
80100d7f:	83 c4 20             	add    $0x20,%esp
80100d82:	85 c0                	test   %eax,%eax
80100d84:	0f 88 71 02 00 00    	js     80100ffb <exec+0x402>
80100d8a:	eb 01                	jmp    80100d8d <exec+0x194>
      continue;
80100d8c:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d8d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d91:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d94:	83 c0 20             	add    $0x20,%eax
80100d97:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d9a:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100da1:	0f b7 c0             	movzwl %ax,%eax
80100da4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100da7:	0f 8c 0f ff ff ff    	jl     80100cbc <exec+0xc3>
      goto bad;
  }
  iunlockput(ip);
80100dad:	83 ec 0c             	sub    $0xc,%esp
80100db0:	ff 75 d8             	pushl  -0x28(%ebp)
80100db3:	e8 29 0f 00 00       	call   80101ce1 <iunlockput>
80100db8:	83 c4 10             	add    $0x10,%esp
  end_op();
80100dbb:	e8 43 29 00 00       	call   80103703 <end_op>
  ip = 0;
80100dc0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100dc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dca:	05 ff 0f 00 00       	add    $0xfff,%eax
80100dcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100dd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100dd7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100dda:	05 00 20 00 00       	add    $0x2000,%eax
80100ddf:	83 ec 04             	sub    $0x4,%esp
80100de2:	50                   	push   %eax
80100de3:	ff 75 e0             	pushl  -0x20(%ebp)
80100de6:	ff 75 d4             	pushl  -0x2c(%ebp)
80100de9:	e8 36 77 00 00       	call   80108524 <allocuvm>
80100dee:	83 c4 10             	add    $0x10,%esp
80100df1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100df4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100df8:	0f 84 00 02 00 00    	je     80100ffe <exec+0x405>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e01:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e06:	83 ec 08             	sub    $0x8,%esp
80100e09:	50                   	push   %eax
80100e0a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e0d:	e8 80 79 00 00       	call   80108792 <clearpteu>
80100e12:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100e15:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e18:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e1b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e22:	e9 96 00 00 00       	jmp    80100ebd <exec+0x2c4>
    if(argc >= MAXARG)
80100e27:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e2b:	0f 87 d0 01 00 00    	ja     80101001 <exec+0x408>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e34:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e3e:	01 d0                	add    %edx,%eax
80100e40:	8b 00                	mov    (%eax),%eax
80100e42:	83 ec 0c             	sub    $0xc,%esp
80100e45:	50                   	push   %eax
80100e46:	e8 63 4b 00 00       	call   801059ae <strlen>
80100e4b:	83 c4 10             	add    $0x10,%esp
80100e4e:	89 c2                	mov    %eax,%edx
80100e50:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e53:	29 d0                	sub    %edx,%eax
80100e55:	83 e8 01             	sub    $0x1,%eax
80100e58:	83 e0 fc             	and    $0xfffffffc,%eax
80100e5b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e61:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e68:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e6b:	01 d0                	add    %edx,%eax
80100e6d:	8b 00                	mov    (%eax),%eax
80100e6f:	83 ec 0c             	sub    $0xc,%esp
80100e72:	50                   	push   %eax
80100e73:	e8 36 4b 00 00       	call   801059ae <strlen>
80100e78:	83 c4 10             	add    $0x10,%esp
80100e7b:	83 c0 01             	add    $0x1,%eax
80100e7e:	89 c1                	mov    %eax,%ecx
80100e80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e8d:	01 d0                	add    %edx,%eax
80100e8f:	8b 00                	mov    (%eax),%eax
80100e91:	51                   	push   %ecx
80100e92:	50                   	push   %eax
80100e93:	ff 75 dc             	pushl  -0x24(%ebp)
80100e96:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e99:	e8 ac 7a 00 00       	call   8010894a <copyout>
80100e9e:	83 c4 10             	add    $0x10,%esp
80100ea1:	85 c0                	test   %eax,%eax
80100ea3:	0f 88 5b 01 00 00    	js     80101004 <exec+0x40b>
      goto bad;
    ustack[3+argc] = sp;
80100ea9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eac:	8d 50 03             	lea    0x3(%eax),%edx
80100eaf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100eb2:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100eb9:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100ebd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eca:	01 d0                	add    %edx,%eax
80100ecc:	8b 00                	mov    (%eax),%eax
80100ece:	85 c0                	test   %eax,%eax
80100ed0:	0f 85 51 ff ff ff    	jne    80100e27 <exec+0x22e>
  }
  ustack[3+argc] = 0;
80100ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed9:	83 c0 03             	add    $0x3,%eax
80100edc:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100ee3:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ee7:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100eee:	ff ff ff 
  ustack[1] = argc;
80100ef1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef4:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efd:	83 c0 01             	add    $0x1,%eax
80100f00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f0a:	29 d0                	sub    %edx,%eax
80100f0c:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	83 c0 04             	add    $0x4,%eax
80100f18:	c1 e0 02             	shl    $0x2,%eax
80100f1b:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f21:	83 c0 04             	add    $0x4,%eax
80100f24:	c1 e0 02             	shl    $0x2,%eax
80100f27:	50                   	push   %eax
80100f28:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f2e:	50                   	push   %eax
80100f2f:	ff 75 dc             	pushl  -0x24(%ebp)
80100f32:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f35:	e8 10 7a 00 00       	call   8010894a <copyout>
80100f3a:	83 c4 10             	add    $0x10,%esp
80100f3d:	85 c0                	test   %eax,%eax
80100f3f:	0f 88 c2 00 00 00    	js     80101007 <exec+0x40e>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f45:	8b 45 08             	mov    0x8(%ebp),%eax
80100f48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f51:	eb 17                	jmp    80100f6a <exec+0x371>
    if(*s == '/')
80100f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f56:	0f b6 00             	movzbl (%eax),%eax
80100f59:	3c 2f                	cmp    $0x2f,%al
80100f5b:	75 09                	jne    80100f66 <exec+0x36d>
      last = s+1;
80100f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f60:	83 c0 01             	add    $0x1,%eax
80100f63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100f66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f6d:	0f b6 00             	movzbl (%eax),%eax
80100f70:	84 c0                	test   %al,%al
80100f72:	75 df                	jne    80100f53 <exec+0x35a>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f74:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f77:	83 c0 6c             	add    $0x6c,%eax
80100f7a:	83 ec 04             	sub    $0x4,%esp
80100f7d:	6a 10                	push   $0x10
80100f7f:	ff 75 f0             	pushl  -0x10(%ebp)
80100f82:	50                   	push   %eax
80100f83:	e8 d8 49 00 00       	call   80105960 <safestrcpy>
80100f88:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f8b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f8e:	8b 40 04             	mov    0x4(%eax),%eax
80100f91:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f94:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f9a:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fa3:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fa5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fa8:	8b 40 18             	mov    0x18(%eax),%eax
80100fab:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100fb1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100fb4:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fb7:	8b 40 18             	mov    0x18(%eax),%eax
80100fba:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100fbd:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100fc0:	83 ec 0c             	sub    $0xc,%esp
80100fc3:	ff 75 d0             	pushl  -0x30(%ebp)
80100fc6:	e8 71 72 00 00       	call   8010823c <switchuvm>
80100fcb:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fce:	83 ec 0c             	sub    $0xc,%esp
80100fd1:	ff 75 cc             	pushl  -0x34(%ebp)
80100fd4:	e8 1c 77 00 00       	call   801086f5 <freevm>
80100fd9:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fdc:	b8 00 00 00 00       	mov    $0x0,%eax
80100fe1:	eb 57                	jmp    8010103a <exec+0x441>
    goto bad;
80100fe3:	90                   	nop
80100fe4:	eb 22                	jmp    80101008 <exec+0x40f>
    goto bad;
80100fe6:	90                   	nop
80100fe7:	eb 1f                	jmp    80101008 <exec+0x40f>
    goto bad;
80100fe9:	90                   	nop
80100fea:	eb 1c                	jmp    80101008 <exec+0x40f>
      goto bad;
80100fec:	90                   	nop
80100fed:	eb 19                	jmp    80101008 <exec+0x40f>
      goto bad;
80100fef:	90                   	nop
80100ff0:	eb 16                	jmp    80101008 <exec+0x40f>
      goto bad;
80100ff2:	90                   	nop
80100ff3:	eb 13                	jmp    80101008 <exec+0x40f>
      goto bad;
80100ff5:	90                   	nop
80100ff6:	eb 10                	jmp    80101008 <exec+0x40f>
      goto bad;
80100ff8:	90                   	nop
80100ff9:	eb 0d                	jmp    80101008 <exec+0x40f>
      goto bad;
80100ffb:	90                   	nop
80100ffc:	eb 0a                	jmp    80101008 <exec+0x40f>
    goto bad;
80100ffe:	90                   	nop
80100fff:	eb 07                	jmp    80101008 <exec+0x40f>
      goto bad;
80101001:	90                   	nop
80101002:	eb 04                	jmp    80101008 <exec+0x40f>
      goto bad;
80101004:	90                   	nop
80101005:	eb 01                	jmp    80101008 <exec+0x40f>
    goto bad;
80101007:	90                   	nop

 bad:
  if(pgdir)
80101008:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010100c:	74 0e                	je     8010101c <exec+0x423>
    freevm(pgdir);
8010100e:	83 ec 0c             	sub    $0xc,%esp
80101011:	ff 75 d4             	pushl  -0x2c(%ebp)
80101014:	e8 dc 76 00 00       	call   801086f5 <freevm>
80101019:	83 c4 10             	add    $0x10,%esp
  if(ip){
8010101c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101020:	74 13                	je     80101035 <exec+0x43c>
    iunlockput(ip);
80101022:	83 ec 0c             	sub    $0xc,%esp
80101025:	ff 75 d8             	pushl  -0x28(%ebp)
80101028:	e8 b4 0c 00 00       	call   80101ce1 <iunlockput>
8010102d:	83 c4 10             	add    $0x10,%esp
    end_op();
80101030:	e8 ce 26 00 00       	call   80103703 <end_op>
  }
  return -1;
80101035:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010103a:	c9                   	leave  
8010103b:	c3                   	ret    

8010103c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
8010103c:	f3 0f 1e fb          	endbr32 
80101040:	55                   	push   %ebp
80101041:	89 e5                	mov    %esp,%ebp
80101043:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80101046:	83 ec 08             	sub    $0x8,%esp
80101049:	68 6a 8a 10 80       	push   $0x80108a6a
8010104e:	68 40 20 11 80       	push   $0x80112040
80101053:	e8 28 44 00 00       	call   80105480 <initlock>
80101058:	83 c4 10             	add    $0x10,%esp
}
8010105b:	90                   	nop
8010105c:	c9                   	leave  
8010105d:	c3                   	ret    

8010105e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
8010105e:	f3 0f 1e fb          	endbr32 
80101062:	55                   	push   %ebp
80101063:	89 e5                	mov    %esp,%ebp
80101065:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101068:	83 ec 0c             	sub    $0xc,%esp
8010106b:	68 40 20 11 80       	push   $0x80112040
80101070:	e8 31 44 00 00       	call   801054a6 <acquire>
80101075:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101078:	c7 45 f4 74 20 11 80 	movl   $0x80112074,-0xc(%ebp)
8010107f:	eb 2d                	jmp    801010ae <filealloc+0x50>
    if(f->ref == 0){
80101081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	85 c0                	test   %eax,%eax
80101089:	75 1f                	jne    801010aa <filealloc+0x4c>
      f->ref = 1;
8010108b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101095:	83 ec 0c             	sub    $0xc,%esp
80101098:	68 40 20 11 80       	push   $0x80112040
8010109d:	e8 76 44 00 00       	call   80105518 <release>
801010a2:	83 c4 10             	add    $0x10,%esp
      return f;
801010a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a8:	eb 23                	jmp    801010cd <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010aa:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010ae:	b8 d4 29 11 80       	mov    $0x801129d4,%eax
801010b3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801010b6:	72 c9                	jb     80101081 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 40 20 11 80       	push   $0x80112040
801010c0:	e8 53 44 00 00       	call   80105518 <release>
801010c5:	83 c4 10             	add    $0x10,%esp
  return 0;
801010c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010cd:	c9                   	leave  
801010ce:	c3                   	ret    

801010cf <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010cf:	f3 0f 1e fb          	endbr32 
801010d3:	55                   	push   %ebp
801010d4:	89 e5                	mov    %esp,%ebp
801010d6:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010d9:	83 ec 0c             	sub    $0xc,%esp
801010dc:	68 40 20 11 80       	push   $0x80112040
801010e1:	e8 c0 43 00 00       	call   801054a6 <acquire>
801010e6:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010e9:	8b 45 08             	mov    0x8(%ebp),%eax
801010ec:	8b 40 04             	mov    0x4(%eax),%eax
801010ef:	85 c0                	test   %eax,%eax
801010f1:	7f 0d                	jg     80101100 <filedup+0x31>
    panic("filedup");
801010f3:	83 ec 0c             	sub    $0xc,%esp
801010f6:	68 71 8a 10 80       	push   $0x80108a71
801010fb:	e8 d1 f4 ff ff       	call   801005d1 <panic>
  f->ref++;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 40 04             	mov    0x4(%eax),%eax
80101106:	8d 50 01             	lea    0x1(%eax),%edx
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010110f:	83 ec 0c             	sub    $0xc,%esp
80101112:	68 40 20 11 80       	push   $0x80112040
80101117:	e8 fc 43 00 00       	call   80105518 <release>
8010111c:	83 c4 10             	add    $0x10,%esp
  return f;
8010111f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101122:	c9                   	leave  
80101123:	c3                   	ret    

80101124 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101124:	f3 0f 1e fb          	endbr32 
80101128:	55                   	push   %ebp
80101129:	89 e5                	mov    %esp,%ebp
8010112b:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010112e:	83 ec 0c             	sub    $0xc,%esp
80101131:	68 40 20 11 80       	push   $0x80112040
80101136:	e8 6b 43 00 00       	call   801054a6 <acquire>
8010113b:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010113e:	8b 45 08             	mov    0x8(%ebp),%eax
80101141:	8b 40 04             	mov    0x4(%eax),%eax
80101144:	85 c0                	test   %eax,%eax
80101146:	7f 0d                	jg     80101155 <fileclose+0x31>
    panic("fileclose");
80101148:	83 ec 0c             	sub    $0xc,%esp
8010114b:	68 79 8a 10 80       	push   $0x80108a79
80101150:	e8 7c f4 ff ff       	call   801005d1 <panic>
  if(--f->ref > 0){
80101155:	8b 45 08             	mov    0x8(%ebp),%eax
80101158:	8b 40 04             	mov    0x4(%eax),%eax
8010115b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010115e:	8b 45 08             	mov    0x8(%ebp),%eax
80101161:	89 50 04             	mov    %edx,0x4(%eax)
80101164:	8b 45 08             	mov    0x8(%ebp),%eax
80101167:	8b 40 04             	mov    0x4(%eax),%eax
8010116a:	85 c0                	test   %eax,%eax
8010116c:	7e 15                	jle    80101183 <fileclose+0x5f>
    release(&ftable.lock);
8010116e:	83 ec 0c             	sub    $0xc,%esp
80101171:	68 40 20 11 80       	push   $0x80112040
80101176:	e8 9d 43 00 00       	call   80105518 <release>
8010117b:	83 c4 10             	add    $0x10,%esp
8010117e:	e9 8b 00 00 00       	jmp    8010120e <fileclose+0xea>
    return;
  }
  ff = *f;
80101183:	8b 45 08             	mov    0x8(%ebp),%eax
80101186:	8b 10                	mov    (%eax),%edx
80101188:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010118b:	8b 50 04             	mov    0x4(%eax),%edx
8010118e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101191:	8b 50 08             	mov    0x8(%eax),%edx
80101194:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101197:	8b 50 0c             	mov    0xc(%eax),%edx
8010119a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010119d:	8b 50 10             	mov    0x10(%eax),%edx
801011a0:	89 55 f0             	mov    %edx,-0x10(%ebp)
801011a3:	8b 40 14             	mov    0x14(%eax),%eax
801011a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801011a9:	8b 45 08             	mov    0x8(%ebp),%eax
801011ac:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011b3:	8b 45 08             	mov    0x8(%ebp),%eax
801011b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011bc:	83 ec 0c             	sub    $0xc,%esp
801011bf:	68 40 20 11 80       	push   $0x80112040
801011c4:	e8 4f 43 00 00       	call   80105518 <release>
801011c9:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
801011cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011cf:	83 f8 01             	cmp    $0x1,%eax
801011d2:	75 19                	jne    801011ed <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
801011d4:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011d8:	0f be d0             	movsbl %al,%edx
801011db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011de:	83 ec 08             	sub    $0x8,%esp
801011e1:	52                   	push   %edx
801011e2:	50                   	push   %eax
801011e3:	e8 c0 2e 00 00       	call   801040a8 <pipeclose>
801011e8:	83 c4 10             	add    $0x10,%esp
801011eb:	eb 21                	jmp    8010120e <fileclose+0xea>
  else if(ff.type == FD_INODE){
801011ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011f0:	83 f8 02             	cmp    $0x2,%eax
801011f3:	75 19                	jne    8010120e <fileclose+0xea>
    begin_op();
801011f5:	e8 79 24 00 00       	call   80103673 <begin_op>
    iput(ff.ip);
801011fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011fd:	83 ec 0c             	sub    $0xc,%esp
80101200:	50                   	push   %eax
80101201:	e8 07 0a 00 00       	call   80101c0d <iput>
80101206:	83 c4 10             	add    $0x10,%esp
    end_op();
80101209:	e8 f5 24 00 00       	call   80103703 <end_op>
  }
}
8010120e:	c9                   	leave  
8010120f:	c3                   	ret    

80101210 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101210:	f3 0f 1e fb          	endbr32 
80101214:	55                   	push   %ebp
80101215:	89 e5                	mov    %esp,%ebp
80101217:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010121a:	8b 45 08             	mov    0x8(%ebp),%eax
8010121d:	8b 00                	mov    (%eax),%eax
8010121f:	83 f8 02             	cmp    $0x2,%eax
80101222:	75 40                	jne    80101264 <filestat+0x54>
    ilock(f->ip);
80101224:	8b 45 08             	mov    0x8(%ebp),%eax
80101227:	8b 40 10             	mov    0x10(%eax),%eax
8010122a:	83 ec 0c             	sub    $0xc,%esp
8010122d:	50                   	push   %eax
8010122e:	e8 71 08 00 00       	call   80101aa4 <ilock>
80101233:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101236:	8b 45 08             	mov    0x8(%ebp),%eax
80101239:	8b 40 10             	mov    0x10(%eax),%eax
8010123c:	83 ec 08             	sub    $0x8,%esp
8010123f:	ff 75 0c             	pushl  0xc(%ebp)
80101242:	50                   	push   %eax
80101243:	e8 1a 0d 00 00       	call   80101f62 <stati>
80101248:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010124b:	8b 45 08             	mov    0x8(%ebp),%eax
8010124e:	8b 40 10             	mov    0x10(%eax),%eax
80101251:	83 ec 0c             	sub    $0xc,%esp
80101254:	50                   	push   %eax
80101255:	e8 61 09 00 00       	call   80101bbb <iunlock>
8010125a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010125d:	b8 00 00 00 00       	mov    $0x0,%eax
80101262:	eb 05                	jmp    80101269 <filestat+0x59>
  }
  return -1;
80101264:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101269:	c9                   	leave  
8010126a:	c3                   	ret    

8010126b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010126b:	f3 0f 1e fb          	endbr32 
8010126f:	55                   	push   %ebp
80101270:	89 e5                	mov    %esp,%ebp
80101272:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101275:	8b 45 08             	mov    0x8(%ebp),%eax
80101278:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010127c:	84 c0                	test   %al,%al
8010127e:	75 0a                	jne    8010128a <fileread+0x1f>
    return -1;
80101280:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101285:	e9 9b 00 00 00       	jmp    80101325 <fileread+0xba>
  if(f->type == FD_PIPE)
8010128a:	8b 45 08             	mov    0x8(%ebp),%eax
8010128d:	8b 00                	mov    (%eax),%eax
8010128f:	83 f8 01             	cmp    $0x1,%eax
80101292:	75 1a                	jne    801012ae <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101294:	8b 45 08             	mov    0x8(%ebp),%eax
80101297:	8b 40 0c             	mov    0xc(%eax),%eax
8010129a:	83 ec 04             	sub    $0x4,%esp
8010129d:	ff 75 10             	pushl  0x10(%ebp)
801012a0:	ff 75 0c             	pushl  0xc(%ebp)
801012a3:	50                   	push   %eax
801012a4:	e8 b4 2f 00 00       	call   8010425d <piperead>
801012a9:	83 c4 10             	add    $0x10,%esp
801012ac:	eb 77                	jmp    80101325 <fileread+0xba>
  if(f->type == FD_INODE){
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 00                	mov    (%eax),%eax
801012b3:	83 f8 02             	cmp    $0x2,%eax
801012b6:	75 60                	jne    80101318 <fileread+0xad>
    ilock(f->ip);
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 40 10             	mov    0x10(%eax),%eax
801012be:	83 ec 0c             	sub    $0xc,%esp
801012c1:	50                   	push   %eax
801012c2:	e8 dd 07 00 00       	call   80101aa4 <ilock>
801012c7:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012cd:	8b 45 08             	mov    0x8(%ebp),%eax
801012d0:	8b 50 14             	mov    0x14(%eax),%edx
801012d3:	8b 45 08             	mov    0x8(%ebp),%eax
801012d6:	8b 40 10             	mov    0x10(%eax),%eax
801012d9:	51                   	push   %ecx
801012da:	52                   	push   %edx
801012db:	ff 75 0c             	pushl  0xc(%ebp)
801012de:	50                   	push   %eax
801012df:	e8 c8 0c 00 00       	call   80101fac <readi>
801012e4:	83 c4 10             	add    $0x10,%esp
801012e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012ee:	7e 11                	jle    80101301 <fileread+0x96>
      f->off += r;
801012f0:	8b 45 08             	mov    0x8(%ebp),%eax
801012f3:	8b 50 14             	mov    0x14(%eax),%edx
801012f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012f9:	01 c2                	add    %eax,%edx
801012fb:	8b 45 08             	mov    0x8(%ebp),%eax
801012fe:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101301:	8b 45 08             	mov    0x8(%ebp),%eax
80101304:	8b 40 10             	mov    0x10(%eax),%eax
80101307:	83 ec 0c             	sub    $0xc,%esp
8010130a:	50                   	push   %eax
8010130b:	e8 ab 08 00 00       	call   80101bbb <iunlock>
80101310:	83 c4 10             	add    $0x10,%esp
    return r;
80101313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101316:	eb 0d                	jmp    80101325 <fileread+0xba>
  }
  panic("fileread");
80101318:	83 ec 0c             	sub    $0xc,%esp
8010131b:	68 83 8a 10 80       	push   $0x80108a83
80101320:	e8 ac f2 ff ff       	call   801005d1 <panic>
}
80101325:	c9                   	leave  
80101326:	c3                   	ret    

80101327 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101327:	f3 0f 1e fb          	endbr32 
8010132b:	55                   	push   %ebp
8010132c:	89 e5                	mov    %esp,%ebp
8010132e:	53                   	push   %ebx
8010132f:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101332:	8b 45 08             	mov    0x8(%ebp),%eax
80101335:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101339:	84 c0                	test   %al,%al
8010133b:	75 0a                	jne    80101347 <filewrite+0x20>
    return -1;
8010133d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101342:	e9 1b 01 00 00       	jmp    80101462 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101347:	8b 45 08             	mov    0x8(%ebp),%eax
8010134a:	8b 00                	mov    (%eax),%eax
8010134c:	83 f8 01             	cmp    $0x1,%eax
8010134f:	75 1d                	jne    8010136e <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101351:	8b 45 08             	mov    0x8(%ebp),%eax
80101354:	8b 40 0c             	mov    0xc(%eax),%eax
80101357:	83 ec 04             	sub    $0x4,%esp
8010135a:	ff 75 10             	pushl  0x10(%ebp)
8010135d:	ff 75 0c             	pushl  0xc(%ebp)
80101360:	50                   	push   %eax
80101361:	e8 f1 2d 00 00       	call   80104157 <pipewrite>
80101366:	83 c4 10             	add    $0x10,%esp
80101369:	e9 f4 00 00 00       	jmp    80101462 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	8b 00                	mov    (%eax),%eax
80101373:	83 f8 02             	cmp    $0x2,%eax
80101376:	0f 85 d9 00 00 00    	jne    80101455 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
8010137c:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
80101383:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010138a:	e9 a3 00 00 00       	jmp    80101432 <filewrite+0x10b>
      int n1 = n - i;
8010138f:	8b 45 10             	mov    0x10(%ebp),%eax
80101392:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101395:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101398:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010139b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010139e:	7e 06                	jle    801013a6 <filewrite+0x7f>
        n1 = max;
801013a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013a3:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013a6:	e8 c8 22 00 00       	call   80103673 <begin_op>
      ilock(f->ip);
801013ab:	8b 45 08             	mov    0x8(%ebp),%eax
801013ae:	8b 40 10             	mov    0x10(%eax),%eax
801013b1:	83 ec 0c             	sub    $0xc,%esp
801013b4:	50                   	push   %eax
801013b5:	e8 ea 06 00 00       	call   80101aa4 <ilock>
801013ba:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013bd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013c0:	8b 45 08             	mov    0x8(%ebp),%eax
801013c3:	8b 50 14             	mov    0x14(%eax),%edx
801013c6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801013cc:	01 c3                	add    %eax,%ebx
801013ce:	8b 45 08             	mov    0x8(%ebp),%eax
801013d1:	8b 40 10             	mov    0x10(%eax),%eax
801013d4:	51                   	push   %ecx
801013d5:	52                   	push   %edx
801013d6:	53                   	push   %ebx
801013d7:	50                   	push   %eax
801013d8:	e8 28 0d 00 00       	call   80102105 <writei>
801013dd:	83 c4 10             	add    $0x10,%esp
801013e0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013e3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013e7:	7e 11                	jle    801013fa <filewrite+0xd3>
        f->off += r;
801013e9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ec:	8b 50 14             	mov    0x14(%eax),%edx
801013ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013f2:	01 c2                	add    %eax,%edx
801013f4:	8b 45 08             	mov    0x8(%ebp),%eax
801013f7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013fa:	8b 45 08             	mov    0x8(%ebp),%eax
801013fd:	8b 40 10             	mov    0x10(%eax),%eax
80101400:	83 ec 0c             	sub    $0xc,%esp
80101403:	50                   	push   %eax
80101404:	e8 b2 07 00 00       	call   80101bbb <iunlock>
80101409:	83 c4 10             	add    $0x10,%esp
      end_op();
8010140c:	e8 f2 22 00 00       	call   80103703 <end_op>

      if(r < 0)
80101411:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101415:	78 29                	js     80101440 <filewrite+0x119>
        break;
      if(r != n1)
80101417:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010141a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010141d:	74 0d                	je     8010142c <filewrite+0x105>
        panic("short filewrite");
8010141f:	83 ec 0c             	sub    $0xc,%esp
80101422:	68 8c 8a 10 80       	push   $0x80108a8c
80101427:	e8 a5 f1 ff ff       	call   801005d1 <panic>
      i += r;
8010142c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010142f:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101435:	3b 45 10             	cmp    0x10(%ebp),%eax
80101438:	0f 8c 51 ff ff ff    	jl     8010138f <filewrite+0x68>
8010143e:	eb 01                	jmp    80101441 <filewrite+0x11a>
        break;
80101440:	90                   	nop
    }
    return i == n ? n : -1;
80101441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101444:	3b 45 10             	cmp    0x10(%ebp),%eax
80101447:	75 05                	jne    8010144e <filewrite+0x127>
80101449:	8b 45 10             	mov    0x10(%ebp),%eax
8010144c:	eb 14                	jmp    80101462 <filewrite+0x13b>
8010144e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101453:	eb 0d                	jmp    80101462 <filewrite+0x13b>
  }
  panic("filewrite");
80101455:	83 ec 0c             	sub    $0xc,%esp
80101458:	68 9c 8a 10 80       	push   $0x80108a9c
8010145d:	e8 6f f1 ff ff       	call   801005d1 <panic>
}
80101462:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101465:	c9                   	leave  
80101466:	c3                   	ret    

80101467 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101467:	f3 0f 1e fb          	endbr32 
8010146b:	55                   	push   %ebp
8010146c:	89 e5                	mov    %esp,%ebp
8010146e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
80101471:	8b 45 08             	mov    0x8(%ebp),%eax
80101474:	83 ec 08             	sub    $0x8,%esp
80101477:	6a 01                	push   $0x1
80101479:	50                   	push   %eax
8010147a:	e8 58 ed ff ff       	call   801001d7 <bread>
8010147f:	83 c4 10             	add    $0x10,%esp
80101482:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101488:	83 c0 5c             	add    $0x5c,%eax
8010148b:	83 ec 04             	sub    $0x4,%esp
8010148e:	6a 1c                	push   $0x1c
80101490:	50                   	push   %eax
80101491:	ff 75 0c             	pushl  0xc(%ebp)
80101494:	e8 73 43 00 00       	call   8010580c <memmove>
80101499:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010149c:	83 ec 0c             	sub    $0xc,%esp
8010149f:	ff 75 f4             	pushl  -0xc(%ebp)
801014a2:	e8 ba ed ff ff       	call   80100261 <brelse>
801014a7:	83 c4 10             	add    $0x10,%esp
}
801014aa:	90                   	nop
801014ab:	c9                   	leave  
801014ac:	c3                   	ret    

801014ad <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014ad:	f3 0f 1e fb          	endbr32 
801014b1:	55                   	push   %ebp
801014b2:	89 e5                	mov    %esp,%ebp
801014b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014b7:	8b 55 0c             	mov    0xc(%ebp),%edx
801014ba:	8b 45 08             	mov    0x8(%ebp),%eax
801014bd:	83 ec 08             	sub    $0x8,%esp
801014c0:	52                   	push   %edx
801014c1:	50                   	push   %eax
801014c2:	e8 10 ed ff ff       	call   801001d7 <bread>
801014c7:	83 c4 10             	add    $0x10,%esp
801014ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d0:	83 c0 5c             	add    $0x5c,%eax
801014d3:	83 ec 04             	sub    $0x4,%esp
801014d6:	68 00 02 00 00       	push   $0x200
801014db:	6a 00                	push   $0x0
801014dd:	50                   	push   %eax
801014de:	e8 62 42 00 00       	call   80105745 <memset>
801014e3:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014e6:	83 ec 0c             	sub    $0xc,%esp
801014e9:	ff 75 f4             	pushl  -0xc(%ebp)
801014ec:	e8 cb 23 00 00       	call   801038bc <log_write>
801014f1:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014f4:	83 ec 0c             	sub    $0xc,%esp
801014f7:	ff 75 f4             	pushl  -0xc(%ebp)
801014fa:	e8 62 ed ff ff       	call   80100261 <brelse>
801014ff:	83 c4 10             	add    $0x10,%esp
}
80101502:	90                   	nop
80101503:	c9                   	leave  
80101504:	c3                   	ret    

80101505 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101505:	f3 0f 1e fb          	endbr32 
80101509:	55                   	push   %ebp
8010150a:	89 e5                	mov    %esp,%ebp
8010150c:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010150f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101516:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010151d:	e9 13 01 00 00       	jmp    80101635 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
80101522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101525:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010152b:	85 c0                	test   %eax,%eax
8010152d:	0f 48 c2             	cmovs  %edx,%eax
80101530:	c1 f8 0c             	sar    $0xc,%eax
80101533:	89 c2                	mov    %eax,%edx
80101535:	a1 58 2a 11 80       	mov    0x80112a58,%eax
8010153a:	01 d0                	add    %edx,%eax
8010153c:	83 ec 08             	sub    $0x8,%esp
8010153f:	50                   	push   %eax
80101540:	ff 75 08             	pushl  0x8(%ebp)
80101543:	e8 8f ec ff ff       	call   801001d7 <bread>
80101548:	83 c4 10             	add    $0x10,%esp
8010154b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010154e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101555:	e9 a6 00 00 00       	jmp    80101600 <balloc+0xfb>
      m = 1 << (bi % 8);
8010155a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155d:	99                   	cltd   
8010155e:	c1 ea 1d             	shr    $0x1d,%edx
80101561:	01 d0                	add    %edx,%eax
80101563:	83 e0 07             	and    $0x7,%eax
80101566:	29 d0                	sub    %edx,%eax
80101568:	ba 01 00 00 00       	mov    $0x1,%edx
8010156d:	89 c1                	mov    %eax,%ecx
8010156f:	d3 e2                	shl    %cl,%edx
80101571:	89 d0                	mov    %edx,%eax
80101573:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101579:	8d 50 07             	lea    0x7(%eax),%edx
8010157c:	85 c0                	test   %eax,%eax
8010157e:	0f 48 c2             	cmovs  %edx,%eax
80101581:	c1 f8 03             	sar    $0x3,%eax
80101584:	89 c2                	mov    %eax,%edx
80101586:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101589:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
8010158e:	0f b6 c0             	movzbl %al,%eax
80101591:	23 45 e8             	and    -0x18(%ebp),%eax
80101594:	85 c0                	test   %eax,%eax
80101596:	75 64                	jne    801015fc <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159b:	8d 50 07             	lea    0x7(%eax),%edx
8010159e:	85 c0                	test   %eax,%eax
801015a0:	0f 48 c2             	cmovs  %edx,%eax
801015a3:	c1 f8 03             	sar    $0x3,%eax
801015a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015a9:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801015ae:	89 d1                	mov    %edx,%ecx
801015b0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015b3:	09 ca                	or     %ecx,%edx
801015b5:	89 d1                	mov    %edx,%ecx
801015b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015ba:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015be:	83 ec 0c             	sub    $0xc,%esp
801015c1:	ff 75 ec             	pushl  -0x14(%ebp)
801015c4:	e8 f3 22 00 00       	call   801038bc <log_write>
801015c9:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801015cc:	83 ec 0c             	sub    $0xc,%esp
801015cf:	ff 75 ec             	pushl  -0x14(%ebp)
801015d2:	e8 8a ec ff ff       	call   80100261 <brelse>
801015d7:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801015da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e0:	01 c2                	add    %eax,%edx
801015e2:	8b 45 08             	mov    0x8(%ebp),%eax
801015e5:	83 ec 08             	sub    $0x8,%esp
801015e8:	52                   	push   %edx
801015e9:	50                   	push   %eax
801015ea:	e8 be fe ff ff       	call   801014ad <bzero>
801015ef:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f8:	01 d0                	add    %edx,%eax
801015fa:	eb 57                	jmp    80101653 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015fc:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101600:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101607:	7f 17                	jg     80101620 <balloc+0x11b>
80101609:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160f:	01 d0                	add    %edx,%eax
80101611:	89 c2                	mov    %eax,%edx
80101613:	a1 40 2a 11 80       	mov    0x80112a40,%eax
80101618:	39 c2                	cmp    %eax,%edx
8010161a:	0f 82 3a ff ff ff    	jb     8010155a <balloc+0x55>
      }
    }
    brelse(bp);
80101620:	83 ec 0c             	sub    $0xc,%esp
80101623:	ff 75 ec             	pushl  -0x14(%ebp)
80101626:	e8 36 ec ff ff       	call   80100261 <brelse>
8010162b:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010162e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101635:	8b 15 40 2a 11 80    	mov    0x80112a40,%edx
8010163b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010163e:	39 c2                	cmp    %eax,%edx
80101640:	0f 87 dc fe ff ff    	ja     80101522 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
80101646:	83 ec 0c             	sub    $0xc,%esp
80101649:	68 a8 8a 10 80       	push   $0x80108aa8
8010164e:	e8 7e ef ff ff       	call   801005d1 <panic>
}
80101653:	c9                   	leave  
80101654:	c3                   	ret    

80101655 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101655:	f3 0f 1e fb          	endbr32 
80101659:	55                   	push   %ebp
8010165a:	89 e5                	mov    %esp,%ebp
8010165c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
8010165f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101662:	c1 e8 0c             	shr    $0xc,%eax
80101665:	89 c2                	mov    %eax,%edx
80101667:	a1 58 2a 11 80       	mov    0x80112a58,%eax
8010166c:	01 c2                	add    %eax,%edx
8010166e:	8b 45 08             	mov    0x8(%ebp),%eax
80101671:	83 ec 08             	sub    $0x8,%esp
80101674:	52                   	push   %edx
80101675:	50                   	push   %eax
80101676:	e8 5c eb ff ff       	call   801001d7 <bread>
8010167b:	83 c4 10             	add    $0x10,%esp
8010167e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101681:	8b 45 0c             	mov    0xc(%ebp),%eax
80101684:	25 ff 0f 00 00       	and    $0xfff,%eax
80101689:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168f:	99                   	cltd   
80101690:	c1 ea 1d             	shr    $0x1d,%edx
80101693:	01 d0                	add    %edx,%eax
80101695:	83 e0 07             	and    $0x7,%eax
80101698:	29 d0                	sub    %edx,%eax
8010169a:	ba 01 00 00 00       	mov    $0x1,%edx
8010169f:	89 c1                	mov    %eax,%ecx
801016a1:	d3 e2                	shl    %cl,%edx
801016a3:	89 d0                	mov    %edx,%eax
801016a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ab:	8d 50 07             	lea    0x7(%eax),%edx
801016ae:	85 c0                	test   %eax,%eax
801016b0:	0f 48 c2             	cmovs  %edx,%eax
801016b3:	c1 f8 03             	sar    $0x3,%eax
801016b6:	89 c2                	mov    %eax,%edx
801016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016bb:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801016c0:	0f b6 c0             	movzbl %al,%eax
801016c3:	23 45 ec             	and    -0x14(%ebp),%eax
801016c6:	85 c0                	test   %eax,%eax
801016c8:	75 0d                	jne    801016d7 <bfree+0x82>
    panic("freeing free block");
801016ca:	83 ec 0c             	sub    $0xc,%esp
801016cd:	68 be 8a 10 80       	push   $0x80108abe
801016d2:	e8 fa ee ff ff       	call   801005d1 <panic>
  bp->data[bi/8] &= ~m;
801016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016da:	8d 50 07             	lea    0x7(%eax),%edx
801016dd:	85 c0                	test   %eax,%eax
801016df:	0f 48 c2             	cmovs  %edx,%eax
801016e2:	c1 f8 03             	sar    $0x3,%eax
801016e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016e8:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
801016ed:	89 d1                	mov    %edx,%ecx
801016ef:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016f2:	f7 d2                	not    %edx
801016f4:	21 ca                	and    %ecx,%edx
801016f6:	89 d1                	mov    %edx,%ecx
801016f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016fb:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016ff:	83 ec 0c             	sub    $0xc,%esp
80101702:	ff 75 f4             	pushl  -0xc(%ebp)
80101705:	e8 b2 21 00 00       	call   801038bc <log_write>
8010170a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010170d:	83 ec 0c             	sub    $0xc,%esp
80101710:	ff 75 f4             	pushl  -0xc(%ebp)
80101713:	e8 49 eb ff ff       	call   80100261 <brelse>
80101718:	83 c4 10             	add    $0x10,%esp
}
8010171b:	90                   	nop
8010171c:	c9                   	leave  
8010171d:	c3                   	ret    

8010171e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010171e:	f3 0f 1e fb          	endbr32 
80101722:	55                   	push   %ebp
80101723:	89 e5                	mov    %esp,%ebp
80101725:	57                   	push   %edi
80101726:	56                   	push   %esi
80101727:	53                   	push   %ebx
80101728:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010172b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101732:	83 ec 08             	sub    $0x8,%esp
80101735:	68 d1 8a 10 80       	push   $0x80108ad1
8010173a:	68 60 2a 11 80       	push   $0x80112a60
8010173f:	e8 3c 3d 00 00       	call   80105480 <initlock>
80101744:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101747:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010174e:	eb 2d                	jmp    8010177d <iinit+0x5f>
    initsleeplock(&icache.inode[i].lock, "inode");
80101750:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101753:	89 d0                	mov    %edx,%eax
80101755:	c1 e0 03             	shl    $0x3,%eax
80101758:	01 d0                	add    %edx,%eax
8010175a:	c1 e0 04             	shl    $0x4,%eax
8010175d:	83 c0 30             	add    $0x30,%eax
80101760:	05 60 2a 11 80       	add    $0x80112a60,%eax
80101765:	83 c0 10             	add    $0x10,%eax
80101768:	83 ec 08             	sub    $0x8,%esp
8010176b:	68 d8 8a 10 80       	push   $0x80108ad8
80101770:	50                   	push   %eax
80101771:	e8 77 3b 00 00       	call   801052ed <initsleeplock>
80101776:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
80101779:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010177d:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101781:	7e cd                	jle    80101750 <iinit+0x32>
  }

  readsb(dev, &sb);
80101783:	83 ec 08             	sub    $0x8,%esp
80101786:	68 40 2a 11 80       	push   $0x80112a40
8010178b:	ff 75 08             	pushl  0x8(%ebp)
8010178e:	e8 d4 fc ff ff       	call   80101467 <readsb>
80101793:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101796:	a1 58 2a 11 80       	mov    0x80112a58,%eax
8010179b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010179e:	8b 3d 54 2a 11 80    	mov    0x80112a54,%edi
801017a4:	8b 35 50 2a 11 80    	mov    0x80112a50,%esi
801017aa:	8b 1d 4c 2a 11 80    	mov    0x80112a4c,%ebx
801017b0:	8b 0d 48 2a 11 80    	mov    0x80112a48,%ecx
801017b6:	8b 15 44 2a 11 80    	mov    0x80112a44,%edx
801017bc:	a1 40 2a 11 80       	mov    0x80112a40,%eax
801017c1:	ff 75 d4             	pushl  -0x2c(%ebp)
801017c4:	57                   	push   %edi
801017c5:	56                   	push   %esi
801017c6:	53                   	push   %ebx
801017c7:	51                   	push   %ecx
801017c8:	52                   	push   %edx
801017c9:	50                   	push   %eax
801017ca:	68 e0 8a 10 80       	push   $0x80108ae0
801017cf:	e8 44 ec ff ff       	call   80100418 <cprintf>
801017d4:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
801017d7:	90                   	nop
801017d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801017db:	5b                   	pop    %ebx
801017dc:	5e                   	pop    %esi
801017dd:	5f                   	pop    %edi
801017de:	5d                   	pop    %ebp
801017df:	c3                   	ret    

801017e0 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
801017e0:	f3 0f 1e fb          	endbr32 
801017e4:	55                   	push   %ebp
801017e5:	89 e5                	mov    %esp,%ebp
801017e7:	83 ec 28             	sub    $0x28,%esp
801017ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801017ed:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801017f1:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017f8:	e9 9e 00 00 00       	jmp    8010189b <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
801017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101800:	c1 e8 03             	shr    $0x3,%eax
80101803:	89 c2                	mov    %eax,%edx
80101805:	a1 54 2a 11 80       	mov    0x80112a54,%eax
8010180a:	01 d0                	add    %edx,%eax
8010180c:	83 ec 08             	sub    $0x8,%esp
8010180f:	50                   	push   %eax
80101810:	ff 75 08             	pushl  0x8(%ebp)
80101813:	e8 bf e9 ff ff       	call   801001d7 <bread>
80101818:	83 c4 10             	add    $0x10,%esp
8010181b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101821:	8d 50 5c             	lea    0x5c(%eax),%edx
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101827:	83 e0 07             	and    $0x7,%eax
8010182a:	c1 e0 06             	shl    $0x6,%eax
8010182d:	01 d0                	add    %edx,%eax
8010182f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101832:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101835:	0f b7 00             	movzwl (%eax),%eax
80101838:	66 85 c0             	test   %ax,%ax
8010183b:	75 4c                	jne    80101889 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
8010183d:	83 ec 04             	sub    $0x4,%esp
80101840:	6a 40                	push   $0x40
80101842:	6a 00                	push   $0x0
80101844:	ff 75 ec             	pushl  -0x14(%ebp)
80101847:	e8 f9 3e 00 00       	call   80105745 <memset>
8010184c:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
8010184f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101852:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101856:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101859:	83 ec 0c             	sub    $0xc,%esp
8010185c:	ff 75 f0             	pushl  -0x10(%ebp)
8010185f:	e8 58 20 00 00       	call   801038bc <log_write>
80101864:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101867:	83 ec 0c             	sub    $0xc,%esp
8010186a:	ff 75 f0             	pushl  -0x10(%ebp)
8010186d:	e8 ef e9 ff ff       	call   80100261 <brelse>
80101872:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101878:	83 ec 08             	sub    $0x8,%esp
8010187b:	50                   	push   %eax
8010187c:	ff 75 08             	pushl  0x8(%ebp)
8010187f:	e8 fc 00 00 00       	call   80101980 <iget>
80101884:	83 c4 10             	add    $0x10,%esp
80101887:	eb 30                	jmp    801018b9 <ialloc+0xd9>
    }
    brelse(bp);
80101889:	83 ec 0c             	sub    $0xc,%esp
8010188c:	ff 75 f0             	pushl  -0x10(%ebp)
8010188f:	e8 cd e9 ff ff       	call   80100261 <brelse>
80101894:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101897:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010189b:	8b 15 48 2a 11 80    	mov    0x80112a48,%edx
801018a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a4:	39 c2                	cmp    %eax,%edx
801018a6:	0f 87 51 ff ff ff    	ja     801017fd <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
801018ac:	83 ec 0c             	sub    $0xc,%esp
801018af:	68 33 8b 10 80       	push   $0x80108b33
801018b4:	e8 18 ed ff ff       	call   801005d1 <panic>
}
801018b9:	c9                   	leave  
801018ba:	c3                   	ret    

801018bb <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018bb:	f3 0f 1e fb          	endbr32 
801018bf:	55                   	push   %ebp
801018c0:	89 e5                	mov    %esp,%ebp
801018c2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018c5:	8b 45 08             	mov    0x8(%ebp),%eax
801018c8:	8b 40 04             	mov    0x4(%eax),%eax
801018cb:	c1 e8 03             	shr    $0x3,%eax
801018ce:	89 c2                	mov    %eax,%edx
801018d0:	a1 54 2a 11 80       	mov    0x80112a54,%eax
801018d5:	01 c2                	add    %eax,%edx
801018d7:	8b 45 08             	mov    0x8(%ebp),%eax
801018da:	8b 00                	mov    (%eax),%eax
801018dc:	83 ec 08             	sub    $0x8,%esp
801018df:	52                   	push   %edx
801018e0:	50                   	push   %eax
801018e1:	e8 f1 e8 ff ff       	call   801001d7 <bread>
801018e6:	83 c4 10             	add    $0x10,%esp
801018e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ef:	8d 50 5c             	lea    0x5c(%eax),%edx
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 40 04             	mov    0x4(%eax),%eax
801018f8:	83 e0 07             	and    $0x7,%eax
801018fb:	c1 e0 06             	shl    $0x6,%eax
801018fe:	01 d0                	add    %edx,%eax
80101900:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101903:	8b 45 08             	mov    0x8(%ebp),%eax
80101906:	0f b7 50 50          	movzwl 0x50(%eax),%edx
8010190a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190d:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	0f b7 50 52          	movzwl 0x52(%eax),%edx
80101917:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	0f b7 50 54          	movzwl 0x54(%eax),%edx
80101925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101928:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010192c:	8b 45 08             	mov    0x8(%ebp),%eax
8010192f:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101936:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010193a:	8b 45 08             	mov    0x8(%ebp),%eax
8010193d:	8b 50 58             	mov    0x58(%eax),%edx
80101940:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101943:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	8d 50 5c             	lea    0x5c(%eax),%edx
8010194c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010194f:	83 c0 0c             	add    $0xc,%eax
80101952:	83 ec 04             	sub    $0x4,%esp
80101955:	6a 34                	push   $0x34
80101957:	52                   	push   %edx
80101958:	50                   	push   %eax
80101959:	e8 ae 3e 00 00       	call   8010580c <memmove>
8010195e:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101961:	83 ec 0c             	sub    $0xc,%esp
80101964:	ff 75 f4             	pushl  -0xc(%ebp)
80101967:	e8 50 1f 00 00       	call   801038bc <log_write>
8010196c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010196f:	83 ec 0c             	sub    $0xc,%esp
80101972:	ff 75 f4             	pushl  -0xc(%ebp)
80101975:	e8 e7 e8 ff ff       	call   80100261 <brelse>
8010197a:	83 c4 10             	add    $0x10,%esp
}
8010197d:	90                   	nop
8010197e:	c9                   	leave  
8010197f:	c3                   	ret    

80101980 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101980:	f3 0f 1e fb          	endbr32 
80101984:	55                   	push   %ebp
80101985:	89 e5                	mov    %esp,%ebp
80101987:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010198a:	83 ec 0c             	sub    $0xc,%esp
8010198d:	68 60 2a 11 80       	push   $0x80112a60
80101992:	e8 0f 3b 00 00       	call   801054a6 <acquire>
80101997:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010199a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019a1:	c7 45 f4 94 2a 11 80 	movl   $0x80112a94,-0xc(%ebp)
801019a8:	eb 60                	jmp    80101a0a <iget+0x8a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	8b 40 08             	mov    0x8(%eax),%eax
801019b0:	85 c0                	test   %eax,%eax
801019b2:	7e 39                	jle    801019ed <iget+0x6d>
801019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b7:	8b 00                	mov    (%eax),%eax
801019b9:	39 45 08             	cmp    %eax,0x8(%ebp)
801019bc:	75 2f                	jne    801019ed <iget+0x6d>
801019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c1:	8b 40 04             	mov    0x4(%eax),%eax
801019c4:	39 45 0c             	cmp    %eax,0xc(%ebp)
801019c7:	75 24                	jne    801019ed <iget+0x6d>
      ip->ref++;
801019c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019cc:	8b 40 08             	mov    0x8(%eax),%eax
801019cf:	8d 50 01             	lea    0x1(%eax),%edx
801019d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d5:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019d8:	83 ec 0c             	sub    $0xc,%esp
801019db:	68 60 2a 11 80       	push   $0x80112a60
801019e0:	e8 33 3b 00 00       	call   80105518 <release>
801019e5:	83 c4 10             	add    $0x10,%esp
      return ip;
801019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019eb:	eb 77                	jmp    80101a64 <iget+0xe4>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019f1:	75 10                	jne    80101a03 <iget+0x83>
801019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f6:	8b 40 08             	mov    0x8(%eax),%eax
801019f9:	85 c0                	test   %eax,%eax
801019fb:	75 06                	jne    80101a03 <iget+0x83>
      empty = ip;
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a03:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a0a:	81 7d f4 b4 46 11 80 	cmpl   $0x801146b4,-0xc(%ebp)
80101a11:	72 97                	jb     801019aa <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a17:	75 0d                	jne    80101a26 <iget+0xa6>
    panic("iget: no inodes");
80101a19:	83 ec 0c             	sub    $0xc,%esp
80101a1c:	68 45 8b 10 80       	push   $0x80108b45
80101a21:	e8 ab eb ff ff       	call   801005d1 <panic>

  ip = empty;
80101a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	8b 55 08             	mov    0x8(%ebp),%edx
80101a32:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a37:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a3a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a51:	83 ec 0c             	sub    $0xc,%esp
80101a54:	68 60 2a 11 80       	push   $0x80112a60
80101a59:	e8 ba 3a 00 00       	call   80105518 <release>
80101a5e:	83 c4 10             	add    $0x10,%esp

  return ip;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a64:	c9                   	leave  
80101a65:	c3                   	ret    

80101a66 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a66:	f3 0f 1e fb          	endbr32 
80101a6a:	55                   	push   %ebp
80101a6b:	89 e5                	mov    %esp,%ebp
80101a6d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101a70:	83 ec 0c             	sub    $0xc,%esp
80101a73:	68 60 2a 11 80       	push   $0x80112a60
80101a78:	e8 29 3a 00 00       	call   801054a6 <acquire>
80101a7d:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	8b 40 08             	mov    0x8(%eax),%eax
80101a86:	8d 50 01             	lea    0x1(%eax),%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a8f:	83 ec 0c             	sub    $0xc,%esp
80101a92:	68 60 2a 11 80       	push   $0x80112a60
80101a97:	e8 7c 3a 00 00       	call   80105518 <release>
80101a9c:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a9f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101aa2:	c9                   	leave  
80101aa3:	c3                   	ret    

80101aa4 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101aa4:	f3 0f 1e fb          	endbr32 
80101aa8:	55                   	push   %ebp
80101aa9:	89 e5                	mov    %esp,%ebp
80101aab:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101aae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ab2:	74 0a                	je     80101abe <ilock+0x1a>
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	8b 40 08             	mov    0x8(%eax),%eax
80101aba:	85 c0                	test   %eax,%eax
80101abc:	7f 0d                	jg     80101acb <ilock+0x27>
    panic("ilock");
80101abe:	83 ec 0c             	sub    $0xc,%esp
80101ac1:	68 55 8b 10 80       	push   $0x80108b55
80101ac6:	e8 06 eb ff ff       	call   801005d1 <panic>

  acquiresleep(&ip->lock);
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	83 c0 0c             	add    $0xc,%eax
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	50                   	push   %eax
80101ad5:	e8 53 38 00 00       	call   8010532d <acquiresleep>
80101ada:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101add:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ae3:	85 c0                	test   %eax,%eax
80101ae5:	0f 85 cd 00 00 00    	jne    80101bb8 <ilock+0x114>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101aee:	8b 40 04             	mov    0x4(%eax),%eax
80101af1:	c1 e8 03             	shr    $0x3,%eax
80101af4:	89 c2                	mov    %eax,%edx
80101af6:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101afb:	01 c2                	add    %eax,%edx
80101afd:	8b 45 08             	mov    0x8(%ebp),%eax
80101b00:	8b 00                	mov    (%eax),%eax
80101b02:	83 ec 08             	sub    $0x8,%esp
80101b05:	52                   	push   %edx
80101b06:	50                   	push   %eax
80101b07:	e8 cb e6 ff ff       	call   801001d7 <bread>
80101b0c:	83 c4 10             	add    $0x10,%esp
80101b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b15:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b18:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1b:	8b 40 04             	mov    0x4(%eax),%eax
80101b1e:	83 e0 07             	and    $0x7,%eax
80101b21:	c1 e0 06             	shl    $0x6,%eax
80101b24:	01 d0                	add    %edx,%eax
80101b26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b2c:	0f b7 10             	movzwl (%eax),%edx
80101b2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b32:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b39:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b40:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b47:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4e:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b55:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b63:	8b 50 08             	mov    0x8(%eax),%edx
80101b66:	8b 45 08             	mov    0x8(%ebp),%eax
80101b69:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b6f:	8d 50 0c             	lea    0xc(%eax),%edx
80101b72:	8b 45 08             	mov    0x8(%ebp),%eax
80101b75:	83 c0 5c             	add    $0x5c,%eax
80101b78:	83 ec 04             	sub    $0x4,%esp
80101b7b:	6a 34                	push   $0x34
80101b7d:	52                   	push   %edx
80101b7e:	50                   	push   %eax
80101b7f:	e8 88 3c 00 00       	call   8010580c <memmove>
80101b84:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b87:	83 ec 0c             	sub    $0xc,%esp
80101b8a:	ff 75 f4             	pushl  -0xc(%ebp)
80101b8d:	e8 cf e6 ff ff       	call   80100261 <brelse>
80101b92:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101b95:	8b 45 08             	mov    0x8(%ebp),%eax
80101b98:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101ba6:	66 85 c0             	test   %ax,%ax
80101ba9:	75 0d                	jne    80101bb8 <ilock+0x114>
      panic("ilock: no type");
80101bab:	83 ec 0c             	sub    $0xc,%esp
80101bae:	68 5b 8b 10 80       	push   $0x80108b5b
80101bb3:	e8 19 ea ff ff       	call   801005d1 <panic>
  }
}
80101bb8:	90                   	nop
80101bb9:	c9                   	leave  
80101bba:	c3                   	ret    

80101bbb <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bbb:	f3 0f 1e fb          	endbr32 
80101bbf:	55                   	push   %ebp
80101bc0:	89 e5                	mov    %esp,%ebp
80101bc2:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bc5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bc9:	74 20                	je     80101beb <iunlock+0x30>
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	83 c0 0c             	add    $0xc,%eax
80101bd1:	83 ec 0c             	sub    $0xc,%esp
80101bd4:	50                   	push   %eax
80101bd5:	e8 0d 38 00 00       	call   801053e7 <holdingsleep>
80101bda:	83 c4 10             	add    $0x10,%esp
80101bdd:	85 c0                	test   %eax,%eax
80101bdf:	74 0a                	je     80101beb <iunlock+0x30>
80101be1:	8b 45 08             	mov    0x8(%ebp),%eax
80101be4:	8b 40 08             	mov    0x8(%eax),%eax
80101be7:	85 c0                	test   %eax,%eax
80101be9:	7f 0d                	jg     80101bf8 <iunlock+0x3d>
    panic("iunlock");
80101beb:	83 ec 0c             	sub    $0xc,%esp
80101bee:	68 6a 8b 10 80       	push   $0x80108b6a
80101bf3:	e8 d9 e9 ff ff       	call   801005d1 <panic>

  releasesleep(&ip->lock);
80101bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfb:	83 c0 0c             	add    $0xc,%eax
80101bfe:	83 ec 0c             	sub    $0xc,%esp
80101c01:	50                   	push   %eax
80101c02:	e8 8e 37 00 00       	call   80105395 <releasesleep>
80101c07:	83 c4 10             	add    $0x10,%esp
}
80101c0a:	90                   	nop
80101c0b:	c9                   	leave  
80101c0c:	c3                   	ret    

80101c0d <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c0d:	f3 0f 1e fb          	endbr32 
80101c11:	55                   	push   %ebp
80101c12:	89 e5                	mov    %esp,%ebp
80101c14:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101c17:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1a:	83 c0 0c             	add    $0xc,%eax
80101c1d:	83 ec 0c             	sub    $0xc,%esp
80101c20:	50                   	push   %eax
80101c21:	e8 07 37 00 00       	call   8010532d <acquiresleep>
80101c26:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101c29:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c2f:	85 c0                	test   %eax,%eax
80101c31:	74 6a                	je     80101c9d <iput+0x90>
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101c3a:	66 85 c0             	test   %ax,%ax
80101c3d:	75 5e                	jne    80101c9d <iput+0x90>
    acquire(&icache.lock);
80101c3f:	83 ec 0c             	sub    $0xc,%esp
80101c42:	68 60 2a 11 80       	push   $0x80112a60
80101c47:	e8 5a 38 00 00       	call   801054a6 <acquire>
80101c4c:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 08             	mov    0x8(%eax),%eax
80101c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c58:	83 ec 0c             	sub    $0xc,%esp
80101c5b:	68 60 2a 11 80       	push   $0x80112a60
80101c60:	e8 b3 38 00 00       	call   80105518 <release>
80101c65:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101c68:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c6c:	75 2f                	jne    80101c9d <iput+0x90>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c6e:	83 ec 0c             	sub    $0xc,%esp
80101c71:	ff 75 08             	pushl  0x8(%ebp)
80101c74:	e8 b5 01 00 00       	call   80101e2e <itrunc>
80101c79:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c85:	83 ec 0c             	sub    $0xc,%esp
80101c88:	ff 75 08             	pushl  0x8(%ebp)
80101c8b:	e8 2b fc ff ff       	call   801018bb <iupdate>
80101c90:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca0:	83 c0 0c             	add    $0xc,%eax
80101ca3:	83 ec 0c             	sub    $0xc,%esp
80101ca6:	50                   	push   %eax
80101ca7:	e8 e9 36 00 00       	call   80105395 <releasesleep>
80101cac:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101caf:	83 ec 0c             	sub    $0xc,%esp
80101cb2:	68 60 2a 11 80       	push   $0x80112a60
80101cb7:	e8 ea 37 00 00       	call   801054a6 <acquire>
80101cbc:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc2:	8b 40 08             	mov    0x8(%eax),%eax
80101cc5:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccb:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cce:	83 ec 0c             	sub    $0xc,%esp
80101cd1:	68 60 2a 11 80       	push   $0x80112a60
80101cd6:	e8 3d 38 00 00       	call   80105518 <release>
80101cdb:	83 c4 10             	add    $0x10,%esp
}
80101cde:	90                   	nop
80101cdf:	c9                   	leave  
80101ce0:	c3                   	ret    

80101ce1 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101ce1:	f3 0f 1e fb          	endbr32 
80101ce5:	55                   	push   %ebp
80101ce6:	89 e5                	mov    %esp,%ebp
80101ce8:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101ceb:	83 ec 0c             	sub    $0xc,%esp
80101cee:	ff 75 08             	pushl  0x8(%ebp)
80101cf1:	e8 c5 fe ff ff       	call   80101bbb <iunlock>
80101cf6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cf9:	83 ec 0c             	sub    $0xc,%esp
80101cfc:	ff 75 08             	pushl  0x8(%ebp)
80101cff:	e8 09 ff ff ff       	call   80101c0d <iput>
80101d04:	83 c4 10             	add    $0x10,%esp
}
80101d07:	90                   	nop
80101d08:	c9                   	leave  
80101d09:	c3                   	ret    

80101d0a <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d0a:	f3 0f 1e fb          	endbr32 
80101d0e:	55                   	push   %ebp
80101d0f:	89 e5                	mov    %esp,%ebp
80101d11:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d14:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d18:	77 42                	ja     80101d5c <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d20:	83 c2 14             	add    $0x14,%edx
80101d23:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d2e:	75 24                	jne    80101d54 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 00                	mov    (%eax),%eax
80101d35:	83 ec 0c             	sub    $0xc,%esp
80101d38:	50                   	push   %eax
80101d39:	e8 c7 f7 ff ff       	call   80101505 <balloc>
80101d3e:	83 c4 10             	add    $0x10,%esp
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	8b 45 08             	mov    0x8(%ebp),%eax
80101d47:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d4a:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d50:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	e9 d0 00 00 00       	jmp    80101e2c <bmap+0x122>
  }
  bn -= NDIRECT;
80101d5c:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d60:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d64:	0f 87 b5 00 00 00    	ja     80101e1f <bmap+0x115>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d7a:	75 20                	jne    80101d9c <bmap+0x92>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7f:	8b 00                	mov    (%eax),%eax
80101d81:	83 ec 0c             	sub    $0xc,%esp
80101d84:	50                   	push   %eax
80101d85:	e8 7b f7 ff ff       	call   80101505 <balloc>
80101d8a:	83 c4 10             	add    $0x10,%esp
80101d8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d90:	8b 45 08             	mov    0x8(%ebp),%eax
80101d93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d96:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9f:	8b 00                	mov    (%eax),%eax
80101da1:	83 ec 08             	sub    $0x8,%esp
80101da4:	ff 75 f4             	pushl  -0xc(%ebp)
80101da7:	50                   	push   %eax
80101da8:	e8 2a e4 ff ff       	call   801001d7 <bread>
80101dad:	83 c4 10             	add    $0x10,%esp
80101db0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101db6:	83 c0 5c             	add    $0x5c,%eax
80101db9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101dbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dc9:	01 d0                	add    %edx,%eax
80101dcb:	8b 00                	mov    (%eax),%eax
80101dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dd4:	75 36                	jne    80101e0c <bmap+0x102>
      a[bn] = addr = balloc(ip->dev);
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 00                	mov    (%eax),%eax
80101ddb:	83 ec 0c             	sub    $0xc,%esp
80101dde:	50                   	push   %eax
80101ddf:	e8 21 f7 ff ff       	call   80101505 <balloc>
80101de4:	83 c4 10             	add    $0x10,%esp
80101de7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dea:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ded:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df7:	01 c2                	add    %eax,%edx
80101df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dfc:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101dfe:	83 ec 0c             	sub    $0xc,%esp
80101e01:	ff 75 f0             	pushl  -0x10(%ebp)
80101e04:	e8 b3 1a 00 00       	call   801038bc <log_write>
80101e09:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e0c:	83 ec 0c             	sub    $0xc,%esp
80101e0f:	ff 75 f0             	pushl  -0x10(%ebp)
80101e12:	e8 4a e4 ff ff       	call   80100261 <brelse>
80101e17:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e1d:	eb 0d                	jmp    80101e2c <bmap+0x122>
  }

  panic("bmap: out of range");
80101e1f:	83 ec 0c             	sub    $0xc,%esp
80101e22:	68 72 8b 10 80       	push   $0x80108b72
80101e27:	e8 a5 e7 ff ff       	call   801005d1 <panic>
}
80101e2c:	c9                   	leave  
80101e2d:	c3                   	ret    

80101e2e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e2e:	f3 0f 1e fb          	endbr32 
80101e32:	55                   	push   %ebp
80101e33:	89 e5                	mov    %esp,%ebp
80101e35:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e3f:	eb 45                	jmp    80101e86 <itrunc+0x58>
    if(ip->addrs[i]){
80101e41:	8b 45 08             	mov    0x8(%ebp),%eax
80101e44:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e47:	83 c2 14             	add    $0x14,%edx
80101e4a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e4e:	85 c0                	test   %eax,%eax
80101e50:	74 30                	je     80101e82 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e52:	8b 45 08             	mov    0x8(%ebp),%eax
80101e55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e58:	83 c2 14             	add    $0x14,%edx
80101e5b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e5f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e62:	8b 12                	mov    (%edx),%edx
80101e64:	83 ec 08             	sub    $0x8,%esp
80101e67:	50                   	push   %eax
80101e68:	52                   	push   %edx
80101e69:	e8 e7 f7 ff ff       	call   80101655 <bfree>
80101e6e:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e71:	8b 45 08             	mov    0x8(%ebp),%eax
80101e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e77:	83 c2 14             	add    $0x14,%edx
80101e7a:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e81:	00 
  for(i = 0; i < NDIRECT; i++){
80101e82:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e86:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e8a:	7e b5                	jle    80101e41 <itrunc+0x13>
    }
  }

  if(ip->addrs[NDIRECT]){
80101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e95:	85 c0                	test   %eax,%eax
80101e97:	0f 84 aa 00 00 00    	je     80101f47 <itrunc+0x119>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea0:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ea6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea9:	8b 00                	mov    (%eax),%eax
80101eab:	83 ec 08             	sub    $0x8,%esp
80101eae:	52                   	push   %edx
80101eaf:	50                   	push   %eax
80101eb0:	e8 22 e3 ff ff       	call   801001d7 <bread>
80101eb5:	83 c4 10             	add    $0x10,%esp
80101eb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ebb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebe:	83 c0 5c             	add    $0x5c,%eax
80101ec1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ec4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ecb:	eb 3c                	jmp    80101f09 <itrunc+0xdb>
      if(a[j])
80101ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eda:	01 d0                	add    %edx,%eax
80101edc:	8b 00                	mov    (%eax),%eax
80101ede:	85 c0                	test   %eax,%eax
80101ee0:	74 23                	je     80101f05 <itrunc+0xd7>
        bfree(ip->dev, a[j]);
80101ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ee5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101eec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eef:	01 d0                	add    %edx,%eax
80101ef1:	8b 00                	mov    (%eax),%eax
80101ef3:	8b 55 08             	mov    0x8(%ebp),%edx
80101ef6:	8b 12                	mov    (%edx),%edx
80101ef8:	83 ec 08             	sub    $0x8,%esp
80101efb:	50                   	push   %eax
80101efc:	52                   	push   %edx
80101efd:	e8 53 f7 ff ff       	call   80101655 <bfree>
80101f02:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101f05:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f0c:	83 f8 7f             	cmp    $0x7f,%eax
80101f0f:	76 bc                	jbe    80101ecd <itrunc+0x9f>
    }
    brelse(bp);
80101f11:	83 ec 0c             	sub    $0xc,%esp
80101f14:	ff 75 ec             	pushl  -0x14(%ebp)
80101f17:	e8 45 e3 ff ff       	call   80100261 <brelse>
80101f1c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101f28:	8b 55 08             	mov    0x8(%ebp),%edx
80101f2b:	8b 12                	mov    (%edx),%edx
80101f2d:	83 ec 08             	sub    $0x8,%esp
80101f30:	50                   	push   %eax
80101f31:	52                   	push   %edx
80101f32:	e8 1e f7 ff ff       	call   80101655 <bfree>
80101f37:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3d:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f44:	00 00 00 
  }

  ip->size = 0;
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f51:	83 ec 0c             	sub    $0xc,%esp
80101f54:	ff 75 08             	pushl  0x8(%ebp)
80101f57:	e8 5f f9 ff ff       	call   801018bb <iupdate>
80101f5c:	83 c4 10             	add    $0x10,%esp
}
80101f5f:	90                   	nop
80101f60:	c9                   	leave  
80101f61:	c3                   	ret    

80101f62 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f62:	f3 0f 1e fb          	endbr32 
80101f66:	55                   	push   %ebp
80101f67:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f69:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6c:	8b 00                	mov    (%eax),%eax
80101f6e:	89 c2                	mov    %eax,%edx
80101f70:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f73:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f76:	8b 45 08             	mov    0x8(%ebp),%eax
80101f79:	8b 50 04             	mov    0x4(%eax),%edx
80101f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f7f:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
80101f85:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f8c:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f92:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101f96:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f99:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa0:	8b 50 58             	mov    0x58(%eax),%edx
80101fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fa6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fa9:	90                   	nop
80101faa:	5d                   	pop    %ebp
80101fab:	c3                   	ret    

80101fac <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fac:	f3 0f 1e fb          	endbr32 
80101fb0:	55                   	push   %ebp
80101fb1:	89 e5                	mov    %esp,%ebp
80101fb3:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101fbd:	66 83 f8 03          	cmp    $0x3,%ax
80101fc1:	75 5c                	jne    8010201f <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc6:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fca:	66 85 c0             	test   %ax,%ax
80101fcd:	78 20                	js     80101fef <readi+0x43>
80101fcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fd6:	66 83 f8 09          	cmp    $0x9,%ax
80101fda:	7f 13                	jg     80101fef <readi+0x43>
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101fe3:	98                   	cwtl   
80101fe4:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
80101feb:	85 c0                	test   %eax,%eax
80101fed:	75 0a                	jne    80101ff9 <readi+0x4d>
      return -1;
80101fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ff4:	e9 0a 01 00 00       	jmp    80102103 <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102000:	98                   	cwtl   
80102001:	8b 04 c5 e0 29 11 80 	mov    -0x7feed620(,%eax,8),%eax
80102008:	8b 55 14             	mov    0x14(%ebp),%edx
8010200b:	83 ec 04             	sub    $0x4,%esp
8010200e:	52                   	push   %edx
8010200f:	ff 75 0c             	pushl  0xc(%ebp)
80102012:	ff 75 08             	pushl  0x8(%ebp)
80102015:	ff d0                	call   *%eax
80102017:	83 c4 10             	add    $0x10,%esp
8010201a:	e9 e4 00 00 00       	jmp    80102103 <readi+0x157>
  }

  if(off > ip->size || off + n < off)
8010201f:	8b 45 08             	mov    0x8(%ebp),%eax
80102022:	8b 40 58             	mov    0x58(%eax),%eax
80102025:	39 45 10             	cmp    %eax,0x10(%ebp)
80102028:	77 0d                	ja     80102037 <readi+0x8b>
8010202a:	8b 55 10             	mov    0x10(%ebp),%edx
8010202d:	8b 45 14             	mov    0x14(%ebp),%eax
80102030:	01 d0                	add    %edx,%eax
80102032:	39 45 10             	cmp    %eax,0x10(%ebp)
80102035:	76 0a                	jbe    80102041 <readi+0x95>
    return -1;
80102037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010203c:	e9 c2 00 00 00       	jmp    80102103 <readi+0x157>
  if(off + n > ip->size)
80102041:	8b 55 10             	mov    0x10(%ebp),%edx
80102044:	8b 45 14             	mov    0x14(%ebp),%eax
80102047:	01 c2                	add    %eax,%edx
80102049:	8b 45 08             	mov    0x8(%ebp),%eax
8010204c:	8b 40 58             	mov    0x58(%eax),%eax
8010204f:	39 c2                	cmp    %eax,%edx
80102051:	76 0c                	jbe    8010205f <readi+0xb3>
    n = ip->size - off;
80102053:	8b 45 08             	mov    0x8(%ebp),%eax
80102056:	8b 40 58             	mov    0x58(%eax),%eax
80102059:	2b 45 10             	sub    0x10(%ebp),%eax
8010205c:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010205f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102066:	e9 89 00 00 00       	jmp    801020f4 <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010206b:	8b 45 10             	mov    0x10(%ebp),%eax
8010206e:	c1 e8 09             	shr    $0x9,%eax
80102071:	83 ec 08             	sub    $0x8,%esp
80102074:	50                   	push   %eax
80102075:	ff 75 08             	pushl  0x8(%ebp)
80102078:	e8 8d fc ff ff       	call   80101d0a <bmap>
8010207d:	83 c4 10             	add    $0x10,%esp
80102080:	8b 55 08             	mov    0x8(%ebp),%edx
80102083:	8b 12                	mov    (%edx),%edx
80102085:	83 ec 08             	sub    $0x8,%esp
80102088:	50                   	push   %eax
80102089:	52                   	push   %edx
8010208a:	e8 48 e1 ff ff       	call   801001d7 <bread>
8010208f:	83 c4 10             	add    $0x10,%esp
80102092:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102095:	8b 45 10             	mov    0x10(%ebp),%eax
80102098:	25 ff 01 00 00       	and    $0x1ff,%eax
8010209d:	ba 00 02 00 00       	mov    $0x200,%edx
801020a2:	29 c2                	sub    %eax,%edx
801020a4:	8b 45 14             	mov    0x14(%ebp),%eax
801020a7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020aa:	39 c2                	cmp    %eax,%edx
801020ac:	0f 46 c2             	cmovbe %edx,%eax
801020af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020b5:	8d 50 5c             	lea    0x5c(%eax),%edx
801020b8:	8b 45 10             	mov    0x10(%ebp),%eax
801020bb:	25 ff 01 00 00       	and    $0x1ff,%eax
801020c0:	01 d0                	add    %edx,%eax
801020c2:	83 ec 04             	sub    $0x4,%esp
801020c5:	ff 75 ec             	pushl  -0x14(%ebp)
801020c8:	50                   	push   %eax
801020c9:	ff 75 0c             	pushl  0xc(%ebp)
801020cc:	e8 3b 37 00 00       	call   8010580c <memmove>
801020d1:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020d4:	83 ec 0c             	sub    $0xc,%esp
801020d7:	ff 75 f0             	pushl  -0x10(%ebp)
801020da:	e8 82 e1 ff ff       	call   80100261 <brelse>
801020df:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e5:	01 45 f4             	add    %eax,-0xc(%ebp)
801020e8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020eb:	01 45 10             	add    %eax,0x10(%ebp)
801020ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020f1:	01 45 0c             	add    %eax,0xc(%ebp)
801020f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020f7:	3b 45 14             	cmp    0x14(%ebp),%eax
801020fa:	0f 82 6b ff ff ff    	jb     8010206b <readi+0xbf>
  }
  return n;
80102100:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102103:	c9                   	leave  
80102104:	c3                   	ret    

80102105 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102105:	f3 0f 1e fb          	endbr32 
80102109:	55                   	push   %ebp
8010210a:	89 e5                	mov    %esp,%ebp
8010210c:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010210f:	8b 45 08             	mov    0x8(%ebp),%eax
80102112:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102116:	66 83 f8 03          	cmp    $0x3,%ax
8010211a:	75 5c                	jne    80102178 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010211c:	8b 45 08             	mov    0x8(%ebp),%eax
8010211f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102123:	66 85 c0             	test   %ax,%ax
80102126:	78 20                	js     80102148 <writei+0x43>
80102128:	8b 45 08             	mov    0x8(%ebp),%eax
8010212b:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010212f:	66 83 f8 09          	cmp    $0x9,%ax
80102133:	7f 13                	jg     80102148 <writei+0x43>
80102135:	8b 45 08             	mov    0x8(%ebp),%eax
80102138:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010213c:	98                   	cwtl   
8010213d:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
80102144:	85 c0                	test   %eax,%eax
80102146:	75 0a                	jne    80102152 <writei+0x4d>
      return -1;
80102148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010214d:	e9 3b 01 00 00       	jmp    8010228d <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
80102152:	8b 45 08             	mov    0x8(%ebp),%eax
80102155:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102159:	98                   	cwtl   
8010215a:	8b 04 c5 e4 29 11 80 	mov    -0x7feed61c(,%eax,8),%eax
80102161:	8b 55 14             	mov    0x14(%ebp),%edx
80102164:	83 ec 04             	sub    $0x4,%esp
80102167:	52                   	push   %edx
80102168:	ff 75 0c             	pushl  0xc(%ebp)
8010216b:	ff 75 08             	pushl  0x8(%ebp)
8010216e:	ff d0                	call   *%eax
80102170:	83 c4 10             	add    $0x10,%esp
80102173:	e9 15 01 00 00       	jmp    8010228d <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102178:	8b 45 08             	mov    0x8(%ebp),%eax
8010217b:	8b 40 58             	mov    0x58(%eax),%eax
8010217e:	39 45 10             	cmp    %eax,0x10(%ebp)
80102181:	77 0d                	ja     80102190 <writei+0x8b>
80102183:	8b 55 10             	mov    0x10(%ebp),%edx
80102186:	8b 45 14             	mov    0x14(%ebp),%eax
80102189:	01 d0                	add    %edx,%eax
8010218b:	39 45 10             	cmp    %eax,0x10(%ebp)
8010218e:	76 0a                	jbe    8010219a <writei+0x95>
    return -1;
80102190:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102195:	e9 f3 00 00 00       	jmp    8010228d <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
8010219a:	8b 55 10             	mov    0x10(%ebp),%edx
8010219d:	8b 45 14             	mov    0x14(%ebp),%eax
801021a0:	01 d0                	add    %edx,%eax
801021a2:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021a7:	76 0a                	jbe    801021b3 <writei+0xae>
    return -1;
801021a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ae:	e9 da 00 00 00       	jmp    8010228d <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021ba:	e9 97 00 00 00       	jmp    80102256 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021bf:	8b 45 10             	mov    0x10(%ebp),%eax
801021c2:	c1 e8 09             	shr    $0x9,%eax
801021c5:	83 ec 08             	sub    $0x8,%esp
801021c8:	50                   	push   %eax
801021c9:	ff 75 08             	pushl  0x8(%ebp)
801021cc:	e8 39 fb ff ff       	call   80101d0a <bmap>
801021d1:	83 c4 10             	add    $0x10,%esp
801021d4:	8b 55 08             	mov    0x8(%ebp),%edx
801021d7:	8b 12                	mov    (%edx),%edx
801021d9:	83 ec 08             	sub    $0x8,%esp
801021dc:	50                   	push   %eax
801021dd:	52                   	push   %edx
801021de:	e8 f4 df ff ff       	call   801001d7 <bread>
801021e3:	83 c4 10             	add    $0x10,%esp
801021e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021e9:	8b 45 10             	mov    0x10(%ebp),%eax
801021ec:	25 ff 01 00 00       	and    $0x1ff,%eax
801021f1:	ba 00 02 00 00       	mov    $0x200,%edx
801021f6:	29 c2                	sub    %eax,%edx
801021f8:	8b 45 14             	mov    0x14(%ebp),%eax
801021fb:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021fe:	39 c2                	cmp    %eax,%edx
80102200:	0f 46 c2             	cmovbe %edx,%eax
80102203:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102206:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102209:	8d 50 5c             	lea    0x5c(%eax),%edx
8010220c:	8b 45 10             	mov    0x10(%ebp),%eax
8010220f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102214:	01 d0                	add    %edx,%eax
80102216:	83 ec 04             	sub    $0x4,%esp
80102219:	ff 75 ec             	pushl  -0x14(%ebp)
8010221c:	ff 75 0c             	pushl  0xc(%ebp)
8010221f:	50                   	push   %eax
80102220:	e8 e7 35 00 00       	call   8010580c <memmove>
80102225:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102228:	83 ec 0c             	sub    $0xc,%esp
8010222b:	ff 75 f0             	pushl  -0x10(%ebp)
8010222e:	e8 89 16 00 00       	call   801038bc <log_write>
80102233:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102236:	83 ec 0c             	sub    $0xc,%esp
80102239:	ff 75 f0             	pushl  -0x10(%ebp)
8010223c:	e8 20 e0 ff ff       	call   80100261 <brelse>
80102241:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102244:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102247:	01 45 f4             	add    %eax,-0xc(%ebp)
8010224a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010224d:	01 45 10             	add    %eax,0x10(%ebp)
80102250:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102253:	01 45 0c             	add    %eax,0xc(%ebp)
80102256:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102259:	3b 45 14             	cmp    0x14(%ebp),%eax
8010225c:	0f 82 5d ff ff ff    	jb     801021bf <writei+0xba>
  }

  if(n > 0 && off > ip->size){
80102262:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102266:	74 22                	je     8010228a <writei+0x185>
80102268:	8b 45 08             	mov    0x8(%ebp),%eax
8010226b:	8b 40 58             	mov    0x58(%eax),%eax
8010226e:	39 45 10             	cmp    %eax,0x10(%ebp)
80102271:	76 17                	jbe    8010228a <writei+0x185>
    ip->size = off;
80102273:	8b 45 08             	mov    0x8(%ebp),%eax
80102276:	8b 55 10             	mov    0x10(%ebp),%edx
80102279:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010227c:	83 ec 0c             	sub    $0xc,%esp
8010227f:	ff 75 08             	pushl  0x8(%ebp)
80102282:	e8 34 f6 ff ff       	call   801018bb <iupdate>
80102287:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010228a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010228d:	c9                   	leave  
8010228e:	c3                   	ret    

8010228f <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010228f:	f3 0f 1e fb          	endbr32 
80102293:	55                   	push   %ebp
80102294:	89 e5                	mov    %esp,%ebp
80102296:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102299:	83 ec 04             	sub    $0x4,%esp
8010229c:	6a 0e                	push   $0xe
8010229e:	ff 75 0c             	pushl  0xc(%ebp)
801022a1:	ff 75 08             	pushl  0x8(%ebp)
801022a4:	e8 01 36 00 00       	call   801058aa <strncmp>
801022a9:	83 c4 10             	add    $0x10,%esp
}
801022ac:	c9                   	leave  
801022ad:	c3                   	ret    

801022ae <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022ae:	f3 0f 1e fb          	endbr32 
801022b2:	55                   	push   %ebp
801022b3:	89 e5                	mov    %esp,%ebp
801022b5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022b8:	8b 45 08             	mov    0x8(%ebp),%eax
801022bb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801022bf:	66 83 f8 01          	cmp    $0x1,%ax
801022c3:	74 0d                	je     801022d2 <dirlookup+0x24>
    panic("dirlookup not DIR");
801022c5:	83 ec 0c             	sub    $0xc,%esp
801022c8:	68 85 8b 10 80       	push   $0x80108b85
801022cd:	e8 ff e2 ff ff       	call   801005d1 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d9:	eb 7b                	jmp    80102356 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022db:	6a 10                	push   $0x10
801022dd:	ff 75 f4             	pushl  -0xc(%ebp)
801022e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e3:	50                   	push   %eax
801022e4:	ff 75 08             	pushl  0x8(%ebp)
801022e7:	e8 c0 fc ff ff       	call   80101fac <readi>
801022ec:	83 c4 10             	add    $0x10,%esp
801022ef:	83 f8 10             	cmp    $0x10,%eax
801022f2:	74 0d                	je     80102301 <dirlookup+0x53>
      panic("dirlookup read");
801022f4:	83 ec 0c             	sub    $0xc,%esp
801022f7:	68 97 8b 10 80       	push   $0x80108b97
801022fc:	e8 d0 e2 ff ff       	call   801005d1 <panic>
    if(de.inum == 0)
80102301:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102305:	66 85 c0             	test   %ax,%ax
80102308:	74 47                	je     80102351 <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
8010230a:	83 ec 08             	sub    $0x8,%esp
8010230d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102310:	83 c0 02             	add    $0x2,%eax
80102313:	50                   	push   %eax
80102314:	ff 75 0c             	pushl  0xc(%ebp)
80102317:	e8 73 ff ff ff       	call   8010228f <namecmp>
8010231c:	83 c4 10             	add    $0x10,%esp
8010231f:	85 c0                	test   %eax,%eax
80102321:	75 2f                	jne    80102352 <dirlookup+0xa4>
      // entry matches path element
      if(poff)
80102323:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102327:	74 08                	je     80102331 <dirlookup+0x83>
        *poff = off;
80102329:	8b 45 10             	mov    0x10(%ebp),%eax
8010232c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010232f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102331:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102335:	0f b7 c0             	movzwl %ax,%eax
80102338:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010233b:	8b 45 08             	mov    0x8(%ebp),%eax
8010233e:	8b 00                	mov    (%eax),%eax
80102340:	83 ec 08             	sub    $0x8,%esp
80102343:	ff 75 f0             	pushl  -0x10(%ebp)
80102346:	50                   	push   %eax
80102347:	e8 34 f6 ff ff       	call   80101980 <iget>
8010234c:	83 c4 10             	add    $0x10,%esp
8010234f:	eb 19                	jmp    8010236a <dirlookup+0xbc>
      continue;
80102351:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102352:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102356:	8b 45 08             	mov    0x8(%ebp),%eax
80102359:	8b 40 58             	mov    0x58(%eax),%eax
8010235c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010235f:	0f 82 76 ff ff ff    	jb     801022db <dirlookup+0x2d>
    }
  }

  return 0;
80102365:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010236a:	c9                   	leave  
8010236b:	c3                   	ret    

8010236c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010236c:	f3 0f 1e fb          	endbr32 
80102370:	55                   	push   %ebp
80102371:	89 e5                	mov    %esp,%ebp
80102373:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102376:	83 ec 04             	sub    $0x4,%esp
80102379:	6a 00                	push   $0x0
8010237b:	ff 75 0c             	pushl  0xc(%ebp)
8010237e:	ff 75 08             	pushl  0x8(%ebp)
80102381:	e8 28 ff ff ff       	call   801022ae <dirlookup>
80102386:	83 c4 10             	add    $0x10,%esp
80102389:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010238c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102390:	74 18                	je     801023aa <dirlink+0x3e>
    iput(ip);
80102392:	83 ec 0c             	sub    $0xc,%esp
80102395:	ff 75 f0             	pushl  -0x10(%ebp)
80102398:	e8 70 f8 ff ff       	call   80101c0d <iput>
8010239d:	83 c4 10             	add    $0x10,%esp
    return -1;
801023a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023a5:	e9 9c 00 00 00       	jmp    80102446 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b1:	eb 39                	jmp    801023ec <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b6:	6a 10                	push   $0x10
801023b8:	50                   	push   %eax
801023b9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023bc:	50                   	push   %eax
801023bd:	ff 75 08             	pushl  0x8(%ebp)
801023c0:	e8 e7 fb ff ff       	call   80101fac <readi>
801023c5:	83 c4 10             	add    $0x10,%esp
801023c8:	83 f8 10             	cmp    $0x10,%eax
801023cb:	74 0d                	je     801023da <dirlink+0x6e>
      panic("dirlink read");
801023cd:	83 ec 0c             	sub    $0xc,%esp
801023d0:	68 a6 8b 10 80       	push   $0x80108ba6
801023d5:	e8 f7 e1 ff ff       	call   801005d1 <panic>
    if(de.inum == 0)
801023da:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023de:	66 85 c0             	test   %ax,%ax
801023e1:	74 18                	je     801023fb <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e6:	83 c0 10             	add    $0x10,%eax
801023e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ec:	8b 45 08             	mov    0x8(%ebp),%eax
801023ef:	8b 50 58             	mov    0x58(%eax),%edx
801023f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f5:	39 c2                	cmp    %eax,%edx
801023f7:	77 ba                	ja     801023b3 <dirlink+0x47>
801023f9:	eb 01                	jmp    801023fc <dirlink+0x90>
      break;
801023fb:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023fc:	83 ec 04             	sub    $0x4,%esp
801023ff:	6a 0e                	push   $0xe
80102401:	ff 75 0c             	pushl  0xc(%ebp)
80102404:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102407:	83 c0 02             	add    $0x2,%eax
8010240a:	50                   	push   %eax
8010240b:	e8 f4 34 00 00       	call   80105904 <strncpy>
80102410:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102413:	8b 45 10             	mov    0x10(%ebp),%eax
80102416:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010241a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241d:	6a 10                	push   $0x10
8010241f:	50                   	push   %eax
80102420:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102423:	50                   	push   %eax
80102424:	ff 75 08             	pushl  0x8(%ebp)
80102427:	e8 d9 fc ff ff       	call   80102105 <writei>
8010242c:	83 c4 10             	add    $0x10,%esp
8010242f:	83 f8 10             	cmp    $0x10,%eax
80102432:	74 0d                	je     80102441 <dirlink+0xd5>
    panic("dirlink");
80102434:	83 ec 0c             	sub    $0xc,%esp
80102437:	68 b3 8b 10 80       	push   $0x80108bb3
8010243c:	e8 90 e1 ff ff       	call   801005d1 <panic>

  return 0;
80102441:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102446:	c9                   	leave  
80102447:	c3                   	ret    

80102448 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102448:	f3 0f 1e fb          	endbr32 
8010244c:	55                   	push   %ebp
8010244d:	89 e5                	mov    %esp,%ebp
8010244f:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102452:	eb 04                	jmp    80102458 <skipelem+0x10>
    path++;
80102454:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102458:	8b 45 08             	mov    0x8(%ebp),%eax
8010245b:	0f b6 00             	movzbl (%eax),%eax
8010245e:	3c 2f                	cmp    $0x2f,%al
80102460:	74 f2                	je     80102454 <skipelem+0xc>
  if(*path == 0)
80102462:	8b 45 08             	mov    0x8(%ebp),%eax
80102465:	0f b6 00             	movzbl (%eax),%eax
80102468:	84 c0                	test   %al,%al
8010246a:	75 07                	jne    80102473 <skipelem+0x2b>
    return 0;
8010246c:	b8 00 00 00 00       	mov    $0x0,%eax
80102471:	eb 77                	jmp    801024ea <skipelem+0xa2>
  s = path;
80102473:	8b 45 08             	mov    0x8(%ebp),%eax
80102476:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102479:	eb 04                	jmp    8010247f <skipelem+0x37>
    path++;
8010247b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
8010247f:	8b 45 08             	mov    0x8(%ebp),%eax
80102482:	0f b6 00             	movzbl (%eax),%eax
80102485:	3c 2f                	cmp    $0x2f,%al
80102487:	74 0a                	je     80102493 <skipelem+0x4b>
80102489:	8b 45 08             	mov    0x8(%ebp),%eax
8010248c:	0f b6 00             	movzbl (%eax),%eax
8010248f:	84 c0                	test   %al,%al
80102491:	75 e8                	jne    8010247b <skipelem+0x33>
  len = path - s;
80102493:	8b 45 08             	mov    0x8(%ebp),%eax
80102496:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102499:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010249c:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024a0:	7e 15                	jle    801024b7 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 0e                	push   $0xe
801024a7:	ff 75 f4             	pushl  -0xc(%ebp)
801024aa:	ff 75 0c             	pushl  0xc(%ebp)
801024ad:	e8 5a 33 00 00       	call   8010580c <memmove>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	eb 26                	jmp    801024dd <skipelem+0x95>
  else {
    memmove(name, s, len);
801024b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024ba:	83 ec 04             	sub    $0x4,%esp
801024bd:	50                   	push   %eax
801024be:	ff 75 f4             	pushl  -0xc(%ebp)
801024c1:	ff 75 0c             	pushl  0xc(%ebp)
801024c4:	e8 43 33 00 00       	call   8010580c <memmove>
801024c9:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801024d2:	01 d0                	add    %edx,%eax
801024d4:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024d7:	eb 04                	jmp    801024dd <skipelem+0x95>
    path++;
801024d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024dd:	8b 45 08             	mov    0x8(%ebp),%eax
801024e0:	0f b6 00             	movzbl (%eax),%eax
801024e3:	3c 2f                	cmp    $0x2f,%al
801024e5:	74 f2                	je     801024d9 <skipelem+0x91>
  return path;
801024e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024ea:	c9                   	leave  
801024eb:	c3                   	ret    

801024ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024ec:	f3 0f 1e fb          	endbr32 
801024f0:	55                   	push   %ebp
801024f1:	89 e5                	mov    %esp,%ebp
801024f3:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024f6:	8b 45 08             	mov    0x8(%ebp),%eax
801024f9:	0f b6 00             	movzbl (%eax),%eax
801024fc:	3c 2f                	cmp    $0x2f,%al
801024fe:	75 17                	jne    80102517 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102500:	83 ec 08             	sub    $0x8,%esp
80102503:	6a 01                	push   $0x1
80102505:	6a 01                	push   $0x1
80102507:	e8 74 f4 ff ff       	call   80101980 <iget>
8010250c:	83 c4 10             	add    $0x10,%esp
8010250f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102512:	e9 ba 00 00 00       	jmp    801025d1 <namex+0xe5>
  else
    ip = idup(myproc()->cwd);
80102517:	e8 15 1f 00 00       	call   80104431 <myproc>
8010251c:	8b 40 68             	mov    0x68(%eax),%eax
8010251f:	83 ec 0c             	sub    $0xc,%esp
80102522:	50                   	push   %eax
80102523:	e8 3e f5 ff ff       	call   80101a66 <idup>
80102528:	83 c4 10             	add    $0x10,%esp
8010252b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010252e:	e9 9e 00 00 00       	jmp    801025d1 <namex+0xe5>
    ilock(ip);
80102533:	83 ec 0c             	sub    $0xc,%esp
80102536:	ff 75 f4             	pushl  -0xc(%ebp)
80102539:	e8 66 f5 ff ff       	call   80101aa4 <ilock>
8010253e:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102544:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102548:	66 83 f8 01          	cmp    $0x1,%ax
8010254c:	74 18                	je     80102566 <namex+0x7a>
      iunlockput(ip);
8010254e:	83 ec 0c             	sub    $0xc,%esp
80102551:	ff 75 f4             	pushl  -0xc(%ebp)
80102554:	e8 88 f7 ff ff       	call   80101ce1 <iunlockput>
80102559:	83 c4 10             	add    $0x10,%esp
      return 0;
8010255c:	b8 00 00 00 00       	mov    $0x0,%eax
80102561:	e9 a7 00 00 00       	jmp    8010260d <namex+0x121>
    }
    if(nameiparent && *path == '\0'){
80102566:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010256a:	74 20                	je     8010258c <namex+0xa0>
8010256c:	8b 45 08             	mov    0x8(%ebp),%eax
8010256f:	0f b6 00             	movzbl (%eax),%eax
80102572:	84 c0                	test   %al,%al
80102574:	75 16                	jne    8010258c <namex+0xa0>
      // Stop one level early.
      iunlock(ip);
80102576:	83 ec 0c             	sub    $0xc,%esp
80102579:	ff 75 f4             	pushl  -0xc(%ebp)
8010257c:	e8 3a f6 ff ff       	call   80101bbb <iunlock>
80102581:	83 c4 10             	add    $0x10,%esp
      return ip;
80102584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102587:	e9 81 00 00 00       	jmp    8010260d <namex+0x121>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010258c:	83 ec 04             	sub    $0x4,%esp
8010258f:	6a 00                	push   $0x0
80102591:	ff 75 10             	pushl  0x10(%ebp)
80102594:	ff 75 f4             	pushl  -0xc(%ebp)
80102597:	e8 12 fd ff ff       	call   801022ae <dirlookup>
8010259c:	83 c4 10             	add    $0x10,%esp
8010259f:	89 45 f0             	mov    %eax,-0x10(%ebp)
801025a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025a6:	75 15                	jne    801025bd <namex+0xd1>
      iunlockput(ip);
801025a8:	83 ec 0c             	sub    $0xc,%esp
801025ab:	ff 75 f4             	pushl  -0xc(%ebp)
801025ae:	e8 2e f7 ff ff       	call   80101ce1 <iunlockput>
801025b3:	83 c4 10             	add    $0x10,%esp
      return 0;
801025b6:	b8 00 00 00 00       	mov    $0x0,%eax
801025bb:	eb 50                	jmp    8010260d <namex+0x121>
    }
    iunlockput(ip);
801025bd:	83 ec 0c             	sub    $0xc,%esp
801025c0:	ff 75 f4             	pushl  -0xc(%ebp)
801025c3:	e8 19 f7 ff ff       	call   80101ce1 <iunlockput>
801025c8:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025d1:	83 ec 08             	sub    $0x8,%esp
801025d4:	ff 75 10             	pushl  0x10(%ebp)
801025d7:	ff 75 08             	pushl  0x8(%ebp)
801025da:	e8 69 fe ff ff       	call   80102448 <skipelem>
801025df:	83 c4 10             	add    $0x10,%esp
801025e2:	89 45 08             	mov    %eax,0x8(%ebp)
801025e5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025e9:	0f 85 44 ff ff ff    	jne    80102533 <namex+0x47>
  }
  if(nameiparent){
801025ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025f3:	74 15                	je     8010260a <namex+0x11e>
    iput(ip);
801025f5:	83 ec 0c             	sub    $0xc,%esp
801025f8:	ff 75 f4             	pushl  -0xc(%ebp)
801025fb:	e8 0d f6 ff ff       	call   80101c0d <iput>
80102600:	83 c4 10             	add    $0x10,%esp
    return 0;
80102603:	b8 00 00 00 00       	mov    $0x0,%eax
80102608:	eb 03                	jmp    8010260d <namex+0x121>
  }
  return ip;
8010260a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010260d:	c9                   	leave  
8010260e:	c3                   	ret    

8010260f <namei>:

struct inode*
namei(char *path)
{
8010260f:	f3 0f 1e fb          	endbr32 
80102613:	55                   	push   %ebp
80102614:	89 e5                	mov    %esp,%ebp
80102616:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102619:	83 ec 04             	sub    $0x4,%esp
8010261c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010261f:	50                   	push   %eax
80102620:	6a 00                	push   $0x0
80102622:	ff 75 08             	pushl  0x8(%ebp)
80102625:	e8 c2 fe ff ff       	call   801024ec <namex>
8010262a:	83 c4 10             	add    $0x10,%esp
}
8010262d:	c9                   	leave  
8010262e:	c3                   	ret    

8010262f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010262f:	f3 0f 1e fb          	endbr32 
80102633:	55                   	push   %ebp
80102634:	89 e5                	mov    %esp,%ebp
80102636:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102639:	83 ec 04             	sub    $0x4,%esp
8010263c:	ff 75 0c             	pushl  0xc(%ebp)
8010263f:	6a 01                	push   $0x1
80102641:	ff 75 08             	pushl  0x8(%ebp)
80102644:	e8 a3 fe ff ff       	call   801024ec <namex>
80102649:	83 c4 10             	add    $0x10,%esp
}
8010264c:	c9                   	leave  
8010264d:	c3                   	ret    

8010264e <inb>:
{
8010264e:	55                   	push   %ebp
8010264f:	89 e5                	mov    %esp,%ebp
80102651:	83 ec 14             	sub    $0x14,%esp
80102654:	8b 45 08             	mov    0x8(%ebp),%eax
80102657:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010265b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010265f:	89 c2                	mov    %eax,%edx
80102661:	ec                   	in     (%dx),%al
80102662:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102665:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102669:	c9                   	leave  
8010266a:	c3                   	ret    

8010266b <insl>:
{
8010266b:	55                   	push   %ebp
8010266c:	89 e5                	mov    %esp,%ebp
8010266e:	57                   	push   %edi
8010266f:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102670:	8b 55 08             	mov    0x8(%ebp),%edx
80102673:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102676:	8b 45 10             	mov    0x10(%ebp),%eax
80102679:	89 cb                	mov    %ecx,%ebx
8010267b:	89 df                	mov    %ebx,%edi
8010267d:	89 c1                	mov    %eax,%ecx
8010267f:	fc                   	cld    
80102680:	f3 6d                	rep insl (%dx),%es:(%edi)
80102682:	89 c8                	mov    %ecx,%eax
80102684:	89 fb                	mov    %edi,%ebx
80102686:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102689:	89 45 10             	mov    %eax,0x10(%ebp)
}
8010268c:	90                   	nop
8010268d:	5b                   	pop    %ebx
8010268e:	5f                   	pop    %edi
8010268f:	5d                   	pop    %ebp
80102690:	c3                   	ret    

80102691 <outb>:
{
80102691:	55                   	push   %ebp
80102692:	89 e5                	mov    %esp,%ebp
80102694:	83 ec 08             	sub    $0x8,%esp
80102697:	8b 45 08             	mov    0x8(%ebp),%eax
8010269a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010269d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801026a1:	89 d0                	mov    %edx,%eax
801026a3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801026a6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801026aa:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801026ae:	ee                   	out    %al,(%dx)
}
801026af:	90                   	nop
801026b0:	c9                   	leave  
801026b1:	c3                   	ret    

801026b2 <outsl>:
{
801026b2:	55                   	push   %ebp
801026b3:	89 e5                	mov    %esp,%ebp
801026b5:	56                   	push   %esi
801026b6:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801026b7:	8b 55 08             	mov    0x8(%ebp),%edx
801026ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026bd:	8b 45 10             	mov    0x10(%ebp),%eax
801026c0:	89 cb                	mov    %ecx,%ebx
801026c2:	89 de                	mov    %ebx,%esi
801026c4:	89 c1                	mov    %eax,%ecx
801026c6:	fc                   	cld    
801026c7:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801026c9:	89 c8                	mov    %ecx,%eax
801026cb:	89 f3                	mov    %esi,%ebx
801026cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026d0:	89 45 10             	mov    %eax,0x10(%ebp)
}
801026d3:	90                   	nop
801026d4:	5b                   	pop    %ebx
801026d5:	5e                   	pop    %esi
801026d6:	5d                   	pop    %ebp
801026d7:	c3                   	ret    

801026d8 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801026d8:	f3 0f 1e fb          	endbr32 
801026dc:	55                   	push   %ebp
801026dd:	89 e5                	mov    %esp,%ebp
801026df:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801026e2:	90                   	nop
801026e3:	68 f7 01 00 00       	push   $0x1f7
801026e8:	e8 61 ff ff ff       	call   8010264e <inb>
801026ed:	83 c4 04             	add    $0x4,%esp
801026f0:	0f b6 c0             	movzbl %al,%eax
801026f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026f9:	25 c0 00 00 00       	and    $0xc0,%eax
801026fe:	83 f8 40             	cmp    $0x40,%eax
80102701:	75 e0                	jne    801026e3 <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102703:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102707:	74 11                	je     8010271a <idewait+0x42>
80102709:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010270c:	83 e0 21             	and    $0x21,%eax
8010270f:	85 c0                	test   %eax,%eax
80102711:	74 07                	je     8010271a <idewait+0x42>
    return -1;
80102713:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102718:	eb 05                	jmp    8010271f <idewait+0x47>
  return 0;
8010271a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010271f:	c9                   	leave  
80102720:	c3                   	ret    

80102721 <ideinit>:

void
ideinit(void)
{
80102721:	f3 0f 1e fb          	endbr32 
80102725:	55                   	push   %ebp
80102726:	89 e5                	mov    %esp,%ebp
80102728:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
8010272b:	83 ec 08             	sub    $0x8,%esp
8010272e:	68 bb 8b 10 80       	push   $0x80108bbb
80102733:	68 e0 c5 10 80       	push   $0x8010c5e0
80102738:	e8 43 2d 00 00       	call   80105480 <initlock>
8010273d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102740:	a1 b0 48 11 80       	mov    0x801148b0,%eax
80102745:	83 e8 01             	sub    $0x1,%eax
80102748:	83 ec 08             	sub    $0x8,%esp
8010274b:	50                   	push   %eax
8010274c:	6a 0e                	push   $0xe
8010274e:	e8 bb 04 00 00       	call   80102c0e <ioapicenable>
80102753:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102756:	83 ec 0c             	sub    $0xc,%esp
80102759:	6a 00                	push   $0x0
8010275b:	e8 78 ff ff ff       	call   801026d8 <idewait>
80102760:	83 c4 10             	add    $0x10,%esp

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102763:	83 ec 08             	sub    $0x8,%esp
80102766:	68 f0 00 00 00       	push   $0xf0
8010276b:	68 f6 01 00 00       	push   $0x1f6
80102770:	e8 1c ff ff ff       	call   80102691 <outb>
80102775:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010277f:	eb 24                	jmp    801027a5 <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102781:	83 ec 0c             	sub    $0xc,%esp
80102784:	68 f7 01 00 00       	push   $0x1f7
80102789:	e8 c0 fe ff ff       	call   8010264e <inb>
8010278e:	83 c4 10             	add    $0x10,%esp
80102791:	84 c0                	test   %al,%al
80102793:	74 0c                	je     801027a1 <ideinit+0x80>
      havedisk1 = 1;
80102795:	c7 05 18 c6 10 80 01 	movl   $0x1,0x8010c618
8010279c:	00 00 00 
      break;
8010279f:	eb 0d                	jmp    801027ae <ideinit+0x8d>
  for(i=0; i<1000; i++){
801027a1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801027a5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801027ac:	7e d3                	jle    80102781 <ideinit+0x60>
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801027ae:	83 ec 08             	sub    $0x8,%esp
801027b1:	68 e0 00 00 00       	push   $0xe0
801027b6:	68 f6 01 00 00       	push   $0x1f6
801027bb:	e8 d1 fe ff ff       	call   80102691 <outb>
801027c0:	83 c4 10             	add    $0x10,%esp
}
801027c3:	90                   	nop
801027c4:	c9                   	leave  
801027c5:	c3                   	ret    

801027c6 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801027c6:	f3 0f 1e fb          	endbr32 
801027ca:	55                   	push   %ebp
801027cb:	89 e5                	mov    %esp,%ebp
801027cd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801027d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027d4:	75 0d                	jne    801027e3 <idestart+0x1d>
    panic("idestart");
801027d6:	83 ec 0c             	sub    $0xc,%esp
801027d9:	68 bf 8b 10 80       	push   $0x80108bbf
801027de:	e8 ee dd ff ff       	call   801005d1 <panic>
  if(b->blockno >= FSSIZE)
801027e3:	8b 45 08             	mov    0x8(%ebp),%eax
801027e6:	8b 40 08             	mov    0x8(%eax),%eax
801027e9:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801027ee:	76 0d                	jbe    801027fd <idestart+0x37>
    panic("incorrect blockno");
801027f0:	83 ec 0c             	sub    $0xc,%esp
801027f3:	68 c8 8b 10 80       	push   $0x80108bc8
801027f8:	e8 d4 dd ff ff       	call   801005d1 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027fd:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102804:	8b 45 08             	mov    0x8(%ebp),%eax
80102807:	8b 50 08             	mov    0x8(%eax),%edx
8010280a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280d:	0f af c2             	imul   %edx,%eax
80102810:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102813:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102817:	75 07                	jne    80102820 <idestart+0x5a>
80102819:	b8 20 00 00 00       	mov    $0x20,%eax
8010281e:	eb 05                	jmp    80102825 <idestart+0x5f>
80102820:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102825:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102828:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010282c:	75 07                	jne    80102835 <idestart+0x6f>
8010282e:	b8 30 00 00 00       	mov    $0x30,%eax
80102833:	eb 05                	jmp    8010283a <idestart+0x74>
80102835:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010283a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010283d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102841:	7e 0d                	jle    80102850 <idestart+0x8a>
80102843:	83 ec 0c             	sub    $0xc,%esp
80102846:	68 bf 8b 10 80       	push   $0x80108bbf
8010284b:	e8 81 dd ff ff       	call   801005d1 <panic>

  idewait(0);
80102850:	83 ec 0c             	sub    $0xc,%esp
80102853:	6a 00                	push   $0x0
80102855:	e8 7e fe ff ff       	call   801026d8 <idewait>
8010285a:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010285d:	83 ec 08             	sub    $0x8,%esp
80102860:	6a 00                	push   $0x0
80102862:	68 f6 03 00 00       	push   $0x3f6
80102867:	e8 25 fe ff ff       	call   80102691 <outb>
8010286c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010286f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102872:	0f b6 c0             	movzbl %al,%eax
80102875:	83 ec 08             	sub    $0x8,%esp
80102878:	50                   	push   %eax
80102879:	68 f2 01 00 00       	push   $0x1f2
8010287e:	e8 0e fe ff ff       	call   80102691 <outb>
80102883:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102886:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102889:	0f b6 c0             	movzbl %al,%eax
8010288c:	83 ec 08             	sub    $0x8,%esp
8010288f:	50                   	push   %eax
80102890:	68 f3 01 00 00       	push   $0x1f3
80102895:	e8 f7 fd ff ff       	call   80102691 <outb>
8010289a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
8010289d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028a0:	c1 f8 08             	sar    $0x8,%eax
801028a3:	0f b6 c0             	movzbl %al,%eax
801028a6:	83 ec 08             	sub    $0x8,%esp
801028a9:	50                   	push   %eax
801028aa:	68 f4 01 00 00       	push   $0x1f4
801028af:	e8 dd fd ff ff       	call   80102691 <outb>
801028b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801028b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ba:	c1 f8 10             	sar    $0x10,%eax
801028bd:	0f b6 c0             	movzbl %al,%eax
801028c0:	83 ec 08             	sub    $0x8,%esp
801028c3:	50                   	push   %eax
801028c4:	68 f5 01 00 00       	push   $0x1f5
801028c9:	e8 c3 fd ff ff       	call   80102691 <outb>
801028ce:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801028d1:	8b 45 08             	mov    0x8(%ebp),%eax
801028d4:	8b 40 04             	mov    0x4(%eax),%eax
801028d7:	c1 e0 04             	shl    $0x4,%eax
801028da:	83 e0 10             	and    $0x10,%eax
801028dd:	89 c2                	mov    %eax,%edx
801028df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028e2:	c1 f8 18             	sar    $0x18,%eax
801028e5:	83 e0 0f             	and    $0xf,%eax
801028e8:	09 d0                	or     %edx,%eax
801028ea:	83 c8 e0             	or     $0xffffffe0,%eax
801028ed:	0f b6 c0             	movzbl %al,%eax
801028f0:	83 ec 08             	sub    $0x8,%esp
801028f3:	50                   	push   %eax
801028f4:	68 f6 01 00 00       	push   $0x1f6
801028f9:	e8 93 fd ff ff       	call   80102691 <outb>
801028fe:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102901:	8b 45 08             	mov    0x8(%ebp),%eax
80102904:	8b 00                	mov    (%eax),%eax
80102906:	83 e0 04             	and    $0x4,%eax
80102909:	85 c0                	test   %eax,%eax
8010290b:	74 35                	je     80102942 <idestart+0x17c>
    outb(0x1f7, write_cmd);
8010290d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102910:	0f b6 c0             	movzbl %al,%eax
80102913:	83 ec 08             	sub    $0x8,%esp
80102916:	50                   	push   %eax
80102917:	68 f7 01 00 00       	push   $0x1f7
8010291c:	e8 70 fd ff ff       	call   80102691 <outb>
80102921:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102924:	8b 45 08             	mov    0x8(%ebp),%eax
80102927:	83 c0 5c             	add    $0x5c,%eax
8010292a:	83 ec 04             	sub    $0x4,%esp
8010292d:	68 80 00 00 00       	push   $0x80
80102932:	50                   	push   %eax
80102933:	68 f0 01 00 00       	push   $0x1f0
80102938:	e8 75 fd ff ff       	call   801026b2 <outsl>
8010293d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, read_cmd);
  }
}
80102940:	eb 17                	jmp    80102959 <idestart+0x193>
    outb(0x1f7, read_cmd);
80102942:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102945:	0f b6 c0             	movzbl %al,%eax
80102948:	83 ec 08             	sub    $0x8,%esp
8010294b:	50                   	push   %eax
8010294c:	68 f7 01 00 00       	push   $0x1f7
80102951:	e8 3b fd ff ff       	call   80102691 <outb>
80102956:	83 c4 10             	add    $0x10,%esp
}
80102959:	90                   	nop
8010295a:	c9                   	leave  
8010295b:	c3                   	ret    

8010295c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010295c:	f3 0f 1e fb          	endbr32 
80102960:	55                   	push   %ebp
80102961:	89 e5                	mov    %esp,%ebp
80102963:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102966:	83 ec 0c             	sub    $0xc,%esp
80102969:	68 e0 c5 10 80       	push   $0x8010c5e0
8010296e:	e8 33 2b 00 00       	call   801054a6 <acquire>
80102973:	83 c4 10             	add    $0x10,%esp

  if((b = idequeue) == 0){
80102976:	a1 14 c6 10 80       	mov    0x8010c614,%eax
8010297b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010297e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102982:	75 15                	jne    80102999 <ideintr+0x3d>
    release(&idelock);
80102984:	83 ec 0c             	sub    $0xc,%esp
80102987:	68 e0 c5 10 80       	push   $0x8010c5e0
8010298c:	e8 87 2b 00 00       	call   80105518 <release>
80102991:	83 c4 10             	add    $0x10,%esp
    return;
80102994:	e9 9a 00 00 00       	jmp    80102a33 <ideintr+0xd7>
  }
  idequeue = b->qnext;
80102999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299c:	8b 40 58             	mov    0x58(%eax),%eax
8010299f:	a3 14 c6 10 80       	mov    %eax,0x8010c614

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801029a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a7:	8b 00                	mov    (%eax),%eax
801029a9:	83 e0 04             	and    $0x4,%eax
801029ac:	85 c0                	test   %eax,%eax
801029ae:	75 2d                	jne    801029dd <ideintr+0x81>
801029b0:	83 ec 0c             	sub    $0xc,%esp
801029b3:	6a 01                	push   $0x1
801029b5:	e8 1e fd ff ff       	call   801026d8 <idewait>
801029ba:	83 c4 10             	add    $0x10,%esp
801029bd:	85 c0                	test   %eax,%eax
801029bf:	78 1c                	js     801029dd <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
801029c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c4:	83 c0 5c             	add    $0x5c,%eax
801029c7:	83 ec 04             	sub    $0x4,%esp
801029ca:	68 80 00 00 00       	push   $0x80
801029cf:	50                   	push   %eax
801029d0:	68 f0 01 00 00       	push   $0x1f0
801029d5:	e8 91 fc ff ff       	call   8010266b <insl>
801029da:	83 c4 10             	add    $0x10,%esp

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801029dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e0:	8b 00                	mov    (%eax),%eax
801029e2:	83 c8 02             	or     $0x2,%eax
801029e5:	89 c2                	mov    %eax,%edx
801029e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ea:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801029ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029ef:	8b 00                	mov    (%eax),%eax
801029f1:	83 e0 fb             	and    $0xfffffffb,%eax
801029f4:	89 c2                	mov    %eax,%edx
801029f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f9:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801029fb:	83 ec 0c             	sub    $0xc,%esp
801029fe:	ff 75 f4             	pushl  -0xc(%ebp)
80102a01:	e8 70 26 00 00       	call   80105076 <wakeup>
80102a06:	83 c4 10             	add    $0x10,%esp

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a09:	a1 14 c6 10 80       	mov    0x8010c614,%eax
80102a0e:	85 c0                	test   %eax,%eax
80102a10:	74 11                	je     80102a23 <ideintr+0xc7>
    idestart(idequeue);
80102a12:	a1 14 c6 10 80       	mov    0x8010c614,%eax
80102a17:	83 ec 0c             	sub    $0xc,%esp
80102a1a:	50                   	push   %eax
80102a1b:	e8 a6 fd ff ff       	call   801027c6 <idestart>
80102a20:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80102a23:	83 ec 0c             	sub    $0xc,%esp
80102a26:	68 e0 c5 10 80       	push   $0x8010c5e0
80102a2b:	e8 e8 2a 00 00       	call   80105518 <release>
80102a30:	83 c4 10             	add    $0x10,%esp
}
80102a33:	c9                   	leave  
80102a34:	c3                   	ret    

80102a35 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a35:	f3 0f 1e fb          	endbr32 
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
80102a3c:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a42:	83 c0 0c             	add    $0xc,%eax
80102a45:	83 ec 0c             	sub    $0xc,%esp
80102a48:	50                   	push   %eax
80102a49:	e8 99 29 00 00       	call   801053e7 <holdingsleep>
80102a4e:	83 c4 10             	add    $0x10,%esp
80102a51:	85 c0                	test   %eax,%eax
80102a53:	75 0d                	jne    80102a62 <iderw+0x2d>
    panic("iderw: buf not locked");
80102a55:	83 ec 0c             	sub    $0xc,%esp
80102a58:	68 da 8b 10 80       	push   $0x80108bda
80102a5d:	e8 6f db ff ff       	call   801005d1 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a62:	8b 45 08             	mov    0x8(%ebp),%eax
80102a65:	8b 00                	mov    (%eax),%eax
80102a67:	83 e0 06             	and    $0x6,%eax
80102a6a:	83 f8 02             	cmp    $0x2,%eax
80102a6d:	75 0d                	jne    80102a7c <iderw+0x47>
    panic("iderw: nothing to do");
80102a6f:	83 ec 0c             	sub    $0xc,%esp
80102a72:	68 f0 8b 10 80       	push   $0x80108bf0
80102a77:	e8 55 db ff ff       	call   801005d1 <panic>
  if(b->dev != 0 && !havedisk1)
80102a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7f:	8b 40 04             	mov    0x4(%eax),%eax
80102a82:	85 c0                	test   %eax,%eax
80102a84:	74 16                	je     80102a9c <iderw+0x67>
80102a86:	a1 18 c6 10 80       	mov    0x8010c618,%eax
80102a8b:	85 c0                	test   %eax,%eax
80102a8d:	75 0d                	jne    80102a9c <iderw+0x67>
    panic("iderw: ide disk 1 not present");
80102a8f:	83 ec 0c             	sub    $0xc,%esp
80102a92:	68 05 8c 10 80       	push   $0x80108c05
80102a97:	e8 35 db ff ff       	call   801005d1 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a9c:	83 ec 0c             	sub    $0xc,%esp
80102a9f:	68 e0 c5 10 80       	push   $0x8010c5e0
80102aa4:	e8 fd 29 00 00       	call   801054a6 <acquire>
80102aa9:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102aac:	8b 45 08             	mov    0x8(%ebp),%eax
80102aaf:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102ab6:	c7 45 f4 14 c6 10 80 	movl   $0x8010c614,-0xc(%ebp)
80102abd:	eb 0b                	jmp    80102aca <iderw+0x95>
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	8b 00                	mov    (%eax),%eax
80102ac4:	83 c0 58             	add    $0x58,%eax
80102ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acd:	8b 00                	mov    (%eax),%eax
80102acf:	85 c0                	test   %eax,%eax
80102ad1:	75 ec                	jne    80102abf <iderw+0x8a>
    ;
  *pp = b;
80102ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad6:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad9:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102adb:	a1 14 c6 10 80       	mov    0x8010c614,%eax
80102ae0:	39 45 08             	cmp    %eax,0x8(%ebp)
80102ae3:	75 23                	jne    80102b08 <iderw+0xd3>
    idestart(b);
80102ae5:	83 ec 0c             	sub    $0xc,%esp
80102ae8:	ff 75 08             	pushl  0x8(%ebp)
80102aeb:	e8 d6 fc ff ff       	call   801027c6 <idestart>
80102af0:	83 c4 10             	add    $0x10,%esp

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102af3:	eb 13                	jmp    80102b08 <iderw+0xd3>
    sleep(b, &idelock);
80102af5:	83 ec 08             	sub    $0x8,%esp
80102af8:	68 e0 c5 10 80       	push   $0x8010c5e0
80102afd:	ff 75 08             	pushl  0x8(%ebp)
80102b00:	e8 44 24 00 00       	call   80104f49 <sleep>
80102b05:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	8b 00                	mov    (%eax),%eax
80102b0d:	83 e0 06             	and    $0x6,%eax
80102b10:	83 f8 02             	cmp    $0x2,%eax
80102b13:	75 e0                	jne    80102af5 <iderw+0xc0>
  }


  release(&idelock);
80102b15:	83 ec 0c             	sub    $0xc,%esp
80102b18:	68 e0 c5 10 80       	push   $0x8010c5e0
80102b1d:	e8 f6 29 00 00       	call   80105518 <release>
80102b22:	83 c4 10             	add    $0x10,%esp
}
80102b25:	90                   	nop
80102b26:	c9                   	leave  
80102b27:	c3                   	ret    

80102b28 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b28:	f3 0f 1e fb          	endbr32 
80102b2c:	55                   	push   %ebp
80102b2d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b2f:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102b34:	8b 55 08             	mov    0x8(%ebp),%edx
80102b37:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b39:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102b3e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b41:	5d                   	pop    %ebp
80102b42:	c3                   	ret    

80102b43 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b43:	f3 0f 1e fb          	endbr32 
80102b47:	55                   	push   %ebp
80102b48:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b4a:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102b4f:	8b 55 08             	mov    0x8(%ebp),%edx
80102b52:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b54:	a1 b4 46 11 80       	mov    0x801146b4,%eax
80102b59:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b5c:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b5f:	90                   	nop
80102b60:	5d                   	pop    %ebp
80102b61:	c3                   	ret    

80102b62 <ioapicinit>:

void
ioapicinit(void)
{
80102b62:	f3 0f 1e fb          	endbr32 
80102b66:	55                   	push   %ebp
80102b67:	89 e5                	mov    %esp,%ebp
80102b69:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b6c:	c7 05 b4 46 11 80 00 	movl   $0xfec00000,0x801146b4
80102b73:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b76:	6a 01                	push   $0x1
80102b78:	e8 ab ff ff ff       	call   80102b28 <ioapicread>
80102b7d:	83 c4 04             	add    $0x4,%esp
80102b80:	c1 e8 10             	shr    $0x10,%eax
80102b83:	25 ff 00 00 00       	and    $0xff,%eax
80102b88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b8b:	6a 00                	push   $0x0
80102b8d:	e8 96 ff ff ff       	call   80102b28 <ioapicread>
80102b92:	83 c4 04             	add    $0x4,%esp
80102b95:	c1 e8 18             	shr    $0x18,%eax
80102b98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b9b:	0f b6 05 e0 47 11 80 	movzbl 0x801147e0,%eax
80102ba2:	0f b6 c0             	movzbl %al,%eax
80102ba5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102ba8:	74 10                	je     80102bba <ioapicinit+0x58>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102baa:	83 ec 0c             	sub    $0xc,%esp
80102bad:	68 24 8c 10 80       	push   $0x80108c24
80102bb2:	e8 61 d8 ff ff       	call   80100418 <cprintf>
80102bb7:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102bc1:	eb 3f                	jmp    80102c02 <ioapicinit+0xa0>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bc6:	83 c0 20             	add    $0x20,%eax
80102bc9:	0d 00 00 01 00       	or     $0x10000,%eax
80102bce:	89 c2                	mov    %eax,%edx
80102bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd3:	83 c0 08             	add    $0x8,%eax
80102bd6:	01 c0                	add    %eax,%eax
80102bd8:	83 ec 08             	sub    $0x8,%esp
80102bdb:	52                   	push   %edx
80102bdc:	50                   	push   %eax
80102bdd:	e8 61 ff ff ff       	call   80102b43 <ioapicwrite>
80102be2:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be8:	83 c0 08             	add    $0x8,%eax
80102beb:	01 c0                	add    %eax,%eax
80102bed:	83 c0 01             	add    $0x1,%eax
80102bf0:	83 ec 08             	sub    $0x8,%esp
80102bf3:	6a 00                	push   $0x0
80102bf5:	50                   	push   %eax
80102bf6:	e8 48 ff ff ff       	call   80102b43 <ioapicwrite>
80102bfb:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102bfe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c05:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c08:	7e b9                	jle    80102bc3 <ioapicinit+0x61>
  }
}
80102c0a:	90                   	nop
80102c0b:	90                   	nop
80102c0c:	c9                   	leave  
80102c0d:	c3                   	ret    

80102c0e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c0e:	f3 0f 1e fb          	endbr32 
80102c12:	55                   	push   %ebp
80102c13:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c15:	8b 45 08             	mov    0x8(%ebp),%eax
80102c18:	83 c0 20             	add    $0x20,%eax
80102c1b:	89 c2                	mov    %eax,%edx
80102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c20:	83 c0 08             	add    $0x8,%eax
80102c23:	01 c0                	add    %eax,%eax
80102c25:	52                   	push   %edx
80102c26:	50                   	push   %eax
80102c27:	e8 17 ff ff ff       	call   80102b43 <ioapicwrite>
80102c2c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c32:	c1 e0 18             	shl    $0x18,%eax
80102c35:	89 c2                	mov    %eax,%edx
80102c37:	8b 45 08             	mov    0x8(%ebp),%eax
80102c3a:	83 c0 08             	add    $0x8,%eax
80102c3d:	01 c0                	add    %eax,%eax
80102c3f:	83 c0 01             	add    $0x1,%eax
80102c42:	52                   	push   %edx
80102c43:	50                   	push   %eax
80102c44:	e8 fa fe ff ff       	call   80102b43 <ioapicwrite>
80102c49:	83 c4 08             	add    $0x8,%esp
}
80102c4c:	90                   	nop
80102c4d:	c9                   	leave  
80102c4e:	c3                   	ret    

80102c4f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c4f:	f3 0f 1e fb          	endbr32 
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
80102c56:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102c59:	83 ec 08             	sub    $0x8,%esp
80102c5c:	68 56 8c 10 80       	push   $0x80108c56
80102c61:	68 c0 46 11 80       	push   $0x801146c0
80102c66:	e8 15 28 00 00       	call   80105480 <initlock>
80102c6b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102c6e:	c7 05 f4 46 11 80 00 	movl   $0x0,0x801146f4
80102c75:	00 00 00 
  freerange(vstart, vend);
80102c78:	83 ec 08             	sub    $0x8,%esp
80102c7b:	ff 75 0c             	pushl  0xc(%ebp)
80102c7e:	ff 75 08             	pushl  0x8(%ebp)
80102c81:	e8 2e 00 00 00       	call   80102cb4 <freerange>
80102c86:	83 c4 10             	add    $0x10,%esp
}
80102c89:	90                   	nop
80102c8a:	c9                   	leave  
80102c8b:	c3                   	ret    

80102c8c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c8c:	f3 0f 1e fb          	endbr32 
80102c90:	55                   	push   %ebp
80102c91:	89 e5                	mov    %esp,%ebp
80102c93:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c96:	83 ec 08             	sub    $0x8,%esp
80102c99:	ff 75 0c             	pushl  0xc(%ebp)
80102c9c:	ff 75 08             	pushl  0x8(%ebp)
80102c9f:	e8 10 00 00 00       	call   80102cb4 <freerange>
80102ca4:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ca7:	c7 05 f4 46 11 80 01 	movl   $0x1,0x801146f4
80102cae:	00 00 00 
}
80102cb1:	90                   	nop
80102cb2:	c9                   	leave  
80102cb3:	c3                   	ret    

80102cb4 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102cb4:	f3 0f 1e fb          	endbr32 
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc1:	05 ff 0f 00 00       	add    $0xfff,%eax
80102cc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ccb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cce:	eb 15                	jmp    80102ce5 <freerange+0x31>
    kfree(p);
80102cd0:	83 ec 0c             	sub    $0xc,%esp
80102cd3:	ff 75 f4             	pushl  -0xc(%ebp)
80102cd6:	e8 1b 00 00 00       	call   80102cf6 <kfree>
80102cdb:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cde:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce8:	05 00 10 00 00       	add    $0x1000,%eax
80102ced:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102cf0:	73 de                	jae    80102cd0 <freerange+0x1c>
}
80102cf2:	90                   	nop
80102cf3:	90                   	nop
80102cf4:	c9                   	leave  
80102cf5:	c3                   	ret    

80102cf6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cf6:	f3 0f 1e fb          	endbr32 
80102cfa:	55                   	push   %ebp
80102cfb:	89 e5                	mov    %esp,%ebp
80102cfd:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d00:	8b 45 08             	mov    0x8(%ebp),%eax
80102d03:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d08:	85 c0                	test   %eax,%eax
80102d0a:	75 18                	jne    80102d24 <kfree+0x2e>
80102d0c:	81 7d 08 48 73 11 80 	cmpl   $0x80117348,0x8(%ebp)
80102d13:	72 0f                	jb     80102d24 <kfree+0x2e>
80102d15:	8b 45 08             	mov    0x8(%ebp),%eax
80102d18:	05 00 00 00 80       	add    $0x80000000,%eax
80102d1d:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d22:	76 0d                	jbe    80102d31 <kfree+0x3b>
    panic("kfree");
80102d24:	83 ec 0c             	sub    $0xc,%esp
80102d27:	68 5b 8c 10 80       	push   $0x80108c5b
80102d2c:	e8 a0 d8 ff ff       	call   801005d1 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d31:	83 ec 04             	sub    $0x4,%esp
80102d34:	68 00 10 00 00       	push   $0x1000
80102d39:	6a 01                	push   $0x1
80102d3b:	ff 75 08             	pushl  0x8(%ebp)
80102d3e:	e8 02 2a 00 00       	call   80105745 <memset>
80102d43:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102d46:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102d4b:	85 c0                	test   %eax,%eax
80102d4d:	74 10                	je     80102d5f <kfree+0x69>
    acquire(&kmem.lock);
80102d4f:	83 ec 0c             	sub    $0xc,%esp
80102d52:	68 c0 46 11 80       	push   $0x801146c0
80102d57:	e8 4a 27 00 00       	call   801054a6 <acquire>
80102d5c:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102d62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d65:	8b 15 f8 46 11 80    	mov    0x801146f8,%edx
80102d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d6e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d73:	a3 f8 46 11 80       	mov    %eax,0x801146f8
  if(kmem.use_lock)
80102d78:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102d7d:	85 c0                	test   %eax,%eax
80102d7f:	74 10                	je     80102d91 <kfree+0x9b>
    release(&kmem.lock);
80102d81:	83 ec 0c             	sub    $0xc,%esp
80102d84:	68 c0 46 11 80       	push   $0x801146c0
80102d89:	e8 8a 27 00 00       	call   80105518 <release>
80102d8e:	83 c4 10             	add    $0x10,%esp
}
80102d91:	90                   	nop
80102d92:	c9                   	leave  
80102d93:	c3                   	ret    

80102d94 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d94:	f3 0f 1e fb          	endbr32 
80102d98:	55                   	push   %ebp
80102d99:	89 e5                	mov    %esp,%ebp
80102d9b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d9e:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102da3:	85 c0                	test   %eax,%eax
80102da5:	74 10                	je     80102db7 <kalloc+0x23>
    acquire(&kmem.lock);
80102da7:	83 ec 0c             	sub    $0xc,%esp
80102daa:	68 c0 46 11 80       	push   $0x801146c0
80102daf:	e8 f2 26 00 00       	call   801054a6 <acquire>
80102db4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102db7:	a1 f8 46 11 80       	mov    0x801146f8,%eax
80102dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102dbf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dc3:	74 0a                	je     80102dcf <kalloc+0x3b>
    kmem.freelist = r->next;
80102dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dc8:	8b 00                	mov    (%eax),%eax
80102dca:	a3 f8 46 11 80       	mov    %eax,0x801146f8
  if(kmem.use_lock)
80102dcf:	a1 f4 46 11 80       	mov    0x801146f4,%eax
80102dd4:	85 c0                	test   %eax,%eax
80102dd6:	74 10                	je     80102de8 <kalloc+0x54>
    release(&kmem.lock);
80102dd8:	83 ec 0c             	sub    $0xc,%esp
80102ddb:	68 c0 46 11 80       	push   $0x801146c0
80102de0:	e8 33 27 00 00       	call   80105518 <release>
80102de5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102deb:	c9                   	leave  
80102dec:	c3                   	ret    

80102ded <inb>:
{
80102ded:	55                   	push   %ebp
80102dee:	89 e5                	mov    %esp,%ebp
80102df0:	83 ec 14             	sub    $0x14,%esp
80102df3:	8b 45 08             	mov    0x8(%ebp),%eax
80102df6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dfa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102dfe:	89 c2                	mov    %eax,%edx
80102e00:	ec                   	in     (%dx),%al
80102e01:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e04:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e08:	c9                   	leave  
80102e09:	c3                   	ret    

80102e0a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e0a:	f3 0f 1e fb          	endbr32 
80102e0e:	55                   	push   %ebp
80102e0f:	89 e5                	mov    %esp,%ebp
80102e11:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e14:	6a 64                	push   $0x64
80102e16:	e8 d2 ff ff ff       	call   80102ded <inb>
80102e1b:	83 c4 04             	add    $0x4,%esp
80102e1e:	0f b6 c0             	movzbl %al,%eax
80102e21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e27:	83 e0 01             	and    $0x1,%eax
80102e2a:	85 c0                	test   %eax,%eax
80102e2c:	75 0a                	jne    80102e38 <kbdgetc+0x2e>
    return -1;
80102e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e33:	e9 23 01 00 00       	jmp    80102f5b <kbdgetc+0x151>
  data = inb(KBDATAP);
80102e38:	6a 60                	push   $0x60
80102e3a:	e8 ae ff ff ff       	call   80102ded <inb>
80102e3f:	83 c4 04             	add    $0x4,%esp
80102e42:	0f b6 c0             	movzbl %al,%eax
80102e45:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e48:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e4f:	75 17                	jne    80102e68 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e51:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102e56:	83 c8 40             	or     $0x40,%eax
80102e59:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
    return 0;
80102e5e:	b8 00 00 00 00       	mov    $0x0,%eax
80102e63:	e9 f3 00 00 00       	jmp    80102f5b <kbdgetc+0x151>
  } else if(data & 0x80){
80102e68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e6b:	25 80 00 00 00       	and    $0x80,%eax
80102e70:	85 c0                	test   %eax,%eax
80102e72:	74 45                	je     80102eb9 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e74:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102e79:	83 e0 40             	and    $0x40,%eax
80102e7c:	85 c0                	test   %eax,%eax
80102e7e:	75 08                	jne    80102e88 <kbdgetc+0x7e>
80102e80:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e83:	83 e0 7f             	and    $0x7f,%eax
80102e86:	eb 03                	jmp    80102e8b <kbdgetc+0x81>
80102e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e91:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e96:	0f b6 00             	movzbl (%eax),%eax
80102e99:	83 c8 40             	or     $0x40,%eax
80102e9c:	0f b6 c0             	movzbl %al,%eax
80102e9f:	f7 d0                	not    %eax
80102ea1:	89 c2                	mov    %eax,%edx
80102ea3:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102ea8:	21 d0                	and    %edx,%eax
80102eaa:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
    return 0;
80102eaf:	b8 00 00 00 00       	mov    $0x0,%eax
80102eb4:	e9 a2 00 00 00       	jmp    80102f5b <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102eb9:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102ebe:	83 e0 40             	and    $0x40,%eax
80102ec1:	85 c0                	test   %eax,%eax
80102ec3:	74 14                	je     80102ed9 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ec5:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ecc:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102ed1:	83 e0 bf             	and    $0xffffffbf,%eax
80102ed4:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
  }

  shift |= shiftcode[data];
80102ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102edc:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ee1:	0f b6 00             	movzbl (%eax),%eax
80102ee4:	0f b6 d0             	movzbl %al,%edx
80102ee7:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102eec:	09 d0                	or     %edx,%eax
80102eee:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
  shift ^= togglecode[data];
80102ef3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ef6:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102efb:	0f b6 00             	movzbl (%eax),%eax
80102efe:	0f b6 d0             	movzbl %al,%edx
80102f01:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102f06:	31 d0                	xor    %edx,%eax
80102f08:	a3 1c c6 10 80       	mov    %eax,0x8010c61c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f0d:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102f12:	83 e0 03             	and    $0x3,%eax
80102f15:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f1f:	01 d0                	add    %edx,%eax
80102f21:	0f b6 00             	movzbl (%eax),%eax
80102f24:	0f b6 c0             	movzbl %al,%eax
80102f27:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f2a:	a1 1c c6 10 80       	mov    0x8010c61c,%eax
80102f2f:	83 e0 08             	and    $0x8,%eax
80102f32:	85 c0                	test   %eax,%eax
80102f34:	74 22                	je     80102f58 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102f36:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f3a:	76 0c                	jbe    80102f48 <kbdgetc+0x13e>
80102f3c:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f40:	77 06                	ja     80102f48 <kbdgetc+0x13e>
      c += 'A' - 'a';
80102f42:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f46:	eb 10                	jmp    80102f58 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102f48:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f4c:	76 0a                	jbe    80102f58 <kbdgetc+0x14e>
80102f4e:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f52:	77 04                	ja     80102f58 <kbdgetc+0x14e>
      c += 'a' - 'A';
80102f54:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f58:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f5b:	c9                   	leave  
80102f5c:	c3                   	ret    

80102f5d <kbdintr>:

void
kbdintr(void)
{
80102f5d:	f3 0f 1e fb          	endbr32 
80102f61:	55                   	push   %ebp
80102f62:	89 e5                	mov    %esp,%ebp
80102f64:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102f67:	83 ec 0c             	sub    $0xc,%esp
80102f6a:	68 0a 2e 10 80       	push   $0x80102e0a
80102f6f:	e8 fd d8 ff ff       	call   80100871 <consoleintr>
80102f74:	83 c4 10             	add    $0x10,%esp
}
80102f77:	90                   	nop
80102f78:	c9                   	leave  
80102f79:	c3                   	ret    

80102f7a <inb>:
{
80102f7a:	55                   	push   %ebp
80102f7b:	89 e5                	mov    %esp,%ebp
80102f7d:	83 ec 14             	sub    $0x14,%esp
80102f80:	8b 45 08             	mov    0x8(%ebp),%eax
80102f83:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f8b:	89 c2                	mov    %eax,%edx
80102f8d:	ec                   	in     (%dx),%al
80102f8e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f91:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f95:	c9                   	leave  
80102f96:	c3                   	ret    

80102f97 <outb>:
{
80102f97:	55                   	push   %ebp
80102f98:	89 e5                	mov    %esp,%ebp
80102f9a:	83 ec 08             	sub    $0x8,%esp
80102f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa0:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fa3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102fa7:	89 d0                	mov    %edx,%eax
80102fa9:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fac:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102fb0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102fb4:	ee                   	out    %al,(%dx)
}
80102fb5:	90                   	nop
80102fb6:	c9                   	leave  
80102fb7:	c3                   	ret    

80102fb8 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fb8:	f3 0f 1e fb          	endbr32 
80102fbc:	55                   	push   %ebp
80102fbd:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fbf:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102fc4:	8b 55 08             	mov    0x8(%ebp),%edx
80102fc7:	c1 e2 02             	shl    $0x2,%edx
80102fca:	01 c2                	add    %eax,%edx
80102fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fcf:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fd1:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102fd6:	83 c0 20             	add    $0x20,%eax
80102fd9:	8b 00                	mov    (%eax),%eax
}
80102fdb:	90                   	nop
80102fdc:	5d                   	pop    %ebp
80102fdd:	c3                   	ret    

80102fde <lapicinit>:

void
lapicinit(void)
{
80102fde:	f3 0f 1e fb          	endbr32 
80102fe2:	55                   	push   %ebp
80102fe3:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102fe5:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80102fea:	85 c0                	test   %eax,%eax
80102fec:	0f 84 0c 01 00 00    	je     801030fe <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ff2:	68 3f 01 00 00       	push   $0x13f
80102ff7:	6a 3c                	push   $0x3c
80102ff9:	e8 ba ff ff ff       	call   80102fb8 <lapicw>
80102ffe:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103001:	6a 0b                	push   $0xb
80103003:	68 f8 00 00 00       	push   $0xf8
80103008:	e8 ab ff ff ff       	call   80102fb8 <lapicw>
8010300d:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103010:	68 20 00 02 00       	push   $0x20020
80103015:	68 c8 00 00 00       	push   $0xc8
8010301a:	e8 99 ff ff ff       	call   80102fb8 <lapicw>
8010301f:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80103022:	68 80 96 98 00       	push   $0x989680
80103027:	68 e0 00 00 00       	push   $0xe0
8010302c:	e8 87 ff ff ff       	call   80102fb8 <lapicw>
80103031:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103034:	68 00 00 01 00       	push   $0x10000
80103039:	68 d4 00 00 00       	push   $0xd4
8010303e:	e8 75 ff ff ff       	call   80102fb8 <lapicw>
80103043:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80103046:	68 00 00 01 00       	push   $0x10000
8010304b:	68 d8 00 00 00       	push   $0xd8
80103050:	e8 63 ff ff ff       	call   80102fb8 <lapicw>
80103055:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103058:	a1 fc 46 11 80       	mov    0x801146fc,%eax
8010305d:	83 c0 30             	add    $0x30,%eax
80103060:	8b 00                	mov    (%eax),%eax
80103062:	c1 e8 10             	shr    $0x10,%eax
80103065:	25 fc 00 00 00       	and    $0xfc,%eax
8010306a:	85 c0                	test   %eax,%eax
8010306c:	74 12                	je     80103080 <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
8010306e:	68 00 00 01 00       	push   $0x10000
80103073:	68 d0 00 00 00       	push   $0xd0
80103078:	e8 3b ff ff ff       	call   80102fb8 <lapicw>
8010307d:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103080:	6a 33                	push   $0x33
80103082:	68 dc 00 00 00       	push   $0xdc
80103087:	e8 2c ff ff ff       	call   80102fb8 <lapicw>
8010308c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010308f:	6a 00                	push   $0x0
80103091:	68 a0 00 00 00       	push   $0xa0
80103096:	e8 1d ff ff ff       	call   80102fb8 <lapicw>
8010309b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010309e:	6a 00                	push   $0x0
801030a0:	68 a0 00 00 00       	push   $0xa0
801030a5:	e8 0e ff ff ff       	call   80102fb8 <lapicw>
801030aa:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030ad:	6a 00                	push   $0x0
801030af:	6a 2c                	push   $0x2c
801030b1:	e8 02 ff ff ff       	call   80102fb8 <lapicw>
801030b6:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030b9:	6a 00                	push   $0x0
801030bb:	68 c4 00 00 00       	push   $0xc4
801030c0:	e8 f3 fe ff ff       	call   80102fb8 <lapicw>
801030c5:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030c8:	68 00 85 08 00       	push   $0x88500
801030cd:	68 c0 00 00 00       	push   $0xc0
801030d2:	e8 e1 fe ff ff       	call   80102fb8 <lapicw>
801030d7:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
801030da:	90                   	nop
801030db:	a1 fc 46 11 80       	mov    0x801146fc,%eax
801030e0:	05 00 03 00 00       	add    $0x300,%eax
801030e5:	8b 00                	mov    (%eax),%eax
801030e7:	25 00 10 00 00       	and    $0x1000,%eax
801030ec:	85 c0                	test   %eax,%eax
801030ee:	75 eb                	jne    801030db <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030f0:	6a 00                	push   $0x0
801030f2:	6a 20                	push   $0x20
801030f4:	e8 bf fe ff ff       	call   80102fb8 <lapicw>
801030f9:	83 c4 08             	add    $0x8,%esp
801030fc:	eb 01                	jmp    801030ff <lapicinit+0x121>
    return;
801030fe:	90                   	nop
}
801030ff:	c9                   	leave  
80103100:	c3                   	ret    

80103101 <lapicid>:

int
lapicid(void)
{
80103101:	f3 0f 1e fb          	endbr32 
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103108:	a1 fc 46 11 80       	mov    0x801146fc,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 07                	jne    80103118 <lapicid+0x17>
    return 0;
80103111:	b8 00 00 00 00       	mov    $0x0,%eax
80103116:	eb 0d                	jmp    80103125 <lapicid+0x24>
  return lapic[ID] >> 24;
80103118:	a1 fc 46 11 80       	mov    0x801146fc,%eax
8010311d:	83 c0 20             	add    $0x20,%eax
80103120:	8b 00                	mov    (%eax),%eax
80103122:	c1 e8 18             	shr    $0x18,%eax
}
80103125:	5d                   	pop    %ebp
80103126:	c3                   	ret    

80103127 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103127:	f3 0f 1e fb          	endbr32 
8010312b:	55                   	push   %ebp
8010312c:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010312e:	a1 fc 46 11 80       	mov    0x801146fc,%eax
80103133:	85 c0                	test   %eax,%eax
80103135:	74 0c                	je     80103143 <lapiceoi+0x1c>
    lapicw(EOI, 0);
80103137:	6a 00                	push   $0x0
80103139:	6a 2c                	push   $0x2c
8010313b:	e8 78 fe ff ff       	call   80102fb8 <lapicw>
80103140:	83 c4 08             	add    $0x8,%esp
}
80103143:	90                   	nop
80103144:	c9                   	leave  
80103145:	c3                   	ret    

80103146 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103146:	f3 0f 1e fb          	endbr32 
8010314a:	55                   	push   %ebp
8010314b:	89 e5                	mov    %esp,%ebp
}
8010314d:	90                   	nop
8010314e:	5d                   	pop    %ebp
8010314f:	c3                   	ret    

80103150 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103150:	f3 0f 1e fb          	endbr32 
80103154:	55                   	push   %ebp
80103155:	89 e5                	mov    %esp,%ebp
80103157:	83 ec 14             	sub    $0x14,%esp
8010315a:	8b 45 08             	mov    0x8(%ebp),%eax
8010315d:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103160:	6a 0f                	push   $0xf
80103162:	6a 70                	push   $0x70
80103164:	e8 2e fe ff ff       	call   80102f97 <outb>
80103169:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010316c:	6a 0a                	push   $0xa
8010316e:	6a 71                	push   $0x71
80103170:	e8 22 fe ff ff       	call   80102f97 <outb>
80103175:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103178:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010317f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103182:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103187:	8b 45 0c             	mov    0xc(%ebp),%eax
8010318a:	c1 e8 04             	shr    $0x4,%eax
8010318d:	89 c2                	mov    %eax,%edx
8010318f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103192:	83 c0 02             	add    $0x2,%eax
80103195:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103198:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010319c:	c1 e0 18             	shl    $0x18,%eax
8010319f:	50                   	push   %eax
801031a0:	68 c4 00 00 00       	push   $0xc4
801031a5:	e8 0e fe ff ff       	call   80102fb8 <lapicw>
801031aa:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031ad:	68 00 c5 00 00       	push   $0xc500
801031b2:	68 c0 00 00 00       	push   $0xc0
801031b7:	e8 fc fd ff ff       	call   80102fb8 <lapicw>
801031bc:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031bf:	68 c8 00 00 00       	push   $0xc8
801031c4:	e8 7d ff ff ff       	call   80103146 <microdelay>
801031c9:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801031cc:	68 00 85 00 00       	push   $0x8500
801031d1:	68 c0 00 00 00       	push   $0xc0
801031d6:	e8 dd fd ff ff       	call   80102fb8 <lapicw>
801031db:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031de:	6a 64                	push   $0x64
801031e0:	e8 61 ff ff ff       	call   80103146 <microdelay>
801031e5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031e8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801031ef:	eb 3d                	jmp    8010322e <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801031f1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031f5:	c1 e0 18             	shl    $0x18,%eax
801031f8:	50                   	push   %eax
801031f9:	68 c4 00 00 00       	push   $0xc4
801031fe:	e8 b5 fd ff ff       	call   80102fb8 <lapicw>
80103203:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103206:	8b 45 0c             	mov    0xc(%ebp),%eax
80103209:	c1 e8 0c             	shr    $0xc,%eax
8010320c:	80 cc 06             	or     $0x6,%ah
8010320f:	50                   	push   %eax
80103210:	68 c0 00 00 00       	push   $0xc0
80103215:	e8 9e fd ff ff       	call   80102fb8 <lapicw>
8010321a:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010321d:	68 c8 00 00 00       	push   $0xc8
80103222:	e8 1f ff ff ff       	call   80103146 <microdelay>
80103227:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010322a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010322e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103232:	7e bd                	jle    801031f1 <lapicstartap+0xa1>
  }
}
80103234:	90                   	nop
80103235:	90                   	nop
80103236:	c9                   	leave  
80103237:	c3                   	ret    

80103238 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80103238:	f3 0f 1e fb          	endbr32 
8010323c:	55                   	push   %ebp
8010323d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010323f:	8b 45 08             	mov    0x8(%ebp),%eax
80103242:	0f b6 c0             	movzbl %al,%eax
80103245:	50                   	push   %eax
80103246:	6a 70                	push   $0x70
80103248:	e8 4a fd ff ff       	call   80102f97 <outb>
8010324d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103250:	68 c8 00 00 00       	push   $0xc8
80103255:	e8 ec fe ff ff       	call   80103146 <microdelay>
8010325a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010325d:	6a 71                	push   $0x71
8010325f:	e8 16 fd ff ff       	call   80102f7a <inb>
80103264:	83 c4 04             	add    $0x4,%esp
80103267:	0f b6 c0             	movzbl %al,%eax
}
8010326a:	c9                   	leave  
8010326b:	c3                   	ret    

8010326c <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010326c:	f3 0f 1e fb          	endbr32 
80103270:	55                   	push   %ebp
80103271:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103273:	6a 00                	push   $0x0
80103275:	e8 be ff ff ff       	call   80103238 <cmos_read>
8010327a:	83 c4 04             	add    $0x4,%esp
8010327d:	8b 55 08             	mov    0x8(%ebp),%edx
80103280:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103282:	6a 02                	push   $0x2
80103284:	e8 af ff ff ff       	call   80103238 <cmos_read>
80103289:	83 c4 04             	add    $0x4,%esp
8010328c:	8b 55 08             	mov    0x8(%ebp),%edx
8010328f:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103292:	6a 04                	push   $0x4
80103294:	e8 9f ff ff ff       	call   80103238 <cmos_read>
80103299:	83 c4 04             	add    $0x4,%esp
8010329c:	8b 55 08             	mov    0x8(%ebp),%edx
8010329f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801032a2:	6a 07                	push   $0x7
801032a4:	e8 8f ff ff ff       	call   80103238 <cmos_read>
801032a9:	83 c4 04             	add    $0x4,%esp
801032ac:	8b 55 08             	mov    0x8(%ebp),%edx
801032af:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801032b2:	6a 08                	push   $0x8
801032b4:	e8 7f ff ff ff       	call   80103238 <cmos_read>
801032b9:	83 c4 04             	add    $0x4,%esp
801032bc:	8b 55 08             	mov    0x8(%ebp),%edx
801032bf:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032c2:	6a 09                	push   $0x9
801032c4:	e8 6f ff ff ff       	call   80103238 <cmos_read>
801032c9:	83 c4 04             	add    $0x4,%esp
801032cc:	8b 55 08             	mov    0x8(%ebp),%edx
801032cf:	89 42 14             	mov    %eax,0x14(%edx)
}
801032d2:	90                   	nop
801032d3:	c9                   	leave  
801032d4:	c3                   	ret    

801032d5 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801032d5:	f3 0f 1e fb          	endbr32 
801032d9:	55                   	push   %ebp
801032da:	89 e5                	mov    %esp,%ebp
801032dc:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032df:	6a 0b                	push   $0xb
801032e1:	e8 52 ff ff ff       	call   80103238 <cmos_read>
801032e6:	83 c4 04             	add    $0x4,%esp
801032e9:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801032ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ef:	83 e0 04             	and    $0x4,%eax
801032f2:	85 c0                	test   %eax,%eax
801032f4:	0f 94 c0             	sete   %al
801032f7:	0f b6 c0             	movzbl %al,%eax
801032fa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801032fd:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103300:	50                   	push   %eax
80103301:	e8 66 ff ff ff       	call   8010326c <fill_rtcdate>
80103306:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103309:	6a 0a                	push   $0xa
8010330b:	e8 28 ff ff ff       	call   80103238 <cmos_read>
80103310:	83 c4 04             	add    $0x4,%esp
80103313:	25 80 00 00 00       	and    $0x80,%eax
80103318:	85 c0                	test   %eax,%eax
8010331a:	75 27                	jne    80103343 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
8010331c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010331f:	50                   	push   %eax
80103320:	e8 47 ff ff ff       	call   8010326c <fill_rtcdate>
80103325:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103328:	83 ec 04             	sub    $0x4,%esp
8010332b:	6a 18                	push   $0x18
8010332d:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103330:	50                   	push   %eax
80103331:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103334:	50                   	push   %eax
80103335:	e8 76 24 00 00       	call   801057b0 <memcmp>
8010333a:	83 c4 10             	add    $0x10,%esp
8010333d:	85 c0                	test   %eax,%eax
8010333f:	74 05                	je     80103346 <cmostime+0x71>
80103341:	eb ba                	jmp    801032fd <cmostime+0x28>
        continue;
80103343:	90                   	nop
    fill_rtcdate(&t1);
80103344:	eb b7                	jmp    801032fd <cmostime+0x28>
      break;
80103346:	90                   	nop
  }

  // convert
  if(bcd) {
80103347:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010334b:	0f 84 b4 00 00 00    	je     80103405 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103351:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103354:	c1 e8 04             	shr    $0x4,%eax
80103357:	89 c2                	mov    %eax,%edx
80103359:	89 d0                	mov    %edx,%eax
8010335b:	c1 e0 02             	shl    $0x2,%eax
8010335e:	01 d0                	add    %edx,%eax
80103360:	01 c0                	add    %eax,%eax
80103362:	89 c2                	mov    %eax,%edx
80103364:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103367:	83 e0 0f             	and    $0xf,%eax
8010336a:	01 d0                	add    %edx,%eax
8010336c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010336f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103372:	c1 e8 04             	shr    $0x4,%eax
80103375:	89 c2                	mov    %eax,%edx
80103377:	89 d0                	mov    %edx,%eax
80103379:	c1 e0 02             	shl    $0x2,%eax
8010337c:	01 d0                	add    %edx,%eax
8010337e:	01 c0                	add    %eax,%eax
80103380:	89 c2                	mov    %eax,%edx
80103382:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103385:	83 e0 0f             	and    $0xf,%eax
80103388:	01 d0                	add    %edx,%eax
8010338a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010338d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103390:	c1 e8 04             	shr    $0x4,%eax
80103393:	89 c2                	mov    %eax,%edx
80103395:	89 d0                	mov    %edx,%eax
80103397:	c1 e0 02             	shl    $0x2,%eax
8010339a:	01 d0                	add    %edx,%eax
8010339c:	01 c0                	add    %eax,%eax
8010339e:	89 c2                	mov    %eax,%edx
801033a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801033a3:	83 e0 0f             	and    $0xf,%eax
801033a6:	01 d0                	add    %edx,%eax
801033a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801033ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033ae:	c1 e8 04             	shr    $0x4,%eax
801033b1:	89 c2                	mov    %eax,%edx
801033b3:	89 d0                	mov    %edx,%eax
801033b5:	c1 e0 02             	shl    $0x2,%eax
801033b8:	01 d0                	add    %edx,%eax
801033ba:	01 c0                	add    %eax,%eax
801033bc:	89 c2                	mov    %eax,%edx
801033be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033c1:	83 e0 0f             	and    $0xf,%eax
801033c4:	01 d0                	add    %edx,%eax
801033c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801033c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033cc:	c1 e8 04             	shr    $0x4,%eax
801033cf:	89 c2                	mov    %eax,%edx
801033d1:	89 d0                	mov    %edx,%eax
801033d3:	c1 e0 02             	shl    $0x2,%eax
801033d6:	01 d0                	add    %edx,%eax
801033d8:	01 c0                	add    %eax,%eax
801033da:	89 c2                	mov    %eax,%edx
801033dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801033df:	83 e0 0f             	and    $0xf,%eax
801033e2:	01 d0                	add    %edx,%eax
801033e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801033e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ea:	c1 e8 04             	shr    $0x4,%eax
801033ed:	89 c2                	mov    %eax,%edx
801033ef:	89 d0                	mov    %edx,%eax
801033f1:	c1 e0 02             	shl    $0x2,%eax
801033f4:	01 d0                	add    %edx,%eax
801033f6:	01 c0                	add    %eax,%eax
801033f8:	89 c2                	mov    %eax,%edx
801033fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fd:	83 e0 0f             	and    $0xf,%eax
80103400:	01 d0                	add    %edx,%eax
80103402:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103405:	8b 45 08             	mov    0x8(%ebp),%eax
80103408:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010340b:	89 10                	mov    %edx,(%eax)
8010340d:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103410:	89 50 04             	mov    %edx,0x4(%eax)
80103413:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103416:	89 50 08             	mov    %edx,0x8(%eax)
80103419:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010341c:	89 50 0c             	mov    %edx,0xc(%eax)
8010341f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103422:	89 50 10             	mov    %edx,0x10(%eax)
80103425:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103428:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010342b:	8b 45 08             	mov    0x8(%ebp),%eax
8010342e:	8b 40 14             	mov    0x14(%eax),%eax
80103431:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103437:	8b 45 08             	mov    0x8(%ebp),%eax
8010343a:	89 50 14             	mov    %edx,0x14(%eax)
}
8010343d:	90                   	nop
8010343e:	c9                   	leave  
8010343f:	c3                   	ret    

80103440 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103440:	f3 0f 1e fb          	endbr32 
80103444:	55                   	push   %ebp
80103445:	89 e5                	mov    %esp,%ebp
80103447:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010344a:	83 ec 08             	sub    $0x8,%esp
8010344d:	68 61 8c 10 80       	push   $0x80108c61
80103452:	68 00 47 11 80       	push   $0x80114700
80103457:	e8 24 20 00 00       	call   80105480 <initlock>
8010345c:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010345f:	83 ec 08             	sub    $0x8,%esp
80103462:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103465:	50                   	push   %eax
80103466:	ff 75 08             	pushl  0x8(%ebp)
80103469:	e8 f9 df ff ff       	call   80101467 <readsb>
8010346e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103471:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103474:	a3 34 47 11 80       	mov    %eax,0x80114734
  log.size = sb.nlog;
80103479:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010347c:	a3 38 47 11 80       	mov    %eax,0x80114738
  log.dev = dev;
80103481:	8b 45 08             	mov    0x8(%ebp),%eax
80103484:	a3 44 47 11 80       	mov    %eax,0x80114744
  recover_from_log();
80103489:	e8 bf 01 00 00       	call   8010364d <recover_from_log>
}
8010348e:	90                   	nop
8010348f:	c9                   	leave  
80103490:	c3                   	ret    

80103491 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103491:	f3 0f 1e fb          	endbr32 
80103495:	55                   	push   %ebp
80103496:	89 e5                	mov    %esp,%ebp
80103498:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010349b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034a2:	e9 95 00 00 00       	jmp    8010353c <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801034a7:	8b 15 34 47 11 80    	mov    0x80114734,%edx
801034ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b0:	01 d0                	add    %edx,%eax
801034b2:	83 c0 01             	add    $0x1,%eax
801034b5:	89 c2                	mov    %eax,%edx
801034b7:	a1 44 47 11 80       	mov    0x80114744,%eax
801034bc:	83 ec 08             	sub    $0x8,%esp
801034bf:	52                   	push   %edx
801034c0:	50                   	push   %eax
801034c1:	e8 11 cd ff ff       	call   801001d7 <bread>
801034c6:	83 c4 10             	add    $0x10,%esp
801034c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034cf:	83 c0 10             	add    $0x10,%eax
801034d2:	8b 04 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%eax
801034d9:	89 c2                	mov    %eax,%edx
801034db:	a1 44 47 11 80       	mov    0x80114744,%eax
801034e0:	83 ec 08             	sub    $0x8,%esp
801034e3:	52                   	push   %edx
801034e4:	50                   	push   %eax
801034e5:	e8 ed cc ff ff       	call   801001d7 <bread>
801034ea:	83 c4 10             	add    $0x10,%esp
801034ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f3:	8d 50 5c             	lea    0x5c(%eax),%edx
801034f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f9:	83 c0 5c             	add    $0x5c,%eax
801034fc:	83 ec 04             	sub    $0x4,%esp
801034ff:	68 00 02 00 00       	push   $0x200
80103504:	52                   	push   %edx
80103505:	50                   	push   %eax
80103506:	e8 01 23 00 00       	call   8010580c <memmove>
8010350b:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010350e:	83 ec 0c             	sub    $0xc,%esp
80103511:	ff 75 ec             	pushl  -0x14(%ebp)
80103514:	e8 fb cc ff ff       	call   80100214 <bwrite>
80103519:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
8010351c:	83 ec 0c             	sub    $0xc,%esp
8010351f:	ff 75 f0             	pushl  -0x10(%ebp)
80103522:	e8 3a cd ff ff       	call   80100261 <brelse>
80103527:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
8010352a:	83 ec 0c             	sub    $0xc,%esp
8010352d:	ff 75 ec             	pushl  -0x14(%ebp)
80103530:	e8 2c cd ff ff       	call   80100261 <brelse>
80103535:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010353c:	a1 48 47 11 80       	mov    0x80114748,%eax
80103541:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103544:	0f 8c 5d ff ff ff    	jl     801034a7 <install_trans+0x16>
  }
}
8010354a:	90                   	nop
8010354b:	90                   	nop
8010354c:	c9                   	leave  
8010354d:	c3                   	ret    

8010354e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010354e:	f3 0f 1e fb          	endbr32 
80103552:	55                   	push   %ebp
80103553:	89 e5                	mov    %esp,%ebp
80103555:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103558:	a1 34 47 11 80       	mov    0x80114734,%eax
8010355d:	89 c2                	mov    %eax,%edx
8010355f:	a1 44 47 11 80       	mov    0x80114744,%eax
80103564:	83 ec 08             	sub    $0x8,%esp
80103567:	52                   	push   %edx
80103568:	50                   	push   %eax
80103569:	e8 69 cc ff ff       	call   801001d7 <bread>
8010356e:	83 c4 10             	add    $0x10,%esp
80103571:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103574:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103577:	83 c0 5c             	add    $0x5c,%eax
8010357a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010357d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103580:	8b 00                	mov    (%eax),%eax
80103582:	a3 48 47 11 80       	mov    %eax,0x80114748
  for (i = 0; i < log.lh.n; i++) {
80103587:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010358e:	eb 1b                	jmp    801035ab <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103590:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103593:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103596:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010359a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010359d:	83 c2 10             	add    $0x10,%edx
801035a0:	89 04 95 0c 47 11 80 	mov    %eax,-0x7feeb8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801035a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035ab:	a1 48 47 11 80       	mov    0x80114748,%eax
801035b0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801035b3:	7c db                	jl     80103590 <read_head+0x42>
  }
  brelse(buf);
801035b5:	83 ec 0c             	sub    $0xc,%esp
801035b8:	ff 75 f0             	pushl  -0x10(%ebp)
801035bb:	e8 a1 cc ff ff       	call   80100261 <brelse>
801035c0:	83 c4 10             	add    $0x10,%esp
}
801035c3:	90                   	nop
801035c4:	c9                   	leave  
801035c5:	c3                   	ret    

801035c6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035c6:	f3 0f 1e fb          	endbr32 
801035ca:	55                   	push   %ebp
801035cb:	89 e5                	mov    %esp,%ebp
801035cd:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801035d0:	a1 34 47 11 80       	mov    0x80114734,%eax
801035d5:	89 c2                	mov    %eax,%edx
801035d7:	a1 44 47 11 80       	mov    0x80114744,%eax
801035dc:	83 ec 08             	sub    $0x8,%esp
801035df:	52                   	push   %edx
801035e0:	50                   	push   %eax
801035e1:	e8 f1 cb ff ff       	call   801001d7 <bread>
801035e6:	83 c4 10             	add    $0x10,%esp
801035e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035ef:	83 c0 5c             	add    $0x5c,%eax
801035f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035f5:	8b 15 48 47 11 80    	mov    0x80114748,%edx
801035fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035fe:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103607:	eb 1b                	jmp    80103624 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010360c:	83 c0 10             	add    $0x10,%eax
8010360f:	8b 0c 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%ecx
80103616:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103619:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010361c:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103620:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103624:	a1 48 47 11 80       	mov    0x80114748,%eax
80103629:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010362c:	7c db                	jl     80103609 <write_head+0x43>
  }
  bwrite(buf);
8010362e:	83 ec 0c             	sub    $0xc,%esp
80103631:	ff 75 f0             	pushl  -0x10(%ebp)
80103634:	e8 db cb ff ff       	call   80100214 <bwrite>
80103639:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010363c:	83 ec 0c             	sub    $0xc,%esp
8010363f:	ff 75 f0             	pushl  -0x10(%ebp)
80103642:	e8 1a cc ff ff       	call   80100261 <brelse>
80103647:	83 c4 10             	add    $0x10,%esp
}
8010364a:	90                   	nop
8010364b:	c9                   	leave  
8010364c:	c3                   	ret    

8010364d <recover_from_log>:

static void
recover_from_log(void)
{
8010364d:	f3 0f 1e fb          	endbr32 
80103651:	55                   	push   %ebp
80103652:	89 e5                	mov    %esp,%ebp
80103654:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103657:	e8 f2 fe ff ff       	call   8010354e <read_head>
  install_trans(); // if committed, copy from log to disk
8010365c:	e8 30 fe ff ff       	call   80103491 <install_trans>
  log.lh.n = 0;
80103661:	c7 05 48 47 11 80 00 	movl   $0x0,0x80114748
80103668:	00 00 00 
  write_head(); // clear the log
8010366b:	e8 56 ff ff ff       	call   801035c6 <write_head>
}
80103670:	90                   	nop
80103671:	c9                   	leave  
80103672:	c3                   	ret    

80103673 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103673:	f3 0f 1e fb          	endbr32 
80103677:	55                   	push   %ebp
80103678:	89 e5                	mov    %esp,%ebp
8010367a:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010367d:	83 ec 0c             	sub    $0xc,%esp
80103680:	68 00 47 11 80       	push   $0x80114700
80103685:	e8 1c 1e 00 00       	call   801054a6 <acquire>
8010368a:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010368d:	a1 40 47 11 80       	mov    0x80114740,%eax
80103692:	85 c0                	test   %eax,%eax
80103694:	74 17                	je     801036ad <begin_op+0x3a>
      sleep(&log, &log.lock);
80103696:	83 ec 08             	sub    $0x8,%esp
80103699:	68 00 47 11 80       	push   $0x80114700
8010369e:	68 00 47 11 80       	push   $0x80114700
801036a3:	e8 a1 18 00 00       	call   80104f49 <sleep>
801036a8:	83 c4 10             	add    $0x10,%esp
801036ab:	eb e0                	jmp    8010368d <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801036ad:	8b 0d 48 47 11 80    	mov    0x80114748,%ecx
801036b3:	a1 3c 47 11 80       	mov    0x8011473c,%eax
801036b8:	8d 50 01             	lea    0x1(%eax),%edx
801036bb:	89 d0                	mov    %edx,%eax
801036bd:	c1 e0 02             	shl    $0x2,%eax
801036c0:	01 d0                	add    %edx,%eax
801036c2:	01 c0                	add    %eax,%eax
801036c4:	01 c8                	add    %ecx,%eax
801036c6:	83 f8 1e             	cmp    $0x1e,%eax
801036c9:	7e 17                	jle    801036e2 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036cb:	83 ec 08             	sub    $0x8,%esp
801036ce:	68 00 47 11 80       	push   $0x80114700
801036d3:	68 00 47 11 80       	push   $0x80114700
801036d8:	e8 6c 18 00 00       	call   80104f49 <sleep>
801036dd:	83 c4 10             	add    $0x10,%esp
801036e0:	eb ab                	jmp    8010368d <begin_op+0x1a>
    } else {
      log.outstanding += 1;
801036e2:	a1 3c 47 11 80       	mov    0x8011473c,%eax
801036e7:	83 c0 01             	add    $0x1,%eax
801036ea:	a3 3c 47 11 80       	mov    %eax,0x8011473c
      release(&log.lock);
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	68 00 47 11 80       	push   $0x80114700
801036f7:	e8 1c 1e 00 00       	call   80105518 <release>
801036fc:	83 c4 10             	add    $0x10,%esp
      break;
801036ff:	90                   	nop
    }
  }
}
80103700:	90                   	nop
80103701:	c9                   	leave  
80103702:	c3                   	ret    

80103703 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103703:	f3 0f 1e fb          	endbr32 
80103707:	55                   	push   %ebp
80103708:	89 e5                	mov    %esp,%ebp
8010370a:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
8010370d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103714:	83 ec 0c             	sub    $0xc,%esp
80103717:	68 00 47 11 80       	push   $0x80114700
8010371c:	e8 85 1d 00 00       	call   801054a6 <acquire>
80103721:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103724:	a1 3c 47 11 80       	mov    0x8011473c,%eax
80103729:	83 e8 01             	sub    $0x1,%eax
8010372c:	a3 3c 47 11 80       	mov    %eax,0x8011473c
  if(log.committing)
80103731:	a1 40 47 11 80       	mov    0x80114740,%eax
80103736:	85 c0                	test   %eax,%eax
80103738:	74 0d                	je     80103747 <end_op+0x44>
    panic("log.committing");
8010373a:	83 ec 0c             	sub    $0xc,%esp
8010373d:	68 65 8c 10 80       	push   $0x80108c65
80103742:	e8 8a ce ff ff       	call   801005d1 <panic>
  if(log.outstanding == 0){
80103747:	a1 3c 47 11 80       	mov    0x8011473c,%eax
8010374c:	85 c0                	test   %eax,%eax
8010374e:	75 13                	jne    80103763 <end_op+0x60>
    do_commit = 1;
80103750:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103757:	c7 05 40 47 11 80 01 	movl   $0x1,0x80114740
8010375e:	00 00 00 
80103761:	eb 10                	jmp    80103773 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103763:	83 ec 0c             	sub    $0xc,%esp
80103766:	68 00 47 11 80       	push   $0x80114700
8010376b:	e8 06 19 00 00       	call   80105076 <wakeup>
80103770:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103773:	83 ec 0c             	sub    $0xc,%esp
80103776:	68 00 47 11 80       	push   $0x80114700
8010377b:	e8 98 1d 00 00       	call   80105518 <release>
80103780:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103783:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103787:	74 3f                	je     801037c8 <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103789:	e8 fa 00 00 00       	call   80103888 <commit>
    acquire(&log.lock);
8010378e:	83 ec 0c             	sub    $0xc,%esp
80103791:	68 00 47 11 80       	push   $0x80114700
80103796:	e8 0b 1d 00 00       	call   801054a6 <acquire>
8010379b:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
8010379e:	c7 05 40 47 11 80 00 	movl   $0x0,0x80114740
801037a5:	00 00 00 
    wakeup(&log);
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	68 00 47 11 80       	push   $0x80114700
801037b0:	e8 c1 18 00 00       	call   80105076 <wakeup>
801037b5:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801037b8:	83 ec 0c             	sub    $0xc,%esp
801037bb:	68 00 47 11 80       	push   $0x80114700
801037c0:	e8 53 1d 00 00       	call   80105518 <release>
801037c5:	83 c4 10             	add    $0x10,%esp
  }
}
801037c8:	90                   	nop
801037c9:	c9                   	leave  
801037ca:	c3                   	ret    

801037cb <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037cb:	f3 0f 1e fb          	endbr32 
801037cf:	55                   	push   %ebp
801037d0:	89 e5                	mov    %esp,%ebp
801037d2:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037dc:	e9 95 00 00 00       	jmp    80103876 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037e1:	8b 15 34 47 11 80    	mov    0x80114734,%edx
801037e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037ea:	01 d0                	add    %edx,%eax
801037ec:	83 c0 01             	add    $0x1,%eax
801037ef:	89 c2                	mov    %eax,%edx
801037f1:	a1 44 47 11 80       	mov    0x80114744,%eax
801037f6:	83 ec 08             	sub    $0x8,%esp
801037f9:	52                   	push   %edx
801037fa:	50                   	push   %eax
801037fb:	e8 d7 c9 ff ff       	call   801001d7 <bread>
80103800:	83 c4 10             	add    $0x10,%esp
80103803:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103809:	83 c0 10             	add    $0x10,%eax
8010380c:	8b 04 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%eax
80103813:	89 c2                	mov    %eax,%edx
80103815:	a1 44 47 11 80       	mov    0x80114744,%eax
8010381a:	83 ec 08             	sub    $0x8,%esp
8010381d:	52                   	push   %edx
8010381e:	50                   	push   %eax
8010381f:	e8 b3 c9 ff ff       	call   801001d7 <bread>
80103824:	83 c4 10             	add    $0x10,%esp
80103827:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010382a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010382d:	8d 50 5c             	lea    0x5c(%eax),%edx
80103830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103833:	83 c0 5c             	add    $0x5c,%eax
80103836:	83 ec 04             	sub    $0x4,%esp
80103839:	68 00 02 00 00       	push   $0x200
8010383e:	52                   	push   %edx
8010383f:	50                   	push   %eax
80103840:	e8 c7 1f 00 00       	call   8010580c <memmove>
80103845:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103848:	83 ec 0c             	sub    $0xc,%esp
8010384b:	ff 75 f0             	pushl  -0x10(%ebp)
8010384e:	e8 c1 c9 ff ff       	call   80100214 <bwrite>
80103853:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103856:	83 ec 0c             	sub    $0xc,%esp
80103859:	ff 75 ec             	pushl  -0x14(%ebp)
8010385c:	e8 00 ca ff ff       	call   80100261 <brelse>
80103861:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103864:	83 ec 0c             	sub    $0xc,%esp
80103867:	ff 75 f0             	pushl  -0x10(%ebp)
8010386a:	e8 f2 c9 ff ff       	call   80100261 <brelse>
8010386f:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103872:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103876:	a1 48 47 11 80       	mov    0x80114748,%eax
8010387b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010387e:	0f 8c 5d ff ff ff    	jl     801037e1 <write_log+0x16>
  }
}
80103884:	90                   	nop
80103885:	90                   	nop
80103886:	c9                   	leave  
80103887:	c3                   	ret    

80103888 <commit>:

static void
commit()
{
80103888:	f3 0f 1e fb          	endbr32 
8010388c:	55                   	push   %ebp
8010388d:	89 e5                	mov    %esp,%ebp
8010388f:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103892:	a1 48 47 11 80       	mov    0x80114748,%eax
80103897:	85 c0                	test   %eax,%eax
80103899:	7e 1e                	jle    801038b9 <commit+0x31>
    write_log();     // Write modified blocks from cache to log
8010389b:	e8 2b ff ff ff       	call   801037cb <write_log>
    write_head();    // Write header to disk -- the real commit
801038a0:	e8 21 fd ff ff       	call   801035c6 <write_head>
    install_trans(); // Now install writes to home locations
801038a5:	e8 e7 fb ff ff       	call   80103491 <install_trans>
    log.lh.n = 0;
801038aa:	c7 05 48 47 11 80 00 	movl   $0x0,0x80114748
801038b1:	00 00 00 
    write_head();    // Erase the transaction from the log
801038b4:	e8 0d fd ff ff       	call   801035c6 <write_head>
  }
}
801038b9:	90                   	nop
801038ba:	c9                   	leave  
801038bb:	c3                   	ret    

801038bc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801038bc:	f3 0f 1e fb          	endbr32 
801038c0:	55                   	push   %ebp
801038c1:	89 e5                	mov    %esp,%ebp
801038c3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038c6:	a1 48 47 11 80       	mov    0x80114748,%eax
801038cb:	83 f8 1d             	cmp    $0x1d,%eax
801038ce:	7f 12                	jg     801038e2 <log_write+0x26>
801038d0:	a1 48 47 11 80       	mov    0x80114748,%eax
801038d5:	8b 15 38 47 11 80    	mov    0x80114738,%edx
801038db:	83 ea 01             	sub    $0x1,%edx
801038de:	39 d0                	cmp    %edx,%eax
801038e0:	7c 0d                	jl     801038ef <log_write+0x33>
    panic("too big a transaction");
801038e2:	83 ec 0c             	sub    $0xc,%esp
801038e5:	68 74 8c 10 80       	push   $0x80108c74
801038ea:	e8 e2 cc ff ff       	call   801005d1 <panic>
  if (log.outstanding < 1)
801038ef:	a1 3c 47 11 80       	mov    0x8011473c,%eax
801038f4:	85 c0                	test   %eax,%eax
801038f6:	7f 0d                	jg     80103905 <log_write+0x49>
    panic("log_write outside of trans");
801038f8:	83 ec 0c             	sub    $0xc,%esp
801038fb:	68 8a 8c 10 80       	push   $0x80108c8a
80103900:	e8 cc cc ff ff       	call   801005d1 <panic>

  acquire(&log.lock);
80103905:	83 ec 0c             	sub    $0xc,%esp
80103908:	68 00 47 11 80       	push   $0x80114700
8010390d:	e8 94 1b 00 00       	call   801054a6 <acquire>
80103912:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103915:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010391c:	eb 1d                	jmp    8010393b <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010391e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103921:	83 c0 10             	add    $0x10,%eax
80103924:	8b 04 85 0c 47 11 80 	mov    -0x7feeb8f4(,%eax,4),%eax
8010392b:	89 c2                	mov    %eax,%edx
8010392d:	8b 45 08             	mov    0x8(%ebp),%eax
80103930:	8b 40 08             	mov    0x8(%eax),%eax
80103933:	39 c2                	cmp    %eax,%edx
80103935:	74 10                	je     80103947 <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
80103937:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010393b:	a1 48 47 11 80       	mov    0x80114748,%eax
80103940:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103943:	7c d9                	jl     8010391e <log_write+0x62>
80103945:	eb 01                	jmp    80103948 <log_write+0x8c>
      break;
80103947:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103948:	8b 45 08             	mov    0x8(%ebp),%eax
8010394b:	8b 40 08             	mov    0x8(%eax),%eax
8010394e:	89 c2                	mov    %eax,%edx
80103950:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103953:	83 c0 10             	add    $0x10,%eax
80103956:	89 14 85 0c 47 11 80 	mov    %edx,-0x7feeb8f4(,%eax,4)
  if (i == log.lh.n)
8010395d:	a1 48 47 11 80       	mov    0x80114748,%eax
80103962:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103965:	75 0d                	jne    80103974 <log_write+0xb8>
    log.lh.n++;
80103967:	a1 48 47 11 80       	mov    0x80114748,%eax
8010396c:	83 c0 01             	add    $0x1,%eax
8010396f:	a3 48 47 11 80       	mov    %eax,0x80114748
  b->flags |= B_DIRTY; // prevent eviction
80103974:	8b 45 08             	mov    0x8(%ebp),%eax
80103977:	8b 00                	mov    (%eax),%eax
80103979:	83 c8 04             	or     $0x4,%eax
8010397c:	89 c2                	mov    %eax,%edx
8010397e:	8b 45 08             	mov    0x8(%ebp),%eax
80103981:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103983:	83 ec 0c             	sub    $0xc,%esp
80103986:	68 00 47 11 80       	push   $0x80114700
8010398b:	e8 88 1b 00 00       	call   80105518 <release>
80103990:	83 c4 10             	add    $0x10,%esp
}
80103993:	90                   	nop
80103994:	c9                   	leave  
80103995:	c3                   	ret    

80103996 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103996:	55                   	push   %ebp
80103997:	89 e5                	mov    %esp,%ebp
80103999:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010399c:	8b 55 08             	mov    0x8(%ebp),%edx
8010399f:	8b 45 0c             	mov    0xc(%ebp),%eax
801039a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801039a5:	f0 87 02             	lock xchg %eax,(%edx)
801039a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801039ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801039ae:	c9                   	leave  
801039af:	c3                   	ret    

801039b0 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801039b0:	f3 0f 1e fb          	endbr32 
801039b4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801039b8:	83 e4 f0             	and    $0xfffffff0,%esp
801039bb:	ff 71 fc             	pushl  -0x4(%ecx)
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	51                   	push   %ecx
801039c2:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039c5:	83 ec 08             	sub    $0x8,%esp
801039c8:	68 00 00 40 80       	push   $0x80400000
801039cd:	68 48 73 11 80       	push   $0x80117348
801039d2:	e8 78 f2 ff ff       	call   80102c4f <kinit1>
801039d7:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801039da:	e8 24 48 00 00       	call   80108203 <kvmalloc>
  mpinit();        // detect other processors
801039df:	e8 d9 03 00 00       	call   80103dbd <mpinit>
  lapicinit();     // interrupt controller
801039e4:	e8 f5 f5 ff ff       	call   80102fde <lapicinit>
  seginit();       // segment descriptors
801039e9:	e8 f0 42 00 00       	call   80107cde <seginit>
  picinit();       // disable pic
801039ee:	e8 34 05 00 00       	call   80103f27 <picinit>
  ioapicinit();    // another interrupt controller
801039f3:	e8 6a f1 ff ff       	call   80102b62 <ioapicinit>
  consoleinit();   // console hardware
801039f8:	e8 ad d1 ff ff       	call   80100baa <consoleinit>
  uartinit();      // serial port
801039fd:	e8 65 36 00 00       	call   80107067 <uartinit>
  pinit();         // process table
80103a02:	e8 6d 09 00 00       	call   80104374 <pinit>
  tvinit();        // trap vectors
80103a07:	e8 fe 31 00 00       	call   80106c0a <tvinit>
  binit();         // buffer cache
80103a0c:	e8 23 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a11:	e8 26 d6 ff ff       	call   8010103c <fileinit>
  ideinit();       // disk 
80103a16:	e8 06 ed ff ff       	call   80102721 <ideinit>
  startothers();   // start other processors
80103a1b:	e8 88 00 00 00       	call   80103aa8 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a20:	83 ec 08             	sub    $0x8,%esp
80103a23:	68 00 00 00 8e       	push   $0x8e000000
80103a28:	68 00 00 40 80       	push   $0x80400000
80103a2d:	e8 5a f2 ff ff       	call   80102c8c <kinit2>
80103a32:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103a35:	e8 5a 0b 00 00       	call   80104594 <userinit>
  mpmain();        // finish this processor's setup
80103a3a:	e8 1e 00 00 00       	call   80103a5d <mpmain>

80103a3f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a3f:	f3 0f 1e fb          	endbr32 
80103a43:	55                   	push   %ebp
80103a44:	89 e5                	mov    %esp,%ebp
80103a46:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a49:	e8 d1 47 00 00       	call   8010821f <switchkvm>
  seginit();
80103a4e:	e8 8b 42 00 00       	call   80107cde <seginit>
  lapicinit();
80103a53:	e8 86 f5 ff ff       	call   80102fde <lapicinit>
  mpmain();
80103a58:	e8 00 00 00 00       	call   80103a5d <mpmain>

80103a5d <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a5d:	f3 0f 1e fb          	endbr32 
80103a61:	55                   	push   %ebp
80103a62:	89 e5                	mov    %esp,%ebp
80103a64:	53                   	push   %ebx
80103a65:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a68:	e8 29 09 00 00       	call   80104396 <cpuid>
80103a6d:	89 c3                	mov    %eax,%ebx
80103a6f:	e8 22 09 00 00       	call   80104396 <cpuid>
80103a74:	83 ec 04             	sub    $0x4,%esp
80103a77:	53                   	push   %ebx
80103a78:	50                   	push   %eax
80103a79:	68 a5 8c 10 80       	push   $0x80108ca5
80103a7e:	e8 95 c9 ff ff       	call   80100418 <cprintf>
80103a83:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a86:	e8 f9 32 00 00       	call   80106d84 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a8b:	e8 25 09 00 00       	call   801043b5 <mycpu>
80103a90:	05 a0 00 00 00       	add    $0xa0,%eax
80103a95:	83 ec 08             	sub    $0x8,%esp
80103a98:	6a 01                	push   $0x1
80103a9a:	50                   	push   %eax
80103a9b:	e8 f6 fe ff ff       	call   80103996 <xchg>
80103aa0:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103aa3:	e8 1c 12 00 00       	call   80104cc4 <scheduler>

80103aa8 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103aa8:	f3 0f 1e fb          	endbr32 
80103aac:	55                   	push   %ebp
80103aad:	89 e5                	mov    %esp,%ebp
80103aaf:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103ab2:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103ab9:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103abe:	83 ec 04             	sub    $0x4,%esp
80103ac1:	50                   	push   %eax
80103ac2:	68 ec c4 10 80       	push   $0x8010c4ec
80103ac7:	ff 75 f0             	pushl  -0x10(%ebp)
80103aca:	e8 3d 1d 00 00       	call   8010580c <memmove>
80103acf:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103ad2:	c7 45 f4 00 48 11 80 	movl   $0x80114800,-0xc(%ebp)
80103ad9:	eb 79                	jmp    80103b54 <startothers+0xac>
    if(c == mycpu())  // We've started already.
80103adb:	e8 d5 08 00 00       	call   801043b5 <mycpu>
80103ae0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103ae3:	74 67                	je     80103b4c <startothers+0xa4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103ae5:	e8 aa f2 ff ff       	call   80102d94 <kalloc>
80103aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103af0:	83 e8 04             	sub    $0x4,%eax
80103af3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103af6:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103afc:	89 10                	mov    %edx,(%eax)
    *(void(**)(void))(code-8) = mpenter;
80103afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b01:	83 e8 08             	sub    $0x8,%eax
80103b04:	c7 00 3f 3a 10 80    	movl   $0x80103a3f,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b0a:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b0f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b18:	83 e8 0c             	sub    $0xc,%eax
80103b1b:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
80103b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b20:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b29:	0f b6 00             	movzbl (%eax),%eax
80103b2c:	0f b6 c0             	movzbl %al,%eax
80103b2f:	83 ec 08             	sub    $0x8,%esp
80103b32:	52                   	push   %edx
80103b33:	50                   	push   %eax
80103b34:	e8 17 f6 ff ff       	call   80103150 <lapicstartap>
80103b39:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b3c:	90                   	nop
80103b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b40:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b46:	85 c0                	test   %eax,%eax
80103b48:	74 f3                	je     80103b3d <startothers+0x95>
80103b4a:	eb 01                	jmp    80103b4d <startothers+0xa5>
      continue;
80103b4c:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103b4d:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b54:	a1 b0 48 11 80       	mov    0x801148b0,%eax
80103b59:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103b5f:	05 00 48 11 80       	add    $0x80114800,%eax
80103b64:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103b67:	0f 82 6e ff ff ff    	jb     80103adb <startothers+0x33>
      ;
  }
}
80103b6d:	90                   	nop
80103b6e:	90                   	nop
80103b6f:	c9                   	leave  
80103b70:	c3                   	ret    

80103b71 <inb>:
{
80103b71:	55                   	push   %ebp
80103b72:	89 e5                	mov    %esp,%ebp
80103b74:	83 ec 14             	sub    $0x14,%esp
80103b77:	8b 45 08             	mov    0x8(%ebp),%eax
80103b7a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b7e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b82:	89 c2                	mov    %eax,%edx
80103b84:	ec                   	in     (%dx),%al
80103b85:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b88:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b8c:	c9                   	leave  
80103b8d:	c3                   	ret    

80103b8e <outb>:
{
80103b8e:	55                   	push   %ebp
80103b8f:	89 e5                	mov    %esp,%ebp
80103b91:	83 ec 08             	sub    $0x8,%esp
80103b94:	8b 45 08             	mov    0x8(%ebp),%eax
80103b97:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b9a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b9e:	89 d0                	mov    %edx,%eax
80103ba0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ba3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ba7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103bab:	ee                   	out    %al,(%dx)
}
80103bac:	90                   	nop
80103bad:	c9                   	leave  
80103bae:	c3                   	ret    

80103baf <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103baf:	f3 0f 1e fb          	endbr32 
80103bb3:	55                   	push   %ebp
80103bb4:	89 e5                	mov    %esp,%ebp
80103bb6:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103bb9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103bc0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103bc7:	eb 15                	jmp    80103bde <sum+0x2f>
    sum += addr[i];
80103bc9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcf:	01 d0                	add    %edx,%eax
80103bd1:	0f b6 00             	movzbl (%eax),%eax
80103bd4:	0f b6 c0             	movzbl %al,%eax
80103bd7:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103bda:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103bde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103be1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103be4:	7c e3                	jl     80103bc9 <sum+0x1a>
  return sum;
80103be6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103be9:	c9                   	leave  
80103bea:	c3                   	ret    

80103beb <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103beb:	f3 0f 1e fb          	endbr32 
80103bef:	55                   	push   %ebp
80103bf0:	89 e5                	mov    %esp,%ebp
80103bf2:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf8:	05 00 00 00 80       	add    $0x80000000,%eax
80103bfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c00:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c06:	01 d0                	add    %edx,%eax
80103c08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c11:	eb 36                	jmp    80103c49 <mpsearch1+0x5e>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c13:	83 ec 04             	sub    $0x4,%esp
80103c16:	6a 04                	push   $0x4
80103c18:	68 bc 8c 10 80       	push   $0x80108cbc
80103c1d:	ff 75 f4             	pushl  -0xc(%ebp)
80103c20:	e8 8b 1b 00 00       	call   801057b0 <memcmp>
80103c25:	83 c4 10             	add    $0x10,%esp
80103c28:	85 c0                	test   %eax,%eax
80103c2a:	75 19                	jne    80103c45 <mpsearch1+0x5a>
80103c2c:	83 ec 08             	sub    $0x8,%esp
80103c2f:	6a 10                	push   $0x10
80103c31:	ff 75 f4             	pushl  -0xc(%ebp)
80103c34:	e8 76 ff ff ff       	call   80103baf <sum>
80103c39:	83 c4 10             	add    $0x10,%esp
80103c3c:	84 c0                	test   %al,%al
80103c3e:	75 05                	jne    80103c45 <mpsearch1+0x5a>
      return (struct mp*)p;
80103c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c43:	eb 11                	jmp    80103c56 <mpsearch1+0x6b>
  for(p = addr; p < e; p += sizeof(struct mp))
80103c45:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c4f:	72 c2                	jb     80103c13 <mpsearch1+0x28>
  return 0;
80103c51:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c56:	c9                   	leave  
80103c57:	c3                   	ret    

80103c58 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c58:	f3 0f 1e fb          	endbr32 
80103c5c:	55                   	push   %ebp
80103c5d:	89 e5                	mov    %esp,%ebp
80103c5f:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c62:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6c:	83 c0 0f             	add    $0xf,%eax
80103c6f:	0f b6 00             	movzbl (%eax),%eax
80103c72:	0f b6 c0             	movzbl %al,%eax
80103c75:	c1 e0 08             	shl    $0x8,%eax
80103c78:	89 c2                	mov    %eax,%edx
80103c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7d:	83 c0 0e             	add    $0xe,%eax
80103c80:	0f b6 00             	movzbl (%eax),%eax
80103c83:	0f b6 c0             	movzbl %al,%eax
80103c86:	09 d0                	or     %edx,%eax
80103c88:	c1 e0 04             	shl    $0x4,%eax
80103c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c92:	74 21                	je     80103cb5 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
80103c94:	83 ec 08             	sub    $0x8,%esp
80103c97:	68 00 04 00 00       	push   $0x400
80103c9c:	ff 75 f0             	pushl  -0x10(%ebp)
80103c9f:	e8 47 ff ff ff       	call   80103beb <mpsearch1>
80103ca4:	83 c4 10             	add    $0x10,%esp
80103ca7:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103caa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cae:	74 51                	je     80103d01 <mpsearch+0xa9>
      return mp;
80103cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cb3:	eb 61                	jmp    80103d16 <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb8:	83 c0 14             	add    $0x14,%eax
80103cbb:	0f b6 00             	movzbl (%eax),%eax
80103cbe:	0f b6 c0             	movzbl %al,%eax
80103cc1:	c1 e0 08             	shl    $0x8,%eax
80103cc4:	89 c2                	mov    %eax,%edx
80103cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc9:	83 c0 13             	add    $0x13,%eax
80103ccc:	0f b6 00             	movzbl (%eax),%eax
80103ccf:	0f b6 c0             	movzbl %al,%eax
80103cd2:	09 d0                	or     %edx,%eax
80103cd4:	c1 e0 0a             	shl    $0xa,%eax
80103cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdd:	2d 00 04 00 00       	sub    $0x400,%eax
80103ce2:	83 ec 08             	sub    $0x8,%esp
80103ce5:	68 00 04 00 00       	push   $0x400
80103cea:	50                   	push   %eax
80103ceb:	e8 fb fe ff ff       	call   80103beb <mpsearch1>
80103cf0:	83 c4 10             	add    $0x10,%esp
80103cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cf6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cfa:	74 05                	je     80103d01 <mpsearch+0xa9>
      return mp;
80103cfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cff:	eb 15                	jmp    80103d16 <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d01:	83 ec 08             	sub    $0x8,%esp
80103d04:	68 00 00 01 00       	push   $0x10000
80103d09:	68 00 00 0f 00       	push   $0xf0000
80103d0e:	e8 d8 fe ff ff       	call   80103beb <mpsearch1>
80103d13:	83 c4 10             	add    $0x10,%esp
}
80103d16:	c9                   	leave  
80103d17:	c3                   	ret    

80103d18 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d18:	f3 0f 1e fb          	endbr32 
80103d1c:	55                   	push   %ebp
80103d1d:	89 e5                	mov    %esp,%ebp
80103d1f:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d22:	e8 31 ff ff ff       	call   80103c58 <mpsearch>
80103d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d2e:	74 0a                	je     80103d3a <mpconfig+0x22>
80103d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d33:	8b 40 04             	mov    0x4(%eax),%eax
80103d36:	85 c0                	test   %eax,%eax
80103d38:	75 07                	jne    80103d41 <mpconfig+0x29>
    return 0;
80103d3a:	b8 00 00 00 00       	mov    $0x0,%eax
80103d3f:	eb 7a                	jmp    80103dbb <mpconfig+0xa3>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d44:	8b 40 04             	mov    0x4(%eax),%eax
80103d47:	05 00 00 00 80       	add    $0x80000000,%eax
80103d4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d4f:	83 ec 04             	sub    $0x4,%esp
80103d52:	6a 04                	push   $0x4
80103d54:	68 c1 8c 10 80       	push   $0x80108cc1
80103d59:	ff 75 f0             	pushl  -0x10(%ebp)
80103d5c:	e8 4f 1a 00 00       	call   801057b0 <memcmp>
80103d61:	83 c4 10             	add    $0x10,%esp
80103d64:	85 c0                	test   %eax,%eax
80103d66:	74 07                	je     80103d6f <mpconfig+0x57>
    return 0;
80103d68:	b8 00 00 00 00       	mov    $0x0,%eax
80103d6d:	eb 4c                	jmp    80103dbb <mpconfig+0xa3>
  if(conf->version != 1 && conf->version != 4)
80103d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d72:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d76:	3c 01                	cmp    $0x1,%al
80103d78:	74 12                	je     80103d8c <mpconfig+0x74>
80103d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7d:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d81:	3c 04                	cmp    $0x4,%al
80103d83:	74 07                	je     80103d8c <mpconfig+0x74>
    return 0;
80103d85:	b8 00 00 00 00       	mov    $0x0,%eax
80103d8a:	eb 2f                	jmp    80103dbb <mpconfig+0xa3>
  if(sum((uchar*)conf, conf->length) != 0)
80103d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d8f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d93:	0f b7 c0             	movzwl %ax,%eax
80103d96:	83 ec 08             	sub    $0x8,%esp
80103d99:	50                   	push   %eax
80103d9a:	ff 75 f0             	pushl  -0x10(%ebp)
80103d9d:	e8 0d fe ff ff       	call   80103baf <sum>
80103da2:	83 c4 10             	add    $0x10,%esp
80103da5:	84 c0                	test   %al,%al
80103da7:	74 07                	je     80103db0 <mpconfig+0x98>
    return 0;
80103da9:	b8 00 00 00 00       	mov    $0x0,%eax
80103dae:	eb 0b                	jmp    80103dbb <mpconfig+0xa3>
  *pmp = mp;
80103db0:	8b 45 08             	mov    0x8(%ebp),%eax
80103db3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103db6:	89 10                	mov    %edx,(%eax)
  return conf;
80103db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103dbb:	c9                   	leave  
80103dbc:	c3                   	ret    

80103dbd <mpinit>:

void
mpinit(void)
{
80103dbd:	f3 0f 1e fb          	endbr32 
80103dc1:	55                   	push   %ebp
80103dc2:	89 e5                	mov    %esp,%ebp
80103dc4:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103dc7:	83 ec 0c             	sub    $0xc,%esp
80103dca:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103dcd:	50                   	push   %eax
80103dce:	e8 45 ff ff ff       	call   80103d18 <mpconfig>
80103dd3:	83 c4 10             	add    $0x10,%esp
80103dd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dd9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ddd:	75 0d                	jne    80103dec <mpinit+0x2f>
    panic("Expect to run on an SMP");
80103ddf:	83 ec 0c             	sub    $0xc,%esp
80103de2:	68 c6 8c 10 80       	push   $0x80108cc6
80103de7:	e8 e5 c7 ff ff       	call   801005d1 <panic>
  ismp = 1;
80103dec:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103df3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103df6:	8b 40 24             	mov    0x24(%eax),%eax
80103df9:	a3 fc 46 11 80       	mov    %eax,0x801146fc
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e01:	83 c0 2c             	add    $0x2c,%eax
80103e04:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e0a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e0e:	0f b7 d0             	movzwl %ax,%edx
80103e11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e14:	01 d0                	add    %edx,%eax
80103e16:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e19:	e9 8b 00 00 00       	jmp    80103ea9 <mpinit+0xec>
    switch(*p){
80103e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e21:	0f b6 00             	movzbl (%eax),%eax
80103e24:	0f b6 c0             	movzbl %al,%eax
80103e27:	83 f8 04             	cmp    $0x4,%eax
80103e2a:	7f 75                	jg     80103ea1 <mpinit+0xe4>
80103e2c:	83 f8 03             	cmp    $0x3,%eax
80103e2f:	7d 6a                	jge    80103e9b <mpinit+0xde>
80103e31:	83 f8 02             	cmp    $0x2,%eax
80103e34:	74 4d                	je     80103e83 <mpinit+0xc6>
80103e36:	83 f8 02             	cmp    $0x2,%eax
80103e39:	7f 66                	jg     80103ea1 <mpinit+0xe4>
80103e3b:	85 c0                	test   %eax,%eax
80103e3d:	74 07                	je     80103e46 <mpinit+0x89>
80103e3f:	83 f8 01             	cmp    $0x1,%eax
80103e42:	74 57                	je     80103e9b <mpinit+0xde>
80103e44:	eb 5b                	jmp    80103ea1 <mpinit+0xe4>
    case MPPROC:
      proc = (struct mpproc*)p;
80103e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e49:	89 45 e0             	mov    %eax,-0x20(%ebp)
      if(ncpu < NCPU) {
80103e4c:	a1 b0 48 11 80       	mov    0x801148b0,%eax
80103e51:	85 c0                	test   %eax,%eax
80103e53:	7f 28                	jg     80103e7d <mpinit+0xc0>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103e55:	8b 15 b0 48 11 80    	mov    0x801148b0,%edx
80103e5b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e5e:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e62:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80103e68:	81 c2 00 48 11 80    	add    $0x80114800,%edx
80103e6e:	88 02                	mov    %al,(%edx)
        ncpu++;
80103e70:	a1 b0 48 11 80       	mov    0x801148b0,%eax
80103e75:	83 c0 01             	add    $0x1,%eax
80103e78:	a3 b0 48 11 80       	mov    %eax,0x801148b0
      }
      p += sizeof(struct mpproc);
80103e7d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e81:	eb 26                	jmp    80103ea9 <mpinit+0xec>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e8c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e90:	a2 e0 47 11 80       	mov    %al,0x801147e0
      p += sizeof(struct mpioapic);
80103e95:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e99:	eb 0e                	jmp    80103ea9 <mpinit+0xec>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e9b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e9f:	eb 08                	jmp    80103ea9 <mpinit+0xec>
    default:
      ismp = 0;
80103ea1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103ea8:	90                   	nop
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eac:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103eaf:	0f 82 69 ff ff ff    	jb     80103e1e <mpinit+0x61>
    }
  }
  if(!ismp)
80103eb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103eb9:	75 0d                	jne    80103ec8 <mpinit+0x10b>
    panic("Didn't find a suitable machine");
80103ebb:	83 ec 0c             	sub    $0xc,%esp
80103ebe:	68 e0 8c 10 80       	push   $0x80108ce0
80103ec3:	e8 09 c7 ff ff       	call   801005d1 <panic>

  if(mp->imcrp){
80103ec8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ecb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ecf:	84 c0                	test   %al,%al
80103ed1:	74 30                	je     80103f03 <mpinit+0x146>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ed3:	83 ec 08             	sub    $0x8,%esp
80103ed6:	6a 70                	push   $0x70
80103ed8:	6a 22                	push   $0x22
80103eda:	e8 af fc ff ff       	call   80103b8e <outb>
80103edf:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ee2:	83 ec 0c             	sub    $0xc,%esp
80103ee5:	6a 23                	push   $0x23
80103ee7:	e8 85 fc ff ff       	call   80103b71 <inb>
80103eec:	83 c4 10             	add    $0x10,%esp
80103eef:	83 c8 01             	or     $0x1,%eax
80103ef2:	0f b6 c0             	movzbl %al,%eax
80103ef5:	83 ec 08             	sub    $0x8,%esp
80103ef8:	50                   	push   %eax
80103ef9:	6a 23                	push   $0x23
80103efb:	e8 8e fc ff ff       	call   80103b8e <outb>
80103f00:	83 c4 10             	add    $0x10,%esp
  }
}
80103f03:	90                   	nop
80103f04:	c9                   	leave  
80103f05:	c3                   	ret    

80103f06 <outb>:
{
80103f06:	55                   	push   %ebp
80103f07:	89 e5                	mov    %esp,%ebp
80103f09:	83 ec 08             	sub    $0x8,%esp
80103f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f12:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f16:	89 d0                	mov    %edx,%eax
80103f18:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f1b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f1f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f23:	ee                   	out    %al,(%dx)
}
80103f24:	90                   	nop
80103f25:	c9                   	leave  
80103f26:	c3                   	ret    

80103f27 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103f27:	f3 0f 1e fb          	endbr32 
80103f2b:	55                   	push   %ebp
80103f2c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f2e:	68 ff 00 00 00       	push   $0xff
80103f33:	6a 21                	push   $0x21
80103f35:	e8 cc ff ff ff       	call   80103f06 <outb>
80103f3a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f3d:	68 ff 00 00 00       	push   $0xff
80103f42:	68 a1 00 00 00       	push   $0xa1
80103f47:	e8 ba ff ff ff       	call   80103f06 <outb>
80103f4c:	83 c4 08             	add    $0x8,%esp
}
80103f4f:	90                   	nop
80103f50:	c9                   	leave  
80103f51:	c3                   	ret    

80103f52 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f52:	f3 0f 1e fb          	endbr32 
80103f56:	55                   	push   %ebp
80103f57:	89 e5                	mov    %esp,%ebp
80103f59:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103f5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f63:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f6f:	8b 10                	mov    (%eax),%edx
80103f71:	8b 45 08             	mov    0x8(%ebp),%eax
80103f74:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f76:	e8 e3 d0 ff ff       	call   8010105e <filealloc>
80103f7b:	8b 55 08             	mov    0x8(%ebp),%edx
80103f7e:	89 02                	mov    %eax,(%edx)
80103f80:	8b 45 08             	mov    0x8(%ebp),%eax
80103f83:	8b 00                	mov    (%eax),%eax
80103f85:	85 c0                	test   %eax,%eax
80103f87:	0f 84 c8 00 00 00    	je     80104055 <pipealloc+0x103>
80103f8d:	e8 cc d0 ff ff       	call   8010105e <filealloc>
80103f92:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f95:	89 02                	mov    %eax,(%edx)
80103f97:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f9a:	8b 00                	mov    (%eax),%eax
80103f9c:	85 c0                	test   %eax,%eax
80103f9e:	0f 84 b1 00 00 00    	je     80104055 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fa4:	e8 eb ed ff ff       	call   80102d94 <kalloc>
80103fa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fb0:	0f 84 a2 00 00 00    	je     80104058 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
80103fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb9:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fc0:	00 00 00 
  p->writeopen = 1;
80103fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc6:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fcd:	00 00 00 
  p->nwrite = 0;
80103fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fd3:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fda:	00 00 00 
  p->nread = 0;
80103fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe0:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fe7:	00 00 00 
  initlock(&p->lock, "pipe");
80103fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fed:	83 ec 08             	sub    $0x8,%esp
80103ff0:	68 ff 8c 10 80       	push   $0x80108cff
80103ff5:	50                   	push   %eax
80103ff6:	e8 85 14 00 00       	call   80105480 <initlock>
80103ffb:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80104001:	8b 00                	mov    (%eax),%eax
80104003:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104009:	8b 45 08             	mov    0x8(%ebp),%eax
8010400c:	8b 00                	mov    (%eax),%eax
8010400e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104012:	8b 45 08             	mov    0x8(%ebp),%eax
80104015:	8b 00                	mov    (%eax),%eax
80104017:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010401b:	8b 45 08             	mov    0x8(%ebp),%eax
8010401e:	8b 00                	mov    (%eax),%eax
80104020:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104023:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104026:	8b 45 0c             	mov    0xc(%ebp),%eax
80104029:	8b 00                	mov    (%eax),%eax
8010402b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104031:	8b 45 0c             	mov    0xc(%ebp),%eax
80104034:	8b 00                	mov    (%eax),%eax
80104036:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010403a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403d:	8b 00                	mov    (%eax),%eax
8010403f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104043:	8b 45 0c             	mov    0xc(%ebp),%eax
80104046:	8b 00                	mov    (%eax),%eax
80104048:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010404b:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010404e:	b8 00 00 00 00       	mov    $0x0,%eax
80104053:	eb 51                	jmp    801040a6 <pipealloc+0x154>
    goto bad;
80104055:	90                   	nop
80104056:	eb 01                	jmp    80104059 <pipealloc+0x107>
    goto bad;
80104058:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104059:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010405d:	74 0e                	je     8010406d <pipealloc+0x11b>
    kfree((char*)p);
8010405f:	83 ec 0c             	sub    $0xc,%esp
80104062:	ff 75 f4             	pushl  -0xc(%ebp)
80104065:	e8 8c ec ff ff       	call   80102cf6 <kfree>
8010406a:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 00                	mov    (%eax),%eax
80104072:	85 c0                	test   %eax,%eax
80104074:	74 11                	je     80104087 <pipealloc+0x135>
    fileclose(*f0);
80104076:	8b 45 08             	mov    0x8(%ebp),%eax
80104079:	8b 00                	mov    (%eax),%eax
8010407b:	83 ec 0c             	sub    $0xc,%esp
8010407e:	50                   	push   %eax
8010407f:	e8 a0 d0 ff ff       	call   80101124 <fileclose>
80104084:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408a:	8b 00                	mov    (%eax),%eax
8010408c:	85 c0                	test   %eax,%eax
8010408e:	74 11                	je     801040a1 <pipealloc+0x14f>
    fileclose(*f1);
80104090:	8b 45 0c             	mov    0xc(%ebp),%eax
80104093:	8b 00                	mov    (%eax),%eax
80104095:	83 ec 0c             	sub    $0xc,%esp
80104098:	50                   	push   %eax
80104099:	e8 86 d0 ff ff       	call   80101124 <fileclose>
8010409e:	83 c4 10             	add    $0x10,%esp
  return -1;
801040a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040a6:	c9                   	leave  
801040a7:	c3                   	ret    

801040a8 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040a8:	f3 0f 1e fb          	endbr32 
801040ac:	55                   	push   %ebp
801040ad:	89 e5                	mov    %esp,%ebp
801040af:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801040b2:	8b 45 08             	mov    0x8(%ebp),%eax
801040b5:	83 ec 0c             	sub    $0xc,%esp
801040b8:	50                   	push   %eax
801040b9:	e8 e8 13 00 00       	call   801054a6 <acquire>
801040be:	83 c4 10             	add    $0x10,%esp
  if(writable){
801040c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040c5:	74 23                	je     801040ea <pipeclose+0x42>
    p->writeopen = 0;
801040c7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ca:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040d1:	00 00 00 
    wakeup(&p->nread);
801040d4:	8b 45 08             	mov    0x8(%ebp),%eax
801040d7:	05 34 02 00 00       	add    $0x234,%eax
801040dc:	83 ec 0c             	sub    $0xc,%esp
801040df:	50                   	push   %eax
801040e0:	e8 91 0f 00 00       	call   80105076 <wakeup>
801040e5:	83 c4 10             	add    $0x10,%esp
801040e8:	eb 21                	jmp    8010410b <pipeclose+0x63>
  } else {
    p->readopen = 0;
801040ea:	8b 45 08             	mov    0x8(%ebp),%eax
801040ed:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040f4:	00 00 00 
    wakeup(&p->nwrite);
801040f7:	8b 45 08             	mov    0x8(%ebp),%eax
801040fa:	05 38 02 00 00       	add    $0x238,%eax
801040ff:	83 ec 0c             	sub    $0xc,%esp
80104102:	50                   	push   %eax
80104103:	e8 6e 0f 00 00       	call   80105076 <wakeup>
80104108:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104114:	85 c0                	test   %eax,%eax
80104116:	75 2c                	jne    80104144 <pipeclose+0x9c>
80104118:	8b 45 08             	mov    0x8(%ebp),%eax
8010411b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104121:	85 c0                	test   %eax,%eax
80104123:	75 1f                	jne    80104144 <pipeclose+0x9c>
    release(&p->lock);
80104125:	8b 45 08             	mov    0x8(%ebp),%eax
80104128:	83 ec 0c             	sub    $0xc,%esp
8010412b:	50                   	push   %eax
8010412c:	e8 e7 13 00 00       	call   80105518 <release>
80104131:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104134:	83 ec 0c             	sub    $0xc,%esp
80104137:	ff 75 08             	pushl  0x8(%ebp)
8010413a:	e8 b7 eb ff ff       	call   80102cf6 <kfree>
8010413f:	83 c4 10             	add    $0x10,%esp
80104142:	eb 10                	jmp    80104154 <pipeclose+0xac>
  } else
    release(&p->lock);
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	83 ec 0c             	sub    $0xc,%esp
8010414a:	50                   	push   %eax
8010414b:	e8 c8 13 00 00       	call   80105518 <release>
80104150:	83 c4 10             	add    $0x10,%esp
}
80104153:	90                   	nop
80104154:	90                   	nop
80104155:	c9                   	leave  
80104156:	c3                   	ret    

80104157 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104157:	f3 0f 1e fb          	endbr32 
8010415b:	55                   	push   %ebp
8010415c:	89 e5                	mov    %esp,%ebp
8010415e:	53                   	push   %ebx
8010415f:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	83 ec 0c             	sub    $0xc,%esp
80104168:	50                   	push   %eax
80104169:	e8 38 13 00 00       	call   801054a6 <acquire>
8010416e:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104171:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104178:	e9 ad 00 00 00       	jmp    8010422a <pipewrite+0xd3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104186:	85 c0                	test   %eax,%eax
80104188:	74 0c                	je     80104196 <pipewrite+0x3f>
8010418a:	e8 a2 02 00 00       	call   80104431 <myproc>
8010418f:	8b 40 24             	mov    0x24(%eax),%eax
80104192:	85 c0                	test   %eax,%eax
80104194:	74 19                	je     801041af <pipewrite+0x58>
        release(&p->lock);
80104196:	8b 45 08             	mov    0x8(%ebp),%eax
80104199:	83 ec 0c             	sub    $0xc,%esp
8010419c:	50                   	push   %eax
8010419d:	e8 76 13 00 00       	call   80105518 <release>
801041a2:	83 c4 10             	add    $0x10,%esp
        return -1;
801041a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041aa:	e9 a9 00 00 00       	jmp    80104258 <pipewrite+0x101>
      }
      wakeup(&p->nread);
801041af:	8b 45 08             	mov    0x8(%ebp),%eax
801041b2:	05 34 02 00 00       	add    $0x234,%eax
801041b7:	83 ec 0c             	sub    $0xc,%esp
801041ba:	50                   	push   %eax
801041bb:	e8 b6 0e 00 00       	call   80105076 <wakeup>
801041c0:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041c3:	8b 45 08             	mov    0x8(%ebp),%eax
801041c6:	8b 55 08             	mov    0x8(%ebp),%edx
801041c9:	81 c2 38 02 00 00    	add    $0x238,%edx
801041cf:	83 ec 08             	sub    $0x8,%esp
801041d2:	50                   	push   %eax
801041d3:	52                   	push   %edx
801041d4:	e8 70 0d 00 00       	call   80104f49 <sleep>
801041d9:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041dc:	8b 45 08             	mov    0x8(%ebp),%eax
801041df:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041e5:	8b 45 08             	mov    0x8(%ebp),%eax
801041e8:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ee:	05 00 02 00 00       	add    $0x200,%eax
801041f3:	39 c2                	cmp    %eax,%edx
801041f5:	74 86                	je     8010417d <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801041fd:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104209:	8d 48 01             	lea    0x1(%eax),%ecx
8010420c:	8b 55 08             	mov    0x8(%ebp),%edx
8010420f:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104215:	25 ff 01 00 00       	and    $0x1ff,%eax
8010421a:	89 c1                	mov    %eax,%ecx
8010421c:	0f b6 13             	movzbl (%ebx),%edx
8010421f:	8b 45 08             	mov    0x8(%ebp),%eax
80104222:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104226:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010422a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104230:	7c aa                	jl     801041dc <pipewrite+0x85>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104232:	8b 45 08             	mov    0x8(%ebp),%eax
80104235:	05 34 02 00 00       	add    $0x234,%eax
8010423a:	83 ec 0c             	sub    $0xc,%esp
8010423d:	50                   	push   %eax
8010423e:	e8 33 0e 00 00       	call   80105076 <wakeup>
80104243:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104246:	8b 45 08             	mov    0x8(%ebp),%eax
80104249:	83 ec 0c             	sub    $0xc,%esp
8010424c:	50                   	push   %eax
8010424d:	e8 c6 12 00 00       	call   80105518 <release>
80104252:	83 c4 10             	add    $0x10,%esp
  return n;
80104255:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104258:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010425b:	c9                   	leave  
8010425c:	c3                   	ret    

8010425d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010425d:	f3 0f 1e fb          	endbr32 
80104261:	55                   	push   %ebp
80104262:	89 e5                	mov    %esp,%ebp
80104264:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104267:	8b 45 08             	mov    0x8(%ebp),%eax
8010426a:	83 ec 0c             	sub    $0xc,%esp
8010426d:	50                   	push   %eax
8010426e:	e8 33 12 00 00       	call   801054a6 <acquire>
80104273:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104276:	eb 3e                	jmp    801042b6 <piperead+0x59>
    if(myproc()->killed){
80104278:	e8 b4 01 00 00       	call   80104431 <myproc>
8010427d:	8b 40 24             	mov    0x24(%eax),%eax
80104280:	85 c0                	test   %eax,%eax
80104282:	74 19                	je     8010429d <piperead+0x40>
      release(&p->lock);
80104284:	8b 45 08             	mov    0x8(%ebp),%eax
80104287:	83 ec 0c             	sub    $0xc,%esp
8010428a:	50                   	push   %eax
8010428b:	e8 88 12 00 00       	call   80105518 <release>
80104290:	83 c4 10             	add    $0x10,%esp
      return -1;
80104293:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104298:	e9 be 00 00 00       	jmp    8010435b <piperead+0xfe>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010429d:	8b 45 08             	mov    0x8(%ebp),%eax
801042a0:	8b 55 08             	mov    0x8(%ebp),%edx
801042a3:	81 c2 34 02 00 00    	add    $0x234,%edx
801042a9:	83 ec 08             	sub    $0x8,%esp
801042ac:	50                   	push   %eax
801042ad:	52                   	push   %edx
801042ae:	e8 96 0c 00 00       	call   80104f49 <sleep>
801042b3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042b6:	8b 45 08             	mov    0x8(%ebp),%eax
801042b9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c8:	39 c2                	cmp    %eax,%edx
801042ca:	75 0d                	jne    801042d9 <piperead+0x7c>
801042cc:	8b 45 08             	mov    0x8(%ebp),%eax
801042cf:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042d5:	85 c0                	test   %eax,%eax
801042d7:	75 9f                	jne    80104278 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042e0:	eb 48                	jmp    8010432a <piperead+0xcd>
    if(p->nread == p->nwrite)
801042e2:	8b 45 08             	mov    0x8(%ebp),%eax
801042e5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042eb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ee:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f4:	39 c2                	cmp    %eax,%edx
801042f6:	74 3c                	je     80104334 <piperead+0xd7>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042f8:	8b 45 08             	mov    0x8(%ebp),%eax
801042fb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104301:	8d 48 01             	lea    0x1(%eax),%ecx
80104304:	8b 55 08             	mov    0x8(%ebp),%edx
80104307:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010430d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104312:	89 c1                	mov    %eax,%ecx
80104314:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431a:	01 c2                	add    %eax,%edx
8010431c:	8b 45 08             	mov    0x8(%ebp),%eax
8010431f:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104324:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104326:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010432a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104330:	7c b0                	jl     801042e2 <piperead+0x85>
80104332:	eb 01                	jmp    80104335 <piperead+0xd8>
      break;
80104334:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104335:	8b 45 08             	mov    0x8(%ebp),%eax
80104338:	05 38 02 00 00       	add    $0x238,%eax
8010433d:	83 ec 0c             	sub    $0xc,%esp
80104340:	50                   	push   %eax
80104341:	e8 30 0d 00 00       	call   80105076 <wakeup>
80104346:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104349:	8b 45 08             	mov    0x8(%ebp),%eax
8010434c:	83 ec 0c             	sub    $0xc,%esp
8010434f:	50                   	push   %eax
80104350:	e8 c3 11 00 00       	call   80105518 <release>
80104355:	83 c4 10             	add    $0x10,%esp
  return i;
80104358:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010435b:	c9                   	leave  
8010435c:	c3                   	ret    

8010435d <readeflags>:
{
8010435d:	55                   	push   %ebp
8010435e:	89 e5                	mov    %esp,%ebp
80104360:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104363:	9c                   	pushf  
80104364:	58                   	pop    %eax
80104365:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104368:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010436b:	c9                   	leave  
8010436c:	c3                   	ret    

8010436d <sti>:
{
8010436d:	55                   	push   %ebp
8010436e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104370:	fb                   	sti    
}
80104371:	90                   	nop
80104372:	5d                   	pop    %ebp
80104373:	c3                   	ret    

80104374 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104374:	f3 0f 1e fb          	endbr32 
80104378:	55                   	push   %ebp
80104379:	89 e5                	mov    %esp,%ebp
8010437b:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
8010437e:	83 ec 08             	sub    $0x8,%esp
80104381:	68 04 8d 10 80       	push   $0x80108d04
80104386:	68 c0 48 11 80       	push   $0x801148c0
8010438b:	e8 f0 10 00 00       	call   80105480 <initlock>
80104390:	83 c4 10             	add    $0x10,%esp
}
80104393:	90                   	nop
80104394:	c9                   	leave  
80104395:	c3                   	ret    

80104396 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104396:	f3 0f 1e fb          	endbr32 
8010439a:	55                   	push   %ebp
8010439b:	89 e5                	mov    %esp,%ebp
8010439d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801043a0:	e8 10 00 00 00       	call   801043b5 <mycpu>
801043a5:	2d 00 48 11 80       	sub    $0x80114800,%eax
801043aa:	c1 f8 04             	sar    $0x4,%eax
801043ad:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801043b3:	c9                   	leave  
801043b4:	c3                   	ret    

801043b5 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801043b5:	f3 0f 1e fb          	endbr32 
801043b9:	55                   	push   %ebp
801043ba:	89 e5                	mov    %esp,%ebp
801043bc:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801043bf:	e8 99 ff ff ff       	call   8010435d <readeflags>
801043c4:	25 00 02 00 00       	and    $0x200,%eax
801043c9:	85 c0                	test   %eax,%eax
801043cb:	74 0d                	je     801043da <mycpu+0x25>
    panic("mycpu called with interrupts enabled\n");
801043cd:	83 ec 0c             	sub    $0xc,%esp
801043d0:	68 0c 8d 10 80       	push   $0x80108d0c
801043d5:	e8 f7 c1 ff ff       	call   801005d1 <panic>
  
  apicid = lapicid();
801043da:	e8 22 ed ff ff       	call   80103101 <lapicid>
801043df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801043e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043e9:	eb 2d                	jmp    80104418 <mycpu+0x63>
    if (cpus[i].apicid == apicid)
801043eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ee:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801043f4:	05 00 48 11 80       	add    $0x80114800,%eax
801043f9:	0f b6 00             	movzbl (%eax),%eax
801043fc:	0f b6 c0             	movzbl %al,%eax
801043ff:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80104402:	75 10                	jne    80104414 <mycpu+0x5f>
      return &cpus[i];
80104404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104407:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
8010440d:	05 00 48 11 80       	add    $0x80114800,%eax
80104412:	eb 1b                	jmp    8010442f <mycpu+0x7a>
  for (i = 0; i < ncpu; ++i) {
80104414:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104418:	a1 b0 48 11 80       	mov    0x801148b0,%eax
8010441d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104420:	7c c9                	jl     801043eb <mycpu+0x36>
  }
  panic("unknown apicid\n");
80104422:	83 ec 0c             	sub    $0xc,%esp
80104425:	68 32 8d 10 80       	push   $0x80108d32
8010442a:	e8 a2 c1 ff ff       	call   801005d1 <panic>
}
8010442f:	c9                   	leave  
80104430:	c3                   	ret    

80104431 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104431:	f3 0f 1e fb          	endbr32 
80104435:	55                   	push   %ebp
80104436:	89 e5                	mov    %esp,%ebp
80104438:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010443b:	e8 f2 11 00 00       	call   80105632 <pushcli>
  c = mycpu();
80104440:	e8 70 ff ff ff       	call   801043b5 <mycpu>
80104445:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104451:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104454:	e8 2a 12 00 00       	call   80105683 <popcli>
  return p;
80104459:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010445c:	c9                   	leave  
8010445d:	c3                   	ret    

8010445e <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010445e:	f3 0f 1e fb          	endbr32 
80104462:	55                   	push   %ebp
80104463:	89 e5                	mov    %esp,%ebp
80104465:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104468:	83 ec 0c             	sub    $0xc,%esp
8010446b:	68 c0 48 11 80       	push   $0x801148c0
80104470:	e8 31 10 00 00       	call   801054a6 <acquire>
80104475:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104478:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
8010447f:	eb 11                	jmp    80104492 <allocproc+0x34>
    if(p->state == UNUSED)
80104481:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104484:	8b 40 0c             	mov    0xc(%eax),%eax
80104487:	85 c0                	test   %eax,%eax
80104489:	74 2a                	je     801044b5 <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010448b:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104492:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
80104499:	72 e6                	jb     80104481 <allocproc+0x23>
      goto found;

  release(&ptable.lock);
8010449b:	83 ec 0c             	sub    $0xc,%esp
8010449e:	68 c0 48 11 80       	push   $0x801148c0
801044a3:	e8 70 10 00 00       	call   80105518 <release>
801044a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801044ab:	b8 00 00 00 00       	mov    $0x0,%eax
801044b0:	e9 dd 00 00 00       	jmp    80104592 <allocproc+0x134>
      goto found;
801044b5:	90                   	nop
801044b6:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044c4:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801044c9:	8d 50 01             	lea    0x1(%eax),%edx
801044cc:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801044d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044d5:	89 42 10             	mov    %eax,0x10(%edx)

  p->wtime = 0;
801044d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044db:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->rutime = 0;
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801044ec:	00 00 00 
  p->snapticks = ticks;
801044ef:	a1 40 73 11 80       	mov    0x80117340,%eax
801044f4:	89 c2                	mov    %eax,%edx
801044f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f9:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  release(&ptable.lock);
801044ff:	83 ec 0c             	sub    $0xc,%esp
80104502:	68 c0 48 11 80       	push   $0x801148c0
80104507:	e8 0c 10 00 00       	call   80105518 <release>
8010450c:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010450f:	e8 80 e8 ff ff       	call   80102d94 <kalloc>
80104514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104517:	89 42 08             	mov    %eax,0x8(%edx)
8010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451d:	8b 40 08             	mov    0x8(%eax),%eax
80104520:	85 c0                	test   %eax,%eax
80104522:	75 11                	jne    80104535 <allocproc+0xd7>
    p->state = UNUSED;
80104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104527:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010452e:	b8 00 00 00 00       	mov    $0x0,%eax
80104533:	eb 5d                	jmp    80104592 <allocproc+0x134>
  }
  sp = p->kstack + KSTACKSIZE;
80104535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104538:	8b 40 08             	mov    0x8(%eax),%eax
8010453b:	05 00 10 00 00       	add    $0x1000,%eax
80104540:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104543:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010454d:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104550:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104554:	ba c4 6b 10 80       	mov    $0x80106bc4,%edx
80104559:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010455c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010455e:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104568:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104571:	83 ec 04             	sub    $0x4,%esp
80104574:	6a 14                	push   $0x14
80104576:	6a 00                	push   $0x0
80104578:	50                   	push   %eax
80104579:	e8 c7 11 00 00       	call   80105745 <memset>
8010457e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104584:	8b 40 1c             	mov    0x1c(%eax),%eax
80104587:	ba ff 4e 10 80       	mov    $0x80104eff,%edx
8010458c:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104592:	c9                   	leave  
80104593:	c3                   	ret    

80104594 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104594:	f3 0f 1e fb          	endbr32 
80104598:	55                   	push   %ebp
80104599:	89 e5                	mov    %esp,%ebp
8010459b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010459e:	e8 bb fe ff ff       	call   8010445e <allocproc>
801045a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	a3 20 c6 10 80       	mov    %eax,0x8010c620
  if((p->pgdir = setupkvm()) == 0)
801045ae:	e8 b3 3b 00 00       	call   80108166 <setupkvm>
801045b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b6:	89 42 04             	mov    %eax,0x4(%edx)
801045b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bc:	8b 40 04             	mov    0x4(%eax),%eax
801045bf:	85 c0                	test   %eax,%eax
801045c1:	75 0d                	jne    801045d0 <userinit+0x3c>
    panic("userinit: out of memory?");
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	68 42 8d 10 80       	push   $0x80108d42
801045cb:	e8 01 c0 ff ff       	call   801005d1 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045d0:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d8:	8b 40 04             	mov    0x4(%eax),%eax
801045db:	83 ec 04             	sub    $0x4,%esp
801045de:	52                   	push   %edx
801045df:	68 c0 c4 10 80       	push   $0x8010c4c0
801045e4:	50                   	push   %eax
801045e5:	e8 f5 3d 00 00       	call   801083df <inituvm>
801045ea:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f0:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f9:	8b 40 18             	mov    0x18(%eax),%eax
801045fc:	83 ec 04             	sub    $0x4,%esp
801045ff:	6a 4c                	push   $0x4c
80104601:	6a 00                	push   $0x0
80104603:	50                   	push   %eax
80104604:	e8 3c 11 00 00       	call   80105745 <memset>
80104609:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	8b 40 18             	mov    0x18(%eax),%eax
80104612:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461b:	8b 40 18             	mov    0x18(%eax),%eax
8010461e:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 50 18             	mov    0x18(%eax),%edx
8010462a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462d:	8b 40 18             	mov    0x18(%eax),%eax
80104630:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104634:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463b:	8b 50 18             	mov    0x18(%eax),%edx
8010463e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104641:	8b 40 18             	mov    0x18(%eax),%eax
80104644:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104648:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010464c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464f:	8b 40 18             	mov    0x18(%eax),%eax
80104652:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104659:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465c:	8b 40 18             	mov    0x18(%eax),%eax
8010465f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	8b 40 18             	mov    0x18(%eax),%eax
8010466c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104676:	83 c0 6c             	add    $0x6c,%eax
80104679:	83 ec 04             	sub    $0x4,%esp
8010467c:	6a 10                	push   $0x10
8010467e:	68 5b 8d 10 80       	push   $0x80108d5b
80104683:	50                   	push   %eax
80104684:	e8 d7 12 00 00       	call   80105960 <safestrcpy>
80104689:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010468c:	83 ec 0c             	sub    $0xc,%esp
8010468f:	68 64 8d 10 80       	push   $0x80108d64
80104694:	e8 76 df ff ff       	call   8010260f <namei>
80104699:	83 c4 10             	add    $0x10,%esp
8010469c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
801046a2:	83 ec 0c             	sub    $0xc,%esp
801046a5:	68 c0 48 11 80       	push   $0x801148c0
801046aa:	e8 f7 0d 00 00       	call   801054a6 <acquire>
801046af:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
801046b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801046bc:	83 ec 0c             	sub    $0xc,%esp
801046bf:	68 c0 48 11 80       	push   $0x801148c0
801046c4:	e8 4f 0e 00 00       	call   80105518 <release>
801046c9:	83 c4 10             	add    $0x10,%esp
}
801046cc:	90                   	nop
801046cd:	c9                   	leave  
801046ce:	c3                   	ret    

801046cf <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046cf:	f3 0f 1e fb          	endbr32 
801046d3:	55                   	push   %ebp
801046d4:	89 e5                	mov    %esp,%ebp
801046d6:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
801046d9:	e8 53 fd ff ff       	call   80104431 <myproc>
801046de:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801046e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046e4:	8b 00                	mov    (%eax),%eax
801046e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046e9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046ed:	7e 2e                	jle    8010471d <growproc+0x4e>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801046ef:	8b 55 08             	mov    0x8(%ebp),%edx
801046f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f5:	01 c2                	add    %eax,%edx
801046f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046fa:	8b 40 04             	mov    0x4(%eax),%eax
801046fd:	83 ec 04             	sub    $0x4,%esp
80104700:	52                   	push   %edx
80104701:	ff 75 f4             	pushl  -0xc(%ebp)
80104704:	50                   	push   %eax
80104705:	e8 1a 3e 00 00       	call   80108524 <allocuvm>
8010470a:	83 c4 10             	add    $0x10,%esp
8010470d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104710:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104714:	75 3b                	jne    80104751 <growproc+0x82>
      return -1;
80104716:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471b:	eb 4f                	jmp    8010476c <growproc+0x9d>
  } else if(n < 0){
8010471d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104721:	79 2e                	jns    80104751 <growproc+0x82>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104723:	8b 55 08             	mov    0x8(%ebp),%edx
80104726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104729:	01 c2                	add    %eax,%edx
8010472b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010472e:	8b 40 04             	mov    0x4(%eax),%eax
80104731:	83 ec 04             	sub    $0x4,%esp
80104734:	52                   	push   %edx
80104735:	ff 75 f4             	pushl  -0xc(%ebp)
80104738:	50                   	push   %eax
80104739:	e8 ef 3e 00 00       	call   8010862d <deallocuvm>
8010473e:	83 c4 10             	add    $0x10,%esp
80104741:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104744:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104748:	75 07                	jne    80104751 <growproc+0x82>
      return -1;
8010474a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474f:	eb 1b                	jmp    8010476c <growproc+0x9d>
  }
  curproc->sz = sz;
80104751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104754:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104757:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104759:	83 ec 0c             	sub    $0xc,%esp
8010475c:	ff 75 f0             	pushl  -0x10(%ebp)
8010475f:	e8 d8 3a 00 00       	call   8010823c <switchuvm>
80104764:	83 c4 10             	add    $0x10,%esp
  return 0;
80104767:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010476c:	c9                   	leave  
8010476d:	c3                   	ret    

8010476e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010476e:	f3 0f 1e fb          	endbr32 
80104772:	55                   	push   %ebp
80104773:	89 e5                	mov    %esp,%ebp
80104775:	57                   	push   %edi
80104776:	56                   	push   %esi
80104777:	53                   	push   %ebx
80104778:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010477b:	e8 b1 fc ff ff       	call   80104431 <myproc>
80104780:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80104783:	e8 d6 fc ff ff       	call   8010445e <allocproc>
80104788:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010478b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010478f:	75 0a                	jne    8010479b <fork+0x2d>
    return -1;
80104791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104796:	e9 48 01 00 00       	jmp    801048e3 <fork+0x175>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010479b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479e:	8b 10                	mov    (%eax),%edx
801047a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a3:	8b 40 04             	mov    0x4(%eax),%eax
801047a6:	83 ec 08             	sub    $0x8,%esp
801047a9:	52                   	push   %edx
801047aa:	50                   	push   %eax
801047ab:	e8 27 40 00 00       	call   801087d7 <copyuvm>
801047b0:	83 c4 10             	add    $0x10,%esp
801047b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047b6:	89 42 04             	mov    %eax,0x4(%edx)
801047b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047bc:	8b 40 04             	mov    0x4(%eax),%eax
801047bf:	85 c0                	test   %eax,%eax
801047c1:	75 30                	jne    801047f3 <fork+0x85>
    kfree(np->kstack);
801047c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047c6:	8b 40 08             	mov    0x8(%eax),%eax
801047c9:	83 ec 0c             	sub    $0xc,%esp
801047cc:	50                   	push   %eax
801047cd:	e8 24 e5 ff ff       	call   80102cf6 <kfree>
801047d2:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047e2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ee:	e9 f0 00 00 00       	jmp    801048e3 <fork+0x175>
  }
  np->sz = curproc->sz;
801047f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f6:	8b 10                	mov    (%eax),%edx
801047f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047fb:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801047fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104800:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104803:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104806:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104809:	8b 48 18             	mov    0x18(%eax),%ecx
8010480c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010480f:	8b 40 18             	mov    0x18(%eax),%eax
80104812:	89 c2                	mov    %eax,%edx
80104814:	89 cb                	mov    %ecx,%ebx
80104816:	b8 13 00 00 00       	mov    $0x13,%eax
8010481b:	89 d7                	mov    %edx,%edi
8010481d:	89 de                	mov    %ebx,%esi
8010481f:	89 c1                	mov    %eax,%ecx
80104821:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104823:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104826:	8b 40 18             	mov    0x18(%eax),%eax
80104829:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104830:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104837:	eb 3b                	jmp    80104874 <fork+0x106>
    if(curproc->ofile[i])
80104839:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010483f:	83 c2 08             	add    $0x8,%edx
80104842:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104846:	85 c0                	test   %eax,%eax
80104848:	74 26                	je     80104870 <fork+0x102>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010484a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104850:	83 c2 08             	add    $0x8,%edx
80104853:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104857:	83 ec 0c             	sub    $0xc,%esp
8010485a:	50                   	push   %eax
8010485b:	e8 6f c8 ff ff       	call   801010cf <filedup>
80104860:	83 c4 10             	add    $0x10,%esp
80104863:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104866:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104869:	83 c1 08             	add    $0x8,%ecx
8010486c:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104870:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104874:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104878:	7e bf                	jle    80104839 <fork+0xcb>
  np->cwd = idup(curproc->cwd);
8010487a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487d:	8b 40 68             	mov    0x68(%eax),%eax
80104880:	83 ec 0c             	sub    $0xc,%esp
80104883:	50                   	push   %eax
80104884:	e8 dd d1 ff ff       	call   80101a66 <idup>
80104889:	83 c4 10             	add    $0x10,%esp
8010488c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010488f:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104892:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104895:	8d 50 6c             	lea    0x6c(%eax),%edx
80104898:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010489b:	83 c0 6c             	add    $0x6c,%eax
8010489e:	83 ec 04             	sub    $0x4,%esp
801048a1:	6a 10                	push   $0x10
801048a3:	52                   	push   %edx
801048a4:	50                   	push   %eax
801048a5:	e8 b6 10 00 00       	call   80105960 <safestrcpy>
801048aa:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801048ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b0:	8b 40 10             	mov    0x10(%eax),%eax
801048b3:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
801048b6:	83 ec 0c             	sub    $0xc,%esp
801048b9:	68 c0 48 11 80       	push   $0x801148c0
801048be:	e8 e3 0b 00 00       	call   801054a6 <acquire>
801048c3:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
801048c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048c9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801048d0:	83 ec 0c             	sub    $0xc,%esp
801048d3:	68 c0 48 11 80       	push   $0x801148c0
801048d8:	e8 3b 0c 00 00       	call   80105518 <release>
801048dd:	83 c4 10             	add    $0x10,%esp

  return pid;
801048e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801048e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048e6:	5b                   	pop    %ebx
801048e7:	5e                   	pop    %esi
801048e8:	5f                   	pop    %edi
801048e9:	5d                   	pop    %ebp
801048ea:	c3                   	ret    

801048eb <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048eb:	f3 0f 1e fb          	endbr32 
801048ef:	55                   	push   %ebp
801048f0:	89 e5                	mov    %esp,%ebp
801048f2:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801048f5:	e8 37 fb ff ff       	call   80104431 <myproc>
801048fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801048fd:	a1 20 c6 10 80       	mov    0x8010c620,%eax
80104902:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104905:	75 0d                	jne    80104914 <exit+0x29>
    panic("init exiting");
80104907:	83 ec 0c             	sub    $0xc,%esp
8010490a:	68 66 8d 10 80       	push   $0x80108d66
8010490f:	e8 bd bc ff ff       	call   801005d1 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104914:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010491b:	eb 3f                	jmp    8010495c <exit+0x71>
    if(curproc->ofile[fd]){
8010491d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104920:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104923:	83 c2 08             	add    $0x8,%edx
80104926:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010492a:	85 c0                	test   %eax,%eax
8010492c:	74 2a                	je     80104958 <exit+0x6d>
      fileclose(curproc->ofile[fd]);
8010492e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104931:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104934:	83 c2 08             	add    $0x8,%edx
80104937:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010493b:	83 ec 0c             	sub    $0xc,%esp
8010493e:	50                   	push   %eax
8010493f:	e8 e0 c7 ff ff       	call   80101124 <fileclose>
80104944:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80104947:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010494a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494d:	83 c2 08             	add    $0x8,%edx
80104950:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104957:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104958:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010495c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104960:	7e bb                	jle    8010491d <exit+0x32>
    }
  }

  begin_op();
80104962:	e8 0c ed ff ff       	call   80103673 <begin_op>
  iput(curproc->cwd);
80104967:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010496a:	8b 40 68             	mov    0x68(%eax),%eax
8010496d:	83 ec 0c             	sub    $0xc,%esp
80104970:	50                   	push   %eax
80104971:	e8 97 d2 ff ff       	call   80101c0d <iput>
80104976:	83 c4 10             	add    $0x10,%esp
  end_op();
80104979:	e8 85 ed ff ff       	call   80103703 <end_op>
  curproc->cwd = 0;
8010497e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104981:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104988:	83 ec 0c             	sub    $0xc,%esp
8010498b:	68 c0 48 11 80       	push   $0x801148c0
80104990:	e8 11 0b 00 00       	call   801054a6 <acquire>
80104995:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104998:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010499b:	8b 40 14             	mov    0x14(%eax),%eax
8010499e:	83 ec 0c             	sub    $0xc,%esp
801049a1:	50                   	push   %eax
801049a2:	e8 78 06 00 00       	call   8010501f <wakeup1>
801049a7:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049aa:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
801049b1:	eb 3a                	jmp    801049ed <exit+0x102>
    if(p->parent == curproc){
801049b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b6:	8b 40 14             	mov    0x14(%eax),%eax
801049b9:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801049bc:	75 28                	jne    801049e6 <exit+0xfb>
      p->parent = initproc;
801049be:	8b 15 20 c6 10 80    	mov    0x8010c620,%edx
801049c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c7:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049cd:	8b 40 0c             	mov    0xc(%eax),%eax
801049d0:	83 f8 05             	cmp    $0x5,%eax
801049d3:	75 11                	jne    801049e6 <exit+0xfb>
        wakeup1(initproc);
801049d5:	a1 20 c6 10 80       	mov    0x8010c620,%eax
801049da:	83 ec 0c             	sub    $0xc,%esp
801049dd:	50                   	push   %eax
801049de:	e8 3c 06 00 00       	call   8010501f <wakeup1>
801049e3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049e6:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801049ed:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
801049f4:	72 bd                	jb     801049b3 <exit+0xc8>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801049f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  curproc->rutime += ticks - curproc->snapticks;
80104a00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a03:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104a09:	89 c1                	mov    %eax,%ecx
80104a0b:	8b 15 40 73 11 80    	mov    0x80117340,%edx
80104a11:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a14:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104a1a:	29 c2                	sub    %eax,%edx
80104a1c:	89 d0                	mov    %edx,%eax
80104a1e:	01 c8                	add    %ecx,%eax
80104a20:	89 c2                	mov    %eax,%edx
80104a22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a25:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  sched();
80104a2b:	e8 93 03 00 00       	call   80104dc3 <sched>
  panic("zombie exit");
80104a30:	83 ec 0c             	sub    $0xc,%esp
80104a33:	68 73 8d 10 80       	push   $0x80108d73
80104a38:	e8 94 bb ff ff       	call   801005d1 <panic>

80104a3d <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a3d:	f3 0f 1e fb          	endbr32 
80104a41:	55                   	push   %ebp
80104a42:	89 e5                	mov    %esp,%ebp
80104a44:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104a47:	e8 e5 f9 ff ff       	call   80104431 <myproc>
80104a4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104a4f:	83 ec 0c             	sub    $0xc,%esp
80104a52:	68 c0 48 11 80       	push   $0x801148c0
80104a57:	e8 4a 0a 00 00       	call   801054a6 <acquire>
80104a5c:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104a5f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a66:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
80104a6d:	e9 a4 00 00 00       	jmp    80104b16 <wait+0xd9>
      //if(p->state != UNUSED) cprintf("pid: %d, wtime: %d, rutime: %d\n", p->pid, p->wtime, p->rutime);
      if(p->parent != curproc)
80104a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a75:	8b 40 14             	mov    0x14(%eax),%eax
80104a78:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a7b:	0f 85 8d 00 00 00    	jne    80104b0e <wait+0xd1>
        continue;
      havekids = 1;
80104a81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8b:	8b 40 0c             	mov    0xc(%eax),%eax
80104a8e:	83 f8 05             	cmp    $0x5,%eax
80104a91:	75 7c                	jne    80104b0f <wait+0xd2>
        // Found one.
        pid = p->pid;
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	8b 40 10             	mov    0x10(%eax),%eax
80104a99:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9f:	8b 40 08             	mov    0x8(%eax),%eax
80104aa2:	83 ec 0c             	sub    $0xc,%esp
80104aa5:	50                   	push   %eax
80104aa6:	e8 4b e2 ff ff       	call   80102cf6 <kfree>
80104aab:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abb:	8b 40 04             	mov    0x4(%eax),%eax
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	50                   	push   %eax
80104ac2:	e8 2e 3c 00 00       	call   801086f5 <freevm>
80104ac7:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae8:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104af9:	83 ec 0c             	sub    $0xc,%esp
80104afc:	68 c0 48 11 80       	push   $0x801148c0
80104b01:	e8 12 0a 00 00       	call   80105518 <release>
80104b06:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b0c:	eb 54                	jmp    80104b62 <wait+0x125>
        continue;
80104b0e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b0f:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b16:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
80104b1d:	0f 82 4f ff ff ff    	jb     80104a72 <wait+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104b23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b27:	74 0a                	je     80104b33 <wait+0xf6>
80104b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b2c:	8b 40 24             	mov    0x24(%eax),%eax
80104b2f:	85 c0                	test   %eax,%eax
80104b31:	74 17                	je     80104b4a <wait+0x10d>
      release(&ptable.lock);
80104b33:	83 ec 0c             	sub    $0xc,%esp
80104b36:	68 c0 48 11 80       	push   $0x801148c0
80104b3b:	e8 d8 09 00 00       	call   80105518 <release>
80104b40:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b48:	eb 18                	jmp    80104b62 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104b4a:	83 ec 08             	sub    $0x8,%esp
80104b4d:	68 c0 48 11 80       	push   $0x801148c0
80104b52:	ff 75 ec             	pushl  -0x14(%ebp)
80104b55:	e8 ef 03 00 00       	call   80104f49 <sleep>
80104b5a:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b5d:	e9 fd fe ff ff       	jmp    80104a5f <wait+0x22>
  }
}
80104b62:	c9                   	leave  
80104b63:	c3                   	ret    

80104b64 <wait2>:

int wait2(int *wtime, int *rutime) {
80104b64:	f3 0f 1e fb          	endbr32 
80104b68:	55                   	push   %ebp
80104b69:	89 e5                	mov    %esp,%ebp
80104b6b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b6e:	e8 be f8 ff ff       	call   80104431 <myproc>
80104b73:	89 45 ec             	mov    %eax,-0x14(%ebp)

  acquire(&ptable.lock);
80104b76:	83 ec 0c             	sub    $0xc,%esp
80104b79:	68 c0 48 11 80       	push   $0x801148c0
80104b7e:	e8 23 09 00 00       	call   801054a6 <acquire>
80104b83:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104b86:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b8d:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
80104b94:	e9 d8 00 00 00       	jmp    80104c71 <wait2+0x10d>
      //if(p->state != UNUSED) cprintf("pid: %d, wtime: %d, rutime: %d\n", p->pid, p->wtime, p->rutime);
      if(p->parent != curproc)
80104b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9c:	8b 40 14             	mov    0x14(%eax),%eax
80104b9f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104ba2:	0f 85 c1 00 00 00    	jne    80104c69 <wait2+0x105>
        continue;
      havekids = 1;
80104ba8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb5:	83 f8 05             	cmp    $0x5,%eax
80104bb8:	0f 85 ac 00 00 00    	jne    80104c6a <wait2+0x106>
        // Found one.
        *wtime = p->wtime;
80104bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc1:	8b 50 7c             	mov    0x7c(%eax),%edx
80104bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc7:	89 10                	mov    %edx,(%eax)
        *rutime = p->rutime;
80104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcc:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bd5:	89 10                	mov    %edx,(%eax)
        //cprintf("wtime: %d, rutime: %d", *wtime, *rutime);
        pid = p->pid;
80104bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bda:	8b 40 10             	mov    0x10(%eax),%eax
80104bdd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be3:	8b 40 08             	mov    0x8(%eax),%eax
80104be6:	83 ec 0c             	sub    $0xc,%esp
80104be9:	50                   	push   %eax
80104bea:	e8 07 e1 ff ff       	call   80102cf6 <kfree>
80104bef:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bff:	8b 40 04             	mov    0x4(%eax),%eax
80104c02:	83 ec 0c             	sub    $0xc,%esp
80104c05:	50                   	push   %eax
80104c06:	e8 ea 3a 00 00       	call   801086f5 <freevm>
80104c0b:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c11:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c1b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c25:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2f:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c36:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->wtime = 0;
80104c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c40:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
        p->rutime = 0;
80104c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4a:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104c51:	00 00 00 
        release(&ptable.lock);
80104c54:	83 ec 0c             	sub    $0xc,%esp
80104c57:	68 c0 48 11 80       	push   $0x801148c0
80104c5c:	e8 b7 08 00 00       	call   80105518 <release>
80104c61:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c64:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c67:	eb 59                	jmp    80104cc2 <wait2+0x15e>
        continue;
80104c69:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c6a:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104c71:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
80104c78:	0f 82 1b ff ff ff    	jb     80104b99 <wait2+0x35>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || myproc()->killed){
80104c7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c82:	74 0c                	je     80104c90 <wait2+0x12c>
80104c84:	e8 a8 f7 ff ff       	call   80104431 <myproc>
80104c89:	8b 40 24             	mov    0x24(%eax),%eax
80104c8c:	85 c0                	test   %eax,%eax
80104c8e:	74 17                	je     80104ca7 <wait2+0x143>
      release(&ptable.lock);
80104c90:	83 ec 0c             	sub    $0xc,%esp
80104c93:	68 c0 48 11 80       	push   $0x801148c0
80104c98:	e8 7b 08 00 00       	call   80105518 <release>
80104c9d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ca5:	eb 1b                	jmp    80104cc2 <wait2+0x15e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(myproc(), &ptable.lock);  //DOC: wait-sleep
80104ca7:	e8 85 f7 ff ff       	call   80104431 <myproc>
80104cac:	83 ec 08             	sub    $0x8,%esp
80104caf:	68 c0 48 11 80       	push   $0x801148c0
80104cb4:	50                   	push   %eax
80104cb5:	e8 8f 02 00 00       	call   80104f49 <sleep>
80104cba:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104cbd:	e9 c4 fe ff ff       	jmp    80104b86 <wait2+0x22>
  }
}
80104cc2:	c9                   	leave  
80104cc3:	c3                   	ret    

80104cc4 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104cc4:	f3 0f 1e fb          	endbr32 
80104cc8:	55                   	push   %ebp
80104cc9:	89 e5                	mov    %esp,%ebp
80104ccb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104cce:	e8 e2 f6 ff ff       	call   801043b5 <mycpu>
80104cd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ce0:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104ce3:	e8 85 f6 ff ff       	call   8010436d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104ce8:	83 ec 0c             	sub    $0xc,%esp
80104ceb:	68 c0 48 11 80       	push   $0x801148c0
80104cf0:	e8 b1 07 00 00       	call   801054a6 <acquire>
80104cf5:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cf8:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
80104cff:	e9 9d 00 00 00       	jmp    80104da1 <scheduler+0xdd>
      if(p->state != RUNNABLE)
80104d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d07:	8b 40 0c             	mov    0xc(%eax),%eax
80104d0a:	83 f8 03             	cmp    $0x3,%eax
80104d0d:	0f 85 86 00 00 00    	jne    80104d99 <scheduler+0xd5>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d19:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104d1f:	83 ec 0c             	sub    $0xc,%esp
80104d22:	ff 75 f4             	pushl  -0xc(%ebp)
80104d25:	e8 12 35 00 00       	call   8010823c <switchuvm>
80104d2a:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d30:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      p->wtime += ticks - p->snapticks;
80104d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3a:	8b 40 7c             	mov    0x7c(%eax),%eax
80104d3d:	89 c1                	mov    %eax,%ecx
80104d3f:	8b 15 40 73 11 80    	mov    0x80117340,%edx
80104d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d48:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104d4e:	29 c2                	sub    %eax,%edx
80104d50:	89 d0                	mov    %edx,%eax
80104d52:	01 c8                	add    %ecx,%eax
80104d54:	89 c2                	mov    %eax,%edx
80104d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d59:	89 50 7c             	mov    %edx,0x7c(%eax)
      p->snapticks = ticks;
80104d5c:	a1 40 73 11 80       	mov    0x80117340,%eax
80104d61:	89 c2                	mov    %eax,%edx
80104d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d66:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

      swtch(&(c->scheduler), p->context);
80104d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d72:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d75:	83 c2 04             	add    $0x4,%edx
80104d78:	83 ec 08             	sub    $0x8,%esp
80104d7b:	50                   	push   %eax
80104d7c:	52                   	push   %edx
80104d7d:	e8 57 0c 00 00       	call   801059d9 <swtch>
80104d82:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104d85:	e8 95 34 00 00       	call   8010821f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d8d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104d94:	00 00 00 
80104d97:	eb 01                	jmp    80104d9a <scheduler+0xd6>
        continue;
80104d99:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d9a:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104da1:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
80104da8:	0f 82 56 ff ff ff    	jb     80104d04 <scheduler+0x40>
    }
    release(&ptable.lock);
80104dae:	83 ec 0c             	sub    $0xc,%esp
80104db1:	68 c0 48 11 80       	push   $0x801148c0
80104db6:	e8 5d 07 00 00       	call   80105518 <release>
80104dbb:	83 c4 10             	add    $0x10,%esp
    sti();
80104dbe:	e9 20 ff ff ff       	jmp    80104ce3 <scheduler+0x1f>

80104dc3 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104dc3:	f3 0f 1e fb          	endbr32 
80104dc7:	55                   	push   %ebp
80104dc8:	89 e5                	mov    %esp,%ebp
80104dca:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
80104dcd:	e8 5f f6 ff ff       	call   80104431 <myproc>
80104dd2:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104dd5:	83 ec 0c             	sub    $0xc,%esp
80104dd8:	68 c0 48 11 80       	push   $0x801148c0
80104ddd:	e8 0b 08 00 00       	call   801055ed <holding>
80104de2:	83 c4 10             	add    $0x10,%esp
80104de5:	85 c0                	test   %eax,%eax
80104de7:	75 0d                	jne    80104df6 <sched+0x33>
    panic("sched ptable.lock");
80104de9:	83 ec 0c             	sub    $0xc,%esp
80104dec:	68 7f 8d 10 80       	push   $0x80108d7f
80104df1:	e8 db b7 ff ff       	call   801005d1 <panic>
  if(mycpu()->ncli != 1)
80104df6:	e8 ba f5 ff ff       	call   801043b5 <mycpu>
80104dfb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e01:	83 f8 01             	cmp    $0x1,%eax
80104e04:	74 0d                	je     80104e13 <sched+0x50>
    panic("sched locks");
80104e06:	83 ec 0c             	sub    $0xc,%esp
80104e09:	68 91 8d 10 80       	push   $0x80108d91
80104e0e:	e8 be b7 ff ff       	call   801005d1 <panic>
  if(p->state == RUNNING)
80104e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e16:	8b 40 0c             	mov    0xc(%eax),%eax
80104e19:	83 f8 04             	cmp    $0x4,%eax
80104e1c:	75 0d                	jne    80104e2b <sched+0x68>
    panic("sched running");
80104e1e:	83 ec 0c             	sub    $0xc,%esp
80104e21:	68 9d 8d 10 80       	push   $0x80108d9d
80104e26:	e8 a6 b7 ff ff       	call   801005d1 <panic>
  if(readeflags()&FL_IF)
80104e2b:	e8 2d f5 ff ff       	call   8010435d <readeflags>
80104e30:	25 00 02 00 00       	and    $0x200,%eax
80104e35:	85 c0                	test   %eax,%eax
80104e37:	74 0d                	je     80104e46 <sched+0x83>
    panic("sched interruptible");
80104e39:	83 ec 0c             	sub    $0xc,%esp
80104e3c:	68 ab 8d 10 80       	push   $0x80108dab
80104e41:	e8 8b b7 ff ff       	call   801005d1 <panic>
  intena = mycpu()->intena;
80104e46:	e8 6a f5 ff ff       	call   801043b5 <mycpu>
80104e4b:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104e54:	e8 5c f5 ff ff       	call   801043b5 <mycpu>
80104e59:	8b 40 04             	mov    0x4(%eax),%eax
80104e5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e5f:	83 c2 1c             	add    $0x1c,%edx
80104e62:	83 ec 08             	sub    $0x8,%esp
80104e65:	50                   	push   %eax
80104e66:	52                   	push   %edx
80104e67:	e8 6d 0b 00 00       	call   801059d9 <swtch>
80104e6c:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104e6f:	e8 41 f5 ff ff       	call   801043b5 <mycpu>
80104e74:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e77:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104e7d:	90                   	nop
80104e7e:	c9                   	leave  
80104e7f:	c3                   	ret    

80104e80 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e80:	f3 0f 1e fb          	endbr32 
80104e84:	55                   	push   %ebp
80104e85:	89 e5                	mov    %esp,%ebp
80104e87:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104e8a:	e8 a2 f5 ff ff       	call   80104431 <myproc>
80104e8f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  acquire(&ptable.lock);  //DOC: yieldlock
80104e92:	83 ec 0c             	sub    $0xc,%esp
80104e95:	68 c0 48 11 80       	push   $0x801148c0
80104e9a:	e8 07 06 00 00       	call   801054a6 <acquire>
80104e9f:	83 c4 10             	add    $0x10,%esp
  p->state = RUNNABLE;
80104ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  p->rutime += ticks - p->snapticks;
80104eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eaf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104eb5:	89 c1                	mov    %eax,%ecx
80104eb7:	8b 15 40 73 11 80    	mov    0x80117340,%edx
80104ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec0:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104ec6:	29 c2                	sub    %eax,%edx
80104ec8:	89 d0                	mov    %edx,%eax
80104eca:	01 c8                	add    %ecx,%eax
80104ecc:	89 c2                	mov    %eax,%edx
80104ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed1:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  p->snapticks = ticks;
80104ed7:	a1 40 73 11 80       	mov    0x80117340,%eax
80104edc:	89 c2                	mov    %eax,%edx
80104ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee1:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  sched();
80104ee7:	e8 d7 fe ff ff       	call   80104dc3 <sched>
  release(&ptable.lock);
80104eec:	83 ec 0c             	sub    $0xc,%esp
80104eef:	68 c0 48 11 80       	push   $0x801148c0
80104ef4:	e8 1f 06 00 00       	call   80105518 <release>
80104ef9:	83 c4 10             	add    $0x10,%esp
}
80104efc:	90                   	nop
80104efd:	c9                   	leave  
80104efe:	c3                   	ret    

80104eff <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104eff:	f3 0f 1e fb          	endbr32 
80104f03:	55                   	push   %ebp
80104f04:	89 e5                	mov    %esp,%ebp
80104f06:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104f09:	83 ec 0c             	sub    $0xc,%esp
80104f0c:	68 c0 48 11 80       	push   $0x801148c0
80104f11:	e8 02 06 00 00       	call   80105518 <release>
80104f16:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104f19:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104f1e:	85 c0                	test   %eax,%eax
80104f20:	74 24                	je     80104f46 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104f22:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104f29:	00 00 00 
    iinit(ROOTDEV);
80104f2c:	83 ec 0c             	sub    $0xc,%esp
80104f2f:	6a 01                	push   $0x1
80104f31:	e8 e8 c7 ff ff       	call   8010171e <iinit>
80104f36:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104f39:	83 ec 0c             	sub    $0xc,%esp
80104f3c:	6a 01                	push   $0x1
80104f3e:	e8 fd e4 ff ff       	call   80103440 <initlog>
80104f43:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104f46:	90                   	nop
80104f47:	c9                   	leave  
80104f48:	c3                   	ret    

80104f49 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104f49:	f3 0f 1e fb          	endbr32 
80104f4d:	55                   	push   %ebp
80104f4e:	89 e5                	mov    %esp,%ebp
80104f50:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
80104f53:	e8 d9 f4 ff ff       	call   80104431 <myproc>
80104f58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104f5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f5f:	75 0d                	jne    80104f6e <sleep+0x25>
    panic("sleep");
80104f61:	83 ec 0c             	sub    $0xc,%esp
80104f64:	68 bf 8d 10 80       	push   $0x80108dbf
80104f69:	e8 63 b6 ff ff       	call   801005d1 <panic>

  if(lk == 0)
80104f6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f72:	75 0d                	jne    80104f81 <sleep+0x38>
    panic("sleep without lk");
80104f74:	83 ec 0c             	sub    $0xc,%esp
80104f77:	68 c5 8d 10 80       	push   $0x80108dc5
80104f7c:	e8 50 b6 ff ff       	call   801005d1 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104f81:	81 7d 0c c0 48 11 80 	cmpl   $0x801148c0,0xc(%ebp)
80104f88:	74 1e                	je     80104fa8 <sleep+0x5f>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104f8a:	83 ec 0c             	sub    $0xc,%esp
80104f8d:	68 c0 48 11 80       	push   $0x801148c0
80104f92:	e8 0f 05 00 00       	call   801054a6 <acquire>
80104f97:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104f9a:	83 ec 0c             	sub    $0xc,%esp
80104f9d:	ff 75 0c             	pushl  0xc(%ebp)
80104fa0:	e8 73 05 00 00       	call   80105518 <release>
80104fa5:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fab:	8b 55 08             	mov    0x8(%ebp),%edx
80104fae:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb4:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  p->rutime += ticks - p->snapticks;
80104fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbe:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fc4:	89 c1                	mov    %eax,%ecx
80104fc6:	8b 15 40 73 11 80    	mov    0x80117340,%edx
80104fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fcf:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104fd5:	29 c2                	sub    %eax,%edx
80104fd7:	89 d0                	mov    %edx,%eax
80104fd9:	01 c8                	add    %ecx,%eax
80104fdb:	89 c2                	mov    %eax,%edx
80104fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe0:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  sched();
80104fe6:	e8 d8 fd ff ff       	call   80104dc3 <sched>

  // Tidy up.
  p->chan = 0;
80104feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fee:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ff5:	81 7d 0c c0 48 11 80 	cmpl   $0x801148c0,0xc(%ebp)
80104ffc:	74 1e                	je     8010501c <sleep+0xd3>
    release(&ptable.lock);
80104ffe:	83 ec 0c             	sub    $0xc,%esp
80105001:	68 c0 48 11 80       	push   $0x801148c0
80105006:	e8 0d 05 00 00       	call   80105518 <release>
8010500b:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010500e:	83 ec 0c             	sub    $0xc,%esp
80105011:	ff 75 0c             	pushl  0xc(%ebp)
80105014:	e8 8d 04 00 00       	call   801054a6 <acquire>
80105019:	83 c4 10             	add    $0x10,%esp
  }
}
8010501c:	90                   	nop
8010501d:	c9                   	leave  
8010501e:	c3                   	ret    

8010501f <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010501f:	f3 0f 1e fb          	endbr32 
80105023:	55                   	push   %ebp
80105024:	89 e5                	mov    %esp,%ebp
80105026:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105029:	c7 45 fc f4 48 11 80 	movl   $0x801148f4,-0x4(%ebp)
80105030:	eb 37                	jmp    80105069 <wakeup1+0x4a>
    if(p->state == SLEEPING && p->chan == chan){
80105032:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105035:	8b 40 0c             	mov    0xc(%eax),%eax
80105038:	83 f8 02             	cmp    $0x2,%eax
8010503b:	75 25                	jne    80105062 <wakeup1+0x43>
8010503d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105040:	8b 40 20             	mov    0x20(%eax),%eax
80105043:	39 45 08             	cmp    %eax,0x8(%ebp)
80105046:	75 1a                	jne    80105062 <wakeup1+0x43>
      p->state = RUNNABLE;
80105048:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010504b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      p->snapticks = ticks;
80105052:	a1 40 73 11 80       	mov    0x80117340,%eax
80105057:	89 c2                	mov    %eax,%edx
80105059:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010505c:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105062:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80105069:	81 7d fc f4 6a 11 80 	cmpl   $0x80116af4,-0x4(%ebp)
80105070:	72 c0                	jb     80105032 <wakeup1+0x13>
    }
}
80105072:	90                   	nop
80105073:	90                   	nop
80105074:	c9                   	leave  
80105075:	c3                   	ret    

80105076 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80105076:	f3 0f 1e fb          	endbr32 
8010507a:	55                   	push   %ebp
8010507b:	89 e5                	mov    %esp,%ebp
8010507d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105080:	83 ec 0c             	sub    $0xc,%esp
80105083:	68 c0 48 11 80       	push   $0x801148c0
80105088:	e8 19 04 00 00       	call   801054a6 <acquire>
8010508d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105090:	83 ec 0c             	sub    $0xc,%esp
80105093:	ff 75 08             	pushl  0x8(%ebp)
80105096:	e8 84 ff ff ff       	call   8010501f <wakeup1>
8010509b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010509e:	83 ec 0c             	sub    $0xc,%esp
801050a1:	68 c0 48 11 80       	push   $0x801148c0
801050a6:	e8 6d 04 00 00       	call   80105518 <release>
801050ab:	83 c4 10             	add    $0x10,%esp
}
801050ae:	90                   	nop
801050af:	c9                   	leave  
801050b0:	c3                   	ret    

801050b1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801050b1:	f3 0f 1e fb          	endbr32 
801050b5:	55                   	push   %ebp
801050b6:	89 e5                	mov    %esp,%ebp
801050b8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801050bb:	83 ec 0c             	sub    $0xc,%esp
801050be:	68 c0 48 11 80       	push   $0x801148c0
801050c3:	e8 de 03 00 00       	call   801054a6 <acquire>
801050c8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050cb:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
801050d2:	eb 58                	jmp    8010512c <kill+0x7b>
    if(p->pid == pid){
801050d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d7:	8b 40 10             	mov    0x10(%eax),%eax
801050da:	39 45 08             	cmp    %eax,0x8(%ebp)
801050dd:	75 46                	jne    80105125 <kill+0x74>
      p->killed = 1;
801050df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING){
801050e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ec:	8b 40 0c             	mov    0xc(%eax),%eax
801050ef:	83 f8 02             	cmp    $0x2,%eax
801050f2:	75 1a                	jne    8010510e <kill+0x5d>
        p->state = RUNNABLE;
801050f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
        p->snapticks = ticks;
801050fe:	a1 40 73 11 80       	mov    0x80117340,%eax
80105103:	89 c2                	mov    %eax,%edx
80105105:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105108:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      }
      release(&ptable.lock);
8010510e:	83 ec 0c             	sub    $0xc,%esp
80105111:	68 c0 48 11 80       	push   $0x801148c0
80105116:	e8 fd 03 00 00       	call   80105518 <release>
8010511b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010511e:	b8 00 00 00 00       	mov    $0x0,%eax
80105123:	eb 25                	jmp    8010514a <kill+0x99>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105125:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010512c:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
80105133:	72 9f                	jb     801050d4 <kill+0x23>
    }
  }
  release(&ptable.lock);
80105135:	83 ec 0c             	sub    $0xc,%esp
80105138:	68 c0 48 11 80       	push   $0x801148c0
8010513d:	e8 d6 03 00 00       	call   80105518 <release>
80105142:	83 c4 10             	add    $0x10,%esp
  return -1;
80105145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010514a:	c9                   	leave  
8010514b:	c3                   	ret    

8010514c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010514c:	f3 0f 1e fb          	endbr32 
80105150:	55                   	push   %ebp
80105151:	89 e5                	mov    %esp,%ebp
80105153:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105156:	c7 45 f0 f4 48 11 80 	movl   $0x801148f4,-0x10(%ebp)
8010515d:	e9 da 00 00 00       	jmp    8010523c <procdump+0xf0>
    if(p->state == UNUSED)
80105162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105165:	8b 40 0c             	mov    0xc(%eax),%eax
80105168:	85 c0                	test   %eax,%eax
8010516a:	0f 84 c4 00 00 00    	je     80105234 <procdump+0xe8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105170:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105173:	8b 40 0c             	mov    0xc(%eax),%eax
80105176:	83 f8 05             	cmp    $0x5,%eax
80105179:	77 23                	ja     8010519e <procdump+0x52>
8010517b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010517e:	8b 40 0c             	mov    0xc(%eax),%eax
80105181:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105188:	85 c0                	test   %eax,%eax
8010518a:	74 12                	je     8010519e <procdump+0x52>
      state = states[p->state];
8010518c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010518f:	8b 40 0c             	mov    0xc(%eax),%eax
80105192:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105199:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010519c:	eb 07                	jmp    801051a5 <procdump+0x59>
    else
      state = "???";
8010519e:	c7 45 ec d6 8d 10 80 	movl   $0x80108dd6,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801051a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a8:	8d 50 6c             	lea    0x6c(%eax),%edx
801051ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ae:	8b 40 10             	mov    0x10(%eax),%eax
801051b1:	52                   	push   %edx
801051b2:	ff 75 ec             	pushl  -0x14(%ebp)
801051b5:	50                   	push   %eax
801051b6:	68 da 8d 10 80       	push   $0x80108dda
801051bb:	e8 58 b2 ff ff       	call   80100418 <cprintf>
801051c0:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801051c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051c6:	8b 40 0c             	mov    0xc(%eax),%eax
801051c9:	83 f8 02             	cmp    $0x2,%eax
801051cc:	75 54                	jne    80105222 <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801051ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051d1:	8b 40 1c             	mov    0x1c(%eax),%eax
801051d4:	8b 40 0c             	mov    0xc(%eax),%eax
801051d7:	83 c0 08             	add    $0x8,%eax
801051da:	89 c2                	mov    %eax,%edx
801051dc:	83 ec 08             	sub    $0x8,%esp
801051df:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801051e2:	50                   	push   %eax
801051e3:	52                   	push   %edx
801051e4:	e8 85 03 00 00       	call   8010556e <getcallerpcs>
801051e9:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801051ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801051f3:	eb 1c                	jmp    80105211 <procdump+0xc5>
        cprintf(" %p", pc[i]);
801051f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f8:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801051fc:	83 ec 08             	sub    $0x8,%esp
801051ff:	50                   	push   %eax
80105200:	68 e3 8d 10 80       	push   $0x80108de3
80105205:	e8 0e b2 ff ff       	call   80100418 <cprintf>
8010520a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010520d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105211:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105215:	7f 0b                	jg     80105222 <procdump+0xd6>
80105217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521a:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010521e:	85 c0                	test   %eax,%eax
80105220:	75 d3                	jne    801051f5 <procdump+0xa9>
    }
    cprintf("\n");
80105222:	83 ec 0c             	sub    $0xc,%esp
80105225:	68 e7 8d 10 80       	push   $0x80108de7
8010522a:	e8 e9 b1 ff ff       	call   80100418 <cprintf>
8010522f:	83 c4 10             	add    $0x10,%esp
80105232:	eb 01                	jmp    80105235 <procdump+0xe9>
      continue;
80105234:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105235:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
8010523c:	81 7d f0 f4 6a 11 80 	cmpl   $0x80116af4,-0x10(%ebp)
80105243:	0f 82 19 ff ff ff    	jb     80105162 <procdump+0x16>
  }
}
80105249:	90                   	nop
8010524a:	90                   	nop
8010524b:	c9                   	leave  
8010524c:	c3                   	ret    

8010524d <updatestatistics>:


/*
  This method will run every clock tick and update the statistic fields for each proc
*/
void updatestatistics() {
8010524d:	f3 0f 1e fb          	endbr32 
80105251:	55                   	push   %ebp
80105252:	89 e5                	mov    %esp,%ebp
80105254:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105257:	83 ec 0c             	sub    $0xc,%esp
8010525a:	68 c0 48 11 80       	push   $0x801148c0
8010525f:	e8 42 02 00 00       	call   801054a6 <acquire>
80105264:	83 c4 10             	add    $0x10,%esp
  int run_cnt=0;
80105267:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010526e:	c7 45 f4 f4 48 11 80 	movl   $0x801148f4,-0xc(%ebp)
80105275:	eb 5a                	jmp    801052d1 <updatestatistics+0x84>
    
    switch(p->state) {
80105277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527a:	8b 40 0c             	mov    0xc(%eax),%eax
8010527d:	83 f8 03             	cmp    $0x3,%eax
80105280:	74 07                	je     80105289 <updatestatistics+0x3c>
80105282:	83 f8 04             	cmp    $0x4,%eax
80105285:	74 13                	je     8010529a <updatestatistics+0x4d>
80105287:	eb 41                	jmp    801052ca <updatestatistics+0x7d>
      case RUNNABLE:
        p->wtime++;
80105289:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528c:	8b 40 7c             	mov    0x7c(%eax),%eax
8010528f:	8d 50 01             	lea    0x1(%eax),%edx
80105292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105295:	89 50 7c             	mov    %edx,0x7c(%eax)
        //cprintf("wtime: proc %d\n", p->pid);
        break;
80105298:	eb 30                	jmp    801052ca <updatestatistics+0x7d>
      case RUNNING:
        if(run_cnt==1)
8010529a:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
8010529e:	75 0d                	jne    801052ad <updatestatistics+0x60>
          panic("more than 1 processes are running\n");
801052a0:	83 ec 0c             	sub    $0xc,%esp
801052a3:	68 ec 8d 10 80       	push   $0x80108dec
801052a8:	e8 24 b3 ff ff       	call   801005d1 <panic>
        run_cnt=1;
801052ad:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        p->rutime++;
801052b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052bd:	8d 50 01             	lea    0x1(%eax),%edx
801052c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c3:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
        //cprintf("rtime: proc %d\n", p->pid);
        break;
801052c9:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052ca:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801052d1:	81 7d f4 f4 6a 11 80 	cmpl   $0x80116af4,-0xc(%ebp)
801052d8:	72 9d                	jb     80105277 <updatestatistics+0x2a>
      default:
        ;
    }
  }

  release(&ptable.lock);
801052da:	83 ec 0c             	sub    $0xc,%esp
801052dd:	68 c0 48 11 80       	push   $0x801148c0
801052e2:	e8 31 02 00 00       	call   80105518 <release>
801052e7:	83 c4 10             	add    $0x10,%esp
801052ea:	90                   	nop
801052eb:	c9                   	leave  
801052ec:	c3                   	ret    

801052ed <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801052ed:	f3 0f 1e fb          	endbr32 
801052f1:	55                   	push   %ebp
801052f2:	89 e5                	mov    %esp,%ebp
801052f4:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
801052f7:	8b 45 08             	mov    0x8(%ebp),%eax
801052fa:	83 c0 04             	add    $0x4,%eax
801052fd:	83 ec 08             	sub    $0x8,%esp
80105300:	68 39 8e 10 80       	push   $0x80108e39
80105305:	50                   	push   %eax
80105306:	e8 75 01 00 00       	call   80105480 <initlock>
8010530b:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
8010530e:	8b 45 08             	mov    0x8(%ebp),%eax
80105311:	8b 55 0c             	mov    0xc(%ebp),%edx
80105314:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105317:	8b 45 08             	mov    0x8(%ebp),%eax
8010531a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105320:	8b 45 08             	mov    0x8(%ebp),%eax
80105323:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010532a:	90                   	nop
8010532b:	c9                   	leave  
8010532c:	c3                   	ret    

8010532d <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010532d:	f3 0f 1e fb          	endbr32 
80105331:	55                   	push   %ebp
80105332:	89 e5                	mov    %esp,%ebp
80105334:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80105337:	8b 45 08             	mov    0x8(%ebp),%eax
8010533a:	83 c0 04             	add    $0x4,%eax
8010533d:	83 ec 0c             	sub    $0xc,%esp
80105340:	50                   	push   %eax
80105341:	e8 60 01 00 00       	call   801054a6 <acquire>
80105346:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105349:	eb 15                	jmp    80105360 <acquiresleep+0x33>
    sleep(lk, &lk->lk);
8010534b:	8b 45 08             	mov    0x8(%ebp),%eax
8010534e:	83 c0 04             	add    $0x4,%eax
80105351:	83 ec 08             	sub    $0x8,%esp
80105354:	50                   	push   %eax
80105355:	ff 75 08             	pushl  0x8(%ebp)
80105358:	e8 ec fb ff ff       	call   80104f49 <sleep>
8010535d:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80105360:	8b 45 08             	mov    0x8(%ebp),%eax
80105363:	8b 00                	mov    (%eax),%eax
80105365:	85 c0                	test   %eax,%eax
80105367:	75 e2                	jne    8010534b <acquiresleep+0x1e>
  }
  lk->locked = 1;
80105369:	8b 45 08             	mov    0x8(%ebp),%eax
8010536c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105372:	e8 ba f0 ff ff       	call   80104431 <myproc>
80105377:	8b 50 10             	mov    0x10(%eax),%edx
8010537a:	8b 45 08             	mov    0x8(%ebp),%eax
8010537d:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
80105383:	83 c0 04             	add    $0x4,%eax
80105386:	83 ec 0c             	sub    $0xc,%esp
80105389:	50                   	push   %eax
8010538a:	e8 89 01 00 00       	call   80105518 <release>
8010538f:	83 c4 10             	add    $0x10,%esp
}
80105392:	90                   	nop
80105393:	c9                   	leave  
80105394:	c3                   	ret    

80105395 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105395:	f3 0f 1e fb          	endbr32 
80105399:	55                   	push   %ebp
8010539a:	89 e5                	mov    %esp,%ebp
8010539c:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010539f:	8b 45 08             	mov    0x8(%ebp),%eax
801053a2:	83 c0 04             	add    $0x4,%eax
801053a5:	83 ec 0c             	sub    $0xc,%esp
801053a8:	50                   	push   %eax
801053a9:	e8 f8 00 00 00       	call   801054a6 <acquire>
801053ae:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
801053b1:	8b 45 08             	mov    0x8(%ebp),%eax
801053b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801053ba:	8b 45 08             	mov    0x8(%ebp),%eax
801053bd:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801053c4:	83 ec 0c             	sub    $0xc,%esp
801053c7:	ff 75 08             	pushl  0x8(%ebp)
801053ca:	e8 a7 fc ff ff       	call   80105076 <wakeup>
801053cf:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
801053d2:	8b 45 08             	mov    0x8(%ebp),%eax
801053d5:	83 c0 04             	add    $0x4,%eax
801053d8:	83 ec 0c             	sub    $0xc,%esp
801053db:	50                   	push   %eax
801053dc:	e8 37 01 00 00       	call   80105518 <release>
801053e1:	83 c4 10             	add    $0x10,%esp
}
801053e4:	90                   	nop
801053e5:	c9                   	leave  
801053e6:	c3                   	ret    

801053e7 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801053e7:	f3 0f 1e fb          	endbr32 
801053eb:	55                   	push   %ebp
801053ec:	89 e5                	mov    %esp,%ebp
801053ee:	53                   	push   %ebx
801053ef:	83 ec 14             	sub    $0x14,%esp
  int r;
  
  acquire(&lk->lk);
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	83 c0 04             	add    $0x4,%eax
801053f8:	83 ec 0c             	sub    $0xc,%esp
801053fb:	50                   	push   %eax
801053fc:	e8 a5 00 00 00       	call   801054a6 <acquire>
80105401:	83 c4 10             	add    $0x10,%esp
  r = lk->locked && (lk->pid == myproc()->pid);
80105404:	8b 45 08             	mov    0x8(%ebp),%eax
80105407:	8b 00                	mov    (%eax),%eax
80105409:	85 c0                	test   %eax,%eax
8010540b:	74 19                	je     80105426 <holdingsleep+0x3f>
8010540d:	8b 45 08             	mov    0x8(%ebp),%eax
80105410:	8b 58 3c             	mov    0x3c(%eax),%ebx
80105413:	e8 19 f0 ff ff       	call   80104431 <myproc>
80105418:	8b 40 10             	mov    0x10(%eax),%eax
8010541b:	39 c3                	cmp    %eax,%ebx
8010541d:	75 07                	jne    80105426 <holdingsleep+0x3f>
8010541f:	b8 01 00 00 00       	mov    $0x1,%eax
80105424:	eb 05                	jmp    8010542b <holdingsleep+0x44>
80105426:	b8 00 00 00 00       	mov    $0x0,%eax
8010542b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010542e:	8b 45 08             	mov    0x8(%ebp),%eax
80105431:	83 c0 04             	add    $0x4,%eax
80105434:	83 ec 0c             	sub    $0xc,%esp
80105437:	50                   	push   %eax
80105438:	e8 db 00 00 00       	call   80105518 <release>
8010543d:	83 c4 10             	add    $0x10,%esp
  return r;
80105440:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105443:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105446:	c9                   	leave  
80105447:	c3                   	ret    

80105448 <readeflags>:
{
80105448:	55                   	push   %ebp
80105449:	89 e5                	mov    %esp,%ebp
8010544b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010544e:	9c                   	pushf  
8010544f:	58                   	pop    %eax
80105450:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105453:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105456:	c9                   	leave  
80105457:	c3                   	ret    

80105458 <cli>:
{
80105458:	55                   	push   %ebp
80105459:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010545b:	fa                   	cli    
}
8010545c:	90                   	nop
8010545d:	5d                   	pop    %ebp
8010545e:	c3                   	ret    

8010545f <sti>:
{
8010545f:	55                   	push   %ebp
80105460:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105462:	fb                   	sti    
}
80105463:	90                   	nop
80105464:	5d                   	pop    %ebp
80105465:	c3                   	ret    

80105466 <xchg>:
{
80105466:	55                   	push   %ebp
80105467:	89 e5                	mov    %esp,%ebp
80105469:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010546c:	8b 55 08             	mov    0x8(%ebp),%edx
8010546f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105472:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105475:	f0 87 02             	lock xchg %eax,(%edx)
80105478:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010547b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010547e:	c9                   	leave  
8010547f:	c3                   	ret    

80105480 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105480:	f3 0f 1e fb          	endbr32 
80105484:	55                   	push   %ebp
80105485:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105487:	8b 45 08             	mov    0x8(%ebp),%eax
8010548a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010548d:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105490:	8b 45 08             	mov    0x8(%ebp),%eax
80105493:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105499:	8b 45 08             	mov    0x8(%ebp),%eax
8010549c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801054a3:	90                   	nop
801054a4:	5d                   	pop    %ebp
801054a5:	c3                   	ret    

801054a6 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801054a6:	f3 0f 1e fb          	endbr32 
801054aa:	55                   	push   %ebp
801054ab:	89 e5                	mov    %esp,%ebp
801054ad:	53                   	push   %ebx
801054ae:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801054b1:	e8 7c 01 00 00       	call   80105632 <pushcli>
  if(holding(lk))
801054b6:	8b 45 08             	mov    0x8(%ebp),%eax
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	50                   	push   %eax
801054bd:	e8 2b 01 00 00       	call   801055ed <holding>
801054c2:	83 c4 10             	add    $0x10,%esp
801054c5:	85 c0                	test   %eax,%eax
801054c7:	74 0d                	je     801054d6 <acquire+0x30>
    panic("acquire");
801054c9:	83 ec 0c             	sub    $0xc,%esp
801054cc:	68 44 8e 10 80       	push   $0x80108e44
801054d1:	e8 fb b0 ff ff       	call   801005d1 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801054d6:	90                   	nop
801054d7:	8b 45 08             	mov    0x8(%ebp),%eax
801054da:	83 ec 08             	sub    $0x8,%esp
801054dd:	6a 01                	push   $0x1
801054df:	50                   	push   %eax
801054e0:	e8 81 ff ff ff       	call   80105466 <xchg>
801054e5:	83 c4 10             	add    $0x10,%esp
801054e8:	85 c0                	test   %eax,%eax
801054ea:	75 eb                	jne    801054d7 <acquire+0x31>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801054ec:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801054f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
801054f4:	e8 bc ee ff ff       	call   801043b5 <mycpu>
801054f9:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801054fc:	8b 45 08             	mov    0x8(%ebp),%eax
801054ff:	83 c0 0c             	add    $0xc,%eax
80105502:	83 ec 08             	sub    $0x8,%esp
80105505:	50                   	push   %eax
80105506:	8d 45 08             	lea    0x8(%ebp),%eax
80105509:	50                   	push   %eax
8010550a:	e8 5f 00 00 00       	call   8010556e <getcallerpcs>
8010550f:	83 c4 10             	add    $0x10,%esp
}
80105512:	90                   	nop
80105513:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105516:	c9                   	leave  
80105517:	c3                   	ret    

80105518 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105518:	f3 0f 1e fb          	endbr32 
8010551c:	55                   	push   %ebp
8010551d:	89 e5                	mov    %esp,%ebp
8010551f:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105522:	83 ec 0c             	sub    $0xc,%esp
80105525:	ff 75 08             	pushl  0x8(%ebp)
80105528:	e8 c0 00 00 00       	call   801055ed <holding>
8010552d:	83 c4 10             	add    $0x10,%esp
80105530:	85 c0                	test   %eax,%eax
80105532:	75 0d                	jne    80105541 <release+0x29>
    panic("release");
80105534:	83 ec 0c             	sub    $0xc,%esp
80105537:	68 4c 8e 10 80       	push   $0x80108e4c
8010553c:	e8 90 b0 ff ff       	call   801005d1 <panic>

  lk->pcs[0] = 0;
80105541:	8b 45 08             	mov    0x8(%ebp),%eax
80105544:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010554b:	8b 45 08             	mov    0x8(%ebp),%eax
8010554e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105555:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010555a:	8b 45 08             	mov    0x8(%ebp),%eax
8010555d:	8b 55 08             	mov    0x8(%ebp),%edx
80105560:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105566:	e8 18 01 00 00       	call   80105683 <popcli>
}
8010556b:	90                   	nop
8010556c:	c9                   	leave  
8010556d:	c3                   	ret    

8010556e <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010556e:	f3 0f 1e fb          	endbr32 
80105572:	55                   	push   %ebp
80105573:	89 e5                	mov    %esp,%ebp
80105575:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105578:	8b 45 08             	mov    0x8(%ebp),%eax
8010557b:	83 e8 08             	sub    $0x8,%eax
8010557e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105581:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105588:	eb 38                	jmp    801055c2 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010558a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010558e:	74 53                	je     801055e3 <getcallerpcs+0x75>
80105590:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105597:	76 4a                	jbe    801055e3 <getcallerpcs+0x75>
80105599:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010559d:	74 44                	je     801055e3 <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010559f:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ac:	01 c2                	add    %eax,%edx
801055ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b1:	8b 40 04             	mov    0x4(%eax),%eax
801055b4:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801055b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b9:	8b 00                	mov    (%eax),%eax
801055bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801055be:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801055c2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055c6:	7e c2                	jle    8010558a <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
801055c8:	eb 19                	jmp    801055e3 <getcallerpcs+0x75>
    pcs[i] = 0;
801055ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d7:	01 d0                	add    %edx,%eax
801055d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801055df:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801055e3:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055e7:	7e e1                	jle    801055ca <getcallerpcs+0x5c>
}
801055e9:	90                   	nop
801055ea:	90                   	nop
801055eb:	c9                   	leave  
801055ec:	c3                   	ret    

801055ed <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801055ed:	f3 0f 1e fb          	endbr32 
801055f1:	55                   	push   %ebp
801055f2:	89 e5                	mov    %esp,%ebp
801055f4:	53                   	push   %ebx
801055f5:	83 ec 14             	sub    $0x14,%esp
  int r;
  pushcli();
801055f8:	e8 35 00 00 00       	call   80105632 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801055fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105600:	8b 00                	mov    (%eax),%eax
80105602:	85 c0                	test   %eax,%eax
80105604:	74 16                	je     8010561c <holding+0x2f>
80105606:	8b 45 08             	mov    0x8(%ebp),%eax
80105609:	8b 58 08             	mov    0x8(%eax),%ebx
8010560c:	e8 a4 ed ff ff       	call   801043b5 <mycpu>
80105611:	39 c3                	cmp    %eax,%ebx
80105613:	75 07                	jne    8010561c <holding+0x2f>
80105615:	b8 01 00 00 00       	mov    $0x1,%eax
8010561a:	eb 05                	jmp    80105621 <holding+0x34>
8010561c:	b8 00 00 00 00       	mov    $0x0,%eax
80105621:	89 45 f4             	mov    %eax,-0xc(%ebp)
  popcli();
80105624:	e8 5a 00 00 00       	call   80105683 <popcli>
  return r;
80105629:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010562c:	83 c4 14             	add    $0x14,%esp
8010562f:	5b                   	pop    %ebx
80105630:	5d                   	pop    %ebp
80105631:	c3                   	ret    

80105632 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105632:	f3 0f 1e fb          	endbr32 
80105636:	55                   	push   %ebp
80105637:	89 e5                	mov    %esp,%ebp
80105639:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010563c:	e8 07 fe ff ff       	call   80105448 <readeflags>
80105641:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105644:	e8 0f fe ff ff       	call   80105458 <cli>
  if(mycpu()->ncli == 0)
80105649:	e8 67 ed ff ff       	call   801043b5 <mycpu>
8010564e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105654:	85 c0                	test   %eax,%eax
80105656:	75 14                	jne    8010566c <pushcli+0x3a>
    mycpu()->intena = eflags & FL_IF;
80105658:	e8 58 ed ff ff       	call   801043b5 <mycpu>
8010565d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105660:	81 e2 00 02 00 00    	and    $0x200,%edx
80105666:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
8010566c:	e8 44 ed ff ff       	call   801043b5 <mycpu>
80105671:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105677:	83 c2 01             	add    $0x1,%edx
8010567a:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105680:	90                   	nop
80105681:	c9                   	leave  
80105682:	c3                   	ret    

80105683 <popcli>:

void
popcli(void)
{
80105683:	f3 0f 1e fb          	endbr32 
80105687:	55                   	push   %ebp
80105688:	89 e5                	mov    %esp,%ebp
8010568a:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010568d:	e8 b6 fd ff ff       	call   80105448 <readeflags>
80105692:	25 00 02 00 00       	and    $0x200,%eax
80105697:	85 c0                	test   %eax,%eax
80105699:	74 0d                	je     801056a8 <popcli+0x25>
    panic("popcli - interruptible");
8010569b:	83 ec 0c             	sub    $0xc,%esp
8010569e:	68 54 8e 10 80       	push   $0x80108e54
801056a3:	e8 29 af ff ff       	call   801005d1 <panic>
  if(--mycpu()->ncli < 0)
801056a8:	e8 08 ed ff ff       	call   801043b5 <mycpu>
801056ad:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801056b3:	83 ea 01             	sub    $0x1,%edx
801056b6:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801056bc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056c2:	85 c0                	test   %eax,%eax
801056c4:	79 0d                	jns    801056d3 <popcli+0x50>
    panic("popcli");
801056c6:	83 ec 0c             	sub    $0xc,%esp
801056c9:	68 6b 8e 10 80       	push   $0x80108e6b
801056ce:	e8 fe ae ff ff       	call   801005d1 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801056d3:	e8 dd ec ff ff       	call   801043b5 <mycpu>
801056d8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801056de:	85 c0                	test   %eax,%eax
801056e0:	75 14                	jne    801056f6 <popcli+0x73>
801056e2:	e8 ce ec ff ff       	call   801043b5 <mycpu>
801056e7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801056ed:	85 c0                	test   %eax,%eax
801056ef:	74 05                	je     801056f6 <popcli+0x73>
    sti();
801056f1:	e8 69 fd ff ff       	call   8010545f <sti>
}
801056f6:	90                   	nop
801056f7:	c9                   	leave  
801056f8:	c3                   	ret    

801056f9 <stosb>:
{
801056f9:	55                   	push   %ebp
801056fa:	89 e5                	mov    %esp,%ebp
801056fc:	57                   	push   %edi
801056fd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801056fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105701:	8b 55 10             	mov    0x10(%ebp),%edx
80105704:	8b 45 0c             	mov    0xc(%ebp),%eax
80105707:	89 cb                	mov    %ecx,%ebx
80105709:	89 df                	mov    %ebx,%edi
8010570b:	89 d1                	mov    %edx,%ecx
8010570d:	fc                   	cld    
8010570e:	f3 aa                	rep stos %al,%es:(%edi)
80105710:	89 ca                	mov    %ecx,%edx
80105712:	89 fb                	mov    %edi,%ebx
80105714:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105717:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010571a:	90                   	nop
8010571b:	5b                   	pop    %ebx
8010571c:	5f                   	pop    %edi
8010571d:	5d                   	pop    %ebp
8010571e:	c3                   	ret    

8010571f <stosl>:
{
8010571f:	55                   	push   %ebp
80105720:	89 e5                	mov    %esp,%ebp
80105722:	57                   	push   %edi
80105723:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105724:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105727:	8b 55 10             	mov    0x10(%ebp),%edx
8010572a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010572d:	89 cb                	mov    %ecx,%ebx
8010572f:	89 df                	mov    %ebx,%edi
80105731:	89 d1                	mov    %edx,%ecx
80105733:	fc                   	cld    
80105734:	f3 ab                	rep stos %eax,%es:(%edi)
80105736:	89 ca                	mov    %ecx,%edx
80105738:	89 fb                	mov    %edi,%ebx
8010573a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010573d:	89 55 10             	mov    %edx,0x10(%ebp)
}
80105740:	90                   	nop
80105741:	5b                   	pop    %ebx
80105742:	5f                   	pop    %edi
80105743:	5d                   	pop    %ebp
80105744:	c3                   	ret    

80105745 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105745:	f3 0f 1e fb          	endbr32 
80105749:	55                   	push   %ebp
8010574a:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010574c:	8b 45 08             	mov    0x8(%ebp),%eax
8010574f:	83 e0 03             	and    $0x3,%eax
80105752:	85 c0                	test   %eax,%eax
80105754:	75 43                	jne    80105799 <memset+0x54>
80105756:	8b 45 10             	mov    0x10(%ebp),%eax
80105759:	83 e0 03             	and    $0x3,%eax
8010575c:	85 c0                	test   %eax,%eax
8010575e:	75 39                	jne    80105799 <memset+0x54>
    c &= 0xFF;
80105760:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105767:	8b 45 10             	mov    0x10(%ebp),%eax
8010576a:	c1 e8 02             	shr    $0x2,%eax
8010576d:	89 c1                	mov    %eax,%ecx
8010576f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105772:	c1 e0 18             	shl    $0x18,%eax
80105775:	89 c2                	mov    %eax,%edx
80105777:	8b 45 0c             	mov    0xc(%ebp),%eax
8010577a:	c1 e0 10             	shl    $0x10,%eax
8010577d:	09 c2                	or     %eax,%edx
8010577f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105782:	c1 e0 08             	shl    $0x8,%eax
80105785:	09 d0                	or     %edx,%eax
80105787:	0b 45 0c             	or     0xc(%ebp),%eax
8010578a:	51                   	push   %ecx
8010578b:	50                   	push   %eax
8010578c:	ff 75 08             	pushl  0x8(%ebp)
8010578f:	e8 8b ff ff ff       	call   8010571f <stosl>
80105794:	83 c4 0c             	add    $0xc,%esp
80105797:	eb 12                	jmp    801057ab <memset+0x66>
  } else
    stosb(dst, c, n);
80105799:	8b 45 10             	mov    0x10(%ebp),%eax
8010579c:	50                   	push   %eax
8010579d:	ff 75 0c             	pushl  0xc(%ebp)
801057a0:	ff 75 08             	pushl  0x8(%ebp)
801057a3:	e8 51 ff ff ff       	call   801056f9 <stosb>
801057a8:	83 c4 0c             	add    $0xc,%esp
  return dst;
801057ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
801057ae:	c9                   	leave  
801057af:	c3                   	ret    

801057b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801057b0:	f3 0f 1e fb          	endbr32 
801057b4:	55                   	push   %ebp
801057b5:	89 e5                	mov    %esp,%ebp
801057b7:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801057ba:	8b 45 08             	mov    0x8(%ebp),%eax
801057bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801057c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801057c3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801057c6:	eb 30                	jmp    801057f8 <memcmp+0x48>
    if(*s1 != *s2)
801057c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057cb:	0f b6 10             	movzbl (%eax),%edx
801057ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057d1:	0f b6 00             	movzbl (%eax),%eax
801057d4:	38 c2                	cmp    %al,%dl
801057d6:	74 18                	je     801057f0 <memcmp+0x40>
      return *s1 - *s2;
801057d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057db:	0f b6 00             	movzbl (%eax),%eax
801057de:	0f b6 d0             	movzbl %al,%edx
801057e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057e4:	0f b6 00             	movzbl (%eax),%eax
801057e7:	0f b6 c0             	movzbl %al,%eax
801057ea:	29 c2                	sub    %eax,%edx
801057ec:	89 d0                	mov    %edx,%eax
801057ee:	eb 1a                	jmp    8010580a <memcmp+0x5a>
    s1++, s2++;
801057f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057f4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
801057f8:	8b 45 10             	mov    0x10(%ebp),%eax
801057fb:	8d 50 ff             	lea    -0x1(%eax),%edx
801057fe:	89 55 10             	mov    %edx,0x10(%ebp)
80105801:	85 c0                	test   %eax,%eax
80105803:	75 c3                	jne    801057c8 <memcmp+0x18>
  }

  return 0;
80105805:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010580a:	c9                   	leave  
8010580b:	c3                   	ret    

8010580c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010580c:	f3 0f 1e fb          	endbr32 
80105810:	55                   	push   %ebp
80105811:	89 e5                	mov    %esp,%ebp
80105813:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105816:	8b 45 0c             	mov    0xc(%ebp),%eax
80105819:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010581c:	8b 45 08             	mov    0x8(%ebp),%eax
8010581f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105822:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105825:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105828:	73 54                	jae    8010587e <memmove+0x72>
8010582a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010582d:	8b 45 10             	mov    0x10(%ebp),%eax
80105830:	01 d0                	add    %edx,%eax
80105832:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80105835:	73 47                	jae    8010587e <memmove+0x72>
    s += n;
80105837:	8b 45 10             	mov    0x10(%ebp),%eax
8010583a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010583d:	8b 45 10             	mov    0x10(%ebp),%eax
80105840:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105843:	eb 13                	jmp    80105858 <memmove+0x4c>
      *--d = *--s;
80105845:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105849:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010584d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105850:	0f b6 10             	movzbl (%eax),%edx
80105853:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105856:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105858:	8b 45 10             	mov    0x10(%ebp),%eax
8010585b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010585e:	89 55 10             	mov    %edx,0x10(%ebp)
80105861:	85 c0                	test   %eax,%eax
80105863:	75 e0                	jne    80105845 <memmove+0x39>
  if(s < d && s + n > d){
80105865:	eb 24                	jmp    8010588b <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105867:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010586a:	8d 42 01             	lea    0x1(%edx),%eax
8010586d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105870:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105873:	8d 48 01             	lea    0x1(%eax),%ecx
80105876:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105879:	0f b6 12             	movzbl (%edx),%edx
8010587c:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
8010587e:	8b 45 10             	mov    0x10(%ebp),%eax
80105881:	8d 50 ff             	lea    -0x1(%eax),%edx
80105884:	89 55 10             	mov    %edx,0x10(%ebp)
80105887:	85 c0                	test   %eax,%eax
80105889:	75 dc                	jne    80105867 <memmove+0x5b>

  return dst;
8010588b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010588e:	c9                   	leave  
8010588f:	c3                   	ret    

80105890 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105890:	f3 0f 1e fb          	endbr32 
80105894:	55                   	push   %ebp
80105895:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105897:	ff 75 10             	pushl  0x10(%ebp)
8010589a:	ff 75 0c             	pushl  0xc(%ebp)
8010589d:	ff 75 08             	pushl  0x8(%ebp)
801058a0:	e8 67 ff ff ff       	call   8010580c <memmove>
801058a5:	83 c4 0c             	add    $0xc,%esp
}
801058a8:	c9                   	leave  
801058a9:	c3                   	ret    

801058aa <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801058aa:	f3 0f 1e fb          	endbr32 
801058ae:	55                   	push   %ebp
801058af:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801058b1:	eb 0c                	jmp    801058bf <strncmp+0x15>
    n--, p++, q++;
801058b3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801058b7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801058bb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
801058bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058c3:	74 1a                	je     801058df <strncmp+0x35>
801058c5:	8b 45 08             	mov    0x8(%ebp),%eax
801058c8:	0f b6 00             	movzbl (%eax),%eax
801058cb:	84 c0                	test   %al,%al
801058cd:	74 10                	je     801058df <strncmp+0x35>
801058cf:	8b 45 08             	mov    0x8(%ebp),%eax
801058d2:	0f b6 10             	movzbl (%eax),%edx
801058d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d8:	0f b6 00             	movzbl (%eax),%eax
801058db:	38 c2                	cmp    %al,%dl
801058dd:	74 d4                	je     801058b3 <strncmp+0x9>
  if(n == 0)
801058df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058e3:	75 07                	jne    801058ec <strncmp+0x42>
    return 0;
801058e5:	b8 00 00 00 00       	mov    $0x0,%eax
801058ea:	eb 16                	jmp    80105902 <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
801058ec:	8b 45 08             	mov    0x8(%ebp),%eax
801058ef:	0f b6 00             	movzbl (%eax),%eax
801058f2:	0f b6 d0             	movzbl %al,%edx
801058f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f8:	0f b6 00             	movzbl (%eax),%eax
801058fb:	0f b6 c0             	movzbl %al,%eax
801058fe:	29 c2                	sub    %eax,%edx
80105900:	89 d0                	mov    %edx,%eax
}
80105902:	5d                   	pop    %ebp
80105903:	c3                   	ret    

80105904 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105904:	f3 0f 1e fb          	endbr32 
80105908:	55                   	push   %ebp
80105909:	89 e5                	mov    %esp,%ebp
8010590b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010590e:	8b 45 08             	mov    0x8(%ebp),%eax
80105911:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105914:	90                   	nop
80105915:	8b 45 10             	mov    0x10(%ebp),%eax
80105918:	8d 50 ff             	lea    -0x1(%eax),%edx
8010591b:	89 55 10             	mov    %edx,0x10(%ebp)
8010591e:	85 c0                	test   %eax,%eax
80105920:	7e 2c                	jle    8010594e <strncpy+0x4a>
80105922:	8b 55 0c             	mov    0xc(%ebp),%edx
80105925:	8d 42 01             	lea    0x1(%edx),%eax
80105928:	89 45 0c             	mov    %eax,0xc(%ebp)
8010592b:	8b 45 08             	mov    0x8(%ebp),%eax
8010592e:	8d 48 01             	lea    0x1(%eax),%ecx
80105931:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105934:	0f b6 12             	movzbl (%edx),%edx
80105937:	88 10                	mov    %dl,(%eax)
80105939:	0f b6 00             	movzbl (%eax),%eax
8010593c:	84 c0                	test   %al,%al
8010593e:	75 d5                	jne    80105915 <strncpy+0x11>
    ;
  while(n-- > 0)
80105940:	eb 0c                	jmp    8010594e <strncpy+0x4a>
    *s++ = 0;
80105942:	8b 45 08             	mov    0x8(%ebp),%eax
80105945:	8d 50 01             	lea    0x1(%eax),%edx
80105948:	89 55 08             	mov    %edx,0x8(%ebp)
8010594b:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010594e:	8b 45 10             	mov    0x10(%ebp),%eax
80105951:	8d 50 ff             	lea    -0x1(%eax),%edx
80105954:	89 55 10             	mov    %edx,0x10(%ebp)
80105957:	85 c0                	test   %eax,%eax
80105959:	7f e7                	jg     80105942 <strncpy+0x3e>
  return os;
8010595b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010595e:	c9                   	leave  
8010595f:	c3                   	ret    

80105960 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105960:	f3 0f 1e fb          	endbr32 
80105964:	55                   	push   %ebp
80105965:	89 e5                	mov    %esp,%ebp
80105967:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010596a:	8b 45 08             	mov    0x8(%ebp),%eax
8010596d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105970:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105974:	7f 05                	jg     8010597b <safestrcpy+0x1b>
    return os;
80105976:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105979:	eb 31                	jmp    801059ac <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010597b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010597f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105983:	7e 1e                	jle    801059a3 <safestrcpy+0x43>
80105985:	8b 55 0c             	mov    0xc(%ebp),%edx
80105988:	8d 42 01             	lea    0x1(%edx),%eax
8010598b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010598e:	8b 45 08             	mov    0x8(%ebp),%eax
80105991:	8d 48 01             	lea    0x1(%eax),%ecx
80105994:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105997:	0f b6 12             	movzbl (%edx),%edx
8010599a:	88 10                	mov    %dl,(%eax)
8010599c:	0f b6 00             	movzbl (%eax),%eax
8010599f:	84 c0                	test   %al,%al
801059a1:	75 d8                	jne    8010597b <safestrcpy+0x1b>
    ;
  *s = 0;
801059a3:	8b 45 08             	mov    0x8(%ebp),%eax
801059a6:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801059a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059ac:	c9                   	leave  
801059ad:	c3                   	ret    

801059ae <strlen>:

int
strlen(const char *s)
{
801059ae:	f3 0f 1e fb          	endbr32 
801059b2:	55                   	push   %ebp
801059b3:	89 e5                	mov    %esp,%ebp
801059b5:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801059b8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801059bf:	eb 04                	jmp    801059c5 <strlen+0x17>
801059c1:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801059c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059c8:	8b 45 08             	mov    0x8(%ebp),%eax
801059cb:	01 d0                	add    %edx,%eax
801059cd:	0f b6 00             	movzbl (%eax),%eax
801059d0:	84 c0                	test   %al,%al
801059d2:	75 ed                	jne    801059c1 <strlen+0x13>
    ;
  return n;
801059d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801059d7:	c9                   	leave  
801059d8:	c3                   	ret    

801059d9 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801059d9:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801059dd:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801059e1:	55                   	push   %ebp
  pushl %ebx
801059e2:	53                   	push   %ebx
  pushl %esi
801059e3:	56                   	push   %esi
  pushl %edi
801059e4:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801059e5:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801059e7:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801059e9:	5f                   	pop    %edi
  popl %esi
801059ea:	5e                   	pop    %esi
  popl %ebx
801059eb:	5b                   	pop    %ebx
  popl %ebp
801059ec:	5d                   	pop    %ebp
  ret
801059ed:	c3                   	ret    

801059ee <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801059ee:	f3 0f 1e fb          	endbr32 
801059f2:	55                   	push   %ebp
801059f3:	89 e5                	mov    %esp,%ebp
801059f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
801059f8:	e8 34 ea ff ff       	call   80104431 <myproc>
801059fd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a03:	8b 00                	mov    (%eax),%eax
80105a05:	39 45 08             	cmp    %eax,0x8(%ebp)
80105a08:	73 0f                	jae    80105a19 <fetchint+0x2b>
80105a0a:	8b 45 08             	mov    0x8(%ebp),%eax
80105a0d:	8d 50 04             	lea    0x4(%eax),%edx
80105a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a13:	8b 00                	mov    (%eax),%eax
80105a15:	39 c2                	cmp    %eax,%edx
80105a17:	76 07                	jbe    80105a20 <fetchint+0x32>
    return -1;
80105a19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a1e:	eb 0f                	jmp    80105a2f <fetchint+0x41>
  *ip = *(int*)(addr);
80105a20:	8b 45 08             	mov    0x8(%ebp),%eax
80105a23:	8b 10                	mov    (%eax),%edx
80105a25:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a28:	89 10                	mov    %edx,(%eax)
  return 0;
80105a2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a2f:	c9                   	leave  
80105a30:	c3                   	ret    

80105a31 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105a31:	f3 0f 1e fb          	endbr32 
80105a35:	55                   	push   %ebp
80105a36:	89 e5                	mov    %esp,%ebp
80105a38:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105a3b:	e8 f1 e9 ff ff       	call   80104431 <myproc>
80105a40:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a46:	8b 00                	mov    (%eax),%eax
80105a48:	39 45 08             	cmp    %eax,0x8(%ebp)
80105a4b:	72 07                	jb     80105a54 <fetchstr+0x23>
    return -1;
80105a4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a52:	eb 43                	jmp    80105a97 <fetchstr+0x66>
  *pp = (char*)addr;
80105a54:	8b 55 08             	mov    0x8(%ebp),%edx
80105a57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a5a:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5f:	8b 00                	mov    (%eax),%eax
80105a61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105a64:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a67:	8b 00                	mov    (%eax),%eax
80105a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a6c:	eb 1c                	jmp    80105a8a <fetchstr+0x59>
    if(*s == 0)
80105a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a71:	0f b6 00             	movzbl (%eax),%eax
80105a74:	84 c0                	test   %al,%al
80105a76:	75 0e                	jne    80105a86 <fetchstr+0x55>
      return s - *pp;
80105a78:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a7b:	8b 00                	mov    (%eax),%eax
80105a7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a80:	29 c2                	sub    %eax,%edx
80105a82:	89 d0                	mov    %edx,%eax
80105a84:	eb 11                	jmp    80105a97 <fetchstr+0x66>
  for(s = *pp; s < ep; s++){
80105a86:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105a90:	72 dc                	jb     80105a6e <fetchstr+0x3d>
  }
  return -1;
80105a92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a97:	c9                   	leave  
80105a98:	c3                   	ret    

80105a99 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105a99:	f3 0f 1e fb          	endbr32 
80105a9d:	55                   	push   %ebp
80105a9e:	89 e5                	mov    %esp,%ebp
80105aa0:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105aa3:	e8 89 e9 ff ff       	call   80104431 <myproc>
80105aa8:	8b 40 18             	mov    0x18(%eax),%eax
80105aab:	8b 40 44             	mov    0x44(%eax),%eax
80105aae:	8b 55 08             	mov    0x8(%ebp),%edx
80105ab1:	c1 e2 02             	shl    $0x2,%edx
80105ab4:	01 d0                	add    %edx,%eax
80105ab6:	83 c0 04             	add    $0x4,%eax
80105ab9:	83 ec 08             	sub    $0x8,%esp
80105abc:	ff 75 0c             	pushl  0xc(%ebp)
80105abf:	50                   	push   %eax
80105ac0:	e8 29 ff ff ff       	call   801059ee <fetchint>
80105ac5:	83 c4 10             	add    $0x10,%esp
}
80105ac8:	c9                   	leave  
80105ac9:	c3                   	ret    

80105aca <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105aca:	f3 0f 1e fb          	endbr32 
80105ace:	55                   	push   %ebp
80105acf:	89 e5                	mov    %esp,%ebp
80105ad1:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80105ad4:	e8 58 e9 ff ff       	call   80104431 <myproc>
80105ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105adc:	83 ec 08             	sub    $0x8,%esp
80105adf:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ae2:	50                   	push   %eax
80105ae3:	ff 75 08             	pushl  0x8(%ebp)
80105ae6:	e8 ae ff ff ff       	call   80105a99 <argint>
80105aeb:	83 c4 10             	add    $0x10,%esp
80105aee:	85 c0                	test   %eax,%eax
80105af0:	79 07                	jns    80105af9 <argptr+0x2f>
    return -1;
80105af2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af7:	eb 3b                	jmp    80105b34 <argptr+0x6a>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105af9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105afd:	78 1f                	js     80105b1e <argptr+0x54>
80105aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b02:	8b 00                	mov    (%eax),%eax
80105b04:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b07:	39 d0                	cmp    %edx,%eax
80105b09:	76 13                	jbe    80105b1e <argptr+0x54>
80105b0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0e:	89 c2                	mov    %eax,%edx
80105b10:	8b 45 10             	mov    0x10(%ebp),%eax
80105b13:	01 c2                	add    %eax,%edx
80105b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b18:	8b 00                	mov    (%eax),%eax
80105b1a:	39 c2                	cmp    %eax,%edx
80105b1c:	76 07                	jbe    80105b25 <argptr+0x5b>
    return -1;
80105b1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b23:	eb 0f                	jmp    80105b34 <argptr+0x6a>
  *pp = (char*)i;
80105b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b28:	89 c2                	mov    %eax,%edx
80105b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b2d:	89 10                	mov    %edx,(%eax)
  return 0;
80105b2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b34:	c9                   	leave  
80105b35:	c3                   	ret    

80105b36 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105b36:	f3 0f 1e fb          	endbr32 
80105b3a:	55                   	push   %ebp
80105b3b:	89 e5                	mov    %esp,%ebp
80105b3d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105b40:	83 ec 08             	sub    $0x8,%esp
80105b43:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b46:	50                   	push   %eax
80105b47:	ff 75 08             	pushl  0x8(%ebp)
80105b4a:	e8 4a ff ff ff       	call   80105a99 <argint>
80105b4f:	83 c4 10             	add    $0x10,%esp
80105b52:	85 c0                	test   %eax,%eax
80105b54:	79 07                	jns    80105b5d <argstr+0x27>
    return -1;
80105b56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5b:	eb 12                	jmp    80105b6f <argstr+0x39>
  return fetchstr(addr, pp);
80105b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b60:	83 ec 08             	sub    $0x8,%esp
80105b63:	ff 75 0c             	pushl  0xc(%ebp)
80105b66:	50                   	push   %eax
80105b67:	e8 c5 fe ff ff       	call   80105a31 <fetchstr>
80105b6c:	83 c4 10             	add    $0x10,%esp
}
80105b6f:	c9                   	leave  
80105b70:	c3                   	ret    

80105b71 <syscall>:
[SYS_wait2]   sys_wait2,
};

void
syscall(void)
{
80105b71:	f3 0f 1e fb          	endbr32 
80105b75:	55                   	push   %ebp
80105b76:	89 e5                	mov    %esp,%ebp
80105b78:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80105b7b:	e8 b1 e8 ff ff       	call   80104431 <myproc>
80105b80:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b86:	8b 40 18             	mov    0x18(%eax),%eax
80105b89:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105b8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b93:	7e 2f                	jle    80105bc4 <syscall+0x53>
80105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b98:	83 f8 16             	cmp    $0x16,%eax
80105b9b:	77 27                	ja     80105bc4 <syscall+0x53>
80105b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba0:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105ba7:	85 c0                	test   %eax,%eax
80105ba9:	74 19                	je     80105bc4 <syscall+0x53>
    curproc->tf->eax = syscalls[num]();
80105bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bae:	8b 04 85 20 c0 10 80 	mov    -0x7fef3fe0(,%eax,4),%eax
80105bb5:	ff d0                	call   *%eax
80105bb7:	89 c2                	mov    %eax,%edx
80105bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bbc:	8b 40 18             	mov    0x18(%eax),%eax
80105bbf:	89 50 1c             	mov    %edx,0x1c(%eax)
80105bc2:	eb 2c                	jmp    80105bf0 <syscall+0x7f>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80105bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcd:	8b 40 10             	mov    0x10(%eax),%eax
80105bd0:	ff 75 f0             	pushl  -0x10(%ebp)
80105bd3:	52                   	push   %edx
80105bd4:	50                   	push   %eax
80105bd5:	68 72 8e 10 80       	push   $0x80108e72
80105bda:	e8 39 a8 ff ff       	call   80100418 <cprintf>
80105bdf:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80105be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be5:	8b 40 18             	mov    0x18(%eax),%eax
80105be8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105bef:	90                   	nop
80105bf0:	90                   	nop
80105bf1:	c9                   	leave  
80105bf2:	c3                   	ret    

80105bf3 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105bf3:	f3 0f 1e fb          	endbr32 
80105bf7:	55                   	push   %ebp
80105bf8:	89 e5                	mov    %esp,%ebp
80105bfa:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105bfd:	83 ec 08             	sub    $0x8,%esp
80105c00:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c03:	50                   	push   %eax
80105c04:	ff 75 08             	pushl  0x8(%ebp)
80105c07:	e8 8d fe ff ff       	call   80105a99 <argint>
80105c0c:	83 c4 10             	add    $0x10,%esp
80105c0f:	85 c0                	test   %eax,%eax
80105c11:	79 07                	jns    80105c1a <argfd+0x27>
    return -1;
80105c13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c18:	eb 4f                	jmp    80105c69 <argfd+0x76>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1d:	85 c0                	test   %eax,%eax
80105c1f:	78 20                	js     80105c41 <argfd+0x4e>
80105c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c24:	83 f8 0f             	cmp    $0xf,%eax
80105c27:	7f 18                	jg     80105c41 <argfd+0x4e>
80105c29:	e8 03 e8 ff ff       	call   80104431 <myproc>
80105c2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c31:	83 c2 08             	add    $0x8,%edx
80105c34:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c3f:	75 07                	jne    80105c48 <argfd+0x55>
    return -1;
80105c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c46:	eb 21                	jmp    80105c69 <argfd+0x76>
  if(pfd)
80105c48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105c4c:	74 08                	je     80105c56 <argfd+0x63>
    *pfd = fd;
80105c4e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c51:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c54:	89 10                	mov    %edx,(%eax)
  if(pf)
80105c56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c5a:	74 08                	je     80105c64 <argfd+0x71>
    *pf = f;
80105c5c:	8b 45 10             	mov    0x10(%ebp),%eax
80105c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c62:	89 10                	mov    %edx,(%eax)
  return 0;
80105c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c69:	c9                   	leave  
80105c6a:	c3                   	ret    

80105c6b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c6b:	f3 0f 1e fb          	endbr32 
80105c6f:	55                   	push   %ebp
80105c70:	89 e5                	mov    %esp,%ebp
80105c72:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105c75:	e8 b7 e7 ff ff       	call   80104431 <myproc>
80105c7a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105c7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c84:	eb 2a                	jmp    80105cb0 <fdalloc+0x45>
    if(curproc->ofile[fd] == 0){
80105c86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c8c:	83 c2 08             	add    $0x8,%edx
80105c8f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c93:	85 c0                	test   %eax,%eax
80105c95:	75 15                	jne    80105cac <fdalloc+0x41>
      curproc->ofile[fd] = f;
80105c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c9d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ca0:	8b 55 08             	mov    0x8(%ebp),%edx
80105ca3:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caa:	eb 0f                	jmp    80105cbb <fdalloc+0x50>
  for(fd = 0; fd < NOFILE; fd++){
80105cac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105cb0:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105cb4:	7e d0                	jle    80105c86 <fdalloc+0x1b>
    }
  }
  return -1;
80105cb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cbb:	c9                   	leave  
80105cbc:	c3                   	ret    

80105cbd <sys_dup>:

int
sys_dup(void)
{
80105cbd:	f3 0f 1e fb          	endbr32 
80105cc1:	55                   	push   %ebp
80105cc2:	89 e5                	mov    %esp,%ebp
80105cc4:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105cc7:	83 ec 04             	sub    $0x4,%esp
80105cca:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ccd:	50                   	push   %eax
80105cce:	6a 00                	push   $0x0
80105cd0:	6a 00                	push   $0x0
80105cd2:	e8 1c ff ff ff       	call   80105bf3 <argfd>
80105cd7:	83 c4 10             	add    $0x10,%esp
80105cda:	85 c0                	test   %eax,%eax
80105cdc:	79 07                	jns    80105ce5 <sys_dup+0x28>
    return -1;
80105cde:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce3:	eb 31                	jmp    80105d16 <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80105ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce8:	83 ec 0c             	sub    $0xc,%esp
80105ceb:	50                   	push   %eax
80105cec:	e8 7a ff ff ff       	call   80105c6b <fdalloc>
80105cf1:	83 c4 10             	add    $0x10,%esp
80105cf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cfb:	79 07                	jns    80105d04 <sys_dup+0x47>
    return -1;
80105cfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d02:	eb 12                	jmp    80105d16 <sys_dup+0x59>
  filedup(f);
80105d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d07:	83 ec 0c             	sub    $0xc,%esp
80105d0a:	50                   	push   %eax
80105d0b:	e8 bf b3 ff ff       	call   801010cf <filedup>
80105d10:	83 c4 10             	add    $0x10,%esp
  return fd;
80105d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d16:	c9                   	leave  
80105d17:	c3                   	ret    

80105d18 <sys_read>:

int
sys_read(void)
{
80105d18:	f3 0f 1e fb          	endbr32 
80105d1c:	55                   	push   %ebp
80105d1d:	89 e5                	mov    %esp,%ebp
80105d1f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d22:	83 ec 04             	sub    $0x4,%esp
80105d25:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d28:	50                   	push   %eax
80105d29:	6a 00                	push   $0x0
80105d2b:	6a 00                	push   $0x0
80105d2d:	e8 c1 fe ff ff       	call   80105bf3 <argfd>
80105d32:	83 c4 10             	add    $0x10,%esp
80105d35:	85 c0                	test   %eax,%eax
80105d37:	78 2e                	js     80105d67 <sys_read+0x4f>
80105d39:	83 ec 08             	sub    $0x8,%esp
80105d3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d3f:	50                   	push   %eax
80105d40:	6a 02                	push   $0x2
80105d42:	e8 52 fd ff ff       	call   80105a99 <argint>
80105d47:	83 c4 10             	add    $0x10,%esp
80105d4a:	85 c0                	test   %eax,%eax
80105d4c:	78 19                	js     80105d67 <sys_read+0x4f>
80105d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d51:	83 ec 04             	sub    $0x4,%esp
80105d54:	50                   	push   %eax
80105d55:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d58:	50                   	push   %eax
80105d59:	6a 01                	push   $0x1
80105d5b:	e8 6a fd ff ff       	call   80105aca <argptr>
80105d60:	83 c4 10             	add    $0x10,%esp
80105d63:	85 c0                	test   %eax,%eax
80105d65:	79 07                	jns    80105d6e <sys_read+0x56>
    return -1;
80105d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6c:	eb 17                	jmp    80105d85 <sys_read+0x6d>
  return fileread(f, p, n);
80105d6e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d71:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d77:	83 ec 04             	sub    $0x4,%esp
80105d7a:	51                   	push   %ecx
80105d7b:	52                   	push   %edx
80105d7c:	50                   	push   %eax
80105d7d:	e8 e9 b4 ff ff       	call   8010126b <fileread>
80105d82:	83 c4 10             	add    $0x10,%esp
}
80105d85:	c9                   	leave  
80105d86:	c3                   	ret    

80105d87 <sys_write>:

int
sys_write(void)
{
80105d87:	f3 0f 1e fb          	endbr32 
80105d8b:	55                   	push   %ebp
80105d8c:	89 e5                	mov    %esp,%ebp
80105d8e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d91:	83 ec 04             	sub    $0x4,%esp
80105d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d97:	50                   	push   %eax
80105d98:	6a 00                	push   $0x0
80105d9a:	6a 00                	push   $0x0
80105d9c:	e8 52 fe ff ff       	call   80105bf3 <argfd>
80105da1:	83 c4 10             	add    $0x10,%esp
80105da4:	85 c0                	test   %eax,%eax
80105da6:	78 2e                	js     80105dd6 <sys_write+0x4f>
80105da8:	83 ec 08             	sub    $0x8,%esp
80105dab:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dae:	50                   	push   %eax
80105daf:	6a 02                	push   $0x2
80105db1:	e8 e3 fc ff ff       	call   80105a99 <argint>
80105db6:	83 c4 10             	add    $0x10,%esp
80105db9:	85 c0                	test   %eax,%eax
80105dbb:	78 19                	js     80105dd6 <sys_write+0x4f>
80105dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc0:	83 ec 04             	sub    $0x4,%esp
80105dc3:	50                   	push   %eax
80105dc4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dc7:	50                   	push   %eax
80105dc8:	6a 01                	push   $0x1
80105dca:	e8 fb fc ff ff       	call   80105aca <argptr>
80105dcf:	83 c4 10             	add    $0x10,%esp
80105dd2:	85 c0                	test   %eax,%eax
80105dd4:	79 07                	jns    80105ddd <sys_write+0x56>
    return -1;
80105dd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddb:	eb 17                	jmp    80105df4 <sys_write+0x6d>
  return filewrite(f, p, n);
80105ddd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105de0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de6:	83 ec 04             	sub    $0x4,%esp
80105de9:	51                   	push   %ecx
80105dea:	52                   	push   %edx
80105deb:	50                   	push   %eax
80105dec:	e8 36 b5 ff ff       	call   80101327 <filewrite>
80105df1:	83 c4 10             	add    $0x10,%esp
}
80105df4:	c9                   	leave  
80105df5:	c3                   	ret    

80105df6 <sys_close>:

int
sys_close(void)
{
80105df6:	f3 0f 1e fb          	endbr32 
80105dfa:	55                   	push   %ebp
80105dfb:	89 e5                	mov    %esp,%ebp
80105dfd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105e00:	83 ec 04             	sub    $0x4,%esp
80105e03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e06:	50                   	push   %eax
80105e07:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e0a:	50                   	push   %eax
80105e0b:	6a 00                	push   $0x0
80105e0d:	e8 e1 fd ff ff       	call   80105bf3 <argfd>
80105e12:	83 c4 10             	add    $0x10,%esp
80105e15:	85 c0                	test   %eax,%eax
80105e17:	79 07                	jns    80105e20 <sys_close+0x2a>
    return -1;
80105e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e1e:	eb 27                	jmp    80105e47 <sys_close+0x51>
  myproc()->ofile[fd] = 0;
80105e20:	e8 0c e6 ff ff       	call   80104431 <myproc>
80105e25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e28:	83 c2 08             	add    $0x8,%edx
80105e2b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105e32:	00 
  fileclose(f);
80105e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e36:	83 ec 0c             	sub    $0xc,%esp
80105e39:	50                   	push   %eax
80105e3a:	e8 e5 b2 ff ff       	call   80101124 <fileclose>
80105e3f:	83 c4 10             	add    $0x10,%esp
  return 0;
80105e42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e47:	c9                   	leave  
80105e48:	c3                   	ret    

80105e49 <sys_fstat>:

int
sys_fstat(void)
{
80105e49:	f3 0f 1e fb          	endbr32 
80105e4d:	55                   	push   %ebp
80105e4e:	89 e5                	mov    %esp,%ebp
80105e50:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105e53:	83 ec 04             	sub    $0x4,%esp
80105e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e59:	50                   	push   %eax
80105e5a:	6a 00                	push   $0x0
80105e5c:	6a 00                	push   $0x0
80105e5e:	e8 90 fd ff ff       	call   80105bf3 <argfd>
80105e63:	83 c4 10             	add    $0x10,%esp
80105e66:	85 c0                	test   %eax,%eax
80105e68:	78 17                	js     80105e81 <sys_fstat+0x38>
80105e6a:	83 ec 04             	sub    $0x4,%esp
80105e6d:	6a 14                	push   $0x14
80105e6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e72:	50                   	push   %eax
80105e73:	6a 01                	push   $0x1
80105e75:	e8 50 fc ff ff       	call   80105aca <argptr>
80105e7a:	83 c4 10             	add    $0x10,%esp
80105e7d:	85 c0                	test   %eax,%eax
80105e7f:	79 07                	jns    80105e88 <sys_fstat+0x3f>
    return -1;
80105e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e86:	eb 13                	jmp    80105e9b <sys_fstat+0x52>
  return filestat(f, st);
80105e88:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8e:	83 ec 08             	sub    $0x8,%esp
80105e91:	52                   	push   %edx
80105e92:	50                   	push   %eax
80105e93:	e8 78 b3 ff ff       	call   80101210 <filestat>
80105e98:	83 c4 10             	add    $0x10,%esp
}
80105e9b:	c9                   	leave  
80105e9c:	c3                   	ret    

80105e9d <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105e9d:	f3 0f 1e fb          	endbr32 
80105ea1:	55                   	push   %ebp
80105ea2:	89 e5                	mov    %esp,%ebp
80105ea4:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105ea7:	83 ec 08             	sub    $0x8,%esp
80105eaa:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105ead:	50                   	push   %eax
80105eae:	6a 00                	push   $0x0
80105eb0:	e8 81 fc ff ff       	call   80105b36 <argstr>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	85 c0                	test   %eax,%eax
80105eba:	78 15                	js     80105ed1 <sys_link+0x34>
80105ebc:	83 ec 08             	sub    $0x8,%esp
80105ebf:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105ec2:	50                   	push   %eax
80105ec3:	6a 01                	push   $0x1
80105ec5:	e8 6c fc ff ff       	call   80105b36 <argstr>
80105eca:	83 c4 10             	add    $0x10,%esp
80105ecd:	85 c0                	test   %eax,%eax
80105ecf:	79 0a                	jns    80105edb <sys_link+0x3e>
    return -1;
80105ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed6:	e9 68 01 00 00       	jmp    80106043 <sys_link+0x1a6>

  begin_op();
80105edb:	e8 93 d7 ff ff       	call   80103673 <begin_op>
  if((ip = namei(old)) == 0){
80105ee0:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105ee3:	83 ec 0c             	sub    $0xc,%esp
80105ee6:	50                   	push   %eax
80105ee7:	e8 23 c7 ff ff       	call   8010260f <namei>
80105eec:	83 c4 10             	add    $0x10,%esp
80105eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ef2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ef6:	75 0f                	jne    80105f07 <sys_link+0x6a>
    end_op();
80105ef8:	e8 06 d8 ff ff       	call   80103703 <end_op>
    return -1;
80105efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f02:	e9 3c 01 00 00       	jmp    80106043 <sys_link+0x1a6>
  }

  ilock(ip);
80105f07:	83 ec 0c             	sub    $0xc,%esp
80105f0a:	ff 75 f4             	pushl  -0xc(%ebp)
80105f0d:	e8 92 bb ff ff       	call   80101aa4 <ilock>
80105f12:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f18:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105f1c:	66 83 f8 01          	cmp    $0x1,%ax
80105f20:	75 1d                	jne    80105f3f <sys_link+0xa2>
    iunlockput(ip);
80105f22:	83 ec 0c             	sub    $0xc,%esp
80105f25:	ff 75 f4             	pushl  -0xc(%ebp)
80105f28:	e8 b4 bd ff ff       	call   80101ce1 <iunlockput>
80105f2d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105f30:	e8 ce d7 ff ff       	call   80103703 <end_op>
    return -1;
80105f35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3a:	e9 04 01 00 00       	jmp    80106043 <sys_link+0x1a6>
  }

  ip->nlink++;
80105f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f42:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105f46:	83 c0 01             	add    $0x1,%eax
80105f49:	89 c2                	mov    %eax,%edx
80105f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4e:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105f52:	83 ec 0c             	sub    $0xc,%esp
80105f55:	ff 75 f4             	pushl  -0xc(%ebp)
80105f58:	e8 5e b9 ff ff       	call   801018bb <iupdate>
80105f5d:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105f60:	83 ec 0c             	sub    $0xc,%esp
80105f63:	ff 75 f4             	pushl  -0xc(%ebp)
80105f66:	e8 50 bc ff ff       	call   80101bbb <iunlock>
80105f6b:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105f6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105f71:	83 ec 08             	sub    $0x8,%esp
80105f74:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105f77:	52                   	push   %edx
80105f78:	50                   	push   %eax
80105f79:	e8 b1 c6 ff ff       	call   8010262f <nameiparent>
80105f7e:	83 c4 10             	add    $0x10,%esp
80105f81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f88:	74 71                	je     80105ffb <sys_link+0x15e>
    goto bad;
  ilock(dp);
80105f8a:	83 ec 0c             	sub    $0xc,%esp
80105f8d:	ff 75 f0             	pushl  -0x10(%ebp)
80105f90:	e8 0f bb ff ff       	call   80101aa4 <ilock>
80105f95:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105f98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f9b:	8b 10                	mov    (%eax),%edx
80105f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa0:	8b 00                	mov    (%eax),%eax
80105fa2:	39 c2                	cmp    %eax,%edx
80105fa4:	75 1d                	jne    80105fc3 <sys_link+0x126>
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	8b 40 04             	mov    0x4(%eax),%eax
80105fac:	83 ec 04             	sub    $0x4,%esp
80105faf:	50                   	push   %eax
80105fb0:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105fb3:	50                   	push   %eax
80105fb4:	ff 75 f0             	pushl  -0x10(%ebp)
80105fb7:	e8 b0 c3 ff ff       	call   8010236c <dirlink>
80105fbc:	83 c4 10             	add    $0x10,%esp
80105fbf:	85 c0                	test   %eax,%eax
80105fc1:	79 10                	jns    80105fd3 <sys_link+0x136>
    iunlockput(dp);
80105fc3:	83 ec 0c             	sub    $0xc,%esp
80105fc6:	ff 75 f0             	pushl  -0x10(%ebp)
80105fc9:	e8 13 bd ff ff       	call   80101ce1 <iunlockput>
80105fce:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105fd1:	eb 29                	jmp    80105ffc <sys_link+0x15f>
  }
  iunlockput(dp);
80105fd3:	83 ec 0c             	sub    $0xc,%esp
80105fd6:	ff 75 f0             	pushl  -0x10(%ebp)
80105fd9:	e8 03 bd ff ff       	call   80101ce1 <iunlockput>
80105fde:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105fe1:	83 ec 0c             	sub    $0xc,%esp
80105fe4:	ff 75 f4             	pushl  -0xc(%ebp)
80105fe7:	e8 21 bc ff ff       	call   80101c0d <iput>
80105fec:	83 c4 10             	add    $0x10,%esp

  end_op();
80105fef:	e8 0f d7 ff ff       	call   80103703 <end_op>

  return 0;
80105ff4:	b8 00 00 00 00       	mov    $0x0,%eax
80105ff9:	eb 48                	jmp    80106043 <sys_link+0x1a6>
    goto bad;
80105ffb:	90                   	nop

bad:
  ilock(ip);
80105ffc:	83 ec 0c             	sub    $0xc,%esp
80105fff:	ff 75 f4             	pushl  -0xc(%ebp)
80106002:	e8 9d ba ff ff       	call   80101aa4 <ilock>
80106007:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010600a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600d:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106011:	83 e8 01             	sub    $0x1,%eax
80106014:	89 c2                	mov    %eax,%edx
80106016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106019:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010601d:	83 ec 0c             	sub    $0xc,%esp
80106020:	ff 75 f4             	pushl  -0xc(%ebp)
80106023:	e8 93 b8 ff ff       	call   801018bb <iupdate>
80106028:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010602b:	83 ec 0c             	sub    $0xc,%esp
8010602e:	ff 75 f4             	pushl  -0xc(%ebp)
80106031:	e8 ab bc ff ff       	call   80101ce1 <iunlockput>
80106036:	83 c4 10             	add    $0x10,%esp
  end_op();
80106039:	e8 c5 d6 ff ff       	call   80103703 <end_op>
  return -1;
8010603e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106043:	c9                   	leave  
80106044:	c3                   	ret    

80106045 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106045:	f3 0f 1e fb          	endbr32 
80106049:	55                   	push   %ebp
8010604a:	89 e5                	mov    %esp,%ebp
8010604c:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010604f:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106056:	eb 40                	jmp    80106098 <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106058:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010605b:	6a 10                	push   $0x10
8010605d:	50                   	push   %eax
8010605e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106061:	50                   	push   %eax
80106062:	ff 75 08             	pushl  0x8(%ebp)
80106065:	e8 42 bf ff ff       	call   80101fac <readi>
8010606a:	83 c4 10             	add    $0x10,%esp
8010606d:	83 f8 10             	cmp    $0x10,%eax
80106070:	74 0d                	je     8010607f <isdirempty+0x3a>
      panic("isdirempty: readi");
80106072:	83 ec 0c             	sub    $0xc,%esp
80106075:	68 8e 8e 10 80       	push   $0x80108e8e
8010607a:	e8 52 a5 ff ff       	call   801005d1 <panic>
    if(de.inum != 0)
8010607f:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80106083:	66 85 c0             	test   %ax,%ax
80106086:	74 07                	je     8010608f <isdirempty+0x4a>
      return 0;
80106088:	b8 00 00 00 00       	mov    $0x0,%eax
8010608d:	eb 1b                	jmp    801060aa <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010608f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106092:	83 c0 10             	add    $0x10,%eax
80106095:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106098:	8b 45 08             	mov    0x8(%ebp),%eax
8010609b:	8b 50 58             	mov    0x58(%eax),%edx
8010609e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a1:	39 c2                	cmp    %eax,%edx
801060a3:	77 b3                	ja     80106058 <isdirempty+0x13>
  }
  return 1;
801060a5:	b8 01 00 00 00       	mov    $0x1,%eax
}
801060aa:	c9                   	leave  
801060ab:	c3                   	ret    

801060ac <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801060ac:	f3 0f 1e fb          	endbr32 
801060b0:	55                   	push   %ebp
801060b1:	89 e5                	mov    %esp,%ebp
801060b3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801060b6:	83 ec 08             	sub    $0x8,%esp
801060b9:	8d 45 cc             	lea    -0x34(%ebp),%eax
801060bc:	50                   	push   %eax
801060bd:	6a 00                	push   $0x0
801060bf:	e8 72 fa ff ff       	call   80105b36 <argstr>
801060c4:	83 c4 10             	add    $0x10,%esp
801060c7:	85 c0                	test   %eax,%eax
801060c9:	79 0a                	jns    801060d5 <sys_unlink+0x29>
    return -1;
801060cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d0:	e9 bf 01 00 00       	jmp    80106294 <sys_unlink+0x1e8>

  begin_op();
801060d5:	e8 99 d5 ff ff       	call   80103673 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801060da:	8b 45 cc             	mov    -0x34(%ebp),%eax
801060dd:	83 ec 08             	sub    $0x8,%esp
801060e0:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801060e3:	52                   	push   %edx
801060e4:	50                   	push   %eax
801060e5:	e8 45 c5 ff ff       	call   8010262f <nameiparent>
801060ea:	83 c4 10             	add    $0x10,%esp
801060ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060f4:	75 0f                	jne    80106105 <sys_unlink+0x59>
    end_op();
801060f6:	e8 08 d6 ff ff       	call   80103703 <end_op>
    return -1;
801060fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106100:	e9 8f 01 00 00       	jmp    80106294 <sys_unlink+0x1e8>
  }

  ilock(dp);
80106105:	83 ec 0c             	sub    $0xc,%esp
80106108:	ff 75 f4             	pushl  -0xc(%ebp)
8010610b:	e8 94 b9 ff ff       	call   80101aa4 <ilock>
80106110:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106113:	83 ec 08             	sub    $0x8,%esp
80106116:	68 a0 8e 10 80       	push   $0x80108ea0
8010611b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010611e:	50                   	push   %eax
8010611f:	e8 6b c1 ff ff       	call   8010228f <namecmp>
80106124:	83 c4 10             	add    $0x10,%esp
80106127:	85 c0                	test   %eax,%eax
80106129:	0f 84 49 01 00 00    	je     80106278 <sys_unlink+0x1cc>
8010612f:	83 ec 08             	sub    $0x8,%esp
80106132:	68 a2 8e 10 80       	push   $0x80108ea2
80106137:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010613a:	50                   	push   %eax
8010613b:	e8 4f c1 ff ff       	call   8010228f <namecmp>
80106140:	83 c4 10             	add    $0x10,%esp
80106143:	85 c0                	test   %eax,%eax
80106145:	0f 84 2d 01 00 00    	je     80106278 <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010614b:	83 ec 04             	sub    $0x4,%esp
8010614e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106151:	50                   	push   %eax
80106152:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106155:	50                   	push   %eax
80106156:	ff 75 f4             	pushl  -0xc(%ebp)
80106159:	e8 50 c1 ff ff       	call   801022ae <dirlookup>
8010615e:	83 c4 10             	add    $0x10,%esp
80106161:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106164:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106168:	0f 84 0d 01 00 00    	je     8010627b <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
8010616e:	83 ec 0c             	sub    $0xc,%esp
80106171:	ff 75 f0             	pushl  -0x10(%ebp)
80106174:	e8 2b b9 ff ff       	call   80101aa4 <ilock>
80106179:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010617c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106183:	66 85 c0             	test   %ax,%ax
80106186:	7f 0d                	jg     80106195 <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80106188:	83 ec 0c             	sub    $0xc,%esp
8010618b:	68 a5 8e 10 80       	push   $0x80108ea5
80106190:	e8 3c a4 ff ff       	call   801005d1 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106195:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106198:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010619c:	66 83 f8 01          	cmp    $0x1,%ax
801061a0:	75 25                	jne    801061c7 <sys_unlink+0x11b>
801061a2:	83 ec 0c             	sub    $0xc,%esp
801061a5:	ff 75 f0             	pushl  -0x10(%ebp)
801061a8:	e8 98 fe ff ff       	call   80106045 <isdirempty>
801061ad:	83 c4 10             	add    $0x10,%esp
801061b0:	85 c0                	test   %eax,%eax
801061b2:	75 13                	jne    801061c7 <sys_unlink+0x11b>
    iunlockput(ip);
801061b4:	83 ec 0c             	sub    $0xc,%esp
801061b7:	ff 75 f0             	pushl  -0x10(%ebp)
801061ba:	e8 22 bb ff ff       	call   80101ce1 <iunlockput>
801061bf:	83 c4 10             	add    $0x10,%esp
    goto bad;
801061c2:	e9 b5 00 00 00       	jmp    8010627c <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
801061c7:	83 ec 04             	sub    $0x4,%esp
801061ca:	6a 10                	push   $0x10
801061cc:	6a 00                	push   $0x0
801061ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061d1:	50                   	push   %eax
801061d2:	e8 6e f5 ff ff       	call   80105745 <memset>
801061d7:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801061da:	8b 45 c8             	mov    -0x38(%ebp),%eax
801061dd:	6a 10                	push   $0x10
801061df:	50                   	push   %eax
801061e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801061e3:	50                   	push   %eax
801061e4:	ff 75 f4             	pushl  -0xc(%ebp)
801061e7:	e8 19 bf ff ff       	call   80102105 <writei>
801061ec:	83 c4 10             	add    $0x10,%esp
801061ef:	83 f8 10             	cmp    $0x10,%eax
801061f2:	74 0d                	je     80106201 <sys_unlink+0x155>
    panic("unlink: writei");
801061f4:	83 ec 0c             	sub    $0xc,%esp
801061f7:	68 b7 8e 10 80       	push   $0x80108eb7
801061fc:	e8 d0 a3 ff ff       	call   801005d1 <panic>
  if(ip->type == T_DIR){
80106201:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106204:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80106208:	66 83 f8 01          	cmp    $0x1,%ax
8010620c:	75 21                	jne    8010622f <sys_unlink+0x183>
    dp->nlink--;
8010620e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106211:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106215:	83 e8 01             	sub    $0x1,%eax
80106218:	89 c2                	mov    %eax,%edx
8010621a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621d:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80106221:	83 ec 0c             	sub    $0xc,%esp
80106224:	ff 75 f4             	pushl  -0xc(%ebp)
80106227:	e8 8f b6 ff ff       	call   801018bb <iupdate>
8010622c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010622f:	83 ec 0c             	sub    $0xc,%esp
80106232:	ff 75 f4             	pushl  -0xc(%ebp)
80106235:	e8 a7 ba ff ff       	call   80101ce1 <iunlockput>
8010623a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010623d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106240:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80106244:	83 e8 01             	sub    $0x1,%eax
80106247:	89 c2                	mov    %eax,%edx
80106249:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80106250:	83 ec 0c             	sub    $0xc,%esp
80106253:	ff 75 f0             	pushl  -0x10(%ebp)
80106256:	e8 60 b6 ff ff       	call   801018bb <iupdate>
8010625b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010625e:	83 ec 0c             	sub    $0xc,%esp
80106261:	ff 75 f0             	pushl  -0x10(%ebp)
80106264:	e8 78 ba ff ff       	call   80101ce1 <iunlockput>
80106269:	83 c4 10             	add    $0x10,%esp

  end_op();
8010626c:	e8 92 d4 ff ff       	call   80103703 <end_op>

  return 0;
80106271:	b8 00 00 00 00       	mov    $0x0,%eax
80106276:	eb 1c                	jmp    80106294 <sys_unlink+0x1e8>
    goto bad;
80106278:	90                   	nop
80106279:	eb 01                	jmp    8010627c <sys_unlink+0x1d0>
    goto bad;
8010627b:	90                   	nop

bad:
  iunlockput(dp);
8010627c:	83 ec 0c             	sub    $0xc,%esp
8010627f:	ff 75 f4             	pushl  -0xc(%ebp)
80106282:	e8 5a ba ff ff       	call   80101ce1 <iunlockput>
80106287:	83 c4 10             	add    $0x10,%esp
  end_op();
8010628a:	e8 74 d4 ff ff       	call   80103703 <end_op>
  return -1;
8010628f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106294:	c9                   	leave  
80106295:	c3                   	ret    

80106296 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106296:	f3 0f 1e fb          	endbr32 
8010629a:	55                   	push   %ebp
8010629b:	89 e5                	mov    %esp,%ebp
8010629d:	83 ec 38             	sub    $0x38,%esp
801062a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801062a3:	8b 55 10             	mov    0x10(%ebp),%edx
801062a6:	8b 45 14             	mov    0x14(%ebp),%eax
801062a9:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801062ad:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801062b1:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801062b5:	83 ec 08             	sub    $0x8,%esp
801062b8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801062bb:	50                   	push   %eax
801062bc:	ff 75 08             	pushl  0x8(%ebp)
801062bf:	e8 6b c3 ff ff       	call   8010262f <nameiparent>
801062c4:	83 c4 10             	add    $0x10,%esp
801062c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062ce:	75 0a                	jne    801062da <create+0x44>
    return 0;
801062d0:	b8 00 00 00 00       	mov    $0x0,%eax
801062d5:	e9 8e 01 00 00       	jmp    80106468 <create+0x1d2>
  ilock(dp);
801062da:	83 ec 0c             	sub    $0xc,%esp
801062dd:	ff 75 f4             	pushl  -0xc(%ebp)
801062e0:	e8 bf b7 ff ff       	call   80101aa4 <ilock>
801062e5:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, 0)) != 0){
801062e8:	83 ec 04             	sub    $0x4,%esp
801062eb:	6a 00                	push   $0x0
801062ed:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801062f0:	50                   	push   %eax
801062f1:	ff 75 f4             	pushl  -0xc(%ebp)
801062f4:	e8 b5 bf ff ff       	call   801022ae <dirlookup>
801062f9:	83 c4 10             	add    $0x10,%esp
801062fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106303:	74 50                	je     80106355 <create+0xbf>
    iunlockput(dp);
80106305:	83 ec 0c             	sub    $0xc,%esp
80106308:	ff 75 f4             	pushl  -0xc(%ebp)
8010630b:	e8 d1 b9 ff ff       	call   80101ce1 <iunlockput>
80106310:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106313:	83 ec 0c             	sub    $0xc,%esp
80106316:	ff 75 f0             	pushl  -0x10(%ebp)
80106319:	e8 86 b7 ff ff       	call   80101aa4 <ilock>
8010631e:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106321:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106326:	75 15                	jne    8010633d <create+0xa7>
80106328:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010632f:	66 83 f8 02          	cmp    $0x2,%ax
80106333:	75 08                	jne    8010633d <create+0xa7>
      return ip;
80106335:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106338:	e9 2b 01 00 00       	jmp    80106468 <create+0x1d2>
    iunlockput(ip);
8010633d:	83 ec 0c             	sub    $0xc,%esp
80106340:	ff 75 f0             	pushl  -0x10(%ebp)
80106343:	e8 99 b9 ff ff       	call   80101ce1 <iunlockput>
80106348:	83 c4 10             	add    $0x10,%esp
    return 0;
8010634b:	b8 00 00 00 00       	mov    $0x0,%eax
80106350:	e9 13 01 00 00       	jmp    80106468 <create+0x1d2>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106355:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635c:	8b 00                	mov    (%eax),%eax
8010635e:	83 ec 08             	sub    $0x8,%esp
80106361:	52                   	push   %edx
80106362:	50                   	push   %eax
80106363:	e8 78 b4 ff ff       	call   801017e0 <ialloc>
80106368:	83 c4 10             	add    $0x10,%esp
8010636b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010636e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106372:	75 0d                	jne    80106381 <create+0xeb>
    panic("create: ialloc");
80106374:	83 ec 0c             	sub    $0xc,%esp
80106377:	68 c6 8e 10 80       	push   $0x80108ec6
8010637c:	e8 50 a2 ff ff       	call   801005d1 <panic>

  ilock(ip);
80106381:	83 ec 0c             	sub    $0xc,%esp
80106384:	ff 75 f0             	pushl  -0x10(%ebp)
80106387:	e8 18 b7 ff ff       	call   80101aa4 <ilock>
8010638c:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010638f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106392:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106396:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010639a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639d:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801063a1:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
801063a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a8:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801063ae:	83 ec 0c             	sub    $0xc,%esp
801063b1:	ff 75 f0             	pushl  -0x10(%ebp)
801063b4:	e8 02 b5 ff ff       	call   801018bb <iupdate>
801063b9:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801063bc:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801063c1:	75 6a                	jne    8010642d <create+0x197>
    dp->nlink++;  // for ".."
801063c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c6:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801063ca:	83 c0 01             	add    $0x1,%eax
801063cd:	89 c2                	mov    %eax,%edx
801063cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d2:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801063d6:	83 ec 0c             	sub    $0xc,%esp
801063d9:	ff 75 f4             	pushl  -0xc(%ebp)
801063dc:	e8 da b4 ff ff       	call   801018bb <iupdate>
801063e1:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801063e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e7:	8b 40 04             	mov    0x4(%eax),%eax
801063ea:	83 ec 04             	sub    $0x4,%esp
801063ed:	50                   	push   %eax
801063ee:	68 a0 8e 10 80       	push   $0x80108ea0
801063f3:	ff 75 f0             	pushl  -0x10(%ebp)
801063f6:	e8 71 bf ff ff       	call   8010236c <dirlink>
801063fb:	83 c4 10             	add    $0x10,%esp
801063fe:	85 c0                	test   %eax,%eax
80106400:	78 1e                	js     80106420 <create+0x18a>
80106402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106405:	8b 40 04             	mov    0x4(%eax),%eax
80106408:	83 ec 04             	sub    $0x4,%esp
8010640b:	50                   	push   %eax
8010640c:	68 a2 8e 10 80       	push   $0x80108ea2
80106411:	ff 75 f0             	pushl  -0x10(%ebp)
80106414:	e8 53 bf ff ff       	call   8010236c <dirlink>
80106419:	83 c4 10             	add    $0x10,%esp
8010641c:	85 c0                	test   %eax,%eax
8010641e:	79 0d                	jns    8010642d <create+0x197>
      panic("create dots");
80106420:	83 ec 0c             	sub    $0xc,%esp
80106423:	68 d5 8e 10 80       	push   $0x80108ed5
80106428:	e8 a4 a1 ff ff       	call   801005d1 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010642d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106430:	8b 40 04             	mov    0x4(%eax),%eax
80106433:	83 ec 04             	sub    $0x4,%esp
80106436:	50                   	push   %eax
80106437:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010643a:	50                   	push   %eax
8010643b:	ff 75 f4             	pushl  -0xc(%ebp)
8010643e:	e8 29 bf ff ff       	call   8010236c <dirlink>
80106443:	83 c4 10             	add    $0x10,%esp
80106446:	85 c0                	test   %eax,%eax
80106448:	79 0d                	jns    80106457 <create+0x1c1>
    panic("create: dirlink");
8010644a:	83 ec 0c             	sub    $0xc,%esp
8010644d:	68 e1 8e 10 80       	push   $0x80108ee1
80106452:	e8 7a a1 ff ff       	call   801005d1 <panic>

  iunlockput(dp);
80106457:	83 ec 0c             	sub    $0xc,%esp
8010645a:	ff 75 f4             	pushl  -0xc(%ebp)
8010645d:	e8 7f b8 ff ff       	call   80101ce1 <iunlockput>
80106462:	83 c4 10             	add    $0x10,%esp

  return ip;
80106465:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106468:	c9                   	leave  
80106469:	c3                   	ret    

8010646a <sys_open>:

int
sys_open(void)
{
8010646a:	f3 0f 1e fb          	endbr32 
8010646e:	55                   	push   %ebp
8010646f:	89 e5                	mov    %esp,%ebp
80106471:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106474:	83 ec 08             	sub    $0x8,%esp
80106477:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010647a:	50                   	push   %eax
8010647b:	6a 00                	push   $0x0
8010647d:	e8 b4 f6 ff ff       	call   80105b36 <argstr>
80106482:	83 c4 10             	add    $0x10,%esp
80106485:	85 c0                	test   %eax,%eax
80106487:	78 15                	js     8010649e <sys_open+0x34>
80106489:	83 ec 08             	sub    $0x8,%esp
8010648c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010648f:	50                   	push   %eax
80106490:	6a 01                	push   $0x1
80106492:	e8 02 f6 ff ff       	call   80105a99 <argint>
80106497:	83 c4 10             	add    $0x10,%esp
8010649a:	85 c0                	test   %eax,%eax
8010649c:	79 0a                	jns    801064a8 <sys_open+0x3e>
    return -1;
8010649e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a3:	e9 61 01 00 00       	jmp    80106609 <sys_open+0x19f>

  begin_op();
801064a8:	e8 c6 d1 ff ff       	call   80103673 <begin_op>

  if(omode & O_CREATE){
801064ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064b0:	25 00 02 00 00       	and    $0x200,%eax
801064b5:	85 c0                	test   %eax,%eax
801064b7:	74 2a                	je     801064e3 <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
801064b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064bc:	6a 00                	push   $0x0
801064be:	6a 00                	push   $0x0
801064c0:	6a 02                	push   $0x2
801064c2:	50                   	push   %eax
801064c3:	e8 ce fd ff ff       	call   80106296 <create>
801064c8:	83 c4 10             	add    $0x10,%esp
801064cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801064ce:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064d2:	75 75                	jne    80106549 <sys_open+0xdf>
      end_op();
801064d4:	e8 2a d2 ff ff       	call   80103703 <end_op>
      return -1;
801064d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064de:	e9 26 01 00 00       	jmp    80106609 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
801064e3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801064e6:	83 ec 0c             	sub    $0xc,%esp
801064e9:	50                   	push   %eax
801064ea:	e8 20 c1 ff ff       	call   8010260f <namei>
801064ef:	83 c4 10             	add    $0x10,%esp
801064f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064f9:	75 0f                	jne    8010650a <sys_open+0xa0>
      end_op();
801064fb:	e8 03 d2 ff ff       	call   80103703 <end_op>
      return -1;
80106500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106505:	e9 ff 00 00 00       	jmp    80106609 <sys_open+0x19f>
    }
    ilock(ip);
8010650a:	83 ec 0c             	sub    $0xc,%esp
8010650d:	ff 75 f4             	pushl  -0xc(%ebp)
80106510:	e8 8f b5 ff ff       	call   80101aa4 <ilock>
80106515:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651b:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010651f:	66 83 f8 01          	cmp    $0x1,%ax
80106523:	75 24                	jne    80106549 <sys_open+0xdf>
80106525:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106528:	85 c0                	test   %eax,%eax
8010652a:	74 1d                	je     80106549 <sys_open+0xdf>
      iunlockput(ip);
8010652c:	83 ec 0c             	sub    $0xc,%esp
8010652f:	ff 75 f4             	pushl  -0xc(%ebp)
80106532:	e8 aa b7 ff ff       	call   80101ce1 <iunlockput>
80106537:	83 c4 10             	add    $0x10,%esp
      end_op();
8010653a:	e8 c4 d1 ff ff       	call   80103703 <end_op>
      return -1;
8010653f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106544:	e9 c0 00 00 00       	jmp    80106609 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106549:	e8 10 ab ff ff       	call   8010105e <filealloc>
8010654e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106551:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106555:	74 17                	je     8010656e <sys_open+0x104>
80106557:	83 ec 0c             	sub    $0xc,%esp
8010655a:	ff 75 f0             	pushl  -0x10(%ebp)
8010655d:	e8 09 f7 ff ff       	call   80105c6b <fdalloc>
80106562:	83 c4 10             	add    $0x10,%esp
80106565:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106568:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010656c:	79 2e                	jns    8010659c <sys_open+0x132>
    if(f)
8010656e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106572:	74 0e                	je     80106582 <sys_open+0x118>
      fileclose(f);
80106574:	83 ec 0c             	sub    $0xc,%esp
80106577:	ff 75 f0             	pushl  -0x10(%ebp)
8010657a:	e8 a5 ab ff ff       	call   80101124 <fileclose>
8010657f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106582:	83 ec 0c             	sub    $0xc,%esp
80106585:	ff 75 f4             	pushl  -0xc(%ebp)
80106588:	e8 54 b7 ff ff       	call   80101ce1 <iunlockput>
8010658d:	83 c4 10             	add    $0x10,%esp
    end_op();
80106590:	e8 6e d1 ff ff       	call   80103703 <end_op>
    return -1;
80106595:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659a:	eb 6d                	jmp    80106609 <sys_open+0x19f>
  }
  iunlock(ip);
8010659c:	83 ec 0c             	sub    $0xc,%esp
8010659f:	ff 75 f4             	pushl  -0xc(%ebp)
801065a2:	e8 14 b6 ff ff       	call   80101bbb <iunlock>
801065a7:	83 c4 10             	add    $0x10,%esp
  end_op();
801065aa:	e8 54 d1 ff ff       	call   80103703 <end_op>

  f->type = FD_INODE;
801065af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b2:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801065b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065be:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801065c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801065cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065ce:	83 e0 01             	and    $0x1,%eax
801065d1:	85 c0                	test   %eax,%eax
801065d3:	0f 94 c0             	sete   %al
801065d6:	89 c2                	mov    %eax,%edx
801065d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065db:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801065de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065e1:	83 e0 01             	and    $0x1,%eax
801065e4:	85 c0                	test   %eax,%eax
801065e6:	75 0a                	jne    801065f2 <sys_open+0x188>
801065e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065eb:	83 e0 02             	and    $0x2,%eax
801065ee:	85 c0                	test   %eax,%eax
801065f0:	74 07                	je     801065f9 <sys_open+0x18f>
801065f2:	b8 01 00 00 00       	mov    $0x1,%eax
801065f7:	eb 05                	jmp    801065fe <sys_open+0x194>
801065f9:	b8 00 00 00 00       	mov    $0x0,%eax
801065fe:	89 c2                	mov    %eax,%edx
80106600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106603:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106606:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106609:	c9                   	leave  
8010660a:	c3                   	ret    

8010660b <sys_mkdir>:

int
sys_mkdir(void)
{
8010660b:	f3 0f 1e fb          	endbr32 
8010660f:	55                   	push   %ebp
80106610:	89 e5                	mov    %esp,%ebp
80106612:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106615:	e8 59 d0 ff ff       	call   80103673 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010661a:	83 ec 08             	sub    $0x8,%esp
8010661d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106620:	50                   	push   %eax
80106621:	6a 00                	push   $0x0
80106623:	e8 0e f5 ff ff       	call   80105b36 <argstr>
80106628:	83 c4 10             	add    $0x10,%esp
8010662b:	85 c0                	test   %eax,%eax
8010662d:	78 1b                	js     8010664a <sys_mkdir+0x3f>
8010662f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106632:	6a 00                	push   $0x0
80106634:	6a 00                	push   $0x0
80106636:	6a 01                	push   $0x1
80106638:	50                   	push   %eax
80106639:	e8 58 fc ff ff       	call   80106296 <create>
8010663e:	83 c4 10             	add    $0x10,%esp
80106641:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106644:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106648:	75 0c                	jne    80106656 <sys_mkdir+0x4b>
    end_op();
8010664a:	e8 b4 d0 ff ff       	call   80103703 <end_op>
    return -1;
8010664f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106654:	eb 18                	jmp    8010666e <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106656:	83 ec 0c             	sub    $0xc,%esp
80106659:	ff 75 f4             	pushl  -0xc(%ebp)
8010665c:	e8 80 b6 ff ff       	call   80101ce1 <iunlockput>
80106661:	83 c4 10             	add    $0x10,%esp
  end_op();
80106664:	e8 9a d0 ff ff       	call   80103703 <end_op>
  return 0;
80106669:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010666e:	c9                   	leave  
8010666f:	c3                   	ret    

80106670 <sys_mknod>:

int
sys_mknod(void)
{
80106670:	f3 0f 1e fb          	endbr32 
80106674:	55                   	push   %ebp
80106675:	89 e5                	mov    %esp,%ebp
80106677:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010667a:	e8 f4 cf ff ff       	call   80103673 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010667f:	83 ec 08             	sub    $0x8,%esp
80106682:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106685:	50                   	push   %eax
80106686:	6a 00                	push   $0x0
80106688:	e8 a9 f4 ff ff       	call   80105b36 <argstr>
8010668d:	83 c4 10             	add    $0x10,%esp
80106690:	85 c0                	test   %eax,%eax
80106692:	78 4f                	js     801066e3 <sys_mknod+0x73>
     argint(1, &major) < 0 ||
80106694:	83 ec 08             	sub    $0x8,%esp
80106697:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010669a:	50                   	push   %eax
8010669b:	6a 01                	push   $0x1
8010669d:	e8 f7 f3 ff ff       	call   80105a99 <argint>
801066a2:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
801066a5:	85 c0                	test   %eax,%eax
801066a7:	78 3a                	js     801066e3 <sys_mknod+0x73>
     argint(2, &minor) < 0 ||
801066a9:	83 ec 08             	sub    $0x8,%esp
801066ac:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066af:	50                   	push   %eax
801066b0:	6a 02                	push   $0x2
801066b2:	e8 e2 f3 ff ff       	call   80105a99 <argint>
801066b7:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801066ba:	85 c0                	test   %eax,%eax
801066bc:	78 25                	js     801066e3 <sys_mknod+0x73>
     (ip = create(path, T_DEV, major, minor)) == 0){
801066be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066c1:	0f bf c8             	movswl %ax,%ecx
801066c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066c7:	0f bf d0             	movswl %ax,%edx
801066ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066cd:	51                   	push   %ecx
801066ce:	52                   	push   %edx
801066cf:	6a 03                	push   $0x3
801066d1:	50                   	push   %eax
801066d2:	e8 bf fb ff ff       	call   80106296 <create>
801066d7:	83 c4 10             	add    $0x10,%esp
801066da:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801066dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066e1:	75 0c                	jne    801066ef <sys_mknod+0x7f>
    end_op();
801066e3:	e8 1b d0 ff ff       	call   80103703 <end_op>
    return -1;
801066e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ed:	eb 18                	jmp    80106707 <sys_mknod+0x97>
  }
  iunlockput(ip);
801066ef:	83 ec 0c             	sub    $0xc,%esp
801066f2:	ff 75 f4             	pushl  -0xc(%ebp)
801066f5:	e8 e7 b5 ff ff       	call   80101ce1 <iunlockput>
801066fa:	83 c4 10             	add    $0x10,%esp
  end_op();
801066fd:	e8 01 d0 ff ff       	call   80103703 <end_op>
  return 0;
80106702:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106707:	c9                   	leave  
80106708:	c3                   	ret    

80106709 <sys_chdir>:

int
sys_chdir(void)
{
80106709:	f3 0f 1e fb          	endbr32 
8010670d:	55                   	push   %ebp
8010670e:	89 e5                	mov    %esp,%ebp
80106710:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106713:	e8 19 dd ff ff       	call   80104431 <myproc>
80106718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010671b:	e8 53 cf ff ff       	call   80103673 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106720:	83 ec 08             	sub    $0x8,%esp
80106723:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106726:	50                   	push   %eax
80106727:	6a 00                	push   $0x0
80106729:	e8 08 f4 ff ff       	call   80105b36 <argstr>
8010672e:	83 c4 10             	add    $0x10,%esp
80106731:	85 c0                	test   %eax,%eax
80106733:	78 18                	js     8010674d <sys_chdir+0x44>
80106735:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106738:	83 ec 0c             	sub    $0xc,%esp
8010673b:	50                   	push   %eax
8010673c:	e8 ce be ff ff       	call   8010260f <namei>
80106741:	83 c4 10             	add    $0x10,%esp
80106744:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106747:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010674b:	75 0c                	jne    80106759 <sys_chdir+0x50>
    end_op();
8010674d:	e8 b1 cf ff ff       	call   80103703 <end_op>
    return -1;
80106752:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106757:	eb 68                	jmp    801067c1 <sys_chdir+0xb8>
  }
  ilock(ip);
80106759:	83 ec 0c             	sub    $0xc,%esp
8010675c:	ff 75 f0             	pushl  -0x10(%ebp)
8010675f:	e8 40 b3 ff ff       	call   80101aa4 <ilock>
80106764:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106767:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010676a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010676e:	66 83 f8 01          	cmp    $0x1,%ax
80106772:	74 1a                	je     8010678e <sys_chdir+0x85>
    iunlockput(ip);
80106774:	83 ec 0c             	sub    $0xc,%esp
80106777:	ff 75 f0             	pushl  -0x10(%ebp)
8010677a:	e8 62 b5 ff ff       	call   80101ce1 <iunlockput>
8010677f:	83 c4 10             	add    $0x10,%esp
    end_op();
80106782:	e8 7c cf ff ff       	call   80103703 <end_op>
    return -1;
80106787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678c:	eb 33                	jmp    801067c1 <sys_chdir+0xb8>
  }
  iunlock(ip);
8010678e:	83 ec 0c             	sub    $0xc,%esp
80106791:	ff 75 f0             	pushl  -0x10(%ebp)
80106794:	e8 22 b4 ff ff       	call   80101bbb <iunlock>
80106799:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
8010679c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010679f:	8b 40 68             	mov    0x68(%eax),%eax
801067a2:	83 ec 0c             	sub    $0xc,%esp
801067a5:	50                   	push   %eax
801067a6:	e8 62 b4 ff ff       	call   80101c0d <iput>
801067ab:	83 c4 10             	add    $0x10,%esp
  end_op();
801067ae:	e8 50 cf ff ff       	call   80103703 <end_op>
  curproc->cwd = ip;
801067b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067b9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801067bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067c1:	c9                   	leave  
801067c2:	c3                   	ret    

801067c3 <sys_exec>:

int
sys_exec(void)
{
801067c3:	f3 0f 1e fb          	endbr32 
801067c7:	55                   	push   %ebp
801067c8:	89 e5                	mov    %esp,%ebp
801067ca:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801067d0:	83 ec 08             	sub    $0x8,%esp
801067d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067d6:	50                   	push   %eax
801067d7:	6a 00                	push   $0x0
801067d9:	e8 58 f3 ff ff       	call   80105b36 <argstr>
801067de:	83 c4 10             	add    $0x10,%esp
801067e1:	85 c0                	test   %eax,%eax
801067e3:	78 18                	js     801067fd <sys_exec+0x3a>
801067e5:	83 ec 08             	sub    $0x8,%esp
801067e8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801067ee:	50                   	push   %eax
801067ef:	6a 01                	push   $0x1
801067f1:	e8 a3 f2 ff ff       	call   80105a99 <argint>
801067f6:	83 c4 10             	add    $0x10,%esp
801067f9:	85 c0                	test   %eax,%eax
801067fb:	79 0a                	jns    80106807 <sys_exec+0x44>
    return -1;
801067fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106802:	e9 c6 00 00 00       	jmp    801068cd <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80106807:	83 ec 04             	sub    $0x4,%esp
8010680a:	68 80 00 00 00       	push   $0x80
8010680f:	6a 00                	push   $0x0
80106811:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106817:	50                   	push   %eax
80106818:	e8 28 ef ff ff       	call   80105745 <memset>
8010681d:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106820:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010682a:	83 f8 1f             	cmp    $0x1f,%eax
8010682d:	76 0a                	jbe    80106839 <sys_exec+0x76>
      return -1;
8010682f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106834:	e9 94 00 00 00       	jmp    801068cd <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683c:	c1 e0 02             	shl    $0x2,%eax
8010683f:	89 c2                	mov    %eax,%edx
80106841:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106847:	01 c2                	add    %eax,%edx
80106849:	83 ec 08             	sub    $0x8,%esp
8010684c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106852:	50                   	push   %eax
80106853:	52                   	push   %edx
80106854:	e8 95 f1 ff ff       	call   801059ee <fetchint>
80106859:	83 c4 10             	add    $0x10,%esp
8010685c:	85 c0                	test   %eax,%eax
8010685e:	79 07                	jns    80106867 <sys_exec+0xa4>
      return -1;
80106860:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106865:	eb 66                	jmp    801068cd <sys_exec+0x10a>
    if(uarg == 0){
80106867:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010686d:	85 c0                	test   %eax,%eax
8010686f:	75 27                	jne    80106898 <sys_exec+0xd5>
      argv[i] = 0;
80106871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106874:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010687b:	00 00 00 00 
      break;
8010687f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106883:	83 ec 08             	sub    $0x8,%esp
80106886:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010688c:	52                   	push   %edx
8010688d:	50                   	push   %eax
8010688e:	e8 66 a3 ff ff       	call   80100bf9 <exec>
80106893:	83 c4 10             	add    $0x10,%esp
80106896:	eb 35                	jmp    801068cd <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
80106898:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010689e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068a1:	c1 e2 02             	shl    $0x2,%edx
801068a4:	01 c2                	add    %eax,%edx
801068a6:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068ac:	83 ec 08             	sub    $0x8,%esp
801068af:	52                   	push   %edx
801068b0:	50                   	push   %eax
801068b1:	e8 7b f1 ff ff       	call   80105a31 <fetchstr>
801068b6:	83 c4 10             	add    $0x10,%esp
801068b9:	85 c0                	test   %eax,%eax
801068bb:	79 07                	jns    801068c4 <sys_exec+0x101>
      return -1;
801068bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c2:	eb 09                	jmp    801068cd <sys_exec+0x10a>
  for(i=0;; i++){
801068c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801068c8:	e9 5a ff ff ff       	jmp    80106827 <sys_exec+0x64>
}
801068cd:	c9                   	leave  
801068ce:	c3                   	ret    

801068cf <sys_pipe>:

int
sys_pipe(void)
{
801068cf:	f3 0f 1e fb          	endbr32 
801068d3:	55                   	push   %ebp
801068d4:	89 e5                	mov    %esp,%ebp
801068d6:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801068d9:	83 ec 04             	sub    $0x4,%esp
801068dc:	6a 08                	push   $0x8
801068de:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068e1:	50                   	push   %eax
801068e2:	6a 00                	push   $0x0
801068e4:	e8 e1 f1 ff ff       	call   80105aca <argptr>
801068e9:	83 c4 10             	add    $0x10,%esp
801068ec:	85 c0                	test   %eax,%eax
801068ee:	79 0a                	jns    801068fa <sys_pipe+0x2b>
    return -1;
801068f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f5:	e9 ae 00 00 00       	jmp    801069a8 <sys_pipe+0xd9>
  if(pipealloc(&rf, &wf) < 0)
801068fa:	83 ec 08             	sub    $0x8,%esp
801068fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106900:	50                   	push   %eax
80106901:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106904:	50                   	push   %eax
80106905:	e8 48 d6 ff ff       	call   80103f52 <pipealloc>
8010690a:	83 c4 10             	add    $0x10,%esp
8010690d:	85 c0                	test   %eax,%eax
8010690f:	79 0a                	jns    8010691b <sys_pipe+0x4c>
    return -1;
80106911:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106916:	e9 8d 00 00 00       	jmp    801069a8 <sys_pipe+0xd9>
  fd0 = -1;
8010691b:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106922:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106925:	83 ec 0c             	sub    $0xc,%esp
80106928:	50                   	push   %eax
80106929:	e8 3d f3 ff ff       	call   80105c6b <fdalloc>
8010692e:	83 c4 10             	add    $0x10,%esp
80106931:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106934:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106938:	78 18                	js     80106952 <sys_pipe+0x83>
8010693a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010693d:	83 ec 0c             	sub    $0xc,%esp
80106940:	50                   	push   %eax
80106941:	e8 25 f3 ff ff       	call   80105c6b <fdalloc>
80106946:	83 c4 10             	add    $0x10,%esp
80106949:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010694c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106950:	79 3e                	jns    80106990 <sys_pipe+0xc1>
    if(fd0 >= 0)
80106952:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106956:	78 13                	js     8010696b <sys_pipe+0x9c>
      myproc()->ofile[fd0] = 0;
80106958:	e8 d4 da ff ff       	call   80104431 <myproc>
8010695d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106960:	83 c2 08             	add    $0x8,%edx
80106963:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010696a:	00 
    fileclose(rf);
8010696b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010696e:	83 ec 0c             	sub    $0xc,%esp
80106971:	50                   	push   %eax
80106972:	e8 ad a7 ff ff       	call   80101124 <fileclose>
80106977:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
8010697a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010697d:	83 ec 0c             	sub    $0xc,%esp
80106980:	50                   	push   %eax
80106981:	e8 9e a7 ff ff       	call   80101124 <fileclose>
80106986:	83 c4 10             	add    $0x10,%esp
    return -1;
80106989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698e:	eb 18                	jmp    801069a8 <sys_pipe+0xd9>
  }
  fd[0] = fd0;
80106990:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106993:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106996:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106998:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010699b:	8d 50 04             	lea    0x4(%eax),%edx
8010699e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a1:	89 02                	mov    %eax,(%edx)
  return 0;
801069a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069a8:	c9                   	leave  
801069a9:	c3                   	ret    

801069aa <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801069aa:	f3 0f 1e fb          	endbr32 
801069ae:	55                   	push   %ebp
801069af:	89 e5                	mov    %esp,%ebp
801069b1:	83 ec 08             	sub    $0x8,%esp
  return fork();
801069b4:	e8 b5 dd ff ff       	call   8010476e <fork>
}
801069b9:	c9                   	leave  
801069ba:	c3                   	ret    

801069bb <sys_exit>:

int
sys_exit(void)
{
801069bb:	f3 0f 1e fb          	endbr32 
801069bf:	55                   	push   %ebp
801069c0:	89 e5                	mov    %esp,%ebp
801069c2:	83 ec 08             	sub    $0x8,%esp
  exit();
801069c5:	e8 21 df ff ff       	call   801048eb <exit>
  return 0;  // not reached
801069ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069cf:	c9                   	leave  
801069d0:	c3                   	ret    

801069d1 <sys_wait2>:

int sys_wait2(void) {
801069d1:	f3 0f 1e fb          	endbr32 
801069d5:	55                   	push   %ebp
801069d6:	89 e5                	mov    %esp,%ebp
801069d8:	83 ec 18             	sub    $0x18,%esp
  int *wtime, *rutime;
  if (argptr(0, (void*)&wtime, sizeof(wtime)) < 0)
801069db:	83 ec 04             	sub    $0x4,%esp
801069de:	6a 04                	push   $0x4
801069e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069e3:	50                   	push   %eax
801069e4:	6a 00                	push   $0x0
801069e6:	e8 df f0 ff ff       	call   80105aca <argptr>
801069eb:	83 c4 10             	add    $0x10,%esp
801069ee:	85 c0                	test   %eax,%eax
801069f0:	79 07                	jns    801069f9 <sys_wait2+0x28>
    return -1;
801069f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069f7:	eb 31                	jmp    80106a2a <sys_wait2+0x59>
  if (argptr(1, (void*)&rutime, sizeof(rutime)) < 0)
801069f9:	83 ec 04             	sub    $0x4,%esp
801069fc:	6a 04                	push   $0x4
801069fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a01:	50                   	push   %eax
80106a02:	6a 01                	push   $0x1
80106a04:	e8 c1 f0 ff ff       	call   80105aca <argptr>
80106a09:	83 c4 10             	add    $0x10,%esp
80106a0c:	85 c0                	test   %eax,%eax
80106a0e:	79 07                	jns    80106a17 <sys_wait2+0x46>
    return -1;
80106a10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a15:	eb 13                	jmp    80106a2a <sys_wait2+0x59>
  return wait2(wtime, rutime);
80106a17:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a1d:	83 ec 08             	sub    $0x8,%esp
80106a20:	52                   	push   %edx
80106a21:	50                   	push   %eax
80106a22:	e8 3d e1 ff ff       	call   80104b64 <wait2>
80106a27:	83 c4 10             	add    $0x10,%esp
}
80106a2a:	c9                   	leave  
80106a2b:	c3                   	ret    

80106a2c <sys_wait>:

int
sys_wait(void)
{
80106a2c:	f3 0f 1e fb          	endbr32 
80106a30:	55                   	push   %ebp
80106a31:	89 e5                	mov    %esp,%ebp
80106a33:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106a36:	e8 02 e0 ff ff       	call   80104a3d <wait>
}
80106a3b:	c9                   	leave  
80106a3c:	c3                   	ret    

80106a3d <sys_kill>:

int
sys_kill(void)
{
80106a3d:	f3 0f 1e fb          	endbr32 
80106a41:	55                   	push   %ebp
80106a42:	89 e5                	mov    %esp,%ebp
80106a44:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106a47:	83 ec 08             	sub    $0x8,%esp
80106a4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a4d:	50                   	push   %eax
80106a4e:	6a 00                	push   $0x0
80106a50:	e8 44 f0 ff ff       	call   80105a99 <argint>
80106a55:	83 c4 10             	add    $0x10,%esp
80106a58:	85 c0                	test   %eax,%eax
80106a5a:	79 07                	jns    80106a63 <sys_kill+0x26>
    return -1;
80106a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a61:	eb 0f                	jmp    80106a72 <sys_kill+0x35>
  return kill(pid);
80106a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a66:	83 ec 0c             	sub    $0xc,%esp
80106a69:	50                   	push   %eax
80106a6a:	e8 42 e6 ff ff       	call   801050b1 <kill>
80106a6f:	83 c4 10             	add    $0x10,%esp
}
80106a72:	c9                   	leave  
80106a73:	c3                   	ret    

80106a74 <sys_getpid>:

int
sys_getpid(void)
{
80106a74:	f3 0f 1e fb          	endbr32 
80106a78:	55                   	push   %ebp
80106a79:	89 e5                	mov    %esp,%ebp
80106a7b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106a7e:	e8 ae d9 ff ff       	call   80104431 <myproc>
80106a83:	8b 40 10             	mov    0x10(%eax),%eax
}
80106a86:	c9                   	leave  
80106a87:	c3                   	ret    

80106a88 <sys_sbrk>:

int
sys_sbrk(void)
{
80106a88:	f3 0f 1e fb          	endbr32 
80106a8c:	55                   	push   %ebp
80106a8d:	89 e5                	mov    %esp,%ebp
80106a8f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106a92:	83 ec 08             	sub    $0x8,%esp
80106a95:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a98:	50                   	push   %eax
80106a99:	6a 00                	push   $0x0
80106a9b:	e8 f9 ef ff ff       	call   80105a99 <argint>
80106aa0:	83 c4 10             	add    $0x10,%esp
80106aa3:	85 c0                	test   %eax,%eax
80106aa5:	79 07                	jns    80106aae <sys_sbrk+0x26>
    return -1;
80106aa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aac:	eb 27                	jmp    80106ad5 <sys_sbrk+0x4d>
  addr = myproc()->sz;
80106aae:	e8 7e d9 ff ff       	call   80104431 <myproc>
80106ab3:	8b 00                	mov    (%eax),%eax
80106ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106abb:	83 ec 0c             	sub    $0xc,%esp
80106abe:	50                   	push   %eax
80106abf:	e8 0b dc ff ff       	call   801046cf <growproc>
80106ac4:	83 c4 10             	add    $0x10,%esp
80106ac7:	85 c0                	test   %eax,%eax
80106ac9:	79 07                	jns    80106ad2 <sys_sbrk+0x4a>
    return -1;
80106acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad0:	eb 03                	jmp    80106ad5 <sys_sbrk+0x4d>
  return addr;
80106ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106ad5:	c9                   	leave  
80106ad6:	c3                   	ret    

80106ad7 <sys_sleep>:

int
sys_sleep(void)
{
80106ad7:	f3 0f 1e fb          	endbr32 
80106adb:	55                   	push   %ebp
80106adc:	89 e5                	mov    %esp,%ebp
80106ade:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106ae1:	83 ec 08             	sub    $0x8,%esp
80106ae4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ae7:	50                   	push   %eax
80106ae8:	6a 00                	push   $0x0
80106aea:	e8 aa ef ff ff       	call   80105a99 <argint>
80106aef:	83 c4 10             	add    $0x10,%esp
80106af2:	85 c0                	test   %eax,%eax
80106af4:	79 07                	jns    80106afd <sys_sleep+0x26>
    return -1;
80106af6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106afb:	eb 76                	jmp    80106b73 <sys_sleep+0x9c>
  acquire(&tickslock);
80106afd:	83 ec 0c             	sub    $0xc,%esp
80106b00:	68 00 6b 11 80       	push   $0x80116b00
80106b05:	e8 9c e9 ff ff       	call   801054a6 <acquire>
80106b0a:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106b0d:	a1 40 73 11 80       	mov    0x80117340,%eax
80106b12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106b15:	eb 38                	jmp    80106b4f <sys_sleep+0x78>
    if(myproc()->killed){
80106b17:	e8 15 d9 ff ff       	call   80104431 <myproc>
80106b1c:	8b 40 24             	mov    0x24(%eax),%eax
80106b1f:	85 c0                	test   %eax,%eax
80106b21:	74 17                	je     80106b3a <sys_sleep+0x63>
      release(&tickslock);
80106b23:	83 ec 0c             	sub    $0xc,%esp
80106b26:	68 00 6b 11 80       	push   $0x80116b00
80106b2b:	e8 e8 e9 ff ff       	call   80105518 <release>
80106b30:	83 c4 10             	add    $0x10,%esp
      return -1;
80106b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b38:	eb 39                	jmp    80106b73 <sys_sleep+0x9c>
    }
    sleep(&ticks, &tickslock);
80106b3a:	83 ec 08             	sub    $0x8,%esp
80106b3d:	68 00 6b 11 80       	push   $0x80116b00
80106b42:	68 40 73 11 80       	push   $0x80117340
80106b47:	e8 fd e3 ff ff       	call   80104f49 <sleep>
80106b4c:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80106b4f:	a1 40 73 11 80       	mov    0x80117340,%eax
80106b54:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106b57:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b5a:	39 d0                	cmp    %edx,%eax
80106b5c:	72 b9                	jb     80106b17 <sys_sleep+0x40>
  }
  release(&tickslock);
80106b5e:	83 ec 0c             	sub    $0xc,%esp
80106b61:	68 00 6b 11 80       	push   $0x80116b00
80106b66:	e8 ad e9 ff ff       	call   80105518 <release>
80106b6b:	83 c4 10             	add    $0x10,%esp
  return 0;
80106b6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b73:	c9                   	leave  
80106b74:	c3                   	ret    

80106b75 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106b75:	f3 0f 1e fb          	endbr32 
80106b79:	55                   	push   %ebp
80106b7a:	89 e5                	mov    %esp,%ebp
80106b7c:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106b7f:	83 ec 0c             	sub    $0xc,%esp
80106b82:	68 00 6b 11 80       	push   $0x80116b00
80106b87:	e8 1a e9 ff ff       	call   801054a6 <acquire>
80106b8c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106b8f:	a1 40 73 11 80       	mov    0x80117340,%eax
80106b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106b97:	83 ec 0c             	sub    $0xc,%esp
80106b9a:	68 00 6b 11 80       	push   $0x80116b00
80106b9f:	e8 74 e9 ff ff       	call   80105518 <release>
80106ba4:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106baa:	c9                   	leave  
80106bab:	c3                   	ret    

80106bac <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106bac:	1e                   	push   %ds
  pushl %es
80106bad:	06                   	push   %es
  pushl %fs
80106bae:	0f a0                	push   %fs
  pushl %gs
80106bb0:	0f a8                	push   %gs
  pushal
80106bb2:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106bb3:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106bb7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106bb9:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106bbb:	54                   	push   %esp
  call trap
80106bbc:	e8 df 01 00 00       	call   80106da0 <trap>
  addl $4, %esp
80106bc1:	83 c4 04             	add    $0x4,%esp

80106bc4 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106bc4:	61                   	popa   
  popl %gs
80106bc5:	0f a9                	pop    %gs
  popl %fs
80106bc7:	0f a1                	pop    %fs
  popl %es
80106bc9:	07                   	pop    %es
  popl %ds
80106bca:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106bcb:	83 c4 08             	add    $0x8,%esp
  iret
80106bce:	cf                   	iret   

80106bcf <lidt>:
{
80106bcf:	55                   	push   %ebp
80106bd0:	89 e5                	mov    %esp,%ebp
80106bd2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106bd8:	83 e8 01             	sub    $0x1,%eax
80106bdb:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80106be2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106be6:	8b 45 08             	mov    0x8(%ebp),%eax
80106be9:	c1 e8 10             	shr    $0x10,%eax
80106bec:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80106bf0:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106bf3:	0f 01 18             	lidtl  (%eax)
}
80106bf6:	90                   	nop
80106bf7:	c9                   	leave  
80106bf8:	c3                   	ret    

80106bf9 <rcr2>:

static inline uint
rcr2(void)
{
80106bf9:	55                   	push   %ebp
80106bfa:	89 e5                	mov    %esp,%ebp
80106bfc:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106bff:	0f 20 d0             	mov    %cr2,%eax
80106c02:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106c05:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106c08:	c9                   	leave  
80106c09:	c3                   	ret    

80106c0a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106c0a:	f3 0f 1e fb          	endbr32 
80106c0e:	55                   	push   %ebp
80106c0f:	89 e5                	mov    %esp,%ebp
80106c11:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106c14:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c1b:	e9 c3 00 00 00       	jmp    80106ce3 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c23:	8b 04 85 7c c0 10 80 	mov    -0x7fef3f84(,%eax,4),%eax
80106c2a:	89 c2                	mov    %eax,%edx
80106c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2f:	66 89 14 c5 40 6b 11 	mov    %dx,-0x7fee94c0(,%eax,8)
80106c36:	80 
80106c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3a:	66 c7 04 c5 42 6b 11 	movw   $0x8,-0x7fee94be(,%eax,8)
80106c41:	80 08 00 
80106c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c47:	0f b6 14 c5 44 6b 11 	movzbl -0x7fee94bc(,%eax,8),%edx
80106c4e:	80 
80106c4f:	83 e2 e0             	and    $0xffffffe0,%edx
80106c52:	88 14 c5 44 6b 11 80 	mov    %dl,-0x7fee94bc(,%eax,8)
80106c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c5c:	0f b6 14 c5 44 6b 11 	movzbl -0x7fee94bc(,%eax,8),%edx
80106c63:	80 
80106c64:	83 e2 1f             	and    $0x1f,%edx
80106c67:	88 14 c5 44 6b 11 80 	mov    %dl,-0x7fee94bc(,%eax,8)
80106c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c71:	0f b6 14 c5 45 6b 11 	movzbl -0x7fee94bb(,%eax,8),%edx
80106c78:	80 
80106c79:	83 e2 f0             	and    $0xfffffff0,%edx
80106c7c:	83 ca 0e             	or     $0xe,%edx
80106c7f:	88 14 c5 45 6b 11 80 	mov    %dl,-0x7fee94bb(,%eax,8)
80106c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c89:	0f b6 14 c5 45 6b 11 	movzbl -0x7fee94bb(,%eax,8),%edx
80106c90:	80 
80106c91:	83 e2 ef             	and    $0xffffffef,%edx
80106c94:	88 14 c5 45 6b 11 80 	mov    %dl,-0x7fee94bb(,%eax,8)
80106c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c9e:	0f b6 14 c5 45 6b 11 	movzbl -0x7fee94bb(,%eax,8),%edx
80106ca5:	80 
80106ca6:	83 e2 9f             	and    $0xffffff9f,%edx
80106ca9:	88 14 c5 45 6b 11 80 	mov    %dl,-0x7fee94bb(,%eax,8)
80106cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cb3:	0f b6 14 c5 45 6b 11 	movzbl -0x7fee94bb(,%eax,8),%edx
80106cba:	80 
80106cbb:	83 ca 80             	or     $0xffffff80,%edx
80106cbe:	88 14 c5 45 6b 11 80 	mov    %dl,-0x7fee94bb(,%eax,8)
80106cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cc8:	8b 04 85 7c c0 10 80 	mov    -0x7fef3f84(,%eax,4),%eax
80106ccf:	c1 e8 10             	shr    $0x10,%eax
80106cd2:	89 c2                	mov    %eax,%edx
80106cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd7:	66 89 14 c5 46 6b 11 	mov    %dx,-0x7fee94ba(,%eax,8)
80106cde:	80 
  for(i = 0; i < 256; i++)
80106cdf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ce3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106cea:	0f 8e 30 ff ff ff    	jle    80106c20 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106cf0:	a1 7c c1 10 80       	mov    0x8010c17c,%eax
80106cf5:	66 a3 40 6d 11 80    	mov    %ax,0x80116d40
80106cfb:	66 c7 05 42 6d 11 80 	movw   $0x8,0x80116d42
80106d02:	08 00 
80106d04:	0f b6 05 44 6d 11 80 	movzbl 0x80116d44,%eax
80106d0b:	83 e0 e0             	and    $0xffffffe0,%eax
80106d0e:	a2 44 6d 11 80       	mov    %al,0x80116d44
80106d13:	0f b6 05 44 6d 11 80 	movzbl 0x80116d44,%eax
80106d1a:	83 e0 1f             	and    $0x1f,%eax
80106d1d:	a2 44 6d 11 80       	mov    %al,0x80116d44
80106d22:	0f b6 05 45 6d 11 80 	movzbl 0x80116d45,%eax
80106d29:	83 c8 0f             	or     $0xf,%eax
80106d2c:	a2 45 6d 11 80       	mov    %al,0x80116d45
80106d31:	0f b6 05 45 6d 11 80 	movzbl 0x80116d45,%eax
80106d38:	83 e0 ef             	and    $0xffffffef,%eax
80106d3b:	a2 45 6d 11 80       	mov    %al,0x80116d45
80106d40:	0f b6 05 45 6d 11 80 	movzbl 0x80116d45,%eax
80106d47:	83 c8 60             	or     $0x60,%eax
80106d4a:	a2 45 6d 11 80       	mov    %al,0x80116d45
80106d4f:	0f b6 05 45 6d 11 80 	movzbl 0x80116d45,%eax
80106d56:	83 c8 80             	or     $0xffffff80,%eax
80106d59:	a2 45 6d 11 80       	mov    %al,0x80116d45
80106d5e:	a1 7c c1 10 80       	mov    0x8010c17c,%eax
80106d63:	c1 e8 10             	shr    $0x10,%eax
80106d66:	66 a3 46 6d 11 80    	mov    %ax,0x80116d46

  initlock(&tickslock, "time");
80106d6c:	83 ec 08             	sub    $0x8,%esp
80106d6f:	68 f4 8e 10 80       	push   $0x80108ef4
80106d74:	68 00 6b 11 80       	push   $0x80116b00
80106d79:	e8 02 e7 ff ff       	call   80105480 <initlock>
80106d7e:	83 c4 10             	add    $0x10,%esp
}
80106d81:	90                   	nop
80106d82:	c9                   	leave  
80106d83:	c3                   	ret    

80106d84 <idtinit>:

void
idtinit(void)
{
80106d84:	f3 0f 1e fb          	endbr32 
80106d88:	55                   	push   %ebp
80106d89:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106d8b:	68 00 08 00 00       	push   $0x800
80106d90:	68 40 6b 11 80       	push   $0x80116b40
80106d95:	e8 35 fe ff ff       	call   80106bcf <lidt>
80106d9a:	83 c4 08             	add    $0x8,%esp
}
80106d9d:	90                   	nop
80106d9e:	c9                   	leave  
80106d9f:	c3                   	ret    

80106da0 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106da0:	f3 0f 1e fb          	endbr32 
80106da4:	55                   	push   %ebp
80106da5:	89 e5                	mov    %esp,%ebp
80106da7:	57                   	push   %edi
80106da8:	56                   	push   %esi
80106da9:	53                   	push   %ebx
80106daa:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106dad:	8b 45 08             	mov    0x8(%ebp),%eax
80106db0:	8b 40 30             	mov    0x30(%eax),%eax
80106db3:	83 f8 40             	cmp    $0x40,%eax
80106db6:	75 3b                	jne    80106df3 <trap+0x53>
    if(myproc()->killed)
80106db8:	e8 74 d6 ff ff       	call   80104431 <myproc>
80106dbd:	8b 40 24             	mov    0x24(%eax),%eax
80106dc0:	85 c0                	test   %eax,%eax
80106dc2:	74 05                	je     80106dc9 <trap+0x29>
      exit();
80106dc4:	e8 22 db ff ff       	call   801048eb <exit>
    myproc()->tf = tf;
80106dc9:	e8 63 d6 ff ff       	call   80104431 <myproc>
80106dce:	8b 55 08             	mov    0x8(%ebp),%edx
80106dd1:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106dd4:	e8 98 ed ff ff       	call   80105b71 <syscall>
    if(myproc()->killed)
80106dd9:	e8 53 d6 ff ff       	call   80104431 <myproc>
80106dde:	8b 40 24             	mov    0x24(%eax),%eax
80106de1:	85 c0                	test   %eax,%eax
80106de3:	0f 84 37 02 00 00    	je     80107020 <trap+0x280>
      exit();
80106de9:	e8 fd da ff ff       	call   801048eb <exit>
    return;
80106dee:	e9 2d 02 00 00       	jmp    80107020 <trap+0x280>
  }

  switch(tf->trapno){
80106df3:	8b 45 08             	mov    0x8(%ebp),%eax
80106df6:	8b 40 30             	mov    0x30(%eax),%eax
80106df9:	83 e8 20             	sub    $0x20,%eax
80106dfc:	83 f8 1f             	cmp    $0x1f,%eax
80106dff:	0f 87 b6 00 00 00    	ja     80106ebb <trap+0x11b>
80106e05:	8b 04 85 9c 8f 10 80 	mov    -0x7fef7064(,%eax,4),%eax
80106e0c:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106e0f:	e8 82 d5 ff ff       	call   80104396 <cpuid>
80106e14:	85 c0                	test   %eax,%eax
80106e16:	75 3d                	jne    80106e55 <trap+0xb5>
      acquire(&tickslock);
80106e18:	83 ec 0c             	sub    $0xc,%esp
80106e1b:	68 00 6b 11 80       	push   $0x80116b00
80106e20:	e8 81 e6 ff ff       	call   801054a6 <acquire>
80106e25:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106e28:	a1 40 73 11 80       	mov    0x80117340,%eax
80106e2d:	83 c0 01             	add    $0x1,%eax
80106e30:	a3 40 73 11 80       	mov    %eax,0x80117340
      //updatestatistics();
      wakeup(&ticks);
80106e35:	83 ec 0c             	sub    $0xc,%esp
80106e38:	68 40 73 11 80       	push   $0x80117340
80106e3d:	e8 34 e2 ff ff       	call   80105076 <wakeup>
80106e42:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106e45:	83 ec 0c             	sub    $0xc,%esp
80106e48:	68 00 6b 11 80       	push   $0x80116b00
80106e4d:	e8 c6 e6 ff ff       	call   80105518 <release>
80106e52:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106e55:	e8 cd c2 ff ff       	call   80103127 <lapiceoi>
    break;
80106e5a:	e9 11 01 00 00       	jmp    80106f70 <trap+0x1d0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106e5f:	e8 f8 ba ff ff       	call   8010295c <ideintr>
    lapiceoi();
80106e64:	e8 be c2 ff ff       	call   80103127 <lapiceoi>
    break;
80106e69:	e9 02 01 00 00       	jmp    80106f70 <trap+0x1d0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106e6e:	e8 ea c0 ff ff       	call   80102f5d <kbdintr>
    lapiceoi();
80106e73:	e8 af c2 ff ff       	call   80103127 <lapiceoi>
    break;
80106e78:	e9 f3 00 00 00       	jmp    80106f70 <trap+0x1d0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106e7d:	e8 80 03 00 00       	call   80107202 <uartintr>
    lapiceoi();
80106e82:	e8 a0 c2 ff ff       	call   80103127 <lapiceoi>
    break;
80106e87:	e9 e4 00 00 00       	jmp    80106f70 <trap+0x1d0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80106e8f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106e92:	8b 45 08             	mov    0x8(%ebp),%eax
80106e95:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106e99:	0f b7 d8             	movzwl %ax,%ebx
80106e9c:	e8 f5 d4 ff ff       	call   80104396 <cpuid>
80106ea1:	56                   	push   %esi
80106ea2:	53                   	push   %ebx
80106ea3:	50                   	push   %eax
80106ea4:	68 fc 8e 10 80       	push   $0x80108efc
80106ea9:	e8 6a 95 ff ff       	call   80100418 <cprintf>
80106eae:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106eb1:	e8 71 c2 ff ff       	call   80103127 <lapiceoi>
    break;
80106eb6:	e9 b5 00 00 00       	jmp    80106f70 <trap+0x1d0>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106ebb:	e8 71 d5 ff ff       	call   80104431 <myproc>
80106ec0:	85 c0                	test   %eax,%eax
80106ec2:	74 11                	je     80106ed5 <trap+0x135>
80106ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80106ec7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ecb:	0f b7 c0             	movzwl %ax,%eax
80106ece:	83 e0 03             	and    $0x3,%eax
80106ed1:	85 c0                	test   %eax,%eax
80106ed3:	75 39                	jne    80106f0e <trap+0x16e>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ed5:	e8 1f fd ff ff       	call   80106bf9 <rcr2>
80106eda:	89 c3                	mov    %eax,%ebx
80106edc:	8b 45 08             	mov    0x8(%ebp),%eax
80106edf:	8b 70 38             	mov    0x38(%eax),%esi
80106ee2:	e8 af d4 ff ff       	call   80104396 <cpuid>
80106ee7:	8b 55 08             	mov    0x8(%ebp),%edx
80106eea:	8b 52 30             	mov    0x30(%edx),%edx
80106eed:	83 ec 0c             	sub    $0xc,%esp
80106ef0:	53                   	push   %ebx
80106ef1:	56                   	push   %esi
80106ef2:	50                   	push   %eax
80106ef3:	52                   	push   %edx
80106ef4:	68 20 8f 10 80       	push   $0x80108f20
80106ef9:	e8 1a 95 ff ff       	call   80100418 <cprintf>
80106efe:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106f01:	83 ec 0c             	sub    $0xc,%esp
80106f04:	68 52 8f 10 80       	push   $0x80108f52
80106f09:	e8 c3 96 ff ff       	call   801005d1 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f0e:	e8 e6 fc ff ff       	call   80106bf9 <rcr2>
80106f13:	89 c6                	mov    %eax,%esi
80106f15:	8b 45 08             	mov    0x8(%ebp),%eax
80106f18:	8b 40 38             	mov    0x38(%eax),%eax
80106f1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106f1e:	e8 73 d4 ff ff       	call   80104396 <cpuid>
80106f23:	89 c3                	mov    %eax,%ebx
80106f25:	8b 45 08             	mov    0x8(%ebp),%eax
80106f28:	8b 48 34             	mov    0x34(%eax),%ecx
80106f2b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f31:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106f34:	e8 f8 d4 ff ff       	call   80104431 <myproc>
80106f39:	8d 50 6c             	lea    0x6c(%eax),%edx
80106f3c:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106f3f:	e8 ed d4 ff ff       	call   80104431 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106f44:	8b 40 10             	mov    0x10(%eax),%eax
80106f47:	56                   	push   %esi
80106f48:	ff 75 e4             	pushl  -0x1c(%ebp)
80106f4b:	53                   	push   %ebx
80106f4c:	ff 75 e0             	pushl  -0x20(%ebp)
80106f4f:	57                   	push   %edi
80106f50:	ff 75 dc             	pushl  -0x24(%ebp)
80106f53:	50                   	push   %eax
80106f54:	68 58 8f 10 80       	push   $0x80108f58
80106f59:	e8 ba 94 ff ff       	call   80100418 <cprintf>
80106f5e:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106f61:	e8 cb d4 ff ff       	call   80104431 <myproc>
80106f66:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106f6d:	eb 01                	jmp    80106f70 <trap+0x1d0>
    break;
80106f6f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106f70:	e8 bc d4 ff ff       	call   80104431 <myproc>
80106f75:	85 c0                	test   %eax,%eax
80106f77:	74 23                	je     80106f9c <trap+0x1fc>
80106f79:	e8 b3 d4 ff ff       	call   80104431 <myproc>
80106f7e:	8b 40 24             	mov    0x24(%eax),%eax
80106f81:	85 c0                	test   %eax,%eax
80106f83:	74 17                	je     80106f9c <trap+0x1fc>
80106f85:	8b 45 08             	mov    0x8(%ebp),%eax
80106f88:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f8c:	0f b7 c0             	movzwl %ax,%eax
80106f8f:	83 e0 03             	and    $0x3,%eax
80106f92:	83 f8 03             	cmp    $0x3,%eax
80106f95:	75 05                	jne    80106f9c <trap+0x1fc>
    exit();
80106f97:	e8 4f d9 ff ff       	call   801048eb <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106f9c:	e8 90 d4 ff ff       	call   80104431 <myproc>
80106fa1:	85 c0                	test   %eax,%eax
80106fa3:	74 4d                	je     80106ff2 <trap+0x252>
80106fa5:	e8 87 d4 ff ff       	call   80104431 <myproc>
80106faa:	8b 40 0c             	mov    0xc(%eax),%eax
80106fad:	83 f8 04             	cmp    $0x4,%eax
80106fb0:	75 40                	jne    80106ff2 <trap+0x252>
     tf->trapno == T_IRQ0+IRQ_TIMER) {
80106fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb5:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106fb8:	83 f8 20             	cmp    $0x20,%eax
80106fbb:	75 35                	jne    80106ff2 <trap+0x252>
        if(!(myproc()->pid % 2 == 0) || ((myproc()->rutime % 2 == 0) && (myproc()->rutime != 0))) {
80106fbd:	e8 6f d4 ff ff       	call   80104431 <myproc>
80106fc2:	8b 40 10             	mov    0x10(%eax),%eax
80106fc5:	83 e0 01             	and    $0x1,%eax
80106fc8:	85 c0                	test   %eax,%eax
80106fca:	75 21                	jne    80106fed <trap+0x24d>
80106fcc:	e8 60 d4 ff ff       	call   80104431 <myproc>
80106fd1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106fd7:	83 e0 01             	and    $0x1,%eax
80106fda:	85 c0                	test   %eax,%eax
80106fdc:	75 14                	jne    80106ff2 <trap+0x252>
80106fde:	e8 4e d4 ff ff       	call   80104431 <myproc>
80106fe3:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106fe9:	85 c0                	test   %eax,%eax
80106feb:	74 05                	je     80106ff2 <trap+0x252>
          yield();
80106fed:	e8 8e de ff ff       	call   80104e80 <yield>
        }
     }

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106ff2:	e8 3a d4 ff ff       	call   80104431 <myproc>
80106ff7:	85 c0                	test   %eax,%eax
80106ff9:	74 26                	je     80107021 <trap+0x281>
80106ffb:	e8 31 d4 ff ff       	call   80104431 <myproc>
80107000:	8b 40 24             	mov    0x24(%eax),%eax
80107003:	85 c0                	test   %eax,%eax
80107005:	74 1a                	je     80107021 <trap+0x281>
80107007:	8b 45 08             	mov    0x8(%ebp),%eax
8010700a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010700e:	0f b7 c0             	movzwl %ax,%eax
80107011:	83 e0 03             	and    $0x3,%eax
80107014:	83 f8 03             	cmp    $0x3,%eax
80107017:	75 08                	jne    80107021 <trap+0x281>
    exit();
80107019:	e8 cd d8 ff ff       	call   801048eb <exit>
8010701e:	eb 01                	jmp    80107021 <trap+0x281>
    return;
80107020:	90                   	nop
}
80107021:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107024:	5b                   	pop    %ebx
80107025:	5e                   	pop    %esi
80107026:	5f                   	pop    %edi
80107027:	5d                   	pop    %ebp
80107028:	c3                   	ret    

80107029 <inb>:
{
80107029:	55                   	push   %ebp
8010702a:	89 e5                	mov    %esp,%ebp
8010702c:	83 ec 14             	sub    $0x14,%esp
8010702f:	8b 45 08             	mov    0x8(%ebp),%eax
80107032:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107036:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010703a:	89 c2                	mov    %eax,%edx
8010703c:	ec                   	in     (%dx),%al
8010703d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107040:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107044:	c9                   	leave  
80107045:	c3                   	ret    

80107046 <outb>:
{
80107046:	55                   	push   %ebp
80107047:	89 e5                	mov    %esp,%ebp
80107049:	83 ec 08             	sub    $0x8,%esp
8010704c:	8b 45 08             	mov    0x8(%ebp),%eax
8010704f:	8b 55 0c             	mov    0xc(%ebp),%edx
80107052:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107056:	89 d0                	mov    %edx,%eax
80107058:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010705b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010705f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107063:	ee                   	out    %al,(%dx)
}
80107064:	90                   	nop
80107065:	c9                   	leave  
80107066:	c3                   	ret    

80107067 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107067:	f3 0f 1e fb          	endbr32 
8010706b:	55                   	push   %ebp
8010706c:	89 e5                	mov    %esp,%ebp
8010706e:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107071:	6a 00                	push   $0x0
80107073:	68 fa 03 00 00       	push   $0x3fa
80107078:	e8 c9 ff ff ff       	call   80107046 <outb>
8010707d:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107080:	68 80 00 00 00       	push   $0x80
80107085:	68 fb 03 00 00       	push   $0x3fb
8010708a:	e8 b7 ff ff ff       	call   80107046 <outb>
8010708f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107092:	6a 0c                	push   $0xc
80107094:	68 f8 03 00 00       	push   $0x3f8
80107099:	e8 a8 ff ff ff       	call   80107046 <outb>
8010709e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
801070a1:	6a 00                	push   $0x0
801070a3:	68 f9 03 00 00       	push   $0x3f9
801070a8:	e8 99 ff ff ff       	call   80107046 <outb>
801070ad:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801070b0:	6a 03                	push   $0x3
801070b2:	68 fb 03 00 00       	push   $0x3fb
801070b7:	e8 8a ff ff ff       	call   80107046 <outb>
801070bc:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
801070bf:	6a 00                	push   $0x0
801070c1:	68 fc 03 00 00       	push   $0x3fc
801070c6:	e8 7b ff ff ff       	call   80107046 <outb>
801070cb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801070ce:	6a 01                	push   $0x1
801070d0:	68 f9 03 00 00       	push   $0x3f9
801070d5:	e8 6c ff ff ff       	call   80107046 <outb>
801070da:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801070dd:	68 fd 03 00 00       	push   $0x3fd
801070e2:	e8 42 ff ff ff       	call   80107029 <inb>
801070e7:	83 c4 04             	add    $0x4,%esp
801070ea:	3c ff                	cmp    $0xff,%al
801070ec:	74 61                	je     8010714f <uartinit+0xe8>
    return;
  uart = 1;
801070ee:	c7 05 24 c6 10 80 01 	movl   $0x1,0x8010c624
801070f5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801070f8:	68 fa 03 00 00       	push   $0x3fa
801070fd:	e8 27 ff ff ff       	call   80107029 <inb>
80107102:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107105:	68 f8 03 00 00       	push   $0x3f8
8010710a:	e8 1a ff ff ff       	call   80107029 <inb>
8010710f:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
80107112:	83 ec 08             	sub    $0x8,%esp
80107115:	6a 00                	push   $0x0
80107117:	6a 04                	push   $0x4
80107119:	e8 f0 ba ff ff       	call   80102c0e <ioapicenable>
8010711e:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107121:	c7 45 f4 1c 90 10 80 	movl   $0x8010901c,-0xc(%ebp)
80107128:	eb 19                	jmp    80107143 <uartinit+0xdc>
    uartputc(*p);
8010712a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712d:	0f b6 00             	movzbl (%eax),%eax
80107130:	0f be c0             	movsbl %al,%eax
80107133:	83 ec 0c             	sub    $0xc,%esp
80107136:	50                   	push   %eax
80107137:	e8 16 00 00 00       	call   80107152 <uartputc>
8010713c:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
8010713f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107146:	0f b6 00             	movzbl (%eax),%eax
80107149:	84 c0                	test   %al,%al
8010714b:	75 dd                	jne    8010712a <uartinit+0xc3>
8010714d:	eb 01                	jmp    80107150 <uartinit+0xe9>
    return;
8010714f:	90                   	nop
}
80107150:	c9                   	leave  
80107151:	c3                   	ret    

80107152 <uartputc>:

void
uartputc(int c)
{
80107152:	f3 0f 1e fb          	endbr32 
80107156:	55                   	push   %ebp
80107157:	89 e5                	mov    %esp,%ebp
80107159:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010715c:	a1 24 c6 10 80       	mov    0x8010c624,%eax
80107161:	85 c0                	test   %eax,%eax
80107163:	74 53                	je     801071b8 <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107165:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010716c:	eb 11                	jmp    8010717f <uartputc+0x2d>
    microdelay(10);
8010716e:	83 ec 0c             	sub    $0xc,%esp
80107171:	6a 0a                	push   $0xa
80107173:	e8 ce bf ff ff       	call   80103146 <microdelay>
80107178:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010717b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010717f:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107183:	7f 1a                	jg     8010719f <uartputc+0x4d>
80107185:	83 ec 0c             	sub    $0xc,%esp
80107188:	68 fd 03 00 00       	push   $0x3fd
8010718d:	e8 97 fe ff ff       	call   80107029 <inb>
80107192:	83 c4 10             	add    $0x10,%esp
80107195:	0f b6 c0             	movzbl %al,%eax
80107198:	83 e0 20             	and    $0x20,%eax
8010719b:	85 c0                	test   %eax,%eax
8010719d:	74 cf                	je     8010716e <uartputc+0x1c>
  outb(COM1+0, c);
8010719f:	8b 45 08             	mov    0x8(%ebp),%eax
801071a2:	0f b6 c0             	movzbl %al,%eax
801071a5:	83 ec 08             	sub    $0x8,%esp
801071a8:	50                   	push   %eax
801071a9:	68 f8 03 00 00       	push   $0x3f8
801071ae:	e8 93 fe ff ff       	call   80107046 <outb>
801071b3:	83 c4 10             	add    $0x10,%esp
801071b6:	eb 01                	jmp    801071b9 <uartputc+0x67>
    return;
801071b8:	90                   	nop
}
801071b9:	c9                   	leave  
801071ba:	c3                   	ret    

801071bb <uartgetc>:

static int
uartgetc(void)
{
801071bb:	f3 0f 1e fb          	endbr32 
801071bf:	55                   	push   %ebp
801071c0:	89 e5                	mov    %esp,%ebp
  if(!uart)
801071c2:	a1 24 c6 10 80       	mov    0x8010c624,%eax
801071c7:	85 c0                	test   %eax,%eax
801071c9:	75 07                	jne    801071d2 <uartgetc+0x17>
    return -1;
801071cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071d0:	eb 2e                	jmp    80107200 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
801071d2:	68 fd 03 00 00       	push   $0x3fd
801071d7:	e8 4d fe ff ff       	call   80107029 <inb>
801071dc:	83 c4 04             	add    $0x4,%esp
801071df:	0f b6 c0             	movzbl %al,%eax
801071e2:	83 e0 01             	and    $0x1,%eax
801071e5:	85 c0                	test   %eax,%eax
801071e7:	75 07                	jne    801071f0 <uartgetc+0x35>
    return -1;
801071e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ee:	eb 10                	jmp    80107200 <uartgetc+0x45>
  return inb(COM1+0);
801071f0:	68 f8 03 00 00       	push   $0x3f8
801071f5:	e8 2f fe ff ff       	call   80107029 <inb>
801071fa:	83 c4 04             	add    $0x4,%esp
801071fd:	0f b6 c0             	movzbl %al,%eax
}
80107200:	c9                   	leave  
80107201:	c3                   	ret    

80107202 <uartintr>:

void
uartintr(void)
{
80107202:	f3 0f 1e fb          	endbr32 
80107206:	55                   	push   %ebp
80107207:	89 e5                	mov    %esp,%ebp
80107209:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
8010720c:	83 ec 0c             	sub    $0xc,%esp
8010720f:	68 bb 71 10 80       	push   $0x801071bb
80107214:	e8 58 96 ff ff       	call   80100871 <consoleintr>
80107219:	83 c4 10             	add    $0x10,%esp
}
8010721c:	90                   	nop
8010721d:	c9                   	leave  
8010721e:	c3                   	ret    

8010721f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010721f:	6a 00                	push   $0x0
  pushl $0
80107221:	6a 00                	push   $0x0
  jmp alltraps
80107223:	e9 84 f9 ff ff       	jmp    80106bac <alltraps>

80107228 <vector1>:
.globl vector1
vector1:
  pushl $0
80107228:	6a 00                	push   $0x0
  pushl $1
8010722a:	6a 01                	push   $0x1
  jmp alltraps
8010722c:	e9 7b f9 ff ff       	jmp    80106bac <alltraps>

80107231 <vector2>:
.globl vector2
vector2:
  pushl $0
80107231:	6a 00                	push   $0x0
  pushl $2
80107233:	6a 02                	push   $0x2
  jmp alltraps
80107235:	e9 72 f9 ff ff       	jmp    80106bac <alltraps>

8010723a <vector3>:
.globl vector3
vector3:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $3
8010723c:	6a 03                	push   $0x3
  jmp alltraps
8010723e:	e9 69 f9 ff ff       	jmp    80106bac <alltraps>

80107243 <vector4>:
.globl vector4
vector4:
  pushl $0
80107243:	6a 00                	push   $0x0
  pushl $4
80107245:	6a 04                	push   $0x4
  jmp alltraps
80107247:	e9 60 f9 ff ff       	jmp    80106bac <alltraps>

8010724c <vector5>:
.globl vector5
vector5:
  pushl $0
8010724c:	6a 00                	push   $0x0
  pushl $5
8010724e:	6a 05                	push   $0x5
  jmp alltraps
80107250:	e9 57 f9 ff ff       	jmp    80106bac <alltraps>

80107255 <vector6>:
.globl vector6
vector6:
  pushl $0
80107255:	6a 00                	push   $0x0
  pushl $6
80107257:	6a 06                	push   $0x6
  jmp alltraps
80107259:	e9 4e f9 ff ff       	jmp    80106bac <alltraps>

8010725e <vector7>:
.globl vector7
vector7:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $7
80107260:	6a 07                	push   $0x7
  jmp alltraps
80107262:	e9 45 f9 ff ff       	jmp    80106bac <alltraps>

80107267 <vector8>:
.globl vector8
vector8:
  pushl $8
80107267:	6a 08                	push   $0x8
  jmp alltraps
80107269:	e9 3e f9 ff ff       	jmp    80106bac <alltraps>

8010726e <vector9>:
.globl vector9
vector9:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $9
80107270:	6a 09                	push   $0x9
  jmp alltraps
80107272:	e9 35 f9 ff ff       	jmp    80106bac <alltraps>

80107277 <vector10>:
.globl vector10
vector10:
  pushl $10
80107277:	6a 0a                	push   $0xa
  jmp alltraps
80107279:	e9 2e f9 ff ff       	jmp    80106bac <alltraps>

8010727e <vector11>:
.globl vector11
vector11:
  pushl $11
8010727e:	6a 0b                	push   $0xb
  jmp alltraps
80107280:	e9 27 f9 ff ff       	jmp    80106bac <alltraps>

80107285 <vector12>:
.globl vector12
vector12:
  pushl $12
80107285:	6a 0c                	push   $0xc
  jmp alltraps
80107287:	e9 20 f9 ff ff       	jmp    80106bac <alltraps>

8010728c <vector13>:
.globl vector13
vector13:
  pushl $13
8010728c:	6a 0d                	push   $0xd
  jmp alltraps
8010728e:	e9 19 f9 ff ff       	jmp    80106bac <alltraps>

80107293 <vector14>:
.globl vector14
vector14:
  pushl $14
80107293:	6a 0e                	push   $0xe
  jmp alltraps
80107295:	e9 12 f9 ff ff       	jmp    80106bac <alltraps>

8010729a <vector15>:
.globl vector15
vector15:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $15
8010729c:	6a 0f                	push   $0xf
  jmp alltraps
8010729e:	e9 09 f9 ff ff       	jmp    80106bac <alltraps>

801072a3 <vector16>:
.globl vector16
vector16:
  pushl $0
801072a3:	6a 00                	push   $0x0
  pushl $16
801072a5:	6a 10                	push   $0x10
  jmp alltraps
801072a7:	e9 00 f9 ff ff       	jmp    80106bac <alltraps>

801072ac <vector17>:
.globl vector17
vector17:
  pushl $17
801072ac:	6a 11                	push   $0x11
  jmp alltraps
801072ae:	e9 f9 f8 ff ff       	jmp    80106bac <alltraps>

801072b3 <vector18>:
.globl vector18
vector18:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $18
801072b5:	6a 12                	push   $0x12
  jmp alltraps
801072b7:	e9 f0 f8 ff ff       	jmp    80106bac <alltraps>

801072bc <vector19>:
.globl vector19
vector19:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $19
801072be:	6a 13                	push   $0x13
  jmp alltraps
801072c0:	e9 e7 f8 ff ff       	jmp    80106bac <alltraps>

801072c5 <vector20>:
.globl vector20
vector20:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $20
801072c7:	6a 14                	push   $0x14
  jmp alltraps
801072c9:	e9 de f8 ff ff       	jmp    80106bac <alltraps>

801072ce <vector21>:
.globl vector21
vector21:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $21
801072d0:	6a 15                	push   $0x15
  jmp alltraps
801072d2:	e9 d5 f8 ff ff       	jmp    80106bac <alltraps>

801072d7 <vector22>:
.globl vector22
vector22:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $22
801072d9:	6a 16                	push   $0x16
  jmp alltraps
801072db:	e9 cc f8 ff ff       	jmp    80106bac <alltraps>

801072e0 <vector23>:
.globl vector23
vector23:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $23
801072e2:	6a 17                	push   $0x17
  jmp alltraps
801072e4:	e9 c3 f8 ff ff       	jmp    80106bac <alltraps>

801072e9 <vector24>:
.globl vector24
vector24:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $24
801072eb:	6a 18                	push   $0x18
  jmp alltraps
801072ed:	e9 ba f8 ff ff       	jmp    80106bac <alltraps>

801072f2 <vector25>:
.globl vector25
vector25:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $25
801072f4:	6a 19                	push   $0x19
  jmp alltraps
801072f6:	e9 b1 f8 ff ff       	jmp    80106bac <alltraps>

801072fb <vector26>:
.globl vector26
vector26:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $26
801072fd:	6a 1a                	push   $0x1a
  jmp alltraps
801072ff:	e9 a8 f8 ff ff       	jmp    80106bac <alltraps>

80107304 <vector27>:
.globl vector27
vector27:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $27
80107306:	6a 1b                	push   $0x1b
  jmp alltraps
80107308:	e9 9f f8 ff ff       	jmp    80106bac <alltraps>

8010730d <vector28>:
.globl vector28
vector28:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $28
8010730f:	6a 1c                	push   $0x1c
  jmp alltraps
80107311:	e9 96 f8 ff ff       	jmp    80106bac <alltraps>

80107316 <vector29>:
.globl vector29
vector29:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $29
80107318:	6a 1d                	push   $0x1d
  jmp alltraps
8010731a:	e9 8d f8 ff ff       	jmp    80106bac <alltraps>

8010731f <vector30>:
.globl vector30
vector30:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $30
80107321:	6a 1e                	push   $0x1e
  jmp alltraps
80107323:	e9 84 f8 ff ff       	jmp    80106bac <alltraps>

80107328 <vector31>:
.globl vector31
vector31:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $31
8010732a:	6a 1f                	push   $0x1f
  jmp alltraps
8010732c:	e9 7b f8 ff ff       	jmp    80106bac <alltraps>

80107331 <vector32>:
.globl vector32
vector32:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $32
80107333:	6a 20                	push   $0x20
  jmp alltraps
80107335:	e9 72 f8 ff ff       	jmp    80106bac <alltraps>

8010733a <vector33>:
.globl vector33
vector33:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $33
8010733c:	6a 21                	push   $0x21
  jmp alltraps
8010733e:	e9 69 f8 ff ff       	jmp    80106bac <alltraps>

80107343 <vector34>:
.globl vector34
vector34:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $34
80107345:	6a 22                	push   $0x22
  jmp alltraps
80107347:	e9 60 f8 ff ff       	jmp    80106bac <alltraps>

8010734c <vector35>:
.globl vector35
vector35:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $35
8010734e:	6a 23                	push   $0x23
  jmp alltraps
80107350:	e9 57 f8 ff ff       	jmp    80106bac <alltraps>

80107355 <vector36>:
.globl vector36
vector36:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $36
80107357:	6a 24                	push   $0x24
  jmp alltraps
80107359:	e9 4e f8 ff ff       	jmp    80106bac <alltraps>

8010735e <vector37>:
.globl vector37
vector37:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $37
80107360:	6a 25                	push   $0x25
  jmp alltraps
80107362:	e9 45 f8 ff ff       	jmp    80106bac <alltraps>

80107367 <vector38>:
.globl vector38
vector38:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $38
80107369:	6a 26                	push   $0x26
  jmp alltraps
8010736b:	e9 3c f8 ff ff       	jmp    80106bac <alltraps>

80107370 <vector39>:
.globl vector39
vector39:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $39
80107372:	6a 27                	push   $0x27
  jmp alltraps
80107374:	e9 33 f8 ff ff       	jmp    80106bac <alltraps>

80107379 <vector40>:
.globl vector40
vector40:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $40
8010737b:	6a 28                	push   $0x28
  jmp alltraps
8010737d:	e9 2a f8 ff ff       	jmp    80106bac <alltraps>

80107382 <vector41>:
.globl vector41
vector41:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $41
80107384:	6a 29                	push   $0x29
  jmp alltraps
80107386:	e9 21 f8 ff ff       	jmp    80106bac <alltraps>

8010738b <vector42>:
.globl vector42
vector42:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $42
8010738d:	6a 2a                	push   $0x2a
  jmp alltraps
8010738f:	e9 18 f8 ff ff       	jmp    80106bac <alltraps>

80107394 <vector43>:
.globl vector43
vector43:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $43
80107396:	6a 2b                	push   $0x2b
  jmp alltraps
80107398:	e9 0f f8 ff ff       	jmp    80106bac <alltraps>

8010739d <vector44>:
.globl vector44
vector44:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $44
8010739f:	6a 2c                	push   $0x2c
  jmp alltraps
801073a1:	e9 06 f8 ff ff       	jmp    80106bac <alltraps>

801073a6 <vector45>:
.globl vector45
vector45:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $45
801073a8:	6a 2d                	push   $0x2d
  jmp alltraps
801073aa:	e9 fd f7 ff ff       	jmp    80106bac <alltraps>

801073af <vector46>:
.globl vector46
vector46:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $46
801073b1:	6a 2e                	push   $0x2e
  jmp alltraps
801073b3:	e9 f4 f7 ff ff       	jmp    80106bac <alltraps>

801073b8 <vector47>:
.globl vector47
vector47:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $47
801073ba:	6a 2f                	push   $0x2f
  jmp alltraps
801073bc:	e9 eb f7 ff ff       	jmp    80106bac <alltraps>

801073c1 <vector48>:
.globl vector48
vector48:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $48
801073c3:	6a 30                	push   $0x30
  jmp alltraps
801073c5:	e9 e2 f7 ff ff       	jmp    80106bac <alltraps>

801073ca <vector49>:
.globl vector49
vector49:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $49
801073cc:	6a 31                	push   $0x31
  jmp alltraps
801073ce:	e9 d9 f7 ff ff       	jmp    80106bac <alltraps>

801073d3 <vector50>:
.globl vector50
vector50:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $50
801073d5:	6a 32                	push   $0x32
  jmp alltraps
801073d7:	e9 d0 f7 ff ff       	jmp    80106bac <alltraps>

801073dc <vector51>:
.globl vector51
vector51:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $51
801073de:	6a 33                	push   $0x33
  jmp alltraps
801073e0:	e9 c7 f7 ff ff       	jmp    80106bac <alltraps>

801073e5 <vector52>:
.globl vector52
vector52:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $52
801073e7:	6a 34                	push   $0x34
  jmp alltraps
801073e9:	e9 be f7 ff ff       	jmp    80106bac <alltraps>

801073ee <vector53>:
.globl vector53
vector53:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $53
801073f0:	6a 35                	push   $0x35
  jmp alltraps
801073f2:	e9 b5 f7 ff ff       	jmp    80106bac <alltraps>

801073f7 <vector54>:
.globl vector54
vector54:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $54
801073f9:	6a 36                	push   $0x36
  jmp alltraps
801073fb:	e9 ac f7 ff ff       	jmp    80106bac <alltraps>

80107400 <vector55>:
.globl vector55
vector55:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $55
80107402:	6a 37                	push   $0x37
  jmp alltraps
80107404:	e9 a3 f7 ff ff       	jmp    80106bac <alltraps>

80107409 <vector56>:
.globl vector56
vector56:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $56
8010740b:	6a 38                	push   $0x38
  jmp alltraps
8010740d:	e9 9a f7 ff ff       	jmp    80106bac <alltraps>

80107412 <vector57>:
.globl vector57
vector57:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $57
80107414:	6a 39                	push   $0x39
  jmp alltraps
80107416:	e9 91 f7 ff ff       	jmp    80106bac <alltraps>

8010741b <vector58>:
.globl vector58
vector58:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $58
8010741d:	6a 3a                	push   $0x3a
  jmp alltraps
8010741f:	e9 88 f7 ff ff       	jmp    80106bac <alltraps>

80107424 <vector59>:
.globl vector59
vector59:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $59
80107426:	6a 3b                	push   $0x3b
  jmp alltraps
80107428:	e9 7f f7 ff ff       	jmp    80106bac <alltraps>

8010742d <vector60>:
.globl vector60
vector60:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $60
8010742f:	6a 3c                	push   $0x3c
  jmp alltraps
80107431:	e9 76 f7 ff ff       	jmp    80106bac <alltraps>

80107436 <vector61>:
.globl vector61
vector61:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $61
80107438:	6a 3d                	push   $0x3d
  jmp alltraps
8010743a:	e9 6d f7 ff ff       	jmp    80106bac <alltraps>

8010743f <vector62>:
.globl vector62
vector62:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $62
80107441:	6a 3e                	push   $0x3e
  jmp alltraps
80107443:	e9 64 f7 ff ff       	jmp    80106bac <alltraps>

80107448 <vector63>:
.globl vector63
vector63:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $63
8010744a:	6a 3f                	push   $0x3f
  jmp alltraps
8010744c:	e9 5b f7 ff ff       	jmp    80106bac <alltraps>

80107451 <vector64>:
.globl vector64
vector64:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $64
80107453:	6a 40                	push   $0x40
  jmp alltraps
80107455:	e9 52 f7 ff ff       	jmp    80106bac <alltraps>

8010745a <vector65>:
.globl vector65
vector65:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $65
8010745c:	6a 41                	push   $0x41
  jmp alltraps
8010745e:	e9 49 f7 ff ff       	jmp    80106bac <alltraps>

80107463 <vector66>:
.globl vector66
vector66:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $66
80107465:	6a 42                	push   $0x42
  jmp alltraps
80107467:	e9 40 f7 ff ff       	jmp    80106bac <alltraps>

8010746c <vector67>:
.globl vector67
vector67:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $67
8010746e:	6a 43                	push   $0x43
  jmp alltraps
80107470:	e9 37 f7 ff ff       	jmp    80106bac <alltraps>

80107475 <vector68>:
.globl vector68
vector68:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $68
80107477:	6a 44                	push   $0x44
  jmp alltraps
80107479:	e9 2e f7 ff ff       	jmp    80106bac <alltraps>

8010747e <vector69>:
.globl vector69
vector69:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $69
80107480:	6a 45                	push   $0x45
  jmp alltraps
80107482:	e9 25 f7 ff ff       	jmp    80106bac <alltraps>

80107487 <vector70>:
.globl vector70
vector70:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $70
80107489:	6a 46                	push   $0x46
  jmp alltraps
8010748b:	e9 1c f7 ff ff       	jmp    80106bac <alltraps>

80107490 <vector71>:
.globl vector71
vector71:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $71
80107492:	6a 47                	push   $0x47
  jmp alltraps
80107494:	e9 13 f7 ff ff       	jmp    80106bac <alltraps>

80107499 <vector72>:
.globl vector72
vector72:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $72
8010749b:	6a 48                	push   $0x48
  jmp alltraps
8010749d:	e9 0a f7 ff ff       	jmp    80106bac <alltraps>

801074a2 <vector73>:
.globl vector73
vector73:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $73
801074a4:	6a 49                	push   $0x49
  jmp alltraps
801074a6:	e9 01 f7 ff ff       	jmp    80106bac <alltraps>

801074ab <vector74>:
.globl vector74
vector74:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $74
801074ad:	6a 4a                	push   $0x4a
  jmp alltraps
801074af:	e9 f8 f6 ff ff       	jmp    80106bac <alltraps>

801074b4 <vector75>:
.globl vector75
vector75:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $75
801074b6:	6a 4b                	push   $0x4b
  jmp alltraps
801074b8:	e9 ef f6 ff ff       	jmp    80106bac <alltraps>

801074bd <vector76>:
.globl vector76
vector76:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $76
801074bf:	6a 4c                	push   $0x4c
  jmp alltraps
801074c1:	e9 e6 f6 ff ff       	jmp    80106bac <alltraps>

801074c6 <vector77>:
.globl vector77
vector77:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $77
801074c8:	6a 4d                	push   $0x4d
  jmp alltraps
801074ca:	e9 dd f6 ff ff       	jmp    80106bac <alltraps>

801074cf <vector78>:
.globl vector78
vector78:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $78
801074d1:	6a 4e                	push   $0x4e
  jmp alltraps
801074d3:	e9 d4 f6 ff ff       	jmp    80106bac <alltraps>

801074d8 <vector79>:
.globl vector79
vector79:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $79
801074da:	6a 4f                	push   $0x4f
  jmp alltraps
801074dc:	e9 cb f6 ff ff       	jmp    80106bac <alltraps>

801074e1 <vector80>:
.globl vector80
vector80:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $80
801074e3:	6a 50                	push   $0x50
  jmp alltraps
801074e5:	e9 c2 f6 ff ff       	jmp    80106bac <alltraps>

801074ea <vector81>:
.globl vector81
vector81:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $81
801074ec:	6a 51                	push   $0x51
  jmp alltraps
801074ee:	e9 b9 f6 ff ff       	jmp    80106bac <alltraps>

801074f3 <vector82>:
.globl vector82
vector82:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $82
801074f5:	6a 52                	push   $0x52
  jmp alltraps
801074f7:	e9 b0 f6 ff ff       	jmp    80106bac <alltraps>

801074fc <vector83>:
.globl vector83
vector83:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $83
801074fe:	6a 53                	push   $0x53
  jmp alltraps
80107500:	e9 a7 f6 ff ff       	jmp    80106bac <alltraps>

80107505 <vector84>:
.globl vector84
vector84:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $84
80107507:	6a 54                	push   $0x54
  jmp alltraps
80107509:	e9 9e f6 ff ff       	jmp    80106bac <alltraps>

8010750e <vector85>:
.globl vector85
vector85:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $85
80107510:	6a 55                	push   $0x55
  jmp alltraps
80107512:	e9 95 f6 ff ff       	jmp    80106bac <alltraps>

80107517 <vector86>:
.globl vector86
vector86:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $86
80107519:	6a 56                	push   $0x56
  jmp alltraps
8010751b:	e9 8c f6 ff ff       	jmp    80106bac <alltraps>

80107520 <vector87>:
.globl vector87
vector87:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $87
80107522:	6a 57                	push   $0x57
  jmp alltraps
80107524:	e9 83 f6 ff ff       	jmp    80106bac <alltraps>

80107529 <vector88>:
.globl vector88
vector88:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $88
8010752b:	6a 58                	push   $0x58
  jmp alltraps
8010752d:	e9 7a f6 ff ff       	jmp    80106bac <alltraps>

80107532 <vector89>:
.globl vector89
vector89:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $89
80107534:	6a 59                	push   $0x59
  jmp alltraps
80107536:	e9 71 f6 ff ff       	jmp    80106bac <alltraps>

8010753b <vector90>:
.globl vector90
vector90:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $90
8010753d:	6a 5a                	push   $0x5a
  jmp alltraps
8010753f:	e9 68 f6 ff ff       	jmp    80106bac <alltraps>

80107544 <vector91>:
.globl vector91
vector91:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $91
80107546:	6a 5b                	push   $0x5b
  jmp alltraps
80107548:	e9 5f f6 ff ff       	jmp    80106bac <alltraps>

8010754d <vector92>:
.globl vector92
vector92:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $92
8010754f:	6a 5c                	push   $0x5c
  jmp alltraps
80107551:	e9 56 f6 ff ff       	jmp    80106bac <alltraps>

80107556 <vector93>:
.globl vector93
vector93:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $93
80107558:	6a 5d                	push   $0x5d
  jmp alltraps
8010755a:	e9 4d f6 ff ff       	jmp    80106bac <alltraps>

8010755f <vector94>:
.globl vector94
vector94:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $94
80107561:	6a 5e                	push   $0x5e
  jmp alltraps
80107563:	e9 44 f6 ff ff       	jmp    80106bac <alltraps>

80107568 <vector95>:
.globl vector95
vector95:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $95
8010756a:	6a 5f                	push   $0x5f
  jmp alltraps
8010756c:	e9 3b f6 ff ff       	jmp    80106bac <alltraps>

80107571 <vector96>:
.globl vector96
vector96:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $96
80107573:	6a 60                	push   $0x60
  jmp alltraps
80107575:	e9 32 f6 ff ff       	jmp    80106bac <alltraps>

8010757a <vector97>:
.globl vector97
vector97:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $97
8010757c:	6a 61                	push   $0x61
  jmp alltraps
8010757e:	e9 29 f6 ff ff       	jmp    80106bac <alltraps>

80107583 <vector98>:
.globl vector98
vector98:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $98
80107585:	6a 62                	push   $0x62
  jmp alltraps
80107587:	e9 20 f6 ff ff       	jmp    80106bac <alltraps>

8010758c <vector99>:
.globl vector99
vector99:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $99
8010758e:	6a 63                	push   $0x63
  jmp alltraps
80107590:	e9 17 f6 ff ff       	jmp    80106bac <alltraps>

80107595 <vector100>:
.globl vector100
vector100:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $100
80107597:	6a 64                	push   $0x64
  jmp alltraps
80107599:	e9 0e f6 ff ff       	jmp    80106bac <alltraps>

8010759e <vector101>:
.globl vector101
vector101:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $101
801075a0:	6a 65                	push   $0x65
  jmp alltraps
801075a2:	e9 05 f6 ff ff       	jmp    80106bac <alltraps>

801075a7 <vector102>:
.globl vector102
vector102:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $102
801075a9:	6a 66                	push   $0x66
  jmp alltraps
801075ab:	e9 fc f5 ff ff       	jmp    80106bac <alltraps>

801075b0 <vector103>:
.globl vector103
vector103:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $103
801075b2:	6a 67                	push   $0x67
  jmp alltraps
801075b4:	e9 f3 f5 ff ff       	jmp    80106bac <alltraps>

801075b9 <vector104>:
.globl vector104
vector104:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $104
801075bb:	6a 68                	push   $0x68
  jmp alltraps
801075bd:	e9 ea f5 ff ff       	jmp    80106bac <alltraps>

801075c2 <vector105>:
.globl vector105
vector105:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $105
801075c4:	6a 69                	push   $0x69
  jmp alltraps
801075c6:	e9 e1 f5 ff ff       	jmp    80106bac <alltraps>

801075cb <vector106>:
.globl vector106
vector106:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $106
801075cd:	6a 6a                	push   $0x6a
  jmp alltraps
801075cf:	e9 d8 f5 ff ff       	jmp    80106bac <alltraps>

801075d4 <vector107>:
.globl vector107
vector107:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $107
801075d6:	6a 6b                	push   $0x6b
  jmp alltraps
801075d8:	e9 cf f5 ff ff       	jmp    80106bac <alltraps>

801075dd <vector108>:
.globl vector108
vector108:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $108
801075df:	6a 6c                	push   $0x6c
  jmp alltraps
801075e1:	e9 c6 f5 ff ff       	jmp    80106bac <alltraps>

801075e6 <vector109>:
.globl vector109
vector109:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $109
801075e8:	6a 6d                	push   $0x6d
  jmp alltraps
801075ea:	e9 bd f5 ff ff       	jmp    80106bac <alltraps>

801075ef <vector110>:
.globl vector110
vector110:
  pushl $0
801075ef:	6a 00                	push   $0x0
  pushl $110
801075f1:	6a 6e                	push   $0x6e
  jmp alltraps
801075f3:	e9 b4 f5 ff ff       	jmp    80106bac <alltraps>

801075f8 <vector111>:
.globl vector111
vector111:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $111
801075fa:	6a 6f                	push   $0x6f
  jmp alltraps
801075fc:	e9 ab f5 ff ff       	jmp    80106bac <alltraps>

80107601 <vector112>:
.globl vector112
vector112:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $112
80107603:	6a 70                	push   $0x70
  jmp alltraps
80107605:	e9 a2 f5 ff ff       	jmp    80106bac <alltraps>

8010760a <vector113>:
.globl vector113
vector113:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $113
8010760c:	6a 71                	push   $0x71
  jmp alltraps
8010760e:	e9 99 f5 ff ff       	jmp    80106bac <alltraps>

80107613 <vector114>:
.globl vector114
vector114:
  pushl $0
80107613:	6a 00                	push   $0x0
  pushl $114
80107615:	6a 72                	push   $0x72
  jmp alltraps
80107617:	e9 90 f5 ff ff       	jmp    80106bac <alltraps>

8010761c <vector115>:
.globl vector115
vector115:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $115
8010761e:	6a 73                	push   $0x73
  jmp alltraps
80107620:	e9 87 f5 ff ff       	jmp    80106bac <alltraps>

80107625 <vector116>:
.globl vector116
vector116:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $116
80107627:	6a 74                	push   $0x74
  jmp alltraps
80107629:	e9 7e f5 ff ff       	jmp    80106bac <alltraps>

8010762e <vector117>:
.globl vector117
vector117:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $117
80107630:	6a 75                	push   $0x75
  jmp alltraps
80107632:	e9 75 f5 ff ff       	jmp    80106bac <alltraps>

80107637 <vector118>:
.globl vector118
vector118:
  pushl $0
80107637:	6a 00                	push   $0x0
  pushl $118
80107639:	6a 76                	push   $0x76
  jmp alltraps
8010763b:	e9 6c f5 ff ff       	jmp    80106bac <alltraps>

80107640 <vector119>:
.globl vector119
vector119:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $119
80107642:	6a 77                	push   $0x77
  jmp alltraps
80107644:	e9 63 f5 ff ff       	jmp    80106bac <alltraps>

80107649 <vector120>:
.globl vector120
vector120:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $120
8010764b:	6a 78                	push   $0x78
  jmp alltraps
8010764d:	e9 5a f5 ff ff       	jmp    80106bac <alltraps>

80107652 <vector121>:
.globl vector121
vector121:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $121
80107654:	6a 79                	push   $0x79
  jmp alltraps
80107656:	e9 51 f5 ff ff       	jmp    80106bac <alltraps>

8010765b <vector122>:
.globl vector122
vector122:
  pushl $0
8010765b:	6a 00                	push   $0x0
  pushl $122
8010765d:	6a 7a                	push   $0x7a
  jmp alltraps
8010765f:	e9 48 f5 ff ff       	jmp    80106bac <alltraps>

80107664 <vector123>:
.globl vector123
vector123:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $123
80107666:	6a 7b                	push   $0x7b
  jmp alltraps
80107668:	e9 3f f5 ff ff       	jmp    80106bac <alltraps>

8010766d <vector124>:
.globl vector124
vector124:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $124
8010766f:	6a 7c                	push   $0x7c
  jmp alltraps
80107671:	e9 36 f5 ff ff       	jmp    80106bac <alltraps>

80107676 <vector125>:
.globl vector125
vector125:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $125
80107678:	6a 7d                	push   $0x7d
  jmp alltraps
8010767a:	e9 2d f5 ff ff       	jmp    80106bac <alltraps>

8010767f <vector126>:
.globl vector126
vector126:
  pushl $0
8010767f:	6a 00                	push   $0x0
  pushl $126
80107681:	6a 7e                	push   $0x7e
  jmp alltraps
80107683:	e9 24 f5 ff ff       	jmp    80106bac <alltraps>

80107688 <vector127>:
.globl vector127
vector127:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $127
8010768a:	6a 7f                	push   $0x7f
  jmp alltraps
8010768c:	e9 1b f5 ff ff       	jmp    80106bac <alltraps>

80107691 <vector128>:
.globl vector128
vector128:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $128
80107693:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107698:	e9 0f f5 ff ff       	jmp    80106bac <alltraps>

8010769d <vector129>:
.globl vector129
vector129:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $129
8010769f:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801076a4:	e9 03 f5 ff ff       	jmp    80106bac <alltraps>

801076a9 <vector130>:
.globl vector130
vector130:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $130
801076ab:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801076b0:	e9 f7 f4 ff ff       	jmp    80106bac <alltraps>

801076b5 <vector131>:
.globl vector131
vector131:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $131
801076b7:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801076bc:	e9 eb f4 ff ff       	jmp    80106bac <alltraps>

801076c1 <vector132>:
.globl vector132
vector132:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $132
801076c3:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801076c8:	e9 df f4 ff ff       	jmp    80106bac <alltraps>

801076cd <vector133>:
.globl vector133
vector133:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $133
801076cf:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801076d4:	e9 d3 f4 ff ff       	jmp    80106bac <alltraps>

801076d9 <vector134>:
.globl vector134
vector134:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $134
801076db:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801076e0:	e9 c7 f4 ff ff       	jmp    80106bac <alltraps>

801076e5 <vector135>:
.globl vector135
vector135:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $135
801076e7:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801076ec:	e9 bb f4 ff ff       	jmp    80106bac <alltraps>

801076f1 <vector136>:
.globl vector136
vector136:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $136
801076f3:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801076f8:	e9 af f4 ff ff       	jmp    80106bac <alltraps>

801076fd <vector137>:
.globl vector137
vector137:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $137
801076ff:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107704:	e9 a3 f4 ff ff       	jmp    80106bac <alltraps>

80107709 <vector138>:
.globl vector138
vector138:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $138
8010770b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107710:	e9 97 f4 ff ff       	jmp    80106bac <alltraps>

80107715 <vector139>:
.globl vector139
vector139:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $139
80107717:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010771c:	e9 8b f4 ff ff       	jmp    80106bac <alltraps>

80107721 <vector140>:
.globl vector140
vector140:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $140
80107723:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107728:	e9 7f f4 ff ff       	jmp    80106bac <alltraps>

8010772d <vector141>:
.globl vector141
vector141:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $141
8010772f:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107734:	e9 73 f4 ff ff       	jmp    80106bac <alltraps>

80107739 <vector142>:
.globl vector142
vector142:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $142
8010773b:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107740:	e9 67 f4 ff ff       	jmp    80106bac <alltraps>

80107745 <vector143>:
.globl vector143
vector143:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $143
80107747:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010774c:	e9 5b f4 ff ff       	jmp    80106bac <alltraps>

80107751 <vector144>:
.globl vector144
vector144:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $144
80107753:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107758:	e9 4f f4 ff ff       	jmp    80106bac <alltraps>

8010775d <vector145>:
.globl vector145
vector145:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $145
8010775f:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107764:	e9 43 f4 ff ff       	jmp    80106bac <alltraps>

80107769 <vector146>:
.globl vector146
vector146:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $146
8010776b:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107770:	e9 37 f4 ff ff       	jmp    80106bac <alltraps>

80107775 <vector147>:
.globl vector147
vector147:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $147
80107777:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010777c:	e9 2b f4 ff ff       	jmp    80106bac <alltraps>

80107781 <vector148>:
.globl vector148
vector148:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $148
80107783:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107788:	e9 1f f4 ff ff       	jmp    80106bac <alltraps>

8010778d <vector149>:
.globl vector149
vector149:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $149
8010778f:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107794:	e9 13 f4 ff ff       	jmp    80106bac <alltraps>

80107799 <vector150>:
.globl vector150
vector150:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $150
8010779b:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801077a0:	e9 07 f4 ff ff       	jmp    80106bac <alltraps>

801077a5 <vector151>:
.globl vector151
vector151:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $151
801077a7:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801077ac:	e9 fb f3 ff ff       	jmp    80106bac <alltraps>

801077b1 <vector152>:
.globl vector152
vector152:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $152
801077b3:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801077b8:	e9 ef f3 ff ff       	jmp    80106bac <alltraps>

801077bd <vector153>:
.globl vector153
vector153:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $153
801077bf:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801077c4:	e9 e3 f3 ff ff       	jmp    80106bac <alltraps>

801077c9 <vector154>:
.globl vector154
vector154:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $154
801077cb:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801077d0:	e9 d7 f3 ff ff       	jmp    80106bac <alltraps>

801077d5 <vector155>:
.globl vector155
vector155:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $155
801077d7:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801077dc:	e9 cb f3 ff ff       	jmp    80106bac <alltraps>

801077e1 <vector156>:
.globl vector156
vector156:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $156
801077e3:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801077e8:	e9 bf f3 ff ff       	jmp    80106bac <alltraps>

801077ed <vector157>:
.globl vector157
vector157:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $157
801077ef:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801077f4:	e9 b3 f3 ff ff       	jmp    80106bac <alltraps>

801077f9 <vector158>:
.globl vector158
vector158:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $158
801077fb:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107800:	e9 a7 f3 ff ff       	jmp    80106bac <alltraps>

80107805 <vector159>:
.globl vector159
vector159:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $159
80107807:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010780c:	e9 9b f3 ff ff       	jmp    80106bac <alltraps>

80107811 <vector160>:
.globl vector160
vector160:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $160
80107813:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107818:	e9 8f f3 ff ff       	jmp    80106bac <alltraps>

8010781d <vector161>:
.globl vector161
vector161:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $161
8010781f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107824:	e9 83 f3 ff ff       	jmp    80106bac <alltraps>

80107829 <vector162>:
.globl vector162
vector162:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $162
8010782b:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107830:	e9 77 f3 ff ff       	jmp    80106bac <alltraps>

80107835 <vector163>:
.globl vector163
vector163:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $163
80107837:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010783c:	e9 6b f3 ff ff       	jmp    80106bac <alltraps>

80107841 <vector164>:
.globl vector164
vector164:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $164
80107843:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107848:	e9 5f f3 ff ff       	jmp    80106bac <alltraps>

8010784d <vector165>:
.globl vector165
vector165:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $165
8010784f:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107854:	e9 53 f3 ff ff       	jmp    80106bac <alltraps>

80107859 <vector166>:
.globl vector166
vector166:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $166
8010785b:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107860:	e9 47 f3 ff ff       	jmp    80106bac <alltraps>

80107865 <vector167>:
.globl vector167
vector167:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $167
80107867:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010786c:	e9 3b f3 ff ff       	jmp    80106bac <alltraps>

80107871 <vector168>:
.globl vector168
vector168:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $168
80107873:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107878:	e9 2f f3 ff ff       	jmp    80106bac <alltraps>

8010787d <vector169>:
.globl vector169
vector169:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $169
8010787f:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107884:	e9 23 f3 ff ff       	jmp    80106bac <alltraps>

80107889 <vector170>:
.globl vector170
vector170:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $170
8010788b:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107890:	e9 17 f3 ff ff       	jmp    80106bac <alltraps>

80107895 <vector171>:
.globl vector171
vector171:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $171
80107897:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010789c:	e9 0b f3 ff ff       	jmp    80106bac <alltraps>

801078a1 <vector172>:
.globl vector172
vector172:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $172
801078a3:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801078a8:	e9 ff f2 ff ff       	jmp    80106bac <alltraps>

801078ad <vector173>:
.globl vector173
vector173:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $173
801078af:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801078b4:	e9 f3 f2 ff ff       	jmp    80106bac <alltraps>

801078b9 <vector174>:
.globl vector174
vector174:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $174
801078bb:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801078c0:	e9 e7 f2 ff ff       	jmp    80106bac <alltraps>

801078c5 <vector175>:
.globl vector175
vector175:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $175
801078c7:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801078cc:	e9 db f2 ff ff       	jmp    80106bac <alltraps>

801078d1 <vector176>:
.globl vector176
vector176:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $176
801078d3:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801078d8:	e9 cf f2 ff ff       	jmp    80106bac <alltraps>

801078dd <vector177>:
.globl vector177
vector177:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $177
801078df:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801078e4:	e9 c3 f2 ff ff       	jmp    80106bac <alltraps>

801078e9 <vector178>:
.globl vector178
vector178:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $178
801078eb:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801078f0:	e9 b7 f2 ff ff       	jmp    80106bac <alltraps>

801078f5 <vector179>:
.globl vector179
vector179:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $179
801078f7:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801078fc:	e9 ab f2 ff ff       	jmp    80106bac <alltraps>

80107901 <vector180>:
.globl vector180
vector180:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $180
80107903:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107908:	e9 9f f2 ff ff       	jmp    80106bac <alltraps>

8010790d <vector181>:
.globl vector181
vector181:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $181
8010790f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107914:	e9 93 f2 ff ff       	jmp    80106bac <alltraps>

80107919 <vector182>:
.globl vector182
vector182:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $182
8010791b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107920:	e9 87 f2 ff ff       	jmp    80106bac <alltraps>

80107925 <vector183>:
.globl vector183
vector183:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $183
80107927:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010792c:	e9 7b f2 ff ff       	jmp    80106bac <alltraps>

80107931 <vector184>:
.globl vector184
vector184:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $184
80107933:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107938:	e9 6f f2 ff ff       	jmp    80106bac <alltraps>

8010793d <vector185>:
.globl vector185
vector185:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $185
8010793f:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107944:	e9 63 f2 ff ff       	jmp    80106bac <alltraps>

80107949 <vector186>:
.globl vector186
vector186:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $186
8010794b:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107950:	e9 57 f2 ff ff       	jmp    80106bac <alltraps>

80107955 <vector187>:
.globl vector187
vector187:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $187
80107957:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010795c:	e9 4b f2 ff ff       	jmp    80106bac <alltraps>

80107961 <vector188>:
.globl vector188
vector188:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $188
80107963:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107968:	e9 3f f2 ff ff       	jmp    80106bac <alltraps>

8010796d <vector189>:
.globl vector189
vector189:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $189
8010796f:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107974:	e9 33 f2 ff ff       	jmp    80106bac <alltraps>

80107979 <vector190>:
.globl vector190
vector190:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $190
8010797b:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107980:	e9 27 f2 ff ff       	jmp    80106bac <alltraps>

80107985 <vector191>:
.globl vector191
vector191:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $191
80107987:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010798c:	e9 1b f2 ff ff       	jmp    80106bac <alltraps>

80107991 <vector192>:
.globl vector192
vector192:
  pushl $0
80107991:	6a 00                	push   $0x0
  pushl $192
80107993:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107998:	e9 0f f2 ff ff       	jmp    80106bac <alltraps>

8010799d <vector193>:
.globl vector193
vector193:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $193
8010799f:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801079a4:	e9 03 f2 ff ff       	jmp    80106bac <alltraps>

801079a9 <vector194>:
.globl vector194
vector194:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $194
801079ab:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801079b0:	e9 f7 f1 ff ff       	jmp    80106bac <alltraps>

801079b5 <vector195>:
.globl vector195
vector195:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $195
801079b7:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801079bc:	e9 eb f1 ff ff       	jmp    80106bac <alltraps>

801079c1 <vector196>:
.globl vector196
vector196:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $196
801079c3:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801079c8:	e9 df f1 ff ff       	jmp    80106bac <alltraps>

801079cd <vector197>:
.globl vector197
vector197:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $197
801079cf:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801079d4:	e9 d3 f1 ff ff       	jmp    80106bac <alltraps>

801079d9 <vector198>:
.globl vector198
vector198:
  pushl $0
801079d9:	6a 00                	push   $0x0
  pushl $198
801079db:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801079e0:	e9 c7 f1 ff ff       	jmp    80106bac <alltraps>

801079e5 <vector199>:
.globl vector199
vector199:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $199
801079e7:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801079ec:	e9 bb f1 ff ff       	jmp    80106bac <alltraps>

801079f1 <vector200>:
.globl vector200
vector200:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $200
801079f3:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801079f8:	e9 af f1 ff ff       	jmp    80106bac <alltraps>

801079fd <vector201>:
.globl vector201
vector201:
  pushl $0
801079fd:	6a 00                	push   $0x0
  pushl $201
801079ff:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107a04:	e9 a3 f1 ff ff       	jmp    80106bac <alltraps>

80107a09 <vector202>:
.globl vector202
vector202:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $202
80107a0b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107a10:	e9 97 f1 ff ff       	jmp    80106bac <alltraps>

80107a15 <vector203>:
.globl vector203
vector203:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $203
80107a17:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107a1c:	e9 8b f1 ff ff       	jmp    80106bac <alltraps>

80107a21 <vector204>:
.globl vector204
vector204:
  pushl $0
80107a21:	6a 00                	push   $0x0
  pushl $204
80107a23:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107a28:	e9 7f f1 ff ff       	jmp    80106bac <alltraps>

80107a2d <vector205>:
.globl vector205
vector205:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $205
80107a2f:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107a34:	e9 73 f1 ff ff       	jmp    80106bac <alltraps>

80107a39 <vector206>:
.globl vector206
vector206:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $206
80107a3b:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107a40:	e9 67 f1 ff ff       	jmp    80106bac <alltraps>

80107a45 <vector207>:
.globl vector207
vector207:
  pushl $0
80107a45:	6a 00                	push   $0x0
  pushl $207
80107a47:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107a4c:	e9 5b f1 ff ff       	jmp    80106bac <alltraps>

80107a51 <vector208>:
.globl vector208
vector208:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $208
80107a53:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107a58:	e9 4f f1 ff ff       	jmp    80106bac <alltraps>

80107a5d <vector209>:
.globl vector209
vector209:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $209
80107a5f:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107a64:	e9 43 f1 ff ff       	jmp    80106bac <alltraps>

80107a69 <vector210>:
.globl vector210
vector210:
  pushl $0
80107a69:	6a 00                	push   $0x0
  pushl $210
80107a6b:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107a70:	e9 37 f1 ff ff       	jmp    80106bac <alltraps>

80107a75 <vector211>:
.globl vector211
vector211:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $211
80107a77:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107a7c:	e9 2b f1 ff ff       	jmp    80106bac <alltraps>

80107a81 <vector212>:
.globl vector212
vector212:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $212
80107a83:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107a88:	e9 1f f1 ff ff       	jmp    80106bac <alltraps>

80107a8d <vector213>:
.globl vector213
vector213:
  pushl $0
80107a8d:	6a 00                	push   $0x0
  pushl $213
80107a8f:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107a94:	e9 13 f1 ff ff       	jmp    80106bac <alltraps>

80107a99 <vector214>:
.globl vector214
vector214:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $214
80107a9b:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107aa0:	e9 07 f1 ff ff       	jmp    80106bac <alltraps>

80107aa5 <vector215>:
.globl vector215
vector215:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $215
80107aa7:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107aac:	e9 fb f0 ff ff       	jmp    80106bac <alltraps>

80107ab1 <vector216>:
.globl vector216
vector216:
  pushl $0
80107ab1:	6a 00                	push   $0x0
  pushl $216
80107ab3:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107ab8:	e9 ef f0 ff ff       	jmp    80106bac <alltraps>

80107abd <vector217>:
.globl vector217
vector217:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $217
80107abf:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107ac4:	e9 e3 f0 ff ff       	jmp    80106bac <alltraps>

80107ac9 <vector218>:
.globl vector218
vector218:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $218
80107acb:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107ad0:	e9 d7 f0 ff ff       	jmp    80106bac <alltraps>

80107ad5 <vector219>:
.globl vector219
vector219:
  pushl $0
80107ad5:	6a 00                	push   $0x0
  pushl $219
80107ad7:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107adc:	e9 cb f0 ff ff       	jmp    80106bac <alltraps>

80107ae1 <vector220>:
.globl vector220
vector220:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $220
80107ae3:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107ae8:	e9 bf f0 ff ff       	jmp    80106bac <alltraps>

80107aed <vector221>:
.globl vector221
vector221:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $221
80107aef:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107af4:	e9 b3 f0 ff ff       	jmp    80106bac <alltraps>

80107af9 <vector222>:
.globl vector222
vector222:
  pushl $0
80107af9:	6a 00                	push   $0x0
  pushl $222
80107afb:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107b00:	e9 a7 f0 ff ff       	jmp    80106bac <alltraps>

80107b05 <vector223>:
.globl vector223
vector223:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $223
80107b07:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107b0c:	e9 9b f0 ff ff       	jmp    80106bac <alltraps>

80107b11 <vector224>:
.globl vector224
vector224:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $224
80107b13:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107b18:	e9 8f f0 ff ff       	jmp    80106bac <alltraps>

80107b1d <vector225>:
.globl vector225
vector225:
  pushl $0
80107b1d:	6a 00                	push   $0x0
  pushl $225
80107b1f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107b24:	e9 83 f0 ff ff       	jmp    80106bac <alltraps>

80107b29 <vector226>:
.globl vector226
vector226:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $226
80107b2b:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107b30:	e9 77 f0 ff ff       	jmp    80106bac <alltraps>

80107b35 <vector227>:
.globl vector227
vector227:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $227
80107b37:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107b3c:	e9 6b f0 ff ff       	jmp    80106bac <alltraps>

80107b41 <vector228>:
.globl vector228
vector228:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $228
80107b43:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107b48:	e9 5f f0 ff ff       	jmp    80106bac <alltraps>

80107b4d <vector229>:
.globl vector229
vector229:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $229
80107b4f:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107b54:	e9 53 f0 ff ff       	jmp    80106bac <alltraps>

80107b59 <vector230>:
.globl vector230
vector230:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $230
80107b5b:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107b60:	e9 47 f0 ff ff       	jmp    80106bac <alltraps>

80107b65 <vector231>:
.globl vector231
vector231:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $231
80107b67:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107b6c:	e9 3b f0 ff ff       	jmp    80106bac <alltraps>

80107b71 <vector232>:
.globl vector232
vector232:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $232
80107b73:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107b78:	e9 2f f0 ff ff       	jmp    80106bac <alltraps>

80107b7d <vector233>:
.globl vector233
vector233:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $233
80107b7f:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107b84:	e9 23 f0 ff ff       	jmp    80106bac <alltraps>

80107b89 <vector234>:
.globl vector234
vector234:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $234
80107b8b:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107b90:	e9 17 f0 ff ff       	jmp    80106bac <alltraps>

80107b95 <vector235>:
.globl vector235
vector235:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $235
80107b97:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107b9c:	e9 0b f0 ff ff       	jmp    80106bac <alltraps>

80107ba1 <vector236>:
.globl vector236
vector236:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $236
80107ba3:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107ba8:	e9 ff ef ff ff       	jmp    80106bac <alltraps>

80107bad <vector237>:
.globl vector237
vector237:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $237
80107baf:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107bb4:	e9 f3 ef ff ff       	jmp    80106bac <alltraps>

80107bb9 <vector238>:
.globl vector238
vector238:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $238
80107bbb:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107bc0:	e9 e7 ef ff ff       	jmp    80106bac <alltraps>

80107bc5 <vector239>:
.globl vector239
vector239:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $239
80107bc7:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107bcc:	e9 db ef ff ff       	jmp    80106bac <alltraps>

80107bd1 <vector240>:
.globl vector240
vector240:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $240
80107bd3:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107bd8:	e9 cf ef ff ff       	jmp    80106bac <alltraps>

80107bdd <vector241>:
.globl vector241
vector241:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $241
80107bdf:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107be4:	e9 c3 ef ff ff       	jmp    80106bac <alltraps>

80107be9 <vector242>:
.globl vector242
vector242:
  pushl $0
80107be9:	6a 00                	push   $0x0
  pushl $242
80107beb:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107bf0:	e9 b7 ef ff ff       	jmp    80106bac <alltraps>

80107bf5 <vector243>:
.globl vector243
vector243:
  pushl $0
80107bf5:	6a 00                	push   $0x0
  pushl $243
80107bf7:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107bfc:	e9 ab ef ff ff       	jmp    80106bac <alltraps>

80107c01 <vector244>:
.globl vector244
vector244:
  pushl $0
80107c01:	6a 00                	push   $0x0
  pushl $244
80107c03:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107c08:	e9 9f ef ff ff       	jmp    80106bac <alltraps>

80107c0d <vector245>:
.globl vector245
vector245:
  pushl $0
80107c0d:	6a 00                	push   $0x0
  pushl $245
80107c0f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107c14:	e9 93 ef ff ff       	jmp    80106bac <alltraps>

80107c19 <vector246>:
.globl vector246
vector246:
  pushl $0
80107c19:	6a 00                	push   $0x0
  pushl $246
80107c1b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107c20:	e9 87 ef ff ff       	jmp    80106bac <alltraps>

80107c25 <vector247>:
.globl vector247
vector247:
  pushl $0
80107c25:	6a 00                	push   $0x0
  pushl $247
80107c27:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107c2c:	e9 7b ef ff ff       	jmp    80106bac <alltraps>

80107c31 <vector248>:
.globl vector248
vector248:
  pushl $0
80107c31:	6a 00                	push   $0x0
  pushl $248
80107c33:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107c38:	e9 6f ef ff ff       	jmp    80106bac <alltraps>

80107c3d <vector249>:
.globl vector249
vector249:
  pushl $0
80107c3d:	6a 00                	push   $0x0
  pushl $249
80107c3f:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107c44:	e9 63 ef ff ff       	jmp    80106bac <alltraps>

80107c49 <vector250>:
.globl vector250
vector250:
  pushl $0
80107c49:	6a 00                	push   $0x0
  pushl $250
80107c4b:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107c50:	e9 57 ef ff ff       	jmp    80106bac <alltraps>

80107c55 <vector251>:
.globl vector251
vector251:
  pushl $0
80107c55:	6a 00                	push   $0x0
  pushl $251
80107c57:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107c5c:	e9 4b ef ff ff       	jmp    80106bac <alltraps>

80107c61 <vector252>:
.globl vector252
vector252:
  pushl $0
80107c61:	6a 00                	push   $0x0
  pushl $252
80107c63:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107c68:	e9 3f ef ff ff       	jmp    80106bac <alltraps>

80107c6d <vector253>:
.globl vector253
vector253:
  pushl $0
80107c6d:	6a 00                	push   $0x0
  pushl $253
80107c6f:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107c74:	e9 33 ef ff ff       	jmp    80106bac <alltraps>

80107c79 <vector254>:
.globl vector254
vector254:
  pushl $0
80107c79:	6a 00                	push   $0x0
  pushl $254
80107c7b:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107c80:	e9 27 ef ff ff       	jmp    80106bac <alltraps>

80107c85 <vector255>:
.globl vector255
vector255:
  pushl $0
80107c85:	6a 00                	push   $0x0
  pushl $255
80107c87:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107c8c:	e9 1b ef ff ff       	jmp    80106bac <alltraps>

80107c91 <lgdt>:
{
80107c91:	55                   	push   %ebp
80107c92:	89 e5                	mov    %esp,%ebp
80107c94:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107c97:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c9a:	83 e8 01             	sub    $0x1,%eax
80107c9d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107ca8:	8b 45 08             	mov    0x8(%ebp),%eax
80107cab:	c1 e8 10             	shr    $0x10,%eax
80107cae:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107cb2:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107cb5:	0f 01 10             	lgdtl  (%eax)
}
80107cb8:	90                   	nop
80107cb9:	c9                   	leave  
80107cba:	c3                   	ret    

80107cbb <ltr>:
{
80107cbb:	55                   	push   %ebp
80107cbc:	89 e5                	mov    %esp,%ebp
80107cbe:	83 ec 04             	sub    $0x4,%esp
80107cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80107cc4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107cc8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107ccc:	0f 00 d8             	ltr    %ax
}
80107ccf:	90                   	nop
80107cd0:	c9                   	leave  
80107cd1:	c3                   	ret    

80107cd2 <lcr3>:

static inline void
lcr3(uint val)
{
80107cd2:	55                   	push   %ebp
80107cd3:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80107cd8:	0f 22 d8             	mov    %eax,%cr3
}
80107cdb:	90                   	nop
80107cdc:	5d                   	pop    %ebp
80107cdd:	c3                   	ret    

80107cde <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107cde:	f3 0f 1e fb          	endbr32 
80107ce2:	55                   	push   %ebp
80107ce3:	89 e5                	mov    %esp,%ebp
80107ce5:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107ce8:	e8 a9 c6 ff ff       	call   80104396 <cpuid>
80107ced:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80107cf3:	05 00 48 11 80       	add    $0x80114800,%eax
80107cf8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d07:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d10:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d17:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d1b:	83 e2 f0             	and    $0xfffffff0,%edx
80107d1e:	83 ca 0a             	or     $0xa,%edx
80107d21:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d27:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d2b:	83 ca 10             	or     $0x10,%edx
80107d2e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d34:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d38:	83 e2 9f             	and    $0xffffff9f,%edx
80107d3b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d41:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107d45:	83 ca 80             	or     $0xffffff80,%edx
80107d48:	88 50 7d             	mov    %dl,0x7d(%eax)
80107d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d52:	83 ca 0f             	or     $0xf,%edx
80107d55:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d5f:	83 e2 ef             	and    $0xffffffef,%edx
80107d62:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d68:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d6c:	83 e2 df             	and    $0xffffffdf,%edx
80107d6f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d75:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d79:	83 ca 40             	or     $0x40,%edx
80107d7c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d82:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107d86:	83 ca 80             	or     $0xffffff80,%edx
80107d89:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d96:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d9d:	ff ff 
80107d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da2:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107da9:	00 00 
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dbf:	83 e2 f0             	and    $0xfffffff0,%edx
80107dc2:	83 ca 02             	or     $0x2,%edx
80107dc5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dce:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dd5:	83 ca 10             	or     $0x10,%edx
80107dd8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107de8:	83 e2 9f             	and    $0xffffff9f,%edx
80107deb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107dfb:	83 ca 80             	or     $0xffffff80,%edx
80107dfe:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e07:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e0e:	83 ca 0f             	or     $0xf,%edx
80107e11:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1a:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e21:	83 e2 ef             	and    $0xffffffef,%edx
80107e24:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e34:	83 e2 df             	and    $0xffffffdf,%edx
80107e37:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e40:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e47:	83 ca 40             	or     $0x40,%edx
80107e4a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e53:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107e5a:	83 ca 80             	or     $0xffffff80,%edx
80107e5d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e66:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107e77:	ff ff 
80107e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7c:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107e83:	00 00 
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e92:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107e99:	83 e2 f0             	and    $0xfffffff0,%edx
80107e9c:	83 ca 0a             	or     $0xa,%edx
80107e9f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea8:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107eaf:	83 ca 10             	or     $0x10,%edx
80107eb2:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebb:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ec2:	83 ca 60             	or     $0x60,%edx
80107ec5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ece:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ed5:	83 ca 80             	or     $0xffffff80,%edx
80107ed8:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ee8:	83 ca 0f             	or     $0xf,%edx
80107eeb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107efb:	83 e2 ef             	and    $0xffffffef,%edx
80107efe:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f07:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f0e:	83 e2 df             	and    $0xffffffdf,%edx
80107f11:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f21:	83 ca 40             	or     $0x40,%edx
80107f24:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f2d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107f34:	83 ca 80             	or     $0xffffff80,%edx
80107f37:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f40:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107f51:	ff ff 
80107f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f56:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107f5d:	00 00 
80107f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f62:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f73:	83 e2 f0             	and    $0xfffffff0,%edx
80107f76:	83 ca 02             	or     $0x2,%edx
80107f79:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f82:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f89:	83 ca 10             	or     $0x10,%edx
80107f8c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f95:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107f9c:	83 ca 60             	or     $0x60,%edx
80107f9f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa8:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107faf:	83 ca 80             	or     $0xffffff80,%edx
80107fb2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fc2:	83 ca 0f             	or     $0xf,%edx
80107fc5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fce:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fd5:	83 e2 ef             	and    $0xffffffef,%edx
80107fd8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107fe8:	83 e2 df             	and    $0xffffffdf,%edx
80107feb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ffb:	83 ca 40             	or     $0x40,%edx
80107ffe:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108007:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010800e:	83 ca 80             	or     $0xffffff80,%edx
80108011:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801a:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108024:	83 c0 70             	add    $0x70,%eax
80108027:	83 ec 08             	sub    $0x8,%esp
8010802a:	6a 30                	push   $0x30
8010802c:	50                   	push   %eax
8010802d:	e8 5f fc ff ff       	call   80107c91 <lgdt>
80108032:	83 c4 10             	add    $0x10,%esp
}
80108035:	90                   	nop
80108036:	c9                   	leave  
80108037:	c3                   	ret    

80108038 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108038:	f3 0f 1e fb          	endbr32 
8010803c:	55                   	push   %ebp
8010803d:	89 e5                	mov    %esp,%ebp
8010803f:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108042:	8b 45 0c             	mov    0xc(%ebp),%eax
80108045:	c1 e8 16             	shr    $0x16,%eax
80108048:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010804f:	8b 45 08             	mov    0x8(%ebp),%eax
80108052:	01 d0                	add    %edx,%eax
80108054:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010805a:	8b 00                	mov    (%eax),%eax
8010805c:	83 e0 01             	and    $0x1,%eax
8010805f:	85 c0                	test   %eax,%eax
80108061:	74 14                	je     80108077 <walkpgdir+0x3f>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108063:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108066:	8b 00                	mov    (%eax),%eax
80108068:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010806d:	05 00 00 00 80       	add    $0x80000000,%eax
80108072:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108075:	eb 42                	jmp    801080b9 <walkpgdir+0x81>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108077:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010807b:	74 0e                	je     8010808b <walkpgdir+0x53>
8010807d:	e8 12 ad ff ff       	call   80102d94 <kalloc>
80108082:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108085:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108089:	75 07                	jne    80108092 <walkpgdir+0x5a>
      return 0;
8010808b:	b8 00 00 00 00       	mov    $0x0,%eax
80108090:	eb 3e                	jmp    801080d0 <walkpgdir+0x98>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108092:	83 ec 04             	sub    $0x4,%esp
80108095:	68 00 10 00 00       	push   $0x1000
8010809a:	6a 00                	push   $0x0
8010809c:	ff 75 f4             	pushl  -0xc(%ebp)
8010809f:	e8 a1 d6 ff ff       	call   80105745 <memset>
801080a4:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801080a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080aa:	05 00 00 00 80       	add    $0x80000000,%eax
801080af:	83 c8 07             	or     $0x7,%eax
801080b2:	89 c2                	mov    %eax,%edx
801080b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080b7:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801080b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801080bc:	c1 e8 0c             	shr    $0xc,%eax
801080bf:	25 ff 03 00 00       	and    $0x3ff,%eax
801080c4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ce:	01 d0                	add    %edx,%eax
}
801080d0:	c9                   	leave  
801080d1:	c3                   	ret    

801080d2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801080d2:	f3 0f 1e fb          	endbr32 
801080d6:	55                   	push   %ebp
801080d7:	89 e5                	mov    %esp,%ebp
801080d9:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801080dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801080df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801080e7:	8b 55 0c             	mov    0xc(%ebp),%edx
801080ea:	8b 45 10             	mov    0x10(%ebp),%eax
801080ed:	01 d0                	add    %edx,%eax
801080ef:	83 e8 01             	sub    $0x1,%eax
801080f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801080f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801080fa:	83 ec 04             	sub    $0x4,%esp
801080fd:	6a 01                	push   $0x1
801080ff:	ff 75 f4             	pushl  -0xc(%ebp)
80108102:	ff 75 08             	pushl  0x8(%ebp)
80108105:	e8 2e ff ff ff       	call   80108038 <walkpgdir>
8010810a:	83 c4 10             	add    $0x10,%esp
8010810d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108110:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108114:	75 07                	jne    8010811d <mappages+0x4b>
      return -1;
80108116:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010811b:	eb 47                	jmp    80108164 <mappages+0x92>
    if(*pte & PTE_P)
8010811d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108120:	8b 00                	mov    (%eax),%eax
80108122:	83 e0 01             	and    $0x1,%eax
80108125:	85 c0                	test   %eax,%eax
80108127:	74 0d                	je     80108136 <mappages+0x64>
      panic("remap");
80108129:	83 ec 0c             	sub    $0xc,%esp
8010812c:	68 24 90 10 80       	push   $0x80109024
80108131:	e8 9b 84 ff ff       	call   801005d1 <panic>
    *pte = pa | perm | PTE_P;
80108136:	8b 45 18             	mov    0x18(%ebp),%eax
80108139:	0b 45 14             	or     0x14(%ebp),%eax
8010813c:	83 c8 01             	or     $0x1,%eax
8010813f:	89 c2                	mov    %eax,%edx
80108141:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108144:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108149:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010814c:	74 10                	je     8010815e <mappages+0x8c>
      break;
    a += PGSIZE;
8010814e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108155:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010815c:	eb 9c                	jmp    801080fa <mappages+0x28>
      break;
8010815e:	90                   	nop
  }
  return 0;
8010815f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108164:	c9                   	leave  
80108165:	c3                   	ret    

80108166 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108166:	f3 0f 1e fb          	endbr32 
8010816a:	55                   	push   %ebp
8010816b:	89 e5                	mov    %esp,%ebp
8010816d:	53                   	push   %ebx
8010816e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108171:	e8 1e ac ff ff       	call   80102d94 <kalloc>
80108176:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108179:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010817d:	75 07                	jne    80108186 <setupkvm+0x20>
    return 0;
8010817f:	b8 00 00 00 00       	mov    $0x0,%eax
80108184:	eb 78                	jmp    801081fe <setupkvm+0x98>
  memset(pgdir, 0, PGSIZE);
80108186:	83 ec 04             	sub    $0x4,%esp
80108189:	68 00 10 00 00       	push   $0x1000
8010818e:	6a 00                	push   $0x0
80108190:	ff 75 f0             	pushl  -0x10(%ebp)
80108193:	e8 ad d5 ff ff       	call   80105745 <memset>
80108198:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010819b:	c7 45 f4 80 c4 10 80 	movl   $0x8010c480,-0xc(%ebp)
801081a2:	eb 4e                	jmp    801081f2 <setupkvm+0x8c>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a7:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
801081aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ad:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801081b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b3:	8b 58 08             	mov    0x8(%eax),%ebx
801081b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b9:	8b 40 04             	mov    0x4(%eax),%eax
801081bc:	29 c3                	sub    %eax,%ebx
801081be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c1:	8b 00                	mov    (%eax),%eax
801081c3:	83 ec 0c             	sub    $0xc,%esp
801081c6:	51                   	push   %ecx
801081c7:	52                   	push   %edx
801081c8:	53                   	push   %ebx
801081c9:	50                   	push   %eax
801081ca:	ff 75 f0             	pushl  -0x10(%ebp)
801081cd:	e8 00 ff ff ff       	call   801080d2 <mappages>
801081d2:	83 c4 20             	add    $0x20,%esp
801081d5:	85 c0                	test   %eax,%eax
801081d7:	79 15                	jns    801081ee <setupkvm+0x88>
      freevm(pgdir);
801081d9:	83 ec 0c             	sub    $0xc,%esp
801081dc:	ff 75 f0             	pushl  -0x10(%ebp)
801081df:	e8 11 05 00 00       	call   801086f5 <freevm>
801081e4:	83 c4 10             	add    $0x10,%esp
      return 0;
801081e7:	b8 00 00 00 00       	mov    $0x0,%eax
801081ec:	eb 10                	jmp    801081fe <setupkvm+0x98>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801081ee:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801081f2:	81 7d f4 c0 c4 10 80 	cmpl   $0x8010c4c0,-0xc(%ebp)
801081f9:	72 a9                	jb     801081a4 <setupkvm+0x3e>
    }
  return pgdir;
801081fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801081fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108201:	c9                   	leave  
80108202:	c3                   	ret    

80108203 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108203:	f3 0f 1e fb          	endbr32 
80108207:	55                   	push   %ebp
80108208:	89 e5                	mov    %esp,%ebp
8010820a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010820d:	e8 54 ff ff ff       	call   80108166 <setupkvm>
80108212:	a3 44 73 11 80       	mov    %eax,0x80117344
  switchkvm();
80108217:	e8 03 00 00 00       	call   8010821f <switchkvm>
}
8010821c:	90                   	nop
8010821d:	c9                   	leave  
8010821e:	c3                   	ret    

8010821f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010821f:	f3 0f 1e fb          	endbr32 
80108223:	55                   	push   %ebp
80108224:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108226:	a1 44 73 11 80       	mov    0x80117344,%eax
8010822b:	05 00 00 00 80       	add    $0x80000000,%eax
80108230:	50                   	push   %eax
80108231:	e8 9c fa ff ff       	call   80107cd2 <lcr3>
80108236:	83 c4 04             	add    $0x4,%esp
}
80108239:	90                   	nop
8010823a:	c9                   	leave  
8010823b:	c3                   	ret    

8010823c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010823c:	f3 0f 1e fb          	endbr32 
80108240:	55                   	push   %ebp
80108241:	89 e5                	mov    %esp,%ebp
80108243:	56                   	push   %esi
80108244:	53                   	push   %ebx
80108245:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
80108248:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010824c:	75 0d                	jne    8010825b <switchuvm+0x1f>
    panic("switchuvm: no process");
8010824e:	83 ec 0c             	sub    $0xc,%esp
80108251:	68 2a 90 10 80       	push   $0x8010902a
80108256:	e8 76 83 ff ff       	call   801005d1 <panic>
  if(p->kstack == 0)
8010825b:	8b 45 08             	mov    0x8(%ebp),%eax
8010825e:	8b 40 08             	mov    0x8(%eax),%eax
80108261:	85 c0                	test   %eax,%eax
80108263:	75 0d                	jne    80108272 <switchuvm+0x36>
    panic("switchuvm: no kstack");
80108265:	83 ec 0c             	sub    $0xc,%esp
80108268:	68 40 90 10 80       	push   $0x80109040
8010826d:	e8 5f 83 ff ff       	call   801005d1 <panic>
  if(p->pgdir == 0)
80108272:	8b 45 08             	mov    0x8(%ebp),%eax
80108275:	8b 40 04             	mov    0x4(%eax),%eax
80108278:	85 c0                	test   %eax,%eax
8010827a:	75 0d                	jne    80108289 <switchuvm+0x4d>
    panic("switchuvm: no pgdir");
8010827c:	83 ec 0c             	sub    $0xc,%esp
8010827f:	68 55 90 10 80       	push   $0x80109055
80108284:	e8 48 83 ff ff       	call   801005d1 <panic>

  pushcli();
80108289:	e8 a4 d3 ff ff       	call   80105632 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010828e:	e8 22 c1 ff ff       	call   801043b5 <mycpu>
80108293:	89 c3                	mov    %eax,%ebx
80108295:	e8 1b c1 ff ff       	call   801043b5 <mycpu>
8010829a:	83 c0 08             	add    $0x8,%eax
8010829d:	89 c6                	mov    %eax,%esi
8010829f:	e8 11 c1 ff ff       	call   801043b5 <mycpu>
801082a4:	83 c0 08             	add    $0x8,%eax
801082a7:	c1 e8 10             	shr    $0x10,%eax
801082aa:	88 45 f7             	mov    %al,-0x9(%ebp)
801082ad:	e8 03 c1 ff ff       	call   801043b5 <mycpu>
801082b2:	83 c0 08             	add    $0x8,%eax
801082b5:	c1 e8 18             	shr    $0x18,%eax
801082b8:	89 c2                	mov    %eax,%edx
801082ba:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801082c1:	67 00 
801082c3:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801082ca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801082ce:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801082d4:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801082db:	83 e0 f0             	and    $0xfffffff0,%eax
801082de:	83 c8 09             	or     $0x9,%eax
801082e1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801082e7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801082ee:	83 c8 10             	or     $0x10,%eax
801082f1:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801082f7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801082fe:	83 e0 9f             	and    $0xffffff9f,%eax
80108301:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108307:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
8010830e:	83 c8 80             	or     $0xffffff80,%eax
80108311:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
80108317:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010831e:	83 e0 f0             	and    $0xfffffff0,%eax
80108321:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108327:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010832e:	83 e0 ef             	and    $0xffffffef,%eax
80108331:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108337:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010833e:	83 e0 df             	and    $0xffffffdf,%eax
80108341:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108347:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010834e:	83 c8 40             	or     $0x40,%eax
80108351:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108357:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
8010835e:	83 e0 7f             	and    $0x7f,%eax
80108361:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80108367:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010836d:	e8 43 c0 ff ff       	call   801043b5 <mycpu>
80108372:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108379:	83 e2 ef             	and    $0xffffffef,%edx
8010837c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108382:	e8 2e c0 ff ff       	call   801043b5 <mycpu>
80108387:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010838d:	8b 45 08             	mov    0x8(%ebp),%eax
80108390:	8b 40 08             	mov    0x8(%eax),%eax
80108393:	89 c3                	mov    %eax,%ebx
80108395:	e8 1b c0 ff ff       	call   801043b5 <mycpu>
8010839a:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
801083a0:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801083a3:	e8 0d c0 ff ff       	call   801043b5 <mycpu>
801083a8:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801083ae:	83 ec 0c             	sub    $0xc,%esp
801083b1:	6a 28                	push   $0x28
801083b3:	e8 03 f9 ff ff       	call   80107cbb <ltr>
801083b8:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
801083bb:	8b 45 08             	mov    0x8(%ebp),%eax
801083be:	8b 40 04             	mov    0x4(%eax),%eax
801083c1:	05 00 00 00 80       	add    $0x80000000,%eax
801083c6:	83 ec 0c             	sub    $0xc,%esp
801083c9:	50                   	push   %eax
801083ca:	e8 03 f9 ff ff       	call   80107cd2 <lcr3>
801083cf:	83 c4 10             	add    $0x10,%esp
  popcli();
801083d2:	e8 ac d2 ff ff       	call   80105683 <popcli>
}
801083d7:	90                   	nop
801083d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801083db:	5b                   	pop    %ebx
801083dc:	5e                   	pop    %esi
801083dd:	5d                   	pop    %ebp
801083de:	c3                   	ret    

801083df <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801083df:	f3 0f 1e fb          	endbr32 
801083e3:	55                   	push   %ebp
801083e4:	89 e5                	mov    %esp,%ebp
801083e6:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801083e9:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801083f0:	76 0d                	jbe    801083ff <inituvm+0x20>
    panic("inituvm: more than a page");
801083f2:	83 ec 0c             	sub    $0xc,%esp
801083f5:	68 69 90 10 80       	push   $0x80109069
801083fa:	e8 d2 81 ff ff       	call   801005d1 <panic>
  mem = kalloc();
801083ff:	e8 90 a9 ff ff       	call   80102d94 <kalloc>
80108404:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108407:	83 ec 04             	sub    $0x4,%esp
8010840a:	68 00 10 00 00       	push   $0x1000
8010840f:	6a 00                	push   $0x0
80108411:	ff 75 f4             	pushl  -0xc(%ebp)
80108414:	e8 2c d3 ff ff       	call   80105745 <memset>
80108419:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010841c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841f:	05 00 00 00 80       	add    $0x80000000,%eax
80108424:	83 ec 0c             	sub    $0xc,%esp
80108427:	6a 06                	push   $0x6
80108429:	50                   	push   %eax
8010842a:	68 00 10 00 00       	push   $0x1000
8010842f:	6a 00                	push   $0x0
80108431:	ff 75 08             	pushl  0x8(%ebp)
80108434:	e8 99 fc ff ff       	call   801080d2 <mappages>
80108439:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010843c:	83 ec 04             	sub    $0x4,%esp
8010843f:	ff 75 10             	pushl  0x10(%ebp)
80108442:	ff 75 0c             	pushl  0xc(%ebp)
80108445:	ff 75 f4             	pushl  -0xc(%ebp)
80108448:	e8 bf d3 ff ff       	call   8010580c <memmove>
8010844d:	83 c4 10             	add    $0x10,%esp
}
80108450:	90                   	nop
80108451:	c9                   	leave  
80108452:	c3                   	ret    

80108453 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108453:	f3 0f 1e fb          	endbr32 
80108457:	55                   	push   %ebp
80108458:	89 e5                	mov    %esp,%ebp
8010845a:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010845d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108460:	25 ff 0f 00 00       	and    $0xfff,%eax
80108465:	85 c0                	test   %eax,%eax
80108467:	74 0d                	je     80108476 <loaduvm+0x23>
    panic("loaduvm: addr must be page aligned");
80108469:	83 ec 0c             	sub    $0xc,%esp
8010846c:	68 84 90 10 80       	push   $0x80109084
80108471:	e8 5b 81 ff ff       	call   801005d1 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108476:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010847d:	e9 8f 00 00 00       	jmp    80108511 <loaduvm+0xbe>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108482:	8b 55 0c             	mov    0xc(%ebp),%edx
80108485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108488:	01 d0                	add    %edx,%eax
8010848a:	83 ec 04             	sub    $0x4,%esp
8010848d:	6a 00                	push   $0x0
8010848f:	50                   	push   %eax
80108490:	ff 75 08             	pushl  0x8(%ebp)
80108493:	e8 a0 fb ff ff       	call   80108038 <walkpgdir>
80108498:	83 c4 10             	add    $0x10,%esp
8010849b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010849e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084a2:	75 0d                	jne    801084b1 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801084a4:	83 ec 0c             	sub    $0xc,%esp
801084a7:	68 a7 90 10 80       	push   $0x801090a7
801084ac:	e8 20 81 ff ff       	call   801005d1 <panic>
    pa = PTE_ADDR(*pte);
801084b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084b4:	8b 00                	mov    (%eax),%eax
801084b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801084be:	8b 45 18             	mov    0x18(%ebp),%eax
801084c1:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084c4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801084c9:	77 0b                	ja     801084d6 <loaduvm+0x83>
      n = sz - i;
801084cb:	8b 45 18             	mov    0x18(%ebp),%eax
801084ce:	2b 45 f4             	sub    -0xc(%ebp),%eax
801084d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084d4:	eb 07                	jmp    801084dd <loaduvm+0x8a>
    else
      n = PGSIZE;
801084d6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801084dd:	8b 55 14             	mov    0x14(%ebp),%edx
801084e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e3:	01 d0                	add    %edx,%eax
801084e5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801084e8:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801084ee:	ff 75 f0             	pushl  -0x10(%ebp)
801084f1:	50                   	push   %eax
801084f2:	52                   	push   %edx
801084f3:	ff 75 10             	pushl  0x10(%ebp)
801084f6:	e8 b1 9a ff ff       	call   80101fac <readi>
801084fb:	83 c4 10             	add    $0x10,%esp
801084fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80108501:	74 07                	je     8010850a <loaduvm+0xb7>
      return -1;
80108503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108508:	eb 18                	jmp    80108522 <loaduvm+0xcf>
  for(i = 0; i < sz; i += PGSIZE){
8010850a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108514:	3b 45 18             	cmp    0x18(%ebp),%eax
80108517:	0f 82 65 ff ff ff    	jb     80108482 <loaduvm+0x2f>
  }
  return 0;
8010851d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108522:	c9                   	leave  
80108523:	c3                   	ret    

80108524 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108524:	f3 0f 1e fb          	endbr32 
80108528:	55                   	push   %ebp
80108529:	89 e5                	mov    %esp,%ebp
8010852b:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010852e:	8b 45 10             	mov    0x10(%ebp),%eax
80108531:	85 c0                	test   %eax,%eax
80108533:	79 0a                	jns    8010853f <allocuvm+0x1b>
    return 0;
80108535:	b8 00 00 00 00       	mov    $0x0,%eax
8010853a:	e9 ec 00 00 00       	jmp    8010862b <allocuvm+0x107>
  if(newsz < oldsz)
8010853f:	8b 45 10             	mov    0x10(%ebp),%eax
80108542:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108545:	73 08                	jae    8010854f <allocuvm+0x2b>
    return oldsz;
80108547:	8b 45 0c             	mov    0xc(%ebp),%eax
8010854a:	e9 dc 00 00 00       	jmp    8010862b <allocuvm+0x107>

  a = PGROUNDUP(oldsz);
8010854f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108552:	05 ff 0f 00 00       	add    $0xfff,%eax
80108557:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010855c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010855f:	e9 b8 00 00 00       	jmp    8010861c <allocuvm+0xf8>
    mem = kalloc();
80108564:	e8 2b a8 ff ff       	call   80102d94 <kalloc>
80108569:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010856c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108570:	75 2e                	jne    801085a0 <allocuvm+0x7c>
      cprintf("allocuvm out of memory\n");
80108572:	83 ec 0c             	sub    $0xc,%esp
80108575:	68 c5 90 10 80       	push   $0x801090c5
8010857a:	e8 99 7e ff ff       	call   80100418 <cprintf>
8010857f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108582:	83 ec 04             	sub    $0x4,%esp
80108585:	ff 75 0c             	pushl  0xc(%ebp)
80108588:	ff 75 10             	pushl  0x10(%ebp)
8010858b:	ff 75 08             	pushl  0x8(%ebp)
8010858e:	e8 9a 00 00 00       	call   8010862d <deallocuvm>
80108593:	83 c4 10             	add    $0x10,%esp
      return 0;
80108596:	b8 00 00 00 00       	mov    $0x0,%eax
8010859b:	e9 8b 00 00 00       	jmp    8010862b <allocuvm+0x107>
    }
    memset(mem, 0, PGSIZE);
801085a0:	83 ec 04             	sub    $0x4,%esp
801085a3:	68 00 10 00 00       	push   $0x1000
801085a8:	6a 00                	push   $0x0
801085aa:	ff 75 f0             	pushl  -0x10(%ebp)
801085ad:	e8 93 d1 ff ff       	call   80105745 <memset>
801085b2:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801085b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b8:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801085be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c1:	83 ec 0c             	sub    $0xc,%esp
801085c4:	6a 06                	push   $0x6
801085c6:	52                   	push   %edx
801085c7:	68 00 10 00 00       	push   $0x1000
801085cc:	50                   	push   %eax
801085cd:	ff 75 08             	pushl  0x8(%ebp)
801085d0:	e8 fd fa ff ff       	call   801080d2 <mappages>
801085d5:	83 c4 20             	add    $0x20,%esp
801085d8:	85 c0                	test   %eax,%eax
801085da:	79 39                	jns    80108615 <allocuvm+0xf1>
      cprintf("allocuvm out of memory (2)\n");
801085dc:	83 ec 0c             	sub    $0xc,%esp
801085df:	68 dd 90 10 80       	push   $0x801090dd
801085e4:	e8 2f 7e ff ff       	call   80100418 <cprintf>
801085e9:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085ec:	83 ec 04             	sub    $0x4,%esp
801085ef:	ff 75 0c             	pushl  0xc(%ebp)
801085f2:	ff 75 10             	pushl  0x10(%ebp)
801085f5:	ff 75 08             	pushl  0x8(%ebp)
801085f8:	e8 30 00 00 00       	call   8010862d <deallocuvm>
801085fd:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
80108600:	83 ec 0c             	sub    $0xc,%esp
80108603:	ff 75 f0             	pushl  -0x10(%ebp)
80108606:	e8 eb a6 ff ff       	call   80102cf6 <kfree>
8010860b:	83 c4 10             	add    $0x10,%esp
      return 0;
8010860e:	b8 00 00 00 00       	mov    $0x0,%eax
80108613:	eb 16                	jmp    8010862b <allocuvm+0x107>
  for(; a < newsz; a += PGSIZE){
80108615:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010861c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861f:	3b 45 10             	cmp    0x10(%ebp),%eax
80108622:	0f 82 3c ff ff ff    	jb     80108564 <allocuvm+0x40>
    }
  }
  return newsz;
80108628:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010862b:	c9                   	leave  
8010862c:	c3                   	ret    

8010862d <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010862d:	f3 0f 1e fb          	endbr32 
80108631:	55                   	push   %ebp
80108632:	89 e5                	mov    %esp,%ebp
80108634:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108637:	8b 45 10             	mov    0x10(%ebp),%eax
8010863a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010863d:	72 08                	jb     80108647 <deallocuvm+0x1a>
    return oldsz;
8010863f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108642:	e9 ac 00 00 00       	jmp    801086f3 <deallocuvm+0xc6>

  a = PGROUNDUP(newsz);
80108647:	8b 45 10             	mov    0x10(%ebp),%eax
8010864a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010864f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108654:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108657:	e9 88 00 00 00       	jmp    801086e4 <deallocuvm+0xb7>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010865c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865f:	83 ec 04             	sub    $0x4,%esp
80108662:	6a 00                	push   $0x0
80108664:	50                   	push   %eax
80108665:	ff 75 08             	pushl  0x8(%ebp)
80108668:	e8 cb f9 ff ff       	call   80108038 <walkpgdir>
8010866d:	83 c4 10             	add    $0x10,%esp
80108670:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108673:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108677:	75 16                	jne    8010868f <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867c:	c1 e8 16             	shr    $0x16,%eax
8010867f:	83 c0 01             	add    $0x1,%eax
80108682:	c1 e0 16             	shl    $0x16,%eax
80108685:	2d 00 10 00 00       	sub    $0x1000,%eax
8010868a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010868d:	eb 4e                	jmp    801086dd <deallocuvm+0xb0>
    else if((*pte & PTE_P) != 0){
8010868f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108692:	8b 00                	mov    (%eax),%eax
80108694:	83 e0 01             	and    $0x1,%eax
80108697:	85 c0                	test   %eax,%eax
80108699:	74 42                	je     801086dd <deallocuvm+0xb0>
      pa = PTE_ADDR(*pte);
8010869b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010869e:	8b 00                	mov    (%eax),%eax
801086a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086a8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086ac:	75 0d                	jne    801086bb <deallocuvm+0x8e>
        panic("kfree");
801086ae:	83 ec 0c             	sub    $0xc,%esp
801086b1:	68 f9 90 10 80       	push   $0x801090f9
801086b6:	e8 16 7f ff ff       	call   801005d1 <panic>
      char *v = P2V(pa);
801086bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086be:	05 00 00 00 80       	add    $0x80000000,%eax
801086c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801086c6:	83 ec 0c             	sub    $0xc,%esp
801086c9:	ff 75 e8             	pushl  -0x18(%ebp)
801086cc:	e8 25 a6 ff ff       	call   80102cf6 <kfree>
801086d1:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801086d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801086dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801086e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801086ea:	0f 82 6c ff ff ff    	jb     8010865c <deallocuvm+0x2f>
    }
  }
  return newsz;
801086f0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801086f3:	c9                   	leave  
801086f4:	c3                   	ret    

801086f5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801086f5:	f3 0f 1e fb          	endbr32 
801086f9:	55                   	push   %ebp
801086fa:	89 e5                	mov    %esp,%ebp
801086fc:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801086ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108703:	75 0d                	jne    80108712 <freevm+0x1d>
    panic("freevm: no pgdir");
80108705:	83 ec 0c             	sub    $0xc,%esp
80108708:	68 ff 90 10 80       	push   $0x801090ff
8010870d:	e8 bf 7e ff ff       	call   801005d1 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108712:	83 ec 04             	sub    $0x4,%esp
80108715:	6a 00                	push   $0x0
80108717:	68 00 00 00 80       	push   $0x80000000
8010871c:	ff 75 08             	pushl  0x8(%ebp)
8010871f:	e8 09 ff ff ff       	call   8010862d <deallocuvm>
80108724:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108727:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010872e:	eb 48                	jmp    80108778 <freevm+0x83>
    if(pgdir[i] & PTE_P){
80108730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108733:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010873a:	8b 45 08             	mov    0x8(%ebp),%eax
8010873d:	01 d0                	add    %edx,%eax
8010873f:	8b 00                	mov    (%eax),%eax
80108741:	83 e0 01             	and    $0x1,%eax
80108744:	85 c0                	test   %eax,%eax
80108746:	74 2c                	je     80108774 <freevm+0x7f>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108752:	8b 45 08             	mov    0x8(%ebp),%eax
80108755:	01 d0                	add    %edx,%eax
80108757:	8b 00                	mov    (%eax),%eax
80108759:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010875e:	05 00 00 00 80       	add    $0x80000000,%eax
80108763:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108766:	83 ec 0c             	sub    $0xc,%esp
80108769:	ff 75 f0             	pushl  -0x10(%ebp)
8010876c:	e8 85 a5 ff ff       	call   80102cf6 <kfree>
80108771:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108774:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108778:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010877f:	76 af                	jbe    80108730 <freevm+0x3b>
    }
  }
  kfree((char*)pgdir);
80108781:	83 ec 0c             	sub    $0xc,%esp
80108784:	ff 75 08             	pushl  0x8(%ebp)
80108787:	e8 6a a5 ff ff       	call   80102cf6 <kfree>
8010878c:	83 c4 10             	add    $0x10,%esp
}
8010878f:	90                   	nop
80108790:	c9                   	leave  
80108791:	c3                   	ret    

80108792 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108792:	f3 0f 1e fb          	endbr32 
80108796:	55                   	push   %ebp
80108797:	89 e5                	mov    %esp,%ebp
80108799:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010879c:	83 ec 04             	sub    $0x4,%esp
8010879f:	6a 00                	push   $0x0
801087a1:	ff 75 0c             	pushl  0xc(%ebp)
801087a4:	ff 75 08             	pushl  0x8(%ebp)
801087a7:	e8 8c f8 ff ff       	call   80108038 <walkpgdir>
801087ac:	83 c4 10             	add    $0x10,%esp
801087af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801087b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087b6:	75 0d                	jne    801087c5 <clearpteu+0x33>
    panic("clearpteu");
801087b8:	83 ec 0c             	sub    $0xc,%esp
801087bb:	68 10 91 10 80       	push   $0x80109110
801087c0:	e8 0c 7e ff ff       	call   801005d1 <panic>
  *pte &= ~PTE_U;
801087c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c8:	8b 00                	mov    (%eax),%eax
801087ca:	83 e0 fb             	and    $0xfffffffb,%eax
801087cd:	89 c2                	mov    %eax,%edx
801087cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d2:	89 10                	mov    %edx,(%eax)
}
801087d4:	90                   	nop
801087d5:	c9                   	leave  
801087d6:	c3                   	ret    

801087d7 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801087d7:	f3 0f 1e fb          	endbr32 
801087db:	55                   	push   %ebp
801087dc:	89 e5                	mov    %esp,%ebp
801087de:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801087e1:	e8 80 f9 ff ff       	call   80108166 <setupkvm>
801087e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801087e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087ed:	75 0a                	jne    801087f9 <copyuvm+0x22>
    return 0;
801087ef:	b8 00 00 00 00       	mov    $0x0,%eax
801087f4:	e9 f8 00 00 00       	jmp    801088f1 <copyuvm+0x11a>
  for(i = 0; i < sz; i += PGSIZE){
801087f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108800:	e9 c7 00 00 00       	jmp    801088cc <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108808:	83 ec 04             	sub    $0x4,%esp
8010880b:	6a 00                	push   $0x0
8010880d:	50                   	push   %eax
8010880e:	ff 75 08             	pushl  0x8(%ebp)
80108811:	e8 22 f8 ff ff       	call   80108038 <walkpgdir>
80108816:	83 c4 10             	add    $0x10,%esp
80108819:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010881c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108820:	75 0d                	jne    8010882f <copyuvm+0x58>
      panic("copyuvm: pte should exist");
80108822:	83 ec 0c             	sub    $0xc,%esp
80108825:	68 1a 91 10 80       	push   $0x8010911a
8010882a:	e8 a2 7d ff ff       	call   801005d1 <panic>
    if(!(*pte & PTE_P))
8010882f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108832:	8b 00                	mov    (%eax),%eax
80108834:	83 e0 01             	and    $0x1,%eax
80108837:	85 c0                	test   %eax,%eax
80108839:	75 0d                	jne    80108848 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010883b:	83 ec 0c             	sub    $0xc,%esp
8010883e:	68 34 91 10 80       	push   $0x80109134
80108843:	e8 89 7d ff ff       	call   801005d1 <panic>
    pa = PTE_ADDR(*pte);
80108848:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010884b:	8b 00                	mov    (%eax),%eax
8010884d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108852:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108855:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108858:	8b 00                	mov    (%eax),%eax
8010885a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010885f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108862:	e8 2d a5 ff ff       	call   80102d94 <kalloc>
80108867:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010886a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010886e:	74 6d                	je     801088dd <copyuvm+0x106>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108870:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108873:	05 00 00 00 80       	add    $0x80000000,%eax
80108878:	83 ec 04             	sub    $0x4,%esp
8010887b:	68 00 10 00 00       	push   $0x1000
80108880:	50                   	push   %eax
80108881:	ff 75 e0             	pushl  -0x20(%ebp)
80108884:	e8 83 cf ff ff       	call   8010580c <memmove>
80108889:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010888c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010888f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108892:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889b:	83 ec 0c             	sub    $0xc,%esp
8010889e:	52                   	push   %edx
8010889f:	51                   	push   %ecx
801088a0:	68 00 10 00 00       	push   $0x1000
801088a5:	50                   	push   %eax
801088a6:	ff 75 f0             	pushl  -0x10(%ebp)
801088a9:	e8 24 f8 ff ff       	call   801080d2 <mappages>
801088ae:	83 c4 20             	add    $0x20,%esp
801088b1:	85 c0                	test   %eax,%eax
801088b3:	79 10                	jns    801088c5 <copyuvm+0xee>
      kfree(mem);
801088b5:	83 ec 0c             	sub    $0xc,%esp
801088b8:	ff 75 e0             	pushl  -0x20(%ebp)
801088bb:	e8 36 a4 ff ff       	call   80102cf6 <kfree>
801088c0:	83 c4 10             	add    $0x10,%esp
      goto bad;
801088c3:	eb 19                	jmp    801088de <copyuvm+0x107>
  for(i = 0; i < sz; i += PGSIZE){
801088c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088d2:	0f 82 2d ff ff ff    	jb     80108805 <copyuvm+0x2e>
    }
  }
  return d;
801088d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088db:	eb 14                	jmp    801088f1 <copyuvm+0x11a>
      goto bad;
801088dd:	90                   	nop

bad:
  freevm(d);
801088de:	83 ec 0c             	sub    $0xc,%esp
801088e1:	ff 75 f0             	pushl  -0x10(%ebp)
801088e4:	e8 0c fe ff ff       	call   801086f5 <freevm>
801088e9:	83 c4 10             	add    $0x10,%esp
  return 0;
801088ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088f1:	c9                   	leave  
801088f2:	c3                   	ret    

801088f3 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801088f3:	f3 0f 1e fb          	endbr32 
801088f7:	55                   	push   %ebp
801088f8:	89 e5                	mov    %esp,%ebp
801088fa:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801088fd:	83 ec 04             	sub    $0x4,%esp
80108900:	6a 00                	push   $0x0
80108902:	ff 75 0c             	pushl  0xc(%ebp)
80108905:	ff 75 08             	pushl  0x8(%ebp)
80108908:	e8 2b f7 ff ff       	call   80108038 <walkpgdir>
8010890d:	83 c4 10             	add    $0x10,%esp
80108910:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108916:	8b 00                	mov    (%eax),%eax
80108918:	83 e0 01             	and    $0x1,%eax
8010891b:	85 c0                	test   %eax,%eax
8010891d:	75 07                	jne    80108926 <uva2ka+0x33>
    return 0;
8010891f:	b8 00 00 00 00       	mov    $0x0,%eax
80108924:	eb 22                	jmp    80108948 <uva2ka+0x55>
  if((*pte & PTE_U) == 0)
80108926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108929:	8b 00                	mov    (%eax),%eax
8010892b:	83 e0 04             	and    $0x4,%eax
8010892e:	85 c0                	test   %eax,%eax
80108930:	75 07                	jne    80108939 <uva2ka+0x46>
    return 0;
80108932:	b8 00 00 00 00       	mov    $0x0,%eax
80108937:	eb 0f                	jmp    80108948 <uva2ka+0x55>
  return (char*)P2V(PTE_ADDR(*pte));
80108939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893c:	8b 00                	mov    (%eax),%eax
8010893e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108943:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108948:	c9                   	leave  
80108949:	c3                   	ret    

8010894a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010894a:	f3 0f 1e fb          	endbr32 
8010894e:	55                   	push   %ebp
8010894f:	89 e5                	mov    %esp,%ebp
80108951:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108954:	8b 45 10             	mov    0x10(%ebp),%eax
80108957:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010895a:	eb 7f                	jmp    801089db <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
8010895c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010895f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108964:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108967:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010896a:	83 ec 08             	sub    $0x8,%esp
8010896d:	50                   	push   %eax
8010896e:	ff 75 08             	pushl  0x8(%ebp)
80108971:	e8 7d ff ff ff       	call   801088f3 <uva2ka>
80108976:	83 c4 10             	add    $0x10,%esp
80108979:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010897c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108980:	75 07                	jne    80108989 <copyout+0x3f>
      return -1;
80108982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108987:	eb 61                	jmp    801089ea <copyout+0xa0>
    n = PGSIZE - (va - va0);
80108989:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010898c:	2b 45 0c             	sub    0xc(%ebp),%eax
8010898f:	05 00 10 00 00       	add    $0x1000,%eax
80108994:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010899a:	3b 45 14             	cmp    0x14(%ebp),%eax
8010899d:	76 06                	jbe    801089a5 <copyout+0x5b>
      n = len;
8010899f:	8b 45 14             	mov    0x14(%ebp),%eax
801089a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801089a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801089a8:	2b 45 ec             	sub    -0x14(%ebp),%eax
801089ab:	89 c2                	mov    %eax,%edx
801089ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089b0:	01 d0                	add    %edx,%eax
801089b2:	83 ec 04             	sub    $0x4,%esp
801089b5:	ff 75 f0             	pushl  -0x10(%ebp)
801089b8:	ff 75 f4             	pushl  -0xc(%ebp)
801089bb:	50                   	push   %eax
801089bc:	e8 4b ce ff ff       	call   8010580c <memmove>
801089c1:	83 c4 10             	add    $0x10,%esp
    len -= n;
801089c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089c7:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089cd:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801089d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089d3:	05 00 10 00 00       	add    $0x1000,%eax
801089d8:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
801089db:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801089df:	0f 85 77 ff ff ff    	jne    8010895c <copyout+0x12>
  }
  return 0;
801089e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089ea:	c9                   	leave  
801089eb:	c3                   	ret    
